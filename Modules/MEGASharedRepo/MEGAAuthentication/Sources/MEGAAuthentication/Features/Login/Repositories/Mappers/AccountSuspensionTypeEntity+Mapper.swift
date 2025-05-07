import MEGASdk

extension AccountSuspensionType {
    public func toAccountSuspensionTypeEntity() -> AccountSuspensionTypeEntity? {
        switch self {
        case .copyright: .copyright
        case .nonCopyright: .nonCopyright
        case .businessDisabled: .businessDisabled
        case .businessRemoved: .businessRemoved
        case .emailVerification: .emailVerification
        default: nil
        }
    }
}
