// ============================================
// Theater — Streaming Content Aggregator
// ============================================

const TMDB_BASE = 'https://api.themoviedb.org/3';
const IMG_BASE = 'https://image.tmdb.org/t/p/';
let API_KEY = '8ebf6146d38c10e74873f2729e20afde';
let DEMO_MODE = false;

// Platform definitions
const PLATFORMS = {
    netflix:     { id: 8,   name: 'Netflix',     color: '#E50914', url: 'https://www.netflix.com/search?q=' },
    disneyPlus:  { id: 337, name: 'Disney+',     color: '#0063E5', url: 'https://www.disneyplus.com/search?q=' },
    hboMax:      { id: 384, name: 'HBO Max',      color: '#B535F6', url: 'https://play.max.com/search?q=' },
    primeVideo:  { id: 9,   name: 'Prime Video',  color: '#00A8E1', url: 'https://www.amazon.com/s?i=instant-video&k=' },
    appleTVPlus: { id: 350, name: 'Apple TV+',    color: '#A8A8A8', url: 'https://tv.apple.com/search?term=' },
    crunchyroll: { id: 283, name: 'Crunchyroll',  color: '#F47521', url: 'https://www.crunchyroll.com/search?q=' },
};

const GENRES = [
    { id: 28, name: 'Action', icon: '💥', gradient: ['#FF416C','#FF4B2B'] },
    { id: 12, name: 'Adventure', icon: '🗺️', gradient: ['#11998e','#38ef7d'] },
    { id: 16, name: 'Animation', icon: '✨', gradient: ['#6441A5','#2a0845'] },
    { id: 35, name: 'Comedy', icon: '😂', gradient: ['#F7971E','#FFD200'] },
    { id: 80, name: 'Crime', icon: '🔍', gradient: ['#434343','#000000'] },
    { id: 99, name: 'Documentary', icon: '🎥', gradient: ['#2193b0','#6dd5ed'] },
    { id: 18, name: 'Drama', icon: '🎭', gradient: ['#C33764','#1D2671'] },
    { id: 14, name: 'Fantasy', icon: '🧙', gradient: ['#7F00FF','#E100FF'] },
    { id: 27, name: 'Horror', icon: '👻', gradient: ['#000000','#e74c3c'] },
    { id: 10749, name: 'Romance', icon: '💕', gradient: ['#ee9ca7','#ffdde1'] },
    { id: 878, name: 'Sci-Fi', icon: '🚀', gradient: ['#0F2027','#2C5364'] },
    { id: 53, name: 'Thriller', icon: '🔪', gradient: ['#200122','#6f0000'] },
];

// State
let watchlist = JSON.parse(localStorage.getItem('theater_watchlist') || '[]');
let enabledPlatforms = new Set(Object.keys(PLATFORMS));
let heroIndex = 0;
let heroInterval = null;
let searchTimeout = null;
let activeSearchFilters = { platforms: new Set(), genres: new Set() };
let watchlistFilter = 'all';
let watchlistSort = 'recent';

// ============================================
// API
// ============================================

async function tmdbFetch(path, params = {}) {
    if (DEMO_MODE) return demoData(path);
    params.api_key = API_KEY;
    params.language = 'en-US';
    const qs = new URLSearchParams(params).toString();
    const res = await fetch(`${TMDB_BASE}${path}?${qs}`);
    if (!res.ok) throw new Error(`TMDB error: ${res.status}`);
    return res.json();
}

function imgURL(path, size = 'w500') {
    if (!path) return null;
    return `${IMG_BASE}${size}${path}`;
}

async function fetchOMDbRatings(title, year) {
    try {
        const params = new URLSearchParams({ apikey: 'b2b11f5b', t: title });
        if (year) params.set('y', year);
        const res = await fetch(`https://www.omdbapi.com/?${params}`);
        if (!res.ok) return null;
        const data = await res.json();
        if (data.Response === 'False') return null;
        let rt = null;
        for (const r of (data.Ratings || [])) {
            if (r.Source === 'Rotten Tomatoes') {
                rt = parseInt(r.Value);
            }
        }
        return { rt, metascore: data.Metascore !== 'N/A' ? parseInt(data.Metascore) : null };
    } catch {
        return null;
    }
}

// ============================================
// Init
// ============================================

