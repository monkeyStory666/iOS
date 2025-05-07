// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import MEGATest

public final class MockLoginStoreRepository:
    MockObject<MockLoginStoreRepository.Action>,
    LoginStoreRepositoryProtocol,
    @unchecked Sendable {
    public enum Action: Equatable {
        case set(session: String, updateDuplicateSession: Bool)
        case session
        case delete
    }

    private var setSessionInformationResult: Result<Void, any Error>
    public var returnSessionInformationResult: Result<String, any Error>
    public let deleteServiceResult: Result<Void, any Error>

    public init(
        setSessionInformationResult: Result<Void, any Error> = .success(()),
        returnSessionInformationResult: Result<String, any Error> = .success(""),
        deleteServiceResult: Result<Void, any Error> = .success(())
    ) {
        self.setSessionInformationResult = setSessionInformationResult
        self.returnSessionInformationResult = returnSessionInformationResult
        self.deleteServiceResult = deleteServiceResult

        super.init()
    }

    public func set(session: String, updateDuplicateSession: Bool) throws {
        actions.append(.set(
            session: session,
            updateDuplicateSession: updateDuplicateSession
        ))
        try setSessionInformationResult.get()
    }

    public func session() throws -> String {
        actions.append(.session)
        return try returnSessionInformationResult.get()
    }

    public func delete() throws {
        actions.append(.delete)
        try deleteServiceResult.get()
    }
}
