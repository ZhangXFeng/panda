//
//  TestDataGenerator.swift
//  Panda
//
//  Created on 2026-02-02.
//

import Foundation
import SwiftData

@MainActor
class TestDataGenerator {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func generateTestData() throws {
        // 创建项目
        let project = createTestProject()
        modelContext.insert(project)

        // 创建预算
        let budget = createTestBudget()
        budget.project = project
        project.budget = budget
        modelContext.insert(budget)

        // 创建支出记录
        let expenses = createTestExpenses(for: budget)
        expenses.forEach { modelContext.insert($0) }

        // 创建装修阶段（带任务）
        let phases = createTestPhases(for: project)
        phases.forEach { phase in
            modelContext.insert(phase)
            project.addPhase(phase)
        }

        // 创建材料清单
        let materials = createTestMaterials(for: project)
        materials.forEach { material in
            modelContext.insert(material)
            project.addMaterial(material)
        }

        // 创建联系人
        let contacts = createTestContacts(for: project)
        contacts.forEach { contact in
            modelContext.insert(contact)
            project.addContact(contact)
        }

        // 创建装修日记
        let journals = createTestJournals(for: project)
        journals.forEach { journal in
            modelContext.insert(journal)
            project.addJournalEntry(journal)
        }

        // 保存所有数据
        try modelContext.save()
    }

    // MARK: - Project

    private func createTestProject() -> Project {
        let project = Project(
            name: "温馨小家装修",
            houseType: "三室两厅一卫",
            area: 95.0,
            startDate: Calendar.current.date(byAdding: .day, value: -45, to: Date())!,
            estimatedDuration: 90,
            notes: "简约现代风格，注重环保材料",
            isActive: true
        )
        return project
    }

    // MARK: - Budget & Expenses

    private func createTestBudget() -> Budget {
        Budget(totalAmount: 180000, warningThreshold: 0.85)
    }

    private func createTestExpenses(for budget: Budget) -> [Expense] {
        let expensesData: [(Decimal, ExpenseCategory, String, String, Int)] = [
            (8000, .design, "设计费用", "张设计工作室", -40),
            (12000, .demolition, "拆除及垃圾清理", "李师傅施工队", -38),
            (25000, .plumbing, "水电改造材料及人工", "水电工程公司", -30),
            (15000, .flooring, "客厅卧室地板", "大自然地板", -25),
            (8500, .masonry, "瓷砖铺贴人工费", "王师傅瓦工队", -20),
            (6800, .painting, "墙面乳胶漆", "多乐士专卖店", -15),
            (18000, .cabinets, "定制橱柜", "欧派橱柜", -10),
            (4500, .bathroom, "卫浴五金套装", "九牧卫浴", -8),
            (3200, .lighting, "全屋灯具", "雷士照明", -5),
            (2800, .doors, "卧室门", "TATA木门", -3)
        ]

        return expensesData.map { amount, category, notes, vendor, daysAgo in
            let expense = Expense(
                amount: amount,
                category: category,
                date: Calendar.current.date(byAdding: .day, value: daysAgo, to: Date())!,
                notes: notes,
                paymentType: amount > 10000 ? .deposit : .fullPayment,
                vendor: vendor
            )
            budget.addExpense(expense)
            return expense
        }
    }

    // MARK: - Phases

    private func createTestPhases(for project: Project) -> [Phase] {
        let phaseTypes: [(PhaseType, Bool, Int, Int)] = [
            (.preparation, true, -45, -31),
            (.demolition, true, -30, -26),
            (.plumbing, true, -25, -16),
            (.masonry, true, -15, -8),
            (.carpentry, false, -7, 5),
            (.painting, false, 6, 16),
            (.installation, false, 17, 27),
            (.softDecoration, false, 28, 35),
            (.cleaning, false, 36, 39),
            (.ventilation, false, 40, 70)
        ]

        let calendar = Calendar.current
        var phases: [Phase] = []

        for (index, (type, isCompleted, startOffset, endOffset)) in phaseTypes.enumerated() {
            let startDate = calendar.date(byAdding: .day, value: startOffset, to: Date())!
            let endDate = calendar.date(byAdding: .day, value: endOffset, to: Date())!

            let phase = Phase(
                name: type.displayName,
                type: type,
                sortOrder: index + 1,
                plannedStartDate: startDate,
                plannedEndDate: endDate,
                notes: type.description
            )

            if isCompleted {
                phase.actualStartDate = startDate
                phase.actualEndDate = calendar.date(byAdding: .day, value: -1, to: endDate)
                phase.isCompleted = true
            } else if startOffset < 0 {
                // 进行中的阶段
                phase.actualStartDate = startDate
            }

            phases.append(phase)
        }

        return phases
    }

    // MARK: - Materials