document.addEventListener('DOMContentLoaded', () => {
    const savedKey = localStorage.getItem('theater_api_key');
    if (API_KEY) {
        startApp();
    } else if (savedKey) {
        API_KEY = savedKey;
        startApp();
    } else {
        document.getElementById('apiKeyModal').classList.remove('hidden');
        document.getElementById('app').classList.add('hidden');
    }

    document.getElementById('apiKeySubmit').onclick = () => {
        const key = document.getElementById('apiKeyInput').value.trim();
        if (key) {
            API_KEY = key;
            localStorage.setItem('theater_api_key', key);
            startApp();
        }
    };

    document.getElementById('apiKeyDemo').onclick = () => {
        DEMO_MODE = true;
        startApp();
    };

    document.getElementById('apiKeyInput').addEventListener('keydown', (e) => {
        if (e.key === 'Enter') document.getElementById('apiKeySubmit').click();
    });

    // Search
    document.getElementById('searchInput').addEventListener('input', (e) => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => performSearch(e.target.value), 400);
    });
});

function startApp() {
    document.getElementById('apiKeyModal').classList.add('hidden');
    document.getElementById('app').classList.remove('hidden');
    setupPlatformToggles();
    setupSearchFilters();
    setupBrowseGenres();
    loadHome();
    renderWatchlist();
}

// ============================================
// Navigation
// ============================================

function switchTab(tab) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
    document.getElementById(`${tab}Tab`).classList.add('active');
    document.querySelector(`[data-tab="${tab}"]`).classList.add('active');

    if (tab === 'search') {
        setTimeout(() => document.getElementById('searchInput').focus(), 100);
    }
}

function toggleSidebar() {
    document.getElementById('sidebar').classList.toggle('open');
    document.getElementById('sidebarOverlay').classList.toggle('open');
}

// ============================================
// Home
// ============================================

async function loadHome() {
    const carouselsEl = document.getElementById('carousels');
    const heroEl = document.getElementById('heroSlides');

    // Show shimmer
    heroEl.innerHTML = '<div class="shimmer shimmer-hero"></div>';
    carouselsEl.innerHTML = Array(4).fill('').map(() => shimmerCarousel()).join('');

    try {
        const [trending, netflix, anime, upcoming, popular] = await Promise.all([
            tmdbFetch('/trending/all/week'),
            tmdbFetch('/discover/movie', { with_watch_providers: '8', watch_region: 'US', sort_by: 'popularity.desc' }),
            tmdbFetch('/discover/tv', { with_watch_providers: '283', with_genres: '16', watch_region: 'US', sort_by: 'popularity.desc' }),
            tmdbFetch('/movie/upcoming'),
            tmdbFetch('/movie/popular'),
        ]);

        // Hero
        const heroItems = trending.results.slice(0, 5);
        renderHero(heroItems);

        // Carousels
        const sections = [
            { title: 'Trending Now', items: trending.results },
            { title: 'New on Netflix', items: netflix.results },
            { title: 'Top Anime', items: anime.results },
            { title: 'Critically Acclaimed', items: popular.results.filter(m => m.vote_average >= 7.5) },
            { title: 'Coming Soon', items: upcoming.results },
        ];

        carouselsEl.innerHTML = sections
            .filter(s => s.items.length > 0)
            .map(s => renderCarouselHTML(s.title, s.items))
            .join('');

    } catch (err) {
        console.error('Failed to load home:', err);
        carouselsEl.innerHTML = `
            <div class="empty-state">
                <span class="empty-icon">⚠️</span>
                <p>Failed to load content</p>
                <p class="muted">${err.message}</p>
                <button class="btn-secondary" style="margin-top:12px;width:auto;padding:10px 24px" onclick="loadHome()">Retry</button>
            </div>`;
    }
}

