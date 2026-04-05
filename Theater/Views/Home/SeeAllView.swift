import SwiftUI

struct SeeAllView: View {
    let title: String
    let items: [Media]
    @State private var selectedMedia: Media?
    @State private var showDetail = false

    private let columns = [
        GridItem(.adaptive(minimum: TheaterTheme.posterWidth, maximum: TheaterTheme.posterWidth + 20), spacing: TheaterTheme.spacingSM)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: TheaterTheme.spacingMD) {
                ForEach(items) { media in
                    PosterCardView(media: media)
                        .onTapGesture {
                            selectedMedia = media
                            showDetail = true
                        }
                }
            }
            .padding(TheaterTheme.spacingMD)
        }
        .theaterBackground()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $showDetail) {
            if let media = selectedMedia {
                DetailView(media: media)
            }
        }
    }
}
