//
//  ExpenseDetailView.swift
//  Panda
//
//  Created on 2026-02-07.
//

import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let expense: Expense
    let budget: Budget
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // 金额
                    amountSection

                    // 详细信息
                    detailsCard

                    // 照片
                    if expense.hasPhotos {
                        photosSection
                    }

                    // 备注
                    if !expense.notes.isEmpty {
                        notesCard
                    }

                    // 元数据
                    metadataSection
                }
                .padding(Spacing.md)
            }
            .background(Colors.backgroundPrimary)
            .navigationTitle("支出详情")
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
                AddExpenseView(modelContext: modelContext, budget: budget, expense: expense)
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteExpense()
                }
            } message: {
                Text("确定要删除这笔支出吗？此操作无法撤销。")
            }
        }
    }

    // MARK: - Amount Section

    private var amountSection: some View {
        CardView {
            VStack(spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("支出金额")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        Text(expense.formattedAmount)
                            .font(.numberLarge)
                            .foregroundColor(.primaryWood)
                    }
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color.primaryWood.opacity(0.1))
                            .frame(width: 48, height: 48)

                        Image(systemName: expense.category.iconName)
                            .foregroundColor(.primaryWood)
                            .font(.system(size: 22))
                    }
                }
            }
        }
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("详细信息")
                    .font(Fonts.headline)

                Divider()

                infoRow(label: "分类", value: expense.category.displayName)
                infoRow(label: "日期", value: expense.formattedDate)
                infoRow(label: "付款方式", value: expense.paymentType.displayName)

                if !expense.vendor.isEmpty {
                    infoRow(label: "商家/供应商", value: expense.vendor)
                }
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Photos Section

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("凭证照片")
                .font(Fonts.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.sm) {
                ForEach(Array(expense.photoData.enumerated()), id: \.offset) { _, data in
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

    // MARK: - Notes Card

    private var notesCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("备注")
                    .font(Fonts.headline)

                Divider()

                Text(expense.notes)
                    .font(Fonts.body)
                    .foregroundColor(Colors.textSecondary)
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Metadata Section

    private var metadataSection: some View {
        VStack(spacing: Spacing.xs) {
            Text("创建于 \(expense.createdAt.formatted(date: .long, time: .shortened))")
                .font(Fonts.caption)
                .foregroundColor(Colors.textHint)

            if expense.updatedAt != expense.createdAt {
                Text("更新于 \(expense.updatedAt.formatted(date: .long, time: .shortened))")
                    .font(Fonts.caption)
                    .foregroundColor(Colors.textHint)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.md)
    }

    // MARK: - Helper Methods

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(Colors.textPrimary)
        }
    }

    private func deleteExpense() {
        let expenseRepo = ExpenseRepository(modelContext: modelContext)
        do {
            try expenseRepo.delete(expense)
            dismiss()
        } catch {
            print("Failed to delete expense: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Budget.self, Expense.self, configurations: config)
    let budget = Budget(totalAmount: 180000)
    container.mainContext.insert(budget)

    let expense = Expense(
        amount: 5800,
        category: .plumbing,
        notes: "水电改造第一期",
        paymentType: .deposit,
        vendor: "张师傅水电"
    )
    container.mainContext.insert(expense)

    return ExpenseDetailView(expense: expense, budget: budget)
        .modelContainer(container)
}
