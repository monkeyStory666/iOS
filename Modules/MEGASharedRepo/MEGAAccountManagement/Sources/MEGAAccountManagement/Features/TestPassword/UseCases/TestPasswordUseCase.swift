// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol TestPasswordUseCaseProtocol {
    func testPassword(_ password: String) async -> Bool
}

public struct TestPasswordUseCase: TestPasswordUseCaseProtocol {
    private let tester: any PasswordTesting

    public init(tester: some PasswordTesting) {
        self.tester = tester
    }

    public func testPassword(_ password: String) async -> Bool {
        await tester.testPassword(password)
    }
}
