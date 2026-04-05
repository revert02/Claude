import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSidebar = false

    var body: some View {
        ZStack {
            TheaterTheme.background.ignoresSafeArea()

            // Main content
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(1)

                WatchlistView()
                    .tabItem {
                        Label("Watchlist", systemImage: "bookmark.fill")
                    }
                    .tag(2)
            }
            .tint(TheaterTheme.accent)

            // Sidebar overlay
            if showSidebar {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showSidebar = false } }
                    .transition(.opacity)

                HStack {
                    SidebarView(isPresented: $showSidebar)
                        .frame(width: 300)
                        .transition(.move(edge: .leading))

                    Spacer()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSidebar)
        .onReceive(NotificationCenter.default.publisher(for: .toggleSidebar)) { _ in
            showSidebar.toggle()
        }
    }
}
