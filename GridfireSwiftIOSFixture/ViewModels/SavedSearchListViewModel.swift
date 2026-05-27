import Foundation

final class SavedSearchListViewModel: ObservableObject {
    @Published private(set) var searches: [SavedTriageSearch]
    @Published var selectedSearchID: SavedTriageSearch.ID?

    private let store: SavedTriageSearchStore

    init(store: SavedTriageSearchStore = SavedTriageSearchStore()) {
        self.store = store
        searches = store.searches
    }

    var selectedSearch: SavedTriageSearch? {
        guard let selectedSearchID else {
            return nil
        }
        return store.search(withID: selectedSearchID)
    }

    var emptyStateTitle: String {
        searches.isEmpty ? "No saved searches" : ""
    }

    func select(_ search: SavedTriageSearch) {
        selectedSearchID = search.id
    }

    func save(title: String, query: String, filter: IssueFilter, includeResolved: Bool) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            return
        }
        store.save(SavedTriageSearch(
            title: trimmedTitle,
            query: query,
            filter: filter,
            includeResolved: includeResolved
        ))
        searches = store.searches
    }

    func delete(_ search: SavedTriageSearch) {
        store.delete(id: search.id)
        if selectedSearchID == search.id {
            selectedSearchID = nil
        }
        searches = store.searches
    }
}
