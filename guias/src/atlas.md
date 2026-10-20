titulo: Atlas del conocimiento
subtitulo: Un mapa 3D de más de 300 funciones y de tu propia biblioteca, con guía para aprender
version: 1.15.1
icono: img/iconos/atlas.png
color: #6b4de6
color_oscuro: #4d35b0

## Qué es esta app

El Atlas del conocimiento junta en un solo sitio dos cosas: un árbol de más de trescientas funciones de estadística, actuarial, finanzas y aprendizaje automático (con su explicación, su ejemplo ejecutable y su equivalente en SAS), y tu biblioteca personal de libros, artículos y apuntes, clasificada por temas.

Todo se explora en un universo 3D en forma de galaxias: cada galaxia es una parte del conocimiento, cada punto es una función, un concepto o una obra. Se gira, se acerca, se entra en una galaxia con un clic y, en el panel de la derecha, se lee todo sobre lo que se ha elegido.

![El universo: una galaxia por cada parte](guias/img/atlas/universo.jpg)

Sirve para tres cosas:

- **Encontrar qué función usar** y cuándo, con su ficha de propiedades y las alternativas.
- **Aprender desde cero** con una guía paso a paso, demos interactivas y preguntas.
- **Ordenar tu biblioteca**: importas libros y apuntes, se clasifican solos y se pueden buscar por su texto.

## Instalación

1. Descarga el instalador desde el botón «Descargar para Windows» del portal (unos 160 MB).
2. Ábrelo. Si Windows avisa de que no conoce al editor, pulsa «Más información» y luego «Ejecutar de todas formas».
3. Elige la carpeta y los accesos directos. Evita las carpetas sincronizadas (OneDrive, Dropbox): Python y las librerías son miles de ficheros y la sincronización los ralentiza.
4. Abre el Atlas desde el acceso directo del Escritorio.

No hace falta tener Python ni conexión a internet para instalarlo: lleva el suyo dentro. La IA local es opcional y se instala aparte (pesa unos 2 GB).

Para instalar una versión nueva, ejecuta el instalador nuevo encima. Conserva tu catálogo de conceptos y tus fichas, y solo les añade lo nuevo.

## La ventana

Arriba están las pestañas, el buscador y las herramientas.

| Pestaña | Para qué sirve |
|---|---|
| 🌌 Universo | El mapa 3D de todo tu conocimiento. |
| ⚫ Importar | Un agujero negro al que sueltas archivos para clasificarlos. |
| 🔭 Observatorio | Lo que has importado: editar, reclasificar o borrar. |
| 🌘 Eclipses | Cuánto ocupa tu biblioteca frente al límite de GitHub. |
| 🧠 IA | Reentrenar la IA local, charlar con ella y ajustar sus recursos. |
| 📡 Telescopio | Buscar obras de acceso abierto y traerlas a tu biblioteca. |
| ⟳ Actualizar | Recarga el programa y el universo sin cerrar la app. |

A la derecha de la barra están el botón 🎓 **Aprender** (la guía paso a paso), el selector de **perfil de proyecto**, el tema (automático, claro u oscuro), el plegado del panel de detalle (tecla P) y la pantalla completa (tecla F).

### Buscador

Pulsa `/` para escribir en el buscador. Encuentra funciones, conceptos, obras de tu biblioteca y, dentro de ellas, el texto exacto con su página; al elegir un resultado de un PDF, lo abre en esa página. Puedes acotar con prefijos: `libros:`, `pdf:`, `epub:`, `historia:`, `vídeo:`.

## El Universo

![Universo](guias/img/atlas/universo.jpg)

Cada galaxia es una parte del árbol (código, conceptos, demos, finanzas) o una colección de tu biblioteca (libros, notas).

- **Arrastrar** gira el mapa, **la rueda** acerca y aleja.
- **Un clic en una galaxia** entra en ella; el núcleo y las ramas se despliegan. Las migas de pan de arriba permiten volver.
- **Cada punto** es una función (más grande cuanto más importante) o un concepto. Al elegirlo, el panel de la derecha muestra su ficha.
- **Botones del mapa**: volver al universo entero (🌌), pausar o reanudar el movimiento (⏸) y volver a la vista general (⌂).
- **Panel de detalle**: se redimensiona arrastrando el divisor; con doble clic se oculta o se muestra.

