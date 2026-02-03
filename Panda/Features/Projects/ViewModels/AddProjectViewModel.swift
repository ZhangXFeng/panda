//
//  AddProjectViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI

@MainActor
class AddProjectViewModel: ObservableObject {
    // MARK: - Properties

    @Published var name: String = ""
    @Published var houseType: String = "三室两厅"
    @Published var area: Double = 100.0
    @Published var startDate: Date = Date()
    @Published var estimatedDuration: Int = 90
    @Published var notes: String = ""
    @Published var coverImageData: Data?
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var isActive: Bool = true

    @Published var showingError: Bool = false
    @Published var errorMessage: String = ""

    private let modelContext: ModelContext
    private var projectToEdit: Project?

    var isEditMode: Bool {
        projectToEdit != nil
    }

    var title: String {
        isEditMode ? "编辑项目" : "新建项目"
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        area > 0 &&
        estimatedDuration > 0
    }

    var estimatedEndDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: estimatedDuration,
            to: startDate
        ) ?? startDate
    }

    // MARK: - Constants

    static let houseTypes = [
        "一室一厅",
        "两室一厅",
        "两室两厅",
        "三室一厅",
        "三室两厅",
        "四室两厅",
        "复式",
        "别墅",
        "其他"
    ]

    // MARK: - Initialization

    init(modelContext: ModelContext, project: Project? = nil) {
        self.modelContext = modelContext
        self.projectToEdit = project

        if let project = project {
            loadProject(project)
        }
    }

    // MARK: - Methods

    private func loadProject(_ project: Project) {
        name = project.name
        houseType = project.houseType
        area = project.area
        startDate = project.startDate
        estimatedDuration = project.estimatedDuration
        notes = project.notes
        coverImageData = project.coverImageData
        isActive = project.isActive
    }

    func save() -> Bool {
        guard canSave else {
            showError("请填写完整信息")
            return false
        }

        guard area > 0 && area <= 10000 else {
            showError("建筑面积应在 0-10000 平方米之间")
            return false
        }

        guard estimatedDuration >= 30 && estimatedDuration <= 365 else {
            showError("预计工期应在 30-365 天之间")
            return false
        }

        do {
            if let projectToEdit = projectToEdit {
                // Edit mode
                updateExistingProject(projectToEdit)
            } else {
                // Add mode
                createNewProject()
            }

            try modelContext.save()
            return true
        } catch {
            showError("保存失败: \(error.localizedDescription)")
            return false
        }
    }

    private func createNewProject() {
        let project = Project(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            houseType: houseType,
            area: area,
            startDate: startDate,
            estimatedDuration: estimatedDuration,
            coverImageData: coverImageData,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            isActive: isActive
        )

        modelContext.insert(project)

        // Create default budget if needed
        if project.budget == nil {
            let budget = Budget(totalBudget: 0)
            budget.project = project
            modelContext.insert(budget)
        }
    }

    private func updateExistingProject(_ project: Project) {
        project.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        project.houseType = houseType
        project.area = area
        project.startDate = startDate
        project.estimatedDuration = estimatedDuration
        project.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        project.coverImageData = coverImageData
        project.isActive = isActive
        project.updateTimestamp()
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }

    // MARK: - Photo Management

    func loadSelectedPhoto() async {
        guard let item = selectedPhoto else { return }

        if let data = try? await item.loadTransferable(type: Data.self) {
            coverImageData = data
        }
    }

    func removeCoverImage() {
        coverImageData = nil
        selectedPhoto = nil
    }

    // MARK: - Quick Actions

    func resetForm() {
        name = ""
        houseType = "三室两厅"
        area = 100.0
        startDate = Date()
        estimatedDuration = 90
        notes = ""
        coverImageData = nil
        selectedPhoto = nil
        isActive = true
    }

    func setDuration(_ days: Int) {
        estimatedDuration = max(30, min(365, days))
    }

    func adjustDuration(by days: Int) {
        setDuration(estimatedDuration + days)
    }
}
