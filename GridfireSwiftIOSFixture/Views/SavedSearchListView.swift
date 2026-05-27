import SwiftUI

struct SavedSearchListView: View {
    @ObservedObject var viewModel: SavedSearchListViewModel

    var body: some View {
        List {
            if viewModel.searches.isEmpty {
                Text(viewModel.emptyStateTitle)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.searches) { search in
                    Button {
                        viewModel.select(search)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(search.title)
                                .font(.headline)
                            Text(search.accessibilitySummary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityLabel(search.accessibilitySummary)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.delete(viewModel.searches[index])
                    }
                }
            }
        }
        .navigationTitle("Saved Searches")
    }
}
