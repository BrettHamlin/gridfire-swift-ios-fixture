import Foundation

struct SavedTriageSearch: Identifiable, Equatable {
    let id: UUID
    var title: String
    var query: String
    var filter: IssueFilter
    var includeResolved: Bool

    init(
        id: UUID = UUID(),
        title: String,
        query: String,
        filter: IssueFilter,
        includeResolved: Bool
    ) {
        self.id = id
        self.title = title
        self.query = query
        self.filter = filter
        self.includeResolved = includeResolved
    }

    var normalizedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var accessibilitySummary: String {
        let resolvedText = includeResolved ? "including resolved issues" : "excluding resolved issues"
        if normalizedQuery.isEmpty {
            return "\(title), \(filter.title), \(resolvedText)"
        }
        return "\(title), \(filter.title), query \(normalizedQuery), \(resolvedText)"
    }
}

final class SavedTriageSearchStore {
    private(set) var searches: [SavedTriageSearch]

    init(searches: [SavedTriageSearch] = SavedTriageSearchStore.defaults) {
        self.searches = searches
    }

    func save(_ search: SavedTriageSearch) {
        if let index = searches.firstIndex(where: { $0.id == search.id }) {
            searches[index] = search
            sort()
            return
        }
        searches.append(search)
        sort()
    }

    func delete(id: SavedTriageSearch.ID) {
        searches.removeAll { $0.id == id }
    }

    func search(withID id: SavedTriageSearch.ID) -> SavedTriageSearch? {
        searches.first { $0.id == id }
    }

    private func sort() {
        searches.sort { lhs, rhs in
            lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
        }
    }

    static let defaults: [SavedTriageSearch] = [
        SavedTriageSearch(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            title: "High priority",
            query: "",
            filter: .open,
            includeResolved: false
        ),
        SavedTriageSearch(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            title: "Watching",
            query: "release",
            filter: .watching,
            includeResolved: true
        )
    ]
}
