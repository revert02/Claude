import SwiftUI

struct StreamingBadgesView: View {
    let platforms: [StreamingPlatform]

    var body: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingSM) {
            Text("Where to Watch")
                .font(TheaterTheme.headline)
                .foregroundStyle(TheaterTheme.textPrimary)

            if platforms.isEmpty {
                Text("Streaming availability not found")
                    .font(TheaterTheme.caption)
                    .foregroundStyle(TheaterTheme.textSecondary)
            } else {
                HStack(spacing: TheaterTheme.spacingSM) {
                    ForEach(platforms) { platform in
                        StreamingPlatformButton(platform: platform)
                    }
                }
            }
        }
    }
}

struct StreamingPlatformButton: View {
    let platform: StreamingPlatform

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: platform.iconName)
                .font(.system(size: 14))
            Text(platform.displayName)
                .font(TheaterTheme.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(platform.color)
        .clipShape(RoundedRectangle(cornerRadius: TheaterTheme.cornerRadiusSM))
    }
}
