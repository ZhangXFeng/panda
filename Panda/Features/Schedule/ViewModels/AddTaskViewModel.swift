//
//  AddTaskViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI

@MainActor
class AddTaskViewModel: ObservableObject {
    // MARK: - Properties

    @Published var title: String = ""
    @Published var taskDescription: String = ""
    @Published var status: TaskStatus = .pending
    @Published var assignee: String = ""
    @Published var assigneeContact: String = ""
    @Published var plannedStartDate: Date = Date()
    @Published var plannedEndDate: Date = Date().addingTimeInterval(86400 * 7) // 7 days later
    @Published var photoData: [Data] = []
    @Published var selectedPhotos: [PhotosPickerItem] = []

    @Published var showingError: Bool = false
    @Published var errorMessage: String = ""

    private let modelContext: ModelContext
    private var taskToEdit: Task?
    private var parentPhase: Phase?

    var isEditMode: Bool {
        taskToEdit != nil
    }

    var title_: String {
        isEditMode ? "编辑任务" : "添加任务"
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Initialization

    init(
        modelContext: ModelContext,
        task: Task? = nil,
        phase: Phase? = nil
    ) {
        self.modelContext = modelContext
        self.taskToEdit = task
        self.parentPhase = phase

        if let task = task {
            loadTask(task)
        }
    }

    // MARK: - Methods

    private func loadTask(_ task: Task) {
        title = task.title
        taskDescription = task.taskDescription
        status = task.status
        assignee = task.assignee
        assigneeContact = task.assigneeContact
        photoData = task.photoData

        if let startDate = task.plannedStartDate {
            plannedStartDate = startDate
        }
        if let endDate = task.plannedEndDate {
            plannedEndDate = endDate
        }
    }

    func save() -> Bool {
        guard canSave else {
            showError("请填写任务标题")
            return false
        }

        guard parentPhase != nil || taskToEdit != nil else {
            showError("无法确定任务所属阶段")
            return false
        }

        do {
            if let taskToEdit = taskToEdit {
                // Edit mode
                updateExistingTask(taskToEdit)
            } else {
                // Add mode
                createNewTask()
            }

            try modelContext.save()
            return true
        } catch {
            showError("保存失败: \(error.localizedDescription)")
            return false
        }
    }

    private func createNewTask() {
        guard let phase = parentPhase else { return }

        let task = Task(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            taskDescription: taskDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            status: status,
            assignee: assignee.trimmingCharacters(in: .whitespacesAndNewlines),
            assigneeContact: assigneeContact.trimmingCharacters(in: .whitespacesAndNewlines),
            plannedStartDate: plannedStartDate,
            plannedEndDate: plannedEndDate
        )

        task.photoData = photoData
        task.phase = phase
        modelContext.insert(task)
        phase.syncStatusFromTasks()
    }

    private func updateExistingTask(_ task: Task) {
        task.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        task.taskDescription = taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        task.status = status
        task.assignee = assignee.trimmingCharacters(in: .whitespacesAndNewlines)
        task.assigneeContact = assigneeContact.trimmingCharacters(in: .whitespacesAndNewlines)
        task.plannedStartDate = plannedStartDate
        task.plannedEndDate = plannedEndDate
        task.photoData = photoData
        task.updateTimestamp()
        task.phase?.syncStatusFromTasks()
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }

    // MARK: - Photo Management

    func addPhoto(_ data: Data) {
        photoData.append(data)
    }

    func removePhoto(at index: Int) {
        guard index >= 0 && index < photoData.count else { return }
        photoData.remove(at: index)
    }

    func loadSelectedPhotos() async {
        photoData.removeAll()

        for item in selectedPhotos {
            if let data = try? await item.loadTransferable(type: Data.self) {
                photoData.append(data)
            }
        }
    }

    // MARK: - Quick Actions

    func markAsCompleted() {
        status = .completed
    }

    func markAsInProgress() {
        status = .inProgress
    }

    func markAsIssue() {
        status = .issue
    }
}
