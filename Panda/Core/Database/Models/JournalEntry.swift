//
//  JournalEntry.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

/// 装修日记模型
@Model
final class Journal Entry {
    // MARK: - Properties

    /// 唯一标识符
    var id: UUID

    /// 标题
    var title: String

    /// 内容
    var content: String

    /// 照片数据
    var photoData: [Data]

    /// 标签
    var tags: [String]

    /// 日记日期
    var date: Date

    /// 创建时间
    var createdAt: Date

    /// 最后更新时间
    var updatedAt: Date

    // MARK: - Relationships

    /// 关联的项目（反向关系）
    var project: Project?

    // MARK: - Initialization

    init(
        title: String,
        content: String,
        photoData: [Data] = [],
        tags: [String] = [],
        date: Date = Date()
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.photoData = photoData
        self.tags = tags
        self.date = date
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// 是否有照片
    var hasPhotos: Bool {
        !photoData.isEmpty
    }

    /// 照片数量
    var photoCount: Int {
        photoData.count
    }

    /// 格式化日期
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - Helper Methods

extension JournalEntry {
    /// 更新时间戳
    func updateTimestamp() {
        updatedAt = Date()
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

    /// 添加标签
    func addTag(_ tag: String) {
        guard !tags.contains(tag) else { return }
        tags.append(tag)
        updateTimestamp()
    }

    /// 删除标签
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        updateTimestamp()
    }
}
