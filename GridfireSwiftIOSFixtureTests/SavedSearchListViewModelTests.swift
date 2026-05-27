import XCTest
@testable import GridfireSwiftIOSFixture

final class SavedSearchListViewModelTests: XCTestCase {
    func testSaveRejectsBlankTitle() {
        let viewModel = SavedSearchListViewModel(store: SavedTriageSearchStore(searches: []))

        viewModel.save(title: "  ", query: "release", filter: .open, includeResolved: false)

        XCTAssertTrue(viewModel.searches.isEmpty)
        XCTAssertEqual(viewModel.emptyStateTitle, "No saved searches")
    }

    func testSaveAddsSearchAndKeepsTitleTrimmed() {
        let viewModel = SavedSearchListViewModel(store: SavedTriageSearchStore(searches: []))

        viewModel.save(title: " Release ", query: "ios", filter: .watching, includeResolved: true)

        XCTAssertEqual(viewModel.searches.map(\.title), ["Release"])
        XCTAssertEqual(viewModel.searches.first?.filter, .watching)
    }

    func testDeleteClearsSelection() {
        let search = SavedTriageSearch(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            title: "Selected",
            query: "",
            filter: .all,
            includeResolved: true
        )
        let viewModel = SavedSearchListViewModel(store: SavedTriageSearchStore(searches: [search]))

        viewModel.select(search)
        viewModel.delete(search)

        XCTAssertNil(viewModel.selectedSearchID)
        XCTAssertTrue(viewModel.searches.isEmpty)
    }
}
