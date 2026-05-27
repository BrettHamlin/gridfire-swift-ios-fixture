import XCTest
@testable import GridfireSwiftIOSFixture

@MainActor
final class IssueListViewModelTests: XCTestCase {
    func testDefaultListSortsByPriorityThenUpdatedTime() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        // harness:criterion=c-matches-filter-all-still-returns-all-issues
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [
            TriageIssueStore.firstID,
            TriageIssueStore.secondID,
            TriageIssueStore.thirdID,
            TriageIssueStore.fourthID
        ])
    }

    func testFilterShowsOnlyOpenIssues() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .open

        // harness:criterion=c-matches-filter-open-unaffected
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [
            TriageIssueStore.firstID,
            TriageIssueStore.fourthID
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
        // harness:criterion=c-matches-filter-done-unaffected
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
        // harness:criterion=c-matches-filter-watch-unaffected
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { $0.state == .watching })
    }

    func testHighPriorityFilterTitleAndAllCases() {
        // harness:criterion=c-issue-filter-high-priority-case-exists,c-issue-filter-high-priority-title,c-issue-filter-all-cases-includes-high-priority
        XCTAssertEqual(IssueFilter.highPriority.title, "High")
        XCTAssertTrue(IssueFilter.allCases.contains(.highPriority))
    }

    func testHighPriorityFilterReturnsOnlyHighPriorityIssues() {
        let highIssue = Self.issue(id: TriageIssueStore.firstID, priority: .high)
        let mediumIssue = Self.issue(id: TriageIssueStore.secondID, priority: .medium)
        let lowIssue = Self.issue(id: TriageIssueStore.thirdID, priority: .low)
        let viewModel = IssueListViewModel(store: TriageIssueStore(issues: [
            mediumIssue,
            highIssue,
            lowIssue
        ]))

        viewModel.filter = .highPriority

        // harness:criterion=c-matches-filter-high-priority-returns-high-issues-only,c-matches-filter-switch-exhaustive
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.firstID])
    }

    func testHighPriorityFilterShowsFixtureIssue() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority

        // harness:criterion=c-visible-issues-high-priority-filter-fixture-issue
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.firstID])
    }

    func testHighPriorityFilterEmptyStateTitle() {
        let viewModel = IssueListViewModel(store: TriageIssueStore(issues: [
            Self.issue(id: TriageIssueStore.secondID, priority: .medium),
            Self.issue(id: TriageIssueStore.thirdID, priority: .low)
        ]))

        viewModel.filter = .highPriority

        // harness:criterion=c-empty-state-title-high-priority,c-empty-state-title-switch-exhaustive
        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
        XCTAssertEqual(viewModel.emptyStateTitle, "No high-priority issues")
    }

    func testHighPriorityFilterSearchNarrowsResults() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = "analytics"

        // harness:criterion=c-high-priority-filter-search-narrows-results
        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
    }

    func testHighPriorityFilterSearchPreservesMatchingIssue() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = "payment sheet"

        // harness:criterion=c-high-priority-filter-search-preserves-match
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.firstID])
    }

    private static func issue(
        id: TriageIssue.ID,
        priority: IssuePriority,
        state: IssueState = .open,
        updatedAt: Date = Date(timeIntervalSince1970: 1_000)
    ) -> TriageIssue {
        TriageIssue.fixture(
            id: id,
            title: "Issue \(id.uuidString)",
            productArea: "Fixture",
            summary: "Fixture summary",
            priority: priority,
            state: state,
            owner: "Tester",
            updatedAt: updatedAt
        )
    }
}
