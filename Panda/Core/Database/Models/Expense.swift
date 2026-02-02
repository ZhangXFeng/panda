//
//  Expense.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

/// 支出记录模型
@Model
final class Expense {
    // MARK: - Properties

    /// 唯一标识符
    var id: UUID

    /// 支出金额
    var amount: Decimal

    /// 支出分类
    var category: ExpenseCategory

    /// 支出日期
    var date: Date

    /// 备注说明
    var notes: String

    /// 照片/凭证数据（多张图片）
    var photoData: [Data]

    /// 付款方式
    var paymentType: PaymentType

    /// 关联的供应商/商家名称
    var vendor: String

    /// 创建时间
    var createdAt: Date

    /// 最后更新时间
    var updatedAt: Date

    // MARK: - Relationships

    /// 关联的预算（反向关系）
    var budget: Budget?

    // MARK: - Initialization

    init(
        amount: Decimal,
        category: ExpenseCategory,
        date: Date = Date(),
        notes: String = "",
        photoData: [Data] = [],
        paymentType: PaymentType = .fullPayment,
        vendor: String = ""
    ) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
        self.photoData = photoData
        self.paymentType = paymentType
        self.vendor = vendor
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// 格式化金额显示
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 2

        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0.00"
    }

    /// 格式化日期显示
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")

        return formatter.string(from: date)
    }

    /// 是否有照片
    var hasPhotos: Bool {
        !photoData.isEmpty
    }

    /// 照片数量
    var photoCount: Int {
        photoData.count
    }
}

// MARK: - Payment Type

/// 付款方式
enum PaymentType: String, Codable, CaseIterable, Identifiable {
    /// 全款
    case fullPayment = "full"

    /// 定金
    case deposit = "deposit"

    /// 尾款
    case finalPayment = "final"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fullPayment: return "全款"
        case .deposit: return "定金"
        case .finalPayment: return "尾款"
        }
    }

    var icon: String {
        switch self {
        case .fullPayment: return "banknote"
        case .deposit: return "creditcard"
        case .finalPayment: return "checkmark.circle"
        }
    }
}

// MARK: - Helper Methods

extension Expense {
    /// 更新时间戳
    func updateTimestamp() {
        updatedAt = Date()
    }

    /// 添加照片
    func addPhoto(_ data: Data) {
        photoData.append(data)
        updateTimestamp()
    }

    /// 删除照片
    func removePhoto(at index: Int) {
        guard index >= 0 && index < photoData.count else { return }
        photoData.remove(at: index)
        updateTimestamp()
    }

    /// 更新金额
    func updateAmount(_ newAmount: Decimal) {
        amount = newAmount
        updateTimestamp()
    }

    /// 更新分类
    func updateCategory(_ newCategory: ExpenseCategory) {
        category = newCategory
        updateTimestamp()
    }

    /// 更新备注
    func updateNotes(_ newNotes: String) {
        notes = newNotes
        updateTimestamp()
    }
}

// MARK: - Sorting

extension Expense {
    /// 按日期排序（降序）
    static func sortByDateDescending(_ lhs: Expense, _ rhs: Expense) -> Bool {
        lhs.date > rhs.date
    }

    /// 按日期排序（升序）
    static func sortByDateAscending(_ lhs: Expense, _ rhs: Expense) -> Bool {
        lhs.date < rhs.date
    }

    /// 按金额排序（降序）
    static func sortByAmountDescending(_ lhs: Expense, _ rhs: Expense) -> Bool {
        lhs.amount > rhs.amount
    }

    /// 按金额排序（升序）
    static func sortByAmountAscending(_ lhs: Expense, _ rhs: Expense) -> Bool {
        lhs.amount < rhs.amount
    }
}
