//
//  PrivacySecurityView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData
import LocalAuthentication

struct PrivacySecurityView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsArray: [AppSettings]

    @State private var biometricType: LABiometryType = .none
    @State private var showingClearDataAlert = false

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
            // Biometric Authentication
            Section {
                HStack {
                    Label {
                        Text("生物识别")
                    } icon: {
                        Image(systemName: biometricIcon)
                            .foregroundColor(Colors.primary)
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { settings.biometricAuthEnabled },
                        set: { newValue in
                            if newValue {
                                authenticateUser { success in
                                    if success {
                                        settings.biometricAuthEnabled = true
                                        settings.updateTimestamp()
                                        try? modelContext.save()
                                    }
                                }
                            } else {
                                settings.biometricAuthEnabled = false
                                settings.updateTimestamp()
                                try? modelContext.save()
                            }
                        }
                    ))
                }
            } header: {
                Text("安全认证")
            } footer: {
                Text(biometricFooter)
            }

            // Cloud Sync
            Section {
                Toggle("iCloud 同步", isOn: Binding(
                    get: { settings.iCloudSyncEnabled },
                    set: { newValue in
                        settings.iCloudSyncEnabled = newValue
                        settings.updateTimestamp()
                        try? modelContext.save()
                    }
                ))
            } header: {
                Text("云同步")
            } footer: {
                Text("启用后数据将自动同步到 iCloud，可在多台设备间共享")
            }

            // Backup Settings
            Section {
                Toggle("自动备份", isOn: Binding(
                    get: { settings.autoBackupEnabled },
                    set: { newValue in
                        settings.autoBackupEnabled = newValue
                        settings.updateTimestamp()
                        try? modelContext.save()
                    }
                ))

                if settings.autoBackupEnabled {
                    Stepper("备份频率: \(settings.backupFrequencyDays) 天", value: Binding(
                        get: { settings.backupFrequencyDays },
                        set: { newValue in
                            settings.backupFrequencyDays = newValue
                            settings.updateTimestamp()
                            try? modelContext.save()
                        }
                    ), in: 1...30)
                }

                Button {
                    performBackup()
                } label: {
                    Label("立即备份", systemImage: "arrow.down.doc")
                }
            } header: {
                Text("数据备份")
            } footer: {
                if settings.autoBackupEnabled {
                    Text("每 \(settings.backupFrequencyDays) 天自动备份一次数据")
                } else {
                    Text("自动备份已关闭")
                }
            }

            // Data Management
            Section {
                Button(role: .destructive) {
                    showingClearDataAlert = true
                } label: {
                    Label("清除所有数据", systemImage: "trash")
                }
            } header: {
                Text("数据管理")
            } footer: {
                Text("此操作将删除所有项目数据，包括预算、进度、材料等信息，且不可恢复")
            }

            // Privacy Policy
            Section {
                Link(destination: URL(string: "https://example.com/privacy")!) {
                    HStack {
                        Text("隐私政策")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(Colors.textSecondary)
                    }
                }

                Link(destination: URL(string: "https://example.com/terms")!) {
                    HStack {
                        Text("使用条款")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(Colors.textSecondary)
                    }
                }
            } header: {
                Text("法律信息")
            }
        }
        .navigationTitle("隐私与安全")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkBiometricType()
        }
        .alert("清除所有数据", isPresented: $showingClearDataAlert) {
            Button("取消", role: .cancel) { }
            Button("清除", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("确定要清除所有数据吗？此操作不可撤销！")
        }
    }

    // MARK: - Helper Properties

    private var biometricIcon: String {
        switch biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "lock.fill"
        }
    }

    private var biometricFooter: String {
        switch biometricType {
        case .faceID:
            return "使用 Face ID 保护您的数据安全"
        case .touchID:
            return "使用 Touch ID 保护您的数据安全"
        default:
            return "此设备不支持生物识别功能"
        }
    }

    // MARK: - Helper Methods

    private func checkBiometricType() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
        }
    }

    private func authenticateUser(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "使用生物识别保护您的数据"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }

    private func performBackup() {
        // TODO: Implement actual backup functionality
        print("执行备份...")
    }

    private func clearAllData() {
        // Delete all projects (cascade delete will handle related data)
        do {
            let descriptor = FetchDescriptor<Project>()
            let projects = try modelContext.fetch(descriptor)

            for project in projects {
                modelContext.delete(project)
            }

            try modelContext.save()
            print("所有数据已清除")
        } catch {
            print("清除数据失败: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AppSettings.self, configurations: config)

    return NavigationStack {
        PrivacySecurityView()
            .modelContainer(container)
    }
}
