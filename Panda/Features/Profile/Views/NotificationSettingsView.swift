//
//  NotificationSettingsView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct NotificationSettingsView: View {
    @Environment(\.modelContext) private var modelContext
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
            // Master Switch
            Section {
                Toggle("启用通知", isOn: Binding(
                    get: { settings.notificationsEnabled },
                    set: { newValue in
                        settings.notificationsEnabled = newValue
                        settings.updateTimestamp()
                        try? modelContext.save()
                    }
                ))
            } footer: {
                Text("关闭后将不会收到任何通知提醒")
            }

            if settings.notificationsEnabled {
                // Budget Notifications
                Section {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Text("预算警告阈值")
                            Spacer()
                            Text("\(Int(settings.budgetWarningThreshold * 100))%")
                                .foregroundColor(Colors.textSecondary)
                        }

                        Slider(value: Binding(
                            get: { settings.budgetWarningThreshold },
                            set: { newValue in
                                settings.budgetWarningThreshold = newValue
                                settings.updateTimestamp()
                                try? modelContext.save()
                            }
                        ), in: 0.5...1.0, step: 0.05)
                    }
                } header: {
                    Text("预算提醒")
                } footer: {
                    Text("当支出达到总预算的 \(Int(settings.budgetWarningThreshold * 100))% 时提醒")
                }

                // Payment Notifications
                Section {
                    Stepper("付款提醒: \(settings.paymentReminderDays) 天前", value: Binding(
                        get: { settings.paymentReminderDays },
                        set: { newValue in
                            settings.paymentReminderDays = newValue
                            settings.updateTimestamp()
                            try? modelContext.save()
                        }
                    ), in: 1...30)
                } header: {
                    Text("付款提醒")
                } footer: {
                    Text("在付款到期日前 \(settings.paymentReminderDays) 天发送提醒")
                }

                // Task Notifications
                Section {
                    Toggle("任务到期提醒", isOn: Binding(
                        get: { settings.taskDueReminderEnabled },
                        set: { newValue in
                            settings.taskDueReminderEnabled = newValue
                            settings.updateTimestamp()
                            try? modelContext.save()
                        }
                    ))

                    if settings.taskDueReminderEnabled {
                        Stepper("提前提醒: \(settings.taskReminderDays) 天", value: Binding(
                            get: { settings.taskReminderDays },
                            set: { newValue in
                                settings.taskReminderDays = newValue
                                settings.updateTimestamp()
                                try? modelContext.save()
                            }
                        ), in: 0...7)
                    }
                } header: {
                    Text("任务提醒")
                } footer: {
                    if settings.taskDueReminderEnabled {
                        Text("在任务到期前 \(settings.taskReminderDays) 天发送提醒")
                    } else {
                        Text("任务到期提醒已关闭")
                    }
                }

                // Notification Examples
                Section {
                    NotificationExample(
                        icon: "exclamationmark.triangle.fill",
                        color: .orange,
                        title: "预算警告",
                        message: "预算使用已达到 \(Int(settings.budgetWarningThreshold * 100))%"
                    )

                    NotificationExample(
                        icon: "creditcard.fill",
                        color: .blue,
                        title: "付款提醒",
                        message: "中期款将于 \(settings.paymentReminderDays) 天后到期"
                    )

                    if settings.taskDueReminderEnabled {
                        NotificationExample(
                            icon: "calendar.badge.clock",
                            color: .green,
                            title: "任务提醒",
                            message: "水电改造将于 \(settings.taskReminderDays) 天后到期"
                        )
                    }
                } header: {
                    Text("通知预览")
                }
            }
        }
        .navigationTitle("通知提醒")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Views

private struct NotificationExample: View {
    let icon: String
    let color: Color
    let title: String
    let message: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 32)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Fonts.headline)
                    .foregroundColor(Colors.textPrimary)

                Text(message)
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AppSettings.self, configurations: config)
    let context = container.mainContext

    let settings = AppSettings()
    context.insert(settings)

    return NavigationStack {
        NotificationSettingsView()
            .modelContainer(container)
    }
}
