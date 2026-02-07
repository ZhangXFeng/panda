//
//  AddDocumentView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddDocumentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddDocumentViewModel

    init(modelContext: ModelContext, document: Document? = nil) {
        _viewModel = StateObject(wrappedValue: AddDocumentViewModel(modelContext: modelContext, document: document))
    }

    var body: some View {
        NavigationStack {
            Form {
                // Basic info
                basicInfoSection

                // Photos
                photosSection

                // Contract specific (if type is contract)
                if viewModel.isContractType {
                    contractSection
                    partiesSection
                    paymentRecordsSection
                }

                // Notes
                notesSection
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if viewModel.save() { dismiss() }
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

    private var basicInfoSection: some View {
        Section("基本信息") {
            TextField("文档名称", text: $viewModel.name)
            Picker("文档类型", selection: $viewModel.type) {
                ForEach(DocumentType.allCases) { type in
                    HStack {
                        Image(systemName: type.iconName)
                        Text(type.displayName)
                    }
                    .tag(type)
                }
            }
            DatePicker("日期", selection: $viewModel.date, displayedComponents: .date)
        }
    }

    private var photosSection: some View {
        Section("照片") {
            PhotosPicker(selection: $viewModel.selectedPhotos, maxSelectionCount: 9, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("选择照片")
                    Spacer()
                    if !viewModel.photoData.isEmpty {
                        Text("\(viewModel.photoData.count) 张")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onChange(of: viewModel.selectedPhotos) { _, _ in
                _Concurrency.Task { await viewModel.loadSelectedPhotos() }
            }
        }
    }

    private var contractSection: some View {
        Section("合同信息") {
            TextField("合同金额", text: $viewModel.contractAmount)
                .keyboardType(.decimalPad)
            Picker("付款方式", selection: $viewModel.paymentMethod) {
                ForEach(PaymentMethod.allCases) { method in
                    Text(method.displayName).tag(method)
                }
            }
            DatePicker("开始日期", selection: $viewModel.contractStartDate, displayedComponents: .date)
            DatePicker("结束日期", selection: $viewModel.contractEndDate, displayedComponents: .date)
        }
    }

    private var partiesSection: some View {
        Section("当事人") {
            TextField("甲方（业主）", text: $viewModel.partyA)
            TextField("乙方（装修公司）", text: $viewModel.partyB)
        }
    }

    private var paymentRecordsSection: some View {
        Section {
            ForEach(Array(viewModel.paymentRecords.enumerated()), id: \.offset) { index, record in
                VStack(alignment: .leading, spacing: 8) {
                    Text(record.name)
                        .font(.headline)
                    Text(record.formattedAmount)
                        .foregroundColor(record.isPaid ? Colors.success : .secondary)
                }
            }
            Button("生成默认付款计划") {
                viewModel.setupDefaultPaymentRecords()
            }
        } header: {
            Text("付款计划")
        }
    }

    private var notesSection: some View {
        Section("备注") {
            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 100)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Document.self, configurations: config)
    AddDocumentView(modelContext: container.mainContext)
}
