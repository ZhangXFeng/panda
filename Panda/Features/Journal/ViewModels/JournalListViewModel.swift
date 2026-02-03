//
//  JournalListViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class JournalListViewModel: ObservableObject {
    // MARK: - Properties

    @Published var entries: [JournalEntry] = []
    @Published var searchText: String = ""
    @Published var selectedTag: String?
    @Published var showingAddEntry: Bool = false
    @Published var selectedEntry: JournalEntry?

    private let modelContext: ModelContext
    private let projectManager: ProjectManager

    // MARK: - Computed Properties

    var filteredEntries: [JournalEntry] {
        var result = entries

        // Filter by tag
        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return result
    }

    var groupedEntries: [(month: String, entries: [JournalEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: entry.date)
        }

        return grouped.map { (month: $0.key, entries: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.month > $1.month }
    }

    var allTags: [String] {
        let tags = entries.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }

    var entriesWithPhotos: [JournalEntry] {
        filteredEntries.filter { $0.hasPhotos }
    }

    // MARK: - Initialization

    init(modelContext: ModelContext, projectManager: ProjectManager = ProjectManager.shared) {
        self.modelContext = modelContext
        self.projectManager = projectManager
    }

    // MARK: - Methods

    func loadEntries() {
        guard let currentProject = projectManager.currentProject else {
            entries = []
            return
        }

        let projectID = currentProject.id
        let descriptor = FetchDescriptor<JournalEntry>(
            predicate: #Predicate<JournalEntry> { entry in
                entry.project?.id == projectID
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            entries = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch journal entries: \(error)")
            entries = []
        }
    }

    func deleteEntry(_ entry: JournalEntry) {
        modelContext.delete(entry)

        do {
            try modelContext.save()
            loadEntries()
        } catch {
            print("Failed to delete journal entry: \(error)")
        }
    }

    func deleteEntries(at offsets: IndexSet, from entries: [JournalEntry]) {
        for index in offsets {
            let entry = entries[index]
            deleteEntry(entry)
        }
    }

    func formatDate(_ date: Date, style: String = "long") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")

        switch style {
        case "short":
            formatter.dateFormat = "MM/dd"
        case "medium":
            formatter.dateFormat = "MM月dd日"
        case "long":
            formatter.dateFormat = "yyyy年MM月dd日"
        case "full":
            formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        default:
            formatter.dateStyle = .long
            formatter.timeStyle = .none
        }

        return formatter.string(from: date)
    }

    func relativeDateString(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else if let daysAgo = calendar.dateComponents([.day], from: date, to: now).day, daysAgo < 7 {
            return "\(daysAgo) 天前"
        } else {
            return formatDate(date, style: "medium")
        }
    }
}
