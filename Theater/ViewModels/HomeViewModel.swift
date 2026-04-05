import Foundation
import Observation

@Observable
class HomeViewModel {
    var featuredMedia: [Media] = []
    var trendingNow: [Media] = []
    var newOnNetflix: [Media] = []
    var topAnime: [Media] = []
    var criticallyAcclaimed: [Media] = []
    var comingSoon: [Media] = []
    var isLoading = false
    var errorMessage: String?

    private let tmdb = TMDBService.shared

    var carouselSections: [(title: String, items: [Media])] {
        var sections: [(String, [Media])] = []
        if !trendingNow.isEmpty { sections.append(("Trending Now", trendingNow)) }
        if !newOnNetflix.isEmpty { sections.append(("New on Netflix", newOnNetflix)) }
        if !topAnime.isEmpty { sections.append(("Top Anime", topAnime)) }
        if !criticallyAcclaimed.isEmpty { sections.append(("Critically Acclaimed", criticallyAcclaimed)) }
        if !comingSoon.isEmpty { sections.append(("Coming Soon", comingSoon)) }
        return sections
    }

    func loadContent() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        let region = SidebarViewModel.shared.selectedRegion

        async let trendingTask = tmdb.fetchTrending()
        async let netflixTask = tmdb.discover(mediaType: .movie, providers: [.netflix], region: region)
        async let animeTask = tmdb.discover(mediaType: .tvShow, providers: [.crunchyroll], genres: [Genre.animationId], region: region)
        async let upcomingTask = tmdb.fetchUpcoming()
        async let popularMoviesTask = tmdb.fetchPopularMovies()

        do {
            let trending = try await trendingTask
            let netflix = try await netflixTask
            let anime = try await animeTask
            let upcoming = try await upcomingTask
            let popularMovies = try await popularMoviesTask

            self.featuredMedia = Array(trending.prefix(5))
            self.trendingNow = trending
            self.newOnNetflix = netflix
            self.topAnime = anime
            self.criticallyAcclaimed = popularMovies.filter { $0.voteAverage >= 7.5 }
            self.comingSoon = upcoming
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
