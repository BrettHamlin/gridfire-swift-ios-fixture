import XCTest
@testable import GridfireSwiftIOSFixture

@MainActor
final class IssueListViewModelTests: XCTestCase {
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

    // harness:criterion=c-high-priority-enum-case-exists,c-high-priority-title-string,c-picker-has-five-segments,c-title-switch-exhaustive
    func testHighPriorityFilterTitleAndAllCasesOrder() {
        XCTAssertEqual(IssueFilter.highPriority.title, "High Priority")
        XCTAssertEqual(IssueFilter.allCases.count, 5)
        XCTAssertEqual(IssueFilter.allCases.last, .highPriority)
        XCTAssertEqual(IssueFilter.allCases.last?.title, "High Priority")
    }

    // harness:criterion=c-high-priority-filter-matches-high-priority-issues,c-high-priority-filter-excludes-non-high-priority-issues,c-matches-filter-switch-exhaustive,c-tests-in-existing-file
    func testHighPriorityFilterShowsOnlyHighPriorityIssuesFromSampleIssues() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())
        let expectedHighPriorityIssues = TriageIssueStore.sampleIssues
            .filter { $0.priority == .high }
            .map(\.id)

        viewModel.filter = .highPriority

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), expectedHighPriorityIssues)
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { $0.priority == .high })
        XCTAssertTrue(viewModel.visibleIssues.filter { $0.priority != .high }.isEmpty)
    }

    // harness:criterion=c-high-priority-empty-state-title,c-high-priority-search-overrides-empty-state-title,c-empty-state-title-switch-exhaustive,c-tests-in-existing-file
    func testHighPriorityEmptyStateTitleAndSearchOverride() {
        let issuesWithoutHighPriority = TriageIssueStore.sampleIssues.filter { $0.priority != .high }
        let viewModel = IssueListViewModel(store: TriageIssueStore(issues: issuesWithoutHighPriority))

        viewModel.filter = .highPriority

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
        XCTAssertEqual(viewModel.emptyStateTitle, "No high-priority issues")

        viewModel.searchText = "not present in any issue"

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
        XCTAssertEqual(viewModel.emptyStateTitle, "No matching issues")
    }

    // harness:criterion=c-high-priority-search-composition,c-tests-in-existing-file
    func testHighPrioritySearchCompositionRequiresPriorityAndSearchMatch() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = "payment"

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.firstID])
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { issue in
            issue.priority == .high
                && (
                    issue.title.localizedCaseInsensitiveContains(viewModel.searchText)
                    || issue.productArea.localizedCaseInsensitiveContains(viewModel.searchText)
                    || issue.owner.localizedCaseInsensitiveContains(viewModel.searchText)
                )
        })
    }

    // harness:criterion=c-summary-tiles-unaffected-by-high-priority-filter,c-tests-in-existing-file
    func testHighPriorityFilterDoesNotChangeSummaryViewModel() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .all
        let allFilterSummary = viewModel.summaryViewModel

        viewModel.filter = .highPriority

        XCTAssertEqual(viewModel.summaryViewModel, allFilterSummary)
    }

    // harness:criterion=c-all-filter-preserved,c-open-filter-preserved,c-watch-filter-preserved,c-done-filter-preserved
    func testExistingFiltersRemainPreserved() {
        let expectedIDsByFilter: [(filter: IssueFilter, expectedIDs: [TriageIssue.ID])] = [
            (
                filter: .all,
                expectedIDs: [
                    TriageIssueStore.firstID,
                    TriageIssueStore.secondID,
                    TriageIssueStore.thirdID,
                    TriageIssueStore.fourthID
                ]
            ),
            (
                filter: .open,
                expectedIDs: [
                    TriageIssueStore.firstID,
                    TriageIssueStore.fourthID
                ]
            ),
            (
                filter: .watching,
                expectedIDs: [
                    TriageIssueStore.secondID
                ]
            ),
            (
                filter: .resolved,
                expectedIDs: [
                    TriageIssueStore.thirdID
                ]
            )
        ]

        for expectation in expectedIDsByFilter {
            let viewModel = IssueListViewModel(store: TriageIssueStore())

            viewModel.filter = expectation.filter

            XCTAssertEqual(viewModel.visibleIssues.map(\.id), expectation.expectedIDs)
        }
    }
}
