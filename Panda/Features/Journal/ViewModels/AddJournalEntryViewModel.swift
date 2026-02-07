//
//  AddJournalEntryViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI

@MainActor
class AddJournalEntryViewModel: ObservableObject {
    // MARK: - Properties

    @Published var title: String = ""
    @Published var content: String = ""
    @Published var date: Date = Date()
    @Published var photoData: [Data] = []
    @Published var tags: [String] = []
    @Published var newTag: String = ""

    @Published var showingError: Bool = false
    @Published var errorMessage: String = ""
    @Published var selectedPhotos: [PhotosPickerItem] = []

    private let modelContext: ModelContext
    private let projectManager: ProjectManager
    private var entryToEdit: JournalEntry?

    var isEditMode: Bool {
        entryToEdit != nil
    }

    var title_: String {
        isEditMode ? "编辑日记" : "写日记"
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasPhotos: Bool {
        !photoData.isEmpty
    }

    var photoCount: Int {
        photoData.count
    }

    // MARK: - Initialization

    init(
        modelContext: ModelContext,
        entry: JournalEntry? = nil,
        projectManager: ProjectManager = ProjectManager.shared
    ) {
        self.modelContext = modelContext
        self.projectManager = projectManager
        self.entryToEdit = entry

        if let entry = entry {
            loadEntry(entry)
        }
    }

    // MARK: - Methods

    private func loadEntry(_ entry: JournalEntry) {
        title = entry.title
        content = entry.content
        date = entry.date
        photoData = entry.photoData
        tags = entry.tags
    }

    func save() -> Bool {
        guard canSave else {
            showError("请填写标题和内容")
            return false
        }

        guard let currentProject = projectManager.currentProject(in: modelContext) else {
            showError("请先选择或创建项目")
            return false
        }

        do {
            if let entryToEdit = entryToEdit {
                // Edit mode
                updateExistingEntry(entryToEdit)
            } else {
                // Add mode
                createNewEntry(project: currentProject)
            }

            try modelContext.save()
            return true
        } catch {
            showError("保存失败: \(error.localizedDescription)")
            return false
        }
    }

    private func createNewEntry(project: Project) {
        let entry = JournalEntry(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            photoData: photoData,
            tags: tags,
            date: date
        )

        entry.project = project
        modelContext.insert(entry)
    }

    private func updateExistingEntry(_ entry: JournalEntry) {
        entry.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.date = date
        entry.photoData = photoData
        entry.tags = tags
        entry.updateTimestamp()
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

    // MARK: - Tag Management

    func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty else { return }
        guard !tags.contains(trimmedTag) else {
            newTag = ""
            return
        }

        tags.append(trimmedTag)
        newTag = ""
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    func addPredefinedTag(_ tag: String) {
        guard !tags.contains(tag) else { return }
        tags.append(tag)
    }

    // MARK: - Predefined Tags

    static let commonTags = [
        "拆除", "水电", "泥瓦", "木工", "油漆",
        "安装", "验收", "问题", "进展", "材料",
        "设计", "效果", "前后对比"
    ]
}
