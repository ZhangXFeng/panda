//
//  PhaseDetailView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct PhaseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PhaseDetailViewModel
    @State private var showingAddTask = false
    @State private var showingEditPhase = false
    @State private var showingDeletePhase = false
    @State private var selectedTask: Task?

    let phase: Phase

    init(phase: Phase, modelContext: ModelContext) {
        self.phase = phase
        _viewModel = StateObject(wrappedValue: PhaseDetailViewModel(phase: phase, modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar (if has tasks)
                if !viewModel.tasks.isEmpty {
                    searchBar
                }

                // Status filter (if has tasks)
                if !viewModel.tasks.isEmpty && (viewModel.selectedStatus != nil || !viewModel.searchText.isEmpty) {
                    statusFilterSection
                }

                // Task list
                if viewModel.filteredTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .navigationTitle(phase.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingEditPhase = true
                        } label: {
                            Label("编辑阶段", systemImage: "pencil")
                        }

                        if phase.type == .custom {
                            Button(role: .destructive) {
                                showingDeletePhase = true
                            } label: {
                                Label("删除阶段", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                phaseProgressCard
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.sm)
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(modelContext: modelContext, phase: phase)
                    .onDisappear {
                        viewModel.loadTasks()
                    }
            }
            .sheet(item: $selectedTask) { task in
                AddTaskView(modelContext: modelContext, task: task)
                    .onDisappear {
                        viewModel.loadTasks()
                    }
            }
            .sheet(isPresented: $showingEditPhase) {
                EditPhaseView(phase: phase)
                    .onDisappear {
                        viewModel.loadTasks()
                    }
            }
            .alert("删除阶段", isPresented: $showingDeletePhase) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deletePhase()
                }
            } message: {
                Text("确定要删除此阶段吗？此操作将删除该阶段下所有任务，且不可撤销。")
            }
            .onAppear {
                viewModel.loadTasks()
            }
        }
    }

    // MARK: - Phase Progress Card

    private var phaseProgressCard: some View {
        CardView {
            VStack(spacing: Spacing.md) {
                Toggle("启用此阶段", isOn: Binding(
                    get: { phase.isEnabled },
                    set: { newValue in
                        viewModel.setPhaseEnabled(newValue)
                    }
                ))
                .tint(Colors.primary)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("任务进度")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.textSecondary)

                        Text("\(viewModel.completedTasks.count)/\(viewModel.tasks.count) 已完成")
                            .font(Fonts.headline)
                            .foregroundColor(Colors.primary)
                    }

                    Spacer()

                    Text("\(Int(viewModel.taskProgress * 100))%")
                        .font(Fonts.numberMedium)
                        .foregroundColor(Colors.primary)
                }

                ProgressBar(progress: viewModel.taskProgress)

                if !viewModel.overdueTasks.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Colors.warning)
                        Text("\(viewModel.overdueTasks.count) 个任务逾期")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.warning)
                        Spacer()
                    }
                }
            }
            .padding(Spacing.md)
        }
        .background(Colors.backgroundPrimary)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("搜索任务", text: $viewModel.searchText)
                .textFieldStyle(.plain)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Colors.backgroundSecondary)
        .cornerRadius(CornerRadius.md)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Status Filter Section

    private var statusFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // All button
                FilterChip(
                    title: "全部",
                    isSelected: viewModel.selectedStatus == nil
                ) {
                    viewModel.selectedStatus = nil
                }

                // Status filters
                ForEach(TaskStatus.allCases) { status in
                    FilterChip(
                        title: status.displayName,
                        isSelected: viewModel.selectedStatus == status
                    ) {
                        viewModel.selectedStatus = status
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Task List

    private var taskList: some View {
        List {
            ForEach(viewModel.filteredTasks) { task in
                TaskRow(task: task, viewModel: viewModel)
                    .onTapGesture {
                        selectedTask = task
                    }
            }
            .onDelete { offsets in
                viewModel.deleteTasks(at: offsets, from: viewModel.filteredTasks)
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(viewModel.searchText.isEmpty ? "还没有任务" : "未找到匹配的任务")
                .font(.headline)
                .foregroundColor(.secondary)

            if viewModel.searchText.isEmpty {
                Text("点击右上角 + 添加任务")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func deletePhase() {
        modelContext.delete(phase)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete phase: \(error)")
        }
    }
}

// MARK: - Task Row

private struct TaskRow: View {
    let task: Task
    let viewModel: PhaseDetailViewModel

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Status icon
            ZStack {
                Circle()
                    .fill(task.status.color.opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: task.status.iconName)
                    .foregroundColor(task.status.color)
                    .font(.system(size: 18))
            }

            // Task info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(Fonts.headline)
                    .lineLimit(2)

                HStack {
                    if !task.assignee.isEmpty {
                        Label(task.assignee, systemImage: "person")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.textSecondary)
                    }

                    if task.hasPhotos {
                        Label("\(task.photoCount)", systemImage: "photo")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.textSecondary)
                    }
                }

                if let dateRange = task.formattedDateRange {
                    Text(dateRange)
                        .font(Fonts.caption)
                        .foregroundColor(task.isOverdue ? Colors.error : Colors.textSecondary)
                }
            }

            Spacer()

            // Quick action button
            Button {
                viewModel.toggleTaskStatus(task)
            } label: {
                Image(systemName: task.isCompleted ? "arrow.counterclockwise" : "checkmark")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(task.isCompleted ? Colors.textSecondary : Colors.success)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Phase.self, Task.self, configurations: config)

    let phase = Phase(
        name: "水电改造",
        type: .plumbing,
        sortOrder: 1,
        plannedStartDate: Date(),
        plannedEndDate: Date().addingTimeInterval(86400 * 15)
    )

    return PhaseDetailView(phase: phase, modelContext: container.mainContext)
        .modelContainer(container)
}
