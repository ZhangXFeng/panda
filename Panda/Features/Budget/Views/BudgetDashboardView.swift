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

    /// 当前选中的项目
    private var currentProject: Project? {
        projectManager.currentProject(from: projects)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel, let budget = viewModel.budget {
                    ScrollView {
                        VStack(spacing: Spacing.md) {
                            // 总预算卡片
                            totalBudgetCard(viewModel: viewModel)

                            // 本月支出
                            monthlyExpenseSection(viewModel: viewModel)

                            // 分类预算
                            categoryBudgetSection(viewModel: viewModel)
                        }
                        .padding()
                    }
                } else {
                    emptyState
                }
            }
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
            }
            .sheet(isPresented: $showingAddExpense) {
                if let budget = viewModel?.budget {
                    AddExpenseView(budget: budget)
                }
            }
            .task {
                await loadData()
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

    private func monthlyExpenseSection(viewModel: BudgetDashboardViewModel) -> some View {
        HStack {
            Text("本月支出")
                .font(.captionRegular)
                .foregroundColor(.textSecondary)
            Spacer()
            Text(viewModel.currentMonthExpensesFormatted)
                .font(.numberSmall)
        }
        .padding(.horizontal, Spacing.sm)
    }

    private func categoryBudgetSection(viewModel: BudgetDashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("分类预算")
                .font(.titleSmall)
                .padding(.horizontal, Spacing.sm)

            ForEach(viewModel.categoryStatistics.prefix(5), id: \.category) { stat in
                CategoryCard(statistic: stat)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "chart.pie")
                .font(.system(size: 64))
                .foregroundColor(.textHint)
            Text("暂无预算数据")
                .font(.titleSmall)
                .foregroundColor(.textSecondary)
            Text("请先创建装修项目")
                .font(.bodyRegular)
                .foregroundColor(.textHint)
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
        .modelContainer(for: [Project.self, Budget.self, Expense.self], inMemory: true)
}