function renderHero(items) {
    const heroEl = document.getElementById('heroSlides');
    const dotsEl = document.getElementById('heroDots');

    heroEl.innerHTML = items.map((item, i) => {
        const title = item.title || item.name;
        const type = item.media_type === 'movie' ? 'MOVIE' : 'TV SHOW';
        const backdrop = imgURL(item.backdrop_path, 'w780') || imgURL(item.poster_path, 'w500');
        const rating = item.vote_average?.toFixed(1) || '—';
        const year = (item.release_date || item.first_air_date || '').slice(0, 4);
        const genreNames = (item.genre_ids || []).slice(0, 2).map(id => {
            const g = GENRES.find(g => g.id === id);
            return g ? g.name : '';
        }).filter(Boolean).join(' · ');

        return `
            <div class="hero-slide" onclick="openDetail(${item.id}, '${item.media_type || 'movie'}')">
                ${backdrop ? `<img src="${backdrop}" alt="${title}" loading="${i === 0 ? 'eager' : 'lazy'}">` : '<div class="poster-placeholder">🎬</div>'}
                <div class="hero-gradient"></div>
                <div class="hero-info">
                    <div class="hero-chips">
                        <span class="hero-type">${type}</span>
                        ${genreNames ? `<span class="hero-genre">${genreNames}</span>` : ''}
                    </div>
                    <div class="hero-title">${escapeHTML(title)}</div>
                    <div class="hero-meta">
                        <span class="hero-rating">★ ${rating}</span>
                        ${year ? `<span class="hero-divider">·</span><span class="hero-year">${year}</span>` : ''}
                    </div>
                    ${item.overview ? `<div class="hero-overview">${escapeHTML(item.overview)}</div>` : ''}
                </div>
            </div>`;
    }).join('');

    dotsEl.innerHTML = items.map((_, i) =>
        `<div class="hero-dot ${i === 0 ? 'active' : ''}"></div>`
    ).join('');

    heroIndex = 0;
    clearInterval(heroInterval);
    heroInterval = setInterval(() => {
        heroIndex = (heroIndex + 1) % items.length;
        heroEl.style.transform = `translateX(-${heroIndex * 100}%)`;
        dotsEl.querySelectorAll('.hero-dot').forEach((d, i) =>
            d.classList.toggle('active', i === heroIndex));
    }, 5000);

    // Touch swipe
    let touchStartX = 0;
    heroEl.parentElement.addEventListener('touchstart', e => { touchStartX = e.touches[0].clientX; });
    heroEl.parentElement.addEventListener('touchend', e => {
        const diff = touchStartX - e.changedTouches[0].clientX;
        if (Math.abs(diff) > 50) {
            heroIndex = diff > 0
                ? Math.min(heroIndex + 1, items.length - 1)
                : Math.max(heroIndex - 1, 0);
            heroEl.style.transform = `translateX(-${heroIndex * 100}%)`;
            dotsEl.querySelectorAll('.hero-dot').forEach((d, i) =>
                d.classList.toggle('active', i === heroIndex));
        }
    });
}

function renderCarouselHTML(title, items, icon) {
    // First item is a featured large card, rest are small in a row
    const featured = items[0];
    const rest = items.slice(1);
    const featuredType = featured?.media_type || (featured?.first_air_date ? 'tv' : 'movie');
    const featuredBackdrop = imgURL(featured?.backdrop_path, 'w780');
    const featuredTitle = featured?.title || featured?.name || '';
    const featuredRating = featured?.vote_average?.toFixed(1);
    const featuredYear = (featured?.release_date || featured?.first_air_date || '').slice(0, 4);

    return `
        <div class="category-row">
            <div class="category-header">
                <h2 class="category-title">${escapeHTML(title)}</h2>
                <span class="category-count">${items.length}</span>
            </div>
            ${featured ? `
            <div class="featured-card" onclick="openDetail(${featured.id}, '${featuredType}')">
                <div class="featured-img">
                    ${featuredBackdrop ? `<img src="${featuredBackdrop}" alt="${escapeHTML(featuredTitle)}" loading="lazy">` : ''}
                    <div class="featured-overlay"></div>
                    <div class="featured-info">
                        <div class="featured-title">${escapeHTML(featuredTitle)}</div>
                        <div class="featured-meta">
                            ${featuredRating > 0 ? `<span class="featured-rating">★ ${featuredRating}</span>` : ''}
                            ${featuredYear ? `<span>${featuredYear}</span>` : ''}
                        </div>
                    </div>
                </div>
            </div>` : ''}
            <div class="carousel">
                ${rest.map(item => posterCardHTML(item)).join('')}
            </div>
        </div>`;
}

