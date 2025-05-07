import MEGAAuthentication
import MEGASdk
import Testing

struct AccountSuspensionTypeEntity_Mapper_Tests {
    @Test(arguments: [
        (type: AccountSuspensionType.copyright, expectedType: Optional.some(AccountSuspensionTypeEntity.copyright)),
        (type: .nonCopyright, expectedType: .some(.nonCopyright)),
        (type: .businessDisabled, expectedType: .some(.businessDisabled)),
        (type: .businessRemoved, expectedType: .some(.businessRemoved)),
        (type: .emailVerification, expectedType: .some(.emailVerification)),
        (type: .none, expectedType: .none)
    ])
    func mappingIsCorrect(
        type: AccountSuspensionType,
        expectedType: AccountSuspensionTypeEntity?
    ) {
        #expect(type.toAccountSuspensionTypeEntity() == expectedType)
    }

}
