"""Genera las guías en PDF del portal: guias/src/<id>.md -> guias/<id>.pdf (portada, índice con números de página y el contenido).

Uso: python guias/construir.py [id ...]        (sin ids: todas las que haya en guias/src/)
     python guias/construir.py --indice      (solo rehace guias/index.html, la lista de guías)

El Markdown empieza con unas líneas «clave: valor» (titulo, subtitulo, version, icono, color) y una línea en blanco.
Las imágenes se escriben ![pie](img/galeria/x.jpg) con la ruta relativa a la raíz del portal.
El PDF se hace con Edge sin ventana (protocolo de depuración) y los números del índice se calculan buscando cada título en el PDF.
"""
import base64
import html
import json
import re
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.request
from pathlib import Path

import fitz          # PyMuPDF: buscar en qué página cae cada título
import markdown
import websocket

RAIZ = Path(__file__).resolve().parent.parent
SRC = RAIZ / "guias" / "src"
EDGE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
import os
PUERTO = 9300 + os.getpid() % 600          # uno distinto en cada ejecución: un Edge que se quedó abierto no estorba

CSS = """
@page { size: A4; margin: 20mm 18mm 20mm 18mm; }
* { box-sizing: border-box; }
html { font-family: "Segoe UI", system-ui, sans-serif; font-size: 10.5pt; line-height: 1.55; color: #1c2230; }
body { margin: 0; }
h1, h2, h3, h4 { font-weight: 650; line-height: 1.25; color: #121826; break-after: avoid; }
h2 { font-size: 17pt; margin: 0 0 .5em; padding-bottom: .25em; border-bottom: 2px solid var(--acento); break-before: page; }
h2.sin-salto { break-before: auto; margin-top: 1.6em; }
h3 { font-size: 12.5pt; margin: 1.5em 0 .4em; color: var(--acento-oscuro); }
h4 { font-size: 10.8pt; margin: 1.1em 0 .3em; }
p { margin: .5em 0; orphans: 3; widows: 3; }
ul, ol { margin: .4em 0 .6em; padding-left: 1.4em; }
li { margin: .18em 0; }
a { color: var(--acento-oscuro); text-decoration: none; }
code { font-family: Consolas, "Cascadia Mono", monospace; font-size: 9.2pt; background: #eef1f6; padding: .05em .35em; border-radius: 4px; }
pre { background: #121826; color: #e6e9f0; padding: .8em 1em; border-radius: 8px; font-size: 8.8pt; line-height: 1.45; overflow-wrap: anywhere; white-space: pre-wrap; break-inside: avoid; }
pre code { background: none; color: inherit; padding: 0; font-size: inherit; }
table { border-collapse: collapse; width: 100%; margin: .8em 0; font-size: 9.6pt; break-inside: auto; }
th { background: var(--acento); color: #fff; text-align: left; padding: .4em .6em; font-weight: 600; }
td { padding: .38em .6em; border-bottom: 1px solid #dde2ec; vertical-align: top; }
tr { break-inside: avoid; }
tbody tr:nth-child(even) td { background: #f5f7fb; }
blockquote { margin: .8em 0; padding: .6em 1em; border-left: 4px solid var(--acento); background: color-mix(in srgb, var(--acento) 9%, white); border-radius: 0 8px 8px 0; break-inside: avoid; }
blockquote p { margin: .25em 0; }
figure { margin: 1em 0; break-inside: avoid; text-align: center; }
figure img { max-width: 100%; max-height: 105mm; border-radius: 8px; border: 1px solid #dde2ec; }
figcaption { font-size: 8.8pt; color: #5a6477; margin-top: .35em; }
.portada { min-height: 245mm; display: flex; flex-direction: column; justify-content: center; align-items: flex-start; gap: 6mm; break-after: page; }
.portada .banda { width: 100%; height: 5mm; background: var(--acento); border-radius: 3mm; }
.portada img.ico { width: 34mm; height: 34mm; border-radius: 8mm; }
.portada h1 { font-size: 40pt; margin: 0; letter-spacing: -.02em; }
.portada .sub { font-size: 15pt; color: #4a5468; max-width: 150mm; }
.portada .meta { margin-top: 12mm; font-size: 10pt; color: #5a6477; }
.indice { break-after: page; }
.indice h2 { break-before: auto; }
.indice ol { list-style: none; padding: 0; margin: 0; }
.indice li { display: flex; align-items: baseline; gap: .4em; margin: .1em 0; font-size: 9.6pt; line-height: 1.35; }
.indice li.n2 { margin-top: .5em; font-weight: 650; font-size: 10.2pt; }
.indice li.n3 { padding-left: 1.6em; font-size: 9pt; color: #3a4458; }
.indice li .p { flex: none; font-variant-numeric: tabular-nums; color: #5a6477; }
.indice li .pt { flex: 1; border-bottom: 1px dotted #b7bfce; transform: translateY(-.25em); }
.indice li a { color: inherit; }
"""


