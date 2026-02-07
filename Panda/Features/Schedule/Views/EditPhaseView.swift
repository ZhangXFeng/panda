//
//  EditPhaseView.swift
//  Panda
//
//  Created on 2026-02-07.
//

import SwiftUI
import SwiftData

struct EditPhaseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let phase: Phase

    @State private var name: String
    @State private var plannedStartDate: Date
    @State private var plannedEndDate: Date
    @State private var notes: String

    @State private var showingError = false
    @State private var errorMessage = ""

    init(phase: Phase) {
        self.phase = phase
        _name = State(initialValue: phase.name)
        _plannedStartDate = State(initialValue: phase.plannedStartDate)
        _plannedEndDate = State(initialValue: phase.plannedEndDate)
        _notes = State(initialValue: phase.notes)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("阶段信息") {
                    TextField("阶段名称", text: $name)
                        .autocorrectionDisabled()

                    TextField("备注（可选）", text: $notes)
                        .autocorrectionDisabled()
                }

                Section("计划时间") {
                    DatePicker("开始日期", selection: $plannedStartDate, displayedComponents: .date)
                    DatePicker("结束日期", selection: $plannedEndDate, displayedComponents: .date)
                }
            }
            .navigationTitle("编辑阶段")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                }
            }
            .alert("错误", isPresented: $showingError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errorMessage = "请填写阶段名称"
            showingError = true
            return
        }

        if plannedEndDate < plannedStartDate {
            errorMessage = "结束日期不能早于开始日期"
            showingError = true
            return
        }

        phase.name = trimmedName
        phase.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        phase.plannedStartDate = plannedStartDate
        phase.plannedEndDate = plannedEndDate
        phase.updateTimestamp()

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "保存失败: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Phase.self, configurations: config)
    let phase = Phase(
        name: "水电阶段",
        type: .plumbing,
        sortOrder: 2,
        plannedStartDate: Date(),
        plannedEndDate: Date().addingTimeInterval(86400 * 10)
    )
    container.mainContext.insert(phase)

    return EditPhaseView(phase: phase)
        .modelContainer(container)
}
