//
//  SampleDataGenerator.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData

/// 测试数据生成器
enum SampleDataGenerator {

    // MARK: - Generate All Sample Data

    /// 生成所有测试数据
    @MainActor
    static func generateAllSampleData(in context: ModelContext) {
        clearAllData(in: context)

        let bundles = [
            makeMyHomeBundle(),
            makeParentsHomeBundle(),
            makeRentalApartmentBundle(),
            makeNewlywedHomeBundle()
        ]

        for bundle in bundles {
            insert(bundle: bundle, into: context)
        }

        do {
            try context.save()
            print("✅ 测试数据生成完成，共创建 \(bundles.count) 个项目")
        } catch {
            print("⚠️ 测试数据保存失败: \(error)")
        }
    }

    /// 清除所有数据
    @MainActor
    static func clearAllData(in context: ModelContext) {
        do {
            try context.delete(model: Project.self)
            try context.delete(model: Budget.self)
            try context.delete(model: Expense.self)
            try context.delete(model: Phase.self)
            try context.delete(model: Task.self)
            try context.delete(model: Material.self)
            try context.delete(model: Contact.self)
            try context.delete(model: JournalEntry.self)
            print("🗑️ 已清除所有现有数据")
        } catch {
            print("⚠️ 清除数据失败: \(error)")
        }
    }

    // MARK: - Bundles

    private struct ProjectBundle {
        let project: Project
        let budget: Budget
        let expenses: [Expense]
        let phases: [Phase]
        let tasks: [Task]
        let materials: [Material]
        let contacts: [Contact]
        let journals: [JournalEntry]
    }

    private enum PhaseStatus {
        case pending
        case inProgress
        case completed
    }

    // MARK: - Project 1: 我的家（进行中，50%进度）

    private static func makeMyHomeBundle() -> ProjectBundle {
        let startDate = dateByAdding(days: -45)
        let project = Project(
            name: "我的家",
            houseType: "三室两厅",
            area: 120,
            startDate: startDate,
            estimatedDuration: 90,
            notes: "新房装修，北欧简约风格",
            isActive: true
        )

        let budget = makeBudget(amount: 180000, warning: 0.8, project: project)

        let expenses = [
            makeExpense(8000, .design, -40, "全屋设计方案", "张设计工作室", .deposit, budget),
            makeExpense(5500, .demolition, -32, "客厅阳台打通", "李师傅施工队", .fullPayment, budget),
            makeExpense(20000, .plumbing, -25, "水电改造（材料+人工）", "水电工程公司", .deposit, budget),
            makeExpense(15000, .flooring, -18, "客厅+厨卫瓷砖", "马可波罗", .deposit, budget),
            makeExpense(9000, .masonry, -12, "贴砖人工费", "王师傅瓦工队", .fullPayment, budget)
        ]

        let phases = makeDefaultPhases(for: project)
        let phaseByType = phasesByType(phases)

        applyPhaseStatus(phaseByType[.preparation], .completed)
        applyPhaseStatus(phaseByType[.demolition], .completed)
        applyPhaseStatus(phaseByType[.plumbing], .inProgress)

        let tasks: [Task] = [
            makeTask("确定设计方案", .completed, phaseByType[.preparation]),
            makeTask("签订施工合同", .completed, phaseByType[.preparation]),
            makeTask("水电定位", .completed, phaseByType[.plumbing]),
            makeTask("材料进场", .inProgress, phaseByType[.plumbing]),
            makeTask("隐蔽工程验收", .pending, phaseByType[.plumbing])
        ]

        let materials = [
            makeMaterial("马可波罗瓷砖", "马可波罗", "800x800", 89.9, 120, "块", .ordered, "客厅", project),
            makeMaterial("多乐士乳胶漆", "多乐士", "20L", 480, 3, "桶", .pending, "全屋", project)
        ]

        let contacts = [
            makeContact("张设计师", .designer, "13800001111", "设计工作室", project),
            makeContact("李工长", .foreman, "13900002222", "施工队", project)
        ]

        let journals = [
            makeJournal("开工第一天", "水电定位完成，沟通顺利。", ["开工", "水电"], -25, project),
            makeJournal("瓦工进场", "瓷砖到货，现场开始贴砖。", ["瓦工", "材料"], -12, project)
        ]

        return ProjectBundle(
            project: project,
            budget: budget,
            expenses: expenses,
            phases: phases,
            tasks: tasks,
            materials: materials,
            contacts: contacts,
            journals: journals
        )
    }

