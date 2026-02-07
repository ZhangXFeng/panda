//
//  ContactDetailView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct ContactDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let contact: Contact
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header card
                    headerCard

                    // Contact info card
                    contactInfoCard

                    // Company info card
                    if !contact.company.isEmpty || !contact.address.isEmpty {
                        companyInfoCard
                    }

                    // Rating card
                    if contact.rating > 0 || contact.isRecommended {
                        ratingCard
                    }

                    // Notes card
                    if !contact.notes.isEmpty {
                        notesCard
                    }

                    // Metadata
                    metadataSection
                }
                .padding(Spacing.md)
            }
            .background(Colors.backgroundPrimary)
            .navigationTitle("联系人详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("编辑", systemImage: "pencil")
                        }

                        Divider()

                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                AddContactView(modelContext: modelContext, contact: contact)
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteContact()
                }
            } message: {
                Text("确定要删除联系人 \(contact.name) 吗？此操作无法撤销。")
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        CardView {
            VStack(spacing: Spacing.md) {
                // Role icon
                ZStack {
                    Circle()
                        .fill(Colors.primary.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: contact.role.iconName)
                        .foregroundColor(Colors.primary)
                        .font(.system(size: 36))
                }

                // Name
                HStack {
                    Text(contact.name)
                        .font(Fonts.titleMedium)

                    if contact.isRecommended {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.title3)
                    }
                }

                // Role
                Text(contact.role.displayName)
                    .font(Fonts.body)
                    .foregroundColor(Colors.textSecondary)

                // Quick actions
                HStack(spacing: Spacing.lg) {
                    // Phone
                    ActionButton(
                        icon: "phone.fill",
                        label: "拨打",
                        color: Colors.success
                    ) {
                        makePhoneCall()
                    }

                    // WeChat
                    if !contact.wechatID.isEmpty {
                        ActionButton(
                            icon: "message.fill",
                            label: "微信",
                            color: .green
                        ) {
                            openWechat()
                        }
                    }

                    // Map
                    if !contact.address.isEmpty {
                        ActionButton(
                            icon: "map.fill",
                            label: "导航",
                            color: .blue
                        ) {
                            openMap()
                        }
                    }
                }
                .padding(.top, Spacing.sm)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
        }
    }

    // MARK: - Contact Info Card

    private var contactInfoCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("联系方式")
                    .font(Fonts.headline)
                    .foregroundColor(Colors.textPrimary)

                Divider()

                // Phone
                InfoRow(
                    icon: "phone.fill",
                    label: "电话",
                    value: contact.phoneNumber,
                    color: Colors.success
                )

                // WeChat
                if !contact.wechatID.isEmpty {
                    InfoRow(
                        icon: "message.fill",
                        label: "微信",
                        value: contact.wechatID,
                        color: .green
                    )
                }
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Company Info Card

    private var companyInfoCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("公司信息")
                    .font(Fonts.headline)
                    .foregroundColor(Colors.textPrimary)

                Divider()

                if !contact.company.isEmpty {
                    InfoRow(
                        icon: "building.2",
                        label: "公司",
                        value: contact.company,
                        color: Colors.primary
                    )
                }

                if !contact.address.isEmpty {
                    InfoRow(
                        icon: "location.fill",
                        label: "地址",
                        value: contact.address,
                        color: .blue
                    )
                }
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Rating Card

    private var ratingCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("评价")
                    .font(Fonts.headline)
                    .foregroundColor(Colors.textPrimary)

                Divider()

                if contact.rating > 0 {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(Colors.primary)

                        Text("评分")
                            .font(Fonts.body)
                            .foregroundColor(Colors.textSecondary)

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(0..<contact.rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.body)
                            }
                            ForEach(contact.rating..<5, id: \.self) { _ in
                                Image(systemName: "star")
                                    .foregroundColor(.gray)
                                    .font(.body)
                            }
                        }
                    }
                }

                if contact.isRecommended {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(Colors.primary)

                        Text("推荐")
                            .font(Fonts.body)
                            .foregroundColor(Colors.textSecondary)

                        Spacer()

                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Colors.success)
                    }
                }
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("备注")
                    .font(Fonts.headline)
                    .foregroundColor(Colors.textPrimary)

                Divider()

                Text(contact.notes)
                    .font(Fonts.body)
                    .foregroundColor(Colors.textSecondary)
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Metadata Section

    private var metadataSection: some View {
        VStack(spacing: Spacing.xs) {
            Text("创建于 \(contact.createdAt.formatted(date: .long, time: .shortened))")
                .font(Fonts.caption)
                .foregroundColor(Colors.textHint)

            if contact.updatedAt != contact.createdAt {
                Text("更新于 \(contact.updatedAt.formatted(date: .long, time: .shortened))")
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textHint)
            }
        }
        .padding(.top, Spacing.md)
    }

    // MARK: - Actions

    private func makePhoneCall() {
        let cleanedNumber = contact.phoneNumber
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")

        if let url = URL(string: "tel://\(cleanedNumber)") {
            UIApplication.shared.open(url)
        }
    }

    private func openWechat() {
        if let url = URL(string: "weixin://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

    private func openMap() {
        let encodedAddress = contact.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?address=\(encodedAddress)") {
            UIApplication.shared.open(url)
        }
    }

    private func deleteContact() {
        modelContext.delete(contact)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete contact: \(error)")
        }
    }
}

// MARK: - Action Button

private struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .clipShape(Circle())

                Text(label)
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textSecondary)
            }
        }
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(Fonts.body)
                .foregroundColor(Colors.textSecondary)

            Spacer()

            Text(value)
                .font(Fonts.body)
                .foregroundColor(Colors.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview {
    let contact = Contact(
        name: "张工长",
        role: .foreman,
        phoneNumber: "13800138001",
        wechatID: "zhanglaoshi",
        company: "专业装修队",
        address: "北京市朝阳区建材市场3号楼",
        rating: 5,
        notes: "工作认真负责，价格合理，已合作多个项目，值得推荐。",
        isRecommended: true
    )

    ContactDetailView(contact: contact)
        .modelContainer(for: [Project.self, Contact.self], inMemory: true)
}
