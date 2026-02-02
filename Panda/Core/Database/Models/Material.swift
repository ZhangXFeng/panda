//
//  Material.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

/// 材料模型
@Model
final class Material {
    // MARK: - Properties

    /// 唯一标识符
    var id: UUID

    /// 材料名称
    var name: String

    /// 品牌
    var brand: String

    /// 规格型号
    var specification: String

    /// 单价
    var unitPrice: Decimal

    /// 数量
    var quantity: Double

    /// 单位（如：㎡、延米、个）
    var unit: String

    /// 材料状态
    var status: MaterialStatus

    /// 使用位置（如：客厅、主卧）
    var location: String

    /// 备注
    var notes: String

    /// 照片数据
    var photoData: [Data]

    /// 创建时间
    var createdAt: Date

    /// 最后更新时间
    var updatedAt: Date

    // MARK: - Relationships

    /// 关联的项目（反向关系）
    var project: Project?

    // MARK: - Initialization

    init(
        name: String,
        brand: String = "",
        specification: String = "",
        unitPrice: Decimal,
        quantity: Double,
        unit: String = "个",
        status: MaterialStatus = .pending,
        location: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.specification = specification
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.unit = unit
        self.status = status
        self.location = location
        self.notes = ""
        self.photoData = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// 总价
    var totalPrice: Decimal {
        unitPrice * Decimal(quantity)
    }

    /// 格式化单价
    var formattedUnitPrice: String {
        formatCurrency(unitPrice)
    }

    /// 格式化总价
    var formattedTotalPrice: String {
        formatCurrency(totalPrice)
    }

    /// 是否有照片
    var hasPhotos: Bool {
        !photoData.isEmpty
    }

    // MARK: - Private Helpers

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0.00"
    }
}

// MARK: - Helper Methods

extension Material {
    /// 更新时间戳
    func updateTimestamp() {
        updatedAt = Date()
    }

    /// 添加照片
    func addPhoto(_ data: Data) {
        photoData.append(data)
        updateTimestamp()
    }

    /// 更新状态
    func updateStatus(_ newStatus: MaterialStatus) {
        status = newStatus
        updateTimestamp()
    }
}
