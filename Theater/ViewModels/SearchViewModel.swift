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

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
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
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            var searchResults = try await tmdb.search(query: trimmed)

            if !selectedPlatforms.isEmpty {
                // Filter by platform availability (client-side for search results)
                // For better accuracy, we'd need to check each item's watch providers
                // For MVP, we show all results but could enhance later
            }

            if !selectedGenres.isEmpty {
                searchResults = searchResults.filter { media in
                    !Set(media.genreIds).isDisjoint(with: selectedGenres)
                }
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
