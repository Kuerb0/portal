// Fondo animado: una red de puntos que derivan despacio y se unen con líneas cuando se acercan; el puntero también se une a
// los que tiene cerca. Usa el color de acento del tema (--acento) y se adapta si se cambia entre claro y oscuro.
// Con «reducir movimiento» en el sistema se pinta una sola imagen quieta.
(() => {
  const lienzo = document.getElementById("fondo");
  if (!lienzo || !lienzo.getContext) return;
  const ctx = lienzo.getContext("2d");
  const quieto = matchMedia("(prefers-reduced-motion: reduce)");
  const DIST = 140, DIST_PUNTERO = 190;
  let ancho = 0, alto = 0, puntos = [], color = [123, 155, 240], oscuro = true, cuadro = 0;
  const puntero = { x: -1e4, y: -1e4 };

  function leerTema() {
    const css = getComputedStyle(document.documentElement);
    const hex = css.getPropertyValue("--acento").trim().replace("#", "");
    if (hex.length === 6) color = [0, 2, 4].map(i => parseInt(hex.slice(i, i + 2), 16));
    oscuro = css.getPropertyValue("--fondo").trim().toLowerCase() < "#80";   // los fondos oscuros empiezan por 0 o 1
  }

  function ajustar() {
    const dpr = Math.min(devicePixelRatio || 1, 2);
    ancho = innerWidth; alto = innerHeight;
    lienzo.width = ancho * dpr; lienzo.height = alto * dpr;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    const n = Math.min(90, Math.round(ancho * alto / 15000));
    while (puntos.length < n) puntos.push({ x: Math.random() * ancho, y: Math.random() * alto, vx: (Math.random() - .5) * .3, vy: (Math.random() - .5) * .3, r: 1 + Math.random() * 1.4 });
    puntos.length = n;
  }

  function pintar() {
    const [r, g, b] = color, fuerza = oscuro ? 1 : .7;
    ctx.clearRect(0, 0, ancho, alto);
    for (const p of puntos) {
      if (!quieto.matches) {
        p.x += p.vx; p.y += p.vy;
        if (p.x < -20) p.x = ancho + 20; else if (p.x > ancho + 20) p.x = -20;
        if (p.y < -20) p.y = alto + 20; else if (p.y > alto + 20) p.y = -20;
      }
    }
    ctx.lineWidth = 1;
    for (let i = 0; i < puntos.length; i++) {
      const a = puntos[i];
      for (let j = i + 1; j < puntos.length; j++) {
        const c = puntos[j], d = Math.hypot(a.x - c.x, a.y - c.y);
        if (d < DIST) {
          ctx.strokeStyle = `rgba(${r},${g},${b},${(1 - d / DIST) * .32 * fuerza})`;
          ctx.beginPath(); ctx.moveTo(a.x, a.y); ctx.lineTo(c.x, c.y); ctx.stroke();
        }
      }
      const dp = Math.hypot(a.x - puntero.x, a.y - puntero.y);
      if (dp < DIST_PUNTERO) {
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
    if (!quieto.matches) requestAnimationFrame(vuelta);
  }

  addEventListener("pointermove", e => { puntero.x = e.clientX; puntero.y = e.clientY; }, { passive: true });
  addEventListener("pointerleave", () => { puntero.x = puntero.y = -1e4; });
  let espera;
  addEventListener("resize", () => { clearTimeout(espera); espera = setTimeout(() => { ajustar(); pintar(); }, 150); });
  quieto.addEventListener?.("change", () => { if (!quieto.matches) vuelta(); else pintar(); });
  document.getElementById("tema").addEventListener("click", () => setTimeout(() => { leerTema(); pintar(); }, 0));
  leerTema(); ajustar(); vuelta();
})();
