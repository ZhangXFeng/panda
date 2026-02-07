//
//  JournalDetailView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct JournalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let entry: JournalEntry
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var selectedPhotoIndex: Int?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header
                    headerSection

                    // Content
                    contentSection

                    // Photos
                    if entry.hasPhotos {
                        photosSection
                    }

                    // Tags
                    if !entry.tags.isEmpty {
                        tagsSection
                    }

                    // Metadata
                    metadataSection
                }
                .padding(Spacing.md)
            }
            .background(Colors.backgroundPrimary)
            .navigationTitle("日记详情")
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
                AddJournalEntryView(modelContext: modelContext, entry: entry)
            }
            .sheet(item: $selectedPhotoIndex) { index in
                PhotoDetailView(photoData: entry.photoData, initialIndex: index)
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteEntry()
                }
            } message: {
                Text("确定要删除这条日记吗？此操作无法撤销。")
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(entry.title)
                .font(Fonts.titleMedium)
                .foregroundColor(Colors.textPrimary)

            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(Colors.primary)

                Text(entry.formattedDate)
                    .font(Fonts.body)
                    .foregroundColor(Colors.textSecondary)

                if entry.hasPhotos {
                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.caption)
                        Text("\(entry.photoCount)")
                            .font(Fonts.caption)
                    }
                    .foregroundColor(Colors.primary)
                }
            }
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        CardView {
            Text(entry.content)
                .font(Fonts.body)
                .foregroundColor(Colors.textPrimary)
                .padding(Spacing.md)
        }
    }

    // MARK: - Photos Section

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "photo.stack")
                    .foregroundColor(Colors.primary)
                Text("照片")
                    .font(Fonts.headline)
                    .foregroundColor(Colors.textPrimary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.sm) {
                ForEach(Array(entry.photoData.enumerated()), id: \.offset) { index, data in
                    if let uiImage = UIImage(data: data) {
                        Button {
                            selectedPhotoIndex = index
                        } label: {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Tags Section

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "tag")
                    .foregroundColor(Colors.primary)
                Text("标签")
                    .font(Fonts.headline)
                    .foregroundColor(Colors.textPrimary)
            }

            FlowLayout(spacing: Spacing.sm) {
                ForEach(entry.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(Fonts.caption)
                        .foregroundColor(Colors.primary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Colors.primary.opacity(0.1))
                        .cornerRadius(CornerRadius.sm)
                }
            }
        }
    }

    // MARK: - Metadata Section

    private var metadataSection: some View {
        VStack(spacing: Spacing.xs) {
            Text("创建于 \(entry.createdAt.formatted(date: .long, time: .shortened))")
                .font(Fonts.caption)
                .foregroundColor(Colors.textHint)

            if entry.updatedAt != entry.createdAt {
                Text("更新于 \(entry.updatedAt.formatted(date: .long, time: .shortened))")
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textHint)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.md)
    }

    // MARK: - Actions

    private func deleteEntry() {
        modelContext.delete(entry)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete journal entry: \(error)")
        }
    }
}

// MARK: - Photo Detail View

private struct PhotoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let photoData: [Data]
    @State var currentIndex: Int

    init(photoData: [Data], initialIndex: Int) {
        self.photoData = photoData
        _currentIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $currentIndex) {
                ForEach(Array(photoData.enumerated()), id: \.offset) { index, data in
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .background(Color.black)
            .navigationTitle("\(currentIndex + 1) / \(photoData.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Int Identifiable Extension

extension Int: Identifiable {
    public var id: Int { self }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, JournalEntry.self, configurations: config)

    let entry = JournalEntry(
        title: "开工大吉！新家装修正式启动",
        content: "今天是个好日子，我的新家装修正式开工了！",
        tags: ["拆除", "开工", "进展"]
    )

    return JournalDetailView(entry: entry)
        .modelContainer(container)
}
