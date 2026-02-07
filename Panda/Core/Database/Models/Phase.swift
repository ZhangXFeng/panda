//
//  Phase.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

/// 装修阶段模型
@Model
final class Phase {
    // MARK: - Properties

    /// 唯一标识符
    var id: UUID

    /// 阶段名称
    var name: String

    /// 阶段类型
    var type: PhaseType

    /// 排序顺序
    var sortOrder: Int

    /// 计划开始日期
    var plannedStartDate: Date

    /// 计划结束日期
    var plannedEndDate: Date

    /// 实际开始日期
    var actualStartDate: Date?

    /// 实际结束日期
    var actualEndDate: Date?

    /// 阶段描述
    var notes: String

    /// 是否已完成
    var isCompleted: Bool

    /// 是否启用阶段
    var isEnabled: Bool

    /// 创建时间
    var createdAt: Date

    /// 最后更新时间
    var updatedAt: Date

    // MARK: - Relationships

    /// 关联的项目（反向关系）
    var project: Project?

    /// 任务列表（一对多关系）
    @Relationship(deleteRule: .cascade, inverse: \Task.phase)
    var tasks: [Task]

    // MARK: - Initialization

    init(
        name: String,
        type: PhaseType,
        sortOrder: Int,
        plannedStartDate: Date,
        plannedEndDate: Date,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.sortOrder = sortOrder
        self.plannedStartDate = plannedStartDate
        self.plannedEndDate = plannedEndDate
        self.notes = notes
        self.isCompleted = false
        self.isEnabled = true
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tasks = []
    }

    // MARK: - Computed Properties

    /// 计划工期（天数）
    var plannedDuration: Int {
        Calendar.current.dateComponents(
            [.day],
            from: plannedStartDate,
            to: plannedEndDate
        ).day ?? 0
    }

    /// 实际工期（天数）
    var actualDuration: Int? {
        guard let start = actualStartDate, let end = actualEndDate else {
            return nil
        }

        return Calendar.current.dateComponents(
            [.day],
            from: start,
            to: end
        ).day
    }

    /// 是否已开始
    var hasStarted: Bool {
        actualStartDate != nil
    }

    /// 是否进行中
    var isInProgress: Bool {
        hasStarted && !isCompleted
    }

    /// 是否延期
    var isDelayed: Bool {
        guard let actualStart = actualStartDate else {
            return Date() > plannedStartDate && !hasStarted
        }

        if let actualEnd = actualEndDate {
            return actualEnd > plannedEndDate
        } else {
            return Date() > plannedEndDate && !isCompleted
        }
    }

    /// 延期天数
    var delayedDays: Int {
        guard isDelayed else { return 0 }

        if let actualEnd = actualEndDate {
            return Calendar.current.dateComponents(
                [.day],
                from: plannedEndDate,
                to: actualEnd
            ).day ?? 0
        } else {
            return Calendar.current.dateComponents(
                [.day],
                from: plannedEndDate,
                to: Date()
            ).day ?? 0
        }
    }

    /// 阶段进度（基于任务完成情况）
    var progress: Double {
        guard isEnabled else { return 0.0 }
        guard !tasks.isEmpty else { return isCompleted ? 1.0 : 0.0 }

        let completedTasks = tasks.filter { $0.status == .completed }.count
        return Double(completedTasks) / Double(tasks.count)
    }

    /// 已完成任务数
    var completedTasksCount: Int {
        guard isEnabled else { return 0 }
        return tasks.filter { $0.status == .completed }.count
    }

    /// 总任务数
    var totalTasksCount: Int {
        guard isEnabled else { return 0 }
        return tasks.count
    }
}

// MARK: - Helper Methods

extension Phase {
    /// 更新时间戳
    func updateTimestamp() {
        updatedAt = Date()
    }

    /// 开始阶段
    func start(at date: Date = Date()) {
        guard actualStartDate == nil else { return }
        actualStartDate = date
        updateTimestamp()
    }

    /// 完成阶段
    func complete(at date: Date = Date()) {
        guard !isCompleted else { return }

        actualEndDate = date
        isCompleted = true

        // 自动完成所有未完成的任务
        for task in tasks where task.status != .completed {
            task.complete(at: date)
        }

        updateTimestamp()
    }

    /// 添加任务
    func addTask(_ task: Task) {
        tasks.append(task)
        updateTimestamp()
    }

    /// 删除任务
    func removeTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        updateTimestamp()
    }

    /// 检查是否所有任务都已完成
    func areAllTasksCompleted() -> Bool {
        guard !tasks.isEmpty else { return false }
        return tasks.allSatisfy { $0.status == .completed }
    }

    /// 根据任务状态同步阶段状态
    func syncStatusFromTasks() {
        guard !tasks.isEmpty else { return }

        if tasks.allSatisfy({ $0.status == .completed }) {
            complete()
            return
        }

        if isCompleted {
            isCompleted = false
            actualEndDate = nil
            updateTimestamp()
        }

        if tasks.contains(where: { $0.status == .inProgress || $0.status == .completed }) {
            start()
        }
    }
}

// MARK: - Sorting

extension Phase {
    /// 按排序顺序排序
    static func sortBySortOrder(_ lhs: Phase, _ rhs: Phase) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    /// 按计划开始日期排序
    static func sortByPlannedStartDate(_ lhs: Phase, _ rhs: Phase) -> Bool {
        lhs.plannedStartDate < rhs.plannedStartDate
    }
}
