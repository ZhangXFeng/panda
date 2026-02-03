//
//  ProjectSelectorView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

/// 项目选择器组件 - 在导航栏显示当前项目并支持切换
struct ProjectSelectorView: View {
    // MARK: - Properties

    @Environment(ProjectManager.self) private var projectManager
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]
    @State private var showingProjectList = false

    // MARK: - Body

    var body: some View {
        Button {
            showingProjectList = true
        } label: {
            HStack(spacing: Spacing.xs) {
                if let currentProject = projectManager.currentProject(from: projects) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 16))
                    Text(currentProject.name)
                        .font(.titleSmall)
                        .lineLimit(1)
                } else {
                    Image(systemName: "house")
                        .font(.system(size: 16))
                    Text("选择项目")
                        .font(.titleSmall)
                }
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.textPrimary)
        }
        .sheet(isPresented: $showingProjectList) {
            ProjectListSheet(
                projects: projects,
                currentProjectId: projectManager.currentProjectId
            ) { project in
                projectManager.selectProject(project)
                showingProjectList = false
            }
        }
    }
}

// MARK: - Project List Sheet

/// 项目列表弹窗
struct ProjectListSheet: View {
    let projects: [Project]
    let currentProjectId: UUID?
    let onSelect: (Project) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if projects.isEmpty {
                    emptyState
                } else {
                    ForEach(projects, id: \.id) { project in
                        ProjectRowView(
                            project: project,
                            isSelected: project.id == currentProjectId
                        ) {
                            onSelect(project)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("我的项目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "house")
                .font(.system(size: 48))
                .foregroundColor(.textHint)
            Text("暂无项目")
                .font(.bodyRegular)
                .foregroundColor(.textSecondary)
            Text("请先创建装修项目")
                .font(.captionRegular)
                .foregroundColor(.textHint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
        .listRowBackground(Color.clear)
    }
}

// MARK: - Project Row View

/// 项目行视图
struct ProjectRowView: View {
    let project: Project
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // 项目图标
                projectIcon

                // 项目信息
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(project.name)
                            .font(.titleSmall)
                            .foregroundColor(.textPrimary)

                        if project.isActive {
                            Text("进行中")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.success)
                                .cornerRadius(4)
                        }
                    }

                    Text("\(project.houseType) · \(Int(project.area))㎡")
                        .font(.captionRegular)
                        .foregroundColor(.textSecondary)

                    // 进度信息
                    HStack(spacing: Spacing.sm) {
                        ProgressView(value: project.overallProgress)
                            .progressViewStyle(.linear)
                            .frame(width: 60)
                            .tint(.primaryWood)

                        Text("\(Int(project.overallProgress * 100))%")
                            .font(.captionMedium)
                            .foregroundColor(.textSecondary)
                    }
                }

                Spacer()

                // 选中指示器
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primaryWood)
                        .font(.system(size: 24))
                }
            }
            .padding(.vertical, Spacing.xs)
        }
        .buttonStyle(.plain)
    }

    private var projectIcon: some View {
        Group {
            if let imageData = project.coverImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "house.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.primaryWood)
            }
        }
        .frame(width: 56, height: 56)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.md)
    }
}

// MARK: - Preview

#Preview("Project Selector") {
    NavigationStack {
        Text("首页内容")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ProjectSelectorView()
                }
            }
    }
    .environment(ProjectManager())
    .modelContainer(for: [Project.self, Budget.self, Phase.self], inMemory: true)
}
