//
//  ProgressBar.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI

/// 进度条组件
struct ProgressBar: View {
    // MARK: - Properties

    let progress: Double
    let height: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color

    // MARK: - Initialization

    init(
        progress: Double,
        height: CGFloat = 8,
        backgroundColor: Color = .divider,
        foregroundColor: Color = .primaryWood
    ) {
        self.progress = max(0, min(1, progress))
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)

                // Foreground
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Convenience Initializers

extension ProgressBar {
    /// 根据百分比自动选择颜色
    init(progress: Double, height: CGFloat = 8) {
        let color: Color
        if progress < 0.7 {
            color = .success
        } else if progress < 0.9 {
            color = .warning
        } else {
            color = .error
        }

        self.init(
            progress: progress,
            height: height,
            backgroundColor: .divider,
            foregroundColor: color
        )
    }
}

// MARK: - Preview

#Preview("Progress Bar") {
    VStack(spacing: Spacing.lg) {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("30% - 正常").font(.captionRegular)
            ProgressBar(progress: 0.3)
        }

        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("75% - 注意").font(.captionRegular)
            ProgressBar(progress: 0.75)
        }

        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("95% - 预警").font(.captionRegular)
            ProgressBar(progress: 0.95)
        }

        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("自定义颜色").font(.captionRegular)
            ProgressBar(
                progress: 0.6,
                height: 12,
                backgroundColor: .bgSecondary,
                foregroundColor: .info
            )
        }
    }
    .padding()
}
