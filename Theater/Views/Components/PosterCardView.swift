import SwiftUI

struct PosterCardView: View {
    let media: Media
    var width: CGFloat = TheaterTheme.posterWidth
    var height: CGFloat = TheaterTheme.posterHeight

    var body: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingXS) {
            CachedAsyncImage(url: media.posterURL) {
                ImagePlaceholder()
            }
            .posterStyle(width: width, height: height)
            .overlay(alignment: .topTrailing) {
                ratingBadge
            }

            Text(media.title)
                .font(TheaterTheme.caption)
                .foregroundStyle(TheaterTheme.textPrimary)
                .lineLimit(2)
                .frame(width: width, alignment: .leading)
        }
    }

    private var ratingBadge: some View {
        Group {
            if media.voteAverage > 0 {
                Text(media.formattedRating)
                    .font(TheaterTheme.smallCaption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(ratingColor.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(6)
            }
        }
    }

    private var ratingColor: Color {
        if media.voteAverage >= 7.5 { return .green }
        if media.voteAverage >= 5.0 { return .orange }
        return .red
    }
}
