//
//  ProjectListView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

/// 项目列表视图 - 管理所有装修项目
struct ProjectListView: View {
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Environment(ProjectManager.self) private var projectManager
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]

    @State private var showingAddProject = false
    @State private var projectToDelete: Project?
    @State private var showingDeleteConfirmation = false

    // MARK: - Body

    var body: some View {
        List {
            if projects.isEmpty {
                emptyState
            } else {
                projectsSection
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("我的项目")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddProject = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddProject) {
            AddProjectView()
        }
        .alert("删除项目", isPresented: $showingDeleteConfirmation) {
            Button("取消", role: .cancel) {}
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
            projectManager.autoSelectIfNeeded(from: projects)
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        Section {
            VStack(spacing: Spacing.lg) {
                Image(systemName: "house")
                    .font(.system(size: 64))
                    .foregroundColor(.textHint)

                Text("还没有装修项目")
                    .font(.titleSmall)
                    .foregroundColor(.textSecondary)

                Text("点击右上角「+」创建你的第一个装修项目")
                    .font(.captionRegular)
                    .foregroundColor(.textHint)
                    .multilineTextAlignment(.center)

                Button {
                    showingAddProject = true
                } label: {
                    Label("创建项目", systemImage: "plus.circle.fill")
                        .font(.titleSmall)
                }
                .buttonStyle(.borderedProminent)
                .tint(.primaryWood)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xl)
        }
        .listRowBackground(Color.clear)
    }

    private var projectsSection: some View {
        Section {
            ForEach(projects, id: \.id) { project in
                ProjectCardView(
                    project: project,
                    isSelected: project.id == projectManager.currentProjectId
                ) {
                    projectManager.selectProject(project)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        projectToDelete = project
                        showingDeleteConfirmation = true
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                }
            }
        } header: {
            HStack {
                Text("共 \(projects.count) 个项目")
                Spacer()
            }
        }
    }

    // MARK: - Methods

    private func deleteProject(_ project: Project) {
        // 如果删除的是当前选中的项目，需要更新选择
        let wasSelected = project.id == projectManager.currentProjectId

        modelContext.delete(project)

        if wasSelected {
            // 选择下一个可用的项目
            if let nextProject = projects.first(where: { $0.id != project.id }) {
                projectManager.selectProject(nextProject)
            } else {
                projectManager.clearSelection()
            }
        }
    }
}

// MARK: - Project Card View

/// 项目卡片视图
struct ProjectCardView: View {
    let project: Project
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // 项目封面
                projectCover

                // 项目信息
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text(project.name)
                            .font(.titleSmall)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        if isSelected {
                            Text("当前")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.primaryWood)
                                .cornerRadius(4)
                        }
                    }

                    Text("\(project.houseType) · \(Int(project.area))㎡")
                        .font(.bodyRegular)
                        .foregroundColor(.textSecondary)

                    // 进度和状态
                    HStack {
                        // 进度条
                        ProgressView(value: project.overallProgress)
                            .progressViewStyle(.linear)
                            .tint(progressColor)
                            .frame(maxWidth: 120)

                        Text("\(Int(project.overallProgress * 100))%")
                            .font(.captionMedium)
                            .foregroundColor(.textSecondary)

                        Spacer()

                        // 状态标签
                        statusLabel
                    }

                    // 开工信息
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.textHint)
                        Text(formatDate(project.startDate))
                            .font(.captionRegular)
                            .foregroundColor(.textHint)

                        Spacer()

                        if project.remainingDays > 0 {
                            Text("剩余 \(project.remainingDays) 天")
                                .font(.captionRegular)
                                .foregroundColor(project.isDelayed ? .error : .textHint)
                        } else if project.overallProgress >= 1.0 {
                            Text("已完工")
                                .font(.captionRegular)
                                .foregroundColor(.success)
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
                    Color.bgSecondary
                    Image(systemName: "house.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.primaryWood)
                }
            }
        }
        .frame(width: 72, height: 72)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(isSelected ? Color.primaryWood : Color.clear, lineWidth: 2)
        )
    }

    private var statusLabel: some View {
        Group {
            if project.overallProgress >= 1.0 {
                Label("完工", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.success)
            } else if project.isDelayed {
                Label("延期", systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.error)
            } else if project.isActive {
                Label("进行中", systemImage: "play.circle.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primaryWood)
            }
        }
    }

    private var progressColor: Color {
        if project.overallProgress >= 1.0 {
            return .success
        } else if project.isDelayed {
            return .error
        } else {
            return .primaryWood
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - Add Project View (Placeholder)

/// 添加项目视图（占位）
struct AddProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ProjectManager.self) private var projectManager

    @State private var name = ""
    @State private var houseType = "两室一厅"
    @State private var area: Double = 100
    @State private var startDate = Date()
    @State private var estimatedDuration: Int = 90

    private let houseTypes = ["一室一厅", "两室一厅", "两室两厅", "三室一厅", "三室两厅", "四室两厅", "复式", "别墅", "其他"]

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("项目名称", text: $name)
                        .textInputAutocapitalization(.never)

                    Picker("房屋类型", selection: $houseType) {
                        ForEach(houseTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }

                    HStack {
                        Text("建筑面积")
                        Spacer()
                        TextField("面积", value: $area, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("㎡")
                            .foregroundColor(.textSecondary)
                    }
                }

                Section("时间规划") {
                    DatePicker("开工日期", selection: $startDate, displayedComponents: .date)

                    Stepper("预计工期：\(estimatedDuration) 天", value: $estimatedDuration, in: 30...365, step: 15)
                }

                Section {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("预计完工")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        Text(formatDate(estimatedEndDate))
                            .font(.titleSmall)
                    }
                }
            }
            .navigationTitle("新建项目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("创建") {
                        createProject()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private var estimatedEndDate: Date {
        Calendar.current.date(byAdding: .day, value: estimatedDuration, to: startDate) ?? startDate
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    private func createProject() {
        let project = Project(
            name: name,
            houseType: houseType,
            area: area,
            startDate: startDate,
            estimatedDuration: estimatedDuration
        )

        modelContext.insert(project)
        projectManager.selectProject(project)
        dismiss()
    }
}

// MARK: - Preview

#Preview("Project List") {
    NavigationStack {
        ProjectListView()
    }
    .environment(ProjectManager())
    .modelContainer(for: [Project.self, Budget.self, Phase.self], inMemory: true)
}
