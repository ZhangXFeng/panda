//
//  GeneralSettingsView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct GeneralSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var settingsArray: [AppSettings]

    private var settings: AppSettings {
        if let existing = settingsArray.first {
            return existing
        } else {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            return newSettings
        }
    }

    var body: some View {
        Form {
            // Appearance
            Section {
                Picker("主题模式", selection: Binding(
                    get: { settings.themeMode },
                    set: { newValue in
                        settings.themeMode = newValue
                        settings.updateTimestamp()
                        try? modelContext.save()
                    }
                )) {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        Label(mode.rawValue, systemImage: mode.systemName)
                            .tag(mode)
                    }
                }

                Picker("语言", selection: Binding(
                    get: { settings.language },
                    set: { newValue in
                        settings.language = newValue
                        settings.updateTimestamp()
                        try? modelContext.save()
                    }
                )) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.rawValue).tag(lang)
                    }
                }
            } header: {
                Text("外观")
            } footer: {
                Text("更改主题和语言设置")
            }

            // Currency & Display
            Section {
                HStack {
                    Text("货币符号")
                    Spacer()
                    TextField("符号", text: Binding(
                        get: { settings.currencySymbol },
                        set: { newValue in
                            settings.currencySymbol = newValue
                            settings.updateTimestamp()
                            try? modelContext.save()
                        }
                    ))
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                }

                Stepper("小数位数: \(settings.decimalPlaces)", value: Binding(
                    get: { settings.decimalPlaces },
                    set: { newValue in
                        settings.decimalPlaces = newValue
                        settings.updateTimestamp()
                        try? modelContext.save()
                    }
                ), in: 0...4)

                Toggle("显示小数", isOn: Binding(
                    get: { settings.showDecimalInCurrency },
                    set: { newValue in
                        settings.showDecimalInCurrency = newValue
                        settings.updateTimestamp()
                        try? modelContext.save()
                    }
                ))

                Toggle("千位分隔符", isOn: Binding(
                    get: { settings.useThousandsSeparator },
                    set: { newValue in
                        settings.useThousandsSeparator = newValue
                        settings.updateTimestamp()
                        try? modelContext.save()
                    }
                ))
            } header: {
                Text("货币显示")
            } footer: {
                Text("示例: \(formatCurrencyExample())")
            }

            // Default View
            Section {
                Picker("默认启动页", selection: Binding(
                    get: { settings.defaultView },
                    set: { newValue in
                        settings.defaultView = newValue
                        settings.updateTimestamp()
                        try? modelContext.save()
                    }
                )) {
                    ForEach(DefaultView.allCases, id: \.self) { view in
                        Label(view.rawValue, systemImage: view.iconName)
                            .tag(view)
                    }
                }
            } header: {
                Text("启动设置")
            } footer: {
                Text("选择打开应用时显示的页面")
            }
        }
        .navigationTitle("通用设置")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helper Methods

    private func formatCurrencyExample() -> String {
        let amount: Decimal = 12345.67

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = settings.currencySymbol
        formatter.maximumFractionDigits = settings.showDecimalInCurrency ? settings.decimalPlaces : 0
        formatter.usesGroupingSeparator = settings.useThousandsSeparator

        return formatter.string(from: amount as NSDecimalNumber) ?? "\(settings.currencySymbol)0"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GeneralSettingsView()
    }
    .modelContainer(for: [AppSettings.self], inMemory: true)
}
