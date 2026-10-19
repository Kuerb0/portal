titulo: Estadística
subtitulo: Aprender y usar estadística viéndola moverse, con el código en Python, R y SAS
version: 1.0.0
icono: img/iconos/estadistica-app.png
color: #3a7bd5
color_oscuro: #2a5aa0

## Qué es esta app

Estadística es una caja de herramientas para entender y usar la estadística viéndola moverse. En lugar de una fórmula quieta en una página, tienes deslizadores: mueves un parámetro y la distribución cambia de forma; pulsas «Reproducir» y ves cómo un algoritmo converge paso a paso; cargas tus datos y obtienes el modelo, su resumen y el código para repetirlo fuera.

![Distribuciones](guias/img/estadistica-app/distribuciones.jpg)

Está pensada para tres usos:

- **Aprender**: cada tema tiene una animación, una explicación corta y la fórmula.
- **Probar**: cambias datos y parámetros y ves el efecto al momento.
- **Trabajar**: cada resultado trae el código en Python, R y SAS listo para copiar.

La app calcula con scipy y statsmodels dentro de tu equipo. No sube nada a internet y funciona sin conexión.

### Qué hay dentro

| Página | De qué va |
|---|---|
| Distribuciones | 23 distribuciones con deslizadores, comparación y simulador. |
| Regresiones | Lineal, logit, probit y siete modelos lineales generalizados. |
| Contrastes | Bondad de ajuste, medias, proporciones, independencia, ANOVA y potencia. |
| Conceptos básicos | 13 ideas de probabilidad e inferencia con demostración animada. |
| Descriptiva | Qué gráfico y qué resumen toca según el tipo de variable. |
| Bayes | Previa más datos igual a posterior, y muestreo Metropolis. |
| Clasificación | Umbral, matriz de confusión, curva ROC y sobreajuste. |
| Supervivencia | Kaplan-Meier, log-rank y riesgos proporcionales de Cox. |
| Clustering | Seis métodos para agrupar, cada uno con su algoritmo animado. |
| Actuarial | Tablas de vida, ruina, bonus-malus, reservas, credibilidad y valores extremos. |
| Índice | Todo lo anterior en una sola página, con buscador. |
| Apariencia | Paletas, estilos y fondos animados. |

## Instalación

### En Windows

1. Descarga el instalador desde el botón «Instalador» del portal.
2. Ábrelo. Si Windows avisa de que no conoce al editor, pulsa «Más información» y luego «Ejecutar de todas formas».
3. Elige la carpeta y los accesos directos que quieras.
4. Abre Estadística desde el acceso directo del Escritorio.

No hace falta tener Python ni conexión a internet: el programa lleva todo dentro. La ventana usa WebView2, que viene con Windows 11 y con Microsoft Edge. Para una versión nueva, ejecuta el instalador nuevo encima.

### En Android

Descarga el «Instalador móvil» (`.apk`), ábrelo y permite instalar apps de origen desconocido. La primera vez necesita internet para descargar Python y las librerías de cálculo; después funciona sin conexión.

## Recorrido por la pantalla

A la izquierda está el menú, agrupado por temas: Fundamentos (Índice, Conceptos básicos, Descriptiva y Distribuciones), Inferencia (Contrastes, Bayes y Regresiones), Modelos (Clasificación, Supervivencia, Clustering y Actuarial) y La app (Apariencia). En la parte de arriba del menú hay un botón de búsqueda (Ctrl+K). El contenido de la página está a la derecha y casi todas las páginas se organizan igual:

1. Un título con una frase que dice de qué va.
2. A la izquierda de la página (o arriba), una lista de secciones o modelos.
3. Parámetros con deslizadores.
4. El gráfico animado.
5. Resultados y, abajo, el código.

### Buscador global (Ctrl+K)

Pulsa Ctrl+K o el botón de la lupa y escribe lo que buscas, sin importar acentos ni mayúsculas: «gompertz», «dbscan», «sobredispersion»… La lista te lleva a la sección exacta, no solo a la página.

![Índice de la app](guias/img/estadistica-app/indice.jpg)

### Animaciones: el reloj

Las secciones con algoritmos tienen un reloj con controles para reproducir, pausar, ir paso a paso y cambiar la velocidad. Mueve el deslizador de tiempo para ver cualquier momento del proceso.

### Código en tres lenguajes

