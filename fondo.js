// Fondo animado: una red de puntos que derivan despacio y se unen con líneas cuando se acercan; el puntero también se une a
// los que tiene cerca. Usa el color de acento del tema (--acento) y se adapta si se cambia entre claro y oscuro.
// Con «reducir movimiento» en el sistema se pinta una sola imagen quieta.
(() => {
  const lienzo = document.getElementById("fondo");
  if (!lienzo || !lienzo.getContext) return;
  const ctx = lienzo.getContext("2d");
  const quieto = matchMedia("(prefers-reduced-motion: reduce)"), pequena = matchMedia("(max-width: 600px)");
  const ahorro = !!(navigator.connection && navigator.connection.saveData);
  const parado = () => quieto.matches || pequena.matches || ahorro;        // en esos casos se pinta una sola imagen quieta
  let andando = false;
  const DIST = 140, DIST_PUNTERO = 190, DIST2 = DIST * DIST, DIST_PUNTERO2 = DIST_PUNTERO * DIST_PUNTERO;
  let ancho = 0, alto = 0, puntos = [], color = [123, 155, 240], oscuro = true, cuadro = 0;
  const puntero = { x: -1e4, y: -1e4 };

  function leerTema() {          // los colores se leen ya resueltos (las variables usan light-dark())
    lienzo.style.color = "var(--acento)";
    color = getComputedStyle(lienzo).color.match(/[\d.]+/g).slice(0, 3).map(Number);
    const [r, g, b] = getComputedStyle(document.body).backgroundColor.match(/[\d.]+/g).map(Number);
    oscuro = r + g + b < 384;
  }

  function ajustar() {
    const dpr = Math.min(devicePixelRatio || 1, 2);
    ancho = innerWidth; alto = innerHeight;
    lienzo.width = ancho * dpr; lienzo.height = alto * dpr;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    const n = Math.min(60, Math.round(ancho * alto / 18000));
    while (puntos.length < n) puntos.push({ x: Math.random() * ancho, y: Math.random() * alto, vx: (Math.random() - .5) * .3, vy: (Math.random() - .5) * .3, r: 1 + Math.random() * 1.4 });
    puntos.length = n;
  }

  function pintar() {
    const [r, g, b] = color, fuerza = oscuro ? 1 : .7;
    ctx.clearRect(0, 0, ancho, alto);
    for (const p of puntos) {
      if (!parado()) {
        p.x += p.vx; p.y += p.vy;
        if (p.x < -20) p.x = ancho + 20; else if (p.x > ancho + 20) p.x = -20;
        if (p.y < -20) p.y = alto + 20; else if (p.y > alto + 20) p.y = -20;
      }
    }
    ctx.lineWidth = 1;
    for (let i = 0; i < puntos.length; i++) {
      const a = puntos[i];
      for (let j = i + 1; j < puntos.length; j++) {
        const c = puntos[j], dx = a.x - c.x, dy = a.y - c.y, d2 = dx * dx + dy * dy;
        if (d2 < DIST2) {                       // la raíz solo se calcula para los que están cerca
          const d = Math.sqrt(d2);
          ctx.strokeStyle = `rgba(${r},${g},${b},${(1 - d / DIST) * .32 * fuerza})`;
          ctx.beginPath(); ctx.moveTo(a.x, a.y); ctx.lineTo(c.x, c.y); ctx.stroke();
        }
      }
      const px = a.x - puntero.x, py = a.y - puntero.y, dp2 = px * px + py * py;
      if (dp2 < DIST_PUNTERO2) {
        const dp = Math.sqrt(dp2);
        ctx.strokeStyle = `rgba(${r},${g},${b},${(1 - dp / DIST_PUNTERO) * .55 * fuerza})`;
        ctx.beginPath(); ctx.moveTo(a.x, a.y); ctx.lineTo(puntero.x, puntero.y); ctx.stroke();
      }
      ctx.fillStyle = `rgba(${r},${g},${b},${.55 * fuerza})`;
      ctx.beginPath(); ctx.arc(a.x, a.y, a.r, 0, 6.2832); ctx.fill();
    }
  }

  function vuelta() {
    if (!(cuadro++ % 60)) leerTema();            // por si se cambia de tema
    pintar();
    andando = !parado() && !document.hidden;     // con la pestaña oculta no se pinta
    if (andando) requestAnimationFrame(vuelta);
  }
  const seguir = () => { if (!andando) vuelta(); };

  addEventListener("pointermove", e => { puntero.x = e.clientX; puntero.y = e.clientY; }, { passive: true });
  addEventListener("pointerleave", () => { puntero.x = puntero.y = -1e4; });
  let espera;
  addEventListener("resize", () => { clearTimeout(espera); espera = setTimeout(() => { ajustar(); pintar(); }, 150); });
  quieto.addEventListener?.("change", seguir);
  pequena.addEventListener?.("change", seguir);
  document.addEventListener("visibilitychange", () => { if (!document.hidden) seguir(); });
  document.getElementById("tema").addEventListener("click", () => setTimeout(() => { leerTema(); pintar(); }, 0));
  leerTema(); ajustar(); vuelta();
})();
