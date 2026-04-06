// Theater — Netflix Clone
const TMDB_BASE = 'https://api.themoviedb.org/3';
const IMG_BASE = 'https://image.tmdb.org/t/p/';
let API_KEY = '8ebf6146d38c10e74873f2729e20afde';
let DEMO_MODE = false;

const PLATFORMS = {
    netflix:     { id: 8,   name: 'Netflix',     color: '#E50914', url: 'https://www.netflix.com/search?q=' },
    disneyPlus:  { id: 337, name: 'Disney+',     color: '#0063E5', url: 'https://www.disneyplus.com/search?q=' },
    hboMax:      { id: 384, name: 'Max',          color: '#B535F6', url: 'https://play.max.com/search?q=' },
    primeVideo:  { id: 9,   name: 'Prime Video',  color: '#00A8E1', url: 'https://www.amazon.com/s?i=instant-video&k=' },
    appleTVPlus: { id: 350, name: 'Apple TV+',    color: '#555',    url: 'https://tv.apple.com/search?term=' },
    crunchyroll: { id: 283, name: 'Crunchyroll',  color: '#F47521', url: 'https://www.crunchyroll.com/search?q=' },
};

const GENRES = [
    { id: 28, name: 'Action', gradient: ['#FF416C','#FF4B2B'] },
    { id: 12, name: 'Adventure', gradient: ['#11998e','#38ef7d'] },
    { id: 16, name: 'Animation', gradient: ['#6441A5','#2a0845'] },
    { id: 35, name: 'Comedy', gradient: ['#F7971E','#FFD200'] },
    { id: 80, name: 'Crime', gradient: ['#434343','#000'] },
    { id: 99, name: 'Documentary', gradient: ['#2193b0','#6dd5ed'] },
    { id: 18, name: 'Drama', gradient: ['#C33764','#1D2671'] },
    { id: 14, name: 'Fantasy', gradient: ['#7F00FF','#E100FF'] },
    { id: 27, name: 'Horror', gradient: ['#000','#e74c3c'] },
    { id: 10749, name: 'Romance', gradient: ['#ee9ca7','#ffdde1'] },
    { id: 878, name: 'Sci-Fi', gradient: ['#0F2027','#2C5364'] },
    { id: 53, name: 'Thriller', gradient: ['#200122','#6f0000'] },
];

let watchlist = JSON.parse(localStorage.getItem('theater_watchlist') || '[]');
let enabledPlatforms = new Set(Object.keys(PLATFORMS));
let searchTimeout = null;
let activeSearchFilters = { platforms: new Set(), genres: new Set() };
let watchlistFilter = 'all';
let currentBillboard = null;

// ---- API ----
async function tmdbFetch(path, params = {}) {
    if (DEMO_MODE) return demoData(path);
    params.api_key = API_KEY;
    params.language = 'en-US';
    const qs = new URLSearchParams(params).toString();
    const res = await fetch(`${TMDB_BASE}${path}?${qs}`);
    if (!res.ok) throw new Error(`TMDB ${res.status}`);
    return res.json();
}

function img(path, size = 'w500') { return path ? `${IMG_BASE}${size}${path}` : null; }

async function fetchOMDb(title, year) {
    try {
        const p = new URLSearchParams({ apikey: 'b2b11f5b', t: title });
        if (year) p.set('y', year);
        const r = await fetch(`https://www.omdbapi.com/?${p}`);
        const d = await r.json();
        if (d.Response === 'False') return null;
        let rt = null;
        for (const x of (d.Ratings || [])) { if (x.Source === 'Rotten Tomatoes') rt = parseInt(x.Value); }
        return { rt, meta: d.Metascore !== 'N/A' ? parseInt(d.Metascore) : null };
    } catch { return null; }
}

