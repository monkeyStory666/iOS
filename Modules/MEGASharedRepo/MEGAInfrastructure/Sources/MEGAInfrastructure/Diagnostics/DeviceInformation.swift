// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import Network

public final class DeviceInformation: DiagnosticReadable, Sendable {
    public let deviceName: String
    public let osType: String
    public let osVersion: String
    public let language: String
    public let timezone: String
    public let connectionStatus: @Sendable () async -> NWInterface.InterfaceType?

    init(
        deviceName: String?,
        osType: String?,
        osVersion: String?,
        language: String?,
        timezone: String,
        connectionStatus: @Sendable @escaping () async -> NWInterface.InterfaceType?
    ) {
        self.deviceName = deviceName ?? "(ADD_DEVICE_MODEL_HERE)"
        self.osType = osType ?? "(ADD_OS_HERE)"
        self.osVersion = osVersion ?? "ADD_OS_VERSION_HERE"
        self.language = language ?? "(ADD_DEVICE_LANGUAGE_HERE)"
        self.timezone = timezone
        self.connectionStatus = connectionStatus
    }

    public func readableDiagnostic() async -> String {
        async let connectionStatus = connectionStatus()

        return """
        **Device Information**
        Device: \(deviceName)
        OS Version: \(osType) (\(osVersion))
        Language: \(language)
        Timezone: \(timezone)
        Connection Status: \(mapConnectionStatusInterface(await connectionStatus))
        """
    }

    func mapConnectionStatusInterface(_ interface: NWInterface.InterfaceType?) -> String {
        switch interface {
        case .wifi:
            "WiFi"
        case .cellular:
            "Cellular"
        case .wiredEthernet:
            "Ethernet"
        case .none:
            "No internet connection"
        default:
            "Other"
        }
    }
}
