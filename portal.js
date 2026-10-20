// Dibuja una tarjeta con miniatura por cada web de webs.json. Para añadir una web basta con añadirla a ese fichero
// (y una captura en img/, o varias en «imagenes» para una galería que va cambiando; «descargas»: lista de {texto, archivo} con botones de descarga, ficheros en descargas/; «flujograma»: un SVG de flujogramas/ que se despliega en la tarjeta; «guia»: ruta de un PDF en guias/ para el botón «Guía (PDF)»). Sin url, la tarjeta sale como «En preparación». «icono» es el nombre de uno de ICONOS (o «icono_img»: el icono propio del proyecto, una imagen).
const rejilla = document.getElementById("rejilla");
const vacio = document.getElementById("vacio");
const contador = document.getElementById("contador");
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
  pc: "M21 2H3c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h7v2H8v2h8v-2h-2v-2h7c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H3V4h18v12z",
  movil: "M17 1.01L7 1c-1.1 0-2 .9-2 2v18c0 1.1.9 2 2 2h10c1.1 0 2-.9 2-2V3c0-1.1-.9-1.99-2-1.99zM17 19H7V5h10v14z",
  chevron: "M16.59 8.59 12 13.17 7.41 8.59 6 10l6 6 6-6z",
  libro: "M21 5c-1.11-.35-2.33-.5-3.5-.5-1.95 0-4.05.4-5.5 1.5-1.45-1.1-3.55-1.5-5.5-1.5S2.45 4.9 1 6v14.65c0 .25.25.5.5.5.1 0 .15-.05.25-.05C3.1 20.45 5.05 20 6.5 20c1.95 0 4.05.4 5.5 1.5 1.35-.85 3.8-1.5 5.5-1.5 1.65 0 3.35.3 4.75 1.05.1.05.15.05.25.05.25 0 .5-.25.5-.5V6c-.6-.45-1.25-.75-2-1zm0 13.5c-1.1-.35-2.3-.5-3.5-.5-1.7 0-4.15.65-5.5 1.5V8c1.35-.85 3.8-1.5 5.5-1.5 1.2 0 2.4.15 3.5.5v11.5z",
  ampliar: "M21 11V3h-8l3.29 3.29-10 10L3 13v8h8l-3.29-3.29 10-10z",
  video: "M17 10.5V7c0-.55-.45-1-1-1H4c-.55 0-1 .45-1 1v10c0 .55.45 1 1 1h12c.55 0 1-.45 1-1v-3.5l4 4v-11l-4 4z",
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
  } catch (e) { return ""; }
}

// Windows (.exe, .bat, .msi), Android (.apk) o nada (vídeos y demás)
function plataforma(d) {
  const f = d.archivo.toLowerCase().split("?")[0];
  return f.endsWith(".apk") ? "movil" : /\.(exe|bat|msi)$/.test(f) ? "pc" : "";
}
const NOMBRE = { pc: "Windows", movil: "Android" };
const megas = b => b ? `${Math.max(1, Math.round(b / 1e6))} MB` : "";
const esRepo = w => w.tipo === "repo" || (w.tipo === "app" && /github\.com/.test(w.url || ""));   // proyecto de GitHub: se enlaza el repositorio

function miniatura(w) {
  const fotos = w.imagenes && w.imagenes.length ? w.imagenes : w.imagen ? [w.imagen] : [];
  if (fotos.length > 1) return `<div class="galeria">${fotos.map((s, k) => `<img class="${k ? "" : "on"}" src="${esc(s)}" alt="Vista previa ${k + 1} de ${esc(w.titulo)}" loading="lazy">`).join("")}
      <div class="puntos">${fotos.map((_, k) => `<button type="button" class="${k ? "" : "on"}" aria-label="Ver captura ${k + 1}"></button>`).join("")}</div></div>`;
  if (fotos.length) return `<img src="${esc(fotos[0])}" alt="Vista previa de ${esc(w.titulo)}" loading="lazy">`;
  return `<div class="sin-imagen" aria-hidden="true">${svg(w.icono, 56)}</div>`;
}

// Las apps llevan barra de ventana (nombre y versión); las webs, barra de navegador con su dirección.
function barra(w) {
  const texto = w.tipo === "app" ? `${w.titulo.replace(/\s*\(App\)$/, "")} ${w.version || ""}` : w.url ? dominio(w.url) : "En preparación";
  return `<div class="barra${w.tipo === "app" ? " ventana" : ""}" aria-hidden="true"><i></i><i></i><i></i><span>${esc(texto.trim())}</span></div>`;
}

