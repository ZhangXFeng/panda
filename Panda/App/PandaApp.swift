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

    /// 项目管理器 - 管理当前选中的项目
    @State private var projectManager = ProjectManager()

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
                isStoredInMemoryOnly: false
            )

            do {
                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
            } catch {
                // 开发期兜底：使用内存数据库避免启动崩溃
                let inMemoryConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [inMemoryConfig]
                )
            }

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
                .environment(projectManager)
        }
    }

}
