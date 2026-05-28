import XCTest
@testable import GridfireSwiftIOSFixture

@MainActor
final class IssueListViewModelTests: XCTestCase {
    func testIssueFilterCaseOrderIncludesHighPriorityAfterResolved() {
        // harness:criterion=c-high-priority-filter-case-exists,c-high-priority-picker-order
        let filters = IssueFilter.allCases
        let resolvedIndex = filters.firstIndex(of: .resolved)!
        let highPriorityIndex = filters.firstIndex(of: .highPriority)!

        XCTAssertEqual(highPriorityIndex, filters.index(after: resolvedIndex))
    }

    func testHighPriorityFilterTitle() {
        // harness:criterion=c-high-priority-filter-title
        XCTAssertEqual(IssueFilter.highPriority.title, "High Priority")
    }

    func testExistingFilterTitlesAndVisibleResultsStayUnchanged() {
        // harness:criterion=c-existing-filters-unaffected
        XCTAssertEqual(IssueFilter.all.title, "All")
        XCTAssertEqual(IssueFilter.open.title, "Open")
        XCTAssertEqual(IssueFilter.watching.title, "Watch")
        XCTAssertEqual(IssueFilter.resolved.title, "Done")

        let viewModel = IssueListViewModel(store: TriageIssueStore())
        let expectedIDs: [(IssueFilter, [TriageIssue.ID])] = [
            (
                .all,
                [
                    TriageIssueStore.firstID,
                    TriageIssueStore.secondID,
                    TriageIssueStore.thirdID,
                    TriageIssueStore.fourthID
                ]
            ),
            (
                .open,
                [
                    TriageIssueStore.firstID,
                    TriageIssueStore.fourthID
                ]
            ),
            (
                .watching,
                [
                    TriageIssueStore.secondID
                ]
            ),
            (
                .resolved,
                [
                    TriageIssueStore.thirdID
                ]
            )
        ]

        for (filter, expectedIDs) in expectedIDs {
            viewModel.filter = filter
            XCTAssertEqual(viewModel.visibleIssues.map(\.id), expectedIDs)
        }
    }

    func testDefaultListSortsByPriorityThenUpdatedTime() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

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

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [
            TriageIssueStore.firstID,
            TriageIssueStore.fourthID
        ])
    }

    func testHighPriorityFilterMatchesOnlyHighPriorityIssues() {
        // harness:criterion=c-high-priority-filter-predicate-passes-high,c-high-priority-filter-predicate-rejects-non-high
        let viewModel = IssueListViewModel(store: TriageIssueStore())
        viewModel.filter = .highPriority

        let highPriorityIssue = TriageIssueStore.sampleIssues.first { $0.priority == .high }!
        let nonHighPriorityIssue = TriageIssueStore.sampleIssues.first { $0.priority != .high }!

        XCTAssertTrue(viewModel.matchesFilter(highPriorityIssue))
        XCTAssertFalse(viewModel.matchesFilter(nonHighPriorityIssue))
    }

    func testHighPriorityFilterShowsOnlySampleHighPriorityIssue() {
        // harness:criterion=c-high-priority-visible-issues-contains-only-first-id
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = ""

        XCTAssertEqual(viewModel.visibleIssues.count, 1)
        XCTAssertEqual(viewModel.visibleIssues[0].id, TriageIssueStore.firstID)
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

    func testHighPriorityEmptyStateWhenNoHighPriorityIssuesExist() {
        // harness:criterion=c-high-priority-empty-state-no-match
        let nonHighPriorityIssues = TriageIssueStore.sampleIssues.filter { $0.priority != .high }
        let viewModel = IssueListViewModel(store: TriageIssueStore(issues: nonHighPriorityIssues))

        viewModel.filter = .highPriority
        viewModel.searchText = ""

        XCTAssertEqual(viewModel.emptyStateTitle, "No high-priority issues")
    }

    func testHighPrioritySearchNoMatchesUsesSearchEmptyState() {
        // harness:criterion=c-high-priority-search-overrides-empty-state
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = "zzznomatch"

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
        XCTAssertEqual(viewModel.emptyStateTitle, "No matching issues")
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

    func testIssueActionsStillUpdateIssueWhenHighPriorityFilterIsActive() {
        // harness:criterion=c-toggle-resolved-unaffected,c-mark-watching-unaffected,c-mark-open-unaffected
        let store = TriageIssueStore()
        let viewModel = IssueListViewModel(store: store)
        let issue = store.issue(withID: TriageIssueStore.firstID)!

        viewModel.filter = .highPriority

        viewModel.toggleResolved(issue)
        XCTAssertEqual(store.issue(withID: TriageIssueStore.firstID)?.state, .resolved)
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.firstID])

        viewModel.markWatching(issue)
        XCTAssertEqual(store.issue(withID: TriageIssueStore.firstID)?.state, .watching)
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.firstID])

        viewModel.markOpen(issue)
        XCTAssertEqual(store.issue(withID: TriageIssueStore.firstID)?.state, .open)
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.firstID])
    }
}
