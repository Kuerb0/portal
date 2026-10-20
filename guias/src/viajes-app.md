titulo: Viajes
subtitulo: Precios de vuelos, hoteles y trenes en tu equipo o en tu móvil, para elegir viaje con datos
version: 2.0.0
icono: img/iconos/viajes.png
color: #2f6fe0
color_oscuro: #2352a8

## Qué es esta app

Viajes descarga precios de vuelos, alojamientos y trenes y te los enseña de varias formas para que decidas cuándo y a dónde ir. En vez de mirar un buscador día a día, eliges de dónde sales, a qué sitios te gustaría ir, entre qué fechas y cuántos días, y la app baja los precios de todas esas combinaciones y los compara: qué destino sale más barato, qué día conviene salir, cómo cambia el precio con el tiempo.

![Resumen: lo más barato por destino](guias/img/viajes-app/d_inicio.jpg)

Funciona en Windows y en Android. Todo se queda en tu equipo o en tu móvil: los precios, tus favoritos y tus alertas no se envían a ningún sitio.

| Tipo de dato | De dónde sale |
|---|---|
| Vuelos | Google Flights. Un precio por trayecto y día; la app empareja ida y vuelta. |
| Alojamientos | Google Hotels. Se baja noche a noche y las estancias se suman. |
| Trenes | Renfe y Ouigo (solo saliendo de Madrid). |
| Rutas de tren | OpenRailRouting con OpenStreetMap, para dibujar el trazado por vía. |

> Los precios son los que vio la app cuando los descargó. Pueden haber cambiado cuando vayas a reservar: los enlaces te llevan a la web de la compañía para que lo compruebes.

## Instalación

### En Windows

1. Descarga el instalador (`Viajes-2.0.0-Instalador.exe`, unos 120 MB) desde el botón «Windows» del portal.
2. Ábrelo. Si Windows avisa de que no conoce al editor, pulsa «Más información» y luego «Ejecutar de todas formas».
3. Elige la carpeta y los accesos directos.
4. Abre Viajes desde el acceso directo.

El programa lleva su propio Python con todas las librerías: no hace falta instalar nada más. Para una versión nueva, ejecuta el instalador nuevo encima: respeta tus descargas y tus ajustes.

### En Android

1. Descarga `Viajes-2.0.0-Movil.apk` desde el botón «Android» del portal.
2. Ábrelo y permite instalar apps de origen desconocido cuando Android te lo pida.
3. Necesitas un móvil Android reciente (WebView 137 o superior).

La versión móvil empieza sin datos. La primera vez, descarga los precios desde la página «Descargas». La primera apertura tarda un poco más porque prepara los cálculos.

### La ventana y la bandeja

En Windows, al cerrar la ventana la app no se apaga: queda en la bandeja del sistema, junto al reloj, y las descargas siguen. Para salir del todo, clic derecho en el icono y «Salir» (si hay una descarga en marcha, se pausa; lo ya descargado queda guardado). Si abres la app estando ya abierta, solo te muestra la ventana que existe.

## Tu búsqueda

Al abrir la app por primera vez, antes de cargar nada, te pide lo que quieres. Todo lo demás se basa en esto: solo se cargan esos destinos y esas fechas, así la app va más rápido, los filtros arrancan con esos valores y las descargas piden justo eso.

1. **Aeropuerto de origen.** Elige de dónde sales. Si tu aeropuerto no está en la lista, escribe su código de tres letras (por ejemplo, VLC).
2. **Destinos.** Hasta diez (con cinco va muy ligero). Los escribes y eliges de la lista, o pulsas «Usar 5 destinos sugeridos».
3. **Cuándo y cuántos días.** Entre qué fechas puedes salir, cuántos días dura el viaje (un número o un rango, por ejemplo de 3 a 7) y cuántas personas viajan.

Debajo de los controles, la app te dice cuántos días de vuelos mirará por destino y cuántas consultas serían descargarlo todo. «5 días» significa que sale el día 1 y vuelve el 6; si pones un rango, se mira cada duración.

![Tu búsqueda](guias/img/viajes-app/m_inicio.jpg)

Para cambiarla más adelante, usa el botón «Cambiar búsqueda» del menú lateral.

## Recorrido por la pantalla

A la izquierda está el menú con todas las páginas, con tres botones arriba: la lupa (buscador, también con Ctrl+K), la paleta (apariencia) y el botón de claro y oscuro. Debajo de las páginas están tu búsqueda actual y los filtros.

### Pestañas Vuelos, Trenes, Hoteles y Completo

Casi todas las páginas se dividen en pestañas:

