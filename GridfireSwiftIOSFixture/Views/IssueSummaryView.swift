import SwiftUI

struct IssueSummaryView: View {
    let viewModel: IssueSummaryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.headline)
                    .font(.headline)
                Text(viewModel.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                ForEach(viewModel.tiles) { tile in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tile.value)
                            .font(.headline)
                        Text(tile.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(tile.isEmphasized ? Color.blue.opacity(0.12) : Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(tile.title): \(tile.value)")
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("issue-summary")
    }
}

