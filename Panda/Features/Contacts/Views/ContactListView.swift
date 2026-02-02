//
//  ContactListView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct ContactListView: View {
    @Query private var projects: [Project]
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                if let project = projects.first {
                    VStack(spacing: Spacing.md) {
                        // 联系人列表
                        contactsSection(project: project)
                    }
                    .padding()
                } else {
                    emptyState
                }
            }
            .navigationTitle("通讯录")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "搜索联系人")
        }
    }

    // MARK: - Components

    private func contactsSection(project: Project) -> some View {
        VStack(spacing: Spacing.md) {
            let contacts = filteredContacts(project: project)

            if contacts.isEmpty {
                Text("暂无联系人")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .padding()
            } else {
                ForEach(contacts) { contact in
                    ContactCard(contact: contact)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 64))
                .foregroundColor(.textHint)
            Text("暂无联系人")
                .font(.titleSmall)
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Helpers

    private func filteredContacts(project: Project) -> [Contact] {
        if searchText.isEmpty {
            return project.contacts
        }
        return project.contacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.company.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Contact Card

struct ContactCard: View {
    let contact: Contact

    var body: some View {
        CardView {
            HStack(spacing: Spacing.md) {
                // 头像
                Circle()
                    .fill(Color.primaryWood.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(contact.name.prefix(1)))
                            .font(.titleSmall)
                            .foregroundColor(.primaryWood)
                    )

                // 信息
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(contact.name)
                        .font(.bodyMedium)

                    if !contact.company.isEmpty {
                        Text(contact.company)
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                    }

                    HStack(spacing: Spacing.md) {
                        if !contact.phoneNumber.isEmpty {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "phone.fill")
                                    .font(.caption)
                                Text(contact.phoneNumber)
                                    .font(.captionRegular)
                            }
                            .foregroundColor(.info)
                        }
                    }
                }

                Spacer()

                // 快捷操作
                if !contact.phoneNumber.isEmpty {
                    Button(action: {
                        if let url = URL(string: "tel://\(contact.phoneNumber)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "phone.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.success)
                    }
                }
            }
        }
    }
}

#Preview {
    ContactListView()
        .modelContainer(for: [Project.self, Contact.self], inMemory: true)
}