| Pestaña | Qué enseña |
|---|---|
| Vuelos | Combinaciones de ida y vuelta, o vuelos sueltos. |
| Trenes | Los trenes de Renfe y Ouigo (solo saliendo de Madrid). |
| Hoteles | Alojamientos por noche. |
| Completo | El viaje entero: vuelo más alojamiento para las mismas fechas y destino. |

### El recuadro de descargas

Mientras hay una descarga en marcha, aparece abajo a la derecha un recuadro con el progreso de cada tipo (vuelos, trenes y hoteles), con su porcentaje y el tiempo restante. Se actualiza solo y puedes seguir usando toda la app.

### En el móvil

El menú se abre con el botón de las tres rayas. Abajo hay una barra con las páginas de uso más habitual y un botón «Más» que abre el menú completo. Los gráficos largos enseñan menos filas y se dibujan más apretados.

## Las páginas

### Resumen

La foto general: la opción más barata (con su botón «Reservar»), el precio por persona, el total mediano, cuántas combinaciones hay y cuántos destinos. Debajo, una tabla y un gráfico con la mejor opción de cada destino, y un mapa de calor con el precio mínimo por destino y mes.

### Buscador

La lista completa de combinaciones de ida y vuelta, ordenable por total, por euros al día o por fecha de ida. Cada fila lleva destino, total, enlace «Reservar» a Google Flights, fechas, días de viaje, aerolíneas, horas y escalas. Con «Solo ida» o «Solo vuelta» ves los vuelos sueltos. Puedes marcar los primeros resultados como favoritos.

![Buscador](guias/img/viajes-app/d_buscador.jpg)

### Favoritos

Guarda vuelos, alojamientos y trenes concretos (pestañas Vuelos, Trenes y Hoteles) para volver a descargar solo esos, sin bajar todo el destino. De cada favorito ves el precio ahora, el mínimo que ha tenido, el precio al guardarlo y el cambio. Puedes poner un objetivo en euros por persona; la app avisa al bajar de él. Con alojamiento elegido, el viaje suma vuelo por personas más noches por habitaciones.

### Alertas

Dices «avísame si este destino baja de X euros por persona», con un rango de días de viaje. La app comprueba, al abrirse y cada vez que cambian los datos, la combinación de ida y vuelta más barata de ese destino con maletas incluidas. Muestra un aviso por cada alerta que se cumple y ha mejorado desde la última vez. Cada alerta se puede activar, desactivar o quitar.

![Alertas](guias/img/viajes-app/d_alertas.jpg)

### Evolución

Cómo cambia el precio día a día: una línea por destino con el total más barato para cada fecha de salida, y debajo el mismo dato por día de la semana de salida.

![Evolución del precio](guias/img/viajes-app/d_evolucion.jpg)

### Calendario

Un mapa de calor: cada celda es el mejor total saliendo ese día, con los filtros actuales. Verde significa más barato. Sirve para ver de un vistazo qué días de la semana y qué semanas conviene salir.

### Mapa

Cinco mapas, cada uno en su pestaña:

| Pestaña | Qué dibuja |
|---|---|
| Vuelos | Un punto por destino, coloreado por el total más barato con tus filtros. |
| Trenes | Una estación por punto, coloreada por el tren más barato. Todas las estaciones de España que consulta la app. |
| Hoteles | Un punto por alojamiento (su noche más barata), de cientos por destino, con color por precio. |
| Completo | Alojamientos y aeropuertos de los destinos que tienen vuelo y hotel para las mismas fechas. En azul, los alojamientos; en rojo, los aeropuertos. |
| Recorrido | Eliges un tren o un vuelo y ves su ruta sobre el mapa y su viaje en movimiento (botón ▶). |

![Mapa de vuelos](guias/img/viajes-app/d_mapa.jpg)

En los mapas de alojamientos, los puntos de color indican el precio, el aeropuerto va en rojo y las estaciones de tren de tu lista en azul. El trazado del tren se calcula por vía con OpenRailRouting; si no hay conexión con ese servicio, se dibuja una línea recta.

### Distribución

Histogramas de precios: cada barra agrupa vuelos (o trenes, o alojamientos) por precio, y puedes colorearlos por región, por trayecto o sin color, cambiar el número de barras y usar escala logarítmica. Cada vuelo cuenta una sola vez, con su dato más reciente, y se respetan todos los filtros.

### Antelación y volatilidad

Responde a «¿con cuánta antelación sube el precio y cada cuánto conviene volver a mirarlo?». Hace falta histórico: al menos dos descargas del mismo vuelo o alojamiento en momentos distintos. Tiene dos modelos que se eligen con botones:

