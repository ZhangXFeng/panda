//
//  ProfileDashboardView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct ProfileDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @State private var showingTestDataAlert = false
    @State private var testDataMessage = ""

    var body: some View {
        NavigationStack {
            List {
                // 项目信息
                if let project = projects.first {
                    Section {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "house.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.primaryWood)

                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text(project.name)
                                    .font(.titleSmall)
                                Text("\(project.houseType) · \(Int(project.area))㎡")
                                    .font(.bodyRegular)
                                    .foregroundColor(.textSecondary)
                                Text("装修进度 \(Int(project.overallProgress * 100))%")
                                    .font(.captionRegular)
                                    .foregroundColor(.primaryWood)
                            }

                            Spacer()
                        }
                        .padding(.vertical, Spacing.sm)
                    }
                }

                // 常用功能
                Section("常用功能") {
                    NavigationLink {
                        Text("合同文档")
                    } label: {
                        Label("合同文档", systemImage: "doc.text")
                    }

                    NavigationLink {
                        ContactListView()
                    } label: {
                        Label("通讯录", systemImage: "person.crop.circle")
                    }

                    NavigationLink {
                        JournalListView()
                    } label: {
                        Label("装修日记", systemImage: "photo")
                    }

                    NavigationLink {
                        Text("数据导出")
                    } label: {
                        Label("数据导出", systemImage: "square.and.arrow.up")
                    }
                }

                // 项目管理
                Section("项目管理") {
                    NavigationLink {
                        Text("项目设置")
                    } label: {
                        Label("项目设置", systemImage: "gearshape")
                    }

                    NavigationLink {
                        Text("切换项目")
                    } label: {
                        Label("切换项目", systemImage: "arrow.triangle.2.circlepath")
                    }
                }

                // 开发工具
                Section("开发工具") {
                    Button {
                        generateTestData()
                    } label: {
                        Label("生成测试数据", systemImage: "wand.and.stars")
                            .foregroundColor(.primaryWood)
                    }

                    Button(role: .destructive) {
                        clearAllData()
                    } label: {
                        Label("清除所有数据", systemImage: "trash")
                    }
                }

                // 应用设置
                Section("应用设置") {
                    NavigationLink {
                        Text("通用设置")
                    } label: {
                        Label("通用设置", systemImage: "slider.horizontal.3")
                    }

                    NavigationLink {
                        Text("通知提醒")
                    } label: {
                        Label("通知提醒", systemImage: "bell")
                    }

                    NavigationLink {
                        Text("隐私与安全")
                    } label: {
                        Label("隐私与安全", systemImage: "lock")
                    }

                    NavigationLink {
                        Text("帮助与反馈")
                    } label: {
                        Label("帮助与反馈", systemImage: "questionmark.circle")
                    }

                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("关于 Panda", systemImage: "info.circle")
                    }
                }

                // 版本信息
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: Spacing.xs) {
                            Text("Panda 装修管家")
                                .font(.captionMedium)
                                .foregroundColor(.textSecondary)
                            Text("v1.0.0")
                                .font(.captionRegular)
                                .foregroundColor(.textHint)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
            .alert("提示", isPresented: $showingTestDataAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(testDataMessage)
            }
        }
    }

    // MARK: - Methods

    private func generateTestData() {
        _Concurrency.Task {
            do {
                let generator = TestDataGenerator(modelContext: modelContext)
                try generator.generateTestData()
                testDataMessage = "✅ 测试数据生成成功！\n\n包含：\n• 1个装修项目\n• 预算及10条支出记录\n• 10个装修阶段\n• 12种材料\n• 9位联系人\n• 6篇装修日记"
                showingTestDataAlert = true
            } catch {
                testDataMessage = "❌ 生成失败：\(error.localizedDescription)"
                showingTestDataAlert = true
            }
        }
    }

    private func clearAllData() {
        _Concurrency.Task {
            do {
                // 删除所有项目（会级联删除所有关联数据）
                for project in projects {
                    modelContext.delete(project)
                }
                try modelContext.save()
                testDataMessage = "✅ 所有数据已清除"
                showingTestDataAlert = true
            } catch {
                testDataMessage = "❌ 清除失败：\(error.localizedDescription)"
                showingTestDataAlert = true
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: Spacing.lg) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.primaryWood)

                    Text("Panda 装修管家")
                        .font(.titleLarge)

                    Text("让装修不再焦虑\n每一分钱都花得明白")
                        .font(.bodyRegular)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
            }

            Section("版本信息") {
                HStack {
                    Text("版本号")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.textSecondary)
                }

                HStack {
                    Text("构建号")
                    Spacer()
                    Text("2026.02.02")
                        .foregroundColor(.textSecondary)
                }
            }

            Section("技术栈") {
                HStack {
                    Text("开发语言")
                    Spacer()
                    Text("Swift 5.9+")
                        .foregroundColor(.textSecondary)
                }

                HStack {
                    Text("UI 框架")
                    Spacer()
                    Text("SwiftUI")
                        .foregroundColor(.textSecondary)
                }

                HStack {
                    Text("数据存储")
                    Spacer()
                    Text("SwiftData")
                        .foregroundColor(.textSecondary)
                }

                HStack {
                    Text("最低版本")
                    Spacer()
                    Text("iOS 17.0+")
                        .foregroundColor(.textSecondary)
                }
            }

            Section("开源协议") {
                Text("本项目仅供学习和参考使用")
                    .font(.captionRegular)
                    .foregroundColor(.textSecondary)
            }
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileDashboardView()
        .modelContainer(for: [Project.self], inMemory: true)
}
