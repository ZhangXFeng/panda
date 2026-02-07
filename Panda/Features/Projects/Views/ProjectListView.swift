//
//  ProjectListView.swift
//  Panda
//
//  Enhanced on 2026-02-03.
//

import SwiftUI
import SwiftData

struct ProjectListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ProjectManager.self) private var projectManager
    @StateObject private var viewModel: ProjectListViewModel

    @State private var showingAddProject = false
    @State private var showingDeleteConfirmation = false
    @State private var projectToDelete: Project?
    @State private var selectedProject: Project?

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ProjectListViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                if viewModel.hasProjects {
                    searchBar
                }

                // Filter chips
                if viewModel.hasProjects {
                    filterSection
                }

                // Project list
                if viewModel.filteredProjects.isEmpty {
                    emptyState
                } else {
                    projectList
                }
            }
            .navigationTitle("我的项目")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingAddProject = true
                        } label: {
                            Label("新建项目", systemImage: "plus")
                        }

                        Menu("排序") {
                            ForEach(ProjectSortOrder.allCases) { order in
                                Button {
                                    viewModel.sortOrder = order
                                } label: {
                                    Label(order.rawValue, systemImage: viewModel.sortOrder == order ? "checkmark" : "")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                AddProjectView(modelContext: modelContext)
                    .onDisappear {
                        viewModel.loadProjects()
                    }
            }
            .sheet(item: $selectedProject) { project in
                NavigationStack {
                    ProjectDetailView(project: project)
                }
                .onDisappear {
                    viewModel.loadProjects()
                }
            }
            .alert("删除项目", isPresented: $showingDeleteConfirmation) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    if let project = projectToDelete {
                        deleteProject(project)
                    }
                }
            } message: {
                if let project = projectToDelete {
                    Text("确定要删除「\(project.name)」吗？\n此操作不可撤销，所有相关数据将被永久删除。")
                }
            }
            .onAppear {
                viewModel.loadProjects()
                projectManager.autoSelectIfNeeded(from: viewModel.projects)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Colors.textSecondary)

            TextField("搜索项目", text: $viewModel.searchText)
                .autocorrectionDisabled()

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Colors.textSecondary)
                }
            }
        }
        .padding(Spacing.sm)
        .background(Colors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(ProjectFilter.allCases) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        viewModel.selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Project List

    private var projectList: some View {
        List {
            // Statistics header
            Section {
                statisticsRow
            }

            // Projects
            Section {
                ForEach(viewModel.filteredProjects) { project in
                    ProjectCardView(
                        project: project,
                        isSelected: project.id == projectManager.currentProjectId
                    ) {
                        projectManager.selectProject(project)
                    }
                    .onTapGesture {
                        selectedProject = project
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            projectToDelete = project
                            showingDeleteConfirmation = true
                        } label: {
                            Label("删除", systemImage: "trash")
                        }

                        Button {
                            viewModel.toggleProjectActive(project)
                        } label: {
                            Label(project.isActive ? "归档" : "激活", systemImage: project.isActive ? "archivebox" : "arrow.up.bin")
                        }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            viewModel.duplicateProject(project)
                        } label: {
                            Label("复制", systemImage: "doc.on.doc")
                        }
                        .tint(.blue)
                    }
                }
            } header: {
                HStack {
                    Text("\(viewModel.filteredProjects.count) 个项目")
                    Spacer()
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Statistics Row

    private var statisticsRow: some View {
        HStack(spacing: Spacing.md) {
            StatBadge(
                icon: "house.fill",
                label: "总计",
                value: "\(viewModel.totalProjects)",
                color: .blue
            )

            StatBadge(
                icon: "hammer.fill",
                label: "进行中",
                value: "\(viewModel.totalActiveProjects)",
                color: .orange
            )

            StatBadge(
                icon: "checkmark.circle.fill",
                label: "已完工",
                value: "\(viewModel.totalCompletedProjects)",
                color: .green
            )

            if viewModel.totalDelayedProjects > 0 {
                StatBadge(
                    icon: "exclamationmark.triangle.fill",
                    label: "延期",
                    value: "\(viewModel.totalDelayedProjects)",
                    color: .red
                )
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: viewModel.searchText.isEmpty ? "house" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(viewModel.searchText.isEmpty ? "还没有装修项目" : "未找到匹配的项目")
                .font(.headline)
                .foregroundColor(.secondary)

            if viewModel.searchText.isEmpty {
                Text("点击右上角菜单创建你的第一个装修项目")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    showingAddProject = true
                } label: {
                    Label("创建项目", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Text("清除搜索")
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Helper Methods

    private func deleteProject(_ project: Project) {
        let wasSelected = project.id == projectManager.currentProjectId

        viewModel.deleteProject(project)

        if wasSelected {
            if let nextProject = viewModel.projects.first(where: { $0.id != project.id }) {
                projectManager.selectProject(nextProject)
            } else {
                projectManager.clearSelection()
            }
        }
    }
}

// MARK: - Project Card View

struct ProjectCardView: View {
    let project: Project
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Cover image
                projectCover

                // Project info
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text(project.name)
                            .font(Fonts.headline)
                            .foregroundColor(Colors.textPrimary)

                        Spacer()

                        if isSelected {
                            Text("当前")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Colors.primary)
                                .cornerRadius(4)
                        }
                    }

                    Text("\(project.houseType) · \(Int(project.area))㎡")
                        .font(Fonts.body)
                        .foregroundColor(Colors.textSecondary)

                    // Progress bar
                    HStack {
                        ProgressView(value: project.overallProgress)
                            .progressViewStyle(.linear)
                            .tint(progressColor)
                            .frame(maxWidth: 120)

                        Text("\(Int(project.overallProgress * 100))%")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.textSecondary)

                        Spacer()

                        statusLabel
                    }

                    // Date info
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(Colors.textSecondary)
                        Text(formatDate(project.startDate))
                            .font(Fonts.caption)
                            .foregroundColor(Colors.textSecondary)

                        Spacer()

                        if project.remainingDays > 0 {
                            Text("剩余 \(project.remainingDays) 天")
                                .font(Fonts.caption)
                                .foregroundColor(project.isDelayed ? Colors.error : Colors.textSecondary)
                        } else if project.overallProgress >= 1.0 {
                            Text("已完工")
                                .font(Fonts.caption)
                                .foregroundColor(Colors.success)
                        }
                    }
                }
            }
            .padding(.vertical, Spacing.sm)
        }
        .buttonStyle(.plain)
    }

    private var projectCover: some View {
        Group {
            if let imageData = project.coverImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Colors.backgroundSecondary
                    Image(systemName: "house.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Colors.primary)
                }
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(isSelected ? Colors.primary : Color.clear, lineWidth: 2)
        )
    }

    private var statusLabel: some View {
        Group {
            if project.overallProgress >= 1.0 {
                Label("完工", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Colors.success)
            } else if project.isDelayed {
                Label("延期", systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Colors.error)
            } else if project.isActive {
                Label("进行中", systemImage: "play.circle.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Colors.primary)
            }
        }
    }

    private var progressColor: Color {
        if project.overallProgress >= 1.0 {
            return Colors.success
        } else if project.isDelayed {
            return Colors.error
        } else {
            return Colors.primary
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

private struct StatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)

            Text(value)
                .font(Fonts.headline)
                .foregroundColor(Colors.textPrimary)

            Text(label)
                .font(Fonts.caption)
                .foregroundColor(Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Budget.self, Phase.self, configurations: config)

    return NavigationStack {
        ProjectListView(modelContext: container.mainContext)
    }
    .environment(ProjectManager())
    .modelContainer(container)
}