// ---- Init ----
document.addEventListener('DOMContentLoaded', () => {
    if (API_KEY) { startApp(); }
    else {
        const saved = localStorage.getItem('theater_api_key');
        if (saved) { API_KEY = saved; startApp(); }
        else {
            document.getElementById('apiKeyModal').classList.remove('hidden');
            document.getElementById('app').classList.add('hidden');
        }
    }
    document.getElementById('apiKeySubmit').onclick = () => {
        const k = document.getElementById('apiKeyInput').value.trim();
        if (k) { API_KEY = k; localStorage.setItem('theater_api_key', k); startApp(); }
    };
    document.getElementById('apiKeyDemo').onclick = () => { DEMO_MODE = true; startApp(); };
    document.getElementById('apiKeyInput').addEventListener('keydown', e => {
        if (e.key === 'Enter') document.getElementById('apiKeySubmit').click();
    });
    document.getElementById('searchInput').addEventListener('input', e => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => performSearch(e.target.value), 400);
    });

    // Header solid on scroll
    const homeScroll = document.getElementById('homeScroll');
    if (homeScroll) {
        homeScroll.addEventListener('scroll', () => {
            document.getElementById('appHeader').classList.toggle('solid', homeScroll.scrollTop > 50);
        });
    }
});

function startApp() {
    document.getElementById('apiKeyModal').classList.add('hidden');
    document.getElementById('app').classList.remove('hidden');
    setupSearchFilters();
    setupBrowseGenres();
    loadHome();
    renderWatchlist();
}

// ---- Category filter ----
async function filterCategory(cat) {
    document.querySelectorAll('.cat-pill').forEach(b => b.classList.toggle('active', b.dataset.cat === cat));
    if (cat === 'all') { loadHome(); return; }

    const rowsEl = document.getElementById('rows');
    const bbBg = document.getElementById('billboardBg');
    const bbInfo = document.getElementById('billboardInfo');
    bbBg.innerHTML = '<div class="shimmer shimmer-billboard"></div>';
    bbInfo.innerHTML = '';
    rowsEl.innerHTML = Array(3).fill('').map(() => shimmerRow()).join('');

    try {
        let sections = [];
        if (cat === 'movie') {
            const [popular, upcoming, action, comedy] = await Promise.all([
                tmdbFetch('/movie/popular'),
                tmdbFetch('/movie/upcoming'),
                tmdbFetch('/discover/movie', { with_genres: '28', sort_by: 'popularity.desc' }),
                tmdbFetch('/discover/movie', { with_genres: '35', sort_by: 'popularity.desc' }),
            ]);
            sections = [
                { title: 'Popular Films', items: popular.results },
                { title: 'Coming Soon', items: upcoming.results },
                { title: 'Action Films', items: action.results },
                { title: 'Comedies', items: comedy.results },
            ];
        } else if (cat === 'tv') {
            const [popular, topRated, drama, crime] = await Promise.all([
                tmdbFetch('/tv/popular'),
                tmdbFetch('/tv/top_rated'),
                tmdbFetch('/discover/tv', { with_genres: '18', sort_by: 'popularity.desc' }),
                tmdbFetch('/discover/tv', { with_genres: '80', sort_by: 'popularity.desc' }),
            ]);
            sections = [
                { title: 'Popular TV Shows', items: popular.results.map(r => ({...r, media_type:'tv'})) },
                { title: 'Top Rated', items: topRated.results.map(r => ({...r, media_type:'tv'})) },
                { title: 'Drama Series', items: drama.results.map(r => ({...r, media_type:'tv'})) },
                { title: 'Crime Series', items: crime.results.map(r => ({...r, media_type:'tv'})) },
            ];
        } else if (cat === 'animation') {
            const [movies, shows] = await Promise.all([
                tmdbFetch('/discover/movie', { with_genres: '16', sort_by: 'popularity.desc' }),
                tmdbFetch('/discover/tv', { with_genres: '16', sort_by: 'popularity.desc' }),
            ]);
            sections = [
                { title: 'Animated Films', items: movies.results },
                { title: 'Animated Series', items: shows.results.map(r => ({...r, media_type:'tv'})) },
            ];
        } else if (cat === 'anime') {
            const [crunchyroll, topAnime] = await Promise.all([
                tmdbFetch('/discover/tv', { with_watch_providers: '283', with_genres: '16', watch_region: 'US', sort_by: 'popularity.desc' }),
                tmdbFetch('/discover/tv', { with_genres: '16', with_keywords: '210024', sort_by: 'popularity.desc' }),
            ]);
            sections = [
                { title: 'Popular Anime', items: crunchyroll.results.map(r => ({...r, media_type:'tv'})) },
                { title: 'Top Anime', items: topAnime.results.map(r => ({...r, media_type:'tv'})) },
            ];
        }

        // Billboard from first section
        const bbItem = sections[0]?.items[0];
        if (bbItem) {
            const mt = bbItem.media_type || 'movie';
            bbBg.innerHTML = bbItem.backdrop_path ? `<img src="${img(bbItem.backdrop_path,'w780')}">` : '';
            const t = bbItem.title || bbItem.name;
            bbInfo.innerHTML = `
                <div class="billboard-title">${esc(t)}</div>
                <div class="billboard-buttons">
                    <button class="btn-play" onclick="openDetail(${bbItem.id},'${mt}')">&#9654; Info</button>
                    <button class="btn-list" onclick="quickAdd(${bbItem.id},'${mt}','${esc(t).replace(/'/g,"\\'")}','${bbItem.poster_path||''}',${bbItem.vote_average||0})">+ My List</button>
                </div>`;
        }

        rowsEl.innerHTML = sections.filter(s => s.items.length).map(s => buildRow(s.title, s.items)).join('');
    } catch (err) {
        rowsEl.innerHTML = `<div class="empty"><p>${err.message}</p></div>`;
    }
}

