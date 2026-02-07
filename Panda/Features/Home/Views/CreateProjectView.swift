//
//  CreateProjectView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct CreateProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var projectName = ""
    @State private var houseType = ""
    @State private var area = ""
    @State private var startDate = Date()
    @State private var estimatedDuration = "90"
    @State private var totalBudget = ""
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // 基本信息
                Section("基本信息") {
                    TextField("项目名称", text: $projectName, prompt: Text("例如：我的新家"))

                    TextField("房屋类型", text: $houseType, prompt: Text("例如：三室两厅"))

                    HStack {
                        TextField("建筑面积", text: $area, prompt: Text("100"))
                            .keyboardType(.decimalPad)
                        Text("㎡")
                            .foregroundColor(.textSecondary)
                    }
                }

                // 时间规划
                Section("时间规划") {
                    DatePicker("开工日期", selection: $startDate, displayedComponents: .date)

                    HStack {
                        TextField("预计工期", text: $estimatedDuration, prompt: Text("90"))
                            .keyboardType(.numberPad)
                        Text("天")
                            .foregroundColor(.textSecondary)
                    }
                }

                // 预算设置
                Section("预算设置") {
                    HStack {
                        Text("¥")
                            .foregroundColor(.textSecondary)
                        TextField("总预算", text: $totalBudget, prompt: Text("180000"))
                            .keyboardType(.decimalPad)
                    }

                    Text("建议预算：中档装修约 1500-2000 元/㎡")
                        .font(.captionRegular)
                        .foregroundColor(.textHint)
                }

                // 备注
                Section("备注（可选）") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("创建项目")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("取消") {
                    dismiss()
                },
                trailing: Button("创建") {
                    createProject()
                }
                .disabled(!isFormValid)
            )
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !projectName.isEmpty &&
        !houseType.isEmpty &&
        !area.isEmpty &&
        !estimatedDuration.isEmpty &&
        !totalBudget.isEmpty
    }

    // MARK: - Methods

    private func createProject() {
        // 验证输入
        guard let areaValue = Double(area), areaValue > 0 else {
            alertMessage = "请输入有效的建筑面积"
            showingAlert = true
            return
        }

        guard let durationValue = Int(estimatedDuration), durationValue > 0 else {
            alertMessage = "请输入有效的工期天数"
            showingAlert = true
            return
        }

        guard let budgetValue = Decimal(string: totalBudget), budgetValue > 0 else {
            alertMessage = "请输入有效的预算金额"
            showingAlert = true
            return
        }

        // 创建项目
        let project = Project(
            name: projectName,
            houseType: houseType,
            area: areaValue,
            startDate: startDate,
            estimatedDuration: durationValue,
            notes: notes,
            isActive: true
        )

        // 创建预算
        let budget = Budget(totalAmount: budgetValue)
        project.budget = budget
        budget.project = project

        // 保存到数据库
        modelContext.insert(project)
        modelContext.insert(budget)

        // 创建预设装修阶段
        createDefaultPhases(for: project)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "保存失败：\(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func createDefaultPhases(for project: Project) {
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

        var currentDate = startDate
        let calendar = Calendar.current

        for phaseType in phaseTypes {
            let duration = phaseType.estimatedDays
            guard let endDate = calendar.date(byAdding: .day, value: duration, to: currentDate) else {
                continue
            }

            let phase = Phase(
                name: phaseType.displayName,
                type: phaseType,
                sortOrder: phaseType.sortOrder,
                plannedStartDate: currentDate,
                plannedEndDate: endDate,
                notes: phaseType.description
            )

            // 插入到数据库
            modelContext.insert(phase)
            project.addPhase(phase)

            // 下一个阶段从当前阶段结束日期开始
            currentDate = endDate
        }
    }
}

// MARK: - Preview

#Preview {
    CreateProjectView()
        .modelContainer(for: [Project.self, Budget.self, Phase.self], inMemory: true)
}
