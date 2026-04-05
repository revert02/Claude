import SwiftUI

struct HeroBannerView: View {
    let items: [Media]
    let onTap: (Media) -> Void

    @State private var currentIndex = 0
    @State private var timer: Timer?

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, media in
                heroBannerItem(media)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: TheaterTheme.heroBannerHeight)
        .onAppear { startAutoScroll() }
        .onDisappear { stopAutoScroll() }
    }

    private func heroBannerItem(_ media: Media) -> some View {
        ZStack(alignment: .bottomLeading) {
            CachedAsyncImage(url: media.backdropURL ?? media.posterURL) {
                ImagePlaceholder()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [.clear, TheaterTheme.background.opacity(0.6), TheaterTheme.background],
                startPoint: .top,
                endPoint: .bottom
            )

            // Content overlay
            VStack(alignment: .leading, spacing: TheaterTheme.spacingSM) {
                Text(media.mediaType.displayName.uppercased())
                    .font(TheaterTheme.smallCaption)
                    .foregroundStyle(TheaterTheme.accent)
                    .fontWeight(.bold)
                    .tracking(1.5)

                Text(media.title)
                    .font(TheaterTheme.largeTitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                HStack(spacing: TheaterTheme.spacingSM) {
                    Label(media.formattedRating, systemImage: "star.fill")
                        .font(TheaterTheme.subheadline)
                        .foregroundStyle(TheaterTheme.accentGold)

                    if let year = media.yearString {
                        Text(year)
                            .font(TheaterTheme.subheadline)
                            .foregroundStyle(TheaterTheme.textSecondary)
                    }
                }

                if !media.overview.isEmpty {
                    Text(media.overview)
                        .font(TheaterTheme.caption)
                        .foregroundStyle(TheaterTheme.textSecondary)
                        .lineLimit(2)
                }
            }
            .padding(TheaterTheme.spacingLG)
        }
        .onTapGesture { onTap(media) }
    }

    private func startAutoScroll() {
        guard items.count > 1 else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % items.count
            }
        }
    }

    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
}
