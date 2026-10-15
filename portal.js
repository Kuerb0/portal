// Dibuja una tarjeta con miniatura por cada web de webs.json. Para añadir una web basta con añadirla a ese fichero
// (y una captura en img/, o varias en «imagenes» para una galería que va cambiando; «descargas»: lista de {texto, archivo} con botones de descarga, ficheros en descargas/). Sin url, la tarjeta sale como «En preparación». «icono» es el nombre de uno de ICONOS (o «icono_img»: el icono propio del proyecto, una imagen).
const rejilla = document.getElementById("rejilla");
const vacio = document.getElementById("vacio");
const buscar = document.getElementById("buscar");
let webs = [];

// Iconos Material de 24x24 (relleno). Un nombre desconocido usa «apps».
const ICONOS = {
  avion: "M21 16v-2l-8-5V3.5c0-.83-.67-1.5-1.5-1.5S10 2.67 10 3.5V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z",
  grafico: "M5 9.2h3V19H5zM10.6 5h2.8v14h-2.8zm5.6 8H19v6h-2.8z",
  euro: "M15 18.5c-2.51 0-4.68-1.42-5.76-3.5H15v-2H8.58c-.05-.33-.08-.66-.08-1s.03-.67.08-1H15V9H9.24C10.32 6.92 12.5 5.5 15 5.5c1.61 0 3.09.59 4.23 1.57L21 5.3C19.41 3.87 17.3 3 15 3c-3.92 0-7.24 2.51-8.48 6H3v2h3.06c-.04.33-.06.66-.06 1s.02.67.06 1H3v2h3.52c1.24 3.49 4.56 6 8.48 6 2.31 0 4.41-.87 6-2.3l-1.78-1.77c-1.13.98-2.6 1.57-4.22 1.57z",
  funciones: "M18 4H6v2l6.5 6L6 18v2h12v-3h-7l5-5-5-5h7z",
  codigo: "M9.4 16.6 4.8 12l4.6-4.6L8 6l-6 6 6 6 1.4-1.4zm5.2 0 4.6-4.6-4.6-4.6L16 6l6 6-6 6-1.4-1.4z",
  apps: "M4 8h4V4H4v4zm6 12h4v-4h-4v4zm-6 0h4v-4H4v4zm0-6h4v-4H4v4zm6 0h4v-4h-4v4zm6-10v4h4V4h-4zm-6 4h4V4h-4v4zm6 6h4v-4h-4v4zm0 6h4v-4h-4v4z",
  calendario: "M20 3h-1V1h-2v2H7V1H5v2H4c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 18H4V8h16v13z",
  cubiertos: "M11 9H9V2H7v7H5V2H3v7c0 2.12 1.66 3.84 3.75 3.97V22h2.5v-9.03C11.34 12.84 13 11.12 13 9V2h-2v7zm5-3v8h2.5v8H21V2c-2.76 0-5 2.24-5 4z",
  arbol: "M22 11V3h-7v3H9V3H2v8h7V8h2v10h4v3h7v-8h-7v3h-2V8h2v3z",
  tabla: "M10 10.02h5V21h-5zM17 21h3c1.1 0 2-.9 2-2v-9h-5v11zm3-18H5c-1.1 0-2 .9-2 2v3h19V5c0-1.1-.9-2-2-2zM3 19c0 1.1.9 2 2 2h3V10H3v9z",
  apagar: "M13 3h-2v10h2V3zm4.83 2.17-1.42 1.42C17.99 7.86 19 9.81 19 12c0 3.87-3.13 7-7 7s-7-3.13-7-7c0-2.19 1.01-4.14 2.58-5.42L6.17 5.17C4.23 6.82 3 9.26 3 12c0 4.97 4.03 9 9 9s9-4.03 9-9c0-2.74-1.23-5.18-3.17-6.83z",
  nota: "M5 3h14a2 2 0 0 1 2 2v10l-6 6H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2zm9 16.5V15h4.5L14 19.5zM7 8h10v2H7V8zm0 4h6v2H7v-2z",
  descarga: "M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z",
  chevron: "M16.59 8.59 12 13.17 7.41 8.59 6 10l6 6 6-6z",
  flecha: "M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z",
};

function svg(nombre, tam) {
  return `<svg viewBox="0 0 24 24" width="${tam}" height="${tam}" aria-hidden="true"><path fill="currentColor" d="${ICONOS[nombre] || ICONOS.apps}"/></svg>`;
}

