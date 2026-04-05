import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var selectedMedia: Media?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: TheaterTheme.spacingMD) {
                    FilterChipsView(viewModel: viewModel)

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(TheaterTheme.accent)
                            .padding(.top, 40)
                    } else if viewModel.results.isEmpty && !viewModel.query.isEmpty {
                        emptyState
                    } else if viewModel.results.isEmpty {
                        browseByGenre
                    } else {
                        SearchResultsGrid(results: viewModel.results) { media in
                            selectedMedia = media
                            showDetail = true
                        }
                    }
                }
                .padding(.top, TheaterTheme.spacingSM)
            }
            .theaterBackground()
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $viewModel.query, prompt: "Movies, TV Shows, Anime...")
            .onChange(of: viewModel.query) {
                viewModel.onQueryChanged()
            }
            .navigationDestination(isPresented: $showDetail) {
                if let media = selectedMedia {
                    DetailView(media: media)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: TheaterTheme.spacingSM) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(TheaterTheme.textSecondary)
            Text("No results found")
                .font(TheaterTheme.headline)
                .foregroundStyle(TheaterTheme.textSecondary)
            Text("Try a different search term")
                .font(TheaterTheme.caption)
                .foregroundStyle(TheaterTheme.textSecondary.opacity(0.7))
        }
        .padding(.top, 60)
    }

    private var browseByGenre: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingMD) {
            Text("Browse by Genre")
                .font(TheaterTheme.title)
                .foregroundStyle(TheaterTheme.textPrimary)
                .padding(.horizontal, TheaterTheme.spacingMD)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: TheaterTheme.spacingSM
            ) {
                ForEach(Genre.commonGenres) { genre in
                    GenreCard(genre: genre) {
                        viewModel.toggleGenre(genre.id)
                        viewModel.query = genre.name
                    }
                }
            }
            .padding(.horizontal, TheaterTheme.spacingMD)
        }
    }
}

struct GenreCard: View {
    let genre: Genre
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(genre.name)
                .font(TheaterTheme.headline)
                .foregroundStyle(TheaterTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    LinearGradient(
                        colors: [TheaterTheme.surface, TheaterTheme.surfaceLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: TheaterTheme.cornerRadiusMD))
        }
    }
}
