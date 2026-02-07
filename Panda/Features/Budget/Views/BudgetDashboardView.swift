//
//  BudgetDashboardView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct BudgetDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ProjectManager.self) private var projectManager
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]
    @State private var viewModel: BudgetDashboardViewModel?
    @State private var showingAddExpense = false
    @State private var refreshID = UUID()
    @State private var showingEditBudget = false
    @State private var editBudgetText = ""
    @State private var showingBudgetError = false
    @State private var budgetErrorMessage = ""

    /// 当前选中的项目
    private var currentProject: Project? {
        projectManager.currentProject(from: projects)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel, viewModel.budget != nil {
                    ScrollView {
                        VStack(spacing: Spacing.md) {
                            // 总预算卡片（含本月支出）
                            totalBudgetCard(viewModel: viewModel)

                            // 支出明细（最近几笔 + 查看全部入口）
                            recentExpensesSection(viewModel: viewModel)

                            // 分类统计
                            categoryStatisticsSection(viewModel: viewModel)
                        }
                        .padding()
                    }
                    .refreshable {
                        await loadData()
                    }
                } else {
                    emptyState
                }
            }
            .id(refreshID)
            .navigationTitle("预算管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        prepareEditBudget()
                        showingEditBudget = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        _Concurrency.Task {
                            await loadData()
                            refreshID = UUID()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                if let budget = viewModel?.budget {
                    AddExpenseView(modelContext: modelContext, budget: budget)
                }
            }
            .alert("设置总预算", isPresented: $showingEditBudget) {
                TextField("总预算", text: $editBudgetText)
                    .keyboardType(.decimalPad)
                Button("取消", role: .cancel) { }
                Button("保存") {
                    saveEditedBudget()
                }
            } message: {
                Text("请输入新的总预算金额")
            }
            .alert("错误", isPresented: $showingBudgetError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(budgetErrorMessage)
            }
            .task {
                await loadData()
            }
            .onAppear {
                _Concurrency.Task {
                    await loadData()
                }
            }
        }
    }

    // MARK: - Components

    private func totalBudgetCard(viewModel: BudgetDashboardViewModel) -> some View {
        CardView {
            VStack(spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("总预算")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        Text(viewModel.totalBudgetFormatted)
                            .font(.numberLarge)
                    }
                    Spacer()
                }

                ProgressRing(progress: viewModel.usagePercentage, size: 100)

                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("已支出")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        Text(viewModel.totalExpensesFormatted)
                            .font(.numberSmall)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        Text("剩余")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        Text(viewModel.remainingBudgetFormatted)
                            .font(.numberSmall)
                            .foregroundColor(.success)
                    }
                }

                Divider()

                HStack {
                    Text("本月支出")
                        .font(.captionRegular)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text(viewModel.currentMonthExpensesFormatted)
                        .font(.numberSmall)
                }

                if viewModel.hasWarning {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.warning)
                        Text("超支预警")
                            .font(.captionMedium)
                            .foregroundColor(.warning)
                    }
                    .padding(.vertical, Spacing.xs)
                }
            }
        }
    }

    private func recentExpensesSection(viewModel: BudgetDashboardViewModel) -> some View {
        VStack(spacing: Spacing.sm) {
            if let budget = viewModel.budget {
                HStack {
                    Text("支出明细")
                        .font(.titleSmall)
                    Spacer()
                    NavigationLink {
                        ExpenseListView(budget: budget)
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Text("查看全部")
                                .font(.captionRegular)
                                .foregroundColor(.textSecondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.textHint)
                        }
                    }
                }

                if viewModel.recentExpenses.isEmpty {
                    CardView {
                        HStack {
                            Spacer()
                            Text("暂无支出记录")
                                .font(.bodyRegular)
                                .foregroundColor(.textHint)
                            Spacer()
                        }
                        .padding(.vertical, Spacing.md)
                    }
                } else {
                    CardView {
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.recentExpenses.enumerated()), id: \.element.id) { index, expense in
                                if index > 0 {
                                    Divider()
                                }
                                HStack(spacing: Spacing.md) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.primaryWood.opacity(0.1))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: expense.category.iconName)
                                            .foregroundColor(.primaryWood)
                                            .font(.system(size: 16))
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(expense.category.displayName)
                                            .font(.bodyMedium)
                                        if !expense.vendor.isEmpty {
                                            Text(expense.vendor)
                                                .font(.captionRegular)
                                                .foregroundColor(.textSecondary)
                                                .lineLimit(1)
                                        } else if !expense.notes.isEmpty {
                                            Text(expense.notes)
                                                .font(.captionRegular)
                                                .foregroundColor(.textSecondary)
                                                .lineLimit(1)
                                        }
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(expense.formattedAmount)
                                            .font(.numberSmall)
                                            .foregroundColor(.primaryWood)
                                        Text(expense.formattedDate)
                                            .font(.captionRegular)
                                            .foregroundColor(.textHint)
                                    }
                                }
                                .padding(.vertical, Spacing.sm)
                            }
                        }
                    }
                }
            }
        }
    }

    private func categoryStatisticsSection(viewModel: BudgetDashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("分类统计")
                .font(.titleSmall)

            if viewModel.categoryStatistics.filter({ $0.amount > 0 }).isEmpty {
                CardView {
                    HStack {
                        Spacer()
                        Text("暂无分类数据")
                            .font(.bodyRegular)
                            .foregroundColor(.textHint)
                        Spacer()
                    }
                    .padding(.vertical, Spacing.md)
                }
            } else {
                ForEach(viewModel.categoryStatistics.filter { $0.amount > 0 }, id: \.category) { stat in
                    CategoryCard(statistic: stat)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image(systemName: "chart.pie")
                .font(.system(size: 64))
                .foregroundColor(.textHint)

            Text("暂无预算数据")
                .font(.titleSmall)
                .foregroundColor(.textSecondary)

            if let project = projects.first {
                Text("为项目创建预算")
                    .font(.bodyRegular)
                    .foregroundColor(.textHint)

                Button(action: {
                    createBudgetForProject(project)
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("创建预算")
                    }
                    .font(.bodyMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(Color.primaryWood)
                    .cornerRadius(CornerRadius.lg)
                }
                .padding(.top, Spacing.md)
            } else {
                Text("请先创建装修项目")
                    .font(.bodyRegular)
                    .foregroundColor(.textHint)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func createBudgetForProject(_ project: Project) {
        _Concurrency.Task {
            await viewModel?.createBudget(for: project, amount: 180000)
        }
    }

    private func prepareEditBudget() {
        guard let budget = viewModel?.budget else {
            editBudgetText = ""
            return
        }

        let number = NSDecimalNumber(decimal: budget.totalAmount)
        editBudgetText = number.stringValue
    }

    private func saveEditedBudget() {
        guard let amount = Decimal(string: editBudgetText), amount > 0 else {
            budgetErrorMessage = "请输入有效的总预算"
            showingBudgetError = true
            return
        }

        _Concurrency.Task {
            await viewModel?.updateTotalBudget(amount: amount)
            await loadData()
        }
    }

    // MARK: - Methods

    private func loadData() async {
        if viewModel == nil {
            viewModel = BudgetDashboardViewModel(modelContext: modelContext)
        }

        if let project = currentProject {
            await viewModel?.loadBudget(for: project)
        }
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let statistic: CategoryStatistic

    var body: some View {
        CardView(padding: Spacing.sm) {
            VStack(spacing: Spacing.sm) {
                HStack {
                    Image(systemName: statistic.category.iconName)
                        .foregroundColor(.primaryWood)
                    Text(statistic.category.displayName)
                        .font(.bodyMedium)
                    Spacer()
                    Text(statistic.formattedPercentage)
                        .font(.captionMedium)
                        .foregroundColor(.primaryWood)
                }

                ProgressBar(progress: statistic.percentage, height: 6)

                HStack {
                    Text(statistic.formattedAmount)
                        .font(.captionRegular)
                        .foregroundColor(.textSecondary)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    BudgetDashboardView()
        .environment(ProjectManager())
        .modelContainer(for: [Project.self, Budget.self, Expense.self], inMemory: true)
}
