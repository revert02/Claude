import Foundation

enum MediaType: String, Codable, CaseIterable, Identifiable {
    case movie
    case tvShow = "tv"
    case anime

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .movie: return "Movie"
        case .tvShow: return "TV Show"
        case .anime: return "Anime"
        }
    }

    var tmdbMediaType: String {
        switch self {
        case .movie: return "movie"
        case .tvShow, .anime: return "tv"
        }
    }
}
