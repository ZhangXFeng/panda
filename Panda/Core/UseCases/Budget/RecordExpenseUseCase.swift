//
//  RecordExpenseUseCase.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation

/// 记录支出用例
@MainActor
final class RecordExpenseUseCase {
    // MARK: - Properties

    private let budgetRepository: BudgetRepository
    private let expenseRepository: ExpenseRepository

    // MARK: - Initialization

    init(
        budgetRepository: BudgetRepository,
        expenseRepository: ExpenseRepository
    ) {
        self.budgetRepository = budgetRepository
        self.expenseRepository = expenseRepository
    }

    // MARK: - Execute

    /// 记录新支出
    func execute(
        amount: Decimal,
        category: ExpenseCategory,
        date: Date,
        notes: String,
        photoData: [Data],
        paymentType: PaymentType,
        vendor: String,
        in budget: Budget
    ) async throws -> Expense {
        // 验证输入
        try validate(amount: amount)

        // 创建支出记录
        let expense = Expense(
            amount: amount,
            category: category,
            date: date,
            notes: notes,
            photoData: photoData,
            paymentType: paymentType,
            vendor: vendor
        )

        // 保存到数据库
        try expenseRepository.create(expense, in: budget)

        // 检查预算预警
        await checkBudgetWarning(for: budget)

        return expense
    }

    /// 更新支出记录
    func update(
        expense: Expense,
        amount: Decimal? = nil,
        category: ExpenseCategory? = nil,
        date: Date? = nil,
        notes: String? = nil,
        paymentType: PaymentType? = nil,
        vendor: String? = nil
    ) async throws {
        // 更新字段
        if let amount = amount {
            try validate(amount: amount)
            expense.updateAmount(amount)
        }

        if let category = category {
            expense.updateCategory(category)
        }

        if let date = date {
            expense.date = date
        }

        if let notes = notes {
            expense.updateNotes(notes)
        }

        if let paymentType = paymentType {
            expense.paymentType = paymentType
        }

        if let vendor = vendor {
            expense.vendor = vendor
        }

        // 保存更新
        try expenseRepository.update(expense)

        // 检查预算预警
        if let budget = expense.budget {
            await checkBudgetWarning(for: budget)
        }
    }

    /// 删除支出记录
    func delete(expense: Expense) async throws {
        try expenseRepository.delete(expense)
    }

    // MARK: - Validation

    private func validate(amount: Decimal) throws {
        guard amount > 0 else {
            throw ValidationError.invalidAmount("金额必须大于0")
        }

        guard amount < 10_000_000 else {
            throw ValidationError.invalidAmount("金额不能超过1000万")
        }
    }

    // MARK: - Budget Warning

    private func checkBudgetWarning(for budget: Budget) async {
        // 检查是否达到预警阈值
        if budget.hasReachedWarningThreshold {
            // 发送通知
            await sendBudgetWarningNotification(budget: budget)
        }

        // 检查是否超支
        if budget.isOverBudget {
            // 发送超支通知
            await sendOverBudgetNotification(budget: budget)
        }
    }

    private func sendBudgetWarningNotification(budget: Budget) async {
        // TODO: 实现通知逻辑
        print("⚠️ 预算预警：已使用 \(Int(budget.usagePercentage * 100))%")
    }

    private func sendOverBudgetNotification(budget: Budget) async {
        // TODO: 实现通知逻辑
        print("🚨 预算超支：超出 \(budget.estimatedOverage)")
    }
}

// MARK: - Validation Error

enum ValidationError: LocalizedError {
    case invalidAmount(String)
    case invalidDate(String)
    case invalidCategory(String)

    var errorDescription: String? {
        switch self {
        case .invalidAmount(let message),
             .invalidDate(let message),
             .invalidCategory(let message):
            return message
        }
    }
}
