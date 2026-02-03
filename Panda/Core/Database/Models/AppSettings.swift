//
//  AppSettings.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData

/// 应用设置模型
@Model
final class AppSettings {
    // MARK: - Properties

    /// 唯一标识符
    var id: UUID

    // MARK: - General Settings

    /// 主题模式
    var themeMode: ThemeMode

    /// 语言
    var language: AppLanguage

    /// 货币符号
    var currencySymbol: String

    /// 小数位数
    var decimalPlaces: Int

    // MARK: - Notification Settings

    /// 启用通知
    var notificationsEnabled: Bool

    /// 预算警告阈值（百分比）
    var budgetWarningThreshold: Double

    /// 支付提醒天数
    var paymentReminderDays: Int

    /// 任务到期提醒
    var taskDueReminderEnabled: Bool

    /// 任务提醒提前天数
    var taskReminderDays: Int

    // MARK: - Privacy & Security

    /// 启用生物识别（Face ID / Touch ID）
    var biometricAuthEnabled: Bool

    /// 启用iCloud同步
    var iCloudSyncEnabled: Bool

    /// 自动备份
    var autoBackupEnabled: Bool

    /// 备份频率（天数）
    var backupFrequencyDays: Int

    // MARK: - Display Settings

    /// 显示小数（对于货币）
    var showDecimalInCurrency: Bool

    /// 使用千位分隔符
    var useThousandsSeparator: Bool

    /// 默认视图（首页显示内容）
    var defaultView: DefaultView

    // MARK: - Timestamps

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        themeMode: ThemeMode = .system,
        language: AppLanguage = .chinese,
        currencySymbol: String = "¥",
        decimalPlaces: Int = 2,
        notificationsEnabled: Bool = true,
        budgetWarningThreshold: Double = 0.8,
        paymentReminderDays: Int = 3,
        taskDueReminderEnabled: Bool = true,
        taskReminderDays: Int = 1,
        biometricAuthEnabled: Bool = false,
        iCloudSyncEnabled: Bool = false,
        autoBackupEnabled: Bool = true,
        backupFrequencyDays: Int = 7,
        showDecimalInCurrency: Bool = true,
        useThousandsSeparator: Bool = true,
        defaultView: DefaultView = .home
    ) {
        self.id = UUID()
        self.themeMode = themeMode
        self.language = language
        self.currencySymbol = currencySymbol
        self.decimalPlaces = decimalPlaces
        self.notificationsEnabled = notificationsEnabled
        self.budgetWarningThreshold = budgetWarningThreshold
        self.paymentReminderDays = paymentReminderDays
        self.taskDueReminderEnabled = taskDueReminderEnabled
        self.taskReminderDays = taskReminderDays
        self.biometricAuthEnabled = biometricAuthEnabled
        self.iCloudSyncEnabled = iCloudSyncEnabled
        self.autoBackupEnabled = autoBackupEnabled
        self.backupFrequencyDays = backupFrequencyDays
        self.showDecimalInCurrency = showDecimalInCurrency
        self.useThousandsSeparator = useThousandsSeparator
        self.defaultView = defaultView
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    func updateTimestamp() {
        updatedAt = Date()
    }
}

// MARK: - Enums

enum ThemeMode: String, Codable, CaseIterable {
    case light = "浅色"
    case dark = "深色"
    case system = "跟随系统"

    var systemName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}

enum AppLanguage: String, Codable, CaseIterable {
    case chinese = "简体中文"
    case english = "English"

    var code: String {
        switch self {
        case .chinese: return "zh-Hans"
        case .english: return "en"
        }
    }
}

enum DefaultView: String, Codable, CaseIterable {
    case home = "首页"
    case budget = "预算"
    case schedule = "进度"
    case materials = "材料"
    case profile = "我的"

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .budget: return "chart.pie.fill"
        case .schedule: return "calendar"
        case .materials: return "shippingbox.fill"
        case .profile: return "person.fill"
        }
    }
}