// Una línea solo cuando hay algo que decir.
function insignia(w) {
  if (!w.url && w.tipo !== "app") return `<span class="estado">En preparación</span>`;
  if (w.tipo === "repo") return `<span class="estado">Repositorio</span>`;
  if (w.tipo === "app") {
    const p = ["pc", "movil"].filter(x => (w.descargas || []).some(d => plataforma(d) === x));
    return `<span class="estado">${p.map(x => svg(x, 14)).join("")} ${p.length === 2 ? "Windows y Android" : "Solo " + NOMBRE[p[0] || "pc"]}</span>`;
  }
  if (/streamlit\.app/.test(w.url)) return `<span class="estado">Puede tardar 30 s en abrir</span>`;
  return "";
}

const enlaceDescarga = (d, clase, html) => `<a class="${clase}" href="${esc(d.archivo)}" download="${esc(d.archivo.split("/").pop())}">${html}</a>`;

// La acción principal: descargar (apps), abrir (webs) o ver en GitHub (repositorios).
function principal(w) {
  const bajar = (w.descargas || []).filter(d => plataforma(d));
  if (bajar.length) return bajar.map(d => enlaceDescarga(d, "boton prin",
    `${svg("descarga", 18)}<span>${bajar.length > 1 ? NOMBRE[plataforma(d)] : "Descargar para " + NOMBRE[plataforma(d)]}<small>${[w.version, megas(d.bytes)].filter(Boolean).join(" · ")}</small></span>`)).join("");
  if (!w.url) return "";
  const repo = esRepo(w);
  return `<a class="boton prin" href="${esc(w.abrir || w.url)}" target="_blank" rel="noopener">${repo ? svg("codigo", 18) + "Ver en GitHub" : "Abrir la web " + svg("flecha", 18)}</a>`;
}

function secundarias(w) {
  const b = (w.descargas || []).filter(d => !plataforma(d)).map(d => enlaceDescarga(d, "boton sec", `${svg("video", 16)}${esc(d.texto)}`));
  if (w.flujograma) b.push(`<button type="button" class="boton sec" data-panel="flujo" aria-expanded="false" aria-label="Esquema de cómo funciona ${esc(w.titulo)}">${svg("arbol", 16)}Esquema</button>`);
  if (w.guia) b.push(`<a class="boton sec" href="${esc(w.guia)}" target="_blank" rel="noopener" aria-label="Guía en PDF de ${esc(w.titulo)}">${svg("libro", 16)}Guía</a>`);
  if (w.tipo === "app" && esRepo(w)) b.push(`<a class="boton sec" href="${esc(w.url)}" target="_blank" rel="noopener" aria-label="Código de ${esc(w.titulo)} en GitHub">${svg("codigo", 16)}GitHub</a>`);
  return b.join("");
}

function panelFlujo(w) {
  return w.flujograma ? `<div class="panel-flujo" hidden><div class="visor-mini"><img alt="Flujograma de ${esc(w.titulo)}" data-src="${esc(w.flujograma)}"></div>
      <div class="barra-flujo"><span>Desplázate para ver el resto</span><button type="button" data-ampliar="${esc(w.flujograma)}" data-titulo="${esc(w.titulo)}">Ampliar ${svg("ampliar", 16)}</button></div></div>` : "";
}

