import SwiftUI
import SwiftData

struct WatchlistView: View {
    @State private var viewModel = WatchlistViewModel()
    @Query(sort: \WatchlistItem.addedDate, order: .reverse) private var allItems: [WatchlistItem]
    @Environment(\.modelContext) private var modelContext

    private var filteredItems: [WatchlistItem] {
        viewModel.filteredItems(allItems)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter bar
                filterBar

                if filteredItems.isEmpty {
                    emptyState
                } else {
                    itemsList
                }
            }
            .theaterBackground()
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(WatchlistSort.allCases, id: \.self) { sort in
                            Button {
                                viewModel.selectedSort = sort
                            } label: {
                                Label(sort.rawValue, systemImage: viewModel.selectedSort == sort ? "checkmark" : "")
                            }
                        }
                        Divider()
                        Toggle("Watched Only", isOn: $viewModel.showWatchedOnly)
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundStyle(TheaterTheme.textPrimary)
                    }
                }
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TheaterTheme.spacingSM) {
                ForEach(WatchlistFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation { viewModel.selectedFilter = filter }
                    } label: {
                        Text(filter.rawValue)
                            .font(TheaterTheme.caption)
                            .fontWeight(viewModel.selectedFilter == filter ? .semibold : .regular)
                            .foregroundStyle(viewModel.selectedFilter == filter ? .white : TheaterTheme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedFilter == filter ? TheaterTheme.accent : TheaterTheme.surfaceLight)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, TheaterTheme.spacingMD)
            .padding(.vertical, TheaterTheme.spacingSM)
        }
    }

    private var itemsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: TheaterTheme.spacingSM) {
                ForEach(filteredItems) { item in
                    WatchlistItemRow(item: item) {
                        item.isWatched.toggle()
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            withAnimation { modelContext.delete(item) }
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            modelContext.delete(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            item.isWatched.toggle()
                        } label: {
                            Label(
                                item.isWatched ? "Unwatched" : "Watched",
                                systemImage: item.isWatched ? "eye.slash" : "eye"
                            )
                        }
                        .tint(.green)
                    }
                }
            }
            .padding(.horizontal, TheaterTheme.spacingMD)
            .padding(.top, TheaterTheme.spacingSM)
        }
    }

    private var emptyState: some View {
        VStack(spacing: TheaterTheme.spacingMD) {
            Spacer()
            Image(systemName: "bookmark")
                .font(.system(size: 60))
                .foregroundStyle(TheaterTheme.textSecondary.opacity(0.5))

            Text("Your watchlist is empty")
                .font(TheaterTheme.headline)
                .foregroundStyle(TheaterTheme.textSecondary)

            Text("Browse movies and shows to add them here")
                .font(TheaterTheme.caption)
                .foregroundStyle(TheaterTheme.textSecondary.opacity(0.7))
            Spacer()
        }
    }
}
