//
//  Fonts.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI

extension Font {
    // MARK: - Title Fonts

    /// 大标题 - 28pt, Bold
    static let titleLarge = Font.system(size: 28, weight: .bold, design: .default)

    /// 中标题 - 22pt, Semibold
    static let titleMedium = Font.system(size: 22, weight: .semibold, design: .default)

    /// 小标题 - 18pt, Semibold
    static let titleSmall = Font.system(size: 18, weight: .semibold, design: .default)

    // MARK: - Body Fonts

    /// 正文 - 16pt, Regular
    static let bodyRegular = Font.system(size: 16, weight: .regular, design: .default)

    /// 正文加粗 - 16pt, Medium
    static let bodyMedium = Font.system(size: 16, weight: .medium, design: .default)

    // MARK: - Caption Fonts

    /// 说明文字 - 14pt, Regular
    static let captionRegular = Font.system(size: 14, weight: .regular, design: .default)

    /// 说明文字加粗 - 14pt, Medium
    static let captionMedium = Font.system(size: 14, weight: .medium, design: .default)

    /// 小文字 - 12pt, Regular
    static let smallRegular = Font.system(size: 12, weight: .regular, design: .default)

    /// 小文字加粗 - 12pt, Medium
    static let smallMedium = Font.system(size: 12, weight: .medium, design: .default)

    // MARK: - Number Fonts (Rounded Design)

    /// 大数字 - 32pt, Bold, Rounded
    static let numberLarge = Font.system(size: 32, weight: .bold, design: .rounded)

    /// 中数字 - 24pt, Semibold, Rounded
    static let numberMedium = Font.system(size: 24, weight: .semibold, design: .rounded)

    /// 小数字 - 18pt, Medium, Rounded
    static let numberSmall = Font.system(size: 18, weight: .medium, design: .rounded)
}

// MARK: - Text Modifiers

extension Text {
    /// 应用主标题样式
    func titleStyle() -> some View {
        self
            .font(.titleLarge)
            .foregroundColor(.textPrimary)
    }

    /// 应用次标题样式
    func subtitleStyle() -> some View {
        self
            .font(.titleMedium)
            .foregroundColor(.textPrimary)
    }

    /// 应用正文样式
    func bodyStyle() -> some View {
        self
            .font(.bodyRegular)
            .foregroundColor(.textPrimary)
    }

    /// 应用次要文字样式
    func secondaryStyle() -> some View {
        self
            .font(.captionRegular)
            .foregroundColor(.textSecondary)
    }

    /// 应用提示文字样式
    func hintStyle() -> some View {
        self
            .font(.smallRegular)
            .foregroundColor(.textHint)
    }

    /// 应用数字样式
    func numberStyle(size: NumberSize = .medium) -> some View {
        self
            .font(size.font)
            .foregroundColor(.textPrimary)
    }
}

enum NumberSize {
    case large, medium, small

    var font: Font {
        switch self {
        case .large: return .numberLarge
        case .medium: return .numberMedium
        case .small: return .numberSmall
        }
    }
}

// MARK: - Preview

#Preview("Fonts") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Titles").font(.caption).foregroundColor(.textSecondary)
                Text("Large Title").font(.titleLarge)
                Text("Medium Title").font(.titleMedium)
                Text("Small Title").font(.titleSmall)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Body").font(.caption).foregroundColor(.textSecondary)
                Text("Body Regular").font(.bodyRegular)
                Text("Body Medium").font(.bodyMedium)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Captions").font(.caption).foregroundColor(.textSecondary)
                Text("Caption Regular").font(.captionRegular)
                Text("Caption Medium").font(.captionMedium)
                Text("Small Regular").font(.smallRegular)
                Text("Small Medium").font(.smallMedium)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Numbers").font(.caption).foregroundColor(.textSecondary)
                Text("¥180,000").font(.numberLarge)
                Text("¥92,500").font(.numberMedium)
                Text("¥5,200").font(.numberSmall)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Styled Text").font(.caption).foregroundColor(.textSecondary)
                Text("Title Style").titleStyle()
                Text("Body Style").bodyStyle()
                Text("Secondary Style").secondaryStyle()
                Text("Hint Style").hintStyle()
            }
        }
        .padding()
    }
}
