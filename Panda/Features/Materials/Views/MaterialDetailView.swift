//
//  MaterialDetailView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct MaterialDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let material: Material
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header
                    headerSection

                    // Price card
                    priceCard

                    // Details
                    detailsCard

                    // Photos
                    if material.hasPhotos {
                        photosSection
                    }

                    // Notes
                    if !material.notes.isEmpty {
                        notesCard
                    }

                    // Metadata
                    metadataSection
                }
                .padding(Spacing.md)
            }
            .background(Colors.backgroundPrimary)
            .navigationTitle("材料详情")
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
                AddMaterialView(modelContext: modelContext, material: material)
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteMaterial()
                }
            } message: {
                Text("确定要删除这个材料吗？此操作无法撤销。")
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: material.status.iconName)
                    .font(.title2)
                    .foregroundColor(material.status.color)
                Text(material.status.displayName)
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textSecondary)
            }

            Text(material.name)
                .font(Fonts.titleMedium)

            if !material.brand.isEmpty || !material.specification.isEmpty {
                HStack {
                    if !material.brand.isEmpty {
                        Text(material.brand)
                            .font(Fonts.body)
                            .foregroundColor(Colors.textSecondary)
                    }

                    if !material.specification.isEmpty {
                        Text(material.specification)
                            .font(Fonts.caption)
                            .foregroundColor(Colors.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Price Card

    private var priceCard: some View {
        CardView {
            VStack(spacing: Spacing.md) {
                HStack {
                    Text("价格信息")
                        .font(Fonts.headline)
                    Spacer()
                }

                Divider()

                HStack {
                    Text("单价")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(material.formattedUnitPrice)
                        .font(Fonts.headline)
                }

                HStack {
                    Text("数量")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(material.quantity, specifier: "%.2f") \(material.unit)")
                        .font(Fonts.headline)
                }

                Divider()

                HStack {
                    Text("总价")
                        .font(Fonts.headline)
                    Spacer()
                    Text(material.formattedTotalPrice)
                        .font(Fonts.titleSmall)
                        .foregroundColor(Colors.primary)
                }
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("详细信息")
                    .font(Fonts.headline)

                Divider()

                if !material.location.isEmpty {
                    infoRow(label: "使用位置", value: material.location)
                }

                infoRow(label: "单位", value: material.unit)
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
                ForEach(Array(material.photoData.enumerated()), id: \.offset) { _, data in
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

    // MARK: - Notes Card

    private var notesCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("备注")
                    .font(Fonts.headline)

                Divider()

                Text(material.notes)
                    .font(Fonts.body)
                    .foregroundColor(Colors.textSecondary)
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Metadata Section

    private var metadataSection: some View {
        VStack(spacing: Spacing.xs) {
            Text("创建于 \(material.createdAt.formatted(date: .long, time: .shortened))")
                .font(Fonts.caption)
                .foregroundColor(Colors.textHint)

            if material.updatedAt != material.createdAt {
                Text("更新于 \(material.updatedAt.formatted(date: .long, time: .shortened))")
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

    private func deleteMaterial() {
        modelContext.delete(material)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete material: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    let material = Material(
        name: "马可波罗瓷砖",
        brand: "马可波罗",
        specification: "800x800mm 全抛釉",
        unitPrice: 89.90,
        quantity: 120,
        unit: "块",
        status: .delivered,
        location: "客厅"
    )

    MaterialDetailView(material: material)
        .modelContainer(for: [Project.self, Material.self], inMemory: true)
}
