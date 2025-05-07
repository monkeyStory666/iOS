import MEGASdk
import MEGASDKRepo
import MEGASwift

public enum DefaultAvatarBackgroundColorRepositoryError: Error {
    case userNotFound
    case colorNotFound
}

public struct DefaultAvatarBackgroundColorRepository<SDK: MEGASdk>: DefaultAvatarBackgroundColorRepositoryProtocol {
    private let sdk: SDK

    public init(sdk: SDK) {
        self.sdk = sdk
    }

    public func fetchBackgroundColor() async throws -> String {
        try await withAsyncThrowingValue { completion in
            guard let handle = sdk.myUser?.handle else {
                completion(.failure(
                    DefaultAvatarBackgroundColorRepositoryError.userNotFound
                ))
                return
            }

            guard let hexColor = SDK.avatarColor(
                forBase64UserHandle: SDK.base64Handle(
                    forUserHandle: handle
                )
            ) else {
                completion(.failure(
                    DefaultAvatarBackgroundColorRepositoryError.colorNotFound
                ))
                return
            }

            completion(.success(hexColor))
        }
    }

    public func fetchSecondaryBackgroundColor() async throws -> String {
        try await withAsyncThrowingValue { completion in
            guard let handle = sdk.myUser?.handle else {
                completion(.failure(
                    DefaultAvatarBackgroundColorRepositoryError.userNotFound
                ))
                return
            }

            guard let hexColor = SDK.avatarSecondaryColor(
                forBase64UserHandle: SDK.base64Handle(
                    forUserHandle: handle
                )
            ) else {
                completion(.failure(
                    DefaultAvatarBackgroundColorRepositoryError.colorNotFound
                ))
                return
            }

            completion(.success(hexColor))
        }
    }
}
