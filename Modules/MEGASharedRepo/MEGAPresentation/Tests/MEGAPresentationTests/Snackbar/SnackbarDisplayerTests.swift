// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAPresentation
import MEGATest
import Testing

struct SnackbarDisplayerTests {
    private let mockViewModel = SecondarySceneViewModel(snackbarEntity: nil)

    @Test func displaySnackbar_whenSingleSnackbar_shouldDisplaySnackbar() {
        var onDismissCallCount = 0
        let spy = mockViewModel.$snackbarEntity.spy()
        let sut = makeSUT()

        let snackbar = SnackbarEntity(text: "Test Snackbar", onDismiss: { onDismissCallCount += 1 })

        sut.display(snackbar)
        #expect(spy.values == [snackbar])
        #expect(onDismissCallCount == 0)

        mockViewModel.snackbarEntity?.onDismiss?()
        #expect(spy.values == [snackbar, nil])
        #expect(onDismissCallCount == 1)
    }

    @Test func displaySnackbar_whenMultipleSnackbars_shouldQueueAndDisplayInOrder() {
        let snackbarSpy = mockViewModel.$snackbarEntity.spy()
        let sut = makeSUT()

        let snackbar1 = SnackbarEntity(text: "Test Snackbar 1")
        let snackbar2 = SnackbarEntity(text: "Test Snackbar 2")
        let snackbar3 = SnackbarEntity(text: "Test Snackbar 3")

        sut.display(snackbar1)
        sut.display(snackbar2)
        sut.display(snackbar3)

        #expect(snackbarSpy.values == [snackbar1])

        mockViewModel.snackbarEntity?.onDismiss?()
        #expect(snackbarSpy.values == [snackbar1, nil, snackbar2])

        mockViewModel.snackbarEntity?.onDismiss?()
        #expect(snackbarSpy.values == [snackbar1, nil, snackbar2, nil, snackbar3])

        mockViewModel.snackbarEntity?.onDismiss?()
        #expect(snackbarSpy.values == [snackbar1, nil, snackbar2, nil, snackbar3, nil])
    }

    @Test func displaySnackbar_whenConsecutiveSameSnackbars_shouldNotAddToQueue_unlessItHasBeenDismissed() {
        let snackbarSpy = mockViewModel.$snackbarEntity.spy()
        let sut = makeSUT()

        let snackbar1 = SnackbarEntity(text: "Same snackbar text")
        let snackbar2 = SnackbarEntity(text: "Same snackbar text")
        let snackbar3 = SnackbarEntity(text: "Same snackbar text")

        sut.display(snackbar1)
        sut.display(snackbar2)
        #expect(snackbarSpy.values == [snackbar1])

        mockViewModel.snackbarEntity?.onDismiss?()
        #expect(snackbarSpy.values == [snackbar1, nil])

        sut.display(snackbar3)
        #expect(snackbarSpy.values == [snackbar1, nil, snackbar3])

        mockViewModel.snackbarEntity?.onDismiss?()
        #expect(snackbarSpy.values == [snackbar1, nil, snackbar3, nil])
    }

    @Test func displaySnackbar_whenNotConsecutiveSameSnackbars_shouldAddToQueue() {
        let snackbarSpy = mockViewModel.$snackbarEntity.spy()
        let sut = makeSUT()

        let snackbar1 = SnackbarEntity(text: "Same snackbar text")
        let snackbar2 = SnackbarEntity(text: "Different snackbar text")
        let snackbar3 = SnackbarEntity(text: "Same snackbar text")

        sut.display(snackbar1)
        sut.display(snackbar2)
        sut.display(snackbar3)
        #expect(snackbarSpy.values == [snackbar1])

        mockViewModel.snackbarEntity?.onDismiss?()
        #expect(snackbarSpy.values == [snackbar1, nil, snackbar2])

        mockViewModel.snackbarEntity?.onDismiss?()
        #expect(
            snackbarSpy.values ==
            [snackbar1, nil, snackbar2, nil, snackbar3]
        )
    }

    // MARK: - Test Helpers

    private typealias SUT = SnackbarDisplayer

    private func makeSUT() -> SUT {
        SnackbarDisplayer(updateSnackbarInViewModel: { snackbarEntity, completion in
            self.mockViewModel.snackbarEntity = snackbarEntity
            completion?()
        })
    }
}
