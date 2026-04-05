import SwiftUI

struct PlatformBadge: View {
    let platform: StreamingPlatform
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: platform.iconName)
                .font(.system(size: compact ? 10 : 12))

            if !compact {
                Text(platform.displayName)
                    .font(TheaterTheme.smallCaption)
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, compact ? 4 : 5)
        .background(platform.color.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct PlatformBadgeRow: View {
    let platforms: [StreamingPlatform]
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(platforms.prefix(3)) { platform in
                PlatformBadge(platform: platform, compact: compact)
            }
            if platforms.count > 3 {
                Text("+\(platforms.count - 3)")
                    .font(TheaterTheme.smallCaption)
                    .foregroundStyle(TheaterTheme.textSecondary)
            }
        }
    }
}
