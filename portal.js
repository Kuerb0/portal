// Dibuja una tarjeta por cada web de webs.json. Para añadir una web basta con añadirla a ese fichero.
const rejilla = document.getElementById("rejilla");
const vacio = document.getElementById("vacio");
const buscar = document.getElementById("buscar");
let webs = [];

function tarjeta(w) {
  const a = document.createElement(w.url ? "a" : "div");
  a.className = "tarjeta" + (w.url ? "" : " apagada");
  if (w.url) { a.href = w.url; a.target = "_blank"; a.rel = "noopener"; }
  const etiquetas = (w.etiquetas || []).map(e => `<span class="etiqueta">${esc(e)}</span>`).join("");
  a.innerHTML = `<div class="icono" aria-hidden="true">${esc(w.icono || "🌐")}</div>
    <h2>${esc(w.titulo)}</h2><p>${esc(w.descripcion)}</p>
    <div class="etiquetas">${etiquetas}</div>
    <span class="boton">${w.url ? "Abrir →" : "En preparación"}</span>`;
  return a;
}

function esc(s) {
  return String(s).replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
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
