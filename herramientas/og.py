"""Hace img/og.jpg (1200x630), la imagen que sale al compartir el portal en redes y mensajería.

    python herramientas/og.py

Monta una página con el cuervo, el título y cuatro capturas, y la fotografía con Edge sin ventana (como guias/construir.py).
Volver a hacerla si cambian las capturas o el número de proyectos.
"""
import base64
import json
import sys
import tempfile
import time
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "guias"))
from construir import Edge  # noqa: E402

CAPTURAS = ["img/galeria/viajes-app-1.jpg", "img/galeria/estadistica-app-1.jpg", "img/calendario.jpg", "img/post-it.jpg"]


def main():
    n = len(json.loads((RAIZ / "webs.json").read_text(encoding="utf-8")))
    url = lambda r: (RAIZ / r).as_uri()
    html = f"""<!doctype html><meta charset="utf-8"><style>
  body{{margin:0;width:1200px;height:630px;overflow:hidden;font-family:"Segoe UI",system-ui,sans-serif;color:#e8ecf5;
       background:radial-gradient(60% 70% at 15% 20%,rgba(123,155,240,.22),transparent 70%),#0e1320;display:flex;align-items:center;gap:48px;padding:0 56px;box-sizing:border-box}}
  .texto{{flex:0 0 470px}}
  img.cuervo{{width:120px;height:120px;border-radius:50%;border:4px solid #7b9bf0}}
  h1{{margin:22px 0 10px;font-size:64px;letter-spacing:-1px;line-height:1}}
  p{{margin:0;font-size:28px;line-height:1.35;color:#c3cbe0}}
  .n{{margin-top:22px;font-size:22px;color:#7b9bf0;font-weight:700}}
  .capturas{{flex:1;display:grid;grid-template-columns:1fr 1fr;gap:16px}}
  .capturas img{{width:100%;aspect-ratio:16/9;object-fit:cover;object-position:top left;border-radius:12px;border:1px solid #34405e;box-shadow:0 10px 30px rgba(0,0,0,.45)}}
</style>
<div class="texto"><img class="cuervo" src="{url('icon-512.png')}" alt=""><h1>Mario</h1>
<p>Webs y apps gratuitas para viajar, ahorrar y aprender estadística</p><p class="n">{n} proyectos · Windows, Android y web</p></div>
<div class="capturas">{"".join(f'<img src="{url(c)}" alt="">' for c in CAPTURAS)}</div>"""
    tmp = Path(tempfile.mkdtemp()) / "og.html"
    tmp.write_text(html, encoding="utf-8")
    edge = Edge()
    try:
        edge.cmd("Page.enable")
        edge.cmd("Emulation.setDeviceMetricsOverride", width=1200, height=630, deviceScaleFactor=1, mobile=False)
        edge.cmd("Page.navigate", url=tmp.as_uri())
        time.sleep(1.5)
        datos = edge.cmd("Page.captureScreenshot", format="jpeg", quality=88)["data"]
        (RAIZ / "img" / "og.jpg").write_bytes(base64.b64decode(datos))
    finally:
        edge.cerrar()
    print("img/og.jpg:", (RAIZ / "img" / "og.jpg").stat().st_size // 1024, "KB")


if __name__ == "__main__":
    main()
