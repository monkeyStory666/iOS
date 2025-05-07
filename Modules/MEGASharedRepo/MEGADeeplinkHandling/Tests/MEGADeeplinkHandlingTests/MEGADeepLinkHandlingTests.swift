import XCTest
@testable import MEGADeeplinkHandling

final class MEGADeeplinkHandlingTests: XCTestCase {
    func testDirectDeepLink_shouldTriggerHandler() async {
        let exp = expectation(description: "Handler should be called")

        let sut = DeeplinkBuilder()
            .scheme("test")
            .build { _ in
                exp.fulfill()
            }

        sut.handle(URL(string:"test://unitTesting")!)
        await fulfillment(of: [exp], timeout: 1)
    }

    func testDirectDeepLink_withoutHost_shouldTriggerHandler() async {
        let exp = expectation(description: "Handler should be called")

        let sut = DeeplinkBuilder()
            .scheme("test")
            .build { _ in
                exp.fulfill()
            }

        sut.handle(URL(string:"test://")!)
        await fulfillment(of: [exp], timeout: 1)
    }

    func testRootDeepLink_shouldTriggerHandler() async {
        let exp = expectation(description: "Handler should be called")

        let sut = DeeplinkBuilder()
            .scheme("vpn")
            .host("test")
            .build { _ in
                exp.fulfill()
            }

        sut.handle(URL(string:"vpn://test/something")!)
        await fulfillment(of: [exp], timeout: 1)
    }


    func testGeneralDeepLink_shouldTriggerHandler() async {
        let exp = expectation(description: "Handler should be called")

        let sut = DeeplinkBuilder()
            .scheme("https")
            .host("vpn")
            .path { $0.starts(with: "/test") }
            .build { components in
                exp.fulfill()
            }

        sut.handle(URL(string:"https://vpn/test/something")!)
        await fulfillment(of: [exp], timeout: 1)
    }

    func testDeepLinkWithMultipleChildHandlers_shouldTriggerCorrectHandlers() async {
        let expectationFileId = expectation(description: "Handler for fileId be called")
        let expectationFolderId = expectation(description: "Handler for folderId be called")

        let componentHandlers: [DeeplinkHandling] = [
            SpecificQueryHandler(queryKey: "fileId") { components in
                XCTAssertEqual(components.queryItems.first?.key, "fileId")
                XCTAssertEqual(components.fragment, "fragmentFile")
                expectationFileId.fulfill()
            },
            SpecificQueryHandler(queryKey: "folderId") { components in
                XCTAssertEqual(components.queryItems.first?.key, "folderId")
                XCTAssertEqual(components.fragment, "fragmentFolder")
                expectationFolderId.fulfill()
            }
        ]

        let sut = DeeplinkBuilder()
            .scheme("https", "http")
            .host("mega.nz")
            .host("vpn.mega.nz")
            .path { $0.contains("file") }
            .path { $0.contains("folder") }
            .build(withChildHandlers: componentHandlers)

        sut.handle(URL(string: "https://mega.nz/file?fileId=12345#fragmentFile")!)
        sut.handle(URL(string: "http://vpn.mega.nz/folder?folderId=67890#fragmentFolder")!)


        await fulfillment(of: [expectationFileId], timeout: 1.0)
        await fulfillment(of: [expectationFolderId], timeout: 1.0)
    }

    func testDeeplinksPath_shouldTriggerHandlerOnlyForMatchingDeeplinks() async {
        var numbersOfTimeHandlerIsCalled = 0

        let sut = DeeplinkBuilder()
            .scheme("https")
            .host("mega.nz")
            .path("file")
            .build { _  in
                numbersOfTimeHandlerIsCalled += 1
            }

        sut.handle(URL(string: "https://mega.nz/file")!)
        sut.handle(URL(string: "https://mega.nz/fm/account/fileHistory")!)

        XCTAssertEqual(numbersOfTimeHandlerIsCalled, 1)
    }

    func testDeeplinkSchemeAndHost_withDirectString_whenLowercase_shouldIgnoreCase() async {
        let exp = expectation(description: "Handler should be called")

        let sut = DeeplinkBuilder()
            .scheme("HTTPS")
            .host("MEGA.NZ")
            .build { _ in
                exp.fulfill()
            }

        sut.handle(URL(string:"https://mega.nz")!)
        await fulfillment(of: [exp], timeout: 1)
    }

    func testDeeplinkSchemeAndHost_withDirectString_whenUppercase_shouldIgnoreCase() async {
        let exp = expectation(description: "Handler should be called")

        let sut = DeeplinkBuilder()
            .scheme("https")
            .host("mega.nz")
            .build { _ in
                exp.fulfill()
            }

        sut.handle(URL(string:"HTTPS://MEGA.NZ")!)
        await fulfillment(of: [exp], timeout: 1)
    }

    func testDeeplinkSchemeAndHost_withDirectString_whenMixedCase_shouldIgnoreCase() async {
        let exp = expectation(description: "Handler should be called")

        let sut = DeeplinkBuilder()
            .scheme("https")
            .host("mega.nz")
            .build { _ in
                exp.fulfill()
            }

        sut.handle(URL(string:"HtTpS://mEgA.nZ")!)
        await fulfillment(of: [exp], timeout: 1)
    }

    func testDeeplinkPath_withDirectString_shouldNotIgnoreCase() async {
        let exp = expectation(description: "Handler should be called")
        exp.isInverted = true

        let sut = DeeplinkBuilder()
            .scheme("https")
            .host("mega.nz")
            .path("file")
            .build { _ in
                exp.fulfill()
            }

        sut.handle(URL(string:"https://mega.nz/FILE")!)
        sut.handle(URL(string:"https://mega.nz/fIlE")!)
        sut.handle(URL(string:"https://mega.nz/FiLe")!)

        await fulfillment(of: [exp], timeout: 1)
    }
}
