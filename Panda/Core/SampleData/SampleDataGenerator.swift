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
        // 清除现有数据
        clearAllData(in: context)

        // 创建多个测试项目
        let projects = [
            createMyHomeProject(),
            createParentsHomeProject(),
            createRentalApartmentProject(),
            createNewlywedHomeProject()
        ]

        // 插入项目
        for project in projects {
            context.insert(project)
        }

        try? context.save()
        print("✅ 测试数据生成完成，共创建 \(projects.count) 个项目")
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

    // MARK: - Project 1: 我的家（进行中，50%进度）

    private static func createMyHomeProject() -> Project {
        let startDate = Calendar.current.date(byAdding: .day, value: -45, to: Date())!

        let project = Project(
            name: "我的家",
            houseType: "三室两厅",
            area: 120,
            startDate: startDate,
            estimatedDuration: 90,
            notes: "新房装修，北欧简约风格",
            isActive: true
        )

        // 添加预算
        let budget = Budget(totalAmount: 180000, warningThreshold: 0.8)
        project.budget = budget

        // 添加支出记录
        let expenses = createExpensesForMyHome(startDate: startDate)
        for expense in expenses {
            budget.addExpense(expense)
        }

        // 添加装修阶段
        let phases = createPhasesForMyHome(startDate: startDate)
        for phase in phases {
            project.addPhase(phase)
        }

        // 添加联系人
        let contacts = createContactsForMyHome()
        for contact in contacts {
            project.addContact(contact)
        }

        return project
    }

    private static func createExpensesForMyHome(startDate: Date) -> [Expense] {
        var expenses: [Expense] = []

        // 设计费
        expenses.append(Expense(
            amount: 8000,
            category: .design,
            date: startDate,
            notes: "全屋设计方案"
        ))

        // 拆改费用
        expenses.append(Expense(
            amount: 5500,
            category: .demolition,
            date: Calendar.current.date(byAdding: .day, value: 15, to: startDate)!,
            notes: "客厅阳台打通"
        ))

        // 水电
        expenses.append(Expense(
            amount: 20000,
            category: .plumbing,
            date: Calendar.current.date(byAdding: .day, value: 20, to: startDate)!,
            notes: "全屋水电改造（材料+人工）"
        ))

        // 瓷砖/地板
        expenses.append(Expense(
            amount: 15000,
            category: .flooring,
            date: Calendar.current.date(byAdding: .day, value: 30, to: startDate)!,
            notes: "客厅+厨卫瓷砖"
        ))

        // 泥瓦
        expenses.append(Expense(
            amount: 9000,
            category: .masonry,
            date: Calendar.current.date(byAdding: .day, value: 35, to: startDate)!,
            notes: "贴砖人工费"
        ))

        // 木工
        expenses.append(Expense(
            amount: 18000,
            category: .carpentry,
            date: Calendar.current.date(byAdding: .day, value: 40, to: startDate)!,
            notes: "吊顶+柜体板材"
        ))

        return expenses
    }

    private static func createPhasesForMyHome(startDate: Date) -> [Phase] {
        var phases: [Phase] = []
        var currentDate = startDate

        // 前期准备 - 已完成
        let preparation = Phase(
            name: "前期准备",
            type: .preparation,
            sortOrder: 1,
            plannedStartDate: currentDate,
            plannedEndDate: Calendar.current.date(byAdding: .day, value: 14, to: currentDate)!
        )
        preparation.actualStartDate = currentDate
        preparation.actualEndDate = Calendar.current.date(byAdding: .day, value: 12, to: currentDate)!
        preparation.isCompleted = true
        phases.append(preparation)

        currentDate = Calendar.current.date(byAdding: .day, value: 14, to: currentDate)!

        // 拆改阶段 - 已完成
        let demolition = Phase(
            name: "拆改阶段",
            type: .demolition,
            sortOrder: 2,
            plannedStartDate: currentDate,
            plannedEndDate: Calendar.current.date(byAdding: .day, value: 5, to: currentDate)!
        )
        demolition.actualStartDate = currentDate
        demolition.actualEndDate = Calendar.current.date(byAdding: .day, value: 4, to: currentDate)!
        demolition.isCompleted = true
        phases.append(demolition)

        currentDate = Calendar.current.date(byAdding: .day, value: 5, to: currentDate)!

        // 水电改造 - 已完成
        let plumbing = Phase(
            name: "水电改造",
            type: .plumbing,
            sortOrder: 3,
            plannedStartDate: currentDate,
            plannedEndDate: Calendar.current.date(byAdding: .day, value: 10, to: currentDate)!
        )
        plumbing.actualStartDate = currentDate
        plumbing.actualEndDate = Calendar.current.date(byAdding: .day, value: 10, to: currentDate)!
        plumbing.isCompleted = true
        phases.append(plumbing)

        currentDate = Calendar.current.date(byAdding: .day, value: 10, to: currentDate)!

        // 泥瓦工程 - 进行中
        let masonry = Phase(
            name: "泥瓦工程",
            type: .masonry,
            sortOrder: 4,
            plannedStartDate: currentDate,
            plannedEndDate: Calendar.current.date(byAdding: .day, value: 15, to: currentDate)!
        )
        masonry.actualStartDate = currentDate
        phases.append(masonry)

        currentDate = Calendar.current.date(byAdding: .day, value: 15, to: currentDate)!

        // 木工工程 - 待开始
        let carpentry = Phase(
            name: "木工工程",
            type: .carpentry,
            sortOrder: 5,
            plannedStartDate: currentDate,
            plannedEndDate: Calendar.current.date(byAdding: .day, value: 15, to: currentDate)!
        )
        phases.append(carpentry)

        currentDate = Calendar.current.date(byAdding: .day, value: 15, to: currentDate)!

        // 油漆工程 - 待开始
        let painting = Phase(
            name: "油漆工程",
            type: .painting,
            sortOrder: 6,
            plannedStartDate: currentDate,
            plannedEndDate: Calendar.current.date(byAdding: .day, value: 10, to: currentDate)!
        )
        phases.append(painting)

        return phases
    }

    private static func createContactsForMyHome() -> [Contact] {
        [
            Contact(name: "王师傅", role: .foreman, phoneNumber: "138-1234-5678", notes: "整体施工负责人"),
            Contact(name: "李设计师", role: .designer, phoneNumber: "139-8765-4321", notes: "室内设计"),
            Contact(name: "张电工", role: .electrician, phoneNumber: "137-1111-2222", notes: "水电改造")
        ]
    }

    // MARK: - Project 2: 爸妈的房子（刚开始，10%进度）

    private static func createParentsHomeProject() -> Project {
        let startDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!

        let project = Project(
            name: "爸妈的房子",
            houseType: "两室一厅",
            area: 85,
            startDate: startDate,
            estimatedDuration: 60,
            notes: "适老化装修，注重安全和便利性",
            isActive: true
        )

        // 添加预算
        let budget = Budget(totalAmount: 100000, warningThreshold: 0.8)
        project.budget = budget

        // 添加少量支出
        budget.addExpense(Expense(
            amount: 5000,
            category: .design,
            date: startDate,
            notes: "设计方案费"
        ))

        budget.addExpense(Expense(
            amount: 2000,
            category: .other,
            date: Calendar.current.date(byAdding: .day, value: 3, to: startDate)!,
            notes: "前期勘测费"
        ))

        // 添加阶段 - 只有前期准备进行中
        let preparation = Phase(
            name: "前期准备",
            type: .preparation,
            sortOrder: 1,
            plannedStartDate: startDate,
            plannedEndDate: Calendar.current.date(byAdding: .day, value: 14, to: startDate)!
        )
        preparation.actualStartDate = startDate
        project.addPhase(preparation)

        // 添加后续阶段（待开始）
        var currentDate = Calendar.current.date(byAdding: .day, value: 14, to: startDate)!

        for phaseType in [PhaseType.demolition, .plumbing, .masonry, .painting, .installation] {
            let phase = Phase(
                name: phaseType.displayName,
                type: phaseType,
                sortOrder: phaseType.sortOrder,
                plannedStartDate: currentDate,
                plannedEndDate: Calendar.current.date(byAdding: .day, value: phaseType.estimatedDays, to: currentDate)!
            )
            project.addPhase(phase)
            currentDate = Calendar.current.date(byAdding: .day, value: phaseType.estimatedDays, to: currentDate)!
        }

        return project
    }

    // MARK: - Project 3: 出租公寓（即将完工，85%进度）

    private static func createRentalApartmentProject() -> Project {
        let startDate = Calendar.current.date(byAdding: .day, value: -75, to: Date())!

        let project = Project(
            name: "出租公寓",
            houseType: "一室一厅",
            area: 50,
            startDate: startDate,
            estimatedDuration: 45,
            notes: "简装出租，控制成本",
            isActive: true
        )

        // 添加预算（接近预警线）
        let budget = Budget(totalAmount: 50000, warningThreshold: 0.8)
        project.budget = budget

        // 添加支出（已花费约 78%）
        let expenseData: [(Decimal, ExpenseCategory, String)] = [
            (3000, .design, "简单设计"),
            (2000, .demolition, "局部拆改"),
            (9000, .plumbing, "水电改造"),
            (6000, .flooring, "瓷砖"),
            (4000, .masonry, "贴砖人工"),
            (8000, .carpentry, "木工"),
            (4000, .painting, "乳胶漆"),
            (3000, .other, "杂项")
        ]

        var dayOffset = 0
        for (amount, category, note) in expenseData {
            budget.addExpense(Expense(
                amount: amount,
                category: category,
                date: Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!,
                notes: note
            ))
            dayOffset += 7
        }

        // 添加已完成的阶段
        var currentDate = startDate

        for phaseType in [PhaseType.preparation, .demolition, .plumbing, .masonry, .carpentry, .painting] {
            let phase = Phase(
                name: phaseType.displayName,
                type: phaseType,
                sortOrder: phaseType.sortOrder,
                plannedStartDate: currentDate,
                plannedEndDate: Calendar.current.date(byAdding: .day, value: phaseType.estimatedDays, to: currentDate)!
            )
            phase.actualStartDate = currentDate
            phase.actualEndDate = Calendar.current.date(byAdding: .day, value: phaseType.estimatedDays - 1, to: currentDate)!
            phase.isCompleted = true
            project.addPhase(phase)
            currentDate = Calendar.current.date(byAdding: .day, value: phaseType.estimatedDays, to: currentDate)!
        }

        // 安装阶段 - 进行中
        let installation = Phase(
            name: "安装阶段",
            type: .installation,
            sortOrder: 7,
            plannedStartDate: currentDate,
            plannedEndDate: Calendar.current.date(byAdding: .day, value: 10, to: currentDate)!
        )
        installation.actualStartDate = currentDate
        project.addPhase(installation)

        return project
    }

    // MARK: - Project 4: 新婚小窝（已完工）

    private static func createNewlywedHomeProject() -> Project {
        let startDate = Calendar.current.date(byAdding: .month, value: -4, to: Date())!

        let project = Project(
            name: "新婚小窝",
            houseType: "两室两厅",
            area: 95,
            startDate: startDate,
            estimatedDuration: 75,
            notes: "婚房装修，浪漫温馨风格，已顺利完工入住",
            isActive: false
        )

        // 添加预算（略超预算）
        let budget = Budget(totalAmount: 150000, warningThreshold: 0.8)
        project.budget = budget

        // 添加完整的支出记录
        let expenseData: [(Decimal, ExpenseCategory, String)] = [
            (12000, .design, "全屋设计"),
            (4000, .demolition, "拆改工程"),
            (25000, .plumbing, "水电改造"),
            (18000, .flooring, "全屋瓷砖"),
            (12000, .masonry, "泥瓦人工"),
            (25000, .carpentry, "定制柜体"),
            (10000, .painting, "油漆工程"),
            (15000, .doors, "室内门+入户门"),
            (12000, .cabinets, "橱柜"),
            (6000, .bathroom, "卫浴洁具"),
            (8000, .lighting, "灯具"),
            (8000, .furniture, "部分家具")
        ]

        var dayOffset = 0
        for (amount, category, note) in expenseData {
            budget.addExpense(Expense(
                amount: amount,
                category: category,
                date: Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!,
                notes: note
            ))
            dayOffset += 5
        }

        // 添加全部已完成的阶段
        var currentDate = startDate

        let allPhaseTypes: [PhaseType] = [
            .preparation, .demolition, .plumbing, .masonry,
            .carpentry, .painting, .installation, .softDecoration, .cleaning
        ]

        for phaseType in allPhaseTypes {
            let phase = Phase(
                name: phaseType.displayName,
                type: phaseType,
                sortOrder: phaseType.sortOrder,
                plannedStartDate: currentDate,
                plannedEndDate: Calendar.current.date(byAdding: .day, value: phaseType.estimatedDays, to: currentDate)!
            )
            phase.actualStartDate = currentDate
            phase.actualEndDate = Calendar.current.date(byAdding: .day, value: phaseType.estimatedDays, to: currentDate)!
            phase.isCompleted = true
            project.addPhase(phase)
            currentDate = Calendar.current.date(byAdding: .day, value: phaseType.estimatedDays, to: currentDate)!
        }

        return project
    }
}
