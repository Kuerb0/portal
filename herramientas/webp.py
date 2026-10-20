"""Hace la copia WebP de cada captura JPG de img/ y img/galeria/ (las tarjetas piden la WebP y usan el JPG de respaldo).

    python herramientas/webp.py

Volver a ejecutarlo al añadir o cambiar una captura; comprobar.py falla si a una captura le falta su WebP.
Hace falta Pillow.
"""
from pathlib import Path

from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent

for jpg in sorted([*RAIZ.glob("img/*.jpg"), *RAIZ.glob("img/galeria/*.jpg")]):
    if jpg.name == "og.jpg":          # la de compartir se queda en JPG: no todas las redes leen WebP
        continue
    webp = jpg.with_suffix(".webp")
    if not webp.exists() or webp.stat().st_mtime < jpg.stat().st_mtime:
        Image.open(jpg).save(webp, "WEBP", quality=80, method=6)
        print(f"{webp.relative_to(RAIZ)}: {jpg.stat().st_size // 1024} KB -> {webp.stat().st_size // 1024} KB")
