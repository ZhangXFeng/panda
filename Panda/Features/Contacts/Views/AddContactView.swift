//
//  AddContactView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddContactViewModel

    init(modelContext: ModelContext, contact: Contact? = nil) {
        _viewModel = StateObject(wrappedValue: AddContactViewModel(modelContext: modelContext, contact: contact))
    }

    var body: some View {
        NavigationStack {
            Form {
                // Basic info section
                Section {
                    TextField("姓名", text: $viewModel.name)
                        .autocorrectionDisabled()

                    Picker("角色", selection: $viewModel.role) {
                        ForEach(ContactRole.allCases) { role in
                            HStack {
                                Image(systemName: role.iconName)
                                Text(role.displayName)
                            }
                            .tag(role)
                        }
                    }

                    TextField("电话", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                        .autocorrectionDisabled()

                    TextField("微信号（可选）", text: $viewModel.wechatID)
                        .autocorrectionDisabled()
                } header: {
                    Text("基本信息")
                } footer: {
                    Text("姓名和电话为必填项")
                }

                // Company info section
                Section("公司信息") {
                    TextField("公司/店铺名称（可选）", text: $viewModel.company)
                        .autocorrectionDisabled()

                    TextField("地址（可选）", text: $viewModel.address)
                        .autocorrectionDisabled()
                }

                // Rating section
                Section {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("评价")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: Spacing.md) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    viewModel.rating = star
                                } label: {
                                    Image(systemName: star <= viewModel.rating ? "star.fill" : "star")
                                        .foregroundColor(star <= viewModel.rating ? .yellow : .gray)
                                        .font(.title2)
                                }
                            }

                            if viewModel.rating > 0 {
                                Button {
                                    viewModel.rating = 0
                                } label: {
                                    Text("清除")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, Spacing.xs)
                    }

                    Toggle("推荐此联系人", isOn: $viewModel.isRecommended)
                }

                // Notes section
                Section("备注") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .alert("错误", isPresented: $viewModel.showingError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - Preview

#Preview("Add Contact") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Contact.self, configurations: config)
    let context = container.mainContext

    // Create sample project
    let project = Project(
        name: "我的新家",
        houseType: "三室两厅",
        area: 120.0
    )
    context.insert(project)
    ProjectManager.shared.currentProject = project

    return AddContactView(modelContext: context)
}

#Preview("Edit Contact") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Contact.self, configurations: config)
    let context = container.mainContext

    // Create sample project
    let project = Project(
        name: "我的新家",
        houseType: "三室两厅",
        area: 120.0
    )
    context.insert(project)

    // Create sample contact
    let contact = Contact(
        name: "张工长",
        role: .foreman,
        phoneNumber: "13800138001",
        wechatID: "zhanglaoshi",
        company: "专业装修队",
        address: "建材市场3号楼",
        rating: 5,
        notes: "工作认真负责，价格合理",
        isRecommended: true
    )
    contact.project = project
    context.insert(contact)

    return AddContactView(modelContext: context, contact: contact)
}
