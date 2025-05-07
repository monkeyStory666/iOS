// Copyright © 2024 MEGA Limited. All rights reserved.

/// This function is used to map errors thrown from a throwing async function
/// to store domain error. It's only intended to be used for the Store context.
func mapErrorThrownToStoreError<T>(
    from throwingAction: () async throws -> T
) async throws -> T {
    do {
        return try await throwingAction()
    } catch {
        throw StoreError(error: error) ?? error
    }
}
