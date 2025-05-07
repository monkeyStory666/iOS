// Copyright © 2024 MEGA Limited. All rights reserved.

public enum EventIdentifierType: Int {
    case screenView = 0
    case tabSelected = 1
    case buttonPressed = 2
    case dialogDisplayed = 3
    case navigationAction = 4
    case menuItemSelected = 5
    case notification = 6
    case general = 7
    case itemSelected = 8
    case reserved = 9
}

#if !targetEnvironment(macCatalyst)
import MEGAAnalyticsiOS

public extension EventIdentifierType {
    init?(from event: (any EventIdentifier)?) {
        guard let event else { return nil }

        if event is ScreenViewEventIdentifier {
            self = .screenView
        } else if event is TabSelectedEventIdentifier {
            self = .tabSelected
        } else if event is ButtonPressedEventIdentifier {
            self = .buttonPressed
        } else if event is DialogDisplayedEventIdentifier {
            self = .dialogDisplayed
        } else if event is NavigationEventIdentifier {
            self = .navigationAction
        } else if event is MenuItemEventIdentifier {
            self = .menuItemSelected
        } else if event is NotificationEventIdentifier {
            self = .notification
        } else if event is GeneralEventIdentifier {
            self = .general
        } else if event is ItemSelectedEventIdentifier {
            self = .itemSelected
        } else {
            return nil
        }
    }
}
#endif
