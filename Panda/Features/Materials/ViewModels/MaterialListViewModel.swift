//
//  MaterialListViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class MaterialListViewModel: ObservableObject {
    // MARK: - Properties

    @Published var materials: [Material] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: MaterialStatus?
    @Published var showingAddMaterial: Bool = false
    @Published var showingCalculator: Bool = false
    @Published var selectedMaterial: Material?

    private let modelContext: ModelContext
    private let projectManager: ProjectManager

    // MARK: - Computed Properties

    var filteredMaterials: [Material] {
        var result = materials

        // Filter by status
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { material in
                material.name.localizedCaseInsensitiveContains(searchText) ||
                material.brand.localizedCaseInsensitiveContains(searchText) ||
                material.specification.localizedCaseInsensitiveContains(searchText) ||
                material.location.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { $0.createdAt > $1.createdAt }
    }

    var groupedByStatus: [(status: MaterialStatus, materials: [Material])] {
        let grouped = Dictionary(grouping: filteredMaterials) { $0.status }
        return MaterialStatus.allCases.compactMap { status in
            guard let materials = grouped[status], !materials.isEmpty else { return nil }
            return (status, materials)
        }
    }

    var groupedByLocation: [(location: String, materials: [Material])] {
        let grouped = Dictionary(grouping: filteredMaterials) { material in
            material.location.isEmpty ? "未指定位置" : material.location
        }
        return grouped.map { (location: $0.key, materials: $0.value) }
            .sorted { $0.location < $1.location }
    }

    var totalCost: Decimal {
        materials.reduce(0) { $0 + $1.totalPrice }
    }

    var pendingMaterials: [Material] {
        materials.filter { $0.status == .pending }
    }

    var orderedMaterials: [Material] {
        materials.filter { $0.status == .ordered }
    }

    var deliveredMaterials: [Material] {
        materials.filter { $0.status == .delivered }
    }

    var issueMaterials: [Material] {
        materials.filter { $0.status == .issue }
    }

    // MARK: - Initialization

    init(modelContext: ModelContext, projectManager: ProjectManager = ProjectManager.shared) {
        self.modelContext = modelContext
        self.projectManager = projectManager
    }

    // MARK: - Methods

    func loadMaterials() {
        guard let currentProject = projectManager.currentProject(in: modelContext) else {
            materials = []
            return
        }

        let projectID = currentProject.id
        let descriptor = FetchDescriptor<Material>(
            predicate: #Predicate<Material> { material in
                material.project?.id == projectID
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            materials = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch materials: \(error)")
            materials = []
        }
    }

    func deleteMaterial(_ material: Material) {
        modelContext.delete(material)

        do {
            try modelContext.save()
            loadMaterials()
        } catch {
            print("Failed to delete material: \(error)")
        }
    }

    func deleteMaterials(at offsets: IndexSet, from materials: [Material]) {
        for index in offsets {
            let material = materials[index]
            deleteMaterial(material)
        }
    }

    func updateMaterialStatus(_ material: Material, to status: MaterialStatus) {
        material.updateStatus(status)

        do {
            try modelContext.save()
            loadMaterials()
        } catch {
            print("Failed to update material status: \(error)")
        }
    }

    func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0.00"
    }
}
