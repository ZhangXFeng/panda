//
//  AddExpenseViewModel.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class AddExpenseViewModel {
    private let recordExpenseUseCase: RecordExpenseUseCase

    var amount: String = ""
    var category: ExpenseCategory = .other
    var date: Date = Date()
    var notes: String = ""
    var vendor: String = ""
    var paymentType: PaymentType = .fullPayment
    var photoData: [Data] = []
    var isLoading = false
    var errorMessage: String?

    init(modelContext: ModelContext) {
        let budgetRepo = BudgetRepository(modelContext: modelContext)
        let expenseRepo = ExpenseRepository(modelContext: modelContext)
        self.recordExpenseUseCase = RecordExpenseUseCase(
            budgetRepository: budgetRepo,
            expenseRepository: expenseRepo
        )
    }

    func saveExpense(to budget: Budget) async -> Bool {
        guard let decimalAmount = Decimal(string: amount) else {
            errorMessage = "请输入有效的金额"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
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
