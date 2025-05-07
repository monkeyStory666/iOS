public enum FieldState: Equatable {
    case normal
    case warning(String)
}

extension FieldState {
    var isWarning: Bool {
        if case .warning = self {
            true
        } else {
            false
        }
    }
}
