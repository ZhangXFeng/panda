//
//  AddExpenseViewModel.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

@MainActor
class AddExpenseViewModel: ObservableObject {
    private let recordExpenseUseCase: RecordExpenseUseCase
    private let budget: Budget
    private var expenseToEdit: Expense?

    @Published var amount: String = ""
    @Published var category: ExpenseCategory = .other
    @Published var date: Date = Date()
    @Published var notes: String = ""
    @Published var vendor: String = ""
    @Published var paymentType: PaymentType = .fullPayment
    @Published var photoData: [Data] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isEditMode: Bool {
        expenseToEdit != nil
    }

    var title: String {
        isEditMode ? "编辑支出" : "记一笔"
    }

    init(modelContext: ModelContext, budget: Budget, expense: Expense? = nil) {
        let budgetRepo = BudgetRepository(modelContext: modelContext)
        let expenseRepo = ExpenseRepository(modelContext: modelContext)
        self.recordExpenseUseCase = RecordExpenseUseCase(
            budgetRepository: budgetRepo,
            expenseRepository: expenseRepo
        )
        self.budget = budget
        self.expenseToEdit = expense

        if let expense = expense {
            loadExpense(expense)
        }
    }

    private func loadExpense(_ expense: Expense) {
        amount = NSDecimalNumber(decimal: expense.amount).stringValue
        category = expense.category
        date = expense.date
        notes = expense.notes
        vendor = expense.vendor
        paymentType = expense.paymentType
        photoData = expense.photoData
    }

    func saveExpense() async -> Bool {
        guard let decimalAmount = Decimal(string: amount) else {
            errorMessage = "请输入有效的金额"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            if let expense = expenseToEdit {
                // Edit mode
                try await recordExpenseUseCase.update(
                    expense: expense,
                    amount: decimalAmount,
                    category: category,
                    date: date,
                    notes: notes,
                    paymentType: paymentType,
                    vendor: vendor
                )
            } else {
                // Add mode
                _ = try await recordExpenseUseCase.execute(
                    amount: decimalAmount,
                    category: category,
                    date: date,
                    notes: notes,
                    photoData: photoData,
                    paymentType: paymentType,
                    vendor: vendor,
                    in: budget
                )
            }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func reset() {
        amount = ""
        category = .other
        date = Date()
        notes = ""
        vendor = ""
        paymentType = .fullPayment
        photoData = []
        errorMessage = nil
    }
}
