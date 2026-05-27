import SwiftUI

struct IssueListView: View {
    @StateObject private var store: TriageIssueStore
    @StateObject private var viewModel: IssueListViewModel
    private let formatter = IssueAccessibilityFormatter()

    init(store: TriageIssueStore = TriageIssueStore()) {
        let storeObject = store
        _store = StateObject(wrappedValue: storeObject)
        _viewModel = StateObject(wrappedValue: IssueListViewModel(store: storeObject))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                IssueSummaryView(viewModel: viewModel.summaryViewModel)

                Picker("Issue Filter", selection: $viewModel.filter) {
                    ForEach(IssueFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])
                .accessibilityIdentifier("issue-filter")

                if viewModel.visibleIssues.isEmpty {
                    ContentUnavailableView(
                        viewModel.emptyStateTitle,
                        systemImage: "tray",
                        description: Text("Try changing the filter or search text.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.visibleIssues) { issue in
                        NavigationLink(value: issue.id) {
                            IssueRowView(
                                issue: issue,
                                formatter: formatter,
                                onToggleResolved: { viewModel.toggleResolved(issue) },
                                onWatch: { viewModel.markWatching(issue) }
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Triage")
            .searchable(text: $viewModel.searchText, prompt: "Search issues")
            .navigationDestination(for: TriageIssue.ID.self) { issueID in
                if let issue = store.issue(withID: issueID) {
                    IssueDetailView(
                        issue: issue,
                        formatter: formatter,
                        onToggleResolved: { viewModel.toggleResolved(issue) },
                        onWatch: { viewModel.markWatching(issue) },
                        onMarkOpen: { viewModel.markOpen(issue) }
                    )
                } else {
                    ContentUnavailableView("Issue unavailable", systemImage: "exclamationmark.triangle")
                }
            }
        }
    }
}

#Preview {
    IssueListView()
}
