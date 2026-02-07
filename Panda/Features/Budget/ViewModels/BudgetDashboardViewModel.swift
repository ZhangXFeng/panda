//
//  BudgetDashboardViewModel.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftUI
import SwiftData

/// 预算仪表盘 ViewModel
@MainActor
@Observable
final class BudgetDashboardViewModel {
    // MARK: - Properties

    private let budgetRepository: BudgetRepository
    private let expenseRepository: ExpenseRepository
    private let modelContext: ModelContext

    var budget: Budget?
    var statistics: BudgetStatistics?
    var categoryStatistics: [CategoryStatistic] = []
    var recentExpenses: [Expense] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.budgetRepository = BudgetRepository(modelContext: modelContext)
        self.expenseRepository = ExpenseRepository(modelContext: modelContext)
    }

    // MARK: - Public Methods

    func loadBudget(for project: Project) async {
        isLoading = true
        errorMessage = nil

        do {
            budget = try budgetRepository.fetchBudget(for: project)

            if let budget = budget {
                statistics = budgetRepository.getBudgetStatistics(for: budget)
                categoryStatistics = Array(budgetRepository.getCategoryStatistics(for: budget).values)
                    .sorted { $0.amount > $1.amount }
                recentExpenses = try expenseRepository.fetchTopRecent(for: budget, limit: 3)
            }
        } catch {
            errorMessage = "加载预算失败: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func createBudget(for project: Project, amount: Decimal) async {
        do {
            let newBudget = Budget(totalAmount: amount)
            newBudget.project = project
            try budgetRepository.create(newBudget)
            budget = newBudget
            await loadBudget(for: project)
        } catch {
            errorMessage = "创建预算失败: \(error.localizedDescription)"
        }
    }

    func updateTotalBudget(amount: Decimal) async {
        guard let budget = budget else { return }

        do {
            try budgetRepository.updateTotalAmount(for: budget, amount: amount)
            if let project = budget.project {
                await loadBudget(for: project)
            }
        } catch {
            errorMessage = "更新预算失败: \(error.localizedDescription)"
        }
    }

    // MARK: - Computed Properties

    var totalBudgetFormatted: String {
        formatCurrency(statistics?.totalBudget ?? 0)
    }

    var totalExpensesFormatted: String {
        formatCurrency(statistics?.totalExpenses ?? 0)
    }

    var remainingBudgetFormatted: String {
        formatCurrency(statistics?.remainingBudget ?? 0)
    }

    var usagePercentage: Double {
        statistics?.usagePercentage ?? 0
    }

    var currentMonthExpensesFormatted: String {
        formatCurrency(statistics?.currentMonthExpenses ?? 0)
    }

    var hasWarning: Bool {
        statistics?.hasReachedWarningThreshold ?? false
    }

    var isOverBudget: Bool {
        statistics?.isOverBudget ?? false
    }

    // MARK: - Private Helpers

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0.00"
    }
}
