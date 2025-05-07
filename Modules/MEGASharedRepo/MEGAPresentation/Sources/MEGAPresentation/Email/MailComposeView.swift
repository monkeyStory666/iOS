// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MessageUI
import SwiftUI

public struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    public var email: EmailEntity

    public init(email: EmailEntity) {
        self.email = email
    }

    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposeView

        init(parent: MailComposeView) {
            self.parent = parent
        }

        public func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true) {
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = context.coordinator
        mailComposeVC.setToRecipients(email.recipients)
        mailComposeVC.setSubject(email.subject)
        mailComposeVC.setMessageBody(email.body, isHTML: false)
        for attachment in email.attachments {
            mailComposeVC.addAttachmentData(
                attachment.data,
                mimeType: attachment.mimeType,
                fileName: attachment.filename
            )
        }
        return mailComposeVC
    }

    public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

