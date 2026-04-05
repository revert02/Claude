import Foundation
import SwiftData

@Model
class WatchlistItem {
    var mediaId: Int
    var mediaType: String
    var title: String
    var posterPath: String?
    var addedDate: Date
    var isWatched: Bool
    var rating: Double?
    var platforms: [String]

    init(
        mediaId: Int,
        mediaType: String,
        title: String,
        posterPath: String?,
        addedDate: Date = .now,
        isWatched: Bool = false,
        rating: Double? = nil,
        platforms: [String] = []
    ) {
        self.mediaId = mediaId
        self.mediaType = mediaType
        self.title = title
        self.posterPath = posterPath
        self.addedDate = addedDate
        self.isWatched = isWatched
        self.rating = rating
        self.platforms = platforms
    }

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var parsedMediaType: MediaType {
        MediaType(rawValue: mediaType) ?? .movie
    }

    static func from(media: Media) -> WatchlistItem {
        WatchlistItem(
            mediaId: media.id,
            mediaType: media.mediaType.rawValue,
            title: media.title,
            posterPath: media.posterPath,
            rating: media.voteAverage,
            platforms: media.availablePlatforms.map(\.displayName)
        )
    }
}
