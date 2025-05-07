// Copyright © 2023 MEGA Limited. All rights reserved.

public enum Localizations {
    public static var noInternetLocalizations = NoInternetViewLocalizations.preview
}

public struct NoInternetViewLocalizations {
    public let noInternetConnectionLabel: String
    public let backOnline: String

    public init(
        noInternetConnectionLabel: String,
        backOnline: String
    ) {
        self.noInternetConnectionLabel = noInternetConnectionLabel
        self.backOnline = backOnline
    }
}

extension NoInternetViewLocalizations {
    static var preview: Self {
        .init(
            noInternetConnectionLabel: "No internet connection",
            backOnline: "Back online"
        )
    }
}
