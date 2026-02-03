//
//  AddMaterialView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddMaterialView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddMaterialViewModel

    init(modelContext: ModelContext, material: Material? = nil) {
        _viewModel = StateObject(wrappedValue: AddMaterialViewModel(modelContext: modelContext, material: material))
    }

    var body: some View {
        NavigationStack {
            Form {
                // Basic info
                Section("基本信息") {
                    TextField("材料名称", text: $viewModel.name)
                        .autocorrectionDisabled()

                    TextField("品牌（可选）", text: $viewModel.brand)
                        .autocorrectionDisabled()

                    TextField("规格型号（可选）", text: $viewModel.specification)
                        .autocorrectionDisabled()

                    Picker("状态", selection: $viewModel.status) {
                        ForEach(MaterialStatus.allCases) { status in
                            HStack {
                                Image(systemName: status.iconName)
                                Text(status.displayName)
                            }
                            .tag(status)
                        }
                    }
                }

                // Price and quantity
                Section {
                    HStack {
                        TextField("单价", text: $viewModel.unitPrice)
                            .keyboardType(.decimalPad)

                        Picker("单位", selection: $viewModel.unit) {
                            ForEach(AddMaterialViewModel.commonUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .labelsHidden()
                    }

                    TextField("数量", text: $viewModel.quantity)
                        .keyboardType(.decimalPad)

                    if viewModel.totalPrice > 0 {
                        HStack {
                            Text("总价")
                                .foregroundColor(.secondary)

                            Spacer()

                            Text(viewModel.formattedTotalPrice)
                                .font(.headline)
                                .foregroundColor(Colors.primary)
                        }
                    }
                } header: {
                    Text("价格与数量")
                } footer: {
                    Text("单价、数量为必填项")
                }

                // Location
                Section("使用位置") {
                    Picker("位置", selection: $viewModel.location) {
                        Text("选择位置").tag("")
                        ForEach(AddMaterialViewModel.commonLocations, id: \.self) { location in
                            Text(location).tag(location)
                        }
                    }
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
                        Task {
                            await viewModel.loadSelectedPhotos()
                        }
                    }

                    if !viewModel.photoData.isEmpty {
                        photoGrid
                    }
                } header: {
                    Text("照片")
                } footer: {
                    Text("材料照片、样品照片等")
                }

                // Notes
                Section("备注") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 80)
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

#Preview("Add Material") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Material.self, configurations: config)
    let context = container.mainContext

    let project = Project(name: "我的新家", houseType: "三室两厅", area: 120.0)
    context.insert(project)
    ProjectManager.shared.currentProject = project

    return AddMaterialView(modelContext: context)
}

#Preview("Edit Material") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Material.self, configurations: config)
    let context = container.mainContext

    let project = Project(name: "我的新家", houseType: "三室两厅", area: 120.0)
    context.insert(project)

    let material = Material(
        name: "马可波罗瓷砖",
        brand: "马可波罗",
        specification: "800x800mm",
        unitPrice: 89.90,
        quantity: 120,
        unit: "块",
        status: .ordered,
        location: "客厅"
    )
    material.project = project
    context.insert(material)

    return AddMaterialView(modelContext: context, material: material)
}