    private func createTestMaterials(for project: Project) -> [Material] {
        let materialsData: [(String, String, String, Decimal, Double, String, MaterialStatus, String)] = [
            ("客厅地砖", "马可波罗", "800x800mm 亚光", 89, 65, "㎡", .installed, "客厅"),
            ("卧室木地板", "大自然", "强化复合 12mm", 168, 38, "㎡", .installed, "主卧"),
            ("乳胶漆", "多乐士", "5合1二代 18L", 428, 8, "桶", .installed, "全屋"),
            ("卫生间瓷砖", "诺贝尔", "300x600mm", 45, 28, "㎡", .installed, "卫生间"),
            ("厨房吊柜", "欧派", "2.8米 上下柜", 6800, 1, "套", .delivered, "厨房"),
            ("入户门", "盼盼防盗门", "子母门 2050x1260", 2800, 1, "樘", .purchased, "入户"),
            ("卧室门", "TATA木门", "实木复合 2100x800", 1580, 3, "樘", .delivered, "卧室"),
            ("马桶", "九牧", "智能马桶 喷射虹吸", 2680, 1, "个", .delivered, "卫生间"),
            ("花洒套装", "九牧", "恒温花洒龙头", 980, 1, "套", .delivered, "卫生间"),
            ("客厅吊灯", "雷士照明", "LED智能吊灯", 1280, 1, "个", .pending, "客厅"),
            ("筒灯", "雷士照明", "LED筒灯 5W", 35, 12, "个", .pending, "全屋"),
            ("开关插座", "施耐德", "绎尚系列", 28, 45, "个", .installed, "全屋")
        ]

        return materialsData.map { name, brand, spec, price, qty, unit, status, location in
            Material(
                name: name,
                brand: brand,
                specification: spec,
                unitPrice: price,
                quantity: qty,
                unit: unit,
                status: status,
                location: location
            )
        }
    }

    // MARK: - Contacts

    private func createTestContacts(for project: Project) -> [Contact] {
        let contactsData: [(String, ContactRole, String, String, String, Int)] = [
            ("张设计师", .designer, "13800138001", "雅致空间设计", "负责全屋设计方案", 5),
            ("李工长", .foreman, "13800138002", "诚信装修队", "总工长，经验丰富", 5),
            ("王瓦工", .mason, "13800138003", "", "手艺好，认真负责", 5),
            ("马水电工", .electrician, "13800138004", "", "水电改造专业", 4),
            ("陈木工", .carpenter, "13800138005", "", "吊顶橱柜制作", 5),
            ("刘油漆工", .painter, "13800138006", "", "墙面处理专业", 4),
            ("欧派橱柜", .vendor, "13900139001", "欧派定制家居", "橱柜定制", 5),
            ("大自然地板", .vendor, "13900139002", "大自然家居", "地板供应", 5),
            ("多乐士专卖", .vendor, "13900139003", "多乐士专卖店", "涂料供应", 4)
        ]

        return contactsData.map { name, role, phone, company, notes, rating in
            let contact = Contact(
                name: name,
                role: role,
                phoneNumber: phone,
                company: company,
                rating: rating
            )
            contact.notes = notes
            return contact
        }
    }

    // MARK: - Journals

    private func createTestJournals(for project: Project) -> [JournalEntry] {
        let journalsData: [(String, String, [String], Int)] = [
            ("开工大吉", "今天正式开工了！上午进行了开工仪式，下午开始拆除工作。心情激动又紧张，期待新家的样子。", ["开工", "拆除"], -40),
            ("水电改造进行中", "水电师傅很专业，按照设计图纸开槽布线。厨房和卫生间的水路改造比较复杂，师傅很耐心地跟我解释每一处的改动。", ["水电", "改造"], -28),
            ("瓷砖铺贴", "今天去看了瓷砖铺贴的进度，王师傅的手艺真不错，贴得整整齐齐。卫生间的墙砖选的小花砖效果很好看。", ["瓷砖", "卫生间"], -18),
            ("橱柜测量", "欧派的设计师来复测尺寸了，根据现场情况微调了一些细节。上柜加了几个拉篮，实用性更强了。", ["橱柜", "测量"], -12),
            ("墙面刷漆", "工人开始刷乳胶漆了，选的多乐士米白色，效果温馨自然。注意通风，味道还是有点的。", ["乳胶漆", "刷漆"], -6),
            ("地板安装", "大自然的安装师傅很专业，地板铺得很平整。走在上面的感觉真好，终于有家的样子了！", ["地板", "安装"], -2)
        ]

        return journalsData.map { title, content, tags, daysAgo in
            JournalEntry(
                title: title,
                content: content,
                tags: tags,
                date: Calendar.current.date(byAdding: .day, value: daysAgo, to: Date())!
            )
        }
    }
}
