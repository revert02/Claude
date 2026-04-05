import Foundation
import SwiftData

@MainActor
class WatchlistService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addToWatchlist(_ media: Media) {
        let item = WatchlistItem.from(media: media)
        modelContext.insert(item)
    }

    func removeFromWatchlist(mediaId: Int, mediaType: String) {
        let descriptor = FetchDescriptor<WatchlistItem>(
            predicate: #Predicate { $0.mediaId == mediaId && $0.mediaType == mediaType }
        )
        if let items = try? modelContext.fetch(descriptor), let item = items.first {
            modelContext.delete(item)
        }
    }

    func toggleWatched(item: WatchlistItem) {
        item.isWatched.toggle()
    }

    func isInWatchlist(mediaId: Int, mediaType: String) -> Bool {
        let descriptor = FetchDescriptor<WatchlistItem>(
            predicate: #Predicate { $0.mediaId == mediaId && $0.mediaType == mediaType }
        )
        return (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }
}
