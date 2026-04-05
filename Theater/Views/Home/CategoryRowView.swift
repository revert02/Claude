import SwiftUI

struct CategoryRowView: View {
    let title: String
    let items: [Media]
    let onTap: (Media) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingSM) {
            HStack {
                Text(title)
                    .font(TheaterTheme.title)
                    .foregroundStyle(TheaterTheme.textPrimary)

                Spacer()

                NavigationLink(destination: SeeAllView(title: title, items: items)) {
                    Text("See All")
                        .font(TheaterTheme.caption)
                        .foregroundStyle(TheaterTheme.accent)
                }
            }
            .padding(.horizontal, TheaterTheme.spacingMD)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: TheaterTheme.spacingSM) {
                    ForEach(items) { media in
                        PosterCardView(media: media)
                            .onTapGesture { onTap(media) }
                    }
                }
                .padding(.horizontal, TheaterTheme.spacingMD)
            }
        }
    }
}
