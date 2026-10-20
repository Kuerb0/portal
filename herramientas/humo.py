"""Prueba de humo del portal con Edge sin ventana.

Sirve la carpeta en local, carga la página en varias vistas (ancho, tema, movimiento reducido), guarda una captura
de página entera de cada una en herramientas/capturas/<etiqueta>/ y comprueba lo básico:
sin desbordamiento horizontal, 12 tarjetas, ningún botón partido o cortado, filas alineadas, la sección «Instálame» con borde y el visor de flujogramas oculto.

    python herramientas/humo.py [etiqueta]        # etiqueta por defecto: «ultima»

Sale con código 1 si alguna comprobación falla. Hace falta Edge y websocket-client (los mismos que guias/construir.py).
"""
import base64
import socket
import subprocess
import sys
import time
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "guias"))
from construir import Edge  # noqa: E402

TARJETAS = 12
VISTAS = [  # nombre, ancho, alto, tema, movimiento reducido, móvil (táctil)
    ("1400-oscuro", 1400, 900, "dark", False, False),
    ("1400-claro", 1400, 900, "light", False, False),
    ("768-claro", 768, 1024, "light", False, True),
    ("375-oscuro", 375, 812, "dark", False, True),
    ("1400-reducido", 1400, 900, "light", True, False),
]

PREPARAR = """(() => {
  const s = document.createElement('style');
  s.textContent = '*,*::before,*::after{animation:none!important;transition:none!important}';
  document.head.append(s);
  document.querySelectorAll('img[loading=lazy]').forEach(i => i.loading = 'eager');
})()"""

COMPROBAR = """(() => {
  const ins = document.querySelector('.instalar'), vis = document.querySelector('.visor-modal');
  return {
    desborde: document.documentElement.scrollWidth - innerWidth,
    tarjetas: document.querySelectorAll('.tarjeta').length,
    instalar_borde: ins ? (ins.hidden || parseFloat(getComputedStyle(ins).borderTopWidth) > 0) : true,
    visor_oculto: !vis || getComputedStyle(vis).display === 'none',
    alto: document.documentElement.scrollHeight,
    botones_rotos: [...document.querySelectorAll('.boton')].filter(b => b.scrollWidth > b.clientWidth + 1 ||
        [...b.querySelectorAll('*')].concat(b).some(n => [...n.childNodes].some(t => {    // un trozo de texto que ocupa más de una línea
          if (t.nodeType !== 3 || !t.textContent.trim()) return false;
          const r = document.createRange(); r.selectNodeContents(t);
          return new Set([...r.getClientRects()].map(x => Math.round(x.top))).size > 1;
        })))
      .map(b => b.closest('.tarjeta').querySelector('h3').textContent + ': ' + b.textContent.trim()),
    desalineadas: (() => {          // en cada fila, título, resumen, insignia y acciones a la misma altura
      const filas = {};
      document.querySelectorAll('.tarjeta:not(.ampliada)').forEach(t => (filas[Math.round(t.offsetTop)] ||= []).push(t));
      return Object.values(filas).filter(f => f.length > 1 && ['h3', '.resumen', '.insignia', '.acciones'].some(sel =>
        new Set(f.map(t => (e => e ? Math.round(e.getBoundingClientRect().top) : 'falta')(t.querySelector(sel)))).size > 1))
        .map(f => f.map(t => t.querySelector('h3').textContent).join(' / '));
    })(),
  };
})()"""


def puerto_libre():
    with socket.socket() as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


def valor(edge, js):
    return edge.cmd("Runtime.evaluate", expression=js, returnByValue=True)["result"].get("value")


def esperar(edge, js, veces=60):
    for _ in range(veces):
        if valor(edge, js):
            return True
        time.sleep(0.25)
    return False


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    etiqueta = sys.argv[1] if len(sys.argv) > 1 else "ultima"
    salida = RAIZ / "herramientas" / "capturas" / etiqueta
    salida.mkdir(parents=True, exist_ok=True)
    puerto = puerto_libre()
    servidor = subprocess.Popen([sys.executable, "-m", "http.server", str(puerto), "--bind", "127.0.0.1"], cwd=RAIZ,
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    edge = Edge()
    fallos = []
    try:
        edge.cmd("Page.enable")
        for nombre, ancho, alto, tema, reducido, movil in VISTAS:
            edge.cmd("Emulation.setDeviceMetricsOverride", width=ancho, height=alto, deviceScaleFactor=1, mobile=movil)
            edge.cmd("Emulation.setTouchEmulationEnabled", enabled=movil, maxTouchPoints=5 if movil else 1)
            edge.cmd("Emulation.setEmulatedMedia", features=[
                {"name": "prefers-color-scheme", "value": tema},
                {"name": "prefers-reduced-motion", "value": "reduce" if reducido else "no-preference"}])
            edge.cmd("Page.navigate", url=f"http://127.0.0.1:{puerto}/")
            time.sleep(0.3)
            esperar(edge, "document.readyState === 'complete' && document.querySelectorAll('.tarjeta').length > 0")
            valor(edge, PREPARAR)
            esperar(edge, "[...document.images].every(i => i.complete)")
            time.sleep(0.4)
            r = valor(edge, COMPROBAR)
            mal = [k for k, ok in [("desborde horizontal", r["desborde"] <= 0), (f"{r['tarjetas']} tarjetas", r["tarjetas"] == TARJETAS),
                                   ("«Instálame» sin borde", r["instalar_borde"]), ("visor visible", r["visor_oculto"]),
                                   (f"botones partidos o cortados: {r['botones_rotos']}", not r["botones_rotos"]),
                                   (f"filas desalineadas: {r['desalineadas']}", not r["desalineadas"])] if not ok]
            fallos += [f"{nombre}: {m}" for m in mal]
            edge.cmd("Emulation.setDeviceMetricsOverride", width=ancho, height=r["alto"], deviceScaleFactor=1, mobile=movil)
            time.sleep(0.3)
            png = edge.cmd("Page.captureScreenshot", format="png")["data"]
            (salida / f"{nombre}.png").write_bytes(base64.b64decode(png))
            # el botón de tema cambia los colores (y se deja como estaba para la vista siguiente)
            if not valor(edge, """(() => { const bg = () => getComputedStyle(document.body).backgroundColor, antes = bg();
                document.getElementById('tema').click(); const cambia = bg() !== antes;
                delete document.documentElement.dataset.tema; localStorage.removeItem('tema'); return cambia; })()"""):
                mal.append("el botón de tema no cambia los colores")
                fallos.append(f"{nombre}: el botón de tema no cambia los colores")
            print(f"{nombre}: {'bien' if not mal else ', '.join(mal)}")
    finally:
        edge.cerrar()
        servidor.terminate()
    print(f"Capturas en {salida}")
    if fallos:
        print("FALLA:\n  " + "\n  ".join(fallos))
        sys.exit(1)


if __name__ == "__main__":
    main()