function tarjeta(w, i) {
  const a = document.createElement("article");
  a.className = "tarjeta " + (w.url || w.tipo === "app" ? "viva" : "apagada");
  a.style.animationDelay = `${i * 80}ms`;
  a.style.viewTransitionName = "t-" + w.id;                      // para que, al ampliar una, las demás se deslicen a su sitio
  const icono = w.icono_img ? `<img src="${esc(w.icono_img)}" alt="" width="36" height="36" loading="lazy">` : svg(w.icono, 22);
  a.innerHTML = `<div class="marco" role="button" tabindex="0" aria-expanded="false" aria-label="Ampliar la vista previa de ${esc(w.titulo)}">
      ${barra(w)}
      <div class="vista">${miniatura(w)}</div>
    </div>
    <div class="cuerpo">
      <div class="titulo"><span class="ico${w.icono_img ? " propio" : ""}" aria-hidden="true">${icono}</span><h3>${esc(w.titulo)}</h3></div>
      <p class="resumen">${esc(w.resumen || "")}</p>
      <div class="insignia">${insignia(w)}</div>
      <div class="acciones">
        <div class="principales">${principal(w)}</div>
        <div class="secundarias">${secundarias(w)}</div>
      </div>
      ${panelFlujo(w)}
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

// Ampliar una tarjeta: clic en su marco. Pasa a ser la primera de su sección y ocupa toda la fila; las demás se recolocan debajo.
// Otro clic en el marco (o Escape) la devuelve a su sitio.
function conTransicion(f) {
  if (document.startViewTransition && !matchMedia("(prefers-reduced-motion: reduce)").matches) return document.startViewTransition(f).finished;
  f(); return Promise.resolve();
}
function encoger(t) {
  t.classList.remove("ampliada");
  t.querySelector(".marco").setAttribute("aria-expanded", "false");
  const li = t.parentElement;
  if (li._marca) { li._marca.replaceWith(li); li._marca = null; }
}
function ampliar(t) {
  const abierta = rejilla.querySelector(".tarjeta.ampliada");
  const nueva = abierta !== t;
  conTransicion(() => {
    if (abierta) encoger(abierta);
    if (!nueva) return;
    const li = t.parentElement;
    li._marca = document.createComment("");
    li.replaceWith(li._marca);
    li._marca.parentElement.prepend(li);
    t.classList.add("ampliada");
    t.querySelector(".marco").setAttribute("aria-expanded", "true");
  }).then(() => { if (nueva) t.scrollIntoView({ behavior: "smooth", block: "nearest" }); });
}
document.addEventListener("click", e => {
  const m = e.target.closest(".marco");
  if (!m || e.target.closest(".puntos button")) return;
  ampliar(m.closest(".tarjeta"));
});
document.addEventListener("keydown", e => {
  if (e.key === "Escape") { const t = rejilla.querySelector(".tarjeta.ampliada"); if (t) ampliar(t); return; }
  const m = e.target.closest && e.target.closest(".marco");
  if (m && (e.key === "Enter" || e.key === " ")) { e.preventDefault(); ampliar(m.closest(".tarjeta")); }
});

// Secciones en el orden en que salen. La sección y el orden de cada tarjeta vienen de webs.json («seccion», «orden»);
// una sección que no esté aquí sale al final con su id como título.
const SECCIONES = {
  webs: { titulo: "Webs interactivas" },
  apps: { titulo: "Apps (Windows y Android)",
          nota: "Windows puede avisar al abrir un instalador porque no está firmado: pulsa «Más información» y luego «Ejecutar de todas formas»." },
  github: { titulo: "Proyectos en GitHub" },
};

function seccion(id, lista) {
  const s = document.createElement("section"), info = SECCIONES[id] || { titulo: id };
  s.className = "grupo";
  s.id = id;
  s.setAttribute("aria-labelledby", "t-" + id);
  s.innerHTML = `<h2 class="seccion" id="t-${esc(id)}">${esc(info.titulo)}</h2>${info.nota ? `<p class="nota">${esc(info.nota)}</p>` : ""}<ul class="rejilla"></ul>`;
  s.querySelector("ul").append(...lista.map((w, i) => { const li = document.createElement("li"); li.append(tarjeta(w, i)); return li; }));
  return s;
}

function pintar() {
  const q = buscar.value.trim().toLowerCase();
  const ver = webs.filter(w => !q || [w.titulo, w.descripcion].join(" ").toLowerCase().includes(q));
  const grupos = {};
  ver.forEach(w => (grupos[w.seccion] ||= []).push(w));
  const ids = [...new Set([...Object.keys(SECCIONES), ...Object.keys(grupos)])].filter(id => grupos[id]);
  rejilla.replaceChildren(...ids.map(id => seccion(id, grupos[id])));
  vacio.hidden = ver.length > 0;
  contador.textContent = q ? `${ver.length} ${ver.length === 1 ? "resultado" : "resultados"}` : `${webs.length} proyectos`;
}

fetch("webs.json").then(r => r.json()).then(d => { webs = d.sort((a, b) => (a.orden ?? 0) - (b.orden ?? 0)); pintar(); pintarApps(); })
  .catch(() => { rejilla.textContent = "No se han podido cargar las webs."; });
buscar.addEventListener("input", pintar);

// tema claro u oscuro: el del sistema, y se recuerda lo que se elija
const raiz = document.documentElement;
const guardado = (() => { try { return localStorage.getItem("tema"); } catch (e) { return null; } })();
function ponerTema(t) {          // la barra del navegador del móvil (theme-color) sigue al tema elegido
  raiz.dataset.tema = t;
  document.querySelectorAll('meta[name="theme-color"]').forEach(m => { m.content = t === "oscuro" ? "#0e1320" : "#f4f6fb"; });
}
if (guardado) ponerTema(guardado);
document.getElementById("tema").addEventListener("click", () => {
  const oscuro = raiz.dataset.tema ? raiz.dataset.tema === "oscuro" : matchMedia("(prefers-color-scheme: dark)").matches;
  ponerTema(oscuro ? "claro" : "oscuro");
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

// ---- flujogramas de las apps de escritorio: se despliegan en la tarjeta y se amplían en un visor con zoom y arrastre
const visor = document.getElementById("visor"), lienzo = document.getElementById("visor-lienzo"), vimg = document.getElementById("visor-img");
let zk = 1, zx = 0, zy = 0, zmin = 1, volver = null;
const colocar = () => { vimg.style.transform = `translate(${zx}px,${zy}px) scale(${zk})`; };
function ajustar() {
  const W = lienzo.clientWidth, H = lienzo.clientHeight, w = vimg.naturalWidth || 1240, h = vimg.naturalHeight || 880;
  vimg.style.width = w + "px"; vimg.style.height = h + "px";
  zk = zmin = Math.min(W / w, H / h) * .98; zx = (W - w * zk) / 2; zy = (H - h * zk) / 2; colocar();
}
function zoom(f, cx = lienzo.clientWidth / 2, cy = lienzo.clientHeight / 2) {
  const n = Math.min(6, Math.max(zmin * .5, zk * f)); f = n / zk;
  zx = cx - (cx - zx) * f; zy = cy - (cy - zy) * f; zk = n; colocar();
}
function abrirVisor(url, titulo, opener) {
  volver = opener;
  document.getElementById("visor-titulo").textContent = "Flujograma · " + titulo;
  document.getElementById("visor-abrir").href = url;
  vimg.alt = "Flujograma de " + titulo;
  visor.classList.add("on"); document.body.style.overflow = "hidden";
  if (vimg.getAttribute("src") === url && vimg.complete) ajustar();
  else { vimg.onload = ajustar; vimg.src = url; }
  document.getElementById("visor-cerrar").focus();
}
function cerrarVisor() {
  if (!visor.classList.contains("on")) return;
  visor.classList.remove("on"); document.body.style.overflow = "";
  if (volver) volver.focus();
}
document.addEventListener("click", e => {
  const b = e.target.closest("[data-panel]");       // flujograma o guía rápida: en cada tarjeta se ve un solo panel a la vez
  if (b) {
    const cuerpo = b.closest(".cuerpo"), abre = b.getAttribute("aria-expanded") !== "true";
    cuerpo.querySelectorAll("[data-panel]").forEach(x => x.setAttribute("aria-expanded", "false"));
    cuerpo.querySelectorAll(".panel-flujo").forEach(p => { p.hidden = true; });
    if (abre) {
      b.setAttribute("aria-expanded", "true");
      const panel = cuerpo.querySelector(".panel-" + b.dataset.panel); panel.hidden = false;
      const im = panel.querySelector("img[data-src]"); if (im && !im.getAttribute("src")) im.src = im.dataset.src;       // el SVG se descarga al desplegar por primera vez
    }
  }
  const a = e.target.closest("[data-ampliar]");
  if (a) abrirVisor(a.dataset.ampliar, a.dataset.titulo, a);
});
document.getElementById("visor-cerrar").addEventListener("click", cerrarVisor);
document.getElementById("visor-mas").addEventListener("click", () => zoom(1.25));
document.getElementById("visor-menos").addEventListener("click", () => zoom(.8));
document.getElementById("visor-ajustar").addEventListener("click", ajustar);
addEventListener("keydown", e => { if (e.key === "Escape") cerrarVisor(); });
addEventListener("resize", () => visor.classList.contains("on") && ajustar());
lienzo.addEventListener("wheel", e => { e.preventDefault(); const r = lienzo.getBoundingClientRect(); zoom(e.deltaY < 0 ? 1.12 : 1 / 1.12, e.clientX - r.left, e.clientY - r.top); }, { passive: false });
let arrastre = null;
lienzo.addEventListener("pointerdown", e => { arrastre = { x: e.clientX - zx, y: e.clientY - zy }; lienzo.setPointerCapture(e.pointerId); lienzo.classList.add("arrastra"); });
lienzo.addEventListener("pointermove", e => { if (arrastre) { zx = e.clientX - arrastre.x; zy = e.clientY - arrastre.y; colocar(); } });
lienzo.addEventListener("pointerup", () => { arrastre = null; lienzo.classList.remove("arrastra"); });
