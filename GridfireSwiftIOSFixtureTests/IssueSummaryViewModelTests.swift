import XCTest
@testable import GridfireSwiftIOSFixture

final class IssueSummaryViewModelTests: XCTestCase {
    func testHeadlineAndSubtitleUseSummaryMessageAndTotal() {
        let viewModel = IssueSummaryViewModel(
            summary: TriageSummary(
                openCount: 2,
                watchingCount: 1,
                resolvedCount: 1,
                highPriorityOpenCount: 1,
                staleOpenCount: 0
            )
        )

        XCTAssertEqual(viewModel.headline, "1 high priority open")
        XCTAssertEqual(viewModel.subtitle, "4 issues tracked")
    }

    func testTilesExposeStableIdsAndValues() {
        let viewModel = IssueSummaryViewModel(
            summary: TriageSummary(
                openCount: 0,
                watchingCount: 2,
                resolvedCount: 5,
                highPriorityOpenCount: 0,
                staleOpenCount: 0
            )
        )

        XCTAssertEqual(viewModel.tiles.map(\.id), ["open", "watching", "resolved"])
        XCTAssertEqual(viewModel.tiles.map(\.value), ["0", "2", "5"])
        XCTAssertEqual(viewModel.tiles.map(\.isEmphasized), [false, true, false])
    }
}