def leer(id_):
    texto = (SRC / f"{id_}.md").read_text(encoding="utf-8")
    cab, _, cuerpo = texto.partition("\n\n")
    meta = {}
    for linea in cab.splitlines():
        k, _, v = linea.partition(":")
        meta[k.strip()] = v.strip()
    return meta, cuerpo


def a_html(cuerpo):
    md = markdown.Markdown(extensions=["tables", "fenced_code", "sane_lists", "attr_list"])
    h = md.convert(cuerpo)
    # una imagen sola en su línea -> figura con pie
    def figura(m):
        alt, src = html.unescape(m.group(1)), m.group(2)
        ruta = src if src.startswith("http") else (RAIZ / src).as_uri()
        return f'<figure><img src="{ruta}" alt="">{"<figcaption>" + html.escape(alt) + "</figcaption>" if alt else ""}</figure>'
    h = re.sub(r'<p><img alt="([^"]*)" src="([^"]+)" ?/?></p>', figura, h)
    return h


def titulos(h):
    """(nivel, texto, id) de cada h2/h3, y el HTML con los id puestos."""
    lista = []

    def poner(m):
        n, txt = int(m.group(1)), m.group(2)
        ident = f"t{len(lista)}"
        lista.append((n, re.sub(r"<[^>]+>", "", html.unescape(txt)), ident))
        return f'<h{n} id="{ident}">{txt}</h{n}>'
    return lista, re.sub(r"<h([23])[^>]*>(.*?)</h\1>", poner, h)


def documento(meta, cuerpo_html, lista, paginas):
    color = meta.get("color", "#2f6fed")
    oscuro = meta.get("color_oscuro", color)
    icono = (RAIZ / meta["icono"]).as_uri() if meta.get("icono") else ""
    filas = []
    n2 = 0
    for n, txt, ident in lista:
        if n == 2:
            n2 += 1
            etiqueta = f"{n2}. {txt}"
        else:
            etiqueta = txt
        p = paginas.get(ident, "")
        filas.append(f'<li class="n{n}"><a href="#{ident}">{html.escape(etiqueta)}</a><span class="pt"></span><span class="p">{p}</span></li>')
    # numera los h2 también en el cuerpo
    cont = [0]

    def numerar(m):
        cont[0] += 1
        return f'<h2 id="{m.group(1)}">{cont[0]}. {m.group(2)}</h2>'
    cuerpo = re.sub(r'<h2 id="(t\d+)">(.*?)</h2>', numerar, cuerpo_html)
    portada = f"""<section class="portada"><div class="banda"></div>{f'<img class="ico" src="{icono}" alt="">' if icono else ''}
      <h1>{html.escape(meta['titulo'])}</h1><div class="sub">{html.escape(meta.get('subtitulo', ''))}</div>
      <div class="meta">Guía completa · versión {html.escape(meta.get('version', ''))}<br>Mario · Kuerb0 · kuerb0.github.io</div></section>"""
    indice = f'<section class="indice"><h2>Índice</h2><ol>{"".join(filas)}</ol><span style="color:#fff;font-size:1px">§fin-indice§</span></section>'
    return f"""<!doctype html><html lang="es"><head><meta charset="utf-8"><title>{html.escape(meta['titulo'])}</title>
<style>:root{{--acento:{color};--acento-oscuro:{oscuro}}}{CSS}</style></head><body>{portada}{indice}{cuerpo}</body></html>"""


