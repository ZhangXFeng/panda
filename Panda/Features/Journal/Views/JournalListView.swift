//
//  JournalListView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: JournalListViewModel
    @State private var showingAddEntry = false
    @State private var selectedEntry: JournalEntry?

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: JournalListViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar

                // Tag filter chips
                if !viewModel.allTags.isEmpty && (viewModel.selectedTag != nil || !viewModel.searchText.isEmpty) {
                    tagFilterSection
                }

                // Journal list
                if viewModel.filteredEntries.isEmpty {
                    emptyState
                } else {
                    journalList
                }
            }
            .navigationTitle("装修日记")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddJournalEntryView(modelContext: modelContext)
                    .onDisappear {
                        viewModel.loadEntries()
                    }
            }
            .sheet(item: $selectedEntry) { entry in
                JournalDetailView(entry: entry)
                    .onDisappear {
                        viewModel.loadEntries()
                    }
            }
            .onAppear {
                viewModel.loadEntries()
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("搜索标题、内容或标签", text: $viewModel.searchText)
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

    // MARK: - Tag Filter Section

    private var tagFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // All button
                FilterChip(
                    title: "全部",
                    isSelected: viewModel.selectedTag == nil
                ) {
                    viewModel.selectedTag = nil
                }

                // Tag filters
                ForEach(viewModel.allTags, id: \.self) { tag in
                    FilterChip(
                        title: tag,
                        isSelected: viewModel.selectedTag == tag
                    ) {
                        viewModel.selectedTag = tag
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Journal List

    private var journalList: some View {
        List {
            ForEach(viewModel.groupedEntries, id: \.month) { group in
                Section {
                    ForEach(group.entries) { entry in
                        JournalEntryRow(entry: entry, viewModel: viewModel)
                            .onTapGesture {
                                selectedEntry = entry
                            }
                    }
                    .onDelete { offsets in
                        viewModel.deleteEntries(at: offsets, from: group.entries)
                    }
                } header: {
                    Text(group.month)
                        .font(.headline)
                        .foregroundColor(Colors.primary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(viewModel.searchText.isEmpty ? "还没有日记" : "未找到匹配的日记")
                .font(.headline)
                .foregroundColor(.secondary)

            if viewModel.searchText.isEmpty {
                Text("点击右上角 ✏️ 开始记录装修日记")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Journal Entry Row

private struct JournalEntryRow: View {
    let entry: JournalEntry
    let viewModel: JournalListViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Date and title
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.headline)
                        .lineLimit(2)

                    Text(viewModel.relativeDateString(entry.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if entry.hasPhotos {
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

            // Content preview
            Text(entry.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .padding(.vertical, 4)

            // Photos preview (if available)
            if entry.hasPhotos {
                photoPreview
            }

            // Tags
            if !entry.tags.isEmpty {
                tagList
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    private var photoPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(Array(entry.photoData.prefix(4).enumerated()), id: \.offset) { index, data in
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    }
                }

                if entry.photoCount > 4 {
                    ZStack {
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .fill(Colors.backgroundSecondary)
                            .frame(width: 80, height: 80)

                        Text("+\(entry.photoCount - 4)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private var tagList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(entry.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .foregroundColor(Colors.primary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Colors.primary.opacity(0.1))
                        .cornerRadius(CornerRadius.sm)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, JournalEntry.self, configurations: config)

    return JournalListView(modelContext: container.mainContext)
        .modelContainer(container)
}
