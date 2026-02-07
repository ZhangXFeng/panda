//
//  MaterialListView.swift
//  Panda
//
//  Enhanced on 2026-02-03.
//

import SwiftUI
import SwiftData

struct MaterialListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: MaterialListViewModel
    @State private var showingAddMaterial = false
    @State private var showingCalculator = false
    @State private var selectedMaterial: Material?

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: MaterialListViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Total cost banner
                if !viewModel.materials.isEmpty {
                    totalCostBanner
                }

                // Status filter chips
                statusFilterSection

                // Material list
                if viewModel.filteredMaterials.isEmpty {
                    emptyState
                } else {
                    materialList
                }
            }
            .navigationTitle("材料管理")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingAddMaterial = true
                        } label: {
                            Label("添加材料", systemImage: "plus")
                        }

                        Button {
                            showingCalculator = true
                        } label: {
                            Label("材料计算器", systemImage: "function")
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddMaterial) {
                AddMaterialView(modelContext: modelContext)
                    .onDisappear {
                        viewModel.loadMaterials()
                    }
            }
            .sheet(isPresented: $showingCalculator) {
                MaterialCalculatorView()
            }
            .sheet(item: $selectedMaterial) { material in
                MaterialDetailView(material: material)
                    .onDisappear {
                        viewModel.loadMaterials()
                    }
            }
            .onAppear {
                viewModel.loadMaterials()
            }
        }
    }

    // MARK: - Total Cost Banner

    private var totalCostBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("材料总成本")
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textSecondary)

                Text(viewModel.formatCurrency(viewModel.totalCost))
                    .font(Fonts.titleMedium)
                    .foregroundColor(Colors.primary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("总计")
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textSecondary)

                Text("\(viewModel.materials.count) 项")
                    .font(Fonts.headline)
            }
        }
        .padding(Spacing.md)
        .background(Colors.primary.opacity(0.1))
    }

    // MARK: - Status Filter Section

    private var statusFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                FilterChip(
                    title: "全部",
                    isSelected: viewModel.selectedStatus == nil
                ) {
                    viewModel.selectedStatus = nil
                }

                ForEach(MaterialStatus.allCases) { status in
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

    // MARK: - Material List

    private var materialList: some View {
        List {
            ForEach(viewModel.groupedByStatus, id: \.status) { group in
                Section {
                    ForEach(group.materials) { material in
                        MaterialRow(material: material, viewModel: viewModel)
                            .onTapGesture {
                                selectedMaterial = material
                            }
                    }
                    .onDelete { offsets in
                        viewModel.deleteMaterials(at: offsets, from: group.materials)
                    }
                } header: {
                    HStack {
                        Image(systemName: group.status.iconName)
                            .foregroundColor(group.status.color)
                            .font(.caption)
                        Text(group.status.displayName)
                            .font(.headline)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "shippingbox")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("还没有材料")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("点击右上角 + 添加材料")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Material Row

private struct MaterialRow: View {
    let material: Material
    let viewModel: MaterialListViewModel

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Status icon
            ZStack {
                Circle()
                    .fill(material.status.color.opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: material.status.iconName)
                    .foregroundColor(material.status.color)
                    .font(.system(size: 18))
            }

            // Material info
            VStack(alignment: .leading, spacing: 4) {
                Text(material.name)
                    .font(Fonts.headline)
                    .lineLimit(2)

                if !material.brand.isEmpty {
                    Text(material.brand)
                        .font(Fonts.caption)
                        .foregroundColor(Colors.textSecondary)
                }

                HStack {
                    if !material.location.isEmpty {
                        Label(material.location, systemImage: "location")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.textSecondary)
                    }

                    Text("\(material.quantity, specifier: "%.0f") \(material.unit)")
                        .font(Fonts.caption)
                        .foregroundColor(Colors.textSecondary)
                }
            }

            Spacer()

            // Price
            VStack(alignment: .trailing, spacing: 4) {
                Text(material.formattedTotalPrice)
                    .font(Fonts.headline)
                    .foregroundColor(Colors.primary)

                Text(material.formattedUnitPrice)
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textSecondary)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Material.self, configurations: config)

    MaterialListView(modelContext: container.mainContext)
        .modelContainer(container)
}
