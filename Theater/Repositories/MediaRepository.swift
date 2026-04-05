import Foundation

actor MediaRepository {
    static let shared = MediaRepository()

    private let tmdb = TMDBService.shared
    private let rt = RottenTomatoesService.shared

    func fetchMediaWithRatings(id: Int, mediaType: MediaType) async throws -> Media {
        var media: Media
        if mediaType == .movie {
            media = try await tmdb.fetchMovieDetail(id: id)
        } else {
            media = try await tmdb.fetchTVDetail(id: id)
        }

        let region = SidebarViewModel.shared.selectedRegion

        // Fetch RT ratings in parallel with watch providers
        async let providers = tmdb.fetchWatchProviders(id: id, mediaType: mediaType, region: region)
        async let credits = tmdb.fetchCredits(id: id, mediaType: mediaType)
        async let rtRatings = rt.fetchRatings(title: media.title, year: media.yearString)

        media.availablePlatforms = (try? await providers) ?? []
        media.cast = (try? await credits) ?? []

        if let ratings = await rtRatings {
            media.rtCriticScore = ratings.criticScore
            media.rtAudienceScore = ratings.audienceScore
        }

        return media
    }
}
