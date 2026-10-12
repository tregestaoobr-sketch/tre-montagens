const CACHE = 'tre-montagens-v5-2-push';
const CORE = ['./', './index.html', './manifest.json', './logo-tre.jpg'];

self.addEventListener('install', event => event.waitUntil(
  caches.open(CACHE).then(c => c.addAll(CORE)).then(() => self.skipWaiting())
));

self.addEventListener('activate', event => event.waitUntil(
  caches.keys().then(keys => Promise.all(
    keys.filter(k => k.startsWith('tre-montagens-') && k !== CACHE).map(k => caches.delete(k))
  )).then(() => self.clients.claim())
));

self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;
  event.respondWith(
    caches.match(event.request).then(cached => cached || fetch(event.request).then(response => {
      const copy = response.clone();
      if (new URL(event.request.url).origin === self.location.origin) {
        caches.open(CACHE).then(c => c.put(event.request, copy));
      }
      return response;
    }).catch(() => cached))
  );
});

/* Recebe notificações Web Push enviadas pelo servidor configurado no Supabase. */
self.addEventListener('push', event => {
  let data = { title: 'T.R.E. Montagens', body: 'Você tem uma nova notificação.', url: './index.html' };
  try {
    if (event.data) data = { ...data, ...event.data.json() };
  } catch (_) {
    try { if (event.data) data.body = event.data.text(); } catch (_) {}
  }
  event.waitUntil(self.registration.showNotification(data.title || 'T.R.E. Montagens', {
    body: data.body || 'Você tem uma nova notificação.',
    icon: './logo-tre.jpg',
    badge: './logo-tre.jpg',
    tag: data.tag || 'tre-montagens',
    data: { url: data.url || './index.html' },
    vibrate: [200, 100, 200]
  }));
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  const target = new URL(event.notification.data?.url || './index.html', self.location.origin).href;
  event.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => {
    for (const client of list) {
      if (client.url.startsWith(self.location.origin) && 'focus' in client) {
        client.navigate(target);
        return client.focus();
      }
    }
    return self.clients.openWindow(target);
  }));
});