Cada resultado trae el código para repetirlo fuera de la app, con tus parámetros ya puestos. Con los botones «Python», «R» y «SAS» eliges el lenguaje y «Copiar» lo lleva al portapapeles.

## Distribuciones

Una página para explorar 23 distribuciones de probabilidad.

| Tipo | Distribuciones |
|---|---|
| Continuas (15) | Normal, t de Student, chi-cuadrado, F de Fisher, exponencial, gamma, beta, uniforme, log-normal, Weibull, Cauchy, Laplace, logística, Pareto y Gumbel. |
| Discretas (6) | Bernoulli, binomial, Poisson, geométrica, binomial negativa e hipergeométrica. |
| Multivariantes (2) | Multinomial y normal multivariante en dos dimensiones. |

Eliges una en la lista de la izquierda y mueves sus parámetros con los deslizadores: la forma cambia al instante. Puedes alternar entre la densidad (o la función de probabilidad) y la acumulada.

- **Comparar con otra**: dibuja dos distribuciones a la vez.
- **Animar**: recorre un parámetro para ver cómo evoluciona.
- **Simulador de muestras**: genera 1.000 valores (u otros) y dibuja su histograma sobre la teoría.
- **Propiedades**: media, varianza, asimetría y curtosis.
- **Relaciones con otras distribuciones** y **Cuándo usarla**: de qué otra distribución sale, y para qué sirve.
- **Código** en Python, R y SAS.

## Regresiones

Ajusta un modelo con datos de ejemplo o con tu propio CSV, mira cómo converge el algoritmo, lee el resumen y copia el código.

![Regresiones](guias/img/estadistica-app/regresiones.jpg)

### Modelos

| Modelo | Para qué respuesta |
|---|---|
| Lineal (MCO) | Una cantidad continua: ventas, notas, temperaturas. |
| Logit | Sí o no. Los coeficientes se leen como razones de odds. |
| Probit | Sí o no, con enlace normal. |
| GLM Poisson | Recuentos. Los coeficientes se leen como razones de tasas. |
| Quasi-Poisson | Recuentos con sobredispersión: mismos coeficientes, errores corregidos. |
| Binomial negativa | Recuentos con sobredispersión, con su propio parámetro. |
| GLM Gamma | Cantidades positivas y asimétricas (cuantías). |
| GLM Tweedie | Mezcla de ceros exactos y cantidades positivas (prima pura). |
| GLM Gaussiana inversa | Positivas con cola muy pesada. |
| GLM Binomial | Éxitos de n ensayos o respuestas 0 y 1. |

Cada modelo explica qué es, cuándo usarlo y su fórmula.

### Datos

- **Ejemplo**: cada modelo trae un conjunto de ejemplo (ventas, aprobados, pólizas con exposición…).
- **Tu CSV**: cargas un archivo, eliges la variable respuesta y las explicativas, y la app ajusta con tus datos.
- **Exposición (offset)**: en Poisson, quasi-Poisson y binomial negativa puedes indicar la exposición de cada póliza.

### Qué ves

1. El ajuste: los datos con la curva del modelo, con banda de confianza.
2. El **algoritmo animado**: cómo converge (mínimos cuadrados, IRLS o la alternancia entre coeficientes y parámetro de dispersión).
3. El **resumen del modelo**: coeficientes, errores, estadísticos, p-valores, AIC y devianza.
4. La **sobredispersión**: un contraste para decidir entre Poisson y sus alternativas.
5. **Entrenamiento y prueba**: un deslizador «reservar para test» (de 0 a 50 %) separa los datos; el modelo solo ve el entrenamiento y la tabla compara las métricas de los dos grupos (RMSE, MAE, R², exactitud…). «Otra partición» cambia la semilla.
6. **Cómo leerlo**: una explicación en lenguaje llano de cada número.

## Contrastes

Contrastes de hipótesis explicados con animaciones: qué se compara, cuánto cuesta que sea casualidad y qué decisión se toma. Cada sección tiene tres pasos: la muestra, el contraste y la animación.

![Contrastes de bondad de ajuste](guias/img/estadistica-app/contrastes.jpg)

| Sección | Qué contrasta |
|---|---|
| Bondad de ajuste | ¿Viene esta muestra de esta distribución? Con Cramér-von Mises, Kolmogorov-Smirnov, Anderson-Darling, chi-cuadrado y Shapiro-Wilk. El p-valor sale de simular muchas muestras que sí vienen de esa distribución. |
| Medias | t de una y de dos muestras. |
| Proporciones | Una o dos proporciones. |
| Independencia | Chi-cuadrado sobre una tabla de contingencia. |
| ANOVA | Comparación de varias medias, con el supuesto de varianzas iguales y las comparaciones por pares de Tukey. |
| Potencia y tamaño muestral | Las dos campanas solapadas: cómo cambian la potencia y el error al variar n, el efecto y α. |

