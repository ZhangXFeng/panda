//
//  TaskDetailView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let task: Task
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header
                    headerSection

                    // Status card
                    statusCard

                    // Schedule
                    if task.plannedStartDate != nil || task.plannedEndDate != nil {
                        scheduleCard
                    }

                    // Assignee
                    if !task.assignee.isEmpty {
                        assigneeCard
                    }

                    // Description
                    if !task.taskDescription.isEmpty {
                        descriptionCard
                    }

                    // Photos
                    if task.hasPhotos {
                        photosSection
                    }

                    // Metadata
                    metadataSection
                }
                .padding(Spacing.md)
            }
            .background(Colors.backgroundPrimary)
            .navigationTitle("任务详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("编辑", systemImage: "pencil")
                        }

                        Divider()

                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                AddTaskView(modelContext: modelContext, task: task)
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteTask()
                }
            } message: {
                Text("确定要删除这个任务吗？此操作无法撤销。")
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(task.title)
                .font(Fonts.titleMedium)
                .foregroundColor(Colors.textPrimary)

            if let phase = task.phase {
                HStack {
                    Image(systemName: phase.type.iconName)
                        .font(.caption)
                        .foregroundColor(Colors.primary)
                    Text(phase.name)
                        .font(Fonts.caption)
                        .foregroundColor(Colors.textSecondary)
                }
            }
        }
    }

    // MARK: - Status Card

    private var statusCard: some View {
        CardView {
            HStack {
                Image(systemName: task.status.iconName)
                    .font(.title2)
                    .foregroundColor(task.status.color)

                VStack(alignment: .leading, spacing: 4) {
                    Text("当前状态")
                        .font(Fonts.caption)
                        .foregroundColor(Colors.textSecondary)

                    Text(task.status.displayName)
                        .font(Fonts.headline)
                        .foregroundColor(task.status.color)
                }

                Spacer()

                if task.isOverdue {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("逾期")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.error)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical: 4)
                            .background(Colors.error.opacity(0.1))
                            .cornerRadius(CornerRadius.sm)
                    }
                }
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Schedule Card

    private var scheduleCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("时间安排")
                    .font(Fonts.headline)

                Divider()

                if let startDate = task.plannedStartDate {
                    infoRow(label: "计划开始", value: formatDate(startDate))
                }

                if let endDate = task.plannedEndDate {
                    infoRow(label: "计划结束", value: formatDate(endDate))
                }

                if let completionDate = task.actualCompletionDate {
                    infoRow(label: "实际完成", value: formatDate(completionDate))
                }
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Assignee Card

    private var assigneeCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("负责人")
                    .font(Fonts.headline)

                Divider()

                infoRow(label: "姓名", value: task.assignee)

                if !task.assigneeContact.isEmpty {
                    HStack {
                        Text("联系方式")
                            .foregroundColor(.secondary)

                        Spacer()

                        Button {
                            makePhoneCall(task.assigneeContact)
                        } label: {
                            HStack {
                                Text(task.assigneeContact)
                                Image(systemName: "phone.fill")
                            }
                            .foregroundColor(Colors.primary)
                        }
                    }
                }
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Description Card

    private var descriptionCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("任务描述")
                    .font(Fonts.headline)

                Divider()

                Text(task.taskDescription)
                    .font(Fonts.body)
                    .foregroundColor(Colors.textSecondary)
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Photos Section

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("照片")
                .font(Fonts.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.sm) {
                ForEach(Array(task.photoData.enumerated()), id: \.offset) { _, data in
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    }
                }
            }
        }
    }

    // MARK: - Metadata Section

    private var metadataSection: some View {
        VStack(spacing: Spacing.xs) {
            Text("创建于 \(task.createdAt.formatted(date: .long, time: .shortened))")
                .font(Fonts.caption)
                .foregroundColor(Colors.textHint)

            if task.updatedAt != task.createdAt {
                Text("更新于 \(task.updatedAt.formatted(date: .long, time: .shortened))")
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textHint)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.md)
    }

    // MARK: - Helper Methods

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(Colors.textPrimary)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    private func makePhoneCall(_ phoneNumber: String) {
        let cleanedNumber = phoneNumber
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")

        if let url = URL(string: "tel://\(cleanedNumber)") {
            UIApplication.shared.open(url)
        }
    }

    private func deleteTask() {
        modelContext.delete(task)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete task: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Phase.swift, Task.self, configurations: config)
    let context = container.mainContext

    let project = Project(name: "我的新家", houseType: "三室两厅", area: 120.0)
    context.insert(project)

    let phase = Phase(
        name: "水电改造",
        type: .plumbing,
        sortOrder: 1,
        plannedStartDate: Date(),
        plannedEndDate: Date().addingTimeInterval(86400 * 15)
    )
    phase.project = project
    context.insert(phase)

    let task = Task(
        title: "水管布线",
        taskDescription: "冷热水管布线，需要注意：\n1. 冷热水管间距15cm\n2. 水管走顶不走地\n3. 使用PPR管材\n4. 打压测试24小时",
        status: .inProgress,
        assignee: "张师傅",
        assigneeContact: "13800138000",
        plannedStartDate: Date(),
        plannedEndDate: Date().addingTimeInterval(86400 * 3)
    )
    task.phase = phase
    context.insert(task)

    return TaskDetailView(task: task)
        .modelContainer(container)
}
