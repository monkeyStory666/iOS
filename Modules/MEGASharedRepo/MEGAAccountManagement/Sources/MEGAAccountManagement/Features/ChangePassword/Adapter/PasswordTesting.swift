// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol PasswordTesting {
    func testPassword(_ password: String) async -> Bool
}
