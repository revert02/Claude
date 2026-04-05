import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var selectedMedia: Media?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: TheaterTheme.spacingLG) {
                    if !viewModel.featuredMedia.isEmpty {
                        HeroBannerView(items: viewModel.featuredMedia) { media in
                            selectedMedia = media
                            showDetail = true
                        }
                    }

                    ForEach(Array(viewModel.carouselSections.enumerated()), id: \.offset) { _, section in
                        CategoryRowView(title: section.title, items: section.items) { media in
                            selectedMedia = media
                            showDetail = true
                        }
                    }
                }
            }
            .theaterBackground()
            .navigationTitle("Theater")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { NotificationCenter.default.post(name: .toggleSidebar, object: nil) }) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(TheaterTheme.textPrimary)
                    }
                }
            }
            .refreshable {
                await viewModel.loadContent()
            }
            .overlay {
                if viewModel.isLoading && viewModel.featuredMedia.isEmpty {
                    ProgressView()
                        .tint(TheaterTheme.accent)
                        .scaleEffect(1.5)
                }
            }
            .overlay {
                if let error = viewModel.errorMessage, viewModel.featuredMedia.isEmpty {
                    VStack(spacing: TheaterTheme.spacingSM) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(TheaterTheme.textSecondary)
                        Text(error)
                            .font(TheaterTheme.caption)
                            .foregroundStyle(TheaterTheme.textSecondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await viewModel.loadContent() }
                        }
                        .foregroundStyle(TheaterTheme.accent)
                    }
                    .padding()
                }
            }
            .task {
                if viewModel.featuredMedia.isEmpty {
                    await viewModel.loadContent()
                }
            }
            .navigationDestination(isPresented: $showDetail) {
                if let media = selectedMedia {
                    DetailView(media: media)
                }
            }
        }
    }
}

extension Notification.Name {
    static let toggleSidebar = Notification.Name("toggleSidebar")
}
