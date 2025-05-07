// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGASettings
import MEGAAccountManagement
import XCTest

final class AccountDetailChangeNameViewModelTests: XCTestCase {
    func testInitialState() {
        let sut = AccountDetailChangeNameViewModel()

        XCTAssertNil(sut.route)
    }

    func testDidTapRow_shouldRouteToChangeName() {
        let sut = AccountDetailChangeNameViewModel()

        sut.didTapRow()

        XCTAssertEqual(sut.route?.isChangeName, true)
    }

    func testChangeNameViewModelBindings_isDismiss_shouldSetRouteToNil() {
        let changeNameViewModel = ChangeNameViewModel()
        let sut = AccountDetailChangeNameViewModel()
        sut.routeTo(.changeName(changeNameViewModel))

        changeNameViewModel.routeTo(.dismissed)

        XCTAssertNil(sut.route)
    }

    func testChangeNameViewModelBindings_isNameChanged_shouldSetRouteToNameChanged() {
        let changeNameViewModel = ChangeNameViewModel()
        let sut = AccountDetailChangeNameViewModel()
        sut.routeTo(.changeName(changeNameViewModel))

        changeNameViewModel.routeTo(.nameChanged)

        XCTAssertEqual(sut.route?.isNameChanged, true)
    }
}
