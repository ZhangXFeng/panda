//
//  ExpenseListViewModel.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class ExpenseListViewModel {
    private let expenseRepository: ExpenseRepository
    private let modelContext: ModelContext

    var expenses: [Expense] = []
    var monthGroups: [MonthGroup] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""
    var selectedCategory: ExpenseCategory?
    var sortOption: ExpenseSortOption = .dateDescending

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.expenseRepository = ExpenseRepository(modelContext: modelContext)
    }

    func loadExpenses(for budget: Budget) async {
        isLoading = true
        errorMessage = nil

        do {
            if !searchText.isEmpty {
                expenses = try expenseRepository.search(for: budget, keyword: searchText)
            } else if let category = selectedCategory {
                expenses = try expenseRepository.fetchExpenses(for: budget, category: category)
            } else {
                expenses = try expenseRepository.fetchAll(for: budget, sortBy: sortOption)
                monthGroups = try expenseRepository.fetchGroupedByMonth(for: budget)
            }
        } catch {
            // Fallback to in-memory filtering if predicate fails on device
            do {
                let allExpenses = try expenseRepository.fetchAll(for: budget, sortBy: sortOption)
                if !searchText.isEmpty {
                    let keyword = searchText.lowercased()
                    expenses = allExpenses.filter { expense in
                        expense.notes.localizedStandardContains(keyword) ||
                        expense.vendor.localizedStandardContains(keyword)
                    }
                } else if let category = selectedCategory {
                    expenses = allExpenses.filter { $0.category == category }
                } else {
                    expenses = allExpenses
                }
                monthGroups = []
                errorMessage = nil
            } catch {
                let nsError = error as NSError
                errorMessage = "加载支出记录失败: \(error.localizedDescription)（\(nsError.domain) \(nsError.code)）"
            }
        }

        isLoading = false
    }

    func deleteExpense(_ expense: Expense, from budget: Budget) async {
        do {
            try expenseRepository.delete(expense)
            await loadExpenses(for: budget)
        } catch {
            errorMessage = "删除失败: \(error.localizedDescription)"
        }
    }
}
