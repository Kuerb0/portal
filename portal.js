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
  flecha: "M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z",
};

function svg(nombre, tam) {
  return `<svg viewBox="0 0 24 24" width="${tam}" height="${tam}" aria-hidden="true"><path fill="currentColor" d="${ICONOS[nombre] || ICONOS.apps}"/></svg>`;
}

function esc(s) {
  return String(s).replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
}

function dominio(url) {
  try { return new URL(url).host; } catch (e) { return "próximamente"; }
}

function tarjeta(w, i) {
  const a = document.createElement(w.url ? "a" : "div");
  a.className = "tarjeta" + (w.url ? "" : " apagada");
  a.style.animationDelay = `${i * 80}ms`;
  if (w.url) { a.href = w.url; a.target = "_blank"; a.rel = "noopener"; }
  const miniatura = w.imagen
    ? `<img src="${esc(w.imagen)}" alt="Vista previa de ${esc(w.titulo)}" loading="lazy">`
    : `<div class="sin-imagen" aria-hidden="true">${svg(w.icono, 56)}</div>`;
  const etiquetas = (w.etiquetas || []).map(e => `<span class="etiqueta">${esc(e)}</span>`).join("");
  const estado = w.url ? `<span class="estado activa">Activa</span>` : `<span class="estado">En preparación</span>`;
  a.innerHTML = `<div class="marco" aria-hidden="true">
      <div class="barra"><i></i><i></i><i></i><span>${esc(dominio(w.url))}</span></div>
      <div class="vista">${miniatura}</div>
    </div>
    <div class="cuerpo">
      <div class="titulo"><span class="ico" aria-hidden="true">${svg(w.icono, 22)}</span><h2>${esc(w.titulo)}</h2></div>
      <p>${esc(w.descripcion)}</p>
      <div class="etiquetas">${etiquetas}</div>
      <div class="pie-tarjeta">${w.url ? `<span class="boton">Abrir ${svg("flecha", 18)}</span>` : ""}${estado}</div>
    </div>`;
  return a;
}

function pintar() {
  const q = buscar.value.trim().toLowerCase();
  const ver = webs.filter(w => !q || [w.titulo, w.descripcion, ...(w.etiquetas || [])].join(" ").toLowerCase().includes(q));
  rejilla.replaceChildren(...ver.map(tarjeta));
  vacio.hidden = ver.length > 0;
}

fetch("webs.json").then(r => r.json()).then(d => { webs = d; pintar(); })
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
