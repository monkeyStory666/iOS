public enum SceneTypeEntity {
    case normal
    case autofill
    case importPassword
}

public extension SceneTypeEntity {
    var isNormal: Bool {
        if case .normal = self {
            true
        } else {
            false
        }
    }

    var isAutofill: Bool {
        if case .autofill = self {
            true
        } else {
            false
        }
    }

    var isImportPassword: Bool {
        if case .importPassword = self {
            true
        } else {
            false
        }
    }
}
