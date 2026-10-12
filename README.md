# Portal

Página central, estática, donde están todas las webs. Siempre encendida (las apps de Streamlit se duermen; esta no).

- `webs.json`: una entrada por web (título, icono, descripción, etiquetas, `url` y `estado`). **Para añadir una web, solo se edita este fichero.** Si `url` está vacío, la tarjeta sale como «En preparación».
- `index.html`, `estilo.css`, `portal.js`: la página (buscador, tema claro/oscuro, tarjetas). Sin dependencias ni paso de compilación.

## Probar en local

```bash
python -m http.server 8000
```

y abrir <http://localhost:8000>.

## Publicar

GitHub Pages: en el repositorio, *Settings → Pages → Deploy from a branch → `main` / `(root)`*. El fichero `.nojekyll` evita que GitHub procese la carpeta.
