//
//  ExpenseCategory.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation

/// 支出分类
enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    // MARK: - Cases

    /// 设计费
    case design = "design"

    /// 硬装 - 拆改
    case demolition = "demolition"

    /// 硬装 - 水电
    case plumbing = "plumbing"

    /// 硬装 - 泥瓦
    case masonry = "masonry"

    /// 硬装 - 木工
    case carpentry = "carpentry"

    /// 硬装 - 油漆
    case painting = "painting"

    /// 主材 - 地板/瓷砖
    case flooring = "flooring"

    /// 主材 - 门窗
    case doors = "doors"

    /// 主材 - 橱柜
    case cabinets = "cabinets"

    /// 主材 - 卫浴
    case bathroom = "bathroom"

    /// 主材 - 灯具
    case lighting = "lighting"

    /// 软装 - 家具
    case furniture = "furniture"

    /// 软装 - 家电
    case appliances = "appliances"

    /// 软装 - 窗帘
    case curtains = "curtains"

    /// 软装 - 装饰品
    case decorations = "decorations"

    /// 其他/应急
    case other = "other"

    // MARK: - Properties

    var id: String { rawValue }

    /// 分类显示名称
    var displayName: String {
        switch self {
        case .design: return "设计费"
        case .demolition: return "拆改"
        case .plumbing: return "水电"
        case .masonry: return "泥瓦"
        case .carpentry: return "木工"
        case .painting: return "油漆"
        case .flooring: return "地板/瓷砖"
        case .doors: return "门窗"
        case .cabinets: return "橱柜"
        case .bathroom: return "卫浴"
        case .lighting: return "灯具"
        case .furniture: return "家具"
        case .appliances: return "家电"
        case .curtains: return "窗帘"
        case .decorations: return "装饰品"
        case .other: return "其他"
        }
    }

    /// 父分类
    var parentCategory: ParentCategory {
        switch self {
        case .design:
            return .design
        case .demolition, .plumbing, .masonry, .carpentry, .painting:
            return .hardDecoration
        case .flooring, .doors, .cabinets, .bathroom, .lighting:
            return .mainMaterials
        case .furniture, .appliances, .curtains, .decorations:
            return .softDecoration
        case .other:
            return .other
        }
    }

    /// SF Symbol 图标名称
    var iconName: String {
        switch self {
        case .design: return "paintbrush"
        case .demolition: return "hammer"
        case .plumbing: return "water.waves"
        case .masonry: return "square.grid.2x2"
        case .carpentry: return "tree"
        case .painting: return "paintpalette"
        case .flooring: return "square.split.2x2"
        case .doors: return "door.left.hand.open"
        case .cabinets: return "cabinet"
        case .bathroom: return "shower"
        case .lighting: return "lightbulb"
        case .furniture: return "sofa"
        case .appliances: return "tv"
        case .curtains: return "wind"
        case .decorations: return "star"
        case .other: return "ellipsis.circle"
        }
    }
}

// MARK: - Parent Category

/// 父分类
enum ParentCategory: String, Codable, CaseIterable {
    case design = "design"
    case hardDecoration = "hard_decoration"
    case mainMaterials = "main_materials"
    case softDecoration = "soft_decoration"
    case other = "other"

    var displayName: String {
        switch self {
        case .design: return "设计费"
        case .hardDecoration: return "硬装"
        case .mainMaterials: return "主材"
        case .softDecoration: return "软装"
        case .other: return "其他"
        }
    }

    /// 获取该父分类下的所有子分类
    var subCategories: [ExpenseCategory] {
        ExpenseCategory.allCases.filter { $0.parentCategory == self }
    }
}
