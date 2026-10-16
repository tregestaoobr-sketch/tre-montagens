const CACHE = 'tre-montagens-v5-2-push';
const CORE = ['./', './index.html', './manifest.json', './logo-tre.jpg'];
self.addEventListener('install', event => event.waitUntil(
  caches.open(CACHE).then(c => c.addAll(CORE)).then(() => self.skipWaiting())
));
self.addEventListener('activate', event => event.waitUntil(
  caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
    .then(() => self.clients.claim())
));
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;
  event.respondWith(caches.match(event.request).then(cached => cached || fetch(event.request).then(response => {
    if (response && response.ok && new URL(event.request.url).origin === self.location.origin) {
      const copy = response.clone(); caches.open(CACHE).then(c => c.put(event.request, copy));
    }
    return response;
  }).catch(() => cached)));
});
self.addEventListener('push', event => {
  let data = {};
  try { data = event.data ? event.data.json() : {}; } catch (_) { data = { body: event.data?.text() || '' }; }
  const title = data.title || 'T.R.E. Montagens';
  const options = { body: data.body || 'Você tem uma nova atualização.', icon: './logo-tre.jpg', badge: './logo-tre.jpg', tag: data.tag || 'tre-notificacao', renotify: true, data: { url: data.url || './' } };
  event.waitUntil(self.registration.showNotification(title, options));
});
self.addEventListener('notificationclick', event => {
  event.notification.close();
  const target = new URL(event.notification.data?.url || './', self.location.origin).href;
  event.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => {
    for (const client of list) { if (client.url.startsWith(self.location.origin) && 'focus' in client) { client.navigate(target); return client.focus(); } }
    return self.clients.openWindow(target);
  }));
});
