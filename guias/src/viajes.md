titulo: Vuelos, hoteles y trenes
subtitulo: La web para comparar de un vistazo los vuelos de ida y vuelta, con hoteles y trenes si quieres
version: web
icono: img/iconos/viajes.png
color: #2f6fe0
color_oscuro: #2352a8

## Qué es esta web

Es una web para elegir viaje con datos. Dices desde qué aeropuerto sales, a qué destinos te gustaría ir y entre qué fechas, y la web descarga en ese momento los precios de los vuelos de ida y vuelta de todos esos días y los compara. Si quieres, añade también los hoteles y los trenes. El resultado es un mapa, un resumen, gráficos y tablas para ver qué destino sale más barato, qué días conviene salir y cuánto costaría el viaje completo.

![La web, en el ordenador](guias/img/vuelos-web/d_inicio.jpg)

Funciona en el navegador, sin instalar nada, en el ordenador y en el móvil. No hace falta cuenta.

> Los precios son los que Google Flights, Google Hoteles, Renfe y Ouigo muestran en el momento de la descarga. Pueden cambiar cuando vayas a reservar: los enlaces de la web te llevan a la página de la compañía para comprobarlo.

### Web y app

Esta web es la versión ligera. La app Viajes (para Windows y Android) hace más cosas: guarda el histórico, avisa de bajadas de precio, tiene más páginas y no necesita descargar cada vez. Aquí no se guarda nada entre visitas (salvo lo que elijas, ver más abajo) y todo se baja al momento.

## Abrirla

La dirección es la del botón «Abrir» del portal. Esta web vive en un servicio gratuito que la duerme cuando lleva un rato sin visitas: la primera vez que entras puede tardar hasta medio minuto en despertar. Después va con normalidad.

La web se puede instalar como app en el móvil o el ordenador («Añadir a pantalla de inicio» o «Instalar») y se abre en su propia ventana.

## Hacer una búsqueda

La pantalla principal es un formulario en tres pasos numerados.

### Origen

Arriba a la derecha hay un botón con el origen, por ejemplo «Origen: MAD · Madrid». Al pulsarlo puedes escoger otro aeropuerto, o escribir cualquier código IATA de tres letras (BCN, JFK, LHR, MEX…); vale cualquier aeropuerto del mundo. El título y el mapa destacan el origen elegido.

> Los trenes solo están disponibles con origen Madrid.

### Paso 1: Destinos

Hay dos modos:

- **Concretos**: escribes una ciudad o un código IATA (BCN, LIS, JFK…) y eliges de la lista. Hasta 5 destinos. Los marcados con «tren» tienen tren desde Madrid.
- **Por región**: eliges los principales aeropuertos de un continente o de un país entero, hasta 25.

### Paso 2: Fechas de salida

| Control | Qué hace |
|---|---|
| Desde y Hasta | El primer y el último día en que puedes salir. Se puede pedir hasta un año. Si «Desde» pasa a ser posterior a «Hasta», «Hasta» se coloca 30 días después. |
| Fechas fijas | Si la marcas, solo se mira la ida del día «Desde» y solo la vuelta del día «Hasta». La estancia la marcan las dos fechas. |
| Noches de estancia | Cuántas noches dura el viaje: un mínimo y un máximo (de 1 a 30), con una barra y con casillas para escribir cualquier número. |

### Paso 3: Qué buscar

Siempre se descargan los vuelos de ida y vuelta. Dos casillas añaden más cosas:

- **Añadir hoteles de todos los días.**
- **Añadir trenes de todos los días** (solo destinos con tren).

Una línea resume lo que va a pasar, por ejemplo «31 días × 2 destinos · vuelos de ida y vuelta» y, cuando se puede calcular, cuántas consultas son y cuánto tardará (por ejemplo, «186 consultas, unos 41 segundos»), o que ya está en caché si no queda nada por descargar. Al pulsar **Buscar vuelos** empieza la descarga.

> Hay un tope de unas 10.000 consultas por búsqueda. Si te pasas, la web te pide que acortes las fechas o quites destinos.

## La descarga

La descarga va por detrás: puedes usar toda la página mientras baja. Hay tres barras, una para vuelos, otra para hoteles y otra para trenes, que avanzan a la vez. Mientras tanto, un desplegable bajo las barras enseña un resumen provisional de lo ya descargado, y los resultados se refrescan solos cada pocos segundos, sin parpadeos.

- **Detener** para cada descarga: lo ya bajado queda guardado y no se repite.
- Si nadie mira la pestaña durante unos 10 minutos, la descarga se cancela sola.
- Si Google o Renfe empiezan a limitar las consultas, la web lo avisa («Google está limitando las consultas de vuelos. Inténtalo de nuevo en unos minutos») y conserva lo ya descargado.
- Una descarga repetida no vuelve a consultar: se guarda una caché compartida durante unas horas, así que dos búsquedas iguales hacen una sola consulta a Google.

### Qué se descarga

| Tipo | Cómo |
|---|---|
| Vuelos | Para cada día, todas las opciones de ida y de vuelta (así se puede filtrar por escalas u horas antes de elegir la más barata). |
| Hoteles | Dos estancias por día (de 1 y de 4 noches): cada consulta trae unos 18 alojamientos, casi siempre distintos, y la web junta los de todas las fechas. Una casilla permite pedir aún más. |
| Trenes | Renfe y Ouigo, desde Madrid a la ciudad del destino y la vuelta, uno por tren y día. |

## Los resultados

Hay dos vistas, que se eligen con un selector arriba. Por defecto sale la sencilla en el móvil y la completa en el ordenador.

### Vista sencilla

