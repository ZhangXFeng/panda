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

// MARK: - Tab Views

/// 首页视图
struct HomeView: View {
    var body: some View {
        HomeDashboardView()
    }
}

/// 预算视图
struct BudgetView: View {
    var body: some View {
        BudgetDashboardView()
    }
}

/// 进度视图
struct ScheduleView: View {
    var body: some View {
        ScheduleOverviewView()
    }
}

/// 材料视图
struct MaterialsView: View {
    var body: some View {
        MaterialListView()
    }
}

/// 我的视图
struct ProfileView: View {
    var body: some View {
        ProfileDashboardView()
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
