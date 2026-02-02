//
//  HomeDashboardView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct HomeDashboardView: View {
    @Query private var projects: [Project]

    var body: some View {
        NavigationStack {
            ScrollView {
                if let project = projects.first {
                    VStack(spacing: Spacing.md) {
                        // 项目信息卡片
                        projectInfoCard(project: project)

                        // 预算概览
                        budgetOverviewCard(project: project)

                        // 进度概览
                        scheduleOverviewCard(project: project)

                        // 快捷操作
                        quickActionsSection()
                    }
                    .padding()
                } else {
                    emptyState
                }
            }
            .navigationTitle("我的家")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Components

    private func projectInfoCard(project: Project) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.primaryWood)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(project.name)
                            .font(.titleMedium)
                        Text("\(project.houseType) · \(Int(project.area))㎡")
                            .font(.bodyRegular)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()
                }

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("开工日期")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        Text(formatDate(project.startDate))
                            .font(.captionMedium)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        Text("预计工期")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        Text("\(project.estimatedDuration) 天")
                            .font(.captionMedium)
                    }
                }
            }
        }
    }

    private func budgetOverviewCard(project: Project) -> some View {
        Group {
            if let budget = project.budget {
                NavigationLink {
                    BudgetDashboardView()
                } label: {
                    CardView {
                        VStack(spacing: Spacing.md) {
                            HStack {
                                Text("预算概览")
                                    .font(.titleSmall)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.textSecondary)
                            }

                            ProgressBar(progress: budget.usagePercentage)

                            HStack {
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text("总预算")
                                        .font(.captionRegular)
                                        .foregroundColor(.textSecondary)
                                    Text(formatCurrency(budget.totalAmount))
                                        .font(.numberSmall)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: Spacing.xs) {
                                    Text("已支出")
                                        .font(.captionRegular)
                                        .foregroundColor(.textSecondary)
                                    Text(formatCurrency(budget.totalExpenses))
                                        .font(.numberSmall)
                                        .foregroundColor(budget.hasReachedWarningThreshold ? .warning : .primaryWood)
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func scheduleOverviewCard(project: Project) -> some View {
        NavigationLink {
            ScheduleOverviewView()
        } label: {
            CardView {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Text("进度概览")
                            .font(.titleSmall)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.textSecondary)
                    }

                    ProgressBar(progress: project.overallProgress)

                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("已完成")
                                .font(.captionRegular)
                                .foregroundColor(.textSecondary)
                            Text("\(project.phases.filter { $0.isCompleted }.count)/\(project.phases.count) 阶段")
                                .font(.captionMedium)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: Spacing.xs) {
                            Text("剩余天数")
                                .font(.captionRegular)
                                .foregroundColor(.textSecondary)
                            Text("\(project.remainingDays) 天")
                                .font(.captionMedium)
                                .foregroundColor(project.isDelayed ? .error : .success)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func quickActionsSection() -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("快捷操作")
                .font(.titleSmall)
                .padding(.horizontal, Spacing.sm)

            HStack(spacing: Spacing.md) {
                QuickActionButton(icon: "plus.circle.fill", title: "记一笔") {
                    // Navigate to add expense
                }

                QuickActionButton(icon: "photo", title: "写日记") {
                    // Navigate to journal
                }

                QuickActionButton(icon: "person.crop.circle", title: "通讯录") {
                    // Navigate to contacts
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "house")
                .font(.system(size: 64))
                .foregroundColor(.textHint)
            Text("欢迎使用 Panda 装修管家")
                .font(.titleSmall)
                .foregroundColor(.textSecondary)
            Text("请先创建装修项目")
                .font(.bodyRegular)
                .foregroundColor(.textHint)
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0.00"
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.primaryWood)
                Text(title)
                    .font(.captionMedium)
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.bgCard)
            .cornerRadius(CornerRadius.lg)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    HomeDashboardView()
        .modelContainer(for: [Project.self, Budget.self, Phase.self], inMemory: true)
}
