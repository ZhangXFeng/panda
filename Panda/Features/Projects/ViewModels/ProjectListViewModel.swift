//
//  ProjectListViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class ProjectListViewModel: ObservableObject {
    // MARK: - Properties

    @Published var projects: [Project] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: ProjectFilter = .all
    @Published var sortOrder: ProjectSortOrder = .updatedDate

    private let modelContext: ModelContext

    // MARK: - Computed Properties

    var filteredProjects: [Project] {
        var result = projects

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .active:
            result = result.filter { $0.isActive && $0.overallProgress < 1.0 }
        case .completed:
            result = result.filter { $0.overallProgress >= 1.0 }
        case .delayed:
            result = result.filter { $0.isDelayed }
        }

        // Apply search
        if !searchText.isEmpty {
            result = result.filter { project in
                project.name.localizedCaseInsensitiveContains(searchText) ||
                project.houseType.localizedCaseInsensitiveContains(searchText) ||
                project.notes.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply sort
        return sortProjects(result, by: sortOrder)
    }

    var activeProjects: [Project] {
        projects.filter { $0.isActive && $0.overallProgress < 1.0 }
    }

    var completedProjects: [Project] {
        projects.filter { $0.overallProgress >= 1.0 }
    }

    var delayedProjects: [Project] {
        projects.filter { $0.isDelayed }
    }

    var hasProjects: Bool {
        !projects.isEmpty
    }

    // MARK: - Statistics

    var totalProjects: Int {
        projects.count
    }

    var totalActiveProjects: Int {
        activeProjects.count
    }

    var totalCompletedProjects: Int {
        completedProjects.count
    }

    var totalDelayedProjects: Int {
        delayedProjects.count
    }

    var averageProgress: Double {
        guard !projects.isEmpty else { return 0 }
        let total = projects.reduce(0.0) { $0 + $1.overallProgress }
        return total / Double(projects.count)
    }

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadProjects()
    }

    // MARK: - Methods

    func loadProjects() {
        let descriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\Project.updatedAt, order: .reverse)]
        )

        do {
            projects = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch projects: \(error)")
            projects = []
        }
    }

    func deleteProject(_ project: Project) {
        modelContext.delete(project)

        do {
            try modelContext.save()
            loadProjects()
        } catch {
            print("Failed to delete project: \(error)")
        }
    }

    func deleteProjects(at offsets: IndexSet) {
        let projectsToDelete = offsets.map { filteredProjects[$0] }

        for project in projectsToDelete {
            modelContext.delete(project)
        }

        do {
            try modelContext.save()
            loadProjects()
        } catch {
            print("Failed to delete projects: \(error)")
        }
    }

    func toggleProjectActive(_ project: Project) {
        project.isActive = !project.isActive
        project.updateTimestamp()

        do {
            try modelContext.save()
            loadProjects()
        } catch {
            print("Failed to toggle project active status: \(error)")
        }
    }

    func duplicateProject(_ project: Project) {
        let newProject = Project(
            name: "\(project.name) - 副本",
            houseType: project.houseType,
            area: project.area,
            startDate: Date(),
            estimatedDuration: project.estimatedDuration,
            notes: project.notes,
            isActive: true
        )

        if let coverImageData = project.coverImageData {
            newProject.coverImageData = coverImageData
        }

        modelContext.insert(newProject)

        do {
            try modelContext.save()
            loadProjects()
        } catch {
            print("Failed to duplicate project: \(error)")
        }
    }

    // MARK: - Sorting

    private func sortProjects(_ projects: [Project], by order: ProjectSortOrder) -> [Project] {
        switch order {
        case .name:
            return projects.sorted { $0.name < $1.name }
        case .startDate:
            return projects.sorted { $0.startDate > $1.startDate }
        case .updatedDate:
            return projects.sorted { $0.updatedAt > $1.updatedAt }
        case .progress:
            return projects.sorted { $0.overallProgress > $1.overallProgress }
        case .area:
            return projects.sorted { $0.area > $1.area }
        }
    }
}

// MARK: - ProjectFilter

enum ProjectFilter: String, CaseIterable, Identifiable {
    case all = "全部"
    case active = "进行中"
    case completed = "已完工"
    case delayed = "延期"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .active: return "hammer.fill"
        case .completed: return "checkmark.circle.fill"
        case .delayed: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - ProjectSortOrder

enum ProjectSortOrder: String, CaseIterable, Identifiable {
    case updatedDate = "最近更新"
    case startDate = "开工时间"
    case name = "项目名称"
    case progress = "完成进度"
    case area = "建筑面积"

    var id: String { rawValue }
}
