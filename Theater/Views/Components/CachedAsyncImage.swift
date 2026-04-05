import SwiftUI

struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let placeholder: () -> Placeholder

    var body: some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderView
                case .empty:
                    ProgressView()
                        .tint(TheaterTheme.textSecondary)
                @unknown default:
                    placeholderView
                }
            }
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        placeholder()
    }
}

struct ImagePlaceholder: View {
    var body: some View {
        ZStack {
            TheaterTheme.surface
            Image(systemName: "film")
                .font(.title)
                .foregroundStyle(TheaterTheme.textSecondary)
        }
    }
}
