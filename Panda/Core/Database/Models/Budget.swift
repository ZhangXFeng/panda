//
//  Budget.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

/// 预算模型
@Model
final class Budget {
    // MARK: - Properties

    /// 唯一标识符
    var id: UUID

    /// 总预算金额
    var totalAmount: Decimal

    /// 预算预警阈值（百分比，如 0.8 表示 80%）
    var warningThreshold: Double

    /// 创建时间
    var createdAt: Date

    /// 最后更新时间
    var updatedAt: Date

    // MARK: - Relationships

    /// 关联的项目（反向关系）
    var project: Project?

    /// 支出记录（一对多关系）
    @Relationship(deleteRule: .cascade, inverse: \Expense.budget)
    var expenses: [Expense]

    // MARK: - Initialization

    init(
        totalAmount: Decimal,
        warningThreshold: Double = 0.8
    ) {
        self.id = UUID()
        self.totalAmount = totalAmount
        self.warningThreshold = warningThreshold
        self.createdAt = Date()
        self.updatedAt = Date()
        self.expenses = []
    }

    // MARK: - Computed Properties

    /// 已支出总额
    var totalExpenses: Decimal {
        expenses.reduce(Decimal.zero) { $0 + $1.amount }
    }

    /// 剩余预算
    var remainingBudget: Decimal {
        totalAmount - totalExpenses
    }

    /// 预算使用率（百分比）
    var usagePercentage: Double {
        guard totalAmount > 0 else { return 0 }
        return Double(truncating: (totalExpenses / totalAmount) as NSNumber)
    }

    /// 是否超支
    var isOverBudget: Bool {
        totalExpenses > totalAmount
    }

    /// 是否达到预警阈值
    var hasReachedWarningThreshold: Bool {
        usagePercentage >= warningThreshold
    }

    /// 预计超支金额（如果有）
    var estimatedOverage: Decimal {
        guard isOverBudget else { return 0 }
        return totalExpenses - totalAmount
    }

    // MARK: - Category Statistics

    /// 按分类统计支出
    func expensesByCategory() -> [ExpenseCategory: Decimal] {
        var result: [ExpenseCategory: Decimal] = [:]

        for expense in expenses {
            let current = result[expense.category] ?? 0
            result[expense.category] = current + expense.amount
        }

        return result
    }

    /// 按父分类统计支出
    func expensesByParentCategory() -> [ParentCategory: Decimal] {
        var result: [ParentCategory: Decimal] = [:]

        for expense in expenses {
            let parentCategory = expense.category.parentCategory
            let current = result[parentCategory] ?? 0
            result[parentCategory] = current + expense.amount
        }

        return result
    }

    /// 获取指定分类的支出总额
    func totalExpenses(for category: ExpenseCategory) -> Decimal {
        expenses
            .filter { $0.category == category }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    /// 获取指定父分类的支出总额
    func totalExpenses(for parentCategory: ParentCategory) -> Decimal {
        expenses
            .filter { $0.category.parentCategory == parentCategory }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    // MARK: - Time-based Statistics

    /// 获取本月支出
    func currentMonthExpenses() -> Decimal {
        let calendar = Calendar.current
        let now = Date()

        return expenses
            .filter { expense in
                calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
            }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    /// 获取指定月份的支出
    func expenses(for date: Date) -> Decimal {
        let calendar = Calendar.current

        return expenses
            .filter { expense in
                calendar.isDate(expense.date, equalTo: date, toGranularity: .month)
            }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    /// 按月份分组的支出统计
    func expensesByMonth() -> [Date: Decimal] {
        var result: [Date: Decimal] = [:]
        let calendar = Calendar.current

        for expense in expenses {
            // 获取月份开始日期
            let components = calendar.dateComponents([.year, .month], from: expense.date)
            guard let monthStart = calendar.date(from: components) else { continue }

            let current = result[monthStart] ?? 0
            result[monthStart] = current + expense.amount
        }

        return result
    }
}

// MARK: - Helper Methods

extension Budget {
    /// 更新时间戳
    func updateTimestamp() {
        updatedAt = Date()
    }

    /// 添加支出
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        updateTimestamp()
    }

    /// 删除支出
    func removeExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        updateTimestamp()
    }

    /// 更新总预算
    func updateTotalAmount(_ newAmount: Decimal) {
        totalAmount = newAmount
        updateTimestamp()
    }

    /// 更新预警阈值
    func updateWarningThreshold(_ threshold: Double) {
        warningThreshold = max(0, min(1, threshold))
        updateTimestamp()
    }
}
