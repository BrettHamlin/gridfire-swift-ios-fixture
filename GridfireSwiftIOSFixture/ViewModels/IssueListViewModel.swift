import Foundation

final class IssueListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var filter: IssueFilter = .all
    @Published var selectedIssueID: TriageIssue.ID?

    private let store: TriageIssueStore
    private let summaryCalculator: TriageSummaryCalculator

    init(
        store: TriageIssueStore,
        summaryCalculator: TriageSummaryCalculator = TriageSummaryCalculator(staleDate: Date(timeIntervalSince1970: 1_550))
    ) {
        self.store = store
        self.summaryCalculator = summaryCalculator
    }

    var visibleIssues: [TriageIssue] {
        store.issues
            .filter(matchesFilter)
            .filter(matchesSearch)
            .sorted(by: issueSort)
    }

    var selectedIssue: TriageIssue? {
        guard let selectedIssueID else {
            return nil
        }
        return store.issue(withID: selectedIssueID)
    }

    var summaryViewModel: IssueSummaryViewModel {
        IssueSummaryViewModel(summary: summaryCalculator.summary(for: store.issues))
    }

    var emptyStateTitle: String {
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "No matching issues"
        }
        switch filter {
        case .all:
            return "No issues"
        case .open:
            return "No open issues"
        case .watching:
            return "No watched issues"
        case .resolved:
            return "No resolved issues"
        }
    }

    func select(_ issue: TriageIssue) {
        selectedIssueID = issue.id
    }

    func clearSelection() {
        selectedIssueID = nil
    }

    func toggleResolved(_ issue: TriageIssue) {
        store.toggleResolved(id: issue.id)
    }

    func markWatching(_ issue: TriageIssue) {
        store.markWatching(id: issue.id)
    }

    func markOpen(_ issue: TriageIssue) {
        store.markOpen(id: issue.id)
    }

    private func matchesFilter(_ issue: TriageIssue) -> Bool {
        switch filter {
        case .all:
            return true
        case .open:
            return issue.state == .open
        case .watching:
            return issue.state == .watching
        case .resolved:
            return issue.state == .resolved
        }
    }

    private func matchesSearch(_ issue: TriageIssue) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return true
        }
        return issue.title.localizedCaseInsensitiveContains(query)
            || issue.productArea.localizedCaseInsensitiveContains(query)
            || issue.owner.localizedCaseInsensitiveContains(query)
    }

    private func issueSort(lhs: TriageIssue, rhs: TriageIssue) -> Bool {
        if lhs.priority.sortRank != rhs.priority.sortRank {
            return lhs.priority.sortRank < rhs.priority.sortRank
        }
        return lhs.updatedAt > rhs.updatedAt
    }
}