    // MARK: - Project 2: 爸妈的房子（刚开始）

    private static func makeParentsHomeBundle() -> ProjectBundle {
        let startDate = dateByAdding(days: -7)
        let project = Project(
            name: "爸妈的房子",
            houseType: "两室一厅",
            area: 78,
            startDate: startDate,
            estimatedDuration: 75,
            notes: "老房翻新，注重实用",
            isActive: false
        )

        let budget = makeBudget(amount: 120000, warning: 0.75, project: project)

        let expenses = [
            makeExpense(3000, .design, -5, "初步设计方案", "张设计工作室", .deposit, budget)
        ]

        let phases = makeDefaultPhases(for: project)
        let phaseByType = phasesByType(phases)
        applyPhaseStatus(phaseByType[.preparation], .inProgress)

        let tasks: [Task] = [
            makeTask("量房", .completed, phaseByType[.preparation]),
            makeTask("预算评估", .inProgress, phaseByType[.preparation])
        ]

        let materials = [
            makeMaterial("墙面涂料", "立邦", "15L", 320, 2, "桶", .pending, "客厅", project)
        ]

        let contacts = [
            makeContact("王师傅", .foreman, "13700003333", "施工队", project)
        ]

        let journals = [
            makeJournal("量房完成", "初步沟通了布局与预算。", ["量房", "沟通"], -5, project)
        ]

        return ProjectBundle(
            project: project,
            budget: budget,
            expenses: expenses,
            phases: phases,
            tasks: tasks,
            materials: materials,
            contacts: contacts,
            journals: journals
        )
    }

    // MARK: - Project 3: 出租公寓（即将完工）

    private static func makeRentalApartmentBundle() -> ProjectBundle {
        let startDate = dateByAdding(days: -80)
        let project = Project(
            name: "出租公寓",
            houseType: "一室一厅",
            area: 45,
            startDate: startDate,
            estimatedDuration: 85,
            notes: "简装快装，控制成本",
            isActive: false
        )

        let budget = makeBudget(amount: 80000, warning: 0.85, project: project)

        let expenses = [
            makeExpense(4000, .design, -70, "简易设计", "张设计工作室", .fullPayment, budget),
            makeExpense(9000, .demolition, -65, "拆旧与清运", "拆改队", .fullPayment, budget),
            makeExpense(15000, .plumbing, -55, "水电改造", "水电工程公司", .deposit, budget),
            makeExpense(12000, .masonry, -40, "贴砖与找平", "王师傅瓦工队", .fullPayment, budget),
            makeExpense(18000, .cabinets, -15, "橱柜与门安装", "欧派橱柜", .deposit, budget)
        ]

        let phases = makeDefaultPhases(for: project)
        let phaseByType = phasesByType(phases)
        applyPhaseStatus(phaseByType[.preparation], .completed)
        applyPhaseStatus(phaseByType[.demolition], .completed)
        applyPhaseStatus(phaseByType[.plumbing], .completed)
        applyPhaseStatus(phaseByType[.masonry], .completed)
        applyPhaseStatus(phaseByType[.carpentry], .completed)
        applyPhaseStatus(phaseByType[.painting], .completed)
        applyPhaseStatus(phaseByType[.installation], .inProgress)

        // 禁用通风阶段（出租房不做长时间通风）
        if let ventilation = phaseByType[.ventilation] {
            ventilation.isEnabled = false
        }

        let tasks: [Task] = [
            makeTask("安装橱柜", .inProgress, phaseByType[.installation]),
            makeTask("安装门套", .pending, phaseByType[.installation])
        ]

        let materials = [
            makeMaterial("复合地板", "圣象", "12mm", 128, 40, "㎡", .delivered, "卧室", project),
            makeMaterial("厨房橱柜", "欧派", "定制", 12000, 1, "套", .ordered, "厨房", project)
        ]

        let contacts = [
            makeContact("刘工长", .foreman, "13600004444", "施工队", project)
        ]

        let journals = [
            makeJournal("安装阶段", "橱柜进场，准备安装。", ["安装", "橱柜"], -15, project)
        ]

        return ProjectBundle(
            project: project,
            budget: budget,
            expenses: expenses,
            phases: phases,
            tasks: tasks,
            materials: materials,
            contacts: contacts,
            journals: journals
        )
    }

