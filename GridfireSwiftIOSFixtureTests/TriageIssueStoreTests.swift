import XCTest
@testable import GridfireSwiftIOSFixture

@MainActor
final class TriageIssueStoreTests: XCTestCase {
    func testToggleResolvedCanReopenIssue() {
        let store = TriageIssueStore()

        store.toggleResolved(id: TriageIssueStore.thirdID)

        XCTAssertEqual(store.issue(withID: TriageIssueStore.thirdID)?.state, .open)
    }

    func testMarkWatchingUpdatesIssueState() {
        let store = TriageIssueStore()

        store.markWatching(id: TriageIssueStore.firstID)

        XCTAssertEqual(store.issue(withID: TriageIssueStore.firstID)?.state, .watching)
    }

    func testUnknownIssueMutationIsIgnored() {
        let store = TriageIssueStore()
        let before = store.issues

        store.toggleResolved(id: UUID(uuidString: "00000000-0000-0000-0000-999999999999")!)

        XCTAssertEqual(store.issues, before)
    }
}

