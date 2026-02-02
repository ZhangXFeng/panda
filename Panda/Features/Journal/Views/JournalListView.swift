//
//  JournalListView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct JournalListView: View {
    @Query private var projects: [Project]

    var body: some View {
        NavigationStack {
            ScrollView {
                if let project = projects.first {
                    VStack(spacing: Spacing.md) {
                        // 日记列表
                        journalsSection(project: project)
                    }
                    .padding()
                } else {
                    emptyState
                }
            }
            .navigationTitle("装修日记")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Components

    private func journalsSection(project: Project) -> some View {
        VStack(spacing: Spacing.md) {
            let journals = project.journalEntries.sorted { $0.date > $1.date }

            if journals.isEmpty {
                Text("暂无日记记录")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .padding()
            } else {
                ForEach(journals) { journal in
                    JournalCard(journal: journal)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "book")
                .font(.system(size: 64))
                .foregroundColor(.textHint)
            Text("暂无日记记录")
                .font(.titleSmall)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Journal Card

struct JournalCard: View {
    let journal: JournalEntry

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // 标题和日期
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(journal.title)
                            .font(.titleSmall)

                        Text(journal.formattedDate)
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    if journal.hasPhotos {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(.info)
                        Text("\(journal.photoCount)")
                            .font(.captionMedium)
                            .foregroundColor(.info)
                    }
                }

                // 内容预览
                if !journal.content.isEmpty {
                    Text(journal.content)
                        .font(.bodyRegular)
                        .foregroundColor(.textPrimary)
                        .lineLimit(3)
                }

                // 标签
                if !journal.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.xs) {
                            ForEach(journal.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.captionRegular)
                                    .foregroundColor(.primaryWood)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xs)
                                    .background(Color.primaryWood.opacity(0.1))
                                    .cornerRadius(CornerRadius.sm)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    JournalListView()
        .modelContainer(for: [Project.self, JournalEntry.self], inMemory: true)
}
