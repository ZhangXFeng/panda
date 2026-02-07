//
//  AddJournalEntryView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddJournalEntryViewModel

    init(modelContext: ModelContext, entry: JournalEntry? = nil) {
        _viewModel = StateObject(wrappedValue: AddJournalEntryViewModel(modelContext: modelContext, entry: entry))
    }

    var body: some View {
        NavigationStack {
            Form {
                // Basic info section
                Section {
                    TextField("标题", text: $viewModel.title)
                        .autocorrectionDisabled()

                    DatePicker("日期", selection: $viewModel.date, displayedComponents: .date)
                } header: {
                    Text("基本信息")
                } footer: {
                    Text("标题和内容为必填项")
                }

                // Content section
                Section("日记内容") {
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 200)
                }

                // Photos section
                Section {
                    PhotosPicker(
                        selection: $viewModel.selectedPhotos,
                        maxSelectionCount: 9,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(Colors.primary)
                            Text("选择照片")
                            Spacer()
                            if viewModel.hasPhotos {
                                Text("\(viewModel.photoCount) 张")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onChange(of: viewModel.selectedPhotos) { _, _ in
                        _Concurrency.Task {
                            await viewModel.loadSelectedPhotos()
                        }
                    }

                    if viewModel.hasPhotos {
                        photoGrid
                    }
                } header: {
                    Text("照片")
                } footer: {
                    Text("最多可选择 9 张照片")
                }

                // Tags section
                Section {
                    // Tag input
                    HStack {
                        TextField("添加标签", text: $viewModel.newTag)
                            .autocorrectionDisabled()
                            .onSubmit {
                                viewModel.addTag()
                            }

                        Button {
                            viewModel.addTag()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Colors.primary)
                        }
                        .disabled(viewModel.newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    // Current tags
                    if !viewModel.tags.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("已添加的标签")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            FlowLayout(spacing: Spacing.sm) {
                                ForEach(viewModel.tags, id: \.self) { tag in
                                    TagChip(tag: tag) {
                                        viewModel.removeTag(tag)
                                    }
                                }
                            }
                        }
                    }

                    // Predefined tags
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("常用标签")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        FlowLayout(spacing: Spacing.sm) {
                            ForEach(AddJournalEntryViewModel.commonTags, id: \.self) { tag in
                                Button {
                                    viewModel.addPredefinedTag(tag)
                                } label: {
                                    Text(tag)
                                        .font(.caption)
                                        .foregroundColor(viewModel.tags.contains(tag) ? .secondary : Colors.primary)
                                        .padding(.horizontal, Spacing.sm)
                                        .padding(.vertical, 4)
                                        .background(viewModel.tags.contains(tag) ? Colors.backgroundSecondary : Colors.primary.opacity(0.1))
                                        .cornerRadius(CornerRadius.sm)
                                }
                                .disabled(viewModel.tags.contains(tag))
                            }
                        }
                    }
                } header: {
                    Text("标签")
                }
            }
            .navigationTitle(viewModel.title_)
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

    // MARK: - Photo Grid

    private var photoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: Spacing.sm) {
            ForEach(Array(viewModel.photoData.enumerated()), id: \.offset) { index, data in
                if let uiImage = UIImage(data: data) {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))

                        Button {
                            viewModel.removePhoto(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding(4)
                    }
                }
            }
        }
    }
}

// MARK: - Tag Chip

private struct TagChip: View {
    let tag: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.caption)

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 4)
        .background(Colors.primary)
        .cornerRadius(CornerRadius.sm)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview("Add Entry") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, JournalEntry.self, configurations: config)

    return AddJournalEntryView(modelContext: container.mainContext)
        .modelContainer(container)
}

#Preview("Edit Entry") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, JournalEntry.self, configurations: config)

    let entry = JournalEntry(
        title: "开工大吉",
        content: "今天正式开工了！工长带着团队过来，先做了开工仪式，然后开始拆除工作。",
        tags: ["拆除", "开工"]
    )

    return AddJournalEntryView(modelContext: container.mainContext, entry: entry)
        .modelContainer(container)
}
