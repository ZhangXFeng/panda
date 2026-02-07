//
//  AddExpenseView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddExpenseViewModel

    init(modelContext: ModelContext, budget: Budget, expense: Expense? = nil) {
        _viewModel = StateObject(wrappedValue: AddExpenseViewModel(
            modelContext: modelContext,
            budget: budget,
            expense: expense
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                // 金额
                Section("金额") {
                    HStack {
                        Text("¥")
                            .font(.numberMedium)
                            .foregroundColor(.textSecondary)
                        TextField("0.00", text: $viewModel.amount)
                            .keyboardType(.decimalPad)
                            .font(.numberMedium)
                    }
                }

                // 分类
                Section("分类") {
                    Picker("选择分类", selection: $viewModel.category) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.iconName)
                                .tag(category)
                        }
                    }
                }

                // 日期
                Section("日期") {
                    DatePicker("支出日期", selection: $viewModel.date, displayedComponents: .date)
                }

                // 付款方式
                Section("付款方式") {
                    Picker("选择方式", selection: $viewModel.paymentType) {
                        ForEach(PaymentType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 供应商
                Section("供应商/商家") {
                    TextField("供应商名称（可选）", text: $viewModel.vendor)
                }

                // 备注
                Section("备注") {
                    TextEditor(text: $viewModel.notes)
                        .frame(height: 80)
                }

                // 错误提示
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.error)
                            .font(.captionRegular)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveExpense()
                    }
                    .disabled(viewModel.amount.isEmpty)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func saveExpense() {
        _Concurrency.Task {
            if await viewModel.saveExpense() == true {
                dismiss()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Budget.self, configurations: config)
    let budget = Budget(totalAmount: 180000)
    container.mainContext.insert(budget)

    return AddExpenseView(modelContext: container.mainContext, budget: budget)
        .modelContainer(container)
}
