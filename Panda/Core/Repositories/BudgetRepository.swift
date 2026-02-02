//
//  BudgetRepository.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

/// 预算数据仓库
@MainActor
final class BudgetRepository {
    // MARK: - Properties

    private let modelContext: ModelContext

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD Operations

    /// 创建预算
    func create(_ budget: Budget) throws {
        modelContext.insert(budget)
        try modelContext.save()
    }

    /// 获取预算
    func fetch(by id: UUID) throws -> Budget? {
        let descriptor = FetchDescriptor<Budget>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    /// 获取项目的预算
    func fetchBudget(for project: Project) throws -> Budget? {
        let projectId = project.id
        let descriptor = FetchDescriptor<Budget>(
            predicate: #Predicate<Budget> { budget in
                budget.project?.id == projectId
            }
        )
        return try modelContext.fetch(descriptor).first
    }

    /// 更新预算
    func update(_ budget: Budget) throws {
        budget.updateTimestamp()
        try modelContext.save()
    }

    /// 删除预算
    func delete(_ budget: Budget) throws {
        modelContext.delete(budget)
        try modelContext.save()
    }

    // MARK: - Business Operations

    /// 更新总预算金额
    func updateTotalAmount(for budget: Budget, amount: Decimal) throws {
        budget.updateTotalAmount(amount)
        try modelContext.save()
    }

    /// 更新预警阈值
    func updateWarningThreshold(for budget: Budget, threshold: Double) throws {
        budget.updateWarningThreshold(threshold)
        try modelContext.save()
    }

    /// 获取预算统计信息
    func getBudgetStatistics(for budget: Budget) -> BudgetStatistics {
        BudgetStatistics(
            totalBudget: budget.totalAmount,
            totalExpenses: budget.totalExpenses,
            remainingBudget: budget.remainingBudget,
            usagePercentage: budget.usagePercentage,
            isOverBudget: budget.isOverBudget,
            hasReachedWarningThreshold: budget.hasReachedWarningThreshold,
            currentMonthExpenses: budget.currentMonthExpenses()
        )
    }

    /// 获取分类统计
    func getCategoryStatistics(for budget: Budget) -> [ExpenseCategory: CategoryStatistic] {
        let expensesByCategory = budget.expensesByCategory()
        var result: [ExpenseCategory: CategoryStatistic] = [:]

        for category in ExpenseCategory.allCases {
            let amount = expensesByCategory[category] ?? 0
            let percentage = budget.totalExpenses > 0
                ? Double(truncating: (amount / budget.totalExpenses) as NSNumber)
                : 0

            result[category] = CategoryStatistic(
                category: category,
                amount: amount,
                percentage: percentage
            )
        }

        return result
    }
}

// MARK: - Statistics Models

/// 预算统计信息
struct BudgetStatistics {
    let totalBudget: Decimal
    let totalExpenses: Decimal
    let remainingBudget: Decimal
    let usagePercentage: Double
    let isOverBudget: Bool
    let hasReachedWarningThreshold: Bool
    let currentMonthExpenses: Decimal
}

/// 分类统计信息
struct CategoryStatistic {
    let category: ExpenseCategory
    let amount: Decimal
    let percentage: Double

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0.00"
    }

    var formattedPercentage: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: percentage)) ?? "0%"
    }
}
