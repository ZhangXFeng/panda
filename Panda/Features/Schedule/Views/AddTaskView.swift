//
//  AddTaskView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddTaskViewModel

    init(modelContext: ModelContext, task: Task? = nil, phase: Phase? = nil) {
        _viewModel = StateObject(wrappedValue: AddTaskViewModel(
            modelContext: modelContext,
            task: task,
            phase: phase
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                // Basic info
                Section("基本信息") {
                    TextField("任务标题", text: $viewModel.title)
                        .autocorrectionDisabled()

                    Picker("状态", selection: $viewModel.status) {
                        ForEach(TaskStatus.allCases) { status in
                            HStack {
                                Image(systemName: status.iconName)
                                Text(status.displayName)
                            }
                            .tag(status)
                        }
                    }
                }

                // Description
                Section("任务描述") {
                    TextEditor(text: $viewModel.taskDescription)
                        .frame(minHeight: 100)
                }

                // Schedule
                Section("时间安排") {
                    DatePicker("计划开始", selection: $viewModel.plannedStartDate, displayedComponents: .date)
                    DatePicker("计划结束", selection: $viewModel.plannedEndDate, displayedComponents: .date)
                }

                // Assignee
                Section("负责人") {
                    TextField("姓名", text: $viewModel.assignee)
                        .autocorrectionDisabled()
                    TextField("联系方式（可选）", text: $viewModel.assigneeContact)
                        .keyboardType(.phonePad)
                        .autocorrectionDisabled()
                }

                // Photos
                Section {
                    PhotosPicker(
                        selection: $viewModel.selectedPhotos,
                        maxSelectionCount: 9,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(Colors.primary)
                            Text("选择照片")
                            Spacer()
                            if !viewModel.photoData.isEmpty {
                                Text("\(viewModel.photoData.count) 张")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onChange(of: viewModel.selectedPhotos) { _, _ in
                        _Concurrency.Task {
                            await viewModel.loadSelectedPhotos()
                        }
                    }

                    if !viewModel.photoData.isEmpty {
                        photoGrid
                    }
                } header: {
                    Text("照片")
                } footer: {
                    Text("施工照片、验收照片等")
                }

                // Quick actions (edit mode only)
                if viewModel.isEditMode {
                    Section("快捷操作") {
                        Button {
                            viewModel.markAsInProgress()
                        } label: {
                            Label("标记为进行中", systemImage: "play.circle")
                        }

                        Button {
                            viewModel.markAsCompleted()
                        } label: {
                            Label("标记为已完成", systemImage: "checkmark.circle")
                        }

                        Button {
                            viewModel.markAsIssue()
                        } label: {
                            Label("标记为有问题", systemImage: "exclamationmark.triangle")
                                .foregroundColor(Colors.warning)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.title_)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .alert("错误", isPresented: $viewModel.showingError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    // MARK: - Photo Grid

    private var photoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: Spacing.sm) {
            ForEach(Array(viewModel.photoData.enumerated()), id: \.offset) { index, data in
                if let uiImage = UIImage(data: data) {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))

                        Button {
                            viewModel.removePhoto(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding(4)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Add Task") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Phase.self, Task.self, configurations: config)

    let phase = Phase(
        name: "水电改造",
        type: .plumbing,
        sortOrder: 1,
        plannedStartDate: Date(),
        plannedEndDate: Date().addingTimeInterval(86400 * 15)
    )

    return AddTaskView(modelContext: container.mainContext, phase: phase)
        .modelContainer(container)
}

#Preview("Edit Task") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Phase.self, Task.self, configurations: config)

    let task = Task(
        title: "水管布线",
        taskDescription: "冷热水管布线，确保间距符合规范",
        status: .inProgress,
        assignee: "张师傅",
        assigneeContact: "13800138000",
        plannedStartDate: Date(),
        plannedEndDate: Date().addingTimeInterval(86400 * 3)
    )

    return AddTaskView(modelContext: container.mainContext, task: task)
        .modelContainer(container)
}
