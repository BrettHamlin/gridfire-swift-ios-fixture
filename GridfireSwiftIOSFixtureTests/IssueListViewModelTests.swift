import XCTest
@testable import GridfireSwiftIOSFixture

@MainActor
final class IssueListViewModelTests: XCTestCase {
    func testIssueFilterIncludesHighPriorityMetadata() {
        //harness:criterion=c-issue-filter-high-priority-case-exists,c-issue-filter-high-priority-title,c-issue-filter-all-cases-count,c-issue-list-view-renders-five-segments
        XCTAssertTrue(IssueFilter.allCases.contains(.highPriority))
        XCTAssertEqual(IssueFilter.highPriority.title, "High Priority")
        XCTAssertEqual(IssueFilter.allCases.count, 5)
    }

    func testDefaultListSortsByPriorityThenUpdatedTime() {
        //harness:criterion=c-existing-filter-all-unaffected
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [
            TriageIssueStore.firstID,
            TriageIssueStore.secondID,
            TriageIssueStore.thirdID,
            TriageIssueStore.fourthID
        ])
    }

    func testFilterShowsOnlyOpenIssues() {
        //harness:criterion=c-existing-filter-open-unaffected
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .open

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [
            TriageIssueStore.firstID,
            TriageIssueStore.fourthID
        ])
    }

    func testHighPriorityFilterMatchesOnlyHighPriorityIssues() {
        //harness:criterion=c-matches-filter-high-priority-returns-true-for-high,c-matches-filter-high-priority-returns-false-for-non-high
        let store = TriageIssueStore()
        let viewModel = IssueListViewModel(store: store)
        let highPriorityIssue = store.issue(withID: TriageIssueStore.firstID)!
        let nonHighPriorityIssues = store.issues.filter { $0.priority != .high }

        viewModel.filter = .highPriority

        XCTAssertEqual(highPriorityIssue.priority, .high)
        XCTAssertTrue(viewModel.matchesFilter(highPriorityIssue))
        XCTAssertFalse(nonHighPriorityIssues.isEmpty)
        for issue in nonHighPriorityIssues {
            XCTAssertFalse(viewModel.matchesFilter(issue), "\(issue.id) should not match the high-priority filter")
        }
    }

    func testHighPriorityFilterShowsOnlyHighPriorityFixtureIssue() {
        //harness:criterion=c-visible-issues-high-priority-filter-returns-only-high-priority
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = ""

        XCTAssertEqual(viewModel.visibleIssues.count, 1)
        XCTAssertEqual(viewModel.visibleIssues[0].id, TriageIssueStore.firstID)
    }

    func testHighPriorityFilterSearchNarrowsToEmptyResult() {
        //harness:criterion=c-visible-issues-high-priority-search-narrows
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = "zzznomatch"

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
        XCTAssertFalse(viewModel.emptyStateTitle.isEmpty)
    }

    func testHighPriorityFilterUsesSpecificEmptyStateTitle() {
        //harness:criterion=c-empty-state-title-high-priority-branch
        let nonHighPriorityIssues = TriageIssueStore.sampleIssues.filter { $0.priority != .high }
        let viewModel = IssueListViewModel(store: TriageIssueStore(issues: nonHighPriorityIssues))

        viewModel.filter = .highPriority
        viewModel.searchText = ""

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
        XCTAssertFalse(viewModel.emptyStateTitle.isEmpty)
        XCTAssertNotEqual(viewModel.emptyStateTitle, "No issues")
        XCTAssertNotEqual(viewModel.emptyStateTitle, "No matching issues")
    }

    func testHighPriorityFilterSearchComposesWithMatchingText() {
        //harness:criterion=c-visible-issues-high-priority-search-composes
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = "payment"

        XCTAssertEqual(viewModel.visibleIssues.count, 1)
        XCTAssertEqual(viewModel.visibleIssues[0].id, TriageIssueStore.firstID)
    }

    func testWatchingAndResolvedFiltersIgnorePriority() {
        //harness:criterion=c-existing-filter-watch-unaffected,c-existing-filter-done-unaffected
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .watching
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.secondID])

        viewModel.filter = .resolved
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.thirdID])
    }

    func testSummaryTileIDsStayUnchanged() {
        //harness:criterion=c-summary-tile-ids-unchanged
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        XCTAssertEqual(viewModel.summaryViewModel.tiles.map(\.id), [
            "open",
            "watching",
            "resolved"
        ])
    }

    func testSearchMatchesTitleAreaAndOwner() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.searchText = "analytics"
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.secondID])

        viewModel.searchText = "quinn"
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.fourthID])

        viewModel.searchText = "save button"
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.thirdID])
    }

    func testSearchAndFilterComposeWithoutLosingFilterState() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .open
        viewModel.searchText = "settings"

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
        XCTAssertEqual(viewModel.emptyStateTitle, "No matching issues")

        viewModel.searchText = "search"

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.fourthID])
        XCTAssertEqual(viewModel.filter, .open)
    }

    func testTogglingResolvedUpdatesVisibleRows() {
        let store = TriageIssueStore()
        let viewModel = IssueListViewModel(store: store)

        viewModel.filter = .resolved
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.thirdID])

        let openIssue = store.issue(withID: TriageIssueStore.firstID)!
        viewModel.toggleResolved(openIssue)

        XCTAssertEqual(Set(viewModel.visibleIssues.map(\.id)), [
            TriageIssueStore.firstID,
            TriageIssueStore.thirdID
        ])
    }

    func testSelectionSurvivesFilteringWhenIssueStillExists() {
        let store = TriageIssueStore()
        let viewModel = IssueListViewModel(store: store)
        let issue = store.issue(withID: TriageIssueStore.firstID)!

        viewModel.select(issue)
        viewModel.filter = .watching

        XCTAssertEqual(viewModel.selectedIssue?.id, TriageIssueStore.firstID)
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { $0.state == .watching })
    }
}