    // MARK: - Project 4: 新婚小窝（已完工）

    private static func makeNewlywedHomeBundle() -> ProjectBundle {
        let startDate = dateByAdding(days: -120)
        let project = Project(
            name: "新婚小窝",
            houseType: "三室两厅",
            area: 110,
            startDate: startDate,
            estimatedDuration: 100,
            notes: "温馨舒适，已完工入住",
            isActive: false
        )

        let budget = makeBudget(amount: 160000, warning: 0.8, project: project)

        let expenses = [
            makeExpense(10000, .design, -110, "设计方案", "张设计工作室", .deposit, budget),
            makeExpense(8000, .demolition, -100, "拆改工程", "拆改队", .fullPayment, budget),
            makeExpense(22000, .plumbing, -90, "水电改造", "水电工程公司", .deposit, budget),
            makeExpense(16000, .masonry, -70, "贴砖工程", "王师傅瓦工队", .fullPayment, budget),
            makeExpense(12000, .painting, -50, "墙面乳胶漆", "多乐士专卖店", .fullPayment, budget),
            makeExpense(20000, .cabinets, -30, "安装阶段", "欧派橱柜", .deposit, budget),
            makeExpense(15000, .furniture, -10, "软装家具", "宜家", .fullPayment, budget)
        ]

        let phases = makeDefaultPhases(for: project)
        for phase in phases {
            applyPhaseStatus(phase, .completed)
        }

        let tasks: [Task] = [
            makeTask("验收完成", .completed, phases.last)
        ]

        let materials = [
            makeMaterial("定制衣柜", "索菲亚", "定制", 20000, 1, "套", .delivered, "主卧", project)
        ]

        let contacts = [
            makeContact("陈设计师", .designer, "13500005555", "设计工作室", project),
            makeContact("赵工长", .foreman, "13400006666", "施工队", project)
        ]

        let journals = [
            makeJournal("完工入住", "终于完工啦，准备入住。", ["完工", "入住"], -1, project)
        ]

        return ProjectBundle(
            project: project,
            budget: budget,
            expenses: expenses,
            phases: phases,
            tasks: tasks,
            materials: materials,
            contacts: contacts,
            journals: journals
        )
    }

    // MARK: - Builders

    private static func insert(bundle: ProjectBundle, into context: ModelContext) {
        context.insert(bundle.project)
        context.insert(bundle.budget)
        bundle.expenses.forEach { context.insert($0) }
        bundle.phases.forEach { context.insert($0) }
        bundle.tasks.forEach { context.insert($0) }
        bundle.materials.forEach { context.insert($0) }
        bundle.contacts.forEach { context.insert($0) }
        bundle.journals.forEach { context.insert($0) }
    }

    private static func makeBudget(amount: Decimal, warning: Double, project: Project) -> Budget {
        let budget = Budget(totalAmount: amount, warningThreshold: warning)
        budget.project = project
        project.budget = budget
        return budget
    }

