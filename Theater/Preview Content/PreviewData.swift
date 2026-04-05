import Foundation

enum PreviewData {
    static let sampleMovie = Media(
        id: 550,
        title: "Fight Club",
        overview: "A ticking-Loss bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy.",
        posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        backdropPath: "/hZkgoQYus5dXo3H8T7Uef6DNknx.jpg",
        mediaType: .movie,
        genreIds: [18, 53, 35],
        voteAverage: 8.4,
        voteCount: 26000,
        releaseDate: "1999-10-15",
        popularity: 73.5,
        runtime: 139,
        genres: [Genre(id: 18, name: "Drama"), Genre(id: 53, name: "Thriller")],
        tagline: "Mischief. Mayhem. Soap."
    )

    static let sampleTVShow = Media(
        id: 1396,
        title: "Breaking Bad",
        overview: "A high school chemistry teacher diagnosed with inoperable lung cancer turns to manufacturing and selling methamphetamine.",
        posterPath: "/ggFHVNu6YYI5L9pCfOacjizRGt.jpg",
        backdropPath: "/tsRy63Mu5cu8etL1X7ZLyf7UP1M.jpg",
        mediaType: .tvShow,
        genreIds: [18, 80],
        voteAverage: 8.9,
        voteCount: 12000,
        releaseDate: "2008-01-20",
        popularity: 200.3,
        numberOfSeasons: 5,
        genres: [Genre(id: 18, name: "Drama"), Genre(id: 80, name: "Crime")]
    )

    static let sampleAnime = Media(
        id: 85937,
        title: "Demon Slayer",
        overview: "It is the Taisho Period in Japan. Tanjiro, a kindhearted boy who sells charcoal for a living, finds his family slaughtered by a demon.",
        posterPath: "/xUfRZu2mi8jH6SJXXs3Grp4Eje2.jpg",
        backdropPath: "/nGxUxi3PfXDRm7Vg95VBNgNM8yc.jpg",
        mediaType: .tvShow,
        genreIds: [16, 10759, 10765],
        voteAverage: 8.7,
        voteCount: 5000,
        releaseDate: "2019-04-06",
        popularity: 150.2,
        numberOfSeasons: 4,
        availablePlatforms: [.crunchyroll]
    )

    static let sampleMedia: [Media] = [sampleMovie, sampleTVShow, sampleAnime]

    static let sampleCast: [CastMember] = [
        CastMember(id: 819, name: "Edward Norton", character: "The Narrator", profilePath: "/8nytsqL59SFJTVYVrN72k6qkGgJ.jpg"),
        CastMember(id: 287, name: "Brad Pitt", character: "Tyler Durden", profilePath: "/cckcYc2v0yh1tc9QjRelptcOBko.jpg"),
        CastMember(id: 1283, name: "Helena Bonham Carter", character: "Marla Singer", profilePath: "/DDeITcCpnBd0CkAIRPhggyZQfbm.jpg"),
    ]
}
