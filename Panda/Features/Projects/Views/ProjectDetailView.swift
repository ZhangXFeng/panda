//
//  ProjectDetailView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let project: Project

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Cover image
                if let imageData = project.coverImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                        .padding(.horizontal, Spacing.md)
                }

                // Basic info card
                basicInfoCard

                // Progress card
                progressCard

                // Timeline card
                timelineCard

                // Statistics grid
                statisticsGrid

                // Related items
                relatedItemsCard

                // Notes
                if !project.notes.isEmpty {
                    notesCard
                }

                // Action buttons
                actionButtons
            }
            .padding(.vertical, Spacing.md)
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                AddProjectView(modelContext: modelContext, project: project)
            }
        }
        .alert("删除项目", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deleteProject()
            }
        } message: {
            Text("确定要删除此项目吗？此操作无法撤销。")
        }
    }

    // MARK: - Basic Info Card

    private var basicInfoCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("基本信息")
                            .font(Fonts.headline)
                        Text(project.houseType)
                            .font(Fonts.caption)
                            .foregroundColor(Colors.textSecondary)
                    }

                    Spacer()

                    if project.isActive {
                        Label("活跃", systemImage: "checkmark.circle.fill")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.success)
                    }
                }

                Divider()

                HStack {
                    InfoRow(label: "建筑面积", value: "\(String(format: "%.0f", project.area)) ㎡")
                    Spacer()
                    InfoRow(label: "预计工期", value: "\(project.estimatedDuration) 天")
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("整体进度")
                        .font(Fonts.headline)

                    Spacer()

                    Text("\(Int(project.overallProgress * 100))%")
                        .font(Fonts.titleMedium)
                        .foregroundColor(Colors.primary)
                }

                ProgressBar(progress: project.overallProgress)
                    .frame(height: 8)

                HStack {
                    Label("\(project.phases.filter { $0.isCompleted }.count)/\(project.phases.count) 阶段完成", systemImage: "checkmark.circle")
                        .font(Fonts.caption)
                        .foregroundColor(Colors.textSecondary)

                    Spacer()

                    if project.isDelayed {
                        Label("延期", systemImage: "exclamationmark.triangle.fill")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.warning)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Timeline Card

    private var timelineCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("时间安排")
                    .font(Fonts.headline)

                Divider()

                VStack(spacing: Spacing.sm) {
                    TimelineRow(
                        icon: "calendar",
                        label: "开工日期",
                        value: formatDate(project.startDate)
                    )

                    TimelineRow(
                        icon: "calendar.badge.clock",
                        label: "预计完工",
                        value: formatDate(project.estimatedEndDate)
                    )

                    TimelineRow(
                        icon: "clock",
                        label: "已用天数",
                        value: "\(project.actualDaysUsed) 天"
                    )

                    if project.remainingDays > 0 {
                        TimelineRow(
                            icon: "hourglass",
                            label: "剩余天数",
                            value: "\(project.remainingDays) 天",
                            valueColor: project.isDelayed ? Colors.warning : Colors.primary
                        )
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Statistics Grid

    private var statisticsGrid: some View {
        VStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                StatCard(
                    icon: "list.bullet",
                    label: "阶段",
                    value: "\(project.phases.count)",
                    color: .blue
                )

                StatCard(
                    icon: "shippingbox",
                    label: "材料",
                    value: "\(project.materials.count)",
                    color: .orange
                )
            }

            HStack(spacing: Spacing.sm) {
                StatCard(
                    icon: "person.2",
                    label: "联系人",
                    value: "\(project.contacts.count)",
                    color: .green
                )

                StatCard(
                    icon: "book",
                    label: "日记",
                    value: "\(project.journalEntries.count)",
                    color: .purple
                )
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Related Items Card

    private var relatedItemsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("相关内容")
                    .font(Fonts.headline)
                    .padding(.bottom, Spacing.xs)

                Divider()

                NavigationLink {
                    ScheduleOverviewView()
                } label: {
                    RelatedItemRow(icon: "calendar", label: "进度管理", count: project.phases.count)
                }

                Divider()

                NavigationLink {
                    MaterialListView(modelContext: modelContext)
                } label: {
                    RelatedItemRow(icon: "shippingbox", label: "材料管理", count: project.materials.count)
                }

                Divider()

                NavigationLink {
                    ContactListView(modelContext: modelContext)
                } label: {
                    RelatedItemRow(icon: "person.2", label: "通讯录", count: project.contacts.count)
                }

                Divider()

                NavigationLink {
                    JournalListView(modelContext: modelContext)
                } label: {
                    RelatedItemRow(icon: "book", label: "装修日记", count: project.journalEntries.count)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("备注")
                    .font(Fonts.headline)

                Divider()

                Text(project.notes)
                    .font(Fonts.body)
                    .foregroundColor(Colors.textSecondary)
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: Spacing.sm) {
            Button {
                showingEditSheet = true
            } label: {
                Label("编辑项目", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("删除项目", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    private func deleteProject() {
        modelContext.delete(project)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete project: \(error)")
        }
    }
}

// MARK: - Supporting Views

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Fonts.caption)
                .foregroundColor(Colors.textSecondary)
            Text(value)
                .font(Fonts.headline)
        }
    }
}

private struct TimelineRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = Colors.textPrimary

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Colors.primary)
                .frame(width: 24)

            Text(label)
                .font(Fonts.body)
                .foregroundColor(Colors.textSecondary)

            Spacer()

            Text(value)
                .font(Fonts.body)
                .foregroundColor(valueColor)
        }
    }
}

private struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        CardView {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)

                Text(value)
                    .font(Fonts.titleLarge)
                    .foregroundColor(Colors.textPrimary)

                Text(label)
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
        }
    }
}

private struct RelatedItemRow: View {
    let icon: String
    let label: String
    let count: Int

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Colors.primary)
                .frame(width: 24)

            Text(label)
                .font(Fonts.body)

            Spacer()

            Text("\(count)")
                .font(Fonts.caption)
                .foregroundColor(Colors.textSecondary)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Colors.textSecondary)
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Phase.self, Material.self, Contact.self, JournalEntry.self, configurations: config)

    let project = Project(
        name: "我的新家",
        houseType: "三室两厅",
        area: 120.0,
        startDate: Date().addingTimeInterval(-86400 * 30),
        estimatedDuration: 90,
        notes: "这是我的第一个装修项目，希望一切顺利！"
    )

    return NavigationStack {
        ProjectDetailView(project: project)
            .modelContainer(container)
    }
}
