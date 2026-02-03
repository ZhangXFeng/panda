//
//  ProjectSettingsView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct ProjectSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ProjectManager.self) private var projectManager
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]

    @State private var showingEditSheet = false

    private var currentProject: Project? {
        projects.first { $0.id == projectManager.currentProjectId }
    }

    var body: some View {
        Form {
            if let project = currentProject {
                // Project Info
                Section {
                    InfoRow(label: "项目名称", value: project.name)
                    InfoRow(label: "房屋类型", value: project.houseType)
                    InfoRow(label: "建筑面积", value: "\(String(format: "%.0f", project.area)) ㎡")
                    InfoRow(label: "开工日期", value: formatDate(project.startDate))
                    InfoRow(label: "预计工期", value: "\(project.estimatedDuration) 天")
                    InfoRow(label: "预计完工", value: formatDate(project.estimatedEndDate))
                } header: {
                    Text("项目信息")
                } footer: {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("编辑项目信息", systemImage: "pencil")
                    }
                }

                // Project Status
                Section {
                    HStack {
                        Text("项目状态")
                        Spacer()
                        Text(project.isActive ? "活跃" : "已归档")
                            .foregroundColor(project.isActive ? Colors.success : Colors.textSecondary)
                    }

                    HStack {
                        Text("整体进度")
                        Spacer()
                        Text("\(Int(project.overallProgress * 100))%")
                            .foregroundColor(Colors.primary)
                    }

                    HStack {
                        Text("已用天数")
                        Spacer()
                        Text("\(project.actualDaysUsed) 天")
                            .foregroundColor(Colors.textSecondary)
                    }

                    if project.isDelayed {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Colors.warning)
                            Text("项目延期")
                                .foregroundColor(Colors.warning)
                        }
                    }
                } header: {
                    Text("项目状态")
                }

                // Related Data
                Section {
                    NavigationLink {
                        ScheduleOverviewView()
                    } label: {
                        DataRow(icon: "calendar", label: "装修阶段", count: project.phases.count)
                    }

                    NavigationLink {
                        MaterialListView(modelContext: modelContext)
                    } label: {
                        DataRow(icon: "shippingbox", label: "材料清单", count: project.materials.count)
                    }

                    NavigationLink {
                        ContactListView(modelContext: modelContext)
                    } label: {
                        DataRow(icon: "person.2", label: "联系人", count: project.contacts.count)
                    }

                    NavigationLink {
                        JournalListView(modelContext: modelContext)
                    } label: {
                        DataRow(icon: "book", label: "装修日记", count: project.journalEntries.count)
                    }
                } header: {
                    Text("相关数据")
                }

                // Budget Settings
                if let budget = project.budget {
                    Section {
                        InfoRow(label: "总预算", value: formatCurrency(budget.totalBudget))
                        InfoRow(label: "已支出", value: formatCurrency(budget.totalSpent))
                        InfoRow(label: "剩余", value: formatCurrency(budget.remainingBudget), valueColor: budget.remainingBudget >= 0 ? Colors.success : Colors.error)
                    } header: {
                        Text("预算信息")
                    }
                }

                // Project Notes
                if !project.notes.isEmpty {
                    Section {
                        Text(project.notes)
                            .font(Fonts.body)
                            .foregroundColor(Colors.textSecondary)
                    } header: {
                        Text("备注")
                    }
                }

                // Actions
                Section {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("编辑项目", systemImage: "pencil")
                    }

                    NavigationLink {
                        ProjectStatisticsView(project: project)
                    } label: {
                        Label("查看统计", systemImage: "chart.bar.fill")
                    }
                } header: {
                    Text("操作")
                }
            } else {
                // No Project Selected
                Section {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)

                        Text("未选择项目")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("请先选择一个装修项目")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        NavigationLink {
                            ProjectListView(modelContext: modelContext)
                        } label: {
                            Text("选择项目")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.lg)
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("项目设置")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            if let project = currentProject {
                NavigationStack {
                    AddProjectView(modelContext: modelContext, project: project)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0.00"
    }
}

// MARK: - Supporting Views

private struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = Colors.textPrimary

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(Colors.textSecondary)
            Spacer()
            Text(value)
                .foregroundColor(valueColor)
        }
    }
}

private struct DataRow: View {
    let icon: String
    let label: String
    let count: Int

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Colors.primary)
                .frame(width: 24)

            Text(label)

            Spacer()

            Text("\(count)")
                .font(Fonts.caption)
                .foregroundColor(Colors.textSecondary)
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Budget.self, Phase.self, configurations: config)
    let context = container.mainContext

    let project = Project(
        name: "我的新家",
        houseType: "三室两厅",
        area: 120.0,
        startDate: Date().addingTimeInterval(-86400 * 30),
        estimatedDuration: 90,
        notes: "这是一个测试项目"
    )
    context.insert(project)

    let budget = Budget(totalBudget: 150000)
    budget.project = project
    context.insert(budget)

    let manager = ProjectManager()
    manager.selectProject(project)

    return NavigationStack {
        ProjectSettingsView()
            .modelContainer(container)
            .environment(manager)
    }
}