function posterCardHTML(item) {
    const title = item.title || item.name || '';
    const poster = imgURL(item.poster_path, 'w342');
    const rating = item.vote_average?.toFixed(1);
    const ratingClass = item.vote_average >= 7.5 ? 'high' : item.vote_average >= 5 ? 'mid' : 'low';
    const mediaType = item.media_type || (item.first_air_date ? 'tv' : 'movie');

    return `
        <div class="poster-card" onclick="openDetail(${item.id}, '${mediaType}')">
            <div class="poster-img-wrap">
                ${poster
                    ? `<img src="${poster}" alt="${escapeHTML(title)}" loading="lazy">`
                    : '<div class="poster-placeholder"></div>'}
                ${rating > 0 ? `<span class="poster-rating ${ratingClass}">${rating}</span>` : ''}
            </div>
            <div class="poster-title">${escapeHTML(title)}</div>
        </div>`;
}

function shimmerCarousel() {
    return `
        <div class="category-row">
            <div class="category-header"><div class="shimmer" style="width:150px;height:20px;border-radius:4px"></div></div>
            <div class="carousel">${Array(5).fill('<div class="shimmer shimmer-poster"></div>').join('')}</div>
        </div>`;
}

// ============================================
// Detail
// ============================================

async function openDetail(id, mediaType) {
    const detailView = document.getElementById('detailView');
    const backdrop = document.getElementById('detailBackdrop');
    const body = document.getElementById('detailBody');

    detailView.classList.remove('hidden');
    backdrop.innerHTML = '<button class="back-btn" onclick="closeDetail()">← Back</button><div class="shimmer" style="width:100%;height:100%"></div>';
    body.innerHTML = '<div class="spinner"></div>';

    try {
        const endpoint = mediaType === 'movie' ? `/movie/${id}` : `/tv/${id}`;
        const [detail, credits, providers, similar] = await Promise.all([
            tmdbFetch(endpoint),
            tmdbFetch(`${endpoint}/credits`).catch(() => ({ cast: [] })),
            tmdbFetch(`${endpoint}/watch/providers`).catch(() => ({ results: {} })),
            tmdbFetch(`${endpoint}/similar`).catch(() => ({ results: [] })),
        ]);

        const title = detail.title || detail.name;
        const backdropImg = imgURL(detail.backdrop_path, 'w780') || imgURL(detail.poster_path, 'w500');
        const year = (detail.release_date || detail.first_air_date || '').slice(0, 4);
        const runtime = detail.runtime ? `${Math.floor(detail.runtime/60)}h ${detail.runtime%60}m` :
            detail.number_of_seasons ? `${detail.number_of_seasons} Season${detail.number_of_seasons > 1 ? 's' : ''}` : '';
        const genres = (detail.genres || []).map(g => g.name).join(' • ');
        const type = mediaType === 'movie' ? 'Movie' : 'TV Show';

        // Watch providers with TMDB link
        const usData = providers.results?.US || {};
        const tmdbWatchLink = usData.link || null;
        const usProviders = usData.flatrate || [];
        const matchedPlatforms = usProviders
            .map(p => {
                const platform = Object.values(PLATFORMS).find(pl => pl.id === p.provider_id);
                if (!platform) return null;
                return { ...platform, searchUrl: platform.url + encodeURIComponent(title) };
            })
            .filter(Boolean);

        // Check watchlist
        const inWatchlist = watchlist.some(w => w.id === id && w.mediaType === mediaType);

        backdrop.innerHTML = `
            <button class="back-btn" onclick="closeDetail()">← Back</button>
            ${backdropImg ? `<img src="${backdropImg}" alt="${escapeHTML(title)}">` : ''}`;

        body.innerHTML = `
            ${detail.tagline ? `<div class="detail-tagline">${escapeHTML(detail.tagline)}</div>` : ''}
            <h1 class="detail-title">${escapeHTML(title)}</h1>
            <div class="detail-meta">
                ${year ? `<span>${year}</span>` : ''}
                ${runtime ? `<span>• ${runtime}</span>` : ''}
                <span>• <span class="type-highlight">${type}</span></span>
            </div>
            ${genres ? `<div class="detail-genres">${escapeHTML(genres)}</div>` : ''}

            <div class="ratings-row" id="ratingsRow">
                ${detail.vote_average > 0 ? ratingCircleHTML(detail.vote_average, 'TMDB') : ''}
            </div>

            <div class="detail-actions">
                <button class="action-btn primary ${inWatchlist ? 'active' : ''}" id="watchlistBtn" onclick="toggleWatchlistFromDetail(${id}, '${mediaType}', '${escapeHTML(title).replace(/'/g, "\\'")}', '${detail.poster_path || ''}', ${detail.vote_average || 0}, ${JSON.stringify((detail.genres || []).map(g => g.id))})">
                    ${inWatchlist ? '🔖 In Watchlist' : '🔖 Add to Watchlist'}
                </button>
            </div>

            ${matchedPlatforms.length > 0 ? `
                <div class="streaming-section">
                    <h3>Where to Watch</h3>
                    <div class="streaming-badges">
                        ${matchedPlatforms.map(p => `
                            <a href="${p.searchUrl}" target="_blank" rel="noopener" class="streaming-badge" style="background:${p.color}" onclick="event.stopPropagation()">
                                ${p.name}
                                <span class="badge-arrow">→</span>
                            </a>
                        `).join('')}
                    </div>
                    ${tmdbWatchLink ? `<a href="${tmdbWatchLink}" target="_blank" rel="noopener" class="watch-all-link" onclick="event.stopPropagation()">View all options on TMDB →</a>` : ''}
                </div>` : ''}

            <div class="detail-section">
                <h3>Overview</h3>
                <p>${escapeHTML(detail.overview || 'No overview available.')}</p>
            </div>

            ${credits.cast?.length > 0 ? `
                <div class="detail-section">
                    <h3>Cast</h3>
                    <div class="cast-scroll">
                        ${credits.cast.slice(0, 20).map(c => `
                            <div class="cast-member">
                                <div class="cast-photo">
                                    ${c.profile_path
                                        ? `<img src="${imgURL(c.profile_path, 'w185')}" alt="${escapeHTML(c.name)}" loading="lazy">`
                                        : '👤'}
                                </div>
                                <div class="cast-name">${escapeHTML(c.name)}</div>
                                <div class="cast-char">${escapeHTML(c.character || '')}</div>
                            </div>
                        `).join('')}
                    </div>
                </div>` : ''}

            ${similar.results?.length > 0 ? renderCarouselHTML('More Like This', similar.results.slice(0, 10)) : ''}
        `;

        // Fetch RT ratings async (don't block initial render)
        if (!DEMO_MODE) {
            fetchOMDbRatings(title, year).then(ratings => {
                const row = document.getElementById('ratingsRow');
                if (ratings && row) {
                    if (ratings.rt != null) {
                        row.innerHTML += rtBadgeHTML(ratings.rt, 'Rotten Tomatoes');
                    }
                    if (ratings.metascore != null) {
                        row.innerHTML += metascoreBadgeHTML(ratings.metascore);
                    }
                }
            });
        }

    } catch (err) {
        body.innerHTML = `
            <div class="empty-state">
                <span class="empty-icon">⚠️</span>
                <p>Failed to load details</p>
                <p class="muted">${err.message}</p>
            </div>`;
    }
}

