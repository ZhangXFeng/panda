//
//  ProgressRing.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI

/// 圆环进度组件
struct ProgressRing: View {
    // MARK: - Properties

    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let showPercentage: Bool

    @State private var animatedProgress: Double = 0

    // MARK: - Initialization

    init(
        progress: Double,
        lineWidth: CGFloat = 10,
        size: CGFloat = 120,
        backgroundColor: Color = .divider,
        foregroundColor: Color = .primaryWood,
        showPercentage: Bool = true
    ) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.showPercentage = showPercentage
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress Arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: animatedProgress)

            // Percentage Text
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.numberMedium)
                    .foregroundColor(.textPrimary)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { oldValue, newValue in
            animatedProgress = newValue
        }
    }
}

// MARK: - Convenience Initializers

extension ProgressRing {
    /// 根据百分比自动选择颜色
    init(
        progress: Double,
        lineWidth: CGFloat = 10,
        size: CGFloat = 120,
        showPercentage: Bool = true
    ) {
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
            lineWidth: lineWidth,
            size: size,
            backgroundColor: .divider,
            foregroundColor: color,
            showPercentage: showPercentage
        )
    }
}

// MARK: - Preview

#Preview("Progress Ring") {
    ScrollView {
        VStack(spacing: Spacing.xl) {
            VStack {
                Text("30% - 正常").font(.captionRegular)
                ProgressRing(progress: 0.3)
            }

            VStack {
                Text("75% - 注意").font(.captionRegular)
                ProgressRing(progress: 0.75)
            }

            VStack {
                Text("95% - 预警").font(.captionRegular)
                ProgressRing(progress: 0.95)
            }

            VStack {
                Text("自定义样式").font(.captionRegular)
                ProgressRing(
                    progress: 0.6,
                    lineWidth: 15,
                    size: 150,
                    backgroundColor: .bgSecondary,
                    foregroundColor: .info
                )
            }

            VStack {
                Text("无百分比文字").font(.captionRegular)
                ProgressRing(
                    progress: 0.45,
                    showPercentage: false
                )
            }
        }
        .padding()
    }
}
