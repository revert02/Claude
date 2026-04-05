import Foundation

struct TMDBWatchProviderResponse: Decodable {
    let id: Int
    let results: [String: TMDBCountryProviders]
}

struct TMDBCountryProviders: Decodable {
    let link: String?
    let flatrate: [TMDBProvider]?
    let rent: [TMDBProvider]?
    let buy: [TMDBProvider]?
}

struct TMDBProvider: Decodable {
    let providerId: Int
    let providerName: String
    let logoPath: String?
    let displayPriority: Int?
}

struct TMDBCreditsResponse: Decodable {
    let id: Int
    let cast: [TMDBCastMember]
}

struct TMDBCastMember: Decodable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?

    func toCastMember() -> CastMember {
        CastMember(
            id: id,
            name: name,
            character: character ?? "",
            profilePath: profilePath
        )
    }
}

struct TMDBMultiSearchResult: Decodable {
    let id: Int
    let mediaType: String
    let title: String?
    let name: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let genreIds: [Int]?
    let voteAverage: Double?
    let voteCount: Int?
    let releaseDate: String?
    let firstAirDate: String?
    let popularity: Double?

    func toMedia() -> Media? {
        guard mediaType == "movie" || mediaType == "tv" else { return nil }

        return Media(
            id: id,
            title: title ?? name ?? "",
            overview: overview ?? "",
            posterPath: posterPath,
            backdropPath: backdropPath,
            mediaType: mediaType == "movie" ? .movie : .tvShow,
            genreIds: genreIds ?? [],
            voteAverage: voteAverage ?? 0,
            voteCount: voteCount ?? 0,
            releaseDate: releaseDate ?? firstAirDate,
            popularity: popularity ?? 0
        )
    }
}