// ---- Navigation ----
function switchTab(tab) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nf-tab, .nf-nav-item').forEach(el => {
        el.classList.toggle('active', el.dataset.tab === tab);
    });
    document.getElementById(`${tab}Tab`).classList.add('active');
    if (tab === 'search') setTimeout(() => document.getElementById('searchInput').focus(), 100);
}

// ---- Home ----
async function loadHome() {
    const rowsEl = document.getElementById('rows');
    const bbBg = document.getElementById('billboardBg');
    const bbInfo = document.getElementById('billboardInfo');

    bbBg.innerHTML = '<div class="shimmer shimmer-billboard"></div>';
    bbInfo.innerHTML = '';
    rowsEl.innerHTML = Array(4).fill('').map(() => shimmerRow()).join('');

    try {
        const [trending, netflix, anime, upcoming, popular] = await Promise.all([
            tmdbFetch('/trending/all/week'),
            tmdbFetch('/discover/movie', { with_watch_providers: '8', watch_region: 'US', sort_by: 'popularity.desc' }),
            tmdbFetch('/discover/tv', { with_watch_providers: '283', with_genres: '16', watch_region: 'US', sort_by: 'popularity.desc' }),
            tmdbFetch('/movie/upcoming'),
            tmdbFetch('/movie/popular'),
        ]);

        // Billboard — pick random from top 5 trending
        const bbItem = trending.results[Math.floor(Math.random() * 5)];
        currentBillboard = bbItem;
        const bbType = bbItem.media_type || 'movie';
        const bbBackdrop = img(bbItem.backdrop_path, 'w780');
        const bbTitle = bbItem.title || bbItem.name;
        const match = Math.floor(70 + Math.random() * 28);

        bbBg.innerHTML = bbBackdrop ? `<img src="${bbBackdrop}" alt="">` : '';
        bbInfo.innerHTML = `
            <div class="billboard-title">${esc(bbTitle)}</div>
            <div class="billboard-meta">
                <span class="billboard-match">${match}% Match</span>
                <span>${(bbItem.release_date || bbItem.first_air_date || '').slice(0,4)}</span>
            </div>
            ${bbItem.overview ? `<div class="billboard-overview">${esc(bbItem.overview)}</div>` : ''}
            <div class="billboard-buttons">
                <button class="btn-play" onclick="openDetail(${bbItem.id}, '${bbType}')">&#9654; Info</button>
                <button class="btn-list" onclick="quickAdd(${bbItem.id}, '${bbType}', '${esc(bbTitle).replace(/'/g,"\\'")}', '${bbItem.poster_path||''}', ${bbItem.vote_average||0})">+ My List</button>
            </div>`;

        // Build rows
        const top10 = trending.results.slice(0, 10);
        let html = '';
        html += buildTop10Row('Top 10 This Week', top10);
        html += buildRow('Trending Now', trending.results.slice(5));
        html += buildRow('New on Netflix', netflix.results);
        html += buildRow('Top Anime', anime.results);
        html += buildRow('Critically Acclaimed', popular.results.filter(m => m.vote_average >= 7.5));
        html += buildRow('Coming Soon', upcoming.results);
        rowsEl.innerHTML = html;

    } catch (err) {
        rowsEl.innerHTML = `<div class="empty"><p>Failed to load: ${err.message}</p>
            <button class="btn-red" style="margin-top:12px;width:auto;padding:8px 20px" onclick="loadHome()">Retry</button></div>`;
    }
}

