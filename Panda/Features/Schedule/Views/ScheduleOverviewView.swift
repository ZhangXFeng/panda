//
//  ScheduleOverviewView.swift
//  Panda
//
//  Created on 2026-02-02.
//

import SwiftUI
import SwiftData

struct ScheduleOverviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ProjectManager.self) private var projectManager
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]
    @State private var selectedPhase: Phase?
    @State private var showDisabledPhases = false

    /// 当前选中的项目
    private var currentProject: Project? {
        projectManager.currentProject(from: projects)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let project = currentProject {
                    VStack(spacing: Spacing.md) {
                        // 整体进度
                        overallProgressCard(project: project)

                        // 阶段列表
                        if project.phases.filter({ $0.isEnabled }).isEmpty {
                            emptyPhasesState
                        } else {
                            phasesSection(project: project)
                        }
                    }
                    .padding()
                } else {
                    emptyState
                }
            }
            .navigationTitle("装修进度")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedPhase) { phase in
                PhaseDetailView(phase: phase, modelContext: modelContext)
            }
        }
    }

    // MARK: - Components

    private func overallProgressCard(project: Project) -> some View {
        CardView {
            VStack(spacing: Spacing.md) {
                HStack {
                    Text("整体进度")
                        .font(.titleSmall)
                    Spacer()
                    Text("\(Int(project.overallProgress * 100))%")
                        .font(.numberMedium)
                        .foregroundColor(.primaryWood)
                }

                ProgressBar(progress: project.overallProgress)

                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("已完成阶段")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        let enabled = project.phases.filter { $0.isEnabled }
                        Text("\(enabled.filter { $0.isCompleted }.count)/\(enabled.count)")
                            .font(.bodyMedium)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        Text("剩余天数")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        Text("\(project.remainingDays) 天")
                            .font(.bodyMedium)
                            .foregroundColor(project.isDelayed ? .error : .success)
                    }
                }
            }
        }
    }

    private func phasesSection(project: Project) -> some View {
        let enabledPhases = project.phases.filter { $0.isEnabled }
        let disabledPhases = project.phases.filter { !$0.isEnabled }
        let phasesToShow = showDisabledPhases ? project.phases : enabledPhases

        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("装修阶段")
                .font(.titleSmall)
                .padding(.horizontal, Spacing.sm)

            ForEach(phasesToShow.sorted(by: Phase.sortBySortOrder)) { phase in
                PhaseCard(phase: phase)
                    .onTapGesture {
                        selectedPhase = phase
                    }
            }

            if !disabledPhases.isEmpty {
                Button {
                    showDisabledPhases.toggle()
                } label: {
                    Text(showDisabledPhases ? "隐藏已禁用阶段" : "显示已禁用阶段 (\(disabledPhases.count))")
                        .font(.captionMedium)
                        .foregroundColor(.textSecondary)
                        .padding(.vertical, Spacing.xs)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var emptyPhasesState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "timeline.selection")
                .font(.system(size: 48))
                .foregroundColor(.textHint)
            Text("尚未生成装修阶段")
                .font(.titleSmall)
                .foregroundColor(.textSecondary)
            Text("请在编辑项目时创建阶段")
                .font(.captionRegular)
                .foregroundColor(.textHint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "calendar")
                .font(.system(size: 64))
                .foregroundColor(.textHint)
            Text("暂无进度数据")
                .font(.titleSmall)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Phase Card

struct PhaseCard: View {
    let phase: Phase

    var body: some View {
        CardView(padding: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: phase.type.iconName)
                        .foregroundColor(phase.isCompleted ? .success : .primaryWood)
                    Text(phase.name)
                        .font(.bodyMedium)
                    Spacer()
                    statusBadge
                }

                if phase.isEnabled && !phase.isCompleted {
                    ProgressBar(progress: phase.progress, height: 6)

                    HStack {
                        Text("进度: \(Int(phase.progress * 100))%")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        Spacer()
                        if phase.isDelayed {
                            Text("延期 \(phase.delayedDays) 天")
                                .font(.captionRegular)
                                .foregroundColor(.warning)
                        }
                    }
                }

                if let start = phase.actualStartDate, let end = phase.actualEndDate {
                    HStack {
                        Text("完成时间:")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        Text("\(formatDate(start)) ~ \(formatDate(end))")
                            .font(.captionRegular)
                    }
                } else {
                    HStack {
                        Text("计划时间:")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        Text("\(formatDate(phase.plannedStartDate)) ~ \(formatDate(phase.plannedEndDate))")
                            .font(.captionRegular)
                    }
                }
            }
        }
    }

    private var statusBadge: some View {
        Group {
            if !phase.isEnabled {
                Text("已禁用")
                    .font(.captionMedium)
                    .foregroundColor(.textHint)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.bgSecondary)
                    .cornerRadius(CornerRadius.sm)
            } else if phase.isCompleted {
                Text("已完成")
                    .font(.captionMedium)
                    .foregroundColor(.success)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.success.opacity(0.1))
                    .cornerRadius(CornerRadius.sm)
            } else if phase.isInProgress {
                Text("进行中")
                    .font(.captionMedium)
                    .foregroundColor(.info)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.info.opacity(0.1))
                    .cornerRadius(CornerRadius.sm)
            } else {
                Text("待开始")
                    .font(.captionMedium)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.bgSecondary)
                    .cornerRadius(CornerRadius.sm)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

#Preview {
    ScheduleOverviewView()
        .environment(ProjectManager())
        .modelContainer(for: [Project.self, Phase.self], inMemory: true)
}
