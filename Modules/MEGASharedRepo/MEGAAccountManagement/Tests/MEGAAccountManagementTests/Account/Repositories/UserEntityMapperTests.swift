import MEGAAccountManagement
import MEGASdk
import MEGASDKRepo
import MEGASDKRepoMocks
import XCTest

final class UserEntityMapperTests: XCTestCase {
    
    func testVisibilityMapper() {
        let sut: [MEGAUserVisibility] = [
            .unknown,
            .hidden,
            .visible,
            .inactive,
            .blocked
        ]
        
        for visibility in sut {
            let entity = visibility.toVisibilityEntity()
            switch visibility {
            case .unknown:
                XCTAssertEqual(entity, .unknown)
            case .hidden:
                XCTAssertEqual(entity, .hidden)
            case .visible:
                XCTAssertEqual(entity, .visible)
            case .inactive:
                XCTAssertEqual(entity, .inactive)
            case .blocked:
                XCTAssertEqual(entity, .blocked)
            @unknown default:
                XCTFail("Please map the new \(type(of: MEGAUserVisibility.self)) to \(type(of: UserEntity.self)).\(type(of: UserEntity.VisibilityEntity.self))")
            }
        }
    }
}
