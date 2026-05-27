import XCTest
@testable import GridfireSwiftIOSFixture

final class SavedTriageSearchTests: XCTestCase {
    //harness:criterion=c-accessibility-summary-high-priority
    func testAccessibilitySummaryIncludesHighPriorityFilterTitle() {
        let search = SavedTriageSearch(
            title: "Urgent backlog",
            query: "",
            filter: .highPriority,
            includeResolved: true
        )

        let summary = search.accessibilitySummary

        XCTAssertFalse(summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        XCTAssertTrue(summary.contains(IssueFilter.highPriority.title))
    }

    func testAccessibilitySummaryIncludesFilterAndQuery() {
        let search = SavedTriageSearch(
            title: "Release blockers",
            query: " release ",
            filter: .watching,
            includeResolved: false
        )

        XCTAssertEqual(
            search.accessibilitySummary,
            "Release blockers, Watch, query release, excluding resolved issues"
        )
    }

    func testAccessibilitySummaryOmitsBlankQuery() {
        let search = SavedTriageSearch(
            title: "Open issues",
            query: " ",
            filter: .open,
            includeResolved: true
        )

        XCTAssertEqual(
            search.accessibilitySummary,
            "Open issues, Open, including resolved issues"
        )
    }

    func testStoreSortsSavedSearchesByTitle() {
        let store = SavedTriageSearchStore(searches: [])
        store.save(SavedTriageSearch(title: "Zeta", query: "", filter: .all, includeResolved: true))
        store.save(SavedTriageSearch(title: "Alpha", query: "", filter: .all, includeResolved: true))

        XCTAssertEqual(store.searches.map(\.title), ["Alpha", "Zeta"])
    }
}
