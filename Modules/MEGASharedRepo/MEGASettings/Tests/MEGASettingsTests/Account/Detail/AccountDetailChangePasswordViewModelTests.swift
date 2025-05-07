// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGASettings
import MEGAAccountManagement
import XCTest

final class AccountDetailChangePasswordViewModelTests: XCTestCase {
    func testInitialState() {
        let sut = AccountDetailChangePasswordViewModel()

        XCTAssertNil(sut.route)
    }

    func testDidTapRow_shouldRouteToChangePassword() {
        let sut = AccountDetailChangePasswordViewModel()

        sut.didTapRow()

        XCTAssertEqual(sut.route?.isChangePassword, true)
    }

    func testChangePassword_isDismiss_shouldSetRouteToNil() {
        let changePasswordViewModel = ChangePasswordViewModel()
        let sut = AccountDetailChangePasswordViewModel()
        sut.routeTo(.changePassword(changePasswordViewModel))

        changePasswordViewModel.routeTo(.dismissed)

        XCTAssertNil(sut.route)
    }
}
