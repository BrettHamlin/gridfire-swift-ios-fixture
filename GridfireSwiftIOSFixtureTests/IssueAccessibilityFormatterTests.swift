import XCTest
@testable import GridfireSwiftIOSFixture

final class IssueAccessibilityFormatterTests: XCTestCase {
    func testRowLabelIncludesActionableState() {
        let issue = TriageIssueStore.sampleIssues[0]
        let formatter = IssueAccessibilityFormatter()

        XCTAssertEqual(
            formatter.rowLabel(for: issue),
            "Payment sheet does not recover after network loss, High priority, Open, owned by Avery"
        )
    }

    func testResolveButtonLabelReflectsCurrentState() {
        let formatter = IssueAccessibilityFormatter()
        let openIssue = TriageIssueStore.sampleIssues[0]
        let resolvedIssue = TriageIssueStore.sampleIssues[2]

        XCTAssertEqual(
            formatter.resolveButtonLabel(for: openIssue),
            "Resolve Payment sheet does not recover after network loss"
        )
        XCTAssertEqual(
            formatter.resolveButtonLabel(for: resolvedIssue),
            "Reopen Settings save button remains enabled after submit"
        )
    }

    func testWatchButtonLabelReflectsCurrentState() {
        let formatter = IssueAccessibilityFormatter()
        let openIssue = TriageIssueStore.sampleIssues[0]
        let watchedIssue = TriageIssueStore.sampleIssues[1]

        XCTAssertEqual(
            formatter.watchButtonLabel(for: openIssue),
            "Watch Payment sheet does not recover after network loss"
        )
        XCTAssertEqual(
            formatter.watchButtonLabel(for: watchedIssue),
            "Watching Dashboard chart hides empty-state copy"
        )
    }
}

