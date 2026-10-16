# Portal

Página central, estática, donde están todas las webs. Siempre encendida (las apps de Streamlit se duermen; esta no).

- `webs.json`: una entrada por web (título, icono —nombre de uno de los de `ICONOS` en `portal.js`: avion, grafico, euro, funciones, codigo, apps, calendario, apagar, nota—, descripción (solo para la búsqueda: las tarjetas no la muestran), etiquetas, `url` y `estado`). **Para añadir una web, solo se edita este fichero.** Si `url` está vacío, la tarjeta sale como «En preparación».
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

Las tarjetas con `"flujograma": "flujogramas/<app>.svg"` en `webs.json` llevan un tercer botón, «Flujograma», junto a Instalador y Actualizador: despliega el esquema en la tarjeta y «Ampliar» lo abre en un visor con zoom y arrastre. El de Viajes (App) es el `Flujograma.svg` de su repositorio; los demás se generan con `python herramientas/generar_flujogramas.py` (cada app se describe en `APPS`, dentro de ese fichero: columnas de cajas y flechas).

El cuarto botón, «Guía rápida», sale con `"guia": {"requisitos": "…", "pasos": […], "datos": "…"}` en `webs.json` y despliega en la tarjeta qué hace falta, el paso a paso y dónde quedan los datos (se cierra el flujograma si estaba abierto: solo se ve un panel a la vez).
