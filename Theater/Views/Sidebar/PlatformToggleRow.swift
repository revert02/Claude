import SwiftUI

struct PlatformToggleRow: View {
    let platform: StreamingPlatform
    let isEnabled: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: TheaterTheme.spaceSM) {
                Image(systemName: platform.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(platform.color)
                    .frame(width: 30)

                Text(platform.displayName)
                    .font(TheaterTheme.body)
                    .foregroundStyle(TheaterTheme.textPrimary)

                Spacer()

                Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isEnabled ? platform.color : TheaterTheme.textSecondary)
            }
            .padding(.vertical, 6)
        }
    }
}

private extension TheaterTheme {
    static let spaceSM = spacingSM
}