La muestra puede generarse desde cualquier distribución del catálogo (o una mezcla) o pegarse desde tus datos. La animación enseña cómo se construye el estadístico y dónde cae el valor observado entre los simulados. Abajo, una tabla de resultados con la decisión de cada contraste y el código.

## Conceptos básicos

Las ideas de partida de la probabilidad y la estadística, cada una con una demostración que se mueve. Sigue el orden de la serie «Stats from Scratch» de Very Normal, con enlaces a sus vídeos.

![El teorema central del límite](guias/img/estadistica-app/conceptos_tlc.jpg)

| Grupo | Temas |
|---|---|
| Datos y azar | Población, muestra y parámetros; variable aleatoria y su distribución; esperanza, varianza y ley de los grandes números; teorema central del límite. |
| Probabilidad condicionada | Probabilidad condicionada y teorema de Bayes; el problema de Monty Hall. |
| Inferencia | Estimadores, sesgo y error cuadrático; intervalos de confianza; bootstrap; modelo estadístico y verosimilitud. |
| Procesos estocásticos | Paseo aleatorio y movimiento browniano; proceso de Poisson; cadenas de Markov. |

Algunos ejemplos de lo que se ve:

- **Teorema central del límite**: eliges una distribución de partida muy asimétrica y el tamaño de cada muestra; el histograma de 2.000 medias se acerca a la normal. Con n igual a 1 no se parece; sube n y mira.
- **Monty Hall**: cuatro partidas de ejemplo y el porcentaje acumulado de victorias de cambiar de puerta (cerca del 67 %) frente a quedarse (cerca del 33 %).
- **Intervalos de confianza**: muchas muestras, cada una con su intervalo; la línea vertical es el parámetro verdadero y se ve cuántos intervalos lo contienen.
- **Bootstrap**: la muestra original y cada remuestra con reemplazo, y la distribución del estadístico.

![Monty Hall](guias/img/estadistica-app/conceptos_monty.jpg)

## Descriptiva

Qué gráfico y qué resumen toca según el tipo de variable.

- **Tipos de variable y qué gráfico toca**: eliges el tipo de una o dos variables (normal, ordinal, numérica discreta o continua) y la app recomienda el gráfico y el resumen adecuados, con un ejemplo real.
- **Paradoja de Simpson**: una animación con datos continuos y el caso de dos tratamientos para cálculos renales, donde el tratamiento que parece mejor en total es peor en cada grupo.

![Descriptiva](guias/img/estadistica-app/descriptiva.jpg)

## Bayes

Dos secciones:

- **Beta-binomial secuencial**: eliges una previa (una beta) y vas añadiendo datos; la posterior se actualiza en cada paso. Hay un resumen de la posterior (media, intervalo creíble) y la comparación con la previa.
- **Muestreo Metropolis (MCMC)**: una cadena que explora la distribución posterior, con su traza y su histograma.

![Bayes](guias/img/estadistica-app/bayes.jpg)

## Clasificación

- **Umbral, matriz de confusión y curva ROC**: dos grupos que se solapan; mueves el umbral y ves cómo cambian los aciertos, los falsos positivos y la curva ROC con su área.
- **Sobreajuste**: ajustas modelos de grado 1 a 10 y ves la frontera de decisión y cómo el error de entrenamiento baja mientras el de prueba sube.

![Clasificación](guias/img/estadistica-app/clasificacion.jpg)

## Supervivencia

- **Kaplan-Meier**: curvas de supervivencia con censura, por grupos, con el contraste log-rank.
- **Riesgos proporcionales de Cox**: coeficientes, razones de riesgo y un perfil concreto para ver su curva.

La animación recorre los individuos y los eventos en el tiempo.

![Supervivencia](guias/img/estadistica-app/supervivencia.jpg)

## Clustering

Agrupar individuos parecidos sin que nadie los etiquete.

