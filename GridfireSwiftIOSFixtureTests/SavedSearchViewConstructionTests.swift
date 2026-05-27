import SwiftUI
import XCTest
@testable import GridfireSwiftIOSFixture

final class SavedSearchViewConstructionTests: XCTestCase {
    func testSavedSearchListViewConstructsWithDefaultViewModel() {
        let view = SavedSearchListView(viewModel: SavedSearchListViewModel())

        XCTAssertNotNil(view.body)
    }
}
