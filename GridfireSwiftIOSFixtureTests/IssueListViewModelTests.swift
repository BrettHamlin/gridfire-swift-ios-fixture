import XCTest
@testable import GridfireSwiftIOSFixture

@MainActor
final class IssueListViewModelTests: XCTestCase {
    //harness:criterion=c-high-priority-case-exists,c-high-priority-title-string,c-segmented-picker-five-segments
    func testHighPriorityFilterCaseIsIncludedAndHasTitle() {
        XCTAssertEqual(IssueFilter.allCases.count, 5)
        XCTAssertTrue(IssueFilter.allCases.contains(.highPriority))

        let title = IssueFilter.highPriority.title
        XCTAssertFalse(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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

    //harness:criterion=c-all-filter-unaffected
    func testAllFilterShowsEverySampleIssue() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .all

        XCTAssertEqual(viewModel.visibleIssues.count, TriageIssueStore.sampleIssues.count)
        XCTAssertEqual(Set(viewModel.visibleIssues.map(\.id)), Set(TriageIssueStore.sampleIssues.map(\.id)))
    }

    //harness:criterion=c-open-filter-unaffected
    func testFilterShowsOnlyOpenIssues() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .open

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [
            TriageIssueStore.firstID,
            TriageIssueStore.fourthID
        ])
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { $0.state == .open })
    }

    //harness:criterion=c-watch-filter-unaffected
    func testFilterShowsOnlyWatchingIssues() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .watching

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.secondID])
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { $0.state == .watching })
    }

    //harness:criterion=c-done-filter-unaffected
    func testFilterShowsOnlyResolvedIssues() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .resolved

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.thirdID])
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { $0.state == .resolved })
    }

    //harness:criterion=c-matches-filter-high-priority-returns-true,c-switch-exhaustive-no-default
    func testHighPriorityFilterMatchesHighPriorityIssue() {
        let store = TriageIssueStore()
        let viewModel = IssueListViewModel(store: store)
        let issue = store.issue(withID: TriageIssueStore.firstID)!

        viewModel.filter = .highPriority

        XCTAssertTrue(viewModel.matchesFilter(issue))
    }

    //harness:criterion=c-matches-filter-high-priority-returns-false
    func testHighPriorityFilterRejectsNonHighPriorityIssue() {
        let store = TriageIssueStore()
        let viewModel = IssueListViewModel(store: store)
        let issue = store.issue(withID: TriageIssueStore.secondID)!

        viewModel.filter = .highPriority

        XCTAssertFalse(viewModel.matchesFilter(issue))
    }

    //harness:criterion=c-visible-issues-high-priority-only
    func testHighPriorityFilterShowsOnlyHighPriorityIssues() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())
        let expectedIDs = TriageIssueStore.sampleIssues
            .filter { $0.priority == .high }
            .map(\.id)

        viewModel.filter = .highPriority

        XCTAssertEqual(viewModel.visibleIssues.count, expectedIDs.count)
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { $0.priority == .high })
        XCTAssertTrue(viewModel.visibleIssues.contains { $0.id == TriageIssueStore.firstID })
        XCTAssertFalse(viewModel.visibleIssues.contains { $0.id == TriageIssueStore.secondID })
    }

    //harness:criterion=c-visible-issues-high-priority-matching-search
    func testHighPriorityFilterComposesWithMatchingSearch() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = "payment sheet"

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.firstID])
        XCTAssertEqual(viewModel.visibleIssues.first?.priority, .high)
    }

    //harness:criterion=c-visible-issues-high-priority-nonmatching-search
    func testHighPriorityFilterComposesWithNonmatchingSearch() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority
        viewModel.searchText = "zzz_no_match_zzz"

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
    }

    //harness:criterion=c-empty-state-title-high-priority
    func testHighPriorityFilterHasEmptyStateTitle() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .highPriority

        XCTAssertFalse(viewModel.emptyStateTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
