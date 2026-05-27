import XCTest
@testable import GridfireSwiftIOSFixture

final class TriageSummaryTests: XCTestCase {
    func testSummaryCountsIssueStates() {
        let calculator = TriageSummaryCalculator(staleDate: Date(timeIntervalSince1970: 1_550))

        let summary = calculator.summary(for: TriageIssueStore.sampleIssues)

        XCTAssertEqual(summary.openCount, 2)
        XCTAssertEqual(summary.watchingCount, 1)
        XCTAssertEqual(summary.resolvedCount, 1)
        XCTAssertEqual(summary.totalCount, 4)
    }

    func testSummaryCountsHighPriorityOpenIssues() {
        let calculator = TriageSummaryCalculator(staleDate: Date(timeIntervalSince1970: 1_550))

        let summary = calculator.summary(for: TriageIssueStore.sampleIssues)

        XCTAssertEqual(summary.highPriorityOpenCount, 1)
        XCTAssertTrue(summary.needsAttention)
        XCTAssertEqual(summary.statusMessage, "1 high priority open")
    }

    func testSummaryFallsBackToStaleOpenMessage() {
        let issues = [
            TriageIssue.fixture(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
                title: "Old medium issue",
                productArea: "Support",
                summary: "Old issue",
                priority: .medium,
                state: .open,
                owner: "Taylor",
                updatedAt: Date(timeIntervalSince1970: 100)
            )
        ]
        let calculator = TriageSummaryCalculator(staleDate: Date(timeIntervalSince1970: 200))

        let summary = calculator.summary(for: issues)

        XCTAssertEqual(summary.staleOpenCount, 1)
        XCTAssertEqual(summary.statusMessage, "1 stale open")
    }

    func testSummaryReportsAllClearWhenNothingNeedsAttention() {
        let issues = [
            TriageIssue.fixture(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
                title: "Resolved issue",
                productArea: "Support",
                summary: "Resolved issue",
                priority: .high,
                state: .resolved,
                owner: "Taylor",
                updatedAt: Date(timeIntervalSince1970: 300)
            )
        ]
        let calculator = TriageSummaryCalculator(staleDate: Date(timeIntervalSince1970: 200))

        let summary = calculator.summary(for: issues)

        XCTAssertFalse(summary.needsAttention)
        XCTAssertEqual(summary.statusMessage, "All clear")
    }
}

