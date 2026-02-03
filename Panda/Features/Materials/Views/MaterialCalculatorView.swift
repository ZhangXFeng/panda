//
//  MaterialCalculatorView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI

struct MaterialCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCalculatorType: CalculatorType = .tile

    enum CalculatorType: String, CaseIterable, Identifiable {
        case tile = "瓷砖"
        case paint = "油漆"
        case flooring = "地板"
        case wallpaper = "壁纸"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .tile: return "square.grid.3x3.fill"
            case .paint: return "paintbrush.fill"
            case .flooring: return "rectangle.fill"
            case .wallpaper: return "rectangle.portrait.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calculator type picker
                Picker("计算器类型", selection: $selectedCalculatorType) {
                    ForEach(CalculatorType.allCases) { type in
                        Label(type.rawValue, systemImage: type.icon).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Calculator content
                ScrollView {
                    Group {
                        switch selectedCalculatorType {
                        case .tile:
                            TileCalculator()
                        case .paint:
                            PaintCalculator()
                        case .flooring:
                            FlooringCalculator()
                        case .wallpaper:
                            WallpaperCalculator()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("材料计算器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Tile Calculator

struct TileCalculator: View {
    @State private var length: String = ""
    @State private var width: String = ""
    @State private var tileLength: String = "800"
    @State private var tileWidth: String = "800"
    @State private var wasteRate: Double = 5.0

    var area: Double {
        (Double(length) ?? 0) * (Double(width) ?? 0)
    }

    var tileArea: Double {
        let l = (Double(tileLength) ?? 0) / 1000
        let w = (Double(tileWidth) ?? 0) / 1000
        return l * w
    }

    var tilesNeeded: Int {
        guard tileArea > 0 else { return 0 }
        let base = area / tileArea
        return Int(ceil(base * (1 + wasteRate / 100)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("瓷砖用量计算")
                .font(Fonts.titleMedium)

            CardView {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Text("房间尺寸")
                            .font(Fonts.headline)
                        Spacer()
                    }

                    HStack {
                        TextField("长度", text: $length)
                            .keyboardType(.decimalPad)
                        Text("米")
                        Text("×")
                        TextField("宽度", text: $width)
                            .keyboardType(.decimalPad)
                        Text("米")
                    }

                    HStack {
                        Text("房间面积")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(area, specifier: "%.2f") ㎡")
                            .font(Fonts.headline)
                    }
                }
                .padding(Spacing.md)
            }

            CardView {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Text("瓷砖规格")
                            .font(Fonts.headline)
                        Spacer()
                    }

                    HStack {
                        TextField("长", text: $tileLength)
                            .keyboardType(.numberPad)
                        Text("mm")
                        Text("×")
                        TextField("宽", text: $tileWidth)
                            .keyboardType(.numberPad)
                        Text("mm")
                    }

                    VStack(spacing: Spacing.sm) {
                        HStack {
                            Text("损耗率")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(wasteRate))%")
                        }

                        Slider(value: $wasteRate, in: 0...20, step: 1)
                    }
                }
                .padding(Spacing.md)
            }

            CardView {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Text("计算结果")
                            .font(Fonts.headline)
                            .foregroundColor(Colors.primary)
                        Spacer()
                    }

                    Divider()

                    HStack {
                        Text("需要瓷砖")
                        Spacer()
                        Text("\(tilesNeeded) 块")
                            .font(Fonts.titleMedium)
                            .foregroundColor(Colors.primary)
                    }

                    Text("提示：已包含 \(Int(wasteRate))% 损耗")
                        .font(Fonts.caption)
                        .foregroundColor(.secondary)
                }
                .padding(Spacing.md)
            }
        }
    }
}

// MARK: - Paint Calculator

struct PaintCalculator: View {
    @State private var wallArea: String = ""
    @State private var coats: Double = 2
    @State private var coverage: String = "10"

    var totalArea: Double {
        (Double(wallArea) ?? 0) * coats
    }

    var painBuckets: Int {
        let cov = Double(coverage) ?? 10
        guard cov > 0 else { return 0 }
        return Int(ceil(totalArea / cov))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("油漆用量计算")
                .font(Fonts.titleMedium)

            CardView {
                VStack(spacing: Spacing.md) {
                    TextField("墙面积（㎡）", text: $wallArea)
                        .keyboardType(.decimalPad)

                    VStack(spacing: Spacing.sm) {
                        HStack {
                            Text("涂刷遍数")
                            Spacer()
                            Text("\(Int(coats)) 遍")
                        }
                        Slider(value: $coats, in: 1...3, step: 1)
                    }

                    TextField("涂刷面积/桶（㎡）", text: $coverage)
                        .keyboardType(.decimalPad)
                }
                .padding(Spacing.md)
            }

            CardView {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Text("计算结果")
                            .font(Fonts.headline)
                            .foregroundColor(Colors.primary)
                        Spacer()
                    }

                    Divider()

                    HStack {
                        Text("需要油漆")
                        Spacer()
                        Text("\(painBuckets) 桶")
                            .font(Fonts.titleMedium)
                            .foregroundColor(Colors.primary)
                    }

                    Text("总涂刷面积: \(totalArea, specifier: "%.1f") ㎡")
                        .font(Fonts.caption)
                        .foregroundColor(.secondary)
                }
                .padding(Spacing.md)
            }
        }
    }
}