function closeDetail() {
    document.getElementById('detailView').classList.add('hidden');
}

function ratingCircleHTML(score, label) {
    const pct = score / 10;
    const circumference = 2 * Math.PI * 22;
    const offset = circumference * (1 - pct);
    const color = pct >= 0.75 ? '#22c55e' : pct >= 0.5 ? '#eab308' : '#ef4444';

    return `
        <div class="rating-circle">
            <div class="rating-ring">
                <svg width="52" height="52" viewBox="0 0 52 52">
                    <circle cx="26" cy="26" r="22" fill="none" stroke="var(--surface-light)" stroke-width="3"/>
                    <circle cx="26" cy="26" r="22" fill="none" stroke="${color}" stroke-width="3"
                        stroke-linecap="round" stroke-dasharray="${circumference}" stroke-dashoffset="${offset}"/>
                </svg>
                <span class="score">${score.toFixed(1)}</span>
            </div>
            <span class="rating-label">${label}</span>
        </div>`;
}

function rtBadgeHTML(score, label) {
    const icon = score >= 60 ? '🍅' : '🤢';
    const color = score >= 60 ? '#FA320A' : '#6C9E1E';
    return `
        <div class="rating-badge rt-badge" style="--badge-color:${color}">
            <span class="badge-icon">${icon}</span>
            <span class="badge-score">${score}%</span>
            <span class="badge-label">${label}</span>
        </div>`;
}

