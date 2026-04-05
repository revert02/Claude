import Foundation
import SwiftData

@MainActor
class WatchlistRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [WatchlistItem] {
        let descriptor = FetchDescriptor<WatchlistItem>(
            sortBy: [SortDescriptor(\.addedDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func add(_ media: Media) {
        let item = WatchlistItem.from(media: media)
        modelContext.insert(item)
    }

    func remove(mediaId: Int, mediaType: String) throws {
        let descriptor = FetchDescriptor<WatchlistItem>(
            predicate: #Predicate { $0.mediaId == mediaId && $0.mediaType == mediaType }
        )
        if let items = try? modelContext.fetch(descriptor) {
            for item in items {
                modelContext.delete(item)
            }
        }
    }

    func exists(mediaId: Int, mediaType: String) -> Bool {
        let descriptor = FetchDescriptor<WatchlistItem>(
            predicate: #Predicate { $0.mediaId == mediaId && $0.mediaType == mediaType }
        )
        return (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }
}
