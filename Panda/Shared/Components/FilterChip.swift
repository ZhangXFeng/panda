//
//  FilterChip.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI

/// 筛选器芯片组件
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.captionMedium)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.primaryWood : Color.bgCard)
                .cornerRadius(CornerRadius.lg)
        }
    }
}

#Preview {
    HStack {
        FilterChip(title: "全部", isSelected: true) {}
        FilterChip(title: "进行中", isSelected: false) {}
        FilterChip(title: "已完成", isSelected: false) {}
    }
}
