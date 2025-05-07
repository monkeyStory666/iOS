// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAConnectivity
import Combine
import MEGAConnectivityMocks
import MEGATest
import Testing

struct ConnectionUseCaseTests {
    @Test func init_shouldStartMonitoringNetworkConnection() {
        let mockNetworkMonitor = MockConnectionMonitor()
        mockNetworkMonitor.swt.assertActions(shouldBe: [])

        let sut = makeSUT(networkConnectionMonitor: mockNetworkMonitor)
        _ = sut

        mockNetworkMonitor.swt.assertActions(shouldBe: [.startMonitoring])
    }

    @Test func init_whenNetworkConnected_andStop_whenNetworkDisconnected_shouldMonitorInternetConnection() {
        let mockNetworkMonitor = MockConnectionMonitor(isConnected: true)
        let mockInternetMonitor = MockConnectionMonitor()
        mockInternetMonitor.swt.assertActions(shouldBe: [])

        let sut = makeSUT(
            networkConnectionMonitor: mockNetworkMonitor,
            internetConnectionMonitor: mockInternetMonitor
        )
        _ = sut

        mockInternetMonitor.swt.assertActions(shouldBe: [.startMonitoring])

        mockNetworkMonitor.simulate(isConnected: false)

        mockInternetMonitor.swt.assertActions(shouldBe: [.startMonitoring, .stopMonitoring])
    }

    @Test func isConnected_whenMonitoringStarted_shouldMonitorInternetConnectivity() {
        let mockNetworkMonitor = MockConnectionMonitor(isConnected: true)
        let mockInternetMonitor = MockConnectionMonitor(isConnected: true)
        let sut = makeSUT(
            networkConnectionMonitor: mockNetworkMonitor,
            internetConnectionMonitor: mockInternetMonitor
        )

        let isConnectedSpy = sut.isConnectedPublisher.spy()
        #expect(isConnectedSpy.values == [true])
        #expect(sut.isConnected)

        mockInternetMonitor.simulate(isConnected: false)
        #expect(isConnectedSpy.values == [true, false])
        #expect(sut.isConnected == false)

        mockInternetMonitor.simulate(isConnected: true)
        #expect(isConnectedSpy.values == [true, false, true])
        #expect(sut.isConnected)
    }

    @Test func isConnected_whenNetworkDisconnected_shouldReturnFalse_andStopMonitoringInternet() {
        let mockNetworkMonitor = MockConnectionMonitor(isConnected: true)
        let mockInternetMonitor = MockConnectionMonitor(isConnected: true)
        let sut = makeSUT(
            networkConnectionMonitor: mockNetworkMonitor,
            internetConnectionMonitor: mockInternetMonitor
        )

        let isConnectedSpy = sut.isConnectedPublisher.spy()
        #expect(isConnectedSpy.values == [true])
        #expect(sut.isConnected)

        mockNetworkMonitor.simulate(isConnected: false)
        #expect(isConnectedSpy.values == [true, false])
        #expect(sut.isConnected == false)

        mockInternetMonitor.simulate(isConnected: false)
        #expect(isConnectedSpy.values == [true, false])
        #expect(sut.isConnected == false)

        mockInternetMonitor.simulate(isConnected: true)
        #expect(isConnectedSpy.values == [true, false])
        #expect(sut.isConnected == false)
    }
    
    @Test func isNetworkConnected_whenMonitoringStarted_shouldMonitorInternetConnectivity() {
        let mockNetworkMonitor = MockConnectionMonitor(isConnected: true)
        let sut = makeSUT(networkConnectionMonitor: mockNetworkMonitor)

        let isConnectedSpy = sut.isConnectedPublisher.spy()
        #expect(isConnectedSpy.values == [true])
        #expect(sut.isNetworkConnected)

        mockNetworkMonitor.simulate(isConnected: false)
        #expect(isConnectedSpy.values == [true, false])
        #expect(sut.isNetworkConnected == false)

        mockNetworkMonitor.simulate(isConnected: true)
        #expect(isConnectedSpy.values == [true, false, true])
        #expect(sut.isNetworkConnected)
    }

    @Test func deinit_shouldStopMonitoring() {
        let mockNetworkMonitor = MockConnectionMonitor(isConnected: true)
        let mockInternetMonitor = MockConnectionMonitor(isConnected: true)
        var sut: ConnectionUseCase? = makeSUT(
            networkConnectionMonitor: mockNetworkMonitor,
            internetConnectionMonitor: mockInternetMonitor
        )
        _ = sut

        sut = nil

        mockNetworkMonitor.swt.assertActions(shouldBe: [.startMonitoring, .stopMonitoring])
        mockInternetMonitor.swt.assertActions(shouldBe: [.startMonitoring, .stopMonitoring])
    }

    // MARK: - Connectivity Status Tests

    @Test func connectivityStatus_whenConnectedToInternet() {
        assertConnectivityStatus(
            .connectedToInternet,
            whenNetworkIsConnected: true,
            andInternetIsConnected: true
        )
    }

    @Test func connectivityStatus_whenNetworkConnectedWithoutInternet() {
        assertConnectivityStatus(
            .connectedWithoutInternet,
            whenNetworkIsConnected: true,
            andInternetIsConnected: false
        )
    }

    @Test func connectivityStatus_whenDisconnected() {
        assertConnectivityStatus(
            .disconnected,
            whenNetworkIsConnected: false,
            andInternetIsConnected: false
        )
    }

    // MARK: - Test Helpers

    private func assertConnectivityStatus(
        _ expectedStatus: ConnectivityStatus,
        whenNetworkIsConnected networkIsConnected: Bool,
        andInternetIsConnected internetIsConnected: Bool
    ) {
        let mockNetworkMonitor = MockConnectionMonitor(
            isConnected: networkIsConnected
        )
        let mockInternetMonitor = MockConnectionMonitor(
            isConnected: internetIsConnected
        )
        let sut = makeSUT(
            networkConnectionMonitor: mockNetworkMonitor,
            internetConnectionMonitor: mockInternetMonitor
        )

        let publisherSpy = sut.connectivityStatusPublisher.spy()

        #expect(publisherSpy.values == [expectedStatus])
        #expect(sut.connectivityStatus == expectedStatus)
    }

    private func makeSUT(
        networkConnectionMonitor: some ConnectionMonitorProtocol = MockConnectionMonitor(),
        internetConnectionMonitor: some ConnectionMonitorProtocol = MockConnectionMonitor()
    ) -> ConnectionUseCase {
        ConnectionUseCase(
            networkConnectionMonitor: networkConnectionMonitor,
            internetConnectionMonitor: internetConnectionMonitor
        )
    }
}
