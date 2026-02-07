//
//  Colors.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors

    /// 主色调 - 温暖木色
    static let primaryWood = Color(light: "#D4A574", dark: "#E0B88A")

    /// 主色调 - 深色
    static let primaryDark = Color(light: "#A67C52", dark: "#C49A6C")

    // MARK: - Status Colors

    /// 成功色 - 绿色
    static let success = Color(light: "#4CAF50", dark: "#66BB6A")

    /// 警告色 - 橙色
    static let warning = Color(light: "#FF9800", dark: "#FFA726")

    /// 错误色 - 红色
    static let error = Color(light: "#F44336", dark: "#EF5350")

    /// 信息色 - 蓝色
    static let info = Color(light: "#2196F3", dark: "#42A5F5")

    // MARK: - Neutral Colors

    /// 主要文字颜色
    static let textPrimary = Color(light: "#212121", dark: "#F5F5F5")

    /// 次要文字颜色
    static let textSecondary = Color(light: "#757575", dark: "#B0B0B0")

    /// 提示文字颜色
    static let textHint = Color(light: "#9E9E9E", dark: "#808080")

    /// 分割线颜色
    static let divider = Color(light: "#E0E0E0", dark: "#3A3A3A")

    // MARK: - Background Colors

    /// 主背景色
    static let bgPrimary = Color(light: "#FFFFFF", dark: "#1C1C1E")

    /// 次背景色
    static let bgSecondary = Color(light: "#F5F5F5", dark: "#2C2C2E")

    /// 卡片背景色
    static let bgCard = Color(light: "#FAFAFA", dark: "#2C2C2E")

    // MARK: - Helper

    /// 从十六进制字符串创建颜色
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }

    /// 创建支持 light/dark 模式的动态颜色
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
    }
}

// MARK: - Colors Enum (for consistency with Spacing/CornerRadius)

enum Colors {
    /// 主色调
    static let primary = Color.primaryWood

    /// 主色调 - 深色
    static let primaryDark = Color.primaryDark

    /// 成功色
    static let success = Color.success

    /// 警告色
    static let warning = Color.warning

    /// 错误色
    static let error = Color.error

    /// 信息色
    static let info = Color.info

    /// 主要文字颜色
    static let textPrimary = Color.textPrimary

    /// 次要文字颜色
    static let textSecondary = Color.textSecondary

    /// 提示文字颜色
    static let textHint = Color.textHint

    /// 分割线颜色
    static let divider = Color.divider

    /// 主背景色
    static let backgroundPrimary = Color.bgPrimary

    /// 次背景色
    static let backgroundSecondary = Color.bgSecondary

    /// 卡片背景色
    static let backgroundCard = Color.bgCard
}

// MARK: - Preview

#Preview("Colors") {
    ScrollView {
        VStack(spacing: 16) {
            ColorRow(name: "Primary Wood", color: .primaryWood)
            ColorRow(name: "Primary Dark", color: .primaryDark)

            Divider()

            ColorRow(name: "Success", color: .success)
            ColorRow(name: "Warning", color: .warning)
            ColorRow(name: "Error", color: .error)
            ColorRow(name: "Info", color: .info)

            Divider()

            ColorRow(name: "Text Primary", color: .textPrimary)
            ColorRow(name: "Text Secondary", color: .textSecondary)
            ColorRow(name: "Text Hint", color: .textHint)
            ColorRow(name: "Divider", color: .divider)

            Divider()

            ColorRow(name: "BG Primary", color: .bgPrimary)
            ColorRow(name: "BG Secondary", color: .bgSecondary)
            ColorRow(name: "BG Card", color: .bgCard)
        }
        .padding()
    }
}

private struct ColorRow: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.divider, lineWidth: 1)
                )

            Text(name)
                .font(.body)
                .foregroundColor(.textPrimary)

            Spacer()
        }
    }
}
