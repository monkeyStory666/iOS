// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI
import MEGAAuthentication

public struct DeleteAccountEmailSentView: View {
    @StateObject private var viewModel: DeleteAccountEmailSentViewModel
    @Environment(\.scenePhase) var scenePhase

    public init(viewModel: @autoclosure @escaping () -> DeleteAccountEmailSentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        EmailSentView(viewModel: viewModel.emailSentViewModel)
            .onAppear(perform: viewModel.listenToLogoutEvents)
    }
}
