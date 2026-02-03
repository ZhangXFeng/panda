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
    @Environment(ProjectManager.self) private var projectManager
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]

    @State private var showingGenerateDataAlert = false
    @State private var showingDataGeneratedAlert = false

    /// 当前选中的项目
    private var currentProject: Project? {
        projectManager.currentProject(from: projects)
    }

    var body: some View {
        NavigationStack {
            List {
                // 项目信息
                if let project = currentProject {
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
                        DocumentListView(modelContext: modelContext)
                    } label: {
                        Label("合同文档", systemImage: "doc.text")
                    }

                    NavigationLink {
                        ContactListView(modelContext: modelContext)
                    } label: {
                        Label("通讯录", systemImage: "person.crop.circle")
                    }

                    NavigationLink {
                        JournalListView(modelContext: modelContext)
                    } label: {
                        Label("装修日记", systemImage: "photo")
                    }

                    NavigationLink {
                        DataExportView()
                    } label: {
                        Label("数据导出", systemImage: "square.and.arrow.up")
                    }
                }

                // 项目管理
                Section("项目管理") {
                    NavigationLink {
                        ProjectSettingsView()
                    } label: {
                        Label("项目设置", systemImage: "gearshape")
                    }

                    NavigationLink {
                        ProjectListView(modelContext: modelContext)
                    } label: {
                        Label("切换项目", systemImage: "arrow.triangle.2.circlepath")
                    }
                }

                // 应用设置
                Section("应用设置") {
                    NavigationLink {
                        GeneralSettingsView()
                    } label: {
                        Label("通用设置", systemImage: "slider.horizontal.3")
                    }

                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("通知提醒", systemImage: "bell")
                    }

                    NavigationLink {
                        PrivacySecurityView()
                    } label: {
                        Label("隐私与安全", systemImage: "lock")
                    }

                    NavigationLink {
                        HelpFeedbackView()
                    } label: {
                        Label("帮助与反馈", systemImage: "questionmark.circle")
                    }

                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("关于 Panda", systemImage: "info.circle")
                    }
                }

                // 开发者选项
                #if DEBUG
                Section("开发者选项") {
                    Button {
                        showingGenerateDataAlert = true
                    } label: {
                        Label("生成测试数据", systemImage: "wand.and.stars")
                    }

                    Button(role: .destructive) {
                        SampleDataGenerator.clearAllData(in: modelContext)
                        projectManager.clearSelection()
                    } label: {
                        Label("清除所有数据", systemImage: "trash")
                    }
                }
                #endif

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
            .alert("生成测试数据", isPresented: $showingGenerateDataAlert) {
                Button("取消", role: .cancel) {}
                Button("生成") {
                    SampleDataGenerator.generateAllSampleData(in: modelContext)
                    projectManager.clearSelection()
                    projectManager.autoSelectIfNeeded(from: projects)
                    showingDataGeneratedAlert = true
                }
            } message: {
                Text("这将清除现有数据并创建 4 个测试项目，确定继续吗？")
            }
            .alert("测试数据已生成", isPresented: $showingDataGeneratedAlert) {
                Button("好的") {}
            } message: {
                Text("已创建 4 个测试项目：\n• 我的家（进行中）\n• 爸妈的房子（刚开始）\n• 出租公寓（即将完工）\n• 新婚小窝（已完工）")
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
        .environment(ProjectManager())
        .modelContainer(for: [Project.self], inMemory: true)
}
