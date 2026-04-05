import Foundation

struct TMDBPagedResponse<T: Decodable>: Decodable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int
}

struct TMDBGenreListResponse: Decodable {
    let genres: [Genre]
}