function buildRow(title, items) {
    if (!items || !items.length) return '';
    return `<div class="nf-row">
        <h3 class="section-title">${esc(title)}</h3>
        <div class="nf-carousel">${items.map(cardHTML).join('')}</div>
    </div>`;
}

function buildTop10Row(title, items) {
    return `<div class="nf-row">
        <h3 class="section-title">${esc(title)}</h3>
        <div class="nf-top10-row">${items.map((item, i) => {
            const mt = item.media_type || (item.first_air_date ? 'tv' : 'movie');
            const poster = img(item.poster_path, 'w342');
            return `<div class="nf-top10-item" onclick="openDetail(${item.id},'${mt}')">
                <span class="nf-top10-num">${i+1}</span>
                <div class="nf-top10-poster">${poster ? `<img src="${poster}" loading="lazy">` : ''}</div>
            </div>`;
        }).join('')}</div>
    </div>`;
}

function cardHTML(item) {
    const title = item.title || item.name || '';
    const poster = img(item.poster_path, 'w342');
    const mt = item.media_type || (item.first_air_date ? 'tv' : 'movie');
    return `<div class="nf-card" onclick="openDetail(${item.id},'${mt}')">
        ${poster ? `<img src="${poster}" alt="${esc(title)}" loading="lazy">` : '<div class="nf-card-placeholder"></div>'}
    </div>`;
}

function shimmerRow() {
    return `<div class="nf-row"><div style="padding:0 12px"><div class="shimmer" style="width:120px;height:18px;margin-bottom:8px"></div></div>
        <div class="nf-carousel">${Array(6).fill('<div class="shimmer shimmer-card"></div>').join('')}</div></div>`;
}

