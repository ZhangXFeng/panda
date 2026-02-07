//
//  ExpenseListView.swift
//  Panda
//
//  Created on 2026-02-07.
//

import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ExpenseListViewModel?
    @State private var showingAddExpense = false
    @State private var selectedExpense: Expense?

    let budget: Budget

    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            searchBar

            // 分类筛选
            categoryFilterSection

            // 列表内容
            if let viewModel = viewModel {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !viewModel.monthGroups.isEmpty && viewModel.selectedCategory == nil && viewModel.searchText.isEmpty {
                    monthGroupedList(viewModel: viewModel)
                } else if !viewModel.expenses.isEmpty {
                    flatExpenseList(viewModel: viewModel)
                } else {
                    emptyState
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("支出明细")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(modelContext: modelContext, budget: budget)
                .onDisappear {
                    _Concurrency.Task {
                        await loadData()
                    }
                }
        }
        .sheet(item: $selectedExpense) { expense in
            AddExpenseView(modelContext: modelContext, budget: budget, expense: expense)
                .onDisappear {
                    _Concurrency.Task {
                        await loadData()
                    }
                }
        }
        .task {
            await loadData()
        }

        if let error = viewModel?.errorMessage {
            Text(error)
                .foregroundColor(.error)
                .font(.captionRegular)
                .padding()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textHint)
            TextField("搜索备注、商家", text: Binding(
                get: { viewModel?.searchText ?? "" },
                set: { newValue in
                    viewModel?.searchText = newValue
                    _Concurrency.Task {
                        await loadData()
                    }
                }
            ))
            .autocorrectionDisabled()

            if !(viewModel?.searchText.isEmpty ?? true) {
                Button {
                    viewModel?.searchText = ""
                    _Concurrency.Task {
                        await loadData()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textHint)
                }
            }
        }
        .padding(Spacing.sm)
        .background(Color.bgCard)
        .cornerRadius(CornerRadius.md)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Category Filter

    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                FilterChip(
                    title: "全部",
                    isSelected: viewModel?.selectedCategory == nil
                ) {
                    viewModel?.selectedCategory = nil
                    _Concurrency.Task {
                        await loadData()
                    }
                }

                ForEach(ExpenseCategory.allCases) { category in
                    FilterChip(
                        title: category.displayName,
                        isSelected: viewModel?.selectedCategory == category
                    ) {
                        viewModel?.selectedCategory = category
                        _Concurrency.Task {
                            await loadData()
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Month Grouped List

    private func monthGroupedList(viewModel: ExpenseListViewModel) -> some View {
        List {
            ForEach(viewModel.monthGroups) { group in
                Section {
                    ForEach(group.expenses) { expense in
                        ExpenseRow(expense: expense)
                            .onTapGesture {
                                selectedExpense = expense
                            }
                    }
                    .onDelete { offsets in
                        deleteExpenses(at: offsets, from: group.expenses)
                    }
                } header: {
                    HStack {
                        Text(group.formattedMonth)
                            .font(.headline)
                        Spacer()
                        Text(group.formattedTotal)
                            .font(.captionMedium)
                            .foregroundColor(.primaryWood)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Flat Expense List

    private func flatExpenseList(viewModel: ExpenseListViewModel) -> some View {
        List {
            ForEach(viewModel.expenses) { expense in
                ExpenseRow(expense: expense)
                    .onTapGesture {
                        selectedExpense = expense
                    }
            }
            .onDelete { offsets in
                deleteExpenses(at: offsets, from: viewModel.expenses)
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.textHint)

            Text("暂无支出记录")
                .font(.titleSmall)
                .foregroundColor(.textSecondary)

            Text("点击右上角 + 记一笔")
                .font(.bodyRegular)
                .foregroundColor(.textHint)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Methods

    private func loadData() async {
        if viewModel == nil {
            viewModel = ExpenseListViewModel(modelContext: modelContext)
        }
        await viewModel?.loadExpenses(for: budget)
    }

    private func deleteExpenses(at offsets: IndexSet, from expenses: [Expense]) {
        for index in offsets {
            let expense = expenses[index]
            _Concurrency.Task {
                await viewModel?.deleteExpense(expense, from: budget)
            }
        }
    }
}

// MARK: - Expense Row

private struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: Spacing.md) {
            // 分类图标
            ZStack {
                Circle()
                    .fill(Color.primaryWood.opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: expense.category.iconName)
                    .foregroundColor(.primaryWood)
                    .font(.system(size: 18))
            }

            // 信息
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(expense.category.displayName)
                    .font(.bodyMedium)

                if !expense.notes.isEmpty {
                    Text(expense.notes)
                        .font(.captionRegular)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                } else if !expense.vendor.isEmpty {
                    Text(expense.vendor)
                        .font(.captionRegular)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 金额和日期
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                Text(expense.formattedAmount)
                    .font(.numberSmall)
                    .foregroundColor(.primaryWood)

                Text(expense.formattedDate)
                    .font(.captionRegular)
                    .foregroundColor(.textHint)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Budget.self, Expense.self, configurations: config)
    let budget = Budget(totalAmount: 180000)
    container.mainContext.insert(budget)

    return NavigationStack {
        ExpenseListView(budget: budget)
    }
    .modelContainer(container)
}
