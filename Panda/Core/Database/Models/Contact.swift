//
//  Contact.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

/// 联系人模型
@Model
final class Contact {
    // MARK: - Properties

    /// 唯一标识符
    var id: UUID

    /// 姓名
    var name: String

    /// 角色/职责
    var role: ContactRole

    /// 电话号码
    var phoneNumber: String

    /// 微信号
    var wechatID: String

    /// 公司/店铺名称
    var company: String

    /// 地址
    var address: String

    /// 评分（1-5星）
    var rating: Int

    /// 备注
    var notes: String

    /// 是否推荐
    var isRecommended: Bool

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
        role: ContactRole,
        phoneNumber: String,
        wechatID: String = "",
        company: String = "",
        address: String = "",
        rating: Int = 0,
        notes: String = "",
        isRecommended: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.phoneNumber = phoneNumber
        self.wechatID = wechatID
        self.company = company
        self.address = address
        self.rating = max(0, min(5, rating))
        self.notes = notes
        self.isRecommended = isRecommended
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Contact Role

/// 联系人角色
enum ContactRole: String, Codable, CaseIterable, Identifiable {
    case company = "company"           // 装修公司
    case designer = "designer"         // 设计师
    case foreman = "foreman"          // 工长/项目经理
    case electrician = "electrician"   // 水电工
    case mason = "mason"              // 泥瓦工
    case carpenter = "carpenter"      // 木工
    case painter = "painter"          // 油漆工
    case vendor = "vendor"            // 材料商家
    case other = "other"              // 其他

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .company: return "装修公司"
        case .designer: return "设计师"
        case .foreman: return "工长"
        case .electrician: return "水电工"
        case .mason: return "泥瓦工"
        case .carpenter: return "木工"
        case .painter: return "油漆工"
        case .vendor: return "材料商家"
        case .other: return "其他"
        }
    }

    var iconName: String {
        switch self {
        case .company: return "building.2"
        case .designer: return "paintbrush"
        case .foreman: return "person.crop.circle.badge.checkmark"
        case .electrician: return "bolt"
        case .mason: return "square.grid.3x3"
        case .carpenter: return "tree"
        case .painter: return "paintpalette"
        case .vendor: return "cart"
        case .other: return "person"
        }
    }
}

extension Contact {
    func updateTimestamp() {
        updatedAt = Date()
    }
}
