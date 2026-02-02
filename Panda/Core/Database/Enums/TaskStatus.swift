//
//  TaskStatus.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftUI

/// 任务状态
enum TaskStatus: String, Codable, CaseIterable, Identifiable {
    // MARK: - Cases

    /// 待开始
    case pending = "pending"

    /// 进行中
    case inProgress = "in_progress"

    /// 已完成
    case completed = "completed"

    /// 有问题
    case issue = "issue"

    /// 已取消
    case cancelled = "cancelled"

    // MARK: - Properties

    var id: String { rawValue }

    /// 状态显示名称
    var displayName: String {
        switch self {
        case .pending: return "待开始"
        case .inProgress: return "进行中"
        case .completed: return "已完成"
        case .issue: return "有问题"
        case .cancelled: return "已取消"
        }
    }

    /// 状态颜色
    var color: Color {
        switch self {
        case .pending: return .textHint
        case .inProgress: return .info
        case .completed: return .success
        case .issue: return .warning
        case .cancelled: return .textSecondary
        }
    }

    /// SF Symbol 图标名称
    var iconName: String {
        switch self {
        case .pending: return "circle"
        case .inProgress: return "clock"
        case .completed: return "checkmark.circle.fill"
        case .issue: return "exclamationmark.triangle.fill"
        case .cancelled: return "xmark.circle"
        }
    }

    /// 是否为终态
    var isFinalState: Bool {
        switch self {
        case .completed, .cancelled:
            return true
        case .pending, .inProgress, .issue:
            return false
        }
    }
}
