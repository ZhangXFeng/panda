//
//  HelpFeedbackView.swift
//  Panda
//
//  Created on 2026-02-03.
//

import SwiftUI
import MessageUI

struct HelpFeedbackView: View {
    @State private var showingMailComposer = false
    @State private var showingMailAlert = false
    @State private var feedbackText = ""
    @State private var showingSubmitAlert = false

    var body: some View {
        Form {
            // FAQ Section
            Section {
                DisclosureGroup {
                    Text("Panda 装修管家是一款专为装修用户设计的全方位管理工具，帮助您轻松管理装修项目的预算、进度、材料、联系人等信息。")
                        .font(Fonts.body)
                        .foregroundColor(Colors.textSecondary)
                        .padding(.vertical, Spacing.xs)
                } label: {
                    FAQLabel(question: "什么是 Panda 装修管家？")
                }

                DisclosureGroup {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("1. 点击右上角「+」创建新项目")
                        Text("2. 填写项目基本信息（名称、房型、面积等）")
                        Text("3. 设置开工日期和预计工期")
                        Text("4. 创建完成后即可开始使用")
                    }
                    .font(Fonts.body)
                    .foregroundColor(Colors.textSecondary)
                    .padding(.vertical, Spacing.xs)
                } label: {
                    FAQLabel(question: "如何创建新项目？")
                }

                DisclosureGroup {
                    Text("在预算页面点击「+」添加支出，选择分类、输入金额和备注，支持上传支出凭证照片。系统会自动统计各分类支出并提醒您预算使用情况。")
                        .font(Fonts.body)
                        .foregroundColor(Colors.textSecondary)
                        .padding(.vertical, Spacing.xs)
                } label: {
                    FAQLabel(question: "如何记录装修支出？")
                }

                DisclosureGroup {
                    Text("可以通过 iCloud 在多台设备间同步数据。请前往「隐私与安全」开启 iCloud 同步功能。")
                        .font(Fonts.body)
                        .foregroundColor(Colors.textSecondary)
                        .padding(.vertical, Spacing.xs)
                } label: {
                    FAQLabel(question: "如何同步数据到其他设备？")
                }

                DisclosureGroup {
                    Text("在「我的 → 数据导出」页面，选择导出格式（PDF/Excel/JSON），即可导出项目的所有数据。")
                        .font(Fonts.body)
                        .foregroundColor(Colors.textSecondary)
                        .padding(.vertical, Spacing.xs)
                } label: {
                    FAQLabel(question: "如何导出数据？")
                }
            } header: {
                Text("常见问题")
            }

            // Contact Section
            Section {
                Link(destination: URL(string: "https://example.com/docs")!) {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(Colors.primary)
                            .frame(width: 24)
                        Text("使用手册")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(Colors.textSecondary)
                    }
                }

                Link(destination: URL(string: "https://example.com/tutorial")!) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(Colors.primary)
                            .frame(width: 24)
                        Text("视频教程")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(Colors.textSecondary)
                    }
                }

                Button {
                    if MFMailComposeViewController.canSendMail() {
                        showingMailComposer = true
                    } else {
                        showingMailAlert = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Colors.primary)
                            .frame(width: 24)
                        Text("联系我们")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(Colors.textSecondary)
                    }
                }
            } header: {
                Text("帮助资源")
            }

            // Feedback Section
            Section {
                TextEditor(text: $feedbackText)
                    .frame(minHeight: 120)
                    .overlay(alignment: .topLeading) {
                        if feedbackText.isEmpty {
                            Text("请输入您的反馈或建议...")
                                .foregroundColor(Colors.textSecondary)
                                .padding(8)
                                .allowsHitTesting(false)
                        }
                    }

                Button {
                    submitFeedback()
                } label: {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("提交反馈")
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } header: {
                Text("反馈与建议")
            } footer: {
                Text("感谢您的反馈，我们会认真听取每一条建议")
            }

            // Version Info
            Section {
                HStack {
                    Text("应用版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(Colors.textSecondary)
                }

                HStack {
                    Text("构建版本")
                    Spacer()
                    Text("2026.02.03")
                        .foregroundColor(Colors.textSecondary)
                }
            } header: {
                Text("版本信息")
            }
        }
        .navigationTitle("帮助与反馈")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingMailComposer) {
            MailComposerView(recipients: ["support@panda.app"], subject: "Panda 装修管家 - 用户反馈")
        }
        .alert("无法发送邮件", isPresented: $showingMailAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("请确保您的设备已配置邮件账户")
        }
        .alert("反馈已提交", isPresented: $showingSubmitAlert) {
            Button("确定", role: .cancel) {
                feedbackText = ""
            }
        } message: {
            Text("感谢您的反馈，我们会尽快处理")
        }
    }

    // MARK: - Helper Methods

    private func submitFeedback() {
        // TODO: Implement actual feedback submission
        print("提交反馈: \(feedbackText)")
        showingSubmitAlert = true
    }
}

// MARK: - Supporting Views

private struct FAQLabel: View {
    let question: String

    var body: some View {
        Text(question)
            .font(Fonts.body)
            .foregroundColor(Colors.textPrimary)
    }
}

// MARK: - Mail Composer

struct MailComposerView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.setToRecipients(recipients)
        composer.setSubject(subject)
        composer.mailComposeDelegate = context.coordinator
        return composer
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerView

        init(parent: MailComposerView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HelpFeedbackView()
    }
}
