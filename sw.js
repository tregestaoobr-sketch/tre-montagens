const CACHE = 'tre-montagens-v5-1-obras';
const CORE = ['./','./index.html','./manifest.json','./logo-tre.jpg'];
self.addEventListener('install', event => event.waitUntil(caches.open(CACHE).then(c => c.addAll(CORE)).then(() => self.skipWaiting())));
self.addEventListener('activate', event => event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim())));
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;
  event.respondWith(caches.match(event.request).then(cached => cached || fetch(event.request).then(response => {
    const copy = response.clone();
    if (new URL(event.request.url).origin === location.origin) caches.open(CACHE).then(c => c.put(event.request, copy));
    return response;
  }).catch(() => cached)));
});


// T.R.E. push notifications
self.addEventListener("push", (event) => {
  let data = {}; try { data = event.data ? event.data.json() : {}; } catch (_) {}
  event.waitUntil(self.registration.showNotification(data.title || "T.R.E. Montagens", {
    body: data.body || "Você tem uma atualização.", icon: "./logo-tre.jpg",
    badge: "./logo-tre.jpg", data: {url: data.url || "./"}
  }));
});
self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const target = new URL(event.notification.data?.url || "./", self.location.origin).href;
  event.waitUntil(clients.matchAll({type:"window",includeUncontrolled:true}).then(wins => {
    for (const c of wins) if (c.url.startsWith(self.location.origin) && "focus" in c) { c.navigate(target); return c.focus(); }
    return clients.openWindow(target);
  }));
});
