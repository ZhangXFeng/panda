//
//  Project.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

/// 装修项目模型
@Model
final class Project {
    // MARK: - Properties

    /// 唯一标识符
    var id: UUID

    /// 项目名称（如：我的家、爸妈的房子）
    var name: String

    /// 房屋类型（如：两室一厅、三室两厅）
    var houseType: String

    /// 建筑面积（平方米）
    var area: Double

    /// 开工日期
    var startDate: Date

    /// 预计工期（天数）
    var estimatedDuration: Int

    /// 项目封面图片数据
    var coverImageData: Data?

    /// 项目描述或备注
    var notes: String

    /// 创建时间
    var createdAt: Date

    /// 最后更新时间
    var updatedAt: Date

    /// 是否为当前活跃项目
    var isActive: Bool

    // MARK: - Relationships

    /// 预算（一对一关系）
    @Relationship(deleteRule: .cascade)
    var budget: Budget?

    /// 装修阶段（一对多关系）
    @Relationship(deleteRule: .cascade, inverse: \Phase.project)
    var phases: [Phase]

    /// 材料清单（一对多关系）
    @Relationship(deleteRule: .cascade, inverse: \Material.project)
    var materials: [Material]

    /// 联系人（一对多关系）
    @Relationship(deleteRule: .cascade, inverse: \Contact.project)
    var contacts: [Contact]

    /// 装修日记（一对多关系）
    @Relationship(deleteRule: .cascade, inverse: \JournalEntry.project)
    var journalEntries: [JournalEntry]

    // MARK: - Initialization

    init(
        name: String,
        houseType: String,
        area: Double,
        startDate: Date,
        estimatedDuration: Int,
        coverImageData: Data? = nil,
        notes: String = "",
        isActive: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.houseType = houseType
        self.area = area
        self.startDate = startDate
        self.estimatedDuration = estimatedDuration
        self.coverImageData = coverImageData
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isActive = isActive
        self.phases = []
        self.materials = []
        self.contacts = []
        self.journalEntries = []
    }

    // MARK: - Computed Properties

    /// 预计完工日期
    var estimatedEndDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: estimatedDuration,
            to: startDate
        ) ?? startDate
    }

    /// 实际已用天数
    var actualDaysUsed: Int {
        Calendar.current.dateComponents(
            [.day],
            from: startDate,
            to: Date()
        ).day ?? 0
    }

    /// 整体进度百分比（基于已完成阶段）
    var overallProgress: Double {
        let enabledPhases = phases.filter { $0.isEnabled }
        guard !enabledPhases.isEmpty else { return 0 }

        let completedPhases = enabledPhases.filter { $0.isCompleted }.count
        return Double(completedPhases) / Double(enabledPhases.count)
    }

    /// 是否延期
    var isDelayed: Bool {
        actualDaysUsed > estimatedDuration && overallProgress < 1.0
    }

    /// 剩余天数
    var remainingDays: Int {
        let remaining = estimatedDuration - actualDaysUsed
        return max(0, remaining)
    }
}

// MARK: - Helper Methods

extension Project {
    /// 更新时间戳
    func updateTimestamp() {
        updatedAt = Date()
    }

    /// 添加阶段
    func addPhase(_ phase: Phase) {
        phases.append(phase)
        updateTimestamp()
    }

    /// 添加材料
    func addMaterial(_ material: Material) {
        materials.append(material)
        updateTimestamp()
    }

    /// 添加联系人
    func addContact(_ contact: Contact) {
        contacts.append(contact)
        updateTimestamp()
    }

    /// 添加日记
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        updateTimestamp()
    }
}
