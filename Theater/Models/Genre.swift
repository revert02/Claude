import Foundation

struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String

    static let animationId = 16
    static let actionAdventureId = 10759  // TV: Action & Adventure

    static let commonGenres: [Genre] = [
        Genre(id: 28, name: "Action"),
        Genre(id: 12, name: "Adventure"),
        Genre(id: 16, name: "Animation"),
        Genre(id: 35, name: "Comedy"),
        Genre(id: 80, name: "Crime"),
        Genre(id: 99, name: "Documentary"),
        Genre(id: 18, name: "Drama"),
        Genre(id: 14, name: "Fantasy"),
        Genre(id: 27, name: "Horror"),
        Genre(id: 10749, name: "Romance"),
        Genre(id: 878, name: "Sci-Fi"),
        Genre(id: 53, name: "Thriller"),
    ]
}
