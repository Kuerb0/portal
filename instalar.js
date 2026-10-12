// Instalación como app. Lo usan el portal y los envoltorios (vuelos/, estadistica/, finanzas/) y Comidas.
//  - window.Instalar: { instalada, ios, puede(), instalar() }. Chrome, Edge y Android avisan con «beforeinstallprompt» y se
//    puede lanzar el diálogo desde un botón; Safari de iPhone no tiene esa API: allí solo se puede explicar a mano.
//  - Si el <script> lleva data-aviso="Nombre", sale un aviso abajo («Instala Nombre…») en móviles donde aún no está instalada.
(() => {
  const standalone = matchMedia("(display-mode: standalone)").matches || navigator.standalone === true;
  const ios = /iPad|iPhone|iPod/.test(navigator.userAgent) || (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1);
  let evento = null;
  const cambio = () => dispatchEvent(new CustomEvent("instalar-cambio"));

  const API = window.Instalar = {
    instalada: standalone, ios,
    puede: () => !!evento,
    async instalar() {
      if (!evento) return false;
      evento.prompt();
      const r = await evento.userChoice;
      evento = null;
      cambio();
      return r.outcome === "accepted";
    },
  };
  addEventListener("beforeinstallprompt", e => { e.preventDefault(); evento = e; cambio(); });
  addEventListener("appinstalled", () => { API.instalada = true; evento = null; cambio(); });

  // ---- aviso inferior (opcional)
  const yo = document.currentScript, nombre = yo && yo.dataset.aviso;
  if (!nombre || standalone || !matchMedia("(pointer: coarse)").matches) return;
  const clave = "instalar-no:" + location.pathname;
  try { if (localStorage.getItem(clave)) return; } catch (e) { /* sin almacenamiento: se enseña igual */ }

  let barra = null;
  function pintar() {
    if (!evento && !ios) { barra?.remove(); barra = null; return; }          // otro navegador: no hay nada que ofrecer
    if (!barra) {
      const css = document.createElement("style");
      css.textContent = ".ins-aviso{position:fixed;left:.7rem;right:.7rem;bottom:calc(.7rem + env(safe-area-inset-bottom));z-index:20;display:flex;" +
        "align-items:center;gap:.7rem;padding:.7rem .8rem;border-radius:14px;background:#16203a;color:#e8ecf5;border:1px solid #2c3a5e;" +
        "box-shadow:0 8px 24px rgba(0,0,0,.4);font:14px/1.35 system-ui,sans-serif}.ins-aviso p{margin:0;flex:1}" +
        ".ins-aviso button{border:0;border-radius:9px;padding:.55rem .9rem;font:600 14px system-ui,sans-serif;cursor:pointer}" +
        ".ins-si{background:#4d8ff7;color:#fff}.ins-no{background:transparent;color:#9aa6bf;font-size:20px!important;padding:.2rem .5rem!important}" +
        ".ins-aviso button:focus-visible{outline:3px solid #fff;outline-offset:2px}";
      document.head.append(css);
      barra = document.createElement("div");
      barra.className = "ins-aviso";
      barra.setAttribute("role", "region");
      barra.setAttribute("aria-label", "Instalar la app");
      document.body.append(barra);
    }
    barra.replaceChildren();
    const p = document.createElement("p");
    p.textContent = evento ? `Instala «${nombre}» en tu móvil.` : `Para instalar «${nombre}»: toca Compartir y elige «Añadir a pantalla de inicio».`;
    barra.append(p);
    if (evento) {
      const si = Object.assign(document.createElement("button"), { type: "button", className: "ins-si", textContent: "Instalar" });
      si.onclick = () => API.instalar();
      barra.append(si);
    }
    const no = Object.assign(document.createElement("button"), { type: "button", className: "ins-no", textContent: "×", title: "Ahora no" });
    no.setAttribute("aria-label", "Cerrar el aviso");
    no.onclick = () => { barra.remove(); barra = null; try { localStorage.setItem(clave, "1"); } catch (e) { /* da igual */ } };
    barra.append(no);
  }
  addEventListener("instalar-cambio", pintar);
  const empezar = () => setTimeout(pintar, 1500);
  if (document.readyState === "loading") addEventListener("DOMContentLoaded", empezar); else empezar();
})();
