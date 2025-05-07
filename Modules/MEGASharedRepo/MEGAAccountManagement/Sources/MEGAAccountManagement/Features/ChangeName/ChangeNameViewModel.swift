// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent

public final class ChangeNameViewModel: ViewModel<ChangeNameViewModel.Route> {
    public enum Route {
        case dismissed
        case nameChanged
    }

    @ViewProperty(animation: nil) var firstName = ""
    @ViewProperty(animation: nil) var lastName = ""
    @ViewProperty var isUpdating = false
    @ViewProperty var isAnyFieldChanged = false
    @ViewProperty var firstNameFieldState: FieldState = .normal
    @ViewProperty var lastNameFieldState: FieldState = .normal

    private var originalFirstName: String = ""
    private var originalLastName: String = ""
    public let nameMaxCharacterLimit: Int = 40

    enum FieldState: Equatable {
        case normal
        case warning(String)
    }

    var buttonState: MEGAButtonStyle.State {
        if isAnyFieldChanged {
            return isUpdating ? .load : .default
        }

        return .disabled
    }

    private var isFirstNameValid: Bool {
        firstName.isNotEmptyOrWhitespace
    }

    private var isLastNameValid: Bool {
        lastName.isNotEmptyOrWhitespace
    }

    private var isNameValid: Bool {
        isFirstNameValid && isLastNameValid
    }

    private let snackbarDisplayer: any SnackbarDisplaying
    private let fetchAccountUseCase: any FetchAccountUseCaseProtocol
    private let changeNameUseCase: any ChangeNameUseCaseProtocol

    public init(
        snackbarDisplayer: SnackbarDisplaying = DependencyInjection.snackbarDisplayer,
        fetchAccountUseCase: some FetchAccountUseCaseProtocol = DependencyInjection.fetchAccountUseCase,
        changeNameUseCase: some ChangeNameUseCaseProtocol = DependencyInjection.changeNameUseCase
    ) {
        self.snackbarDisplayer = snackbarDisplayer
        self.fetchAccountUseCase = fetchAccountUseCase
        self.changeNameUseCase = changeNameUseCase
    }

    func onAppear() async {
        observeFirstNameChanges()
        observeLastNameChanges()
        await updateDefaultNameValues()
    }

    func didTapUpdate() async {
        guard isNameValid else { return updateFieldStates() }

        do {
            isUpdating = true
            try await changeNameUseCase.changeName(
                firstName: firstName,
                lastName: lastName
            )
            isUpdating = false
            displaySuccessfulSnackbar()
            routeTo(.nameChanged)
        } catch {
            isUpdating = false
        }
    }

    func didTapDismiss() {
        routeTo(.dismissed)
    }

    private func updateDefaultNameValues() async {
        guard let account = try? await fetchAccountUseCase.fetchAccount() else { return }

        originalFirstName = account.firstName
        originalLastName = account.lastName

        if firstName.isEmpty { firstName = originalFirstName }
        if lastName.isEmpty { lastName = originalLastName }
    }

    private func displaySuccessfulSnackbar() {
        snackbarDisplayer.display(.init(
            text: SharedStrings.Localizable.Account.ChangeName.Snackbar.success
        ))
    }

    private func updateFieldStates() {
        firstNameFieldState = isFirstNameValid
        ? .normal
        : .warning(SharedStrings.Localizable.Account.ChangeName.enterFirstName)

        lastNameFieldState = isLastNameValid
        ? .normal
        : .warning(SharedStrings.Localizable.Account.ChangeName.enterLastName)
    }

    private func observeFirstNameChanges() {
        observe {
            $firstName
                .removeDuplicates()
                .sink { [weak self] _ in
                    self?.firstNameFieldState = .normal
                    self?.trackFieldModifications()
                }
        }
    }

    private func observeLastNameChanges() {
        observe {
            $lastName
                .removeDuplicates()
                .sink { [weak self] _ in
                    self?.lastNameFieldState = .normal
                    self?.trackFieldModifications()
                }
        }
    }

    private func trackFieldModifications() {
        isAnyFieldChanged = (firstName != originalFirstName || lastName != originalLastName)
    }
}

extension ChangeNameViewModel.FieldState {
    var isWarning: Bool {
        if case .warning = self {
            return true
        } else {
            return false
        }
    }
}

extension ChangeNameViewModel.Route {
    var isDismissed: Bool {
        if case .dismissed = self {
            return true
        } else {
            return false
        }
    }
}
