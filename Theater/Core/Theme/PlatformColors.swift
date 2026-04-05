import SwiftUI

extension StreamingPlatform {
    var color: Color {
        switch self {
        case .netflix:      return Color(hex: "E50914")
        case .disneyPlus:   return Color(hex: "0063E5")
        case .hboMax:       return Color(hex: "B535F6")
        case .primeVideo:   return Color(hex: "00A8E1")
        case .appleTVPlus:  return Color(hex: "A8A8A8")
        case .crunchyroll:  return Color(hex: "F47521")
        }
    }

    var iconName: String {
        switch self {
        case .netflix:      return "play.rectangle.fill"
        case .disneyPlus:   return "sparkles"
        case .hboMax:       return "play.tv.fill"
        case .primeVideo:   return "shippingbox.fill"
        case .appleTVPlus:  return "appletv.fill"
        case .crunchyroll:  return "leaf.fill"
        }
    }
}
