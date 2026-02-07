//
//  ExpenseRepository.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

/// 支出数据仓库
@MainActor
final class ExpenseRepository {
    // MARK: - Properties

    private let modelContext: ModelContext

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD Operations

    /// 创建支出记录
    func create(_ expense: Expense, in budget: Budget) throws {
        modelContext.insert(expense)
        budget.addExpense(expense)
        try modelContext.save()
    }

    /// 获取支出记录
    func fetch(by id: UUID) throws -> Expense? {
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    /// 获取所有支出记录
    func fetchAll(for budget: Budget, sortBy: ExpenseSortOption = .dateDescending) throws -> [Expense] {
        let budgetId = budget.id
        var descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { expense in
                expense.budget?.id == budgetId
            }
        )

        descriptor.sortBy = sortBy.sortDescriptors

        return try modelContext.fetch(descriptor)
    }

    /// 获取指定分类的支出记录
    func fetchExpenses(for budget: Budget, category: ExpenseCategory) throws -> [Expense] {
        let budgetId = budget.id
        let targetRawValue = category.rawValue
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { expense in
                expense.budget?.id == budgetId && expense.category.rawValue == targetRawValue
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    /// 获取指定日期范围的支出记录
    func fetchExpenses(
        for budget: Budget,
        from startDate: Date,
        to endDate: Date
    ) throws -> [Expense] {
        let budgetId = budget.id
        let start = startDate
        let end = endDate
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { expense in
                expense.budget?.id == budgetId &&
                expense.date >= start &&
                expense.date <= end
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    /// 搜索支出记录
    func search(for budget: Budget, keyword: String) throws -> [Expense] {
        let budgetId = budget.id
        let searchKeyword = keyword.lowercased()

        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { expense in
                expense.budget?.id == budgetId && (
                    expense.notes.localizedStandardContains(searchKeyword) ||
                    expense.vendor.localizedStandardContains(searchKeyword)
                )
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    /// 更新支出记录
    func update(_ expense: Expense) throws {
        expense.updateTimestamp()
        try modelContext.save()
    }

    /// 删除支出记录
    func delete(_ expense: Expense) throws {
        expense.budget?.removeExpense(expense)
        modelContext.delete(expense)
        try modelContext.save()
    }

    // MARK: - Statistics

    /// 获取分组的支出（按月）
    func fetchGroupedByMonth(for budget: Budget) throws -> [MonthGroup] {
        let allExpenses = try fetchAll(for: budget, sortBy: .dateDescending)

        var groups: [String: [Expense]] = [:]
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        for expense in allExpenses {
            let monthKey = formatter.string(from: expense.date)
            groups[monthKey, default: []].append(expense)
        }

        return groups.map { key, expenses in
            let components = key.split(separator: "-")
            let year = Int(components[0]) ?? 0
            let month = Int(components[1]) ?? 0

            let dateComponents = DateComponents(year: year, month: month)
            let date = calendar.date(from: dateComponents) ?? Date()

            let total = expenses.reduce(Decimal.zero) { $0 + $1.amount }

            return MonthGroup(
                date: date,
                expenses: expenses,
                totalAmount: total
            )
        }.sorted { $0.date > $1.date }
    }

    /// 获取最近 N 笔支出（按日期降序）
    func fetchTopRecent(for budget: Budget, limit: Int = 3) throws -> [Expense] {
        let budgetId = budget.id
        var descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { expense in
                expense.budget?.id == budgetId
            }
        )

        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        descriptor.fetchLimit = limit

        return try modelContext.fetch(descriptor)
    }

    /// 获取 TOP N 支出
    func fetchTopExpenses(for budget: Budget, limit: Int = 5) throws -> [Expense] {
        let budgetId = budget.id
        var descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { expense in
                expense.budget?.id == budgetId
            }
        )

        descriptor.sortBy = [SortDescriptor(\.amount, order: .reverse)]
        descriptor.fetchLimit = limit

        return try modelContext.fetch(descriptor)
    }
}

// MARK: - Sort Options

/// 支出排序选项
enum ExpenseSortOption {
    case dateDescending
    case dateAscending
    case amountDescending
    case amountAscending

    var sortDescriptors: [SortDescriptor<Expense>] {
        switch self {
        case .dateDescending:
            return [SortDescriptor(\.date, order: .reverse)]
        case .dateAscending:
            return [SortDescriptor(\.date, order: .forward)]
        case .amountDescending:
            return [SortDescriptor(\.amount, order: .reverse)]
        case .amountAscending:
            return [SortDescriptor(\.amount, order: .forward)]
        }
    }
}

// MARK: - Month Group

/// 月份分组
struct MonthGroup: Identifiable {
    let id = UUID()
    let date: Date
    let expenses: [Expense]
    let totalAmount: Decimal

    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: totalAmount as NSDecimalNumber) ?? "¥0.00"
    }
}
