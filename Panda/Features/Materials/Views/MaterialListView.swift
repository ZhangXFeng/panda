//
//  MaterialListView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct MaterialListView: View {
    @Environment(ProjectManager.self) private var projectManager
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]
    @State private var selectedStatus: MaterialStatus?

    /// 当前选中的项目
    private var currentProject: Project? {
        projectManager.currentProject(from: projects)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let project = currentProject {
                    VStack(spacing: Spacing.md) {
                        // 筛选器
                        statusFilterSection()

                        // 材料列表
                        materialsSection(project: project)
                    }
                    .padding()
                } else {
                    emptyState
                }
            }
            .navigationTitle("材料管理")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Components

    private func statusFilterSection() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                FilterChip(title: "全部", isSelected: selectedStatus == nil) {
                    selectedStatus = nil
                }

                ForEach(MaterialStatus.allCases) { status in
                    FilterChip(title: status.displayName, isSelected: selectedStatus == status) {
                        selectedStatus = status
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func materialsSection(project: Project) -> some View {
        VStack(spacing: Spacing.md) {
            let materials = filteredMaterials(project: project)

            if materials.isEmpty {
                Text("暂无材料记录")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .padding()
            } else {
                ForEach(materials) { material in
                    MaterialCard(material: material)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "cube.box")
                .font(.system(size: 64))
                .foregroundColor(.textHint)
            Text("暂无材料数据")
                .font(.titleSmall)
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Helpers

    private func filteredMaterials(project: Project) -> [Material] {
        if let status = selectedStatus {
            return project.materials.filter { $0.status == status }
        }
        return project.materials
    }
}

// MARK: - Material Card

struct MaterialCard: View {
    let material: Material

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(material.name)
                            .font(.bodyMedium)
                        if !material.brand.isEmpty {
                            Text(material.brand)
                                .font(.captionRegular)
                                .foregroundColor(.textSecondary)
                        }
                    }

                    Spacer()

                    statusBadge(for: material.status)
                }

                if !material.specification.isEmpty {
                    Text(material.specification)
                        .font(.captionRegular)
                        .foregroundColor(.textSecondary)
                }

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("单价")
                            .font(.smallRegular)
                            .foregroundColor(.textSecondary)
                        Text(material.formattedUnitPrice)
                            .font(.captionMedium)
                    }

                    Spacer()

                    VStack(alignment: .center, spacing: Spacing.xs) {
                        Text("数量")
                            .font(.smallRegular)
                            .foregroundColor(.textSecondary)
                        Text("\(String(format: "%.1f", material.quantity)) \(material.unit)")
                            .font(.captionMedium)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        Text("总价")
                            .font(.smallRegular)
                            .foregroundColor(.textSecondary)
                        Text(material.formattedTotalPrice)
                            .font(.captionMedium)
                            .foregroundColor(.primaryWood)
                    }
                }

                if !material.location.isEmpty {
                    HStack {
                        Image(systemName: "mappin.circle")
                            .foregroundColor(.textSecondary)
                        Text(material.location)
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
    }

    private func statusBadge(for status: MaterialStatus) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: status.iconName)
            Text(status.displayName)
        }
        .font(.captionMedium)
        .foregroundColor(.white)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(status.color)
        .cornerRadius(CornerRadius.sm)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.captionMedium)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.primaryWood : Color.bgCard)
                .cornerRadius(CornerRadius.lg)
        }
    }
}

#Preview {
    MaterialListView()
        .environment(ProjectManager())
        .modelContainer(for: [Project.self, Material.self], inMemory: true)
}
