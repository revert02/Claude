import Foundation

actor RottenTomatoesService {
    static let shared = RottenTomatoesService()

    // OMDb API provides RT ratings for free (1,000 requests/day)
    // Register at https://www.omdbapi.com/apikey.aspx
    private let omdbApiKey = "YOUR_OMDB_API_KEY"
    private var cache: [String: RTRatings] = [:]

    struct RTRatings {
        let criticScore: Int?
        let audienceScore: Int?
    }

    func fetchRatings(title: String, year: String?) async -> RTRatings? {
        let cacheKey = "\(title)-\(year ?? "")"
        if let cached = cache[cacheKey] {
            return cached
        }

        var urlString = "https://www.omdbapi.com/?apikey=\(omdbApiKey)&t=\(title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title)"
        if let year {
            urlString += "&y=\(year)"
        }

        guard let url = URL(string: urlString) else { return nil }

        do {
            let data = try await APIClient.shared.fetchRaw(url: url)
            let response = try JSONDecoder().decode(OMDbResponse.self, from: data)

            var criticScore: Int?
            var audienceScore: Int?

            for rating in response.ratings ?? [] {
                if rating.source == "Rotten Tomatoes" {
                    criticScore = Int(rating.value.replacingOccurrences(of: "%", with: ""))
                }
            }

            // OMDb doesn't always provide audience score separately
            // Use Metacritic as a supplementary score
            if let metascore = response.metascore, let score = Int(metascore) {
                audienceScore = score
            }

            let ratings = RTRatings(criticScore: criticScore, audienceScore: audienceScore)
            cache[cacheKey] = ratings
            return ratings
        } catch {
            return nil
        }
    }
}

private struct OMDbResponse: Decodable {
    let title: String?
    let year: String?
    let ratings: [OMDbRating]?
    let metascore: String?

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case ratings = "Ratings"
        case metascore = "Metascore"
    }
}

private struct OMDbRating: Decodable {
    let source: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
}
