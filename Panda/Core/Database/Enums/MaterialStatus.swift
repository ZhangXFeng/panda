//
//  MaterialStatus.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftUI

/// 材料状态
enum MaterialStatus: String, Codable, CaseIterable, Identifiable {
    // MARK: - Cases

    /// 待购买
    case pending = "pending"

    /// 已下单
    case ordered = "ordered"

    /// 已购买
    case purchased = "purchased"

    /// 已到货
    case delivered = "delivered"

    /// 已安装
    case installed = "installed"

    /// 有问题
    case issue = "issue"

    // MARK: - Properties

    var id: String { rawValue }

    /// 状态显示名称
    var displayName: String {
        switch self {
        case .pending: return "待购买"
        case .ordered: return "已下单"
        case .purchased: return "已购买"
        case .delivered: return "已到货"
        case .installed: return "已安装"
        case .issue: return "有问题"
        }
    }

    /// 状态颜色
    var color: Color {
        switch self {
        case .pending: return .textHint
        case .ordered: return .info
        case .purchased: return .warning
        case .delivered: return .primaryWood
        case .installed: return .success
        case .issue: return .error
        }
    }

    /// SF Symbol 图标名称
    var iconName: String {
        switch self {
        case .pending: return "cart"
        case .ordered: return "shippingbox"
        case .purchased: return "bag"
        case .delivered: return "cube.box"
        case .installed: return "checkmark.circle.fill"
        case .issue: return "exclamationmark.triangle.fill"
        }
    }

    /// 流程进度（百分比）
    var progressPercentage: Double {
        switch self {
        case .pending: return 0
        case .ordered: return 25
        case .purchased: return 50
        case .delivered: return 75
        case .installed: return 100
        case .issue: return 0
        }
    }
}
