//
//  Document.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData

/// 文档模型（合同、收据、发票等）
@Model
final class Document {
    // MARK: - Properties

    /// 唯一标识符
    var id: UUID

    /// 文档名称/标题
    var name: String

    /// 文档类型
    var type: DocumentType

    /// 文档照片数据（支持多张照片）
    var photoData: [Data]

    /// 文档日期
    var date: Date

    /// 备注
    var notes: String

    // MARK: - Contract Specific Properties

    /// 合同金额（仅合同类型使用）
    var contractAmount: Decimal?

    /// 付款方式
    var paymentMethod: PaymentMethod?

    /// 付款记录
    var paymentRecords: [PaymentRecord]

    /// 合同开始日期
    var contractStartDate: Date?

    /// 合同结束日期
    var contractEndDate: Date?

    /// 甲方（业主）
    var partyA: String

    /// 乙方（装修公司/承包方）
    var partyB: String

    // MARK: - Metadata

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
        type: DocumentType,
        photoData: [Data] = [],
        date: Date = Date(),
        notes: String = "",
        contractAmount: Decimal? = nil,
        paymentMethod: PaymentMethod? = nil,
        paymentRecords: [PaymentRecord] = [],
        contractStartDate: Date? = nil,
        contractEndDate: Date? = nil,
        partyA: String = "",
        partyB: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.photoData = photoData
        self.date = date
        self.notes = notes
        self.contractAmount = contractAmount
        self.paymentMethod = paymentMethod
        self.paymentRecords = paymentRecords
        self.contractStartDate = contractStartDate
        self.contractEndDate = contractEndDate
        self.partyA = partyA
        self.partyB = partyB
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// 是否有照片
    var hasPhotos: Bool {
        !photoData.isEmpty
    }

    /// 照片数量
    var photoCount: Int {
        photoData.count
    }

    /// 是否是合同类型
    var isContract: Bool {
        type == .contract
    }

    /// 已付金额
    var totalPaid: Decimal {
        paymentRecords.filter { $0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    /// 未付金额
    var totalUnpaid: Decimal {
        guard let contractAmount = contractAmount else { return 0 }
        return contractAmount - totalPaid
    }

    /// 付款进度（0-1）
    var paymentProgress: Double {
        guard let contractAmount = contractAmount, contractAmount > 0 else { return 0 }
        return Double(truncating: totalPaid as NSNumber) / Double(truncating: contractAmount as NSNumber)
    }

    /// 是否付清
    var isFullyPaid: Bool {
        totalUnpaid <= 0
    }

    /// 格式化日期
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    /// 格式化金额
    var formattedAmount: String? {
        guard let amount = contractAmount else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: amount as NSNumber)
    }
}

// MARK: - Helper Methods

extension Document {
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

    /// 添加付款记录
    func addPaymentRecord(_ record: PaymentRecord) {
        paymentRecords.append(record)
        updateTimestamp()
    }

    /// 标记付款记录为已付
    func markPaymentAsPaid(at index: Int) {
        guard index >= 0 && index < paymentRecords.count else { return }
        paymentRecords[index].isPaid = true
        paymentRecords[index].paidDate = Date()
        updateTimestamp()
    }
}

// MARK: - Document Type

/// 文档类型
enum DocumentType: String, Codable, CaseIterable, Identifiable {
    case contract = "contract"         // 合同
    case receipt = "receipt"           // 收据
    case invoice = "invoice"           // 发票
    case permit = "permit"             // 许可证/证件
    case drawing = "drawing"           // 设计图纸
    case warranty = "warranty"         // 保修单
    case other = "other"              // 其他

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .contract: return "合同"
        case .receipt: return "收据"
        case .invoice: return "发票"
        case .permit: return "许可证/证件"
        case .drawing: return "设计图纸"
        case .warranty: return "保修单"
        case .other: return "其他"
        }
    }

    var iconName: String {
        switch self {
        case .contract: return "doc.text.fill"
        case .receipt: return "receipt"
        case .invoice: return "doc.plaintext"
        case .permit: return "checkmark.seal"
        case .drawing: return "pencil.and.ruler"
        case .warranty: return "shield.checkered"
        case .other: return "doc"
        }
    }
}

// MARK: - Payment Method

/// 付款方式
enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case lumpSum = "lump_sum"          // 全款
    case installment = "installment"   // 分期
    case progressive = "progressive"   // 按进度付款

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lumpSum: return "全款"
        case .installment: return "分期"
        case .progressive: return "按进度付款"
        }
    }
}

// MARK: - Payment Record

/// 付款记录
struct PaymentRecord: Codable {
    var id: UUID
    var name: String              // 付款节点名称（如：定金、中期款、尾款）
    var amount: Decimal           // 金额
    var dueDate: Date?            // 应付日期
    var isPaid: Bool              // 是否已付
    var paidDate: Date?           // 实际付款日期
    var notes: String             // 备注

    init(
        name: String,
        amount: Decimal,
        dueDate: Date? = nil,
        isPaid: Bool = false,
        paidDate: Date? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.dueDate = dueDate
        self.isPaid = isPaid
        self.paidDate = paidDate
        self.notes = notes
    }

    /// 是否逾期
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isPaid else { return false }
        return dueDate < Date()
    }

    /// 格式化金额
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: amount as NSNumber) ?? "¥0"
    }
}
