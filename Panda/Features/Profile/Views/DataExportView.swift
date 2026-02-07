//
//  DataExportView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import SwiftData

struct DataExportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ProjectManager.self) private var projectManager
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]

    @State private var selectedExportFormat: ExportFormat = .pdf
    @State private var includePhotos = true
    @State private var isExporting = false
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?

    private var currentProject: Project? {
        projects.first { $0.id == projectManager.currentProjectId }
    }

    var body: some View {
        Form {
            // Project Selection
            Section {
                if let project = currentProject {
                    HStack {
                        Text("当前项目")
                        Spacer()
                        Text(project.name)
                            .foregroundColor(Colors.textSecondary)
                    }

                    NavigationLink {
                        ProjectListView(modelContext: modelContext)
                    } label: {
                        Text("切换项目")
                    }
                } else {
                    Text("请先选择项目")
                        .foregroundColor(Colors.textSecondary)

                    NavigationLink {
                        ProjectListView(modelContext: modelContext)
                    } label: {
                        Text("选择项目")
                    }
                }
            } header: {
                Text("导出项目")
            }

            // Export Format
            Section {
                Picker("导出格式", selection: $selectedExportFormat) {
                    ForEach(ExportFormat.allCases) { format in
                        Label(format.rawValue, systemImage: format.iconName)
                            .tag(format)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("格式")
            }

            // Export Options
            Section {
                Toggle("包含照片", isOn: $includePhotos)

                HStack {
                    Text("文件大小")
                    Spacer()
                    Text(estimatedFileSize)
                        .foregroundColor(Colors.textSecondary)
                }
            } header: {
                Text("选项")
            } footer: {
                Text(exportDescription)
            }

            // Export Content
            Section {
                ExportItem(icon: "chart.pie.fill", label: "预算数据", included: true)
                ExportItem(icon: "calendar", label: "进度数据", included: true)
                ExportItem(icon: "shippingbox", label: "材料清单", included: true)
                ExportItem(icon: "person.2", label: "联系人", included: true)
                ExportItem(icon: "doc.text", label: "合同文档", included: true)
                ExportItem(icon: "book", label: "装修日记", included: true)
                ExportItem(icon: "photo.on.rectangle", label: "照片", included: includePhotos)
            } header: {
                Text("导出内容")
            }

            // Export Button
            Section {
                Button {
                    exportData()
                } label: {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }

                        Text(isExporting ? "导出中..." : "导出数据")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(currentProject == nil || isExporting)
            }
        }
        .navigationTitle("数据导出")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(activityItems: [url])
            }
        }
    }

    // MARK: - Helper Properties

    private var estimatedFileSize: String {
        guard let project = currentProject else { return "0 KB" }

        // Rough estimation based on data
        let baseSize = 50 // KB
        let photosSize = includePhotos ? (project.materials.count + project.journalEntries.count) * 200 : 0

        let totalKB = baseSize + photosSize

        if totalKB < 1024 {
            return "\(totalKB) KB"
        } else {
            let mb = Double(totalKB) / 1024.0
            return String(format: "%.1f MB", mb)
        }
    }

    private var exportDescription: String {
        switch selectedExportFormat {
        case .pdf:
            return "导出为 PDF 格式，适合打印和分享"
        case .excel:
            return "导出为 Excel 格式，可编辑和分析数据"
        case .json:
            return "导出为 JSON 格式，适合数据备份和迁移"
        }
    }

    // MARK: - Helper Methods

    private func exportData() {
        guard let project = currentProject else { return }

        isExporting = true

        // Simulate export process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // TODO: Implement actual export logic
            let fileName = "\(project.name)_\(formatDate(Date())).\(selectedExportFormat.fileExtension)"
            print("导出文件: \(fileName)")

            isExporting = false
            // showingShareSheet = true
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
}

// MARK: - Export Format

enum ExportFormat: String, CaseIterable, Identifiable {
    case pdf = "PDF"
    case excel = "Excel"
    case json = "JSON"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .pdf: return "doc.fill"
        case .excel: return "tablecells"
        case .json: return "doc.text"
        }
    }

    var fileExtension: String {
        switch self {
        case .pdf: return "pdf"
        case .excel: return "xlsx"
        case .json: return "json"
        }
    }
}

// MARK: - Supporting Views

private struct ExportItem: View {
    let icon: String
    let label: String
    let included: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(included ? Colors.primary : Colors.textSecondary)
                .frame(width: 24)

            Text(label)
                .foregroundColor(included ? Colors.textPrimary : Colors.textSecondary)

            Spacer()

            if included {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Colors.success)
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DataExportView()
    }
    .modelContainer(for: [Project.self], inMemory: true)
    .environment(ProjectManager())
}