- **Modelo actual**: compara cada vuelo o alojamiento consigo mismo según los días que faltan para la salida, así descuenta la ciudad y el mes.
- **Modelo con más variables**: además descuenta lo que se mueve el mercado cada día de consulta y la franja horaria. Con muchos alojamientos puede tardar varios minutos; una barra indica el tiempo restante.

Enseña el cambio de precio por tramo de antelación (0 a 2 días, 3 a 6, 7 a 13…, hasta 180 o más), con su margen de error y marcando en rojo los tramos con efecto claro, el momento a partir del cual la antelación deja de importar, la tendencia y la volatilidad diarias, la probabilidad de que un precio suba y una estimación de cuánto pagarías de más si contratas más tarde.

![Antelación y volatilidad](guias/img/viajes-app/d_antelacion.jpg)

> Son estimaciones estadísticas sobre tus propias descargas. Cuantos más datos tengas, más fiables son. Los tramos con menos de 30 comparaciones se marcan como poco fiables.

### Maletas

Una tabla con lo que cobra cada aerolínea por maleta facturada y por maleta de cabina grande, por persona y trayecto. Google Flights no da estos precios, así que son valores orientativos: revísalos en la web de la aerolínea y corrígelos aquí. Se usan al elegir maletas en el filtro de equipaje. «Otras» se aplica a las aerolíneas que no estén en la lista. En trenes se explica qué incluye cada compañía: Renfe incluye equipaje en todas las tarifas y Ouigo lleva cabina en la básica.

### Gestión de datos

Cuánto se ha descargado cada día y cuánto pesa cada fichero. Aquí se decide cuánto histórico conservar:

- Los últimos días (180 por defecto) se guardan con todas las consultas.
- Lo más antiguo se reduce a una fila por vuelo, tren o alojamiento y día.
- Opcionalmente se borra lo que pase de un máximo de días.

Se aplica con los botones «Comprimir» de cada pestaña o con el de «Completo», que lo hace todo a la vez.

### Descargas

Es donde se decide qué precios bajar y cómo. Se puede seguir usando la app mientras descarga.

## Descargar los precios

Cada tipo (vuelos, trenes y hoteles) se descarga en su propio proceso, así que van a la vez. Lo descargado se conserva: si cortas, puedes continuar más tarde desde donde se quedó.

### Vuelos

Eliges destinos, días hacia delante y una velocidad. Hay cinco modos:

| Modo | Qué hace |
|---|---|
| Solo lo que falta | Baja lo que todavía no tienes. |
| Refrescar lo de hace más de 24 h | Vuelve a bajar lo viejo. |
| Solo el próximo mes (refrescar) | Actualiza el mes que viene. |
| Solo los meses que hayan cambiado (sondeo) | Pregunta por unos pocos días de cada mes y baja solo los meses que se han movido. |
| Todo de nuevo | Baja todo otra vez. |

Las velocidades fijan cuántos hilos y consultas por segundo se usan:

| Velocidad | Hilos | Consultas por segundo (al empezar, techo) |
|---|---|---|
| Prudente | 3 | 0,7 a 2 |
| Normal | 6 | 2 a 6 |
| Rápida | 10 | 5 a 10 |
| Máxima | 16 | 8 a 16 |

La app empieza despacio y sube el ritmo mientras no haya bloqueos. Si Google pide un captcha, pausa dos minutos y sigue; si ocurre varias veces, avisa y te sugiere bajar la velocidad.

### Hoteles y trenes

Cuatro botones de un clic: descargar todo, descargar todo con los filtros del buscador, descargar solo lo nuevo y solo lo nuevo con filtros. «Con filtros» usa destino, fechas, día de salida y días de viaje del buscador. Los alojamientos se bajan noche a noche; los trenes, para cada destino y día, ida y vuelta.

- Renfe suele abrir la venta con 2 a 6 meses de antelación; más allá no hay trenes.
- Renfe tarda unos 3 segundos por consulta, así que la primera descarga completa lleva un rato.
- Ouigo no llega a todas las estaciones. La app lo aprende sola: si tras cuatro días seguidos no hay ningún tren Ouigo a un destino (y nunca lo hubo), deja de consultarlo.
- iryo no se consulta: exige un navegador real.

### Descargar todo de varias regiones

Con «Descargar todo de estas regiones», eliges zonas del mundo (Europa, Norte de África, Sudamérica…, según el país del aeropuerto) y la app lanza a la vez las descargas de vuelos, trenes y hoteles. Muestra antes cuántos destinos y consultas son.

![Descargas](guias/img/viajes-app/d_descargas.jpg)

### En el móvil

En Android las descargas corren en un proceso aparte dentro de la app y siguen mientras uses el móvil con ella abierta. Funciona igual que en Windows.

## Los filtros

