//
//  PhaseType.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation

/// 装修阶段类型
enum PhaseType: String, Codable, CaseIterable, Identifiable {
    // MARK: - Cases

    /// 前期准备（量房、设计、预算）
    case preparation = "preparation"

    /// 拆改阶段
    case demolition = "demolition"

    /// 水电改造
    case plumbing = "plumbing"

    /// 泥瓦工程
    case masonry = "masonry"

    /// 木工工程
    case carpentry = "carpentry"

    /// 油漆工程
    case painting = "painting"

    /// 安装阶段（橱柜、门、地板等）
    case installation = "installation"

    /// 软装入场
    case softDecoration = "soft_decoration"

    /// 保洁验收
    case cleaning = "cleaning"

    /// 通风入住
    case ventilation = "ventilation"

    /// 自定义阶段
    case custom = "custom"

    // MARK: - Properties

    var id: String { rawValue }

    /// 阶段显示名称
    var displayName: String {
        switch self {
        case .preparation: return "前期准备"
        case .demolition: return "拆改阶段"
        case .plumbing: return "水电改造"
        case .masonry: return "泥瓦工程"
        case .carpentry: return "木工工程"
        case .painting: return "油漆工程"
        case .installation: return "安装阶段"
        case .softDecoration: return "软装入场"
        case .cleaning: return "保洁验收"
        case .ventilation: return "通风入住"
        case .custom: return "自定义阶段"
        }
    }

    /// 阶段描述
    var description: String {
        switch self {
        case .preparation:
            return "量房、设计、预算规划"
        case .demolition:
            return "拆墙、改造房屋结构"
        case .plumbing:
            return "水电线路改造和布局"
        case .masonry:
            return "贴瓷砖、地面找平"
        case .carpentry:
            return "吊顶、柜体制作"
        case .painting:
            return "墙面处理、刷漆"
        case .installation:
            return "安装橱柜、门窗、地板等"
        case .softDecoration:
            return "家具、窗帘、装饰品进场"
        case .cleaning:
            return "开荒保洁、验收检查"
        case .ventilation:
            return "通风散味、准备入住"
        case .custom:
            return "自定义装修阶段"
        }
    }

    /// SF Symbol 图标名称
    var iconName: String {
        switch self {
        case .preparation: return "doc.text"
        case .demolition: return "hammer"
        case .plumbing: return "bolt"
        case .masonry: return "square.grid.3x3"
        case .carpentry: return "tree"
        case .painting: return "paintbrush"
        case .installation: return "wrench.and.screwdriver"
        case .softDecoration: return "sofa"
        case .cleaning: return "sparkles"
        case .ventilation: return "wind"
        case .custom: return "star"
        }
    }

    /// 预计工期（天数）
    var estimatedDays: Int {
        switch self {
        case .preparation: return 14
        case .demolition: return 5
        case .plumbing: return 10
        case .masonry: return 15
        case .carpentry: return 15
        case .painting: return 10
        case .installation: return 10
        case .softDecoration: return 7
        case .cleaning: return 3
        case .ventilation: return 30
        case .custom: return 7
        }
    }

    /// 默认排序顺序
    var sortOrder: Int {
        switch self {
        case .preparation: return 1
        case .demolition: return 2
        case .plumbing: return 3
        case .masonry: return 4
        case .carpentry: return 5
        case .painting: return 6
        case .installation: return 7
        case .softDecoration: return 8
        case .cleaning: return 9
        case .ventilation: return 10
        case .custom: return 99
        }
    }
}