function metascoreBadgeHTML(score) {
    const color = score >= 61 ? '#6C3' : score >= 40 ? '#FC3' : '#F00';
    return `
        <div class="rating-badge meta-badge">
            <span class="meta-score" style="background:${color}">${score}</span>
            <span class="badge-label">Metascore</span>
        </div>`;
}

// ============================================
// Search
// ============================================

function setupSearchFilters() {
    const platformEl = document.getElementById('platformFilters');
    const genreEl = document.getElementById('genreFilters');

    platformEl.innerHTML = Object.entries(PLATFORMS).map(([key, p]) =>
        `<button class="chip" data-platform="${key}" onclick="toggleSearchPlatform('${key}')" style="--active-bg:${p.color}">${p.name}</button>`
    ).join('');

    genreEl.innerHTML = GENRES.map(g =>
        `<button class="chip" data-genre="${g.id}" onclick="toggleSearchGenre(${g.id})">${g.name}</button>`
    ).join('');
}

function toggleSearchPlatform(key) {
    const btn = document.querySelector(`[data-platform="${key}"]`);
    if (activeSearchFilters.platforms.has(key)) {
        activeSearchFilters.platforms.delete(key);
        btn.classList.remove('active');
        btn.style.background = '';
    } else {
        activeSearchFilters.platforms.add(key);
        btn.classList.add('active');
        btn.style.background = PLATFORMS[key].color;
    }
    performSearch(document.getElementById('searchInput').value);
}

function toggleSearchGenre(id) {
    const btn = document.querySelector(`[data-genre="${id}"]`);
    if (activeSearchFilters.genres.has(id)) {
        activeSearchFilters.genres.delete(id);
        btn.classList.remove('active');
        btn.style.background = '';
    } else {
        activeSearchFilters.genres.add(id);
        btn.classList.add('active');
        btn.style.background = 'var(--accent)';
    }
    performSearch(document.getElementById('searchInput').value);
}

async function performSearch(query) {
    const resultsEl = document.getElementById('searchResults');
    const emptyEl = document.getElementById('searchEmpty');
    const browseEl = document.getElementById('browseGenres');

    query = (query || '').trim();

    if (!query && activeSearchFilters.platforms.size === 0 && activeSearchFilters.genres.size === 0) {
        resultsEl.innerHTML = '';
        emptyEl.classList.add('hidden');
        browseEl.classList.remove('hidden');
        return;
    }

    browseEl.classList.add('hidden');
    emptyEl.classList.add('hidden');
    resultsEl.innerHTML = '<div class="spinner" style="grid-column:1/-1"></div>';

    try {
        let results;

        if (query && activeSearchFilters.platforms.size > 0) {
            // Search + platform filter: fetch both search and discover, intersect
            const [searchData, discoverMovies, discoverTV] = await Promise.all([
                tmdbFetch('/search/multi', { query, page: 1 }),
                tmdbFetch('/discover/movie', {
                    sort_by: 'popularity.desc', watch_region: 'US',
                    with_watch_providers: [...activeSearchFilters.platforms].map(k => PLATFORMS[k].id).join('|'),
                }),
                tmdbFetch('/discover/tv', {
                    sort_by: 'popularity.desc', watch_region: 'US',
                    with_watch_providers: [...activeSearchFilters.platforms].map(k => PLATFORMS[k].id).join('|'),
                }),
            ]);
            const discoverIds = new Set([
                ...discoverMovies.results.map(r => r.id),
                ...discoverTV.results.map(r => r.id),
            ]);
            results = searchData.results
                .filter(r => (r.media_type === 'movie' || r.media_type === 'tv') && discoverIds.has(r.id));
        } else if (query) {
            const data = await tmdbFetch('/search/multi', { query, page: 1 });
            results = data.results.filter(r => r.media_type === 'movie' || r.media_type === 'tv');
        } else {
            // Use discover when only filters are active
            const params = { sort_by: 'popularity.desc', watch_region: 'US' };
            if (activeSearchFilters.platforms.size > 0) {
                params.with_watch_providers = [...activeSearchFilters.platforms]
                    .map(k => PLATFORMS[k].id).join('|');
            }
            if (activeSearchFilters.genres.size > 0) {
                params.with_genres = [...activeSearchFilters.genres].join(',');
            }
            const data = await tmdbFetch('/discover/movie', params);
            results = data.results.map(r => ({ ...r, media_type: 'movie' }));
        }

        // Client-side genre filter for search results
        if (query && activeSearchFilters.genres.size > 0) {
            results = results.filter(r =>
                r.genre_ids?.some(id => activeSearchFilters.genres.has(id))
            );
        }

        if (results.length === 0) {
            resultsEl.innerHTML = '';
            emptyEl.classList.remove('hidden');
        } else {
            emptyEl.classList.add('hidden');
            resultsEl.innerHTML = results.map(item => posterCardHTML(item)).join('');
        }
    } catch (err) {
        resultsEl.innerHTML = `<p class="muted" style="grid-column:1/-1;text-align:center;padding:40px">Error: ${err.message}</p>`;
    }
}

