//
//  AddDocumentViewModel.swift
//  Panda
//
//  Created on 2026-02-03.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI

@MainActor
class AddDocumentViewModel: ObservableObject {
    // MARK: - Properties

    @Published var name: String = ""
    @Published var type: DocumentType = .contract
    @Published var date: Date = Date()
    @Published var photoData: [Data] = []
    @Published var notes: String = ""

    // Contract specific
    @Published var contractAmount: String = ""
    @Published var paymentMethod: PaymentMethod = .progressive
    @Published var paymentRecords: [PaymentRecord] = []
    @Published var contractStartDate: Date = Date()
    @Published var contractEndDate: Date = Date().addingTimeInterval(86400 * 90) // 90 days later
    @Published var partyA: String = ""
    @Published var partyB: String = ""

    @Published var showingError: Bool = false
    @Published var errorMessage: String = ""
    @Published var selectedPhotos: [PhotosPickerItem] = []

    private let modelContext: ModelContext
    private let projectManager: ProjectManager
    private var documentToEdit: Document?

    var isEditMode: Bool {
        documentToEdit != nil
    }

    var title: String {
        isEditMode ? "编辑文档" : "添加文档"
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isContractType: Bool {
        type == .contract
    }

    var contractAmountDecimal: Decimal? {
        Decimal(string: contractAmount)
    }

    // MARK: - Initialization

    init(
        modelContext: ModelContext,
        document: Document? = nil,
        projectManager: ProjectManager = ProjectManager.shared
    ) {
        self.modelContext = modelContext
        self.projectManager = projectManager
        self.documentToEdit = document

        if let document = document {
            loadDocument(document)
        } else {
            // Set default payment records for new contracts
            setupDefaultPaymentRecords()
        }
    }

    // MARK: - Methods

    private func loadDocument(_ document: Document) {
        name = document.name
        type = document.type
        date = document.date
        photoData = document.photoData
        notes = document.notes
        partyA = document.partyA
        partyB = document.partyB

        if let amount = document.contractAmount {
            contractAmount = String(describing: amount)
        }
        if let method = document.paymentMethod {
            paymentMethod = method
        }
        paymentRecords = document.paymentRecords
        if let startDate = document.contractStartDate {
            contractStartDate = startDate
        }
        if let endDate = document.contractEndDate {
            contractEndDate = endDate
        }
    }

    func save() -> Bool {
        guard canSave else {
            showError("请填写文档名称")
            return false
        }

        guard let currentProject = projectManager.currentProject else {
            showError("请先选择或创建项目")
            return false
        }

        // Validate contract amount if it's a contract
        if isContractType && !contractAmount.isEmpty && contractAmountDecimal == nil {
            showError("请输入有效的合同金额")
            return false
        }

        do {
            if let documentToEdit = documentToEdit {
                // Edit mode
                updateExistingDocument(documentToEdit)
            } else {
                // Add mode
                createNewDocument(project: currentProject)
            }

            try modelContext.save()
            return true
        } catch {
            showError("保存失败: \(error.localizedDescription)")
            return false
        }
    }

    private func createNewDocument(project: Project) {
        let document = Document(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            photoData: photoData,
            date: date,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            contractAmount: isContractType ? contractAmountDecimal : nil,
            paymentMethod: isContractType ? paymentMethod : nil,
            paymentRecords: isContractType ? paymentRecords : [],
            contractStartDate: isContractType ? contractStartDate : nil,
            contractEndDate: isContractType ? contractEndDate : nil,
            partyA: partyA.trimmingCharacters(in: .whitespacesAndNewlines),
            partyB: partyB.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        document.project = project
        modelContext.insert(document)
    }

    private func updateExistingDocument(_ document: Document) {
        document.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        document.type = type
        document.date = date
        document.photoData = photoData
        document.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        document.partyA = partyA.trimmingCharacters(in: .whitespacesAndNewlines)
        document.partyB = partyB.trimmingCharacters(in: .whitespacesAndNewlines)

        if isContractType {
            document.contractAmount = contractAmountDecimal
            document.paymentMethod = paymentMethod
            document.paymentRecords = paymentRecords
            document.contractStartDate = contractStartDate
            document.contractEndDate = contractEndDate
        } else {
            document.contractAmount = nil
            document.paymentMethod = nil
            document.paymentRecords = []
            document.contractStartDate = nil
            document.contractEndDate = nil
        }

        document.updateTimestamp()
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }

    // MARK: - Photo Management

    func addPhoto(_ data: Data) {
        photoData.append(data)
    }

    func removePhoto(at index: Int) {
        guard index >= 0 && index < photoData.count else { return }
        photoData.remove(at: index)
    }

    func loadSelectedPhotos() async {
        photoData.removeAll()

        for item in selectedPhotos {
            if let data = try? await item.loadTransferable(type: Data.self) {
                photoData.append(data)
            }
        }
    }

    // MARK: - Payment Records Management

    func setupDefaultPaymentRecords() {
        guard let amount = contractAmountDecimal else { return }

        let deposit = amount * 0.3  // 30% 定金
        let midterm = amount * 0.6  // 60% 中期款
        let final = amount * 0.1    // 10% 尾款

        paymentRecords = [
            PaymentRecord(
                name: "定金",
                amount: deposit,
                dueDate: contractStartDate
            ),
            PaymentRecord(
                name: "中期款",
                amount: midterm,
                dueDate: contractStartDate.addingTimeInterval(86400 * 30) // 30 days later
            ),
            PaymentRecord(
                name: "尾款",
                amount: final,
                dueDate: contractEndDate
            )
        ]
    }

    func addPaymentRecord() {
        let record = PaymentRecord(
            name: "付款\(paymentRecords.count + 1)",
            amount: 0
        )
        paymentRecords.append(record)
    }

    func removePaymentRecord(at index: Int) {
        guard index >= 0 && index < paymentRecords.count else { return }
        paymentRecords.remove(at: index)
    }

    func updatePaymentRecord(at index: Int, name: String? = nil, amount: Decimal? = nil, dueDate: Date? = nil) {
        guard index >= 0 && index < paymentRecords.count else { return }

        if let name = name {
            paymentRecords[index].name = name
        }
        if let amount = amount {
            paymentRecords[index].amount = amount
        }
        if let dueDate = dueDate {
            paymentRecords[index].dueDate = dueDate
        }
    }
}
