//
//  AddMaterialViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI

@MainActor
class AddMaterialViewModel: ObservableObject {
    // MARK: - Properties

    @Published var name: String = ""
    @Published var brand: String = ""
    @Published var specification: String = ""
    @Published var unitPrice: String = ""
    @Published var quantity: String = ""
    @Published var unit: String = "个"
    @Published var status: MaterialStatus = .pending
    @Published var location: String = ""
    @Published var notes: String = ""
    @Published var photoData: [Data] = []
    @Published var selectedPhotos: [PhotosPickerItem] = []

    @Published var showingError: Bool = false
    @Published var errorMessage: String = ""

    private let modelContext: ModelContext
    private let projectManager: ProjectManager
    private var materialToEdit: Material?

    var isEditMode: Bool {
        materialToEdit != nil
    }

    var title: String {
        isEditMode ? "编辑材料" : "添加材料"
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !unitPrice.isEmpty &&
        !quantity.isEmpty &&
        unitPriceDecimal != nil &&
        quantityDouble != nil
    }

    var unitPriceDecimal: Decimal? {
        Decimal(string: unitPrice)
    }

    var quantityDouble: Double? {
        Double(quantity)
    }

    var totalPrice: Decimal {
        guard let price = unitPriceDecimal, let qty = quantityDouble else { return 0 }
        return price * Decimal(qty)
    }

    var formattedTotalPrice: String {
        formatCurrency(totalPrice)
    }

    // MARK: - Common Units

    static let commonUnits = ["个", "㎡", "延米", "平米", "块", "桶", "袋", "箱", "卷", "张", "根", "套"]

    // MARK: - Common Locations

    static let commonLocations = ["客厅", "主卧", "次卧", "书房", "厨房", "卫生间", "阳台", "玄关", "餐厅"]

    // MARK: - Initialization

    init(
        modelContext: ModelContext,
        material: Material? = nil,
        projectManager: ProjectManager = ProjectManager.shared
    ) {
        self.modelContext = modelContext
        self.projectManager = projectManager
        self.materialToEdit = material

        if let material = material {
            loadMaterial(material)
        }
    }

    // MARK: - Methods

    private func loadMaterial(_ material: Material) {
        name = material.name
        brand = material.brand
        specification = material.specification
        unitPrice = String(describing: material.unitPrice)
        quantity = String(material.quantity)
        unit = material.unit
        status = material.status
        location = material.location
        notes = material.notes
        photoData = material.photoData
    }

    func save() -> Bool {
        guard canSave else {
            showError("请填写必填字段（名称、单价、数量）")
            return false
        }

        guard let currentProject = projectManager.currentProject else {
            showError("请先选择或创建项目")
            return false
        }

        guard let priceDecimal = unitPriceDecimal, let qtyDouble = quantityDouble else {
            showError("请输入有效的单价和数量")
            return false
        }

        do {
            if let materialToEdit = materialToEdit {
                // Edit mode
                updateExistingMaterial(materialToEdit)
            } else {
                // Add mode
                createNewMaterial(project: currentProject, unitPrice: priceDecimal, quantity: qtyDouble)
            }

            try modelContext.save()
            return true
        } catch {
            showError("保存失败: \(error.localizedDescription)")
            return false
        }
    }

    private func createNewMaterial(project: Project, unitPrice: Decimal, quantity: Double) {
        let material = Material(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            brand: brand.trimmingCharacters(in: .whitespacesAndNewlines),
            specification: specification.trimmingCharacters(in: .whitespacesAndNewlines),
            unitPrice: unitPrice,
            quantity: quantity,
            unit: unit,
            status: status,
            location: location.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        material.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        material.photoData = photoData
        material.project = project
        modelContext.insert(material)
    }

    private func updateExistingMaterial(_ material: Material) {
        material.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        material.brand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
        material.specification = specification.trimmingCharacters(in: .whitespacesAndNewlines)

        if let price = unitPriceDecimal {
            material.unitPrice = price
        }
        if let qty = quantityDouble {
            material.quantity = qty
        }

        material.unit = unit
        material.status = status
        material.location = location.trimmingCharacters(in: .whitespacesAndNewlines)
        material.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        material.photoData = photoData
        material.updateTimestamp()
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }

    // MARK: - Photo Management

    func addPhoto(_ data: Data) {
        photoData.append(data)
    }

    func removePhoto(at index: Int) {
        guard index >= 0 && index < photoData.count else { return }
        photoData.remove(at: index)
    }

    func loadSelectedPhotos() async {
        for item in selectedPhotos {
            if let data = try? await item.loadTransferable(type: Data.self) {
                photoData.append(data)
            }
        }
    }

    // MARK: - Helpers

    func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0.00"
    }
}