function setupBrowseGenres() {
    document.getElementById('browseGenres').innerHTML = `
        <h3 style="grid-column:1/-1;font-size:20px;font-weight:700;padding:0 0 4px">Browse by Genre</h3>
        ${GENRES.map(g => `
            <button class="genre-card" style="--g1:${g.gradient[0]};--g2:${g.gradient[1]}" onclick="searchByGenre('${g.name}', ${g.id})">
                ${g.name}
            </button>
        `).join('')}`;
}

function searchByGenre(name, id) {
    document.getElementById('searchInput').value = name;
    activeSearchFilters.genres.add(id);
    const btn = document.querySelector(`[data-genre="${id}"]`);
    if (btn) { btn.classList.add('active'); btn.style.background = 'var(--accent)'; }
    performSearch(name);
}

// ============================================
// Watchlist
// ============================================

function toggleWatchlistFromDetail(id, mediaType, title, posterPath, rating, genreIds) {
    const idx = watchlist.findIndex(w => w.id === id && w.mediaType === mediaType);
    const btn = document.getElementById('watchlistBtn');

    if (idx !== -1) {
        watchlist.splice(idx, 1);
        btn.classList.remove('active');
        btn.innerHTML = '🔖 Add to Watchlist';
    } else {
        watchlist.push({
            id, mediaType, title, posterPath, rating,
            genreIds: genreIds || [],
            addedDate: new Date().toISOString(),
            isWatched: false,
        });
        btn.classList.add('active');
        btn.innerHTML = '🔖 In Watchlist';
    }

    saveWatchlist();
    renderWatchlist();
}

function toggleWatched(id, mediaType) {
    const item = watchlist.find(w => w.id === id && w.mediaType === mediaType);
    if (item) {
        item.isWatched = !item.isWatched;
        saveWatchlist();
        renderWatchlist();
    }
}

function removeFromWatchlist(id, mediaType) {
    watchlist = watchlist.filter(w => !(w.id === id && w.mediaType === mediaType));
    saveWatchlist();
    renderWatchlist();
}

function setWatchlistFilter(filter) {
    watchlistFilter = filter;
    document.querySelectorAll('#watchlistFilters .filter-pill').forEach(btn =>
        btn.classList.toggle('active', btn.dataset.filter === filter));
    renderWatchlist();
}

function cycleSortOrder() {
    const sorts = ['recent', 'alpha', 'rating'];
    const icons = ['↕️', '🔤', '⭐'];
    const idx = (sorts.indexOf(watchlistSort) + 1) % sorts.length;
    watchlistSort = sorts[idx];
    document.getElementById('sortIcon').textContent = icons[idx];
    renderWatchlist();
}

