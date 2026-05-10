/* ================================================================
   Finance App — Service Worker
   ================================================================
   How updates work:
   - The CACHE_VERSION below changes whenever the app is updated.
   - When the browser sees a different sw.js, it installs the new
     version in the background and notifies the page.
   - The page then shows an "Update available" banner.
   - User clicks → page sends SKIP_WAITING → SW activates and reloads.
   ================================================================ */

const CACHE_VERSION = 'finance-v8';   // bump this on every release
const STATIC_CACHE = `${CACHE_VERSION}-static`;

// Files always cached on install
const STATIC_ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png',
];

/* ============ INSTALL ============ */
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then(cache => cache.addAll(STATIC_ASSETS).catch(() => {
        // Don't fail install if some asset is missing
        return Promise.resolve();
      }))
  );
  // Don't auto-skip — wait for user confirmation via banner
});

/* ============ ACTIVATE ============ */
// Removes old caches when activating
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys
          .filter(key => key.startsWith('finance-') && !key.startsWith(CACHE_VERSION))
          .map(key => caches.delete(key))
      )
    ).then(() => self.clients.claim())
  );
});

/* ============ FETCH ============
   Strategy:
   - HTML/index → network-first (always try fresh, fallback to cache)
   - Static assets (JS/CSS/icons) → cache-first
   - Supabase API → network-only (don't cache user data)
*/
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);

  // Don't cache Supabase API calls or any external API
  if (url.hostname.includes('supabase.co') || url.hostname.includes('supabase.in')) {
    return; // let browser handle it
  }

  // For navigation requests (HTML), use network-first so updates show ASAP
  if (request.mode === 'navigate' ||
      (request.method === 'GET' && request.headers.get('accept')?.includes('text/html'))) {
    event.respondWith(networkFirst(request));
    return;
  }

  // Same-origin static assets: cache-first
  if (url.origin === location.origin) {
    event.respondWith(cacheFirst(request));
    return;
  }

  // External assets (Google Fonts, Supabase JS CDN): cache-first too
  event.respondWith(cacheFirst(request));
});

async function networkFirst(request) {
  try {
    const fresh = await fetch(request);
    // Update cache in background
    if (fresh && fresh.status === 200) {
      const cache = await caches.open(STATIC_CACHE);
      cache.put(request, fresh.clone()).catch(() => {});
    }
    return fresh;
  } catch (e) {
    const cached = await caches.match(request);
    if (cached) return cached;
    // Last resort: return cached index.html
    return caches.match('./index.html');
  }
}

async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;
  try {
    const fresh = await fetch(request);
    if (fresh && fresh.status === 200) {
      const cache = await caches.open(STATIC_CACHE);
      cache.put(request, fresh.clone()).catch(() => {});
    }
    return fresh;
  } catch (e) {
    return new Response('Offline', { status: 503 });
  }
}

/* ============ MESSAGE ============
   Page sends SKIP_WAITING when user clicks "Update now"
*/
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
