public enum Submodule {
    enum SubmoduleError: Error {
        case submoduleNotFound(paths: [String])
    }

    case sdk
    case chatSDK

    public var description: String {
        switch self {
        case .sdk:
            return "MEGASDK"
        case .chatSDK:
            return "MEGAChatSDK"
        }
    }

    public var path: String {
        get throws {
            let directoryManager = DirectoryManager()

            let possiblePaths: [String]
            switch self {
            case .sdk:
                possiblePaths = [
                    "./Modules/DataSource/MEGASDK/Sources/MEGASDK",
                    "./Submodules/DataSource/MEGASDK/Sources/MEGASDK"
                ]
            case .chatSDK:
                possiblePaths = [
                    "./Modules/DataSource/MEGAChatSDK/Sources/MEGAChatSDK",
                    "./Submodules/DataSource/MEGAChatSDK/Sources/MEGAChatSDK"
                ]
            }

            if let validPath = possiblePaths.first(where: { directoryManager.fileExists(atPath: $0) }) {
                return validPath
            } else {
                throw SubmoduleError.submoduleNotFound(paths: possiblePaths)
            }
        }
    }
}
