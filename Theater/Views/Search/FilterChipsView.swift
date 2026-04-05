import SwiftUI

struct FilterChipsView: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingSM) {
            // Platform filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TheaterTheme.spacingSM) {
                    ForEach(StreamingPlatform.allCases) { platform in
                        FilterChip(
                            title: platform.displayName,
                            isSelected: viewModel.selectedPlatforms.contains(platform),
                            accentColor: platform.color
                        ) {
                            viewModel.togglePlatform(platform)
                        }
                    }
                }
                .padding(.horizontal, TheaterTheme.spacingMD)
            }

            // Genre filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TheaterTheme.spacingSM) {
                    ForEach(Genre.commonGenres) { genre in
                        FilterChip(
                            title: genre.name,
                            isSelected: viewModel.selectedGenres.contains(genre.id),
                            accentColor: TheaterTheme.accent
                        ) {
                            viewModel.toggleGenre(genre.id)
                        }
                    }
                }
                .padding(.horizontal, TheaterTheme.spacingMD)
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(TheaterTheme.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : TheaterTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? accentColor : TheaterTheme.surfaceLight)
                .clipShape(Capsule())
        }
    }
}
