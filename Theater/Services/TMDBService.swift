import Foundation

actor TMDBService {
    static let shared = TMDBService()
    private let client = APIClient.shared

    // MARK: - Trending

    func fetchTrending(mediaType: String = "all", timeWindow: String = "week") async throws -> [Media] {
        let endpoint = TMDBEndpoint.trending(mediaType: mediaType, timeWindow: timeWindow)
        let response: TMDBPagedResponse<TMDBMultiSearchResult> = try await client.fetch(endpoint)
        return response.results.compactMap { $0.toMedia() }
    }

    // MARK: - Popular

    func fetchPopularMovies(page: Int = 1) async throws -> [Media] {
        let endpoint = TMDBEndpoint.popularMovies(page: page)
        let response: TMDBPagedResponse<TMDBMovie> = try await client.fetch(endpoint)
        return response.results.map { $0.toMedia() }
    }

    func fetchPopularTV(page: Int = 1) async throws -> [Media] {
        let endpoint = TMDBEndpoint.popularTV(page: page)
        let response: TMDBPagedResponse<TMDBTVShow> = try await client.fetch(endpoint)
        return response.results.map { $0.toMedia() }
    }

    // MARK: - Search

    func search(query: String, page: Int = 1) async throws -> [Media] {
        let endpoint = TMDBEndpoint.searchMulti(query: query, page: page)
        let response: TMDBPagedResponse<TMDBMultiSearchResult> = try await client.fetch(endpoint)
        return response.results.compactMap { $0.toMedia() }
    }

    // MARK: - Details

    func fetchMovieDetail(id: Int) async throws -> Media {
        let endpoint = TMDBEndpoint.movieDetail(id: id)
        let movie: TMDBMovie = try await client.fetch(endpoint)
        return movie.toMedia()
    }

    func fetchTVDetail(id: Int) async throws -> Media {
        let endpoint = TMDBEndpoint.tvDetail(id: id)
        let show: TMDBTVShow = try await client.fetch(endpoint)
        return show.toMedia()
    }

    // MARK: - Watch Providers

    func fetchWatchProviders(id: Int, mediaType: MediaType) async throws -> [StreamingPlatform] {
        let endpoint: TMDBEndpoint = mediaType == .movie
            ? .movieWatchProviders(id: id)
            : .tvWatchProviders(id: id)

        let response: TMDBWatchProviderResponse = try await client.fetch(endpoint)

        guard let usProviders = response.results["US"],
              let flatrate = usProviders.flatrate else {
            return []
        }

        return flatrate.compactMap { StreamingPlatform.from(providerId: $0.providerId) }
    }

    // MARK: - Credits

    func fetchCredits(id: Int, mediaType: MediaType) async throws -> [CastMember] {
        let endpoint: TMDBEndpoint = mediaType == .movie
            ? .movieCredits(id: id)
            : .tvCredits(id: id)

        let response: TMDBCreditsResponse = try await client.fetch(endpoint)
        return Array(response.cast.prefix(20).map { $0.toCastMember() })
    }

    // MARK: - Similar

    func fetchSimilar(id: Int, mediaType: MediaType) async throws -> [Media] {
        let endpoint: TMDBEndpoint = mediaType == .movie
            ? .movieSimilar(id: id)
            : .tvSimilar(id: id)

        if mediaType == .movie {
            let response: TMDBPagedResponse<TMDBMovie> = try await client.fetch(endpoint)
            return response.results.map { $0.toMedia() }
        } else {
            let response: TMDBPagedResponse<TMDBTVShow> = try await client.fetch(endpoint)
            return response.results.map { $0.toMedia() }
        }
    }

    // MARK: - Discover (filtered by platform)

    func discover(
        mediaType: MediaType,
        providers: [StreamingPlatform] = [],
        genres: [Int] = [],
        page: Int = 1
    ) async throws -> [Media] {
        let providerIds = providers.map(\.tmdbProviderId)

        if mediaType == .movie {
            let endpoint = TMDBEndpoint.discoverMovies(providers: providerIds, genres: genres, page: page)
            let response: TMDBPagedResponse<TMDBMovie> = try await client.fetch(endpoint)
            return response.results.map { $0.toMedia() }
        } else {
            let endpoint = TMDBEndpoint.discoverTV(providers: providerIds, genres: genres, page: page)
            let response: TMDBPagedResponse<TMDBTVShow> = try await client.fetch(endpoint)
            return response.results.map { $0.toMedia() }
        }
    }

    // MARK: - Upcoming

    func fetchUpcoming(page: Int = 1) async throws -> [Media] {
        let endpoint = TMDBEndpoint.upcomingMovies(page: page)
        let response: TMDBPagedResponse<TMDBMovie> = try await client.fetch(endpoint)
        return response.results.map { $0.toMedia() }
    }
}