function renderWatchlist() {
    const contentEl = document.getElementById('watchlistContent');
    const emptyEl = document.getElementById('watchlistEmpty');

    let items = [...watchlist];

    // Filter
    if (watchlistFilter === 'movie') items = items.filter(w => w.mediaType === 'movie');
    else if (watchlistFilter === 'tv') items = items.filter(w => w.mediaType === 'tv');
    else if (watchlistFilter === 'anime') items = items.filter(w => w.mediaType === 'tv' && w.genreIds?.includes(16));

    // Sort
    if (watchlistSort === 'recent') items.sort((a, b) => new Date(b.addedDate) - new Date(a.addedDate));
    else if (watchlistSort === 'alpha') items.sort((a, b) => a.title.localeCompare(b.title));
    else if (watchlistSort === 'rating') items.sort((a, b) => (b.rating || 0) - (a.rating || 0));

    if (items.length === 0) {
        contentEl.innerHTML = '';
        emptyEl.classList.remove('hidden');
    } else {
        emptyEl.classList.add('hidden');
        contentEl.innerHTML = items.map(item => {
            const poster = imgURL(item.posterPath, 'w185');
            const type = item.mediaType === 'movie' ? 'Movie' : 'TV Show';
            return `
                <div class="watchlist-item" onclick="openDetail(${item.id}, '${item.mediaType}')">
                    <div class="watchlist-poster">
                        ${poster ? `<img src="${poster}" alt="${escapeHTML(item.title)}" loading="lazy">` : ''}
                    </div>
                    <div class="watchlist-info">
                        <h3>${escapeHTML(item.title)}</h3>
                        <div class="type-badge">${type}</div>
                        ${item.rating ? `<div class="rating-small">⭐ ${item.rating.toFixed(1)}</div>` : ''}
                    </div>
                    <button class="watchlist-watched-btn ${item.isWatched ? 'checked' : ''}"
                        onclick="event.stopPropagation(); toggleWatched(${item.id}, '${item.mediaType}')">
                        ${item.isWatched ? '✅' : '⭕'}
                    </button>
                    <button class="watchlist-delete-btn"
                        onclick="event.stopPropagation(); removeFromWatchlist(${item.id}, '${item.mediaType}')">
                        🗑️
                    </button>
                </div>`;
        }).join('');
    }
}

function saveWatchlist() {
    localStorage.setItem('theater_watchlist', JSON.stringify(watchlist));
}

// ============================================
// Sidebar
// ============================================

function setupPlatformToggles() {
    const el = document.getElementById('platformToggles');
    el.innerHTML = Object.entries(PLATFORMS).map(([key, p]) => `
        <button class="platform-toggle" onclick="togglePlatform('${key}')">
            <span class="platform-dot" style="background:${p.color}"></span>
            <span class="name">${p.name}</span>
            <span class="check" id="platformCheck_${key}">✅</span>
        </button>
    `).join('');
}

function togglePlatform(key) {
    const check = document.getElementById(`platformCheck_${key}`);
    if (enabledPlatforms.has(key)) {
        enabledPlatforms.delete(key);
        check.textContent = '⭕';
    } else {
        enabledPlatforms.add(key);
        check.textContent = '✅';
    }
}

// ============================================
// Demo Mode
// ============================================

function demoData(path) {
    const demoMovies = [
        { id: 550, title: 'Fight Club', overview: 'An insomniac office worker and a devil-may-care soap maker form an underground fight club.', poster_path: null, backdrop_path: null, media_type: 'movie', genre_ids: [18, 53], vote_average: 8.4, vote_count: 26000, release_date: '1999-10-15', popularity: 73.5 },
        { id: 680, title: 'Pulp Fiction', overview: 'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption.', poster_path: null, backdrop_path: null, media_type: 'movie', genre_ids: [53, 80], vote_average: 8.5, vote_count: 25000, release_date: '1994-09-10', popularity: 80.2 },
        { id: 238, title: 'The Godfather', overview: 'The aging patriarch of an organized crime dynasty transfers control to his reluctant son.', poster_path: null, backdrop_path: null, media_type: 'movie', genre_ids: [18, 80], vote_average: 8.7, vote_count: 18000, release_date: '1972-03-14', popularity: 95.1 },
        { id: 1396, name: 'Breaking Bad', overview: 'A high school chemistry teacher turns to manufacturing and selling methamphetamine.', poster_path: null, backdrop_path: null, media_type: 'tv', genre_ids: [18, 80], vote_average: 8.9, vote_count: 12000, first_air_date: '2008-01-20', popularity: 200.3 },
        { id: 85937, name: 'Demon Slayer', overview: 'A boy finds his family slaughtered by a demon and vows to avenge them.', poster_path: null, backdrop_path: null, media_type: 'tv', genre_ids: [16, 10759], vote_average: 8.7, vote_count: 5000, first_air_date: '2019-04-06', popularity: 150.2 },
    ];

    return {
        page: 1,
        results: demoMovies,
        total_pages: 1,
        total_results: demoMovies.length,
        // For detail endpoints
        ...demoMovies[0],
        genres: [{ id: 18, name: 'Drama' }, { id: 53, name: 'Thriller' }],
        tagline: 'Demo Mode',
        cast: [],
    };
}

// ============================================
// Utilities
// ============================================

function escapeHTML(str) {
    if (!str) return '';
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
}
