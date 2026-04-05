import SwiftUI
import SwiftData

@main
struct TheaterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: WatchlistItem.self)
    }
}
