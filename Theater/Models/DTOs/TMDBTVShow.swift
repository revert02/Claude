import Foundation

struct TMDBTVShow: Decodable, Identifiable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let genreIds: [Int]?
    let genres: [Genre]?
    let voteAverage: Double
    let voteCount: Int
    let firstAirDate: String?
    let popularity: Double
    let numberOfSeasons: Int?
    let tagline: String?
    let status: String?

    func toMedia() -> Media {
        Media(
            id: id,
            title: name,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            mediaType: .tvShow,
            genreIds: genreIds ?? genres?.map(\.id) ?? [],
            voteAverage: voteAverage,
            voteCount: voteCount,
            releaseDate: firstAirDate,
            popularity: popularity,
            numberOfSeasons: numberOfSeasons,
            genres: genres,
            tagline: tagline,
            status: status
        )
    }
}
