"""Comprobaciones del portal en un solo comando.

    python herramientas/comprobar.py            # todo: ficheros, Releases de GitHub y prueba de humo en Edge
    python herramientas/comprobar.py --rapido   # sin red ni navegador (solo ficheros)

Falla (código 1) si:
- estilo.css tiene llaves sin cerrar o una sección («/* ---- …») ha quedado dentro de otra regla (p. ej. un @media sin cerrar);
- webs.json no es válido, le falta un campo obligatorio, un id se repite, un resumen pasa de 130 caracteres,
  una ruta (imagen, guía, flujograma, icono, descarga local) no existe, a una captura le falta su copia .webp, o una descarga de una Release no existe o
  su tamaño no coincide con «bytes» (lo mira con `gh release view`);
- una <img> de index.html o portal.js no tiene alt;
- hay un fichero de más de 200 KB en el repositorio al que no se refiere nadie;
- falla la prueba de humo (herramientas/humo.py).
"""
import json
import re
import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
MAX_RESUMEN = 130
PESADO = 200 * 1024
OBLIGATORIOS = ["id", "titulo", "tipo", "seccion", "orden", "icono", "descripcion", "resumen", "estado"]
TIPOS = {"web", "app", "repo"}
RUTAS = ["imagen", "guia", "flujograma", "icono_img", "icono_app", "instalar", "abrir"]
RELEASE = re.compile(r"https://github\.com/([^/]+/[^/]+)/releases/download/([^/]+)/(.+)")

errores = []


def css(texto):
    """Llaves equilibradas y cabeceras de sección siempre fuera de cualquier regla."""
    nivel, linea, i = 0, 1, 0
    while i < len(texto):
        if texto.startswith("/*", i):
            fin = texto.find("*/", i + 2)
            if fin < 0:
                return errores.append(f"estilo.css:{linea}: comentario sin cerrar")
            if texto.startswith("/* ----", i) and nivel:
                errores.append(f"estilo.css:{linea}: la sección «{texto[i + 8:fin].strip()[:40]}» ha quedado dentro de otra regla (¿falta una «}}» antes?)")
            linea += texto.count("\n", i, fin)
            i = fin + 2
            continue
        c = texto[i]
        if c in "\"'":
            fin = texto.find(c, i + 1)
            i = fin + 1 if fin > 0 else len(texto)
            continue
        if c == "\n":
            linea += 1
        elif c == "{":
            nivel += 1
        elif c == "}":
            nivel -= 1
            if nivel < 0:
                errores.append(f"estilo.css:{linea}: «}}» de más")
                nivel = 0
        i += 1
    if nivel:
        errores.append(f"estilo.css: quedan {nivel} llaves sin cerrar al final")


def releases(urls):
    vistos = {}
    for url, bytes_ in urls:
        repo, etiqueta, nombre = RELEASE.match(url).groups()
        if (repo, etiqueta) not in vistos:
            r = subprocess.run(["gh", "release", "view", etiqueta, "-R", repo, "--json", "assets"], capture_output=True, text=True)
            vistos[repo, etiqueta] = {a["name"]: a["size"] for a in json.loads(r.stdout)["assets"]} if r.returncode == 0 else None
        activos = vistos[repo, etiqueta]
        if activos is None:
            errores.append(f"no existe la Release {etiqueta} en {repo}")
        elif nombre not in activos:
            errores.append(f"la Release {etiqueta} de {repo} no tiene {nombre}")
        elif bytes_ and activos[nombre] != bytes_:
            errores.append(f"{nombre}: «bytes» dice {bytes_} y la Release tiene {activos[nombre]}")


def webs():
    try:
        datos = json.loads((RAIZ / "webs.json").read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        return errores.append(f"webs.json no es JSON válido: {e}"), []
    urls, ids = [], set()
    for w in datos:
        nombre = w.get("id", "?")
        errores.extend(f"{nombre}: falta «{k}»" for k in OBLIGATORIOS if not w.get(k))
        if nombre in ids:
            errores.append(f"{nombre}: id repetido")
        ids.add(nombre)
        if w.get("tipo") not in TIPOS:
            errores.append(f"{nombre}: tipo «{w.get('tipo')}» (debe ser web, app o repo)")
        if len(w.get("resumen", "")) > MAX_RESUMEN:
            errores.append(f"{nombre}: el resumen tiene {len(w['resumen'])} caracteres (máximo {MAX_RESUMEN})")
        if not w.get("imagen") and not w.get("imagenes"):
            errores.append(f"{nombre}: sin «imagen» ni «imagenes»")
        if w.get("tipo") == "app":
            errores.extend(f"{nombre}: falta «{k}»" for k in ("version", "descargas") if not w.get(k))
        rutas = [w[k] for k in RUTAS if w.get(k)] + w.get("imagenes", [])
        for d in w.get("descargas", []):
            if RELEASE.match(d["archivo"]):
                urls.append((d["archivo"], d.get("bytes")))
            else:
                rutas.append(d["archivo"])
                f = RAIZ / d["archivo"]
                if f.is_file() and d.get("bytes") and f.stat().st_size != d["bytes"]:
                    errores.append(f"{d['archivo']}: «bytes» dice {d['bytes']} y pesa {f.stat().st_size}")
        errores.extend(f"{nombre}: no existe {r}" for r in rutas if not (RAIZ / r).exists())
        capturas = [w["imagen"]] if w.get("imagen") else []
        errores.extend(f"{nombre}: falta {c[:-4]}.webp (python herramientas/webp.py)" for c in capturas + w.get("imagenes", [])
                       if c.endswith(".jpg") and not (RAIZ / c).with_suffix(".webp").exists())
    return datos, urls


def imagenes_sin_alt():
    for nombre in ["index.html", "portal.js"]:
        texto = (RAIZ / nombre).read_text(encoding="utf-8")
        for m in re.finditer(r"<img\b[^>]*>", texto):
            if not re.search(r"\balt=", m.group(0)):
                errores.append(f"{nombre}:{texto.count(chr(10), 0, m.start()) + 1}: <img> sin alt")


def pesados_sin_uso():
    ficheros = subprocess.run(["git", "ls-files", "-z"], cwd=RAIZ, capture_output=True, text=True, encoding="utf-8").stdout.split("\0")
    textos = [RAIZ / f for f in ficheros if f and Path(f).suffix in {".json", ".html", ".js", ".md", ".py", ".webmanifest", ".css"} and f != "README.md"]
    corpus = "\n".join(p.read_text(encoding="utf-8", errors="ignore") for p in textos)
    for f in ficheros:
        if f and (RAIZ / f).is_file() and (RAIZ / f).stat().st_size > PESADO and Path(f).name not in corpus:
            errores.append(f"{f}: {(RAIZ / f).stat().st_size // 1024} KB y nadie lo usa")


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    rapido = "--rapido" in sys.argv
    css((RAIZ / "estilo.css").read_text(encoding="utf-8"))
    _, urls = webs()
    imagenes_sin_alt()
    pesados_sin_uso()
    if not rapido:
        releases(urls)
    if errores:
        print("FALLA:\n  " + "\n  ".join(errores))
        sys.exit(1)
    print("Ficheros: bien" + ("" if rapido else ", Releases: bien"), flush=True)
    if not rapido:
        sys.exit(subprocess.run([sys.executable, str(RAIZ / "herramientas" / "humo.py")]).returncode)


if __name__ == "__main__":
    main()