class Edge:
    def __init__(self):
        self.perfil = tempfile.mkdtemp(prefix="edge_pdf_")
        self.proc = subprocess.Popen([EDGE, "--headless=new", "--disable-gpu", f"--remote-debugging-port={PUERTO}", f"--user-data-dir={self.perfil}",
                                      "--no-first-run", "--allow-file-access-from-files", "--remote-allow-origins=*", "about:blank"],
                                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        for _ in range(80):
            try:
                t = next(t for t in json.load(urllib.request.urlopen(f"http://127.0.0.1:{PUERTO}/json")) if t["type"] == "page")
                break
            except Exception:
                time.sleep(0.4)
        self.ws = websocket.create_connection(t["webSocketDebuggerUrl"], max_size=None, timeout=180)
        self.n = 0

    def cmd(self, metodo, **p):
        self.n += 1
        self.ws.send(json.dumps({"id": self.n, "method": metodo, "params": p}))
        while True:
            r = json.loads(self.ws.recv())
            if r.get("id") == self.n:
                if "error" in r:
                    raise RuntimeError(r["error"])
                return r.get("result", {})

    def pdf(self, ruta_html, titulo, salida):
        self.cmd("Page.enable")
        self.cmd("Page.navigate", url=Path(ruta_html).as_uri())
        for _ in range(100):
            if self.cmd("Runtime.evaluate", expression="document.readyState === 'complete' && [...document.images].every(i => i.complete)", returnByValue=True)["result"].get("value"):
                break
            time.sleep(0.3)
        time.sleep(0.5)
        pie = ('<div style="font:8px Segoe UI,sans-serif;color:#7a8396;width:100%;padding:0 18mm;display:flex;justify-content:space-between">'
               f'<span>{html.escape(titulo)} · Guía completa</span><span>Página <span class="pageNumber"></span> de <span class="totalPages"></span></span></div>')
        r = self.cmd("Page.printToPDF", printBackground=True, preferCSSPageSize=True, displayHeaderFooter=True, headerTemplate="<span></span>", footerTemplate=pie)
        Path(salida).write_bytes(base64.b64decode(r["data"]))

    def cerrar(self):
        try:
            self.ws.close()
        finally:
            self.proc.terminate()
            shutil.rmtree(self.perfil, ignore_errors=True)


def paginas_de(pdf, lista, saltar):
    """Página (1, 2…) en la que aparece cada título, buscando a partir de la del índice."""
    doc = fitz.open(pdf)
    res, desde = {}, saltar
    n2 = 0
    for n, txt, ident in lista:
        if n == 2:
            n2 += 1
        buscar = f"{n2}. {txt}" if n == 2 else txt
        for p in range(desde, len(doc)):
            if buscar.lower() in doc[p].get_text().lower():
                res[ident] = p + 1
                desde = p
                break
    return res, len(doc)


def construir(id_, edge):
    meta, cuerpo = leer(id_)
    h = a_html(cuerpo)
    lista, h = titulos(h)
    tmp = Path(tempfile.mkdtemp(prefix="guia_"))
    ruta = tmp / "guia.html"
    salida = RAIZ / "guias" / f"{id_}.pdf"
    paginas = {}
    for vuelta in (1, 2):
        ruta.write_text(documento(meta, h, lista, paginas), encoding="utf-8")
        edge.pdf(ruta, meta["titulo"], salida)
        if vuelta == 1:
            doc = fitz.open(salida)
            fin_indice = next((i for i, p in enumerate(doc) if "§fin-indice§" in p.get_text()), 1)
            paginas, total = paginas_de(salida, lista, fin_indice + 1)
    shutil.rmtree(tmp, ignore_errors=True)
    doc = fitz.open(salida)
    print(f"{id_}: {len(doc)} páginas, {len(lista)} apartados, {salida.stat().st_size / 1024:.0f} KB")


def indice():
    """guias/index.html: la lista de las guías, en el orden del portal, con su número de páginas y su tamaño."""
    webs = sorted(json.loads((RAIZ / "webs.json").read_text(encoding="utf-8")), key=lambda w: w.get("orden", 0))
    filas = []
    for w in webs:
        pdf = RAIZ / w["guia"] if w.get("guia") else None
        if pdf and pdf.is_file():
            with fitz.open(pdf) as d:
                n = len(d)
            mb = f"{pdf.stat().st_size / 1e6:.1f}".replace(".", ",")
            filas.append(f'    <li><a href="{html.escape(pdf.name)}">{html.escape(w["titulo"])}</a><span>{n} páginas · {mb} MB</span></li>')
    (RAIZ / "guias" / "index.html").write_text(f"""<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Guías en PDF · Mario</title>
<meta name="description" content="Las guías completas en PDF de las webs y apps del portal de Mario.">
<link rel="icon" type="image/png" href="../icon-192.png">
<link rel="stylesheet" href="../estilo.css">
</head>
<body>
<main class="guias-indice">
  <p><a href="../">← Volver al portal</a></p>
  <h1>Guías en PDF</h1>
  <p>Cada guía explica una web o una app de principio a fin, con capturas e índice. Se abren en el navegador.</p>
  <ul>
{chr(10).join(filas)}
  </ul>
</main>
</body>
</html>
""", encoding="utf-8", newline="\n")
    print(f"guias/index.html: {len(filas)} guías")


if __name__ == "__main__":
    ids = [a for a in sys.argv[1:] if a != "--indice"]
    if "--indice" not in sys.argv[1:] or ids:
        edge = Edge()
        try:
            for i in ids or sorted(p.stem for p in SRC.glob("*.md")):
                construir(i, edge)
        finally:
            edge.cerrar()
    indice()
