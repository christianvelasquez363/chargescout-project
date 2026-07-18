// ChargeScout service worker
// Caches the app shell so it installs as a real app and opens even with a
// weak connection. Community data (reports, points, leaderboard) still needs
// a live connection to Supabase — only the app itself is cached, not the data.

const CACHE_NAME = 'chargescout-v2';
const APP_SHELL = [
  './',
  './index.html',
  './chargescout.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './icon-512-maskable.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  // Never cache Supabase API calls — those must always hit the network.
  if (event.request.url.includes('supabase.co')) return;

  event.respondWith(
    caches.match(event.request).then((cached) => {
      return cached || fetch(event.request).catch(() => caches.match('./chargescout.html'));
    })
  );
});
