import Foundation

enum TMDBEndpoint: APIEndpoint {
    case trending(mediaType: String, timeWindow: String)
    case popularMovies(page: Int)
    case popularTV(page: Int)
    case searchMulti(query: String, page: Int)
    case movieDetail(id: Int)
    case tvDetail(id: Int)
    case movieCredits(id: Int)
    case tvCredits(id: Int)
    case movieWatchProviders(id: Int)
    case tvWatchProviders(id: Int)
    case movieSimilar(id: Int)
    case tvSimilar(id: Int)
    case discoverMovies(providers: [Int], genres: [Int], page: Int, region: String = "US")
    case discoverTV(providers: [Int], genres: [Int], page: Int, region: String = "US")
    case upcomingMovies(page: Int)
    case genreListMovie
    case genreListTV

    var baseURL: String { "https://api.themoviedb.org/3" }

    var path: String {
        switch self {
        case .trending(let mediaType, let timeWindow):
            return "/trending/\(mediaType)/\(timeWindow)"
        case .popularMovies:
            return "/movie/popular"
        case .popularTV:
            return "/tv/popular"
        case .searchMulti:
            return "/search/multi"
        case .movieDetail(let id):
            return "/movie/\(id)"
        case .tvDetail(let id):
            return "/tv/\(id)"
        case .movieCredits(let id):
            return "/movie/\(id)/credits"
        case .tvCredits(let id):
            return "/tv/\(id)/credits"
        case .movieWatchProviders(let id):
            return "/movie/\(id)/watch/providers"
        case .tvWatchProviders(let id):
            return "/tv/\(id)/watch/providers"
        case .movieSimilar(let id):
            return "/movie/\(id)/similar"
        case .tvSimilar(let id):
            return "/tv/\(id)/similar"
        case .discoverMovies:
            return "/discover/movie"
        case .discoverTV:
            return "/discover/tv"
        case .upcomingMovies:
            return "/movie/upcoming"
        case .genreListMovie:
            return "/genre/movie/list"
        case .genreListTV:
            return "/genre/tv/list"
        }
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: TMDBConfig.apiKey),
            URLQueryItem(name: "language", value: "en-US"),
        ]

        switch self {
        case .popularMovies(let page),
             .popularTV(let page),
             .upcomingMovies(let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))

        case .searchMulti(let query, let page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: "\(page)"))

        case .discoverMovies(let providers, let genres, let page, let region),
             .discoverTV(let providers, let genres, let page, let region):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "watch_region", value: region))
            items.append(URLQueryItem(name: "sort_by", value: "popularity.desc"))
            if !providers.isEmpty {
                items.append(URLQueryItem(
                    name: "with_watch_providers",
                    value: providers.map(String.init).joined(separator: "|")
                ))
            }
            if !genres.isEmpty {
                items.append(URLQueryItem(
                    name: "with_genres",
                    value: genres.map(String.init).joined(separator: ",")
                ))
            }

        default:
            break
        }

        return items
    }
}

enum TMDBConfig {
    // Replace with your TMDB API key from https://www.themoviedb.org/settings/api
    static let apiKey = "8ebf6146d38c10e74873f2729e20afde"
    static let imageBaseURL = "https://image.tmdb.org/t/p/"
}
