import SwiftUI

struct SearchResultsGrid: View {
    let results: [Media]
    let onTap: (Media) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: TheaterTheme.spacingSM),
        GridItem(.flexible(), spacing: TheaterTheme.spacingSM),
        GridItem(.flexible(), spacing: TheaterTheme.spacingSM),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: TheaterTheme.spacingMD) {
            ForEach(results) { media in
                PosterCardView(
                    media: media,
                    width: .infinity,
                    height: 180
                )
                .onTapGesture { onTap(media) }
            }
        }
        .padding(.horizontal, TheaterTheme.spacingMD)
    }
}
