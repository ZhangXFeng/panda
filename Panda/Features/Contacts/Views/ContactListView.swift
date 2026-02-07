//
//  ContactListView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct ContactListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ContactListViewModel
    @State private var showingAddContact = false
    @State private var selectedContact: Contact?

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ContactListViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar

                // Role filter chips
                if !viewModel.searchText.isEmpty || viewModel.selectedRole != nil {
                    filterSection
                }

                // Contact list
                if viewModel.filteredContacts.isEmpty {
                    emptyState
                } else {
                    contactList
                }
            }
            .navigationTitle("通讯录")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddContact = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                AddContactView(modelContext: modelContext)
                    .onDisappear {
                        viewModel.loadContacts()
                    }
            }
            .sheet(item: $selectedContact) { contact in
                ContactDetailView(contact: contact)
                    .onDisappear {
                        viewModel.loadContacts()
                    }
            }
            .onAppear {
                viewModel.loadContacts()
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("搜索姓名、公司或电话", text: $viewModel.searchText)
                .textFieldStyle(.plain)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Colors.backgroundSecondary)
        .cornerRadius(CornerRadius.md)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // All button
                FilterChip(
                    title: "全部",
                    isSelected: viewModel.selectedRole == nil
                ) {
                    viewModel.selectedRole = nil
                }

                // Role filters
                ForEach(ContactRole.allCases) { role in
                    FilterChip(
                        title: role.displayName,
                        isSelected: viewModel.selectedRole == role
                    ) {
                        viewModel.selectedRole = role
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Contact List

    private var contactList: some View {
        List {
            // Recommended section
            if !viewModel.recommendedContacts.isEmpty && viewModel.selectedRole == nil {
                Section {
                    ForEach(viewModel.recommendedContacts) { contact in
                        ContactRow(contact: contact, viewModel: viewModel)
                            .onTapGesture {
                                selectedContact = contact
                            }
                    }
                } header: {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("推荐")
                            .font(.headline)
                    }
                }
            }

            // Grouped by role
            ForEach(viewModel.groupedContacts, id: \.role) { group in
                Section {
                    ForEach(group.contacts) { contact in
                        ContactRow(contact: contact, viewModel: viewModel)
                            .onTapGesture {
                                selectedContact = contact
                            }
                    }
                    .onDelete { offsets in
                        viewModel.deleteContacts(at: offsets, from: group.contacts)
                    }
                } header: {
                    HStack {
                        Image(systemName: group.role.iconName)
                            .foregroundColor(Colors.primary)
                            .font(.caption)
                        Text(group.role.displayName)
                            .font(.headline)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(viewModel.searchText.isEmpty ? "还没有联系人" : "未找到匹配的联系人")
                .font(.headline)
                .foregroundColor(.secondary)

            if viewModel.searchText.isEmpty {
                Text("点击右上角 + 添加联系人")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Contact Row

private struct ContactRow: View {
    let contact: Contact
    let viewModel: ContactListViewModel

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Role icon
            ZStack {
                Circle()
                    .fill(Colors.primary.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: contact.role.iconName)
                    .foregroundColor(Colors.primary)
                    .font(.system(size: 20))
            }

            // Contact info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(contact.name)
                        .font(.headline)

                    if contact.isRecommended {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }

                HStack(spacing: Spacing.sm) {
                    if !contact.company.isEmpty {
                        Text(contact.company)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if contact.rating > 0 {
                        HStack(spacing: 2) {
                            ForEach(0..<contact.rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }

                Text(contact.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Quick actions
            HStack(spacing: Spacing.sm) {
                // Phone button
                Button {
                    viewModel.makePhoneCall(contact.phoneNumber)
                } label: {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .frame(width: 32, height: 32)
                        .background(Colors.success)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // WeChat button (if available)
                if !contact.wechatID.isEmpty {
                    Button {
                        viewModel.openWechat(contact.wechatID)
                    } label: {
                        Image(systemName: "message.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .frame(width: 32, height: 32)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: Project.self, Contact.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    ContactListView(modelContext: container.mainContext)
        .modelContainer(container)
}
