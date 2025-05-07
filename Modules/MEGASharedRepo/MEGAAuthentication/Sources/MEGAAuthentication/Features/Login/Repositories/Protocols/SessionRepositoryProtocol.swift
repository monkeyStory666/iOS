import MEGASDKRepo
import MEGASwift

public protocol SessionRepositoryProtocol {
    var sessionUpdates: AnyAsyncSequence<SessionEntity> { get }
}
