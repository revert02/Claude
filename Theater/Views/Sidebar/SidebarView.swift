import SwiftUI

struct SidebarView: View {
    @Binding var isPresented: Bool
    @State private var viewModel = SidebarViewModel.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: TheaterTheme.spacingLG) {
                    platformsSection
                    regionSection
                    aboutSection
                }
                .padding(TheaterTheme.spacingMD)
            }
        }
        .background(TheaterTheme.surface)
        .ignoresSafeArea(edges: .bottom)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingSM) {
            HStack {
                Image(systemName: "film.fill")
                    .font(.title)
                    .foregroundStyle(TheaterTheme.accent)

                Text("Theater")
                    .font(TheaterTheme.title)
                    .foregroundStyle(TheaterTheme.textPrimary)

                Spacer()

                Button {
                    withAnimation { isPresented = false }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(TheaterTheme.textSecondary)
                }
            }

            Text("Your streaming guide")
                .font(TheaterTheme.caption)
                .foregroundStyle(TheaterTheme.textSecondary)
        }
        .padding(TheaterTheme.spacingMD)
        .padding(.top, TheaterTheme.spacingSM)
    }

    private var platformsSection: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingSM) {
            Text("Streaming Platforms")
                .font(TheaterTheme.headline)
                .foregroundStyle(TheaterTheme.textPrimary)

            ForEach(StreamingPlatform.allCases) { platform in
                PlatformToggleRow(
                    platform: platform,
                    isEnabled: viewModel.isPlatformEnabled(platform)
                ) {
                    viewModel.togglePlatform(platform)
                }
            }
        }
    }

    private var regionSection: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingSM) {
            Text("Region")
                .font(TheaterTheme.headline)
                .foregroundStyle(TheaterTheme.textPrimary)

            Menu {
                ForEach(viewModel.availableRegions, id: \.0) { code, name in
                    Button {
                        viewModel.selectedRegion = code
                    } label: {
                        Label(name, systemImage: viewModel.selectedRegion == code ? "checkmark" : "")
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.availableRegions.first { $0.0 == viewModel.selectedRegion }?.1 ?? "")
                        .font(TheaterTheme.body)
                        .foregroundStyle(TheaterTheme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(TheaterTheme.textSecondary)
                }
                .padding(TheaterTheme.spacingSM)
                .background(TheaterTheme.surfaceLight)
                .clipShape(RoundedRectangle(cornerRadius: TheaterTheme.cornerRadiusSM))
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingSM) {
            Text("About")
                .font(TheaterTheme.headline)
                .foregroundStyle(TheaterTheme.textPrimary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Theater v1.0")
                    .font(TheaterTheme.caption)
                    .foregroundStyle(TheaterTheme.textSecondary)
                Text("Powered by TMDB & OMDb")
                    .font(TheaterTheme.smallCaption)
                    .foregroundStyle(TheaterTheme.textSecondary.opacity(0.7))
            }
        }
    }
}
