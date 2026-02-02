//
//  CardView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI

/// 卡片视图组件
struct CardView<Content: View>: View {
    // MARK: - Properties

    let content: () -> Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat

    // MARK: - Initialization

    init(
        padding: CGFloat = Spacing.md,
        cornerRadius: CGFloat = CornerRadius.lg,
        shadowRadius: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }

    // MARK: - Body

    var body: some View {
        content()
            .padding(padding)
            .background(Color.bgCard)
            .cornerRadius(cornerRadius)
            .shadow(
                color: .black.opacity(0.05),
                radius: shadowRadius,
                x: 0,
                y: 2
            )
    }
}

// MARK: - Preview

#Preview("Card View") {
    ScrollView {
        VStack(spacing: Spacing.md) {
            CardView {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("标准卡片")
                        .font(.titleSmall)

                    Text("这是一个标准的卡片组件，带有默认的内边距、圆角和阴影。")
                        .font(.bodyRegular)
                        .foregroundColor(.textSecondary)
                }
            }

            CardView(padding: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("大内边距卡片")
                        .font(.titleSmall)

                    Text("这个卡片使用更大的内边距。")
                        .font(.bodyRegular)
                        .foregroundColor(.textSecondary)
                }
            }

            CardView(cornerRadius: CornerRadius.xl, shadowRadius: 8) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("自定义圆角和阴影")
                        .font(.titleSmall)

                    Text("这个卡片有更大的圆角半径和阴影。")
                        .font(.bodyRegular)
                        .foregroundColor(.textSecondary)
                }
            }

            // 预算卡片示例
            CardView {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Text("预算概览")
                            .font(.titleSmall)

                        Spacer()

                        Text("查看详情")
                            .font(.captionMedium)
                            .foregroundColor(.primaryWood)
                    }

                    Divider()

                    HStack {
                        VStack(alignment: .leading) {
                            Text("总预算")
                                .font(.captionRegular)
                                .foregroundColor(.textSecondary)

                            Text("¥180,000")
                                .font(.numberMedium)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("已支出")
                                .font(.captionRegular)
                                .foregroundColor(.textSecondary)

                            Text("¥92,500")
                                .font(.numberMedium)
                                .foregroundColor(.warning)
                        }
                    }

                    ProgressBar(progress: 0.51)
                }
            }
        }
        .padding()
    }
}
