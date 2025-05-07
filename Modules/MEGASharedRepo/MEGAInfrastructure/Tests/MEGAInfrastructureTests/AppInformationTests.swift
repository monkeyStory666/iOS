// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAInfrastructure
import Testing

struct AppInformationTests {
    @Test func readableDiagnostic_shouldIncludeAppName() async {
        let appName = String.random(withPrefix: "anyAppName")
        let sut = makeSUT(appName: appName)

        #expect(sut.appName == appName)
        #expect(await sut.readableDiagnostic().contains("App Name: \(appName)"))
    }

    @Test func readableDiagnostic_whenAppNameNil_shouldIncludePlaceholder() async {
        let sut = makeSUT(appName: nil)

        #expect(sut.appName == "(APP_NAME)")
        #expect(await sut.readableDiagnostic().contains("App Name: (APP_NAME)"))
    }

    @Test func readableDiagnostic_shouldIncludeAppVersion_andBuildNumber() async {
        let appVersion = String.random(withPrefix: "anyAppVersion")
        let buildNumber = String.random(withPrefix: "anyBuildNumber")
        let sut = makeSUT(appVersion: appVersion, buildNumber: buildNumber)

        #expect(sut.appVersion == appVersion)
        #expect(sut.buildNumber == buildNumber)
        #expect(await sut.readableDiagnostic().contains("App Version: \(appVersion) (\(buildNumber))"))
    }

    @Test func readableDiagnostic_whenAppVersionAndBuildNumberNil_shouldIncludePlaceholder() async {
        let sut = makeSUT(appVersion: nil, buildNumber: nil)

        #expect(sut.appVersion == "(APP_VERSION)")
        #expect(sut.buildNumber == "(APP_VERSION)")
        #expect(await sut.readableDiagnostic().contains("App Version: (APP_VERSION) ((APP_VERSION))"))
    }

    @Test func readableDiagnostic_orderOfProperties() async {
        let sut = makeSUT()

        let readableDiagnostic = await sut.readableDiagnostic().components(separatedBy: .newlines)

        #expect(readableDiagnostic.count == 3)
        #expect(readableDiagnostic[0] == "**App Information**")
        #expect(readableDiagnostic[1].starts(with: "App Name:"))
        #expect(readableDiagnostic[2].starts(with: "App Version:"))
    }

    // MARK: - Test Helpers

    private func makeSUT(
        appVersion: String? = nil,
        buildNumber: String? = nil,
        appName: String? = nil
    ) -> AppInformation {
        AppInformation(
            appVersion: appVersion,
            buildNumber: buildNumber,
            appName: appName
        )
    }
}
