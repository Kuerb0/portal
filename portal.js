// Dibuja una tarjeta con miniatura por cada web de webs.json. Para añadir una web basta con añadirla a ese fichero
// (y una captura en img/). Sin url, la tarjeta sale como «En preparación». «icono» es el nombre de uno de ICONOS.
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
  cubiertos: "M11 9H9V2H7v7H5V2H3v7c0 2.12 1.66 3.84 3.75 3.97V22h2.5v-9.03C11.34 12.84 13 11.12 13 9V2h-2v7zm5-3v8h2.5v8H21V2c-2.76 0-5 2.24-5 4z",
  arbol: "M22 11V3h-7v3H9V3H2v8h7V8h2v10h4v3h7v-8h-7v3h-2V8h2v3z",
  tabla: "M10 10.02h5V21h-5zM17 21h3c1.1 0 2-.9 2-2v-9h-5v11zm3-18H5c-1.1 0-2 .9-2 2v3h19V5c0-1.1-.9-2-2-2zM3 19c0 1.1.9 2 2 2h3V10H3v9z",
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
  a.className = "tarjeta " + (w.url ? "viva" : "apagada");
  a.style.animationDelay = `${i * 80}ms`;
  const miniatura = w.imagen
    ? `<img src="${esc(w.imagen)}" alt="Vista previa de ${esc(w.titulo)}" loading="lazy">`
    : `<div class="sin-imagen" aria-hidden="true">${svg(w.icono, 56)}</div>`;
  const etiquetas = (w.etiquetas || []).map(e => `<span class="etiqueta">${esc(e)}</span>`).join("");
  const repo = w.tipo === "repo";           // un proyecto de GitHub: se enlaza el repositorio, no una web
  const estado = !w.url ? `<span class="estado">En preparación</span>`
    : repo ? `<span class="estado repo">Repositorio</span>` : `<span class="estado activa">Activa</span>`;
  a.innerHTML = `<div class="marco" aria-hidden="true">
      <div class="barra"><i></i><i></i><i></i><span>${esc(dominio(w.url))}</span></div>
      <div class="vista">${miniatura}</div>
    </div>
    <div class="cuerpo">
      <div class="titulo"><span class="ico" aria-hidden="true">${svg(w.icono, 22)}</span><h2>${esc(w.titulo)}</h2></div>
      <div class="etiquetas">${etiquetas}</div>
      <details class="mas"><summary>${svg("chevron", 20)}Descripción</summary><p>${esc(w.descripcion)}</p></details>
      <div class="pie-tarjeta">${w.url ? `<a class="boton" href="${esc(w.url)}" target="_blank" rel="noopener" aria-label="${repo ? "Ver en GitHub" : "Abrir"}: ${esc(w.titulo)}">${repo ? "Ver en GitHub" : "Abrir"} ${svg("flecha", 18)}</a>` : ""}${estado}</div>
    </div>`;
  return a;
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
  const sitios = ver.filter(w => w.tipo !== "repo"), repos = ver.filter(w => w.tipo === "repo");
  const nodos = [];
  if (sitios.length && repos.length) nodos.push(titulo("Webs interactivas"));
  nodos.push(...sitios.map(tarjeta));
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
  lista.replaceChildren(...webs.filter(w => w.instalar).map(w => {
    const li = document.createElement("li");
    li.innerHTML = `<a class="inst-app" href="${esc(w.instalar)}">
      <img src="${esc(w.icono_app)}" alt="" width="48" height="48" loading="lazy">
      <span><strong>${esc(w.titulo)}</strong><small>Abrir e instalar</small></span>${svg("flecha", 18)}</a>`;
    return li;
  }));
}

function pintarInstalar() {
  const boton = document.getElementById("btn-instalar"), texto = document.getElementById("inst-estado");
  const I = window.Instalar;
  boton.hidden = !I.puede();
  document.getElementById("pasos-ios").classList.toggle("resalta", I.ios);
  document.getElementById("pasos-android").classList.toggle("resalta", !I.ios && !I.puede() && !I.instalada);
  texto.textContent = I.instalada ? "Ya estás usando el portal como app."
    : I.puede() ? "Pulsa el botón para añadir el portal a tu pantalla de inicio."
    : I.ios ? "En iPhone no hay botón: sigue los pasos de Safari que ves abajo."
    : "Tu navegador no ofrece botón: usa el menú del navegador, como en los pasos de abajo.";
}
document.getElementById("btn-instalar").addEventListener("click", () => window.Instalar.instalar());
addEventListener("instalar-cambio", pintarInstalar);
pintarInstalar();

if ("serviceWorker" in navigator) navigator.serviceWorker.register("sw.js").catch(() => {});
