//
//  ProjectManager.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData

/// 项目管理器 - 管理当前选中的项目
@Observable
final class ProjectManager {
    // MARK: - Properties

    /// 当前选中项目的 ID
    private(set) var currentProjectId: UUID? {
        didSet {
            if let id = currentProjectId {
                UserDefaults.standard.set(id.uuidString, forKey: Self.currentProjectIdKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.currentProjectIdKey)
            }
        }
    }

    /// UserDefaults 存储键
    private static let currentProjectIdKey = "currentProjectId"

    // MARK: - Initialization

    init() {
        // 从 UserDefaults 恢复上次选中的项目
        if let idString = UserDefaults.standard.string(forKey: Self.currentProjectIdKey),
           let id = UUID(uuidString: idString) {
            self.currentProjectId = id
        }
    }

    // MARK: - Methods

    /// 选择项目
    func selectProject(_ project: Project) {
        currentProjectId = project.id
    }

    /// 选择项目（通过 ID）
    func selectProject(id: UUID) {
        currentProjectId = id
    }

    /// 清除选中的项目
    func clearSelection() {
        currentProjectId = nil
    }

    /// 获取当前项目（需要传入项目列表）
    func currentProject(from projects: [Project]) -> Project? {
        // 优先返回已选中的项目
        if let currentId = currentProjectId,
           let project = projects.first(where: { $0.id == currentId }) {
            return project
        }

        // 如果没有选中项目，返回活跃项目
        if let activeProject = projects.first(where: { $0.isActive }) {
            return activeProject
        }

        // 都没有则返回第一个项目
        return projects.first
    }

    /// 自动选择项目（如果当前没有选中或选中的项目已被删除）
    func autoSelectIfNeeded(from projects: [Project]) {
        // 检查当前选中的项目是否还存在
        if let currentId = currentProjectId,
           projects.contains(where: { $0.id == currentId }) {
            return // 当前选中的项目仍然存在，无需操作
        }

        // 需要自动选择新项目
        if let activeProject = projects.first(where: { $0.isActive }) {
            selectProject(activeProject)
        } else if let firstProject = projects.first {
            selectProject(firstProject)
        } else {
            clearSelection()
        }
    }
}
