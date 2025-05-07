import Foundation

public struct UserEntity: Sendable, Equatable {
    public enum VisibilityEntity: Sendable {
        case unknown
        case hidden
        case visible
        case inactive
        case blocked
    }
    
    public struct ChangeTypeEntity: OptionSet, Sendable {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let avatar = ChangeTypeEntity(rawValue: 1 << 2)
        public static let firstname = ChangeTypeEntity(rawValue: 1 << 3)
        public static let lastname = ChangeTypeEntity(rawValue: 1 << 4)
        public static let email = ChangeTypeEntity(rawValue: 1 << 5)
    }
    
    public enum ChangeSource: Sendable {
        case externalChange
        case explicitRequest
        case implicitRequest
    }
    
    public let email: String?
    public let handle: HandleEntity
    public let visibility: VisibilityEntity
    public let changes: ChangeTypeEntity
    public let changeSource: ChangeSource
    public let addedDate: Date?
    
    public init(email: String?, handle: HandleEntity, visibility: VisibilityEntity, changes: ChangeTypeEntity, changeSource: ChangeSource, addedDate: Date?) {
        self.email = email
        self.handle = handle
        self.visibility = visibility
        self.changes = changes
        self.changeSource = changeSource
        self.addedDate = addedDate
    }
}