Pensada para el móvil. Una tarjeta por destino, ordenadas por precio total (vuelos más hotel). Cada una enseña la mejor combinación de ida y vuelta, con horarios, el hotel elegido, el tren si lo hay y un botón a Google Flights. Debajo, el mapa.

![La web, en el móvil](guias/img/vuelos-web/m_inicio.jpg)

### Vista completa

Cuatro secciones, y en cada una el medio que quieras ver (Vuelos, Hoteles, Trenes o Completo):

| Sección | Qué enseña |
|---|---|
| Mapa | El mapa (por defecto). |
| Resumen | La mejor opción de cada destino. |
| Gráficos | Series de precio, mapas de calor y comparaciones. |
| Tablas | Todos los datos, con descarga en CSV y en Excel. |

#### Mapa

Hay tres mapas según el medio:

- **Vuelos**: cada destino es un punto, unido al origen por un arco de círculo máximo (el que siguen los aviones de verdad). Al pulsar un destino se abre su tarjeta con las fechas, los vuelos, el hotel y el tren, con enlaces.
- **Hoteles**: cada alojamiento en su sitio, coloreado por precio, con el centro de la ciudad como un rombo pequeño que solo se ve al acercar. El mapa dice «N de M alojamientos» para que se vea cuántos ocultan los filtros. Al pulsar un hotel sale su tarjeta. La lista de hoteles junto al mapa se puede ordenar y tiene «Resaltar en el mapa».
- **Tren**: el trayecto por vía desde Madrid, las dos estaciones y el centro de la ciudad, con zoom al destino.

Dentro del mapa hay tres botones de fondo: Normal (OpenStreetMap), Simplificado (claro u oscuro según el tema) y Satélite. Una leyenda explica los colores de precio: el más barato en verde y el más caro en rojo.

#### Tarjetas de hoteles

Cada alojamiento muestra su precio, su valoración, su distancia al centro (en kilómetros, andando y en coche), sus servicios (en verde con una marca si los tiene, en rojo si no) y enlaces a Google Hoteles, a Google Maps y a la ruta desde el centro.

#### Gráficos

- Series de precio en el tiempo: del vuelo, del viaje de ida y vuelta, del hotel y del tren.
- Mapas de calor por semanas, con ida, vuelta, la suma de las dos o las dos por separado con la misma escala de color.
- Calendario de precios de un destino.
- Avión contra tren, con las mismas fechas, ida y vuelta.

Tienen filtros rápidos arriba y se pueden descargar los datos.

## Los filtros

La barra lateral (que en el móvil queda tras un icono) tiene 22 filtros. Valen para todas las vistas y se aplican a lo ya descargado, sin buscar otra vez. Un alojamiento al que le falta un dato no se excluye por eso.

| Grupo | Filtros |
|---|---|
| General | Destinos, fechas, noches, presupuesto máximo, orden, cuántos destinos mostrar y búsqueda por texto. |
| Vuelos | Escalas, precio, hora de salida y de llegada de la ida y de la vuelta, duración, espera en escala, aerolíneas, aeropuertos de origen y de destino, y día de la semana de la ida. |
| Hoteles | Precio por noche, estancia, valoración (con «incluir sin valorar»), número de reseñas, estrellas, tipo, servicios imprescindibles y preferibles (suben en la lista pero no excluyen) y distancias al centro (kilómetros, a pie, en coche, en transporte). |

El botón «Limpiar» arriba de la barra los deja todos como al principio.

## Qué se guarda y qué no

- **Lo que eliges** (origen, destinos, fechas, casillas, vista, sección, filtros) se guarda en la dirección de la página y en tu navegador. Si vuelves a abrir la web, vuelve a donde la dejaste. Si copias la dirección y se la mandas a alguien, verá tu misma búsqueda (tendrá que descargar los precios otra vez).
- **Lo descargado no se guarda** (pesa mucho): sale de la caché mientras siga viva. Cada despliegue de la web o un reinicio del servicio la vacía.
- No hay cuentas: cada navegador es su propio «usuario». No se envía ningún dato personal.

## Cómo calcula

- **Vuelo de ida y vuelta**: se empareja cada ida con las vueltas posibles según las noches elegidas, y se ordenan por precio total.
- **Hotel**: el precio de una estancia suma el de cada noche. La mejor combinación se elige por el total con hotel.
- **Tren**: el mejor tren de ida y vuelta, con sus propias fechas.
- **Presupuesto**: el total por destino suma vuelo, hotel y tren, según lo que hayas pedido.

## Problemas frecuentes

| Qué pasa | Qué hacer |
|---|---|
| La primera carga tarda | La web estaba dormida. Espera medio minuto. |
| «Elige al menos un destino» | Escribe una ciudad o un código IATA y elígelo de la lista. |
| «Google está limitando las consultas» | Espera unos minutos y vuelve a buscar. Lo ya descargado no se repite. |
| «Ningún destino tiene ida y vuelta con esos filtros» | Amplía las noches o quita algún filtro. |
| No hay trenes | Los trenes solo salen de Madrid y solo a destinos con tren. |
| Se perdieron los resultados | La caché se vacía al reiniciarse el servicio. Vuelve a buscar. |
| Un precio es distinto al reservar | Es normal: el precio es el de la descarga. Los enlaces abren la página de la compañía. |

## Versiones y créditos

Los datos de vuelos vienen de Google Flights; los de alojamiento, de Google Hoteles; los de tren, de Renfe y Ouigo; los mapas, de OpenStreetMap y Esri, y las rutas de tren, de OpenRailRouting. Son de sus propietarios y se usan de forma personal y con moderación. El código es de Mario (Kuerb0).
