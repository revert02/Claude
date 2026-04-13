# Theater

A streaming content aggregator that helps you discover movies and TV shows across multiple streaming platforms. Built with a native iOS app (SwiftUI) and a companion web app (vanilla JavaScript).

Powered by [The Movie Database (TMDB)](https://www.themoviedb.org/) API.

## Features

- **Discover Content** -- Browse trending movies and TV shows with a hero carousel, curated categories (Trending, New on Netflix, Top Anime, Critically Acclaimed, Coming Soon), and genre-based exploration
- **Search & Filter** -- Real-time search with debounce, filter by streaming platform, genre, and region
- **Streaming Availability** -- See where to watch any title across Netflix, Disney+, HBO Max, Prime Video, Apple TV+, and Crunchyroll
- **Watchlist** -- Save titles to a personal watchlist, mark items as watched, filter by type (Movies, TV Shows, Anime), and sort by date added, name, or rating
- **Detail View** -- Cast, ratings, similar content, streaming providers, and overview for every title

## Supported Platforms

| Platform | Color |
|----------|-------|
| Netflix | Red |
| Disney+ | Blue |
| HBO Max | Purple |
| Prime Video | Cyan |
| Apple TV+ | Gray |
| Crunchyroll | Orange |

## Project Structure

```
Theater/          # iOS app (SwiftUI + SwiftData)
  Core/           # Networking, extensions, theme
  Models/         # Data models and TMDB DTOs
  Services/       # TMDB API service, watchlist persistence
  Repositories/   # Data aggregation layer
  ViewModels/     # Observable view models
  Views/          # SwiftUI views (Home, Search, Detail, Watchlist, Sidebar)

web-app/          # Web app (vanilla HTML/CSS/JS)
  index.html      # App shell
  app.js          # Application logic
  styles.css      # Styling
  manifest.json   # PWA manifest
```

## Getting Started

### Prerequisites

- A free TMDB API key -- [get one here](https://www.themoviedb.org/settings/api)

### iOS App

1. Open the project in Xcode
2. Build and run on a simulator or device (iOS 17+)
3. The app uses SwiftUI and SwiftData with no external dependencies

### Web App

1. Serve the `web-app/` directory with any static file server:
   ```bash
   cd web-app
   python3 -m http.server 8000
   ```
2. Open `http://localhost:8000` in a browser
3. Enter your TMDB API key when prompted, or use Demo Mode

## Tech Stack

**iOS**: SwiftUI, SwiftData, Swift Concurrency (async/await, actors), URLSession

**Web**: Vanilla JavaScript (ES6+), CSS custom properties, LocalStorage, PWA-ready

## Region Support

Content availability can be checked for: US, GB, CA, AU, DE, FR, JP, IN

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
