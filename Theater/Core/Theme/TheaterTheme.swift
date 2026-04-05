import SwiftUI

enum TheaterTheme {
    // MARK: - Colors
    static let background = Color(hex: "0A0A0F")
    static let surface = Color(hex: "151520")
    static let surfaceLight = Color(hex: "1E1E2E")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "9CA3AF")
    static let accent = Color(hex: "E50914")
    static let accentGold = Color(hex: "FFD700")

    // MARK: - Fonts
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title = Font.system(size: 22, weight: .bold)
    static let headline = Font.system(size: 17, weight: .semibold)
    static let subheadline = Font.system(size: 15, weight: .medium)
    static let body = Font.system(size: 15, weight: .regular)
    static let caption = Font.system(size: 13, weight: .regular)
    static let smallCaption = Font.system(size: 11, weight: .medium)

    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Corner Radius
    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 12
    static let cornerRadiusLG: CGFloat = 16

    // MARK: - Poster Sizes
    static let posterWidth: CGFloat = 120
    static let posterHeight: CGFloat = 180
    static let heroBannerHeight: CGFloat = 450
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
