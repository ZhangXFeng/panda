//
//  MainTabView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI

struct MainTabView: View {
    // MARK: - State

    @State private var selectedTab: Tab = .home

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(Tab.home)

            // 预算
            BudgetView()
                .tabItem {
                    Label("预算", systemImage: "dollarsign.circle.fill")
                }
                .tag(Tab.budget)

            // 进度
            ScheduleView()
                .tabItem {
                    Label("进度", systemImage: "calendar")
                }
                .tag(Tab.schedule)

            // 材料
            MaterialsView()
                .tabItem {
                    Label("材料", systemImage: "cube.box.fill")
                }
                .tag(Tab.materials)

            // 我的
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
        .tint(.primaryWood)
    }
}

// MARK: - Tab Enum

extension MainTabView {
    enum Tab {
        case home
        case budget
        case schedule
        case materials
        case profile
    }
}

// MARK: - Placeholder Views

/// 首页占位视图
struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("首页")
                    .font(.titleLarge)
                    .padding()
            }
            .navigationTitle("我的家")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// 预算占位视图
struct BudgetView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("预算管理")
                    .font(.titleLarge)
                    .padding()
            }
            .navigationTitle("预算管理")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// 进度占位视图
struct ScheduleView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("装修进度")
                    .font(.titleLarge)
                    .padding()
            }
            .navigationTitle("装修进度")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// 材料占位视图
struct MaterialsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("材料管理")
                    .font(.titleLarge)
                    .padding()
            }
            .navigationTitle("材料管理")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// 我的占位视图
struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("我的")
                    .font(.titleLarge)
                    .padding()
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .modelContainer(for: [
            Project.self,
            Budget.self,
            Expense.self,
            Phase.self,
            Task.self,
            Material.self,
            Contact.self,
            JournalEntry.self
        ], inMemory: true)
}
