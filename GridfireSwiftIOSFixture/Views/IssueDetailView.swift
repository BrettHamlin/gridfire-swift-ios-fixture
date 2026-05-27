import SwiftUI

struct IssueDetailView: View {
    let issue: TriageIssue
    let formatter: IssueAccessibilityFormatter
    let onToggleResolved: () -> Void
    let onWatch: () -> Void
    let onMarkOpen: () -> Void

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(issue.title)
                        .font(.title2.weight(.semibold))
                    Text(issue.summary)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }

            Section("Ownership") {
                labeledRow("Area", issue.productArea)
                labeledRow("Owner", issue.owner)
                labeledRow("Priority", issue.priority.title)
                labeledRow("State", issue.state.title)
            }

            Section("Actions") {
                Button(action: onToggleResolved) {
                    Label(issue.isResolved ? "Reopen Issue" : "Resolve Issue",
                          systemImage: issue.isResolved ? "arrow.uturn.backward.circle" : "checkmark.circle")
                }
                .accessibilityLabel(formatter.resolveButtonLabel(for: issue))

                Button(action: onWatch) {
                    Label("Watch Issue", systemImage: "eye")
                }
                .disabled(issue.state == .watching)
                .accessibilityLabel(formatter.watchButtonLabel(for: issue))

                Button(action: onMarkOpen) {
                    Label("Mark Open", systemImage: "exclamationmark.circle")
                }
                .disabled(issue.state == .open)
            }
        }
        .navigationTitle("Issue Detail")
    }

    private func labeledRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