function esc(s) {
  return String(s).replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
}

function dominio(url) {
  try {
    const u = new URL(url);
    return u.host === "github.com" || u.host.endsWith(".github.io") ? u.host + u.pathname.replace(/\/$/, "") : u.host;   // en GitHub se ve la ruta
  } catch (e) { return "próximamente"; }
}

function tarjeta(w, i) {
  const a = document.createElement("article");
  a.className = "tarjeta " + (w.url || w.tipo === "app" ? "viva" : "apagada");
  a.style.animationDelay = `${i * 80}ms`;
  const fotos = (w.imagenes && w.imagenes.length ? w.imagenes : w.imagen ? [w.imagen] : []);
  const miniatura = fotos.length > 1
    ? `<div class="galeria">${fotos.map((s, k) => `<img class="${k ? "" : "on"}" src="${esc(s)}" alt="Vista previa ${k + 1} de ${esc(w.titulo)}" loading="lazy">`).join("")}
        <div class="puntos">${fotos.map((_, k) => `<button type="button" class="${k ? "" : "on"}" aria-label="Ver captura ${k + 1}"></button>`).join("")}</div></div>`
    : fotos.length
    ? `<img src="${esc(fotos[0])}" alt="Vista previa de ${esc(w.titulo)}" loading="lazy">`
    : `<div class="sin-imagen" aria-hidden="true">${svg(w.icono, 56)}</div>`;
  const etiquetas = (w.etiquetas || []).map(e => `<span class="etiqueta">${esc(e)}</span>`).join("");
  const destino = w.abrir || w.url;       // «abrir»: la tarjeta lleva al envoltorio instalable; «url» sigue siendo la web de verdad (barra de direcciones)
  const repo = w.tipo === "repo";           // un proyecto de GitHub: se enlaza el repositorio, no una web
  const estado = !w.url ? `<span class="estado">En preparación</span>`
    : repo ? `<span class="estado repo">Repositorio</span>` : `<span class="estado activa">Activa</span>`;
  const insignia = w.tipo === "app" && !w.url ? `<span class="estado repo">App de escritorio</span>` : estado;
  a.innerHTML = `<div class="marco" aria-hidden="true">
      <div class="barra"><i></i><i></i><i></i><span>${esc(dominio(w.url))}</span></div>
      <div class="vista">${miniatura}</div>
    </div>
    <div class="cuerpo">
      <div class="titulo"><span class="ico${w.icono_img ? " propio" : ""}" aria-hidden="true">${w.icono_img ? `<img src="${esc(w.icono_img)}" alt="" width="36" height="36" loading="lazy">` : svg(w.icono, 22)}</span><h2>${esc(w.titulo)}</h2></div>
      <div class="etiquetas">${etiquetas}</div>
      <details class="mas"><summary>${svg("chevron", 20)}Descripción</summary><p>${esc(w.descripcion)}</p></details>
      ${(w.descargas || []).length ? `<div class="descargas">${w.descargas.map(d => `<a class="boton sec" href="${esc(d.archivo)}" download="${esc(d.archivo.split("/").pop())}" title="Descarga un .bat; Windows puede avisar al abrirlo (Más información → Ejecutar de todas formas)">${svg("descarga", 18)} ${esc(d.texto)}</a>`).join("")}</div>` : ""}
      <div class="pie-tarjeta">${w.url ? `<a class="boton" href="${esc(destino)}" target="_blank" rel="noopener" aria-label="${repo ? "Ver en GitHub" : "Abrir"}: ${esc(w.titulo)}">${repo ? "Ver en GitHub" : "Abrir"} ${svg("flecha", 18)}</a>` : ""}${insignia}</div>
    </div>`;
  return a;
}

