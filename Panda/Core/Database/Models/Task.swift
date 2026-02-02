//
//  Task.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

/// 任务模型
@Model
final class Task {
    // MARK: - Properties

    /// 唯一标识符
    var id: UUID

    /// 任务标题
    var title: String

    /// 任务描述
    var taskDescription: String

    /// 任务状态
    var status: TaskStatus

    /// 负责人
    var assignee: String

    /// 负责人联系方式
    var assigneeContact: String

    /// 计划开始日期
    var plannedStartDate: Date?

    /// 计划完成日期
    var plannedEndDate: Date?

    /// 实际完成日期
    var actualCompletionDate: Date?

    /// 照片数据（施工照片等）
    var photoData: [Data]

    /// 创建时间
    var createdAt: Date

    /// 最后更新时间
    var updatedAt: Date

    // MARK: - Relationships

    /// 关联的阶段（反向关系）
    var phase: Phase?

    // MARK: - Initialization

    init(
        title: String,
        taskDescription: String = "",
        status: TaskStatus = .pending,
        assignee: String = "",
        assigneeContact: String = "",
        plannedStartDate: Date? = nil,
        plannedEndDate: Date? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.taskDescription = taskDescription
        self.status = status
        self.assignee = assignee
        self.assigneeContact = assigneeContact
        self.plannedStartDate = plannedStartDate
        self.plannedEndDate = plannedEndDate
        self.photoData = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// 是否已完成
    var isCompleted: Bool {
        status == .completed
    }

    /// 是否有问题
    var hasIssue: Bool {
        status == .issue
    }

    /// 是否逾期
    var isOverdue: Bool {
        guard !isCompleted, let endDate = plannedEndDate else {
            return false
        }
        return Date() > endDate
    }

    /// 是否有照片
    var hasPhotos: Bool {
        !photoData.isEmpty
    }

    /// 照片数量
    var photoCount: Int {
        photoData.count
    }

    /// 格式化的日期范围
    var formattedDateRange: String? {
        guard let start = plannedStartDate, let end = plannedEndDate else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")

        return "\(formatter.string(from: start)) ~ \(formatter.string(from: end))"
    }
}

// MARK: - Helper Methods

extension Task {
    /// 更新时间戳
    func updateTimestamp() {
        updatedAt = Date()
    }

    /// 开始任务
    func start() {
        guard status == .pending else { return }
        status = .inProgress
        updateTimestamp()
    }

    /// 完成任务
    func complete(at date: Date = Date()) {
        status = .completed
        actualCompletionDate = date
        updateTimestamp()
    }

    /// 标记为有问题
    func markAsIssue() {
        status = .issue
        updateTimestamp()
    }

    /// 取消任务
    func cancel() {
        status = .cancelled
        updateTimestamp()
    }

    /// 重置状态
    func reset() {
        status = .pending
        actualCompletionDate = nil
        updateTimestamp()
    }

    /// 添加照片
    func addPhoto(_ data: Data) {
        photoData.append(data)
        updateTimestamp()
    }

    /// 删除照片
    func removePhoto(at index: Int) {
        guard index >= 0 && index < photoData.count else { return }
        photoData.remove(at: index)
        updateTimestamp()
    }

    /// 更新负责人
    func updateAssignee(_ name: String, contact: String = "") {
        assignee = name
        assigneeContact = contact
        updateTimestamp()
    }
}

// MARK: - Sorting

extension Task {
    /// 按状态排序（待处理优先）
    static func sortByStatus(_ lhs: Task, _ rhs: Task) -> Bool {
        let order: [TaskStatus] = [.issue, .inProgress, .pending, .completed, .cancelled]
        let lhsIndex = order.firstIndex(of: lhs.status) ?? order.count
        let rhsIndex = order.firstIndex(of: rhs.status) ?? order.count
        return lhsIndex < rhsIndex
    }

    /// 按计划完成日期排序
    static func sortByPlannedEndDate(_ lhs: Task, _ rhs: Task) -> Bool {
        guard let lhsDate = lhs.plannedEndDate, let rhsDate = rhs.plannedEndDate else {
            return false
        }
        return lhsDate < rhsDate
    }

    /// 按创建时间排序
    static func sortByCreatedDate(_ lhs: Task, _ rhs: Task) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}