// ---- Detail ----
async function openDetail(id, mediaType) {
    const modal = document.getElementById('detailView');
    const backdrop = document.getElementById('detailBackdrop');
    const body = document.getElementById('detailBody');

    modal.classList.remove('hidden');
    document.getElementById('detailScroll').scrollTop = 0;
    backdrop.innerHTML = '<button class="nf-close" onclick="closeDetail()">&#10005;</button><div class="shimmer" style="width:100%;height:100%"></div>';
    body.innerHTML = '<div class="spinner"></div>';

    try {
        const ep = mediaType === 'movie' ? `/movie/${id}` : `/tv/${id}`;
        const [detail, credits, providers, similar] = await Promise.all([
            tmdbFetch(ep),
            tmdbFetch(`${ep}/credits`).catch(() => ({ cast: [] })),
            tmdbFetch(`${ep}/watch/providers`).catch(() => ({ results: {} })),
            tmdbFetch(`${ep}/similar`).catch(() => ({ results: [] })),
        ]);

        const title = detail.title || detail.name;
        const bdImg = img(detail.backdrop_path, 'w780') || img(detail.poster_path, 'w500');
        const year = (detail.release_date || detail.first_air_date || '').slice(0, 4);
        const runtime = detail.runtime ? `${Math.floor(detail.runtime/60)}h ${detail.runtime%60}m`
            : detail.number_of_seasons ? `${detail.number_of_seasons} Season${detail.number_of_seasons > 1 ? 's' : ''}` : '';
        const genres = (detail.genres || []).map(g => g.name).join(', ');
        const match = Math.floor(70 + Math.random() * 28);
        const inList = watchlist.some(w => w.id === id && w.mediaType === mediaType);

        // Providers
        const usData = providers.results?.US || {};
        const tmdbLink = usData.link || null;
        const flatrate = usData.flatrate || [];
        const matched = flatrate.map(p => {
            const pl = Object.values(PLATFORMS).find(x => x.id === p.provider_id);
            return pl || null;
        }).filter(Boolean);

        backdrop.innerHTML = `<button class="nf-close" onclick="closeDetail()">&#10005;</button>
            ${bdImg ? `<img src="${bdImg}" alt="">` : ''}`;

        body.innerHTML = `
            <h1 class="detail-title">${esc(title)}</h1>
            <div class="detail-meta-row">
                <span class="match-score">${match}% Match</span>
                ${year ? `<span>${year}</span>` : ''}
                ${runtime ? `<span>${runtime}</span>` : ''}
                <span class="maturity">TV-MA</span>
            </div>
            ${genres ? `<div class="detail-genres">${esc(genres)}</div>` : ''}

            <div class="detail-actions-row">
                ${tmdbLink ? `<button class="nf-action-btn play" onclick="window.open('${tmdbLink}','_blank')">&#9654; Watch Now</button>` : '<button class="nf-action-btn play" disabled style="opacity:0.4">&#9654; Not Available</button>'}
                <button class="nf-action-btn secondary ${inList?'active':''}" id="listBtn" onclick="toggleList(${id},'${mediaType}','${esc(title).replace(/'/g,"\\'")}','${detail.poster_path||''}',${detail.vote_average||0},${JSON.stringify((detail.genres||[]).map(g=>g.id))})">
                    ${inList ? '✓ My List' : '+ My List'}
                </button>
            </div>

            <div class="ratings-row" id="ratingsRow">
                ${detail.vote_average > 0 ? `<div class="rating-badge"><span class="tmdb-score">TMDB ${detail.vote_average.toFixed(1)}</span></div>` : ''}
            </div>

            <div class="detail-overview">${esc(detail.overview || 'No overview available.')}</div>

            ${matched.length > 0 ? `
                <div class="streaming-section">
                    <h3>Available on</h3>
                    <div class="streaming-links">
                        ${matched.map(p => `<span class="streaming-link" style="background:${p.color}">${p.name}</span>`).join('')}
                    </div>
                    ${tmdbLink ? `<a href="${tmdbLink}" target="_blank" rel="noopener" class="watch-all-link" onclick="event.stopPropagation()">View all watch options →</a>` : ''}
                </div>` : ''}

            ${credits.cast?.length > 0 ? `
                <div class="detail-section">
                    <div class="detail-label">Cast</div>
                    <div class="cast-row">${credits.cast.slice(0, 15).map(c => `
                        <div class="cast-card">
                            <div class="cast-img">${c.profile_path ? `<img src="${img(c.profile_path,'w185')}" loading="lazy">` : ''}</div>
                            <div class="cast-name">${esc(c.name)}</div>
                            <div class="cast-char">${esc(c.character||'')}</div>
                        </div>`).join('')}
                    </div>
                </div>` : ''}

            ${similar.results?.length > 0 ? buildRow('More Like This', similar.results.slice(0, 12)) : ''}
        `;

        // Async RT ratings
        if (!DEMO_MODE) {
            fetchOMDb(title, year).then(r => {
                const row = document.getElementById('ratingsRow');
                if (r && row) {
                    if (r.rt != null) row.innerHTML += `<div class="rating-badge"><span class="rt-score">🍅 ${r.rt}%</span></div>`;
                    if (r.meta != null) {
                        const mc = r.meta >= 61 ? '#6c3' : r.meta >= 40 ? '#fc3' : '#f00';
                        row.innerHTML += `<div class="rating-badge"><span class="meta-box" style="background:${mc}">${r.meta}</span> Metascore</div>`;
                    }
                }
            });
        }
    } catch (err) {
        body.innerHTML = `<div class="empty"><p>Failed to load: ${err.message}</p></div>`;
    }
}

function closeDetail() { document.getElementById('detailView').classList.add('hidden'); }

// ---- Watchlist ----
function toggleList(id, mt, title, poster, rating, genres) {
    const idx = watchlist.findIndex(w => w.id === id && w.mediaType === mt);
    const btn = document.getElementById('listBtn');
    if (idx !== -1) {
        watchlist.splice(idx, 1);
        if (btn) { btn.classList.remove('active'); btn.innerHTML = '+ My List'; }
    } else {
        watchlist.push({ id, mediaType: mt, title, posterPath: poster, rating, genreIds: genres || [], addedDate: new Date().toISOString(), isWatched: false });
        if (btn) { btn.classList.add('active'); btn.innerHTML = '✓ My List'; }
    }
    localStorage.setItem('theater_watchlist', JSON.stringify(watchlist));
    renderWatchlist();
}

function quickAdd(id, mt, title, poster, rating) {
    if (watchlist.some(w => w.id === id && w.mediaType === mt)) return;
    watchlist.push({ id, mediaType: mt, title, posterPath: poster, rating, genreIds: [], addedDate: new Date().toISOString(), isWatched: false });
    localStorage.setItem('theater_watchlist', JSON.stringify(watchlist));
    renderWatchlist();
}

function setWatchlistFilter(f) {
    watchlistFilter = f;
    document.querySelectorAll('#watchlistFilters .nf-chip').forEach(b => b.classList.toggle('active', b.dataset.filter === f));
    renderWatchlist();
}

function renderWatchlist() {
    const el = document.getElementById('watchlistContent');
    const empty = document.getElementById('watchlistEmpty');
    let items = [...watchlist];
    if (watchlistFilter === 'movie') items = items.filter(w => w.mediaType === 'movie');
    else if (watchlistFilter === 'tv') items = items.filter(w => w.mediaType === 'tv');

    if (!items.length) { el.innerHTML = ''; empty.classList.remove('hidden'); return; }
    empty.classList.add('hidden');
    el.innerHTML = items.map(w => {
        const poster = img(w.posterPath, 'w342');
        return `<div class="nf-card watchlist-card" onclick="openDetail(${w.id},'${w.mediaType}')">
            ${poster ? `<img src="${poster}" loading="lazy">` : '<div class="nf-card-placeholder"></div>'}
            <div class="watchlist-actions">
                <button class="wl-btn" onclick="event.stopPropagation();removeWL(${w.id},'${w.mediaType}')">✕</button>
            </div>
        </div>`;
    }).join('');
}

function removeWL(id, mt) {
    watchlist = watchlist.filter(w => !(w.id === id && w.mediaType === mt));
    localStorage.setItem('theater_watchlist', JSON.stringify(watchlist));
    renderWatchlist();
}

// ---- Search ----
function setupSearchFilters() {
    document.getElementById('platformFilters').innerHTML = Object.entries(PLATFORMS).map(([k, p]) =>
        `<button class="nf-chip" data-platform="${k}" onclick="toggleSP('${k}')">${p.name}</button>`
    ).join('');
    document.getElementById('genreFilters').innerHTML = GENRES.map(g =>
        `<button class="nf-chip" data-genre="${g.id}" onclick="toggleSG(${g.id})">${g.name}</button>`
    ).join('');
}

function toggleSP(k) {
    const b = document.querySelector(`[data-platform="${k}"]`);
    if (activeSearchFilters.platforms.has(k)) { activeSearchFilters.platforms.delete(k); b.classList.remove('active'); }
    else { activeSearchFilters.platforms.add(k); b.classList.add('active'); }
    performSearch(document.getElementById('searchInput').value);
}

function toggleSG(id) {
    const b = document.querySelector(`[data-genre="${id}"]`);
    if (activeSearchFilters.genres.has(id)) { activeSearchFilters.genres.delete(id); b.classList.remove('active'); }
    else { activeSearchFilters.genres.add(id); b.classList.add('active'); }
    performSearch(document.getElementById('searchInput').value);
}

async function performSearch(query) {
    const el = document.getElementById('searchResults');
    const empty = document.getElementById('searchEmpty');
    const browse = document.getElementById('browseGenres');
    query = (query || '').trim();

    if (!query && !activeSearchFilters.platforms.size && !activeSearchFilters.genres.size) {
        el.innerHTML = ''; empty.classList.add('hidden'); browse.classList.remove('hidden'); return;
    }
    browse.classList.add('hidden'); empty.classList.add('hidden');
    el.innerHTML = '<div class="spinner" style="grid-column:1/-1"></div>';

    try {
        let results;
        if (query && activeSearchFilters.platforms.size > 0) {
            const [s, dm, dt] = await Promise.all([
                tmdbFetch('/search/multi', { query, page: 1 }),
                tmdbFetch('/discover/movie', { sort_by: 'popularity.desc', watch_region: 'US', with_watch_providers: [...activeSearchFilters.platforms].map(k => PLATFORMS[k].id).join('|') }),
                tmdbFetch('/discover/tv', { sort_by: 'popularity.desc', watch_region: 'US', with_watch_providers: [...activeSearchFilters.platforms].map(k => PLATFORMS[k].id).join('|') }),
            ]);
            const ids = new Set([...dm.results.map(r=>r.id), ...dt.results.map(r=>r.id)]);
            results = s.results.filter(r => (r.media_type==='movie'||r.media_type==='tv') && ids.has(r.id));
        } else if (query) {
            results = (await tmdbFetch('/search/multi', { query, page: 1 })).results.filter(r => r.media_type==='movie'||r.media_type==='tv');
        } else {
            const p = { sort_by: 'popularity.desc', watch_region: 'US' };
            if (activeSearchFilters.platforms.size) p.with_watch_providers = [...activeSearchFilters.platforms].map(k=>PLATFORMS[k].id).join('|');
            if (activeSearchFilters.genres.size) p.with_genres = [...activeSearchFilters.genres].join(',');
            results = (await tmdbFetch('/discover/movie', p)).results.map(r=>({...r, media_type:'movie'}));
        }
        if (query && activeSearchFilters.genres.size) results = results.filter(r => r.genre_ids?.some(id => activeSearchFilters.genres.has(id)));

        if (!results.length) { el.innerHTML = ''; empty.classList.remove('hidden'); }
        else { empty.classList.add('hidden'); el.innerHTML = results.map(cardHTML).join(''); }
    } catch (err) {
        el.innerHTML = `<p style="grid-column:1/-1;text-align:center;padding:40px;color:#666">${err.message}</p>`;
    }
}

function setupBrowseGenres() {
    document.getElementById('browseGenres').innerHTML = `
        <h3 class="section-title" style="grid-column:1/-1">Browse</h3>
        ${GENRES.map(g => `<button class="genre-card" style="--g1:${g.gradient[0]};--g2:${g.gradient[1]}" onclick="searchByGenre('${g.name}',${g.id})">${g.name}</button>`).join('')}`;
}

function searchByGenre(name, id) {
    document.getElementById('searchInput').value = name;
    activeSearchFilters.genres.add(id);
    const b = document.querySelector(`[data-genre="${id}"]`);
    if (b) b.classList.add('active');
    performSearch(name);
}

// ---- Demo ----
function demoData() {
    const d = [
        { id: 550, title: 'Fight Club', overview: 'An insomniac office worker...', poster_path: null, backdrop_path: null, media_type: 'movie', genre_ids: [18,53], vote_average: 8.4, release_date: '1999-10-15' },
        { id: 680, title: 'Pulp Fiction', overview: 'Four tales of violence...', poster_path: null, backdrop_path: null, media_type: 'movie', genre_ids: [53,80], vote_average: 8.5, release_date: '1994-09-10' },
        { id: 238, title: 'The Godfather', overview: 'Crime dynasty...', poster_path: null, backdrop_path: null, media_type: 'movie', genre_ids: [18,80], vote_average: 8.7, release_date: '1972-03-14' },
    ];
    return { page: 1, results: d, total_pages: 1, ...d[0], genres: [{id:18,name:'Drama'}], cast: [] };
}

function esc(s) { if (!s) return ''; const d = document.createElement('div'); d.textContent = s; return d.innerHTML; }