Los filtros del menú lateral y los de cada página son el mismo: cambiar uno cambia el otro. Se guardan al salir. El botón «Borrar todos los filtros» los deja como al instalar.

| Grupo | Para qué sirve |
|---|---|
| Viaje | Zonas, destinos, aeropuerto concreto, personas, trayecto (ida y vuelta, solo ida o solo vuelta), días de viaje, día de salida, fechas y presupuesto máximo total. |
| Vuelos | Hora de salida de ida y de vuelta, escalas, duración máxima, espera máxima en escala, evitar llegar al día siguiente, solo ciertas aerolíneas o excluir algunas. |
| Equipaje | Maletas facturadas por persona y maleta de cabina grande: se suma al precio la tarifa de cada aerolínea. |
| Alojamiento | Valoración y reseñas mínimas, estrellas, tipo, servicios, precio máximo por noche, distancia al centro andando o en transporte público, distancia a la estación de tren y número de noches. |
| Tren | Tarifa (Básico, Elige, Prémium, Esencial…), flexibilidad, compañía, tipo de tren, horas, duración, solo directos, con plazas y precio máximo. |

El precio típico de una ciudad es la mediana de los N alojamientos más baratos que cumplen los filtros: así dos ciudades se pueden comparar con una «cesta» equivalente.

## Cómo calcula los precios

- **Ida más vuelta**: la app empareja cada ida con la vuelta N días después, para cada duración que hayas elegido, y suma las maletas según las tarifas de cada aerolínea.
- **Alojamiento**: el precio de una estancia de N noches es la suma de las N noches sueltas desde la entrada. Una entrada en viernes cuesta lo que cuesta el viernes, no una media del mes.
- **Viaje completo**: a las combinaciones de vuelos filtradas se les añade el alojamiento de las mismas fechas y destino. Si hay vuelos y hoteles pero no para las mismas fechas, la página te lo dice y te sugiere descargar hoteles de esos días.
- **Trenes**: se toma la tarifa más barata con plazas de cada tren (en Renfe, Básico o Elige; en Ouigo, Esencial). El precio es por persona y trayecto.

## Apariencia y buscador

La paleta abre el panel de apariencia: 10 paletas de color y el modo automático, varios estilos, fondos animados (aurora, constelación, horizonte y otros) y la opción de reducir animaciones. Con Ctrl+K se abre un buscador de páginas y acciones.

## Tus datos

| Qué | Dónde |
|---|---|
| Precios descargados | Carpeta `csv` (vuelos, trenes, hoteles, histórico). Se pueden abrir con Excel. |
| Ajustes y filtros | `config_vuelos.json` |
| Favoritos y alertas | `favoritos.json` y `alertas.json` |
| Rutas de tren | `rutas_tren.json` |

Al actualizar con el instalador nuevo se conservan. Al quitar el programa desde «Aplicaciones» de Windows, tus datos se guardan en una carpeta `Viajes_datos` junto a la del programa.

Los ficheros de datos no deben compartirse sin mirar: contienen tu configuración y tus favoritos.

## Problemas frecuentes

| Qué pasa | Qué hacer |
|---|---|
| «Todavía no hay precios» | Ve a «Descargas» y lanza la primera descarga. Los primeros precios aparecen en cuanto hay ida y vuelta para algún destino. |
| «No hay combinaciones con estos filtros» | Amplía fechas, días de viaje, destinos o presupuesto. |
| La descarga se pausa dos minutos | Google pidió un captcha. Es normal; si pasa a menudo, baja la velocidad. |
| Los trenes salen vacíos | Los trenes solo están disponibles saliendo de Madrid. Con otro origen, esa parte queda vacía. |
| Faltan hoteles para unas fechas | Descarga hoteles de esos destinos y días. |
| Un precio cambió al reservar | Es normal: el precio es el de la descarga. Los enlaces abren la web de la compañía. |
| Windows avisa al abrir el instalador | Es normal en programas sin firma comercial. Pulsa «Más información» y «Ejecutar de todas formas». |
| En el móvil tarda en abrir | La primera vez prepara los cálculos. Las siguientes es más rápido. |

## Versiones y créditos

La versión 2.0.0 estrena una interfaz nueva (la misma de Estadística y de Finanzas Personales), la pantalla «Tu búsqueda», las alertas de precio, los cinco mapas, la versión para Android y un modo ligero para móviles. Antes (1.7.0) funcionaba con un servidor local de Streamlit.

Los datos de vuelos y hoteles vienen de Google Flights y Google Hotels; los de tren, de Renfe y Ouigo; los mapas, de OpenStreetMap. Todos pertenecen a sus propietarios. El código es de Mario (Kuerb0).