Las búsquedas rápidas del panel (odds ratio, VIF, chi cuadrado, Kaplan, Markov…) llevan directamente a la función.

### La ficha de una función

Cada función del árbol muestra:

- Para qué sirve y cuándo usarla.
- Su equivalente en SAS (por ejemplo, `PROC LOGISTIC`).
- De dónde sale (trazabilidad).
- Un botón **Probar**: ejecuta un ejemplo de la función con datos simulados, por celdas, desde la propia app.
- Advertencias: cuándo no usarla.
- La **ficha de propiedades**.

### Fichas de propiedades

Cada función tiene barras de 0 a 10 en las propiedades que le aplican, agrupadas en cinco bloques:

| Bloque | Propiedades |
|---|---|
| Estimación | Insesgadez, consistencia, eficiencia, error cuadrático medio, normalidad asintótica, identificabilidad. |
| Inferencia | Tamaño (error de tipo I), potencia, cobertura de los intervalos, cuantificación de la incertidumbre, validez en muestras pequeñas y tras la selección. |
| Predicción y modelo | Generalización, calibración, discriminación, parsimonia, interpretabilidad, estabilidad. |
| Datos que soporta | Robustez, pocos supuestos, censura, desbalanceo, dependencia. |
| Código | Escalabilidad, velocidad, memoria, estabilidad numérica, tolerancia a datos sucios, reproducibilidad, configurabilidad, coste de ajuste, trazabilidad SAS, cobertura de tests. |

Unas notas son **medidas** de verdad (velocidad, memoria y escalabilidad con datos de 1.000 a 64.000 filas; tamaño real, cobertura y sesgo por simulación de Monte Carlo) y otras **estimadas**, con pros, contras, «úsala si» y «evítala si». Puedes cambiar cualquier nota en tu fichero `conceptos/fichas_mias.json`, que el actualizador no pisa.

### Perfil de proyecto

El selector de arriba pondera esas propiedades según lo que te importe, y reordena las alternativas:

- Equilibrado
- Cartera grande o big data
- Pocos datos o estudio
- Regulatorio o tarificación
- Predicción pura
- Personalizado (tus propios pesos)

La puntuación de cada función es la media ponderada de sus notas con el perfil elegido.

## Qué hay en el árbol

El árbol `arbol_estadistica` tiene catorce ramas:

| Rama | Para qué |
|---|---|
| preprocesado | Preparar datos antes de modelar: imputar, balancear, codificar. |
| seleccion | Qué variables entran: forward, backward, mejor subconjunto, validación cruzada. |
| modelos | Ajustar y explicar: logit, odds ratios, GLM, multinomial, penalizados. |
| diagnostico | Comprobar si el modelo es fiable. |
| clustering | Segmentar. |
| contrastes | Comparar grupos, potencia y tamaño muestral, corrección por FDR. |
| descriptiva | Resumen, atípicos, correlaciones, supuestos, ajuste de distribuciones, tablas. |
| multivariante | Mahalanobis, Hotelling, MANOVA, PCA, análisis factorial, alfa de Cronbach, mezclas, discriminante. |
| ml | Árboles, random forest, boosting, k-NN, SVM, redes, stacking, importancia y dependencia parcial. |
| actuarial | Tablas de vida, seguros y rentas, provisiones, chain ladder, Panjer, ruina, credibilidad, demografía. |
| finanzas | VaR y TVaR, valores extremos, cópulas, estrés, Markowitz, CAPM, Black-Litterman, bonos, curvas de tipos, swaps, opciones. |
| simulacion | Probabilidad, Monte Carlo, bayesiana (conjugadas, MCMC, tests A/B, bandidos), Markov y procesos, muestreo. |
| diseno | ANOVA y diseños, factoriales 2^k, superficies de respuesta, propensión, diferencias en diferencias, ensayos, mediación, metaanálisis. |
| graficos | Gráficos con matplotlib. |

