import Foundation

struct IssueAccessibilityFormatter {
    func rowLabel(for issue: TriageIssue) -> String {
        "\(issue.title), \(issue.priority.title) priority, \(issue.state.title), owned by \(issue.owner)"
    }

    func resolveButtonLabel(for issue: TriageIssue) -> String {
        issue.isResolved ? "Reopen \(issue.title)" : "Resolve \(issue.title)"
    }

    func watchButtonLabel(for issue: TriageIssue) -> String {
        issue.state == .watching ? "Watching \(issue.title)" : "Watch \(issue.title)"
    }
}

