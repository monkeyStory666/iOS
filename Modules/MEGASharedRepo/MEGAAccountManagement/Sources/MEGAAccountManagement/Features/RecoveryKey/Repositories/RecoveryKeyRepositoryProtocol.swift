// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol RecoveryKeyRepositoryProtocol {
    func recoveryKey() -> String?
    func keyExported()
}