Cada función tiene una línea en el INDEX con su cuándo usarla, su equivalente SAS y su origen. Se puede usar también desde Python o desde notebooks:

```
from arbol_estadistica.modelos import tabla_odds_ratios
```

## Aprender

El botón 🎓 **Aprender** abre una guía paso a paso desde cero. Cada ruta lleva demos interactivas, preguntas y código en Python, y tu progreso se guarda en la propia app.

![Guía de aprendizaje](guias/img/atlas/aprender.jpg)

Hay dos rutas:

1. **Fundamentos: del azar a la inferencia**, desde cero (unas 2 horas y 12 pasos). Qué es una variable aleatoria, las distribuciones más importantes, por qué los promedios se estabilizan y cómo se pasa de unos pocos datos a una conclusión con intervalos de confianza y contrastes de hipótesis.
2. **Estadística descriptiva: mirar y resumir los datos**, también para principiantes (alrededor de 1,5 horas y 10 pasos). Cubre los tipos de variables, las medidas de posición y dispersión, los histogramas y diagramas de caja, la relación entre dos variables y los errores clásicos: resúmenes que engañan, la paradoja de Simpson y gráficos manipulados.

### Cómo funciona

El apartado «Cómo funciona» reúne 25 demos interactivas: distribuciones básicas animadas y en galería, t-test, potencia, FDR, intervalos de confianza, teorema central del límite, regresión, logística, censura, MCMC, cadenas de Markov, bandidos, PCA, k-means, VaR, diversificación, ruina, diferencias en diferencias, sobreajuste, descripción de una variable, el cuarteto de Anscombe, la paradoja de Simpson y gráficos engañosos.

## Importar tu biblioteca

Pestaña **⚫ Importar**. Haz clic en el agujero negro, o suelta archivos encima: se abre el explorador de Windows, donde puedes elegir varios a la vez.

![Importar](guias/img/atlas/importar.jpg)

1. **Añade archivos.** Sirven PDF, EPUB y otros formatos de texto, de apuntes y de código.
2. **Se clasifica solo.** De cada archivo se lee el principio y se propone una galaxia (Finanzas si domina el vocabulario financiero; Libros si es un PDF largo o un EPUB; Notas si es corto o de apuntes; Código si es código), un subtema y un tipo.
3. **Tú mandas.** Despliega cada tarjeta para ver qué se ha detectado (barras con las puntuaciones, capítulos, vista previa del texto). Puedes pulsar una barra para fijar un género o subtema, cambiar los desplegables y editar el título.
4. **Nombres largos.** Los nombres tipo «Título -- Autor -- 2016 -- Editorial -- ISBN» se recortan al título (60 caracteres como mucho). El nombre completo se conserva en la ficha.
5. **Al importar,** cada archivo se copia (el original no se toca) a `conocimiento/biblioteca/<galaxia>/<subtema>/`, se indexa su texto y el universo se regenera.
6. **Después,** el buscador encuentra el texto con su página y abre el PDF ahí. En el mapa, cada capítulo tiene su botón «Abrir en la página N».

También existe la casilla «Importar sin revisar (clasifica solo)»: los archivos que sueltes se importan directamente y los revisas luego, por fecha, en el Observatorio. Desde la consola: `python -m conocimiento importar libro.pdf -G historia`.

### Cómo se clasifican los libros

La clasificación mira el texto, y puede apoyarse en dos ayudas opcionales:

- **Wikipedia y Wikidata**: para obras modernas que el texto no deja claras, la app consulta sus APIs oficiales (una petición por segundo como mucho, con caché en disco) para saber el tipo y el género. Solo sale el título y el autor.
- **IA local (Ollama)**: si la tienes instalada, opina sobre el género y el subgénero. Sin ella, todo sigue funcionando.

## Observatorio