| Método | Qué hace |
|---|---|
| k-means | Reparte los puntos en k grupos moviendo los centros. Con historial de iteraciones. |
| k-medoides (PAM) | Como k-means, pero los centros son puntos reales; fases BUILD y SWAP, con distancia Manhattan. |
| Jerárquico | Un árbol de fusiones con dendrograma. Hay varios enlaces (Ward, completo, simple…). |
| DBSCAN | Grupos por densidad: encuentra formas raras y marca el ruido. |
| Mezclas gaussianas (EM) | Cada grupo es una campana; el algoritmo EM la ajusta. |

Además, una sección de componentes principales enseña las cargas de cada componente.

La sección «Los seis repartos» ejecuta k-means, k-medoides, jerárquico con enlace Ward, jerárquico con enlace simple, mezcla gaussiana y DBSCAN sobre los mismos datos y los pone en una cuadrícula. Una tabla de resultados da para cada uno los grupos, el ruido, la silueta (qué tan compactos y separados salen) y el ARI frente al grupo real. En datos como las dos lunas, un reparto equivocado puede tener mejor silueta que el correcto; por eso, si se conoce el grupo real, el ARI es el árbitro. Los datos pueden ser pingüinos, clientes, dos lunas, dos anillos o tu propio CSV.

![Comparar métodos de clustering](guias/img/estadistica-app/comparar.jpg)

## Actuarial

Las matemáticas del seguro. Seis secciones:

| Sección | Qué hace |
|---|---|
| Tabla de vida y seguros | Mortalidad de Gompertz-Makeham: probabilidad de vivir, seguros de vida y rentas. |
| Ruina de una aseguradora | Cramér-Lundberg: la probabilidad de ruina simulada frente a la fórmula exacta. |
| Bonus-malus | Cadena de Markov del sistema de bonificación y su distribución estacionaria. |
| Reservas IBNR | El triángulo de desarrollo que se completa por diagonales, chain-ladder con tres formas de promediar los factores y cola, error de Mack y bootstrap. Con tu CSV de triángulo. |
| Credibilidad de Bühlmann | Una cartera simulada, la Z que sube con los años y los errores frente al riesgo verdadero. |
| Valores extremos | Excesos sobre un umbral con la Pareto generalizada, VaR y TVaR, exceso medio, estabilidad del parámetro y Q-Q. |

![Actuarial: tabla de vida](guias/img/estadistica-app/actuarial.jpg)

![Reservas IBNR](guias/img/estadistica-app/reservas.jpg)

## Apariencia

Elige una paleta y un estilo: cada vista previa está animada y el cambio se aplica con una transición que se abre desde donde pulsas. Se recuerda al cerrar la app.

| Opción | Qué hay |
|---|---|
| Paletas | 11: Automático (sigue al sistema), Noche, Día, Océano, Bosque, Atardecer, Violeta neón, Nórdico, Papel, Menta y Alto contraste. |
| Estilos | 4 de tarjetas: Suave (el actual), Nítido, Cristal y Compacto. |
| Fondos animados | 8: Aurora, Campanas, Lluvia de Galton, Constelación con caminantes de Markov, Paseos aleatorios, Lluvia de símbolos, Ondas y Horizonte, con intensidad regulable. |
| Animación | Normal o reducida. |

Por defecto viene Noche con estilo Suave y fondo Ondas.

![Apariencia](guias/img/estadistica-app/apariencia.jpg)

## Tus datos y privacidad

La app no sube nada a internet, no necesita cuenta y no guarda tus datos: los CSV que cargas se leen en memoria para calcular y no se copian a ninguna parte. Lo único que recuerda es la apariencia que elijas.

Para quitarla, usa «Aplicaciones» de Windows: el instalador deja registrado un desinstalador.

## Problemas frecuentes

| Qué pasa | Qué hacer |
|---|---|
| La ventana sale en blanco | Falta WebView2. Viene con Windows 11 y con Microsoft Edge; en Windows 10, instala Edge. |
| Mi CSV no se carga | Comprueba que tenga cabecera y que las columnas numéricas no tengan texto. |
| El ajuste da error | Con pocos datos o variables que se repiten, el modelo no converge. Prueba con menos variables. |
| Windows avisa al abrir el instalador | Es normal en programas sin firma comercial. Pulsa «Más información» y «Ejecutar de todas formas». |
| No encuentro algo | Pulsa Ctrl+K y escribe su nombre. |

## Versiones y créditos

La versión 1.0.0 reúne las doce páginas descritas aquí. El código es de Mario (Kuerb0). Los vídeos de Conceptos básicos son de la serie «Stats from Scratch» de Very Normal y se abren en el navegador.
