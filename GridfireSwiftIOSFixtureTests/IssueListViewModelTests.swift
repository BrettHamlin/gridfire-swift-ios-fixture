import XCTest
@testable import GridfireSwiftIOSFixture

@MainActor
final class IssueListViewModelTests: XCTestCase {
    // harness:criterion=c-existing-filter-all-unchanged
    func testDefaultListSortsByPriorityThenUpdatedTime() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [
            TriageIssueStore.firstID,
            TriageIssueStore.secondID,
            TriageIssueStore.thirdID,
            TriageIssueStore.fourthID
        ])
    }

    // harness:criterion=c-existing-filter-open-unchanged
    func testFilterShowsOnlyOpenIssues() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.filter = .open

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [
            TriageIssueStore.firstID,
            TriageIssueStore.fourthID
        ])
    }

    // harness:criterion=c-existing-filter-all-unchanged
    func testSearchMatchesTitleAreaAndOwner() {
        let viewModel = IssueListViewModel(store: TriageIssueStore())

        viewModel.searchText = "analytics"
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.secondID])

        viewModel.searchText = "quinn"
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.fourthID])

        viewModel.searchText = "save button"
        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [TriageIssueStore.thirdID])
    }

    // harness:criterion=c-existing-filter-open-unchanged
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

    // harness:criterion=c-existing-filter-done-unchanged
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

    // harness:criterion=c-existing-filter-watch-unchanged
    func testSelectionSurvivesFilteringWhenIssueStillExists() {
        let store = TriageIssueStore()
        let viewModel = IssueListViewModel(store: store)
        let issue = store.issue(withID: TriageIssueStore.firstID)!

        viewModel.select(issue)
        viewModel.filter = .watching

        XCTAssertEqual(viewModel.selectedIssue?.id, TriageIssueStore.firstID)
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { $0.state == .watching })
    }

    // harness:criterion=c-issue-filter-high-priority-case-exists,c-issue-filter-high-priority-title
    func testHighPriorityFilterIsAvailableWithExpectedTitle() {
        XCTAssertTrue(IssueFilter.allCases.contains(.highPriority))
        XCTAssertEqual(IssueFilter.allCases.count, 5)
        XCTAssertEqual(IssueFilter.highPriority.title, "High")
    }

    // harness:criterion=c-matches-filter-high-priority-returns-high-only,c-visible-issues-high-priority-filter
    func testHighPriorityFilterShowsOnlyHighPriorityIssues() {
        let highIssue = makeIssue(
            id: uuid(10),
            title: "Checkout outage",
            priority: .high,
            updatedAt: Date(timeIntervalSince1970: 2_000)
        )
        let mediumIssue = makeIssue(
            id: uuid(11),
            title: "Reports polish",
            priority: .medium,
            updatedAt: Date(timeIntervalSince1970: 2_100)
        )
        let lowIssue = makeIssue(
            id: uuid(12),
            title: "Copy update",
            priority: .low,
            updatedAt: Date(timeIntervalSince1970: 2_200)
        )
        let viewModel = IssueListViewModel(store: TriageIssueStore(issues: [mediumIssue, highIssue, lowIssue]))

        viewModel.filter = .highPriority

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [highIssue.id])
        XCTAssertTrue(viewModel.visibleIssues.allSatisfy { $0.priority == .high })
    }

    // harness:criterion=c-visible-issues-high-priority-sort-order
    func testHighPriorityFilterKeepsExistingUpdatedAtSortOrder() {
        let olderHighIssue = makeIssue(
            id: uuid(20),
            title: "Older high issue",
            priority: .high,
            updatedAt: Date(timeIntervalSince1970: 2_000)
        )
        let newerHighIssue = makeIssue(
            id: uuid(21),
            title: "Newer high issue",
            priority: .high,
            updatedAt: Date(timeIntervalSince1970: 2_400)
        )
        let newestMediumIssue = makeIssue(
            id: uuid(22),
            title: "Newer non-high issue",
            priority: .medium,
            updatedAt: Date(timeIntervalSince1970: 2_800)
        )
        let viewModel = IssueListViewModel(
            store: TriageIssueStore(issues: [olderHighIssue, newestMediumIssue, newerHighIssue])
        )

        viewModel.filter = .highPriority

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [
            newerHighIssue.id,
            olderHighIssue.id
        ])
    }

    // harness:criterion=c-empty-state-title-high-priority-no-issues
    func testHighPriorityEmptyStateTitleWhenNoHighPriorityIssuesExist() {
        let viewModel = IssueListViewModel(store: TriageIssueStore(issues: [
            makeIssue(id: uuid(30), title: "Medium issue", priority: .medium),
            makeIssue(id: uuid(31), title: "Low issue", priority: .low)
        ]))

        viewModel.filter = .highPriority
        viewModel.searchText = ""

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
        XCTAssertEqual(viewModel.emptyStateTitle, "No high-priority issues")
    }

    // harness:criterion=c-empty-state-title-search-overrides-high-priority
    func testSearchEmptyStateTitleOverridesHighPriorityEmptyStateTitle() {
        let viewModel = IssueListViewModel(store: TriageIssueStore(issues: [
            makeIssue(id: uuid(40), title: "Customer cannot pay", priority: .high),
            makeIssue(id: uuid(41), title: "Minor copy edit", priority: .low)
        ]))

        viewModel.filter = .highPriority
        viewModel.searchText = "zzznonexistent"

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
        XCTAssertEqual(viewModel.emptyStateTitle, "No matching issues")
    }

    // harness:criterion=c-search-composes-with-high-priority-filter
    func testSearchComposesWithHighPriorityFilter() {
        let matchingHighIssue = makeIssue(
            id: uuid(50),
            title: "Checkout payment crash",
            productArea: "Checkout",
            priority: .high
        )
        let nonmatchingHighIssue = makeIssue(
            id: uuid(51),
            title: "Profile image crash",
            productArea: "Accounts",
            priority: .high
        )
        let matchingMediumIssue = makeIssue(
            id: uuid(52),
            title: "Checkout receipt typo",
            productArea: "Checkout",
            priority: .medium
        )
        let viewModel = IssueListViewModel(
            store: TriageIssueStore(issues: [nonmatchingHighIssue, matchingMediumIssue, matchingHighIssue])
        )

        viewModel.filter = .highPriority
        viewModel.searchText = "payment"

        XCTAssertEqual(viewModel.visibleIssues.map(\.id), [matchingHighIssue.id])
    }

    // harness:criterion=c-search-composes-high-priority-no-match
    func testHighPrioritySearchWithNoMatchingHighPriorityIssuesIsEmpty() {
        let viewModel = IssueListViewModel(store: TriageIssueStore(issues: [
            makeIssue(id: uuid(60), title: "Payment failure", productArea: "Checkout", priority: .high),
            makeIssue(id: uuid(61), title: "Analytics export", productArea: "Reports", priority: .medium)
        ]))

        viewModel.filter = .highPriority
        viewModel.searchText = "analytics"

        XCTAssertTrue(viewModel.visibleIssues.isEmpty)
    }

    private func makeIssue(
        id: UUID,
        title: String,
        productArea: String = "Checkout",
        summary: String = "Test summary",
        priority: IssuePriority,
        state: IssueState = .open,
        owner: String = "Avery",
        updatedAt: Date = Date(timeIntervalSince1970: 2_000)
    ) -> TriageIssue {
        .fixture(
            id: id,
            title: title,
            productArea: productArea,
            summary: summary,
            priority: priority,
            state: state,
            owner: owner,
            updatedAt: updatedAt
        )
    }

    private func uuid(_ value: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", value))!
    }
}
