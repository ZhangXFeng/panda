//
//  PandaApp.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

@main
struct PandaApp: App {
    // MARK: - Properties

    /// SwiftData 模型容器
    let modelContainer: ModelContainer

    // MARK: - Initialization

    init() {
        do {
            // 配置 SwiftData 模型容器
            let schema = Schema([
                Project.self,
                Budget.self,
                Expense.self,
                Phase.self,
                Task.self,
                Material.self,
                Contact.self,
                JournalEntry.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            print("✅ SwiftData 模型容器初始化成功")
        } catch {
            fatalError("❌ 无法初始化 SwiftData 模型容器: \(error)")
        }
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(modelContainer)
        }
    }
}