// MARK: - Flooring Calculator

struct FlooringCalculator: View {
    @State private var length: String = ""
    @State private var width: String = ""
    @State private var wasteRate: Double = 8.0

    var area: Double {
        (Double(length) ?? 0) * (Double(width) ?? 0)
    }

    var flooringNeeded: Double {
        area * (1 + wasteRate / 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("地板用量计算")
                .font(Fonts.titleMedium)

            CardView {
                VStack(spacing: Spacing.md) {
                    HStack {
                        TextField("长度", text: $length)
                            .keyboardType(.decimalPad)
                        Text("米")
                        Text("×")
                        TextField("宽度", text: $width)
                            .keyboardType(.decimalPad)
                        Text("米")
                    }

                    VStack(spacing: Spacing.sm) {
                        HStack {
                            Text("损耗率")
                            Spacer()
                            Text("\(Int(wasteRate))%")
                        }
                        Slider(value: $wasteRate, in: 3...15, step: 1)
                    }
                }
                .padding(Spacing.md)
            }

            CardView {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Text("计算结果")
                            .font(Fonts.headline)
                            .foregroundColor(Colors.primary)
                        Spacer()
                    }

                    Divider()

                    HStack {
                        Text("需要地板")
                        Spacer()
                        Text("\(flooringNeeded, specifier: "%.2f") ㎡")
                            .font(Fonts.titleMedium)
                            .foregroundColor(Colors.primary)
                    }

                    Text("实际面积: \(area, specifier: "%.2f") ㎡")
                        .font(Fonts.caption)
                        .foregroundColor(.secondary)
                }
                .padding(Spacing.md)
            }
        }
    }
}

// MARK: - Wallpaper Calculator

struct WallpaperCalculator: View {
    @State private var wallHeight: String = "2.8"
    @State private var perimeter: String = ""
    @State private var rollLength: String = "10"
    @State private var rollWidth: String = "0.53"

    var wallArea: Double {
        (Double(wallHeight) ?? 0) * (Double(perimeter) ?? 0)
    }

    var rollArea: Double {
        (Double(rollLength) ?? 0) * (Double(rollWidth) ?? 0)
    }

    var rollsNeeded: Int {
        guard rollArea > 0 else { return 0 }
        return Int(ceil(wallArea / rollArea * 1.1))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("壁纸用量计算")
                .font(Fonts.titleMedium)

            CardView {
                VStack(spacing: Spacing.md) {
                    TextField("墙高（米）", text: $wallHeight)
                        .keyboardType(.decimalPad)

                    TextField("墙周长（米）", text: $perimeter)
                        .keyboardType(.decimalPad)

                    TextField("壁纸卷长（米）", text: $rollLength)
                        .keyboardType(.decimalPad)

                    TextField("壁纸卷宽（米）", text: $rollWidth)
                        .keyboardType(.decimalPad)
                }
                .padding(Spacing.md)
            }

            CardView {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Text("计算结果")
                            .font(Fonts.headline)
                            .foregroundColor(Colors.primary)
                        Spacer()
                    }

                    Divider()

                    HStack {
                        Text("需要壁纸")
                        Spacer()
                        Text("\(rollsNeeded) 卷")
                            .font(Fonts.titleMedium)
                            .foregroundColor(Colors.primary)
                    }

                    Text("已包含10%损耗")
                        .font(Fonts.caption)
                        .foregroundColor(.secondary)
                }
                .padding(Spacing.md)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MaterialCalculatorView()
}
