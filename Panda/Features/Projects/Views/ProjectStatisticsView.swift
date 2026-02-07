//
//  ProjectStatisticsView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData
import Charts

struct ProjectStatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    let project: Project

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Overview card
                overviewCard

                // Progress card
                progressCard

                // Timeline card
                timelineCard

                // Breakdown card
                breakdownCard

                // Cost card (if budget exists)
                if let budget = project.budget {
                    costCard(budget: budget)
                }
            }
            .padding(.vertical, Spacing.md)
        }
        .navigationTitle("项目统计")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Overview Card

    private var overviewCard: some View {
        CardView {
            VStack(spacing: Spacing.md) {
                HStack {
                    Text("项目概览")
                        .font(Fonts.headline)
                    Spacer()
                }

                Divider()

                HStack(spacing: Spacing.lg) {
                    OverviewStat(
                        icon: "calendar",
                        label: "已用天数",
                        value: "\(project.actualDaysUsed)",
                        unit: "天"
                    )

                    Divider()
                        .frame(height: 40)

                    OverviewStat(
                        icon: "hourglass",
                        label: "剩余天数",
                        value: "\(project.remainingDays)",
                        unit: "天",
                        color: project.isDelayed ? Colors.warning : Colors.primary
                    )

                    Divider()
                        .frame(height: 40)

                    OverviewStat(
                        icon: "chart.bar.fill",
                        label: "完成进度",
                        value: "\(Int(project.overallProgress * 100))",
                        unit: "%"
                    )
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("阶段进度")
                    .font(Fonts.headline)

                Divider()

                if project.phases.isEmpty {
                    Text("暂无阶段数据")
                        .font(Fonts.body)
                        .foregroundColor(Colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, Spacing.md)
                } else {
                    // Progress chart
                    Chart {
                        ForEach(project.phases) { phase in
                            BarMark(
                                x: .value("阶段", phase.name),
                                y: .value("进度", phase.isCompleted ? 1.0 : 0.5)
                            )
                            .foregroundStyle(phase.isCompleted ? Colors.success : Colors.primary.opacity(0.5))
                        }
                    }
                    .frame(height: 200)
                    .chartYScale(domain: 0...1)
                    .chartYAxis {
                        AxisMarks(values: [0, 0.5, 1.0]) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let val = value.as(Double.self) {
                                    Text("\(Int(val * 100))%")
                                        .font(Fonts.caption)
                                }
                            }
                        }
                    }

                    // Legend
                    HStack(spacing: Spacing.lg) {
                        LegendItem(color: Colors.success, label: "已完成")
                        LegendItem(color: Colors.primary.opacity(0.5), label: "进行中")
                    }
                    .padding(.top, Spacing.sm)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Timeline Card

    private var timelineCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("时间轴")
                    .font(Fonts.headline)

                Divider()

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    TimelineItem(
                        icon: "flag.fill",
                        label: "项目开工",
                        date: project.startDate,
                        color: Colors.primary
                    )

                    TimelineItem(
                        icon: "clock.fill",
                        label: "当前时间",
                        date: Date(),
                        color: .orange,
                        isHighlighted: true
                    )

                    TimelineItem(
                        icon: "flag.checkered",
                        label: "预计完工",
                        date: project.estimatedEndDate,
                        color: project.isDelayed ? Colors.error : Colors.success
                    )
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Breakdown Card

    private var breakdownCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("数据统计")
                    .font(Fonts.headline)

                Divider()

                VStack(spacing: Spacing.sm) {
                    BreakdownRow(
                        icon: "list.bullet",
                        label: "装修阶段",
                        value: "\(project.phases.count)",
                        detail: "\(project.phases.filter { $0.isCompleted }.count) 已完成"
                    )

                    BreakdownRow(
                        icon: "shippingbox",
                        label: "材料清单",
                        value: "\(project.materials.count)",
                        detail: nil
                    )

                    BreakdownRow(
                        icon: "person.2",
                        label: "联系人",
                        value: "\(project.contacts.count)",
                        detail: nil
                    )

                    BreakdownRow(
                        icon: "book",
                        label: "装修日记",
                        value: "\(project.journalEntries.count)",
                        detail: nil
                    )
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Cost Card

    private func costCard(budget: Budget) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("预算统计")
                    .font(Fonts.headline)

                Divider()

                VStack(spacing: Spacing.md) {
                    // Total budget
                    HStack {
                        Text("总预算")
                            .font(Fonts.body)
                            .foregroundColor(Colors.textSecondary)
                        Spacer()
                        Text(formatCurrency(budget.totalAmount))
                            .font(Fonts.titleMedium)
                            .foregroundColor(Colors.primary)
                    }

                    // Total spent
                    HStack {
                        Text("已支出")
                            .font(Fonts.body)
                            .foregroundColor(Colors.textSecondary)
                        Spacer()
                        Text(formatCurrency(budget.totalExpenses))
                            .font(Fonts.headline)
                            .foregroundColor(Colors.textPrimary)
                    }

                    // Remaining
                    HStack {
                        Text("剩余")
                            .font(Fonts.body)
                            .foregroundColor(Colors.textSecondary)
                        Spacer()
                        Text(formatCurrency(budget.remainingBudget))
                            .font(Fonts.headline)
                            .foregroundColor(budget.remainingBudget >= 0 ? Colors.success : Colors.error)
                    }

                    // Progress bar
                    if budget.totalAmount > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            ProgressBar(progress: min(budget.usagePercentage, 1.0))
                                .frame(height: 8)

                            Text("已使用 \(Int(budget.usagePercentage * 100))%")
                                .font(Fonts.caption)
                                .foregroundColor(Colors.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Helper Methods

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0.00"
    }
}

// MARK: - Supporting Views

private struct OverviewStat: View {
    let icon: String
    let label: String
    let value: String
    let unit: String
    var color: Color = Colors.primary

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(Fonts.titleLarge)
                    .foregroundColor(Colors.textPrimary)
                Text(unit)
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textSecondary)
            }

            Text(label)
                .font(Fonts.caption)
                .foregroundColor(Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(Fonts.caption)
                .foregroundColor(Colors.textSecondary)
        }
    }
}

private struct TimelineItem: View {
    let icon: String
    let label: String
    let date: Date
    let color: Color
    var isHighlighted: Bool = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(isHighlighted ? Fonts.headline : Fonts.body)
                    .foregroundColor(Colors.textPrimary)

                Text(formatDate(date))
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, Spacing.xs)
        .padding(.horizontal, Spacing.sm)
        .background(isHighlighted ? color.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

private struct BreakdownRow: View {
    let icon: String
    let label: String
    let value: String
    let detail: String?

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Colors.primary)
                .frame(width: 24)

            Text(label)
                .font(Fonts.body)
                .foregroundColor(Colors.textSecondary)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(Fonts.headline)
                    .foregroundColor(Colors.textPrimary)

                if let detail = detail {
                    Text(detail)
                        .font(Fonts.caption)
                        .foregroundColor(Colors.textSecondary)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Budget.self, Phase.self, Material.self, Contact.self, JournalEntry.self, configurations: config)

    let project = Project(
        name: "我的新家",
        houseType: "三室两厅",
        area: 120.0,
        startDate: Date().addingTimeInterval(-86400 * 30),
        estimatedDuration: 90
    )

    return NavigationStack {
        ProjectStatisticsView(project: project)
            .modelContainer(container)
    }
}
