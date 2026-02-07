//
//  DocumentDetailView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct DocumentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let document: Document
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header
                    headerSection

                    // Photos
                    if document.hasPhotos {
                        photosSection
                    }

                    // Contract info
                    if document.isContract {
                        contractInfoSection
                        paymentRecordsSection
                    }

                    // Parties
                    if !document.partyA.isEmpty || !document.partyB.isEmpty {
                        partiesSection
                    }

                    // Notes
                    if !document.notes.isEmpty {
                        notesSection
                    }

                    // Metadata
                    metadataSection
                }
                .padding(Spacing.md)
            }
            .background(Colors.backgroundPrimary)
            .navigationTitle("文档详情")
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
                AddDocumentView(modelContext: modelContext, document: document)
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) { deleteDocument() }
            } message: {
                Text("确定要删除这个文档吗？此操作无法撤销。")
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: document.type.iconName)
                    .font(.title2)
                    .foregroundColor(Colors.primary)
                Text(document.type.displayName)
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textSecondary)
            }

            Text(document.name)
                .font(Fonts.titleMedium)

            Text(document.formattedDate)
                .font(Fonts.body)
                .foregroundColor(Colors.textSecondary)
        }
    }

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("照片")
                .font(Fonts.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                ForEach(Array(document.photoData.enumerated()), id: \.offset) { _, data in
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    }
                }
            }
        }
    }

    private var contractInfoSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("合同信息")
                    .font(Fonts.headline)

                Divider()

                if let amount = document.formattedAmount {
                    infoRow(label: "合同金额", value: amount)
                }

                if let method = document.paymentMethod {
                    infoRow(label: "付款方式", value: method.displayName)
                }

                if document.isFullyPaid {
                    HStack {
                        Text("付款状态")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("已付清")
                            .foregroundColor(Colors.success)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 4)
                            .background(Colors.success.opacity(0.1))
                            .cornerRadius(CornerRadius.sm)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("付款进度")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(document.paymentProgress * 100))%")
                                .foregroundColor(Colors.primary)
                        }
                        ProgressBar(progress: document.paymentProgress)
                    }
                }
            }
            .padding(Spacing.md)
        }
    }

    private var paymentRecordsSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("付款记录")
                    .font(Fonts.headline)

                Divider()

                ForEach(Array(document.paymentRecords.enumerated()), id: \.offset) { _, record in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.name)
                                .font(Fonts.body)
                            if let dueDate = record.dueDate {
                                Text("应付: \(dueDate, style: .date)")
                                    .font(Fonts.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(record.formattedAmount)
                                .font(Fonts.headline)
                                .foregroundColor(record.isPaid ? Colors.success : Colors.textPrimary)

                            if record.isPaid {
                                Text("已付")
                                    .font(Fonts.caption)
                                    .foregroundColor(Colors.success)
                            } else if record.isOverdue {
                                Text("逾期")
                                    .font(Fonts.caption)
                                    .foregroundColor(Colors.error)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(Spacing.md)
        }
    }

    private var partiesSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("当事人")
                    .font(Fonts.headline)

                Divider()

                if !document.partyA.isEmpty {
                    infoRow(label: "甲方（业主）", value: document.partyA)
                }

                if !document.partyB.isEmpty {
                    infoRow(label: "乙方（装修公司）", value: document.partyB)
                }
            }
            .padding(Spacing.md)
        }
    }

    private var notesSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("备注")
                    .font(Fonts.headline)

                Divider()

                Text(document.notes)
                    .font(Fonts.body)
                    .foregroundColor(Colors.textSecondary)
            }
            .padding(Spacing.md)
        }
    }

    private var metadataSection: some View {
        VStack(spacing: Spacing.xs) {
            Text("创建于 \(document.createdAt.formatted(date: .long, time: .shortened))")
                .font(Fonts.caption)
                .foregroundColor(Colors.textHint)

            if document.updatedAt != document.createdAt {
                Text("更新于 \(document.updatedAt.formatted(date: .long, time: .shortened))")
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textHint)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.md)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(Colors.textPrimary)
        }
    }

    private func deleteDocument() {
        modelContext.delete(document)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete document: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Document.self, configurations: config)

    let document = Document(
        name: "装修施工合同",
        type: .contract,
        contractAmount: 100000,
        paymentMethod: .progressive,
        paymentRecords: [
            PaymentRecord(name: "定金", amount: 30000, isPaid: true),
            PaymentRecord(name: "中期款", amount: 60000),
            PaymentRecord(name: "尾款", amount: 10000)
        ],
        partyA: "张三",
        partyB: "XX装修公司"
    )

    return DocumentDetailView(document: document)
        .modelContainer(container)
}