// Galería de capturas: cambia sola cada pocos segundos (se pausa al pasar el ratón o si el sistema pide menos movimiento).
function mostrar(g, k) {
  const fotos = [...g.querySelectorAll("img")], pts = [...g.querySelectorAll(".puntos button")];
  g.dataset.i = k = (k + fotos.length) % fotos.length;
  fotos.forEach((f, j) => f.classList.toggle("on", j === k));
  pts.forEach((p, j) => p.classList.toggle("on", j === k));
}
document.addEventListener("click", e => {
  const p = e.target.closest(".galeria .puntos button");
  if (p) { const g = p.closest(".galeria"); mostrar(g, [...p.parentNode.children].indexOf(p)); g.dataset.pausa = "1"; }
});
document.addEventListener("mouseover", e => { const g = e.target.closest(".galeria"); if (g) g.dataset.sobre = "1"; });
document.addEventListener("mouseout", e => { const g = e.target.closest(".galeria"); if (g && !g.contains(e.relatedTarget)) delete g.dataset.sobre; });
if (!matchMedia("(prefers-reduced-motion: reduce)").matches) {
  setInterval(() => {
    if (document.hidden) return;
    document.querySelectorAll(".galeria").forEach(g => { if (!g.dataset.sobre && !g.dataset.pausa) mostrar(g, +(g.dataset.i || 0) + 1); });
  }, 3500);
}

function titulo(texto) {
  const h = document.createElement("h2");
  h.className = "seccion";
  h.textContent = texto;
  return h;
}

function pintar() {
  const q = buscar.value.trim().toLowerCase();
  const ver = webs.filter(w => !q || [w.titulo, w.descripcion, ...(w.etiquetas || [])].join(" ").toLowerCase().includes(q));
  const sitios = ver.filter(w => w.tipo !== "repo" && w.tipo !== "app"), apps = ver.filter(w => w.tipo === "app"), repos = ver.filter(w => w.tipo === "repo");
  const nodos = [];
  if (sitios.length && (apps.length || repos.length)) nodos.push(titulo("Webs interactivas"));
  nodos.push(...sitios.map(tarjeta));
  if (apps.length) nodos.push(titulo("Apps de escritorio"), ...apps.map(tarjeta));
  if (repos.length) nodos.push(titulo("Proyectos en GitHub"), ...repos.map(tarjeta));
  rejilla.replaceChildren(...nodos);
  vacio.hidden = ver.length > 0;
}

fetch("webs.json").then(r => r.json()).then(d => { webs = d; pintar(); pintarApps(); })
  .catch(() => { rejilla.textContent = "No se han podido cargar las webs."; });
buscar.addEventListener("input", pintar);

// tema claro u oscuro: el del sistema, y se recuerda lo que se elija
const raiz = document.documentElement;
const guardado = (() => { try { return localStorage.getItem("tema"); } catch (e) { return null; } })();
if (guardado) raiz.dataset.tema = guardado;
document.getElementById("tema").addEventListener("click", () => {
  const oscuro = raiz.dataset.tema ? raiz.dataset.tema === "oscuro" : matchMedia("(prefers-color-scheme: dark)").matches;
  raiz.dataset.tema = oscuro ? "claro" : "oscuro";
  try { localStorage.setItem("tema", raiz.dataset.tema); } catch (e) { /* sin almacenamiento: no pasa nada */ }
});

// ---- sección «Instálame»: botón de instalar el portal, ayuda según el aparato y una ficha por cada web instalable
function pintarApps() {
  const lista = document.getElementById("inst-apps");
  const propio = { titulo: "Este portal", instalar: "inicio/", icono_app: "icon-192.png" };       // el portal se instala desde inicio/
  lista.replaceChildren(...[propio, ...webs.filter(w => w.instalar)].map(w => {
    const li = document.createElement("li");
    li.innerHTML = `<a class="inst-app" href="${esc(w.instalar)}">
      <img src="${esc(w.icono_app)}" alt="" width="48" height="48" loading="lazy">
      <span><strong>${esc(w.titulo)}</strong><small>Abrir e instalar</small></span>${svg("flecha", 18)}</a>`;
    return li;
  }));
}

function pintarInstalar() {
  const I = window.Instalar;
  document.getElementById("instalar").hidden = I.instalada;       // dentro de la app instalada no tiene sentido (y la ficha del portal se abriría a sí misma)
  document.getElementById("pasos-ios").classList.toggle("resalta", I.ios);
  document.getElementById("pasos-android").classList.toggle("resalta", !I.ios && !I.instalada);
  document.getElementById("inst-estado").textContent = I.instalada ? "Ya estás usando el portal como app."
    : "Pulsa una ficha: se abre la página de esa web con su botón para instalarla.";
}
pintarInstalar();

if ("serviceWorker" in navigator) navigator.serviceWorker.register("sw.js").catch(() => {});
