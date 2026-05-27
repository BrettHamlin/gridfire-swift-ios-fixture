import Foundation

struct TriageSummary: Equatable {
    var openCount: Int
    var watchingCount: Int
    var resolvedCount: Int
    var highPriorityOpenCount: Int
    var staleOpenCount: Int

    var totalCount: Int {
        openCount + watchingCount + resolvedCount
    }

    var needsAttention: Bool {
        highPriorityOpenCount > 0 || staleOpenCount > 0
    }

    var statusMessage: String {
        if highPriorityOpenCount > 0 {
            return "\(highPriorityOpenCount) high priority open"
        }
        if staleOpenCount > 0 {
            return "\(staleOpenCount) stale open"
        }
        if openCount > 0 {
            return "\(openCount) open"
        }
        return "All clear"
    }
}

struct TriageSummaryCalculator {
    let staleDate: Date

    func summary(for issues: [TriageIssue]) -> TriageSummary {
        TriageSummary(
            openCount: issues.filter { $0.state == .open }.count,
            watchingCount: issues.filter { $0.state == .watching }.count,
            resolvedCount: issues.filter { $0.state == .resolved }.count,
            highPriorityOpenCount: issues.filter { $0.state == .open && $0.priority == .high }.count,
            staleOpenCount: issues.filter { $0.state == .open && $0.updatedAt < staleDate }.count
        )
    }
}

