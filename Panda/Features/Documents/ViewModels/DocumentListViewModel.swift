//
//  DocumentListViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class DocumentListViewModel: ObservableObject {
    // MARK: - Properties

    @Published var documents: [Document] = []
    @Published var searchText: String = ""
    @Published var selectedType: DocumentType?
    @Published var showingAddDocument: Bool = false
    @Published var selectedDocument: Document?

    private let modelContext: ModelContext
    private let projectManager: ProjectManager

    // MARK: - Computed Properties

    var filteredDocuments: [Document] {
        var result = documents

        // Filter by type
        if let type = selectedType {
            result = result.filter { $0.type == type }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { document in
                document.name.localizedCaseInsensitiveContains(searchText) ||
                document.notes.localizedCaseInsensitiveContains(searchText) ||
                document.partyA.localizedCaseInsensitiveContains(searchText) ||
                document.partyB.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { $0.date > $1.date }
    }

    var groupedDocuments: [(type: DocumentType, documents: [Document])] {
        let grouped = Dictionary(grouping: filteredDocuments) { $0.type }
        return DocumentType.allCases.compactMap { type in
            guard let documents = grouped[type], !documents.isEmpty else { return nil }
            return (type, documents.sorted { $0.date > $1.date })
        }
    }

    var contracts: [Document] {
        filteredDocuments.filter { $0.type == .contract }
    }

    var unpaidContracts: [Document] {
        contracts.filter { !$0.isFullyPaid }
    }

    var overduePayments: [(document: Document, record: PaymentRecord)] {
        var result: [(Document, PaymentRecord)] = []
        for document in documents where document.isContract {
            for record in document.paymentRecords where record.isOverdue {
                result.append((document, record))
            }
        }
        return result
    }

    // MARK: - Initialization

    init(modelContext: ModelContext, projectManager: ProjectManager = ProjectManager.shared) {
        self.modelContext = modelContext
        self.projectManager = projectManager
    }

    // MARK: - Methods

    func loadDocuments() {
        guard let currentProject = projectManager.currentProject else {
            documents = []
            return
        }

        let projectID = currentProject.id
        let descriptor = FetchDescriptor<Document>(
            predicate: #Predicate<Document> { document in
                document.project?.id == projectID
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            documents = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch documents: \(error)")
            documents = []
        }
    }

    func deleteDocument(_ document: Document) {
        modelContext.delete(document)

        do {
            try modelContext.save()
            loadDocuments()
        } catch {
            print("Failed to delete document: \(error)")
        }
    }

    func deleteDocuments(at offsets: IndexSet, from documents: [Document]) {
        for index in offsets {
            let document = documents[index]
            deleteDocument(document)
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
        default:
            formatter.dateStyle = .long
            formatter.timeStyle = .none
        }

        return formatter.string(from: date)
    }
}
