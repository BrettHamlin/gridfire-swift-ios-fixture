import Foundation

struct IssueSummaryTile: Identifiable, Equatable {
    let id: String
    let title: String
    let value: String
    let isEmphasized: Bool
}

struct IssueSummaryViewModel: Equatable {
    let summary: TriageSummary

    var headline: String {
        summary.statusMessage
    }

    var subtitle: String {
        if summary.totalCount == 1 {
            return "1 issue tracked"
        }
        return "\(summary.totalCount) issues tracked"
    }

    var tiles: [IssueSummaryTile] {
        [
            IssueSummaryTile(
                id: "open",
                title: "Open",
                value: "\(summary.openCount)",
                isEmphasized: summary.openCount > 0
            ),
            IssueSummaryTile(
                id: "watching",
                title: "Watch",
                value: "\(summary.watchingCount)",
                isEmphasized: summary.watchingCount > 0
            ),
            IssueSummaryTile(
                id: "resolved",
                title: "Done",
                value: "\(summary.resolvedCount)",
                isEmphasized: false
            )
        ]
    }
}

