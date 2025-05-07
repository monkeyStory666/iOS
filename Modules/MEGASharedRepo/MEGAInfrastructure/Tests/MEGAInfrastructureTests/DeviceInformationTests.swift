// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAInfrastructure
import Network
import Testing

struct DeviceInformationTests {
    @Test func readableDiagnostic_shouldIncludeDeviceName() async {
        let deviceName = String.random(withPrefix: "anyName")
        let sut = makeSUT(deviceName: deviceName)

        #expect(sut.deviceName == deviceName)
        #expect(await sut.readableDiagnostic().contains("Device: \(deviceName)"))
    }

    @Test func readableDiagnostic_whenDeviceNameNil_shouldIncludePlaceholder() async {
        let sut = makeSUT(deviceName: nil)

        #expect(sut.deviceName == "(ADD_DEVICE_MODEL_HERE)")
        #expect(await sut.readableDiagnostic().contains("Device: (ADD_DEVICE_MODEL_HERE)"))
    }

    @Test func readableDiagnostic_shouldIncludeOsType_andVersion() async {
        let osType = String.random(withPrefix: "anyOsType")
        let osVersion = String.random(withPrefix: "anyOsVersion")
        let sut = makeSUT(osType: osType, osVersion: osVersion)

        #expect(sut.osType == osType)
        #expect(sut.osVersion == osVersion)
        #expect(await sut.readableDiagnostic().contains("OS Version: \(osType) (\(osVersion))"))
    }

    @Test func readableDiagnostic_whenOsTypeAndVersionNil_shouldIncludePlaceholder() async {
        let sut = makeSUT(osType: nil, osVersion: nil)

        #expect(sut.osType == "(ADD_OS_HERE)")
        #expect(sut.osVersion == "ADD_OS_VERSION_HERE")
        #expect(await sut.readableDiagnostic().contains("OS Version: (ADD_OS_HERE) (ADD_OS_VERSION_HERE)"))
    }

    @Test func readableDiagnostic_shouldIncludeLanguage() async {
        let language = String.random(withPrefix: "anyLanguage")
        let sut = makeSUT(language: language)

        #expect(sut.language == language)
        #expect(await sut.readableDiagnostic().contains("Language: \(language)"))
    }

    @Test func readableDiagnostic_whenLanguageNil_shouldIncludePlaceholder() async {
        let sut = makeSUT(language: nil)

        #expect(sut.language == "(ADD_DEVICE_LANGUAGE_HERE)")
        #expect(await sut.readableDiagnostic().contains("Language: (ADD_DEVICE_LANGUAGE_HERE)"))
    }

    @Test func readableDiagnostic_shouldIncludeTimezone() async {
        let timezone = String.random(withPrefix: "anyTimezone")
        let sut = makeSUT(timezone: timezone)

        #expect(sut.timezone == timezone)
        #expect(await sut.readableDiagnostic().contains("Timezone: \(timezone)"))
    }

    @Test func readableDiagnostic_orderOfProperties() async {
        let sut = makeSUT()

        let readableDiagnostic = await sut.readableDiagnostic().components(separatedBy: .newlines)

        #expect(readableDiagnostic.count == 6)
        #expect(readableDiagnostic[0] == "**Device Information**")
        #expect(readableDiagnostic[1].starts(with: "Device:"))
        #expect(readableDiagnostic[2].starts(with: "OS Version:"))
        #expect(readableDiagnostic[3].starts(with: "Language:"))
        #expect(readableDiagnostic[4].starts(with: "Timezone:"))
        #expect(readableDiagnostic[5].starts(with: "Connection Status:"))
    }

    struct ConnectionStatusArguments {
        let interfaceType: NWInterface.InterfaceType?
        let expectedConnectionStatus: String
    }

    @Test(
        arguments: [
            ConnectionStatusArguments(
                interfaceType: .wifi,
                expectedConnectionStatus: "WiFi"
            ),
            ConnectionStatusArguments(
                interfaceType: .cellular,
                expectedConnectionStatus: "Cellular"
            ),
            ConnectionStatusArguments(
                interfaceType: .wiredEthernet,
                expectedConnectionStatus: "Ethernet"
            ),
            ConnectionStatusArguments(
                interfaceType: nil,
                expectedConnectionStatus: "No internet connection"
            ),
            ConnectionStatusArguments(
                interfaceType: .other,
                expectedConnectionStatus: "Other"
            )
        ]
    ) func readableDiagnostic_shouldIncludeConnectionStatus(
        arguments: ConnectionStatusArguments
    ) async {
        let sut = makeSUT(connectionStatus: { arguments.interfaceType })

        #expect(await sut.readableDiagnostic().contains("Connection Status: \(arguments.expectedConnectionStatus)"))
    }

    // MARK: - Test Helpers

    private func makeSUT(
        deviceName: String? = nil,
        osType: String? = nil,
        osVersion: String? = nil,
        language: String? = nil,
        timezone: String = "timezone",
        connectionStatus: @escaping () async -> NWInterface.InterfaceType? = { .wifi }
    ) -> DeviceInformation {
        DeviceInformation(
            deviceName: deviceName,
            osType: osType,
            osVersion: osVersion,
            language: language,
            timezone: timezone,
            connectionStatus: connectionStatus
        )
    }

}
