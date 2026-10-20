# Portal

Página central, estática, donde están todas las webs. Siempre encendida (las apps de Streamlit se duermen; esta no).

- `webs.json`: una entrada por web (título, icono —nombre de uno de los de `ICONOS` en `portal.js`: avion, grafico, euro, funciones, codigo, apps, calendario, apagar, nota—, descripción (la larga: no se ve en la tarjeta, solo sirve para la búsqueda), `resumen` (tres líneas sencillas bajo el título), `url` y `estado`). **Para añadir una web, solo se edita este fichero.** Si `url` está vacío (y no es una app), la tarjeta sale como «En preparación».
  - Apps: `version` (sale en la barra de ventana de la miniatura y en el botón de descarga) y `descargas`, una lista de `{texto, archivo, bytes}`. Los `.exe`/`.bat`/`.msi` y los `.apk` son la acción principal («Descargar para Windows», «Android»), con versión y tamaño (`bytes`, el de la Release: `gh release view <etiqueta> -R Kuerb0/descargas --json assets`). Lo demás (el tráiler) sale como botón secundario con su `texto`.
  - Orden de cada tarjeta: miniatura, título, resumen, insignia (solo si hay algo que decir) y acciones abajo: la principal rellena y las secundarias (Tráiler, Esquema, Guía, GitHub) con borde fino.
- `index.html`, `estilo.css`, `portal.js`: la página (buscador, tema claro/oscuro, tarjetas). Sin dependencias ni paso de compilación.

## Probar en local

```bash
python -m http.server 8000
```

y abrir <http://localhost:8000>.

## Publicar

GitHub Pages: en el repositorio, *Settings → Pages → Deploy from a branch → `main` / `(root)`*. El fichero `.nojekyll` evita que GitHub procese la carpeta.

## Webs instalables (envoltorios)

`vuelos/` es una página mínima que muestra la app de Streamlit de Vuelos a pantalla completa y la hace instalable en el móvil
(`manifest.webmanifest`, `sw.js` e iconos PNG). La app sigue en su dirección de Streamlit; esto solo la enmarca. Para cambiar
la dirección de la app, editar `URL_APP` en `vuelos/index.html`. Dirección: <https://kuerb0.github.io/portal/vuelos/>.

Los envoltorios de estadistica/ y inanzas/ son iguales que el de uelos/ (copiar la carpeta, cambiar URL_APP, los textos, el manifiesto y los iconos). instalar.js da el botón y el aviso de instalación; el portal muestra la sección «Instálame» y es instalable (manifest.webmanifest, sw.js).

`inicio/` es el envoltorio instalable del propio portal (muestra `../` en un marco y tiene su manifiesto, icono y service worker). La raíz (`/portal/`) ya no lleva manifiesto: así los ámbitos de todas las apps instalables quedan al mismo nivel.

## Flujogramas de las apps de escritorio

Las tarjetas con `"flujograma": "flujogramas/<app>.svg"` en `webs.json` llevan el botón «Esquema»: despliega el esquema en la tarjeta y «Ampliar» lo abre en un visor con zoom y arrastre. El de Viajes (App) es el `Flujograma.svg` de su repositorio; los demás se generan con `python herramientas/generar_flujogramas.py` (cada app se describe en `APPS`, dentro de ese fichero: columnas de cajas y flechas).

El botón «Guía» sale con `"guia": "guias/<id>.pdf"` en `webs.json` y abre en otra pestaña la documentación completa de la app, con portada, índice y números de página. Los PDF se hacen con `python guias/construir.py [id]` a partir de `guias/src/<id>.md` (con imágenes en `guias/img/`; hace falta Edge, `markdown`, `PyMuPDF` y `websocket-client`).

## Prueba de humo

`python herramientas/humo.py [etiqueta]` sirve la carpeta en local, abre la página con Edge sin ventana a 1400 px (oscuro, claro y con movimiento reducido), 768 px y 375 px, y falla si hay desbordamiento horizontal, si no salen las 12 tarjetas, si algún botón se parte o se corta, si una fila de tarjetas no alinea título, resumen, insignia y acciones, si «Instálame» pierde el borde o si el visor de flujogramas se ve. Deja capturas de página entera en `herramientas/capturas/<etiqueta>/` (fuera de git).
