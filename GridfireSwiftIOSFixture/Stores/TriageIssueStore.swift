import Foundation

final class TriageIssueStore: ObservableObject {
    @Published private(set) var issues: [TriageIssue]

    init(issues: [TriageIssue] = TriageIssueStore.sampleIssues) {
        self.issues = issues
    }

    func issue(withID id: TriageIssue.ID) -> TriageIssue? {
        issues.first { $0.id == id }
    }

    func toggleResolved(id: TriageIssue.ID) {
        updateIssue(id: id) { issue in
            issue.state = issue.state == .resolved ? .open : .resolved
            issue.updatedAt = Date.distantFuture
        }
    }

    func markWatching(id: TriageIssue.ID) {
        updateIssue(id: id) { issue in
            issue.state = .watching
            issue.updatedAt = Date.distantFuture
        }
    }

    func markOpen(id: TriageIssue.ID) {
        updateIssue(id: id) { issue in
            issue.state = .open
            issue.updatedAt = Date.distantFuture
        }
    }

    private func updateIssue(id: TriageIssue.ID, mutate: (inout TriageIssue) -> Void) {
        guard let index = issues.firstIndex(where: { $0.id == id }) else {
            return
        }
        mutate(&issues[index])
    }
}

extension TriageIssueStore {
    static let firstID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let secondID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let thirdID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let fourthID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!

    static let sampleIssues: [TriageIssue] = [
        .fixture(
            id: firstID,
            title: "Payment sheet does not recover after network loss",
            productArea: "Checkout",
            summary: "Customers see a stale spinner if a retry succeeds after the first request times out.",
            priority: .high,
            state: .open,
            owner: "Avery",
            updatedAt: Date(timeIntervalSince1970: 1_800)
        ),
        .fixture(
            id: secondID,
            title: "Dashboard chart hides empty-state copy",
            productArea: "Analytics",
            summary: "A zero-data response leaves screen-reader users without the empty-state explanation.",
            priority: .medium,
            state: .watching,
            owner: "Morgan",
            updatedAt: Date(timeIntervalSince1970: 1_700)
        ),
        .fixture(
            id: thirdID,
            title: "Settings save button remains enabled after submit",
            productArea: "Settings",
            summary: "Repeated taps enqueue duplicate profile update requests.",
            priority: .medium,
            state: .resolved,
            owner: "Riley",
            updatedAt: Date(timeIntervalSince1970: 1_600)
        ),
        .fixture(
            id: fourthID,
            title: "Search results lose selected row on refresh",
            productArea: "Search",
            summary: "Refreshing filtered results drops navigation back to the list root.",
            priority: .low,
            state: .open,
            owner: "Quinn",
            updatedAt: Date(timeIntervalSince1970: 1_500)
        )
    ]
}
