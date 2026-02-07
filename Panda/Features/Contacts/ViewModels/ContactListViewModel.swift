//
//  ContactListViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class ContactListViewModel: ObservableObject {
    // MARK: - Properties

    @Published var contacts: [Contact] = []
    @Published var searchText: String = ""
    @Published var selectedRole: ContactRole?
    @Published var showingAddContact: Bool = false
    @Published var selectedContact: Contact?

    private let modelContext: ModelContext
    private let projectManager: ProjectManager

    // MARK: - Computed Properties

    var filteredContacts: [Contact] {
        var result = contacts

        // Filter by role
        if let role = selectedRole {
            result = result.filter { $0.role == role }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchText) ||
                contact.company.localizedCaseInsensitiveContains(searchText) ||
                contact.phoneNumber.contains(searchText)
            }
        }

        return result
    }

    var groupedContacts: [(role: ContactRole, contacts: [Contact])] {
        let grouped = Dictionary(grouping: filteredContacts) { $0.role }
        return ContactRole.allCases.compactMap { role in
            guard let contacts = grouped[role], !contacts.isEmpty else { return nil }
            return (role, contacts.sorted { $0.name < $1.name })
        }
    }

    var recommendedContacts: [Contact] {
        filteredContacts.filter { $0.isRecommended }
    }

    // MARK: - Initialization

    init(modelContext: ModelContext, projectManager: ProjectManager = ProjectManager.shared) {
        self.modelContext = modelContext
        self.projectManager = projectManager
    }

    // MARK: - Methods

    func loadContacts() {
        guard let currentProject = projectManager.currentProject(in: modelContext) else {
            contacts = []
            return
        }

        let projectID = currentProject.id
        let descriptor = FetchDescriptor<Contact>(
            predicate: #Predicate<Contact> { contact in
                contact.project?.id == projectID
            },
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            contacts = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch contacts: \(error)")
            contacts = []
        }
    }

    func deleteContact(_ contact: Contact) {
        modelContext.delete(contact)

        do {
            try modelContext.save()
            loadContacts()
        } catch {
            print("Failed to delete contact: \(error)")
        }
    }

    func deleteContacts(at offsets: IndexSet, from contacts: [Contact]) {
        for index in offsets {
            let contact = contacts[index]
            deleteContact(contact)
        }
    }

    func makePhoneCall(_ phoneNumber: String) {
        let cleanedNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")

        if let url = URL(string: "tel://\(cleanedNumber)") {
            UIApplication.shared.open(url)
        }
    }

    func openWechat(_ wechatID: String) {
        // WeChat URL scheme: weixin://
        if let url = URL(string: "weixin://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

    func toggleRecommended(_ contact: Contact) {
        contact.isRecommended.toggle()
        contact.updateTimestamp()

        do {
            try modelContext.save()
            loadContacts()
        } catch {
            print("Failed to toggle recommended status: \(error)")
        }
    }
}
