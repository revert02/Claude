import Foundation

struct Media: Identifiable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let mediaType: MediaType
    let genreIds: [Int]
    let voteAverage: Double
    let voteCount: Int
    let releaseDate: String?
    let popularity: Double

    // Detail fields (populated on detail fetch)
    var runtime: Int?
    var numberOfSeasons: Int?
    var genres: [Genre]?
    var tagline: String?
    var status: String?

    // Streaming availability
    var availablePlatforms: [StreamingPlatform] = []

    // Rotten Tomatoes ratings
    var rtCriticScore: Int?
    var rtAudienceScore: Int?

    // Cast
    var cast: [CastMember] = []

    // MARK: - Computed

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var backdropURL: URL? {
        guard let backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath)")
    }

    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }

    var yearString: String? {
        guard let releaseDate, !releaseDate.isEmpty else { return nil }
        return String(releaseDate.prefix(4))
    }

    var isAnime: Bool {
        let isAnimation = genreIds.contains(Genre.animationId)
        let onAnimeService = availablePlatforms.contains(.crunchyroll)
        let hasAnimeGenres = genreIds.contains(Genre.animationId) && genreIds.contains(Genre.actionAdventureId)
        return isAnimation && (onAnimeService || hasAnimeGenres)
    }

    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(mediaType)
    }

    static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.id == rhs.id && lhs.mediaType == rhs.mediaType
    }
}

struct CastMember: Identifiable, Hashable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?

    var profileURL: URL? {
        guard let profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)")
    }
}
