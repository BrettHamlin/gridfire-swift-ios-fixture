import SwiftUI

struct IssueRowView: View {
    let issue: TriageIssue
    let formatter: IssueAccessibilityFormatter
    let onToggleResolved: () -> Void
    let onWatch: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggleResolved) {
                Image(systemName: issue.isResolved ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(issue.isResolved ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(formatter.resolveButtonLabel(for: issue))

            VStack(alignment: .leading, spacing: 6) {
                Text(issue.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(issue.productArea)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Text(issue.priority.title)
                        .font(.caption)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(priorityTint.opacity(0.18), in: Capsule())
                    Text(issue.state.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: onWatch) {
                Image(systemName: issue.state == .watching ? "eye.fill" : "eye")
                    .foregroundStyle(issue.state == .watching ? .blue : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(formatter.watchButtonLabel(for: issue))
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(formatter.rowLabel(for: issue))
    }

    private var priorityTint: Color {
        switch issue.priority {
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}

