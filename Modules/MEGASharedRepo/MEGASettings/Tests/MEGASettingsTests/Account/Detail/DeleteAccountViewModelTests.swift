// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGASettings
import MEGAAccountManagement
import MEGAConnectivityMocks
import MEGAPresentationMocks
import XCTest

final class DeleteAccountViewModelTests: XCTestCase {
    func testInitialState() {
        let sut = makeSUT()

        XCTAssertNil(sut.route)
    }

    func testOnTap_shouldRouteToDetails() {
        let sut = makeSUT()

        sut.onTap()

        XCTAssertEqual(sut.route?.isShowingDetails, true)
    }

    private func makeSUT(
        mockConnectionUseCase: some MockConnectionUseCase = MockConnectionUseCase(),
        file: StaticString = #file, line: UInt = #line
    ) -> DeleteAccountViewModel {
        let sut = DeleteAccountViewModel(
            snackbarDisplayer: MockSnackbarDisplayer(),
            connectionUseCase: mockConnectionUseCase,
            clientDetailsSection: nil
        )

        trackForMemoryLeaks(on: sut, file: file, line: line)
        return sut
    }
}
