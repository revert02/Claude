import Foundation

struct TMDBMovie: Decodable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let genreIds: [Int]?
    let genres: [Genre]?
    let voteAverage: Double
    let voteCount: Int
    let releaseDate: String?
    let popularity: Double
    let runtime: Int?
    let tagline: String?
    let status: String?

    func toMedia() -> Media {
        Media(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            mediaType: .movie,
            genreIds: genreIds ?? genres?.map(\.id) ?? [],
            voteAverage: voteAverage,
            voteCount: voteCount,
            releaseDate: releaseDate,
            popularity: popularity,
            runtime: runtime,
            genres: genres,
            tagline: tagline,
            status: status
        )
    }
}
