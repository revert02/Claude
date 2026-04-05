import Foundation
import Observation

@Observable
class DetailViewModel {
    var media: Media
    var isLoading = false
    var errorMessage: String?
    var similar: [Media] = []

    private let tmdb = TMDBService.shared

    init(media: Media) {
        self.media = media
    }

    func loadDetails() async {
        guard !isLoading else { return }
        isLoading = true

        async let detailTask = fetchDetail()
        async let providersTask = tmdb.fetchWatchProviders(id: media.id, mediaType: media.mediaType)
        async let creditsTask = tmdb.fetchCredits(id: media.id, mediaType: media.mediaType)
        async let similarTask = tmdb.fetchSimilar(id: media.id, mediaType: media.mediaType)

        do {
            let detail = try await detailTask
            let providers = try await providersTask
            let cast = try await creditsTask
            let similarResults = try await similarTask

            self.media.runtime = detail.runtime
            self.media.numberOfSeasons = detail.numberOfSeasons
            self.media.genres = detail.genres
            self.media.tagline = detail.tagline
            self.media.status = detail.status
            self.media.availablePlatforms = providers
            self.media.cast = cast
            self.similar = similarResults
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func fetchDetail() async throws -> Media {
        if media.mediaType == .movie {
            return try await tmdb.fetchMovieDetail(id: media.id)
        } else {
            return try await tmdb.fetchTVDetail(id: media.id)
        }
    }

    var runtimeDisplay: String? {
        if let runtime = media.runtime, runtime > 0 {
            let hours = runtime / 60
            let minutes = runtime % 60
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            }
            return "\(minutes)m"
        }
        if let seasons = media.numberOfSeasons {
            return "\(seasons) Season\(seasons == 1 ? "" : "s")"
        }
        return nil
    }
}
