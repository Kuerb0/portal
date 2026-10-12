// Solo guarda el envoltorio (la página y los iconos) para que abra aunque no haya red. La app de Streamlit no se guarda:
// vive en su propio servidor. Red primero, para que las actualizaciones lleguen; caché si no hay conexión.
const V = "estadistica-v1";
const ARCHIVOS = ["./", "index.html", "manifest.webmanifest", "icon-192.png", "icon-512.png", "apple-touch-icon.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(V).then(c => c.addAll(ARCHIVOS)));
  self.skipWaiting();
});

self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== V).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});

self.addEventListener("fetch", e => {
  if (e.request.method !== "GET" || new URL(e.request.url).origin !== location.origin) return;     // lo de otros sitios no se toca
  e.respondWith(
    fetch(e.request).then(r => { const copia = r.clone(); caches.open(V).then(c => c.put(e.request, copia)); return r; })
      .catch(() => caches.match(e.request).then(m => m || caches.match("./")))
  );
});
