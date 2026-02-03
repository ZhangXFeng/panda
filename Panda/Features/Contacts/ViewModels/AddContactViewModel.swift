//
//  AddContactViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class AddContactViewModel: ObservableObject {
    // MARK: - Properties

    @Published var name: String = ""
    @Published var role: ContactRole = .other
    @Published var phoneNumber: String = ""
    @Published var wechatID: String = ""
    @Published var company: String = ""
    @Published var address: String = ""
    @Published var rating: Int = 0
    @Published var notes: String = ""
    @Published var isRecommended: Bool = false

    @Published var showingError: Bool = false
    @Published var errorMessage: String = ""

    private let modelContext: ModelContext
    private let projectManager: ProjectManager
    private var contactToEdit: Contact?

    var isEditMode: Bool {
        contactToEdit != nil
    }

    var title: String {
        isEditMode ? "编辑联系人" : "添加联系人"
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Initialization

    init(
        modelContext: ModelContext,
        contact: Contact? = nil,
        projectManager: ProjectManager = ProjectManager.shared
    ) {
        self.modelContext = modelContext
        self.projectManager = projectManager
        self.contactToEdit = contact

        if let contact = contact {
            loadContact(contact)
        }
    }

    // MARK: - Methods

    private func loadContact(_ contact: Contact) {
        name = contact.name
        role = contact.role
        phoneNumber = contact.phoneNumber
        wechatID = contact.wechatID
        company = contact.company
        address = contact.address
        rating = contact.rating
        notes = contact.notes
        isRecommended = contact.isRecommended
    }

    func save() -> Bool {
        guard canSave else {
            showError("请填写必填字段（姓名和电话）")
            return false
        }

        guard let currentProject = projectManager.currentProject else {
            showError("请先选择或创建项目")
            return false
        }

        do {
            if let contactToEdit = contactToEdit {
                // Edit mode
                updateExistingContact(contactToEdit)
            } else {
                // Add mode
                createNewContact(project: currentProject)
            }

            try modelContext.save()
            return true
        } catch {
            showError("保存失败: \(error.localizedDescription)")
            return false
        }
    }

    private func createNewContact(project: Project) {
        let contact = Contact(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            role: role,
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            wechatID: wechatID.trimmingCharacters(in: .whitespacesAndNewlines),
            company: company.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            rating: rating,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            isRecommended: isRecommended
        )

        contact.project = project
        modelContext.insert(contact)
    }

    private func updateExistingContact(_ contact: Contact) {
        contact.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        contact.role = role
        contact.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        contact.wechatID = wechatID.trimmingCharacters(in: .whitespacesAndNewlines)
        contact.company = company.trimmingCharacters(in: .whitespacesAndNewlines)
        contact.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        contact.rating = rating
        contact.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        contact.isRecommended = isRecommended
        contact.updateTimestamp()
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }

    func validatePhoneNumber() -> Bool {
        let phonePattern = "^1[3-9]\\d{9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phonePattern)
        return phoneTest.evaluate(with: phoneNumber)
    }
}
