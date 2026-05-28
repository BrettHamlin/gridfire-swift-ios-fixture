import XCTest
@testable import GridfireSwiftIOSFixture

@MainActor
final class IssueListViewModelTests: XCTestCase {
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

    func testHighPriorityFilterAppearsInAllCases() {
        //harness:criterion=c-high-priority-filter-case-exists,c-segmented-control-picks-up-high-priority,c-exhaustive-switch-compiles-with-high-priority
        XCTAssertTrue(IssueFilter.allCases.contains(.highPriority))
    }

    func testHighPriorityFilterTitleIsExact() {
        //harness:criterion=c-high-priority-filter-title-exact
        XCTAssertEqual(IssueFilter.highPriority.title, "High Priority")
    }

    func testFilterShowsOnlyHighPriorityIssues() {
        //harness:criterion=c-high-priority-filter-shows-only-high-issues,c-high-priority-filter-excludes-non-high-issues,c-matches-filter-high-priority-branch
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority

        XCTAssertFalse(viewModel.visibleIssues.isEmpty)
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { $0.priority == .high })
        XCTAssertEqual(viewModel.visibleIssues.filter { $0.priority != .high }.count, 0)
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.firstID])
    }

    func testHighPriorityFilterPreservesSortOrder() {
        //harness:criterion=c-high-priority-sort-pipeline-unchanged
        let olderHighID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let newerHighID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        let mediumID = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
        let issues = [
            TriageIssue.fixture(
                id: olderHighID,
                title: "Older high priority issue",
                productArea: "Checkout",
                summary: "Older high priority issue summary.",
                priority: .high,
                state: .open,
                owner: "Avery",
                updatedAt: Date(timeIntervalSince1970: 100)
            ),
            TriageIssue.fixture(
                id: mediumID,
                title: "Newest medium priority issue",
                productArea: "Analytics",
                summary: "Medium priority issue summary.",
                priority: .medium,
                state: .open,
                owner: "Morgan",
                updatedAt: Date(timeIntervalSince1970: 300)
            ),
            TriageIssue.fixture(
                id: newerHighID,
                title: "Newer high priority issue",
                productArea: "Search",
                summary: "Newer high priority issue summary.",
                priority: .high,
                state: .watching,
                owner: "Quinn",
                updatedAt: Date(timeIntervalSince1970: 200)
            )
        ]
        let viewModel = IssueListViewModel(store: TriageIssueStore(issues: issues))

        viewModel.filter = .highPriority

        let expectedOrder = issues
            .filter { $0.priority == .high }
            .sorted { lhs, rhs in
                if lhs.priority.sortRank != rhs.priority.sortRank {
                    return lhs.priority.sortRank < rhs.priority.sortRank
                }
                return lhs.updatedAt > rhs.updatedAt
            }
            .map(\.id)
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), expectedOrder)
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [newerHighID, olderHighID])
    }

    func testHighPriorityEmptyStateTitleIsExact() {
        //harness:criterion=c-high-priority-empty-state-title-exact
        let nonHighIssues = TriageIssueStore.sampleIssues.filter { $0.priority != .high }
        let viewModel = IssueListViewModel(store: TriageIssueStore(issues: nonHighIssues))

        viewModel.filter = .highPriority

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
        XCTAssertEqual(viewModel.emptyStateTitle, "No high-priority issues")
    }

    func testHighPriorityEmptyStateTitleIsHiddenWhenResultsExist() {
        //harness:criterion=c-high-priority-empty-state-not-shown-when-results-exist
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority

        XCTAssertFalse(viewModel.visibleIssues.isEmpty)
        XCTAssertNotEqual(viewModel.emptyStateTitle, "No high-priority issues")
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
        //harness:criterion=c-existing-filter-open-unaffected
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .open
        viewModel.searchText = "settings"

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
        XCTAssertEqual(viewModel.emptyStateTitle, "No matching issues")

        viewModel.searchText = "search"

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.fourthID])
        XCTAssertEqual(viewModel.filter, .open)
    }

    func testSearchComposesWithHighPriorityFilter() {
        //harness:criterion=c-high-priority-filter-composes-with-search
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = "payment"

        XCTAssertFalse(viewModel.visibleIssues.isEmpty)
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { issue in
            issue.priority == .high && issue.title.localizedCaseInsensitiveContains("payment")
        })
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.firstID])
        XCTAssertEqual(viewModel.filter, .highPriority)
    }

    func testHighPrioritySearchHidesNonMatchingHighIssues() {
        //harness:criterion=c-high-priority-search-narrows-non-matching-high-issues-hidden
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = "__no_match_xyz__"

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
    }

    func testTogglingResolvedUpdatesVisibleRows() {
        //harness:criterion=c-existing-filter-done-unaffected
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
        //harness:criterion=c-existing-filter-watch-unaffected
        let store = TriageIssueStore()
        let viewModel = IssueListViewModel(store: store)
        let issue = store.issue(withID: TriageIssueStore.firstID)!

        viewModel.select(issue)
        viewModel.filter = .watching

        XCTAssertEqual(viewModel.selectedIssue?.id, TriageIssueStore.firstID)
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { $0.state == .watching })
    }
}
