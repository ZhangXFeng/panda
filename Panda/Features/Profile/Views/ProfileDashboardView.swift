//
//  ProfileDashboardView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct ProfileDashboardView: View {
    @Environment(ProjectManager.self) private var projectManager
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]

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
                        Text("合同文档")
                    } label: {
                        Label("合同文档", systemImage: "doc.text")
                    }

                    NavigationLink {
                        Text("通讯录")
                    } label: {
                        Label("通讯录", systemImage: "person.crop.circle")
                    }

                    NavigationLink {
                        Text("装修日记")
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
                        ProjectListView()
                    } label: {
                        Label("切换项目", systemImage: "arrow.triangle.2.circlepath")
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
