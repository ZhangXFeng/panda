//
//  Spacing.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI

/// 标准间距定义
enum Spacing {
    /// 超小间距 - 4pt
    static let xs: CGFloat = 4

    /// 小间距 - 8pt
    static let sm: CGFloat = 8

    /// 中等间距 - 16pt
    static let md: CGFloat = 16

    /// 大间距 - 24pt
    static let lg: CGFloat = 24

    /// 超大间距 - 32pt
    static let xl: CGFloat = 32

    /// 超超大间距 - 48pt
    static let xxl: CGFloat = 48
}

/// 圆角半径定义
enum CornerRadius {
    /// 小圆角 - 4pt
    static let sm: CGFloat = 4

    /// 中圆角 - 8pt
    static let md: CGFloat = 8

    /// 大圆角 - 12pt
    static let lg: CGFloat = 12

    /// 超大圆角 - 16pt
    static let xl: CGFloat = 16

    /// 圆形
    static let circle: CGFloat = 9999
}

// MARK: - View Extensions

extension View {
    /// 应用标准内边距 (16pt)
    func standardPadding() -> some View {
        self.padding(Spacing.md)
    }

    /// 应用小内边距 (8pt)
    func smallPadding() -> some View {
        self.padding(Spacing.sm)
    }

    /// 应用大内边距 (24pt)
    func largePadding() -> some View {
        self.padding(Spacing.lg)
    }

    /// 应用标准卡片样式
    func cardStyle() -> some View {
        self
            .background(Color.bgCard)
            .cornerRadius(CornerRadius.lg)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    /// 应用圆角
    func cornerRadius(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

// MARK: - Preview

#Preview("Spacing") {
    ScrollView {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Spacing Examples
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Spacing").font(.titleMedium)

                HStack(spacing: Spacing.xs) {
                    ForEach(0..<4) { _ in
                        Rectangle()
                            .fill(Color.primaryWood)
                            .frame(width: 30, height: 30)
                    }
                }
                Text("XS: 4pt").font(.captionRegular).foregroundColor(.textSecondary)

                HStack(spacing: Spacing.sm) {
                    ForEach(0..<4) { _ in
                        Rectangle()
                            .fill(Color.primaryWood)
                            .frame(width: 30, height: 30)
                    }
                }
                Text("SM: 8pt").font(.captionRegular).foregroundColor(.textSecondary)

                HStack(spacing: Spacing.md) {
                    ForEach(0..<4) { _ in
                        Rectangle()
                            .fill(Color.primaryWood)
                            .frame(width: 30, height: 30)
                    }
                }
                Text("MD: 16pt").font(.captionRegular).foregroundColor(.textSecondary)

                HStack(spacing: Spacing.lg) {
                    ForEach(0..<4) { _ in
                        Rectangle()
                            .fill(Color.primaryWood)
                            .frame(width: 30, height: 30)
                    }
                }
                Text("LG: 24pt").font(.captionRegular).foregroundColor(.textSecondary)
            }

            Divider()

            // Corner Radius Examples
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Corner Radius").font(.titleMedium)

                HStack(spacing: Spacing.md) {
                    Rectangle()
                        .fill(Color.primaryWood)
                        .frame(width: 60, height: 60)
                        .cornerRadius(CornerRadius.sm)
                        .overlay(
                            Text("SM").foregroundColor(.white).font(.caption)
                        )

                    Rectangle()
                        .fill(Color.primaryWood)
                        .frame(width: 60, height: 60)
                        .cornerRadius(CornerRadius.md)
                        .overlay(
                            Text("MD").foregroundColor(.white).font(.caption)
                        )

                    Rectangle()
                        .fill(Color.primaryWood)
                        .frame(width: 60, height: 60)
                        .cornerRadius(CornerRadius.lg)
                        .overlay(
                            Text("LG").foregroundColor(.white).font(.caption)
                        )

                    Rectangle()
                        .fill(Color.primaryWood)
                        .frame(width: 60, height: 60)
                        .cornerRadius(CornerRadius.xl)
                        .overlay(
                            Text("XL").foregroundColor(.white).font(.caption)
                        )
                }

                Circle()
                    .fill(Color.primaryWood)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("Circle").foregroundColor(.white).font(.caption)
                    )
            }

            Divider()

            // Card Style Example
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Card Style").font(.titleMedium)

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Card Title").font(.titleSmall)
                    Text("This is a card with standard padding and corner radius.")
                        .font(.bodyRegular)
                        .foregroundColor(.textSecondary)
                }
                .standardPadding()
                .cardStyle()
            }
        }
        .padding()
    }
}
