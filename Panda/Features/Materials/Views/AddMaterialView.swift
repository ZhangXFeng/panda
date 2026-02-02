//
//  AddMaterialView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct AddMaterialView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let project: Project

    // MARK: - State

    @State private var name = ""
    @State private var brand = ""
    @State private var specification = ""
    @State private var unit = "个"
    @State private var quantity = ""
    @State private var unitPrice = ""
    @State private var location = ""
    @State private var status: MaterialStatus = .pending
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    // 常用单位
    private let commonUnits = ["个", "件", "㎡", "米", "包", "桶", "箱", "套"]

    var body: some View {
        NavigationStack {
            Form {
                // 基本信息
                Section("基本信息") {
                    TextField("材料名称", text: $name, prompt: Text("例如：瓷砖"))

                    TextField("品牌", text: $brand, prompt: Text("例如：马可波罗"))

                    TextField("规格", text: $specification, prompt: Text("例如：800x800mm"))
                }

                // 价格信息
                Section("价格信息") {
                    HStack {
                        Text("¥")
                            .foregroundColor(.textSecondary)
                        TextField("单价", text: $unitPrice, prompt: Text("100"))
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        TextField("数量", text: $quantity, prompt: Text("10"))
                            .keyboardType(.decimalPad)

                        Picker("单位", selection: $unit) {
                            ForEach(commonUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    if let totalPrice = calculateTotalPrice() {
                        HStack {
                            Text("总价")
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text("¥\(String(format: "%.2f", NSDecimalNumber(decimal: totalPrice).doubleValue))")
                                .font(.numberMedium)
                                .foregroundColor(.primaryWood)
                        }
                    }
                }

                // 采购信息
                Section("采购信息") {
                    Picker("状态", selection: $status) {
                        ForEach(MaterialStatus.allCases) { status in
                            Text(status.displayName).tag(status)
                        }
                    }

                    TextField("安装位置", text: $location, prompt: Text("例如：客厅"))
                }

                // 备注
                Section("备注（可选）") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("添加材料")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("取消") {
                    dismiss()
                },
                trailing: Button("保存") {
                    saveMaterial()
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
        !name.isEmpty && !unitPrice.isEmpty && !quantity.isEmpty
    }

    private func calculateTotalPrice() -> Decimal? {
        guard let price = Decimal(string: unitPrice),
              let qty = Double(quantity) else {
            return nil
        }
        return price * Decimal(qty)
    }

    // MARK: - Methods

    private func saveMaterial() {
        guard let priceValue = Decimal(string: unitPrice), priceValue > 0 else {
            alertMessage = "请输入有效的单价"
            showingAlert = true
            return
        }

        guard let qtyValue = Double(quantity), qtyValue > 0 else {
            alertMessage = "请输入有效的数量"
            showingAlert = true
            return
        }

        let material = Material(
            name: name,
            brand: brand,
            specification: specification,
            unitPrice: priceValue,
            quantity: qtyValue,
            unit: unit,
            status: status,
            location: location
        )

        material.notes = notes
        modelContext.insert(material)
        project.addMaterial(material)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "保存失败：\(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Material.self, configurations: config)
    let project = Project(
        name: "我的家",
        houseType: "三室两厅",
        area: 100,
        startDate: Date(),
        estimatedDuration: 90
    )

    return AddMaterialView(project: project)
        .modelContainer(container)
}
