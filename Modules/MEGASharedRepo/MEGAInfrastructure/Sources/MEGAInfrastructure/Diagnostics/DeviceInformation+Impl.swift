// Copyright © 2024 MEGA Limited. All rights reserved.

import DeviceKit
import Foundation
import Network

extension DeviceInformation {
    convenience init() {
        self.init(
            deviceName: {
                #if targetEnvironment(macCatalyst)
                let service = IOServiceGetMatchingService(
                    kIOMasterPortDefault,
                    IOServiceMatching("IOPlatformExpertDevice")
                )
                var modelIdentifier: String?
                if let modelData = IORegistryEntryCreateCFProperty(
                    service, "model" as CFString,
                    kCFAllocatorDefault, 0
                ).takeRetainedValue() as? Data {
                    modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
                }
                IOObjectRelease(service)
                return modelIdentifier
                #else
                Device.current.description
                #endif
            }(),
            osType: {
                #if targetEnvironment(macCatalyst)
                "macOS"
                #else
                Device.current.systemName
                #endif
            }(),
            osVersion: {
                #if targetEnvironment(macCatalyst)
                let version = ProcessInfo.processInfo.operatingSystemVersion
                return "\(version.majorVersion)"
                    + ".\(version.minorVersion)"
                    + ".\(version.patchVersion)"
                #else
                Device.current.systemVersion
                #endif
            }(),
            language: Locale.preferredLanguages.first,
            timezone: TimeZone.current.identifier,
            connectionStatus: {
                await withCheckedContinuation { continuation in
                    let monitor = NWPathMonitor()
                    monitor.start(queue: DispatchQueue(label: "\(#file).NetworkMonitor"))
                    monitor.pathUpdateHandler = { path in
                        continuation.resume(returning: path.status == .satisfied ? path.interfaceType : nil)
                        monitor.pathUpdateHandler = nil
                        monitor.cancel()
                    }
                }
            }
        )
    }
}

extension NWPath {
    var interfaceType: NWInterface.InterfaceType? {
        status == .satisfied ? availableInterfaces.first?.type : nil
    }
}
