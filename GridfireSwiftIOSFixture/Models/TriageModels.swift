import Foundation

enum IssuePriority: String, CaseIterable, Identifiable, Equatable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var title: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }

    var sortRank: Int {
        switch self {
        case .high:
            return 0
        case .medium:
            return 1
        case .low:
            return 2
        }
    }
}

enum IssueState: String, CaseIterable, Identifiable, Equatable {
    case open
    case watching
    case resolved

    var id: String { rawValue }

    var title: String {
        switch self {
        case .open:
            return "Open"
        case .watching:
            return "Watching"
        case .resolved:
            return "Resolved"
        }
    }
}

enum IssueFilter: String, CaseIterable, Identifiable, Equatable {
    case all
    case open
    case highPriority
    case watching
    case resolved

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .open:
            return "Open"
        case .highPriority:
            return "High"
        case .watching:
            return "Watch"
        case .resolved:
            return "Done"
        }
    }
}

struct TriageIssue: Identifiable, Equatable {
    let id: UUID
    var title: String
    var productArea: String
    var summary: String
    var priority: IssuePriority
    var state: IssueState
    var owner: String
    var updatedAt: Date

    var isResolved: Bool {
        state == .resolved
    }
}

extension TriageIssue {
    static func fixture(
        id: UUID,
        title: String,
        productArea: String,
        summary: String,
        priority: IssuePriority,
        state: IssueState,
        owner: String,
        updatedAt: Date
    ) -> TriageIssue {
        TriageIssue(
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
}
