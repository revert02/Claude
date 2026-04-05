import Foundation
import Observation

@Observable
class SearchViewModel {
    var query = ""
    var results: [Media] = []
    var isLoading = false
    var errorMessage: String?
    var selectedPlatforms: Set<StreamingPlatform> = []
    var selectedGenres: Set<Int> = []

    private let tmdb = TMDBService.shared
    private var searchTask: Task<Void, Never>?

    func onQueryChanged() {
        searchTask?.cancel()

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty || !selectedPlatforms.isEmpty || !selectedGenres.isEmpty else {
            results = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    func performSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty || !selectedPlatforms.isEmpty || !selectedGenres.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        let region = SidebarViewModel.shared.selectedRegion

        do {
            var searchResults: [Media]

            if trimmed.isEmpty && !selectedPlatforms.isEmpty {
                // No query but platform filters active — use discover endpoint
                searchResults = try await tmdb.discover(
                    mediaType: .movie,
                    providers: Array(selectedPlatforms),
                    genres: Array(selectedGenres),
                    region: region
                )
            } else if !trimmed.isEmpty {
                searchResults = try await tmdb.search(query: trimmed)

                // Filter by genre client-side
                if !selectedGenres.isEmpty {
                    searchResults = searchResults.filter { media in
                        !Set(media.genreIds).isDisjoint(with: selectedGenres)
                    }
                }

                // Filter by platform using discover as a secondary source when platforms selected
                if !selectedPlatforms.isEmpty {
                    let providerIds = Set(selectedPlatforms.map(\.tmdbProviderId))
                    // Fetch discover results for the selected platforms and intersect with search
                    let discoverResults = try await tmdb.discover(
                        mediaType: .movie,
                        providers: Array(selectedPlatforms),
                        region: region
                    )
                    let discoverIds = Set(discoverResults.map(\.id))
                    // Also fetch TV discover
                    let discoverTV = try await tmdb.discover(
                        mediaType: .tvShow,
                        providers: Array(selectedPlatforms),
                        region: region
                    )
                    let allDiscoverIds = discoverIds.union(Set(discoverTV.map(\.id)))

                    searchResults = searchResults.filter { allDiscoverIds.contains($0.id) }
                }
            } else {
                // Only genre filter, no platforms — use discover with genres
                searchResults = try await tmdb.discover(
                    mediaType: .movie,
                    genres: Array(selectedGenres),
                    region: region
                )
            }

            self.results = searchResults
        } catch {
            if !Task.isCancelled {
                self.errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }

    func togglePlatform(_ platform: StreamingPlatform) {
        if selectedPlatforms.contains(platform) {
            selectedPlatforms.remove(platform)
        } else {
            selectedPlatforms.insert(platform)
        }
    }

    func toggleGenre(_ genreId: Int) {
        if selectedGenres.contains(genreId) {
            selectedGenres.remove(genreId)
        } else {
            selectedGenres.insert(genreId)
        }
    }

    func clearFilters() {
        selectedPlatforms.removeAll()
        selectedGenres.removeAll()
    }
}
