//
//  AddExpenseView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddExpenseViewModel?

    let budget: Budget

    var body: some View {
        NavigationStack {
            Form {
                // 金额
                Section("金额") {
                    HStack {
                        Text("¥")
                            .font(.numberMedium)
                            .foregroundColor(.textSecondary)
                        TextField("0.00", text: Binding(
                            get: { viewModel?.amount ?? "" },
                            set: { viewModel?.amount = $0 }
                        ))
                        .keyboardType(.decimalPad)
                        .font(.numberMedium)
                    }
                }

                // 分类
                Section("分类") {
                    Picker("选择分类", selection: Binding(
                        get: { viewModel?.category ?? .other },
                        set: { viewModel?.category = $0 }
                    )) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.iconName)
                                .tag(category)
                        }
                    }
                }

                // 日期
                Section("日期") {
                    DatePicker("支出日期", selection: Binding(
                        get: { viewModel?.date ?? Date() },
                        set: { viewModel?.date = $0 }
                    ), displayedComponents: .date)
                }

                // 付款方式
                Section("付款方式") {
                    Picker("选择方式", selection: Binding(
                        get: { viewModel?.paymentType ?? .fullPayment },
                        set: { viewModel?.paymentType = $0 }
                    )) {
                        ForEach(PaymentType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 供应商
                Section("供应商/商家") {
                    TextField("供应商名称（可选）", text: Binding(
                        get: { viewModel?.vendor ?? "" },
                        set: { viewModel?.vendor = $0 }
                    ))
                }

                // 备注
                Section("备注") {
                    TextEditor(text: Binding(
                        get: { viewModel?.notes ?? "" },
                        set: { viewModel?.notes = $0 }
                    ))
                    .frame(height: 80)
                }

                // 错误提示
                if let error = viewModel?.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.error)
                            .font(.captionRegular)
                    }
                }
            }
            .navigationTitle("记一笔")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("取消") {
                    dismiss()
                },
                trailing: Button("保存") {
                    saveExpense()
                }
                .disabled(viewModel?.amount.isEmpty ?? true)
            )
            .task {
                if viewModel == nil {
                    viewModel = AddExpenseViewModel(modelContext: modelContext)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func saveExpense() {
        _Concurrency.Task {
            await performSave()
        }
    }

    @MainActor
    private func performSave() async {
        if await viewModel?.saveExpense(to: budget) == true {
            dismiss()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Budget.self, configurations: config)
    let budget = Budget(totalAmount: 180000)

    return AddExpenseView(budget: budget)
        .modelContainer(container)
}
