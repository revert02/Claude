import SwiftUI
import SwiftData

struct DetailView: View {
    let media: Media
    @State private var viewModel: DetailViewModel
    @State private var selectedSimilar: Media?
    @State private var showSimilarDetail = false

    @Environment(\.modelContext) private var modelContext
    @Query private var watchlistItems: [WatchlistItem]

    init(media: Media) {
        self.media = media
        self._viewModel = State(initialValue: DetailViewModel(media: media))
    }

    private var isInWatchlist: Bool {
        watchlistItems.contains { $0.mediaId == media.id && $0.mediaType == media.mediaType.rawValue }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: TheaterTheme.spacingMD) {
                // Backdrop
                backdropSection

                // Info
                VStack(alignment: .leading, spacing: TheaterTheme.spacingMD) {
                    titleSection
                    ratingsSection
                    actionButtons

                    if !viewModel.media.availablePlatforms.isEmpty || viewModel.isLoading {
                        StreamingBadgesView(platforms: viewModel.media.availablePlatforms)
                    }

                    overviewSection

                    if !viewModel.media.cast.isEmpty {
                        castSection
                    }

                    if !viewModel.similar.isEmpty {
                        similarSection
                    }
                }
                .padding(.horizontal, TheaterTheme.spacingMD)
            }
        }
        .theaterBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await viewModel.loadDetails() }
        .navigationDestination(isPresented: $showSimilarDetail) {
            if let similar = selectedSimilar {
                DetailView(media: similar)
            }
        }
    }

    // MARK: - Sections

    private var backdropSection: some View {
        ZStack(alignment: .bottomLeading) {
            CachedAsyncImage(url: media.backdropURL ?? media.posterURL) {
                ImagePlaceholder()
            }
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .clipped()

            LinearGradient(
                colors: [.clear, TheaterTheme.background],
                startPoint: .center,
                endPoint: .bottom
            )
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingXS) {
            if let tagline = viewModel.media.tagline, !tagline.isEmpty {
                Text(tagline)
                    .font(TheaterTheme.caption)
                    .foregroundStyle(TheaterTheme.accent)
                    .italic()
            }

            Text(media.title)
                .font(TheaterTheme.largeTitle)
                .foregroundStyle(TheaterTheme.textPrimary)

            HStack(spacing: TheaterTheme.spacingSM) {
                if let year = media.yearString {
                    Text(year)
                        .foregroundStyle(TheaterTheme.textSecondary)
                }

                if let runtime = viewModel.runtimeDisplay {
                    Text("•")
                        .foregroundStyle(TheaterTheme.textSecondary)
                    Text(runtime)
                        .foregroundStyle(TheaterTheme.textSecondary)
                }

                Text("•")
                    .foregroundStyle(TheaterTheme.textSecondary)
                Text(media.mediaType.displayName)
                    .foregroundStyle(TheaterTheme.accent)
            }
            .font(TheaterTheme.subheadline)

            if let genres = viewModel.media.genres, !genres.isEmpty {
                Text(genres.map(\.name).joined(separator: " • "))
                    .font(TheaterTheme.caption)
                    .foregroundStyle(TheaterTheme.textSecondary)
            }
        }
    }

    private var ratingsSection: some View {
        HStack(spacing: TheaterTheme.spacingLG) {
            if media.voteAverage > 0 {
                RatingBadgeView(score: media.voteAverage, label: "TMDB")
            }

            if let rtCritic = viewModel.media.rtCriticScore {
                RTScoreBadge(score: rtCritic, type: "critic")
            }

            if let rtAudience = viewModel.media.rtAudienceScore {
                RTScoreBadge(score: rtAudience, type: "audience")
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: TheaterTheme.spacingSM) {
            Button(action: toggleWatchlist) {
                Label(
                    isInWatchlist ? "In Watchlist" : "Add to Watchlist",
                    systemImage: isInWatchlist ? "bookmark.fill" : "bookmark"
                )
                .font(TheaterTheme.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isInWatchlist ? TheaterTheme.background : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isInWatchlist ? TheaterTheme.accent : TheaterTheme.surfaceLight)
                .clipShape(RoundedRectangle(cornerRadius: TheaterTheme.cornerRadiusSM))
            }

            Link(destination: torrentGalaxyURL) {
                Label("Search Torrent", systemImage: "magnet")
                    .font(TheaterTheme.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(TheaterTheme.surfaceLight)
                    .clipShape(RoundedRectangle(cornerRadius: TheaterTheme.cornerRadiusSM))
            }
        }
    }

    private var torrentGalaxyURL: URL {
        let query = media.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? media.title
        return URL(string: "https://torrentgalaxy.to/torrents.php?search=\(query)")!
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingSM) {
            Text("Overview")
                .font(TheaterTheme.headline)
                .foregroundStyle(TheaterTheme.textPrimary)

            Text(media.overview)
                .font(TheaterTheme.body)
                .foregroundStyle(TheaterTheme.textSecondary)
                .lineSpacing(4)
        }
    }

    private var castSection: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingSM) {
            Text("Cast")
                .font(TheaterTheme.headline)
                .foregroundStyle(TheaterTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: TheaterTheme.spacingSM) {
                    ForEach(viewModel.media.cast) { member in
                        VStack(spacing: 4) {
                            CachedAsyncImage(url: member.profileURL) {
                                Circle()
                                    .fill(TheaterTheme.surfaceLight)
                                    .overlay {
                                        Image(systemName: "person.fill")
                                            .foregroundStyle(TheaterTheme.textSecondary)
                                    }
                            }
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())

                            Text(member.name)
                                .font(TheaterTheme.smallCaption)
                                .foregroundStyle(TheaterTheme.textPrimary)
                                .lineLimit(1)

                            Text(member.character)
                                .font(TheaterTheme.smallCaption)
                                .foregroundStyle(TheaterTheme.textSecondary)
                                .lineLimit(1)
                        }
                        .frame(width: 80)
                    }
                }
            }
        }
    }

    private var similarSection: some View {
        CategoryRowView(title: "More Like This", items: viewModel.similar) { media in
            selectedSimilar = media
            showSimilarDetail = true
        }
        .padding(.horizontal, -TheaterTheme.spacingMD)
    }

    // MARK: - Actions

    private func toggleWatchlist() {
        if let existing = watchlistItems.first(where: { $0.mediaId == media.id && $0.mediaType == media.mediaType.rawValue }) {
            modelContext.delete(existing)
        } else {
            let item = WatchlistItem.from(media: viewModel.media)
            modelContext.insert(item)
        }
    }
}
