//
//  AddProjectView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddProjectViewModel

    init(modelContext: ModelContext, project: Project? = nil) {
        _viewModel = StateObject(wrappedValue: AddProjectViewModel(
            modelContext: modelContext,
            project: project
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                // Basic info
                Section("基本信息") {
                    TextField("项目名称", text: $viewModel.name)
                        .autocorrectionDisabled()

                    Picker("房屋类型", selection: $viewModel.houseType) {
                        ForEach(AddProjectViewModel.houseTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }

                    HStack {
                        Text("建筑面积")
                        Spacer()
                        TextField("面积", value: $viewModel.area, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("㎡")
                            .foregroundColor(Colors.textSecondary)
                    }
                }

                // Timeline
                Section("时间规划") {
                    DatePicker("开工日期", selection: $viewModel.startDate, displayedComponents: .date)

                    HStack {
                        Stepper("预计工期", value: $viewModel.estimatedDuration, in: 30...365, step: 15)
                        Spacer()
                        Text("\(viewModel.estimatedDuration) 天")
                            .foregroundColor(Colors.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("预计完工")
                            .font(Fonts.caption)
                            .foregroundColor(Colors.textSecondary)
                        Text(formatDate(viewModel.estimatedEndDate))
                            .font(Fonts.headline)
                    }
                }

                // Cover image
                Section {
                    if let imageData = viewModel.coverImageData,
                       let uiImage = UIImage(data: imageData) {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))

                            Button {
                                viewModel.removeCoverImage()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                                    .padding(8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        PhotosPicker(
                            selection: $viewModel.selectedPhoto,
                            matching: .images
                        ) {
                            HStack {
                                Image(systemName: "photo")
                                    .foregroundColor(Colors.primary)
                                Text("选择封面图片")
                                Spacer()
                            }
                        }
                        .onChange(of: viewModel.selectedPhoto) { _, _ in
                            _Concurrency.Task {
                                await viewModel.loadSelectedPhoto()
                            }
                        }
                    }
                } header: {
                    Text("封面图片")
                } footer: {
                    Text("选择一张代表此项目的照片")
                }

                // Notes
                Section("备注") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                }

                // Status (edit mode only)
                if viewModel.isEditMode {
                    Section("状态") {
                        Toggle("活跃项目", isOn: $viewModel.isActive)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isEditMode ? "保存" : "创建") {
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

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("Add Project") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, configurations: config)

    return AddProjectView(modelContext: container.mainContext)
        .modelContainer(container)
}

#Preview("Edit Project") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, configurations: config)

    let project = Project(
        name: "我的新家",
        houseType: "三室两厅",
        area: 120.0,
        startDate: Date(),
        estimatedDuration: 90,
        notes: "这是一个测试项目"
    )

    return AddProjectView(modelContext: container.mainContext, project: project)
        .modelContainer(container)
}
