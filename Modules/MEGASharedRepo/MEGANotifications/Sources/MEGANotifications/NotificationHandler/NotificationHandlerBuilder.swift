import Foundation
import UserNotifications

public protocol NotificationHandling {
    func canHandle(_ notification: UNNotification) -> Bool
    func handle(_ notification: UNNotification)
}

public class NotificationHandlerBuilder {
    public typealias ValidateType = (String) -> Bool

    private var typePredicates: [ValidateType] = []

    public init() {}

    public func type(_ predicates: String...) -> NotificationHandlerBuilder {
        self.typePredicates.append(contentsOf: predicates.map { type in
            { $0.lowercased() == type.lowercased() }
        })
        return self
    }

    public func build(
        withChildHandlers childHandlers: [NotificationHandling]? = nil,
        handler: ((UNNotification) -> Void)? = nil
    ) -> NotificationHandling {
        NotificationHandler(
            types: typePredicates,
            handler: handler,
            childHandlers: childHandlers
        )
    }

    private struct NotificationHandler: NotificationHandling {
        let types: [ValidateType]
        let handler: ((UNNotification) -> Void)?
        let childHandlers: [NotificationHandling]?

        init(
            types: [ValidateType],
            handler: ((UNNotification) -> Void)? = nil,
            childHandlers: [NotificationHandling]? = nil
        ) {
            self.types = types
            self.handler = handler
            self.childHandlers = childHandlers
        }

        func isTypeValid(in notification: UNNotification) -> Bool {
            types.contains(where: { $0(notification.request.identifier) })
        }

        func canHandle(_ notification: UNNotification) -> Bool {
            isTypeValid(in: notification)
        }

        func handle(_ notification: UNNotification) {
            guard canHandle(notification) else { return }

            if let childHandlers {
                for handler in childHandlers where handler.canHandle(notification) {
                    handler.handle(notification)
                    return
                }
            } else {
                handler?(notification)
            }
        }
    }
}
