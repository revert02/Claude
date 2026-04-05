import Foundation

enum StreamingPlatform: Int, Codable, CaseIterable, Identifiable {
    case netflix = 8
    case disneyPlus = 337
    case hboMax = 384
    case primeVideo = 9
    case appleTVPlus = 350
    case crunchyroll = 283

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .netflix:      return "Netflix"
        case .disneyPlus:   return "Disney+"
        case .hboMax:       return "HBO Max"
        case .primeVideo:   return "Prime Video"
        case .appleTVPlus:  return "Apple TV+"
        case .crunchyroll:  return "Crunchyroll"
        }
    }

    var tmdbProviderId: Int { rawValue }

    static func from(providerId: Int) -> StreamingPlatform? {
        StreamingPlatform(rawValue: providerId)
    }
}