Pestaña **🔭 Observatorio**. Lista todo lo que has importado. Puedes cambiar título, galaxia, género, subtema, tipo o etiquetas, y se guarda al momento; el universo se actualiza al volver a él (o con el botón «Actualizar el universo ahora»). Hay filtro por texto, por galaxia y orden por fecha. Al borrar, solo se quita la copia de tu biblioteca; el original no se toca.

![Observatorio](guias/img/atlas/observatorio.jpg)

## Eclipses

Pestaña **🌘 Eclipses**. Responde a «¿cuánto pesa mi biblioteca?». El Sol representa el límite de GitHub (1 GB recomendado por repositorio); una sola luna lo tapa entero y es un gráfico de sectores: cada porción es una galaxia o un tipo de archivo, en proporción a lo que pesa. El anillo de la corona se completa según lo lleno que esté el límite. Dos botones alternan entre la medida en GitHub y la vista por tipo de archivo.

![Eclipses](guias/img/atlas/eclipses.jpg)

## IA

Pestaña **🧠 IA**. Una IA local, opcional, que se entrena con tu biblioteca. Tiene tres subpáginas:

| Subpágina | Qué hace |
|---|---|
| Entrenamiento | Eliges un nombre (si ya existe, reanuda), un modelo base y si quieres sumar tu biblioteca, y pulsas «Entrenar». Ves el progreso y puedes parar. |
| Chat | Charlas con el modelo. |
| Configuración | Ajustas cuánta GPU, VRAM y RAM puede usar. |

El entrenamiento usa QLoRA y puede exportar el modelo a Ollama. Si tu equipo no tiene tarjeta gráfica potente, no uses esta pestaña: el resto de la app no la necesita.

![IA](guias/img/atlas/ia.jpg)

## Telescopio

Pestaña **📡 Telescopio**. Busca obras en Google Books (ficha y enlace; solo descarga lo que es de dominio público), Project Gutenberg, Internet Archive y artículos en abierto (arXiv, OpenAlex), y las trae a tu biblioteca: se clasifican con las materias reales de la obra. Solo usa fuentes legales.

Eliges qué buscas (todo, un libro o un artículo), escribes el tema, el título o el autor, y si quieres solo PDF o solo EPUB.

![Telescopio](guias/img/atlas/telescopio.jpg)

## Tus datos

| Qué | Dónde |
|---|---|
| Catálogo de conceptos | `conceptos/catalogo.json`. Es tuyo: la actualización no lo pisa, solo añade lo nuevo. |
| Tus fichas de propiedades | `conceptos/fichas_mias.json` (opcional). |
| Tu biblioteca importada e índice | Carpeta `conocimiento/`: no se publica en ningún sitio. |
| Progreso de «Aprender» | En la propia app. |

El Atlas no envía tus datos a ningún sitio. Solo usa internet si lo pides (Telescopio, o la consulta opcional a Wikipedia). Al actualizar se conservan tu catálogo, tus fichas y tu biblioteca. Para quitarlo, usa «Aplicaciones» de Windows; el instalador deja registrado un desinstalador.

## Problemas frecuentes

| Qué pasa | Qué hacer |
|---|---|
| «Probar» no ejecuta nada | Solo funciona en la ventana de la app (necesita hablar con Python). No funciona abriendo el HTML suelto en el navegador. |
| El universo no refleja lo que importé | Pulsa «⟳ Actualizar» o «Actualizar el universo ahora» en el Observatorio. |
| Un PDF no se clasifica bien | En la tarjeta de importar o en el Observatorio, cambia la galaxia, el género o el subtema a mano. |
| La IA no responde | Necesita Ollama y el modelo instalados. Sin ellos, el resto de la app sigue como siempre. |
| Windows avisa al abrir el instalador | Es normal en programas sin firma comercial. Pulsa «Más información» y «Ejecutar de todas formas». |

## Versiones y créditos

Versión 1.15.1. El árbol nació de un notebook de consultoría y de los temarios de un máster de actuarial y se fue ampliando con funciones nuevas, fichas de propiedades medidas y el visor 3D. El código es de Mario (Kuerb0).
