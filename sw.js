/* ================================================================
   Finance App — Service Worker (SELF-DESTRUCT)
   ================================================================
   This file exists ONLY to clean up the previous SW installation.
   Once installed, it:
     1. Unregisters itself
     2. Deletes all caches it created
     3. Reloads any open tabs to ensure fresh content
   After this runs once on each device, the SW is gone forever.
   You can delete this file entirely after a few weeks.
   ================================================================ */

self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    // Delete every cache from the old SW
    const keys = await caches.keys();
    await Promise.all(keys.map(k => caches.delete(k)));

    // Unregister this SW
    await self.registration.unregister();

    // Reload any open clients so they pick up the new (no-SW) version
    const clients = await self.clients.matchAll({ type: 'window' });
    clients.forEach(client => {
      try { client.navigate(client.url); } catch (e) {}
    });
  })());
});
