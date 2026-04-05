import Foundation
import Observation

enum WatchlistFilter: String, CaseIterable {
    case all = "All"
    case movies = "Movies"
    case tvShows = "TV Shows"
    case anime = "Anime"
}

enum WatchlistSort: String, CaseIterable {
    case recentlyAdded = "Recently Added"
    case alphabetical = "A-Z"
    case rating = "Rating"
}

@Observable
class WatchlistViewModel {
    var selectedFilter: WatchlistFilter = .all
    var selectedSort: WatchlistSort = .recentlyAdded
    var showWatchedOnly = false

    func filteredItems(_ items: [WatchlistItem]) -> [WatchlistItem] {
        var result = items

        // Filter by type
        switch selectedFilter {
        case .all:
            break
        case .movies:
            result = result.filter { $0.mediaType == "movie" }
        case .tvShows:
            result = result.filter { $0.mediaType == "tv" }
        case .anime:
            result = result.filter {
                $0.platforms.contains("Crunchyroll")
            }
        }

        // Filter watched
        if showWatchedOnly {
            result = result.filter { $0.isWatched }
        }

        // Sort
        switch selectedSort {
        case .recentlyAdded:
            result.sort { $0.addedDate > $1.addedDate }
        case .alphabetical:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .rating:
            result.sort { ($0.rating ?? 0) > ($1.rating ?? 0) }
        }

        return result
    }
}
