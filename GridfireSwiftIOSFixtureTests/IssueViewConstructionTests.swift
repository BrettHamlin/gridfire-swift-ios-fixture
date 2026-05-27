import SwiftUI
import XCTest
@testable import GridfireSwiftIOSFixture

@MainActor
final class IssueViewConstructionTests: XCTestCase {
    func testIssueListViewCanBeConstructedWithFixtureStore() {
        let view = IssueListView(store: TriageIssueStore())

        XCTAssertNotNil(view.body)
    }

    func testIssueDetailViewCanBeConstructedForEveryFixtureIssue() {
        let formatter = IssueAccessibilityFormatter()

        for issue in TriageIssueStore.sampleIssues {
            let view = IssueDetailView(
                issue: issue,
                formatter: formatter,
                onToggleResolved: {},
                onWatch: {},
                onMarkOpen: {}
            )

            XCTAssertNotNil(view.body)
        }
    }
}

