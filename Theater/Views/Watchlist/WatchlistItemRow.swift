import SwiftUI

struct WatchlistItemRow: View {
    let item: WatchlistItem
    let onToggleWatched: () -> Void

    var body: some View {
        HStack(spacing: TheaterTheme.spaceSM) {
            // Poster
            CachedAsyncImage(url: item.posterURL) {
                ImagePlaceholder()
            }
            .frame(width: 70, height: 105)
            .clipShape(RoundedRectangle(cornerRadius: TheaterTheme.cornerRadiusSM))

            // Info
            VStack(alignment: .leading, spacing: TheaterTheme.spacingXS) {
                Text(item.title)
                    .font(TheaterTheme.headline)
                    .foregroundStyle(TheaterTheme.textPrimary)
                    .lineLimit(2)

                Text(item.parsedMediaType.displayName)
                    .font(TheaterTheme.caption)
                    .foregroundStyle(TheaterTheme.accent)

                if let rating = item.rating, rating > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(TheaterTheme.accentGold)
                        Text(String(format: "%.1f", rating))
                            .font(TheaterTheme.caption)
                            .foregroundStyle(TheaterTheme.textSecondary)
                    }
                }

                if !item.platforms.isEmpty {
                    Text(item.platforms.joined(separator: " • "))
                        .font(TheaterTheme.smallCaption)
                        .foregroundStyle(TheaterTheme.textSecondary)
                        .lineLimit(1)
                }

                Text("Added \(item.addedDate.timeAgoDisplay)")
                    .font(TheaterTheme.smallCaption)
                    .foregroundStyle(TheaterTheme.textSecondary.opacity(0.7))
            }

            Spacer()

            // Watched toggle
            Button(action: onToggleWatched) {
                Image(systemName: item.isWatched ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isWatched ? .green : TheaterTheme.textSecondary)
            }
        }
        .padding(TheaterTheme.spacingSM)
        .background(TheaterTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: TheaterTheme.cornerRadiusMD))
        .opacity(item.isWatched ? 0.7 : 1.0)
    }
}

// Fix: spaceSM should reference spacingSM
private extension TheaterTheme {
    static let spaceSM = spacingSM
}
