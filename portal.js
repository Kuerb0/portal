// Dibuja una tarjeta con miniatura por cada web de webs.json. Para añadir una web basta con añadirla a ese fichero
// (y una captura en img/). Sin url, la tarjeta sale como «En preparación».
const rejilla = document.getElementById("rejilla");
const vacio = document.getElementById("vacio");
const buscar = document.getElementById("buscar");
let webs = [];

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
    : `<div class="sin-imagen" aria-hidden="true">${esc(w.icono || "🌐")}</div>`;
  const etiquetas = (w.etiquetas || []).map(e => `<span class="etiqueta">${esc(e)}</span>`).join("");
  a.innerHTML = `<span class="estado ${w.url ? "on" : "off"}">${w.url ? "Activa" : "Pronto"}</span>
    <div class="marco" aria-hidden="true">
      <div class="barra"><i></i><i></i><i></i><span>${esc(dominio(w.url))}</span></div>
      <div class="vista">${miniatura}</div>
    </div>
    <div class="cuerpo">
      <h2><span aria-hidden="true">${esc(w.icono || "")}</span> ${esc(w.titulo)}</h2>
      <p>${esc(w.descripcion)}</p>
      <div class="etiquetas">${etiquetas}</div>
      <span class="boton">${w.url ? "Abrir →" : "En preparación"}</span>
    </div>`;
  return a;
}

let etiqueta = "";
function chips() {
  const todas = [...new Set(webs.flatMap(w => w.etiquetas || []))];
  document.getElementById("chips").replaceChildren(...["", ...todas].map(t => {
    const b = document.createElement("button");
    b.type = "button"; b.className = "chip"; b.textContent = t || "Todas";
    b.setAttribute("aria-pressed", String(t === etiqueta));
    b.onclick = () => { etiqueta = t; chips(); pintar(); };
    return b;
  }));
}

function cifras() {
  const hechas = webs.filter(w => w.url).length;
  document.getElementById("cifras").innerHTML = [[webs.length, "webs"], [hechas, "activas"], [webs.length - hechas, "en camino"]]
    .map(([n, t]) => `<li><b>${n}</b><span>${t}</span></li>`).join("");
}

function pintar() {
  const q = buscar.value.trim().toLowerCase();
  const ver = webs.filter(w => (!etiqueta || (w.etiquetas || []).includes(etiqueta)) &&
    (!q || [w.titulo, w.descripcion, ...(w.etiquetas || [])].join(" ").toLowerCase().includes(q)));
  rejilla.replaceChildren(...ver.map(tarjeta));
  vacio.hidden = ver.length > 0;
}

fetch("webs.json").then(r => r.json()).then(d => { webs = d; cifras(); chips(); pintar(); })
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