    private static func makeExpense(
        _ amount: Decimal,
        _ category: ExpenseCategory,
        _ daysOffset: Int,
        _ notes: String,
        _ vendor: String,
        _ paymentType: PaymentType,
        _ budget: Budget
    ) -> Expense {
        let expense = Expense(
            amount: amount,
            category: category,
            date: dateByAdding(days: daysOffset),
            notes: notes,
            paymentType: paymentType,
            vendor: vendor
        )
        expense.budget = budget
        budget.addExpense(expense)
        return expense
    }

    private static func makeDefaultPhases(for project: Project) -> [Phase] {
        let phaseTypes: [PhaseType] = [
            .preparation,
            .demolition,
            .plumbing,
            .masonry,
            .carpentry,
            .painting,
            .installation,
            .softDecoration,
            .cleaning,
            .ventilation
        ]

        var currentDate = project.startDate
        var phases: [Phase] = []

        for phaseType in phaseTypes {
            let duration = phaseType.estimatedDays
            let endDate = Calendar.current.date(byAdding: .day, value: duration, to: currentDate) ?? currentDate

            let phase = Phase(
                name: phaseType.displayName,
                type: phaseType,
                sortOrder: phaseType.sortOrder,
                plannedStartDate: currentDate,
                plannedEndDate: endDate,
                notes: phaseType.description
            )

            phase.project = project
            project.addPhase(phase)
            phases.append(phase)

            currentDate = endDate
        }

        return phases
    }

    private static func phasesByType(_ phases: [Phase]) -> [PhaseType: Phase] {
        var result: [PhaseType: Phase] = [:]
        for phase in phases {
            result[phase.type] = phase
        }
        return result
    }

    private static func applyPhaseStatus(_ phase: Phase?, _ status: PhaseStatus) {
        guard let phase = phase else { return }
        switch status {
        case .pending:
            break
        case .inProgress:
            phase.actualStartDate = phase.plannedStartDate
        case .completed:
            phase.actualStartDate = phase.plannedStartDate
            phase.actualEndDate = phase.plannedEndDate
            phase.isCompleted = true
        }
    }

    private static func makeTask(_ title: String, _ status: TaskStatus, _ phase: Phase?) -> Task {
        let task = Task(
            title: title,
            taskDescription: "",
            status: status,
            assignee: "",
            assigneeContact: "",
            plannedStartDate: phase?.plannedStartDate,
            plannedEndDate: phase?.plannedEndDate
        )

        if status == .completed {
            task.actualCompletionDate = phase?.plannedEndDate ?? Date()
        }

        if let phase = phase {
            task.phase = phase
            phase.addTask(task)
            phase.syncStatusFromTasks()
        }

        return task
    }

    private static func makeMaterial(
        _ name: String,
        _ brand: String,
        _ specification: String,
        _ unitPrice: Decimal,
        _ quantity: Double,
        _ unit: String,
        _ status: MaterialStatus,
        _ location: String,
        _ project: Project
    ) -> Material {
        let material = Material(
            name: name,
            brand: brand,
            specification: specification,
            unitPrice: unitPrice,
            quantity: quantity,
            unit: unit,
            status: status,
            location: location
        )
        material.project = project
        project.addMaterial(material)
        return material
    }

    private static func makeContact(
        _ name: String,
        _ role: ContactRole,
        _ phone: String,
        _ company: String,
        _ project: Project
    ) -> Contact {
        let contact = Contact(
            name: name,
            role: role,
            phoneNumber: phone,
            company: company
        )
        contact.project = project
        project.addContact(contact)
        return contact
    }

    private static func makeJournal(
        _ title: String,
        _ content: String,
        _ tags: [String],
        _ daysOffset: Int,
        _ project: Project
    ) -> JournalEntry {
        let entry = JournalEntry(
            title: title,
            content: content,
            tags: tags,
            date: dateByAdding(days: daysOffset)
        )
        entry.project = project
        project.addJournalEntry(entry)
        return entry
    }

    private static func dateByAdding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }
}
