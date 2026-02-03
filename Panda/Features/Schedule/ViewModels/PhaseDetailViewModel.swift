//
//  PhaseDetailViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class PhaseDetailViewModel: ObservableObject {
    // MARK: - Properties

    @Published var tasks: [Task] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: TaskStatus?

    private let phase: Phase
    private let modelContext: ModelContext

    // MARK: - Computed Properties

    var filteredTasks: [Task] {
        var result = tasks

        // Filter by status
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.taskDescription.localizedCaseInsensitiveContains(searchText) ||
                task.assignee.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted(by: Task.sortByStatus)
    }

    var pendingTasks: [Task] {
        tasks.filter { $0.status == .pending }
    }

    var inProgressTasks: [Task] {
        tasks.filter { $0.status == .inProgress }
    }

    var completedTasks: [Task] {
        tasks.filter { $0.status == .completed }
    }

    var issueTasks: [Task] {
        tasks.filter { $0.status == .issue }
    }

    var overdueTasks: [Task] {
        tasks.filter { $0.isOverdue }
    }

    var taskProgress: Double {
        guard !tasks.isEmpty else { return 0 }
        let completed = completedTasks.count
        return Double(completed) / Double(tasks.count)
    }

    // MARK: - Initialization

    init(phase: Phase, modelContext: ModelContext) {
        self.phase = phase
        self.modelContext = modelContext
        loadTasks()
    }

    // MARK: - Methods

    func loadTasks() {
        tasks = phase.tasks
    }

    func deleteTask(_ task: Task) {
        modelContext.delete(task)

        do {
            try modelContext.save()
            loadTasks()
        } catch {
            print("Failed to delete task: \(error)")
        }
    }

    func deleteTasks(at offsets: IndexSet, from tasks: [Task]) {
        for index in offsets {
            let task = tasks[index]
            deleteTask(task)
        }
    }

    func toggleTaskStatus(_ task: Task) {
        switch task.status {
        case .pending:
            task.start()
        case .inProgress:
            task.complete()
        case .completed:
            task.reset()
        case .issue, .cancelled:
            task.reset()
        }

        do {
            try modelContext.save()
            loadTasks()
        } catch {
            print("Failed to update task status: \(error)")
        }
    }

    func markPhaseAsCompleted() {
        phase.isCompleted = true
        phase.actualEndDate = Date()
        if phase.actualStartDate == nil {
            phase.actualStartDate = Date()
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to mark phase as completed: \(error)")
        }
    }

    func startPhase() {
        phase.actualStartDate = Date()

        do {
            try modelContext.save()
        } catch {
            print("Failed to start phase: \(error)")
        }
    }
}
