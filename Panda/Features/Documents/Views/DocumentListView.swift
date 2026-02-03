//
//  DocumentListView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct DocumentListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: DocumentListViewModel
    @State private var showingAddDocument = false
    @State private var selectedDocument: Document?

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: DocumentListViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar

                // Type filter chips
                if !viewModel.searchText.isEmpty || viewModel.selectedType != nil {
                    typeFilterSection
                }

                // Overdue payments warning
                if !viewModel.overduePayments.isEmpty {
                    overduePaymentsWarning
                }

                // Document list
                if viewModel.filteredDocuments.isEmpty {
                    emptyState
                } else {
                    documentList
                }
            }
            .navigationTitle("合同文档")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddDocument = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDocument) {
                AddDocumentView(modelContext: modelContext)
                    .onDisappear {
                        viewModel.loadDocuments()
                    }
            }
            .sheet(item: $selectedDocument) { document in
                DocumentDetailView(document: document, modelContext: modelContext)
                    .onDisappear {
                        viewModel.loadDocuments()
                    }
            }
            .onAppear {
                viewModel.loadDocuments()
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("搜索文档名称、备注或当事人", text: $viewModel.searchText)
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

    // MARK: - Type Filter Section

    private var typeFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // All button
                FilterChip(
                    title: "全部",
                    isSelected: viewModel.selectedType == nil
                ) {
                    viewModel.selectedType = nil
                }

                // Type filters
                ForEach(DocumentType.allCases) { type in
                    FilterChip(
                        title: type.displayName,
                        isSelected: viewModel.selectedType == type
                    ) {
                        viewModel.selectedType = type
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Overdue Payments Warning

    private var overduePaymentsWarning: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Colors.warning)

                Text("有 \(viewModel.overduePayments.count) 笔付款逾期")
                    .font(Fonts.body)
                    .foregroundColor(Colors.textPrimary)

                Spacer()
            }
            .padding(Spacing.md)
            .background(Colors.warning.opacity(0.1))
            .cornerRadius(CornerRadius.md)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - Document List

    private var documentList: some View {
        List {
            ForEach(viewModel.groupedDocuments, id: \.type) { group in
                Section {
                    ForEach(group.documents) { document in
                        DocumentRow(document: document, viewModel: viewModel)
                            .onTapGesture {
                                selectedDocument = document
                            }
                    }
                    .onDelete { offsets in
                        viewModel.deleteDocuments(at: offsets, from: group.documents)
                    }
                } header: {
                    HStack {
                        Image(systemName: group.type.iconName)
                            .foregroundColor(Colors.primary)
                            .font(.caption)
                        Text(group.type.displayName)
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
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(viewModel.searchText.isEmpty ? "还没有文档" : "未找到匹配的文档")
                .font(.headline)
                .foregroundColor(.secondary)

            if viewModel.searchText.isEmpty {
                Text("点击右上角 + 添加合同或文档")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Document Row

private struct DocumentRow: View {
    let document: Document
    let viewModel: DocumentListViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.name)
                        .font(.headline)
                        .lineLimit(2)

                    Text(viewModel.formatDate(document.date, style: "medium"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if document.hasPhotos {
                    ZStack {
                        Circle()
                            .fill(Colors.primary.opacity(0.1))
                            .frame(width: 32, height: 32)

                        Image(systemName: "photo")
                            .foregroundColor(Colors.primary)
                            .font(.system(size: 14))
                    }
                }
            }

            // Contract info (if applicable)
            if document.isContract {
                contractInfo
            }

            // Parties (if specified)
            if !document.partyA.isEmpty || !document.partyB.isEmpty {
                partiesInfo
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    private var contractInfo: some View {
        VStack(spacing: Spacing.xs) {
            if let formattedAmount = document.formattedAmount {
                HStack {
                    Text("合同金额")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(formattedAmount)
                        .font(.headline)
                        .foregroundColor(Colors.primary)
                }
            }

            if !document.isFullyPaid {
                HStack {
                    Text("付款进度")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    ProgressBar(
                        value: document.paymentProgress,
                        height: 6
                    )
                    .frame(width: 100)

                    Text("\(Int(document.paymentProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                HStack {
                    Spacer()
                    Text("已付清")
                        .font(.caption)
                        .foregroundColor(Colors.success)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Colors.success.opacity(0.1))
                        .cornerRadius(CornerRadius.sm)
                }
            }
        }
        .padding(Spacing.sm)
        .background(Colors.backgroundSecondary)
        .cornerRadius(CornerRadius.md)
    }

    private var partiesInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !document.partyA.isEmpty {
                HStack {
                    Text("甲方:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(document.partyA)
                        .font(.caption)
                        .foregroundColor(Colors.textPrimary)
                }
            }

            if !document.partyB.isEmpty {
                HStack {
                    Text("乙方:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(document.partyB)
                        .font(.caption)
                        .foregroundColor(Colors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Document.self, configurations: config)
    let context = container.mainContext

    // Create sample project
    let project = Project(
        name: "我的新家",
        houseType: "三室两厅",
        area: 120.0
    )
    context.insert(project)

    // Create sample documents
    let contract = Document(
        name: "装修施工合同",
        type: .contract,
        date: Date(),
        notes: "全包装修合同",
        contractAmount: 100000,
        paymentMethod: .progressive,
        paymentRecords: [
            PaymentRecord(name: "定金", amount: 30000, isPaid: true, paidDate: Date()),
            PaymentRecord(name: "中期款", amount: 60000, isPaid: false),
            PaymentRecord(name: "尾款", amount: 10000, isPaid: false)
        ],
        partyA: "张三",
        partyB: "XX装修公司"
    )
    contract.project = project
    context.insert(contract)

    let receipt = Document(
        name: "材料采购收据",
        type: .receipt,
        date: Date().addingTimeInterval(-86400),
        notes: "瓷砖采购"
    )
    receipt.project = project
    context.insert(receipt)

    return DocumentListView(modelContext: context)
}
