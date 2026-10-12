# Portal

Página central, estática, donde están todas las webs. Siempre encendida (las apps de Streamlit se duermen; esta no).

- `webs.json`: una entrada por web (título, icono —nombre de uno de los de `ICONOS` en `portal.js`: avion, grafico, euro, funciones, codigo, apps—, descripción (solo para la búsqueda: las tarjetas no la muestran), etiquetas, `url` y `estado`). **Para añadir una web, solo se edita este fichero.** Si `url` está vacío, la tarjeta sale como «En preparación».
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

Los envoltorios de estadistica/ y inanzas/ son iguales que el de uelos/ (copiar la carpeta, cambiar URL_APP, los textos, el manifiesto y los iconos). instalar.js da el bot�n y el aviso de instalaci�n; el portal muestra la secci�n �Inst�lame� y es instalable (manifest.webmanifest, sw.js).
