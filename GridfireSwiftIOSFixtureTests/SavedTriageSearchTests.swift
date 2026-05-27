import XCTest
@testable import GridfireSwiftIOSFixture

final class SavedTriageSearchTests: XCTestCase {
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

    func testAccessibilitySummaryIncludesHighPriorityFilterTitle() {
        let search = SavedTriageSearch(
            title: "Critical path",
            query: "",
            filter: .highPriority,
            includeResolved: true
        )

        // harness:criterion=c-saved-triage-search-accessibility-summary-includes-high
        XCTAssertTrue(search.accessibilitySummary.contains("High"))
    }

    func testStoreSortsSavedSearchesByTitle() {
        let store = SavedTriageSearchStore(searches: [])
        store.save(SavedTriageSearch(title: "Zeta", query: "", filter: .all, includeResolved: true))
        store.save(SavedTriageSearch(title: "Alpha", query: "", filter: .all, includeResolved: true))

        XCTAssertEqual(store.searches.map(\.title), ["Alpha", "Zeta"])
    }
}
