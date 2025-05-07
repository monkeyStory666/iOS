import Foundation
import MEGASdk
import MEGASDKRepo
import MEGASwift

public enum UserAvatarRepositoryError: Error {
    case invalidFile
    case dataConversionError
}

public typealias GetDataFromPath = (String) throws -> Data

public struct UserAvatarRepository<SDK: MEGASdk>: UserAvatarRepositoryProtocol {
    private let sdk: MEGASdk
    private let getDataFromPath: GetDataFromPath

    public init(
        sdk: MEGASdk,
        getDataFromPath: @escaping GetDataFromPath
    ) {
        self.sdk = sdk
        self.getDataFromPath = getDataFromPath
    }

    public func fetchAvatar(
        for base64Handle: Base64HandleEntity,
        destinationFilePath: String
    ) async throws -> Data? {
        return try await withAsyncThrowingValue { completion in
            sdk.getAvatarUser(
                withEmailOrHandle: base64Handle,
                destinationFilePath: destinationFilePath,
                delegate: RequestDelegate { result in
                    switch result {
                    case .success(let request):
                        if let filePath = request.file, filePath.contains(base64Handle) {
                            if let data = try? getDataFromPath(filePath) {
                                completion(.success(data))
                            } else {
                                completion(.failure(
                                    UserAvatarRepositoryError.dataConversionError
                                ))
                            }
                        } else {
                            completion(.failure(
                                UserAvatarRepositoryError.invalidFile
                            ))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            )
        }
    }
}
