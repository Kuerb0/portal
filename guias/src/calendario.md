titulo: Calendario
subtitulo: Tu calendario de Outlook en el escritorio de Windows, con avisos, alarmas y correo
version: 2.0.1
icono: img/iconos/calendario.png
color: #2f6fe0
color_oscuro: #2352a8

## Qué es esta app

Calendario es un widget: una ventana que vive en el escritorio de Windows y enseña tu calendario de Outlook siempre a la vista. No sustituye a Outlook; lo lee y le añade cosas que Outlook no tiene en el escritorio: varias vistas a la vez, avisos y alarmas con sonido por evento, cuentas atrás, hábitos, cumpleaños y el correo en una columna.

![El widget con eventos de ejemplo](guias/img/calendario/captura.jpg)

Lo que hace:

- Muestra tus eventos en una rejilla por horas, en una lista, en las dos a la vez o en un mes completo.
- Te avisa antes de cada evento y puede sonar una alarma a la hora que elijas.
- Marca los festivos de tu comunidad autónoma y de tu municipio.
- Deja crear, cambiar, mover y borrar eventos sin abrir Outlook.
- Enseña los correos recientes dentro del propio widget.
- Cuenta cuántos días faltan para los eventos que fijes.
- Es software libre (licencia GPL 3).

## Instalación

1. Descarga el instalador desde el botón «Instalador» del portal.
2. Ábrelo. Si Windows avisa de que no conoce al editor, pulsa «Más información» y luego «Ejecutar de todas formas».
3. Elige la carpeta y los accesos directos que quieras.
4. Se abre el asistente de configuración. Cuando lo guardes, aparece el widget en el escritorio.

No hace falta ser administrador, ni tener Python, ni internet (salvo que uses el enlace ICS). Para instalar una versión nueva, ejecuta el instalador nuevo encima: conserva tu configuración y tus perfiles.

### Qué necesitas

Windows 10 u 11 y una fuente de eventos. Hay dos, y las puedes tener a la vez:

| | Outlook instalado | Enlace ICS publicado |
|---|---|---|
| Etiquetas de Outlook con su color | Sí | No, Outlook.com no las exporta |
| Actualización | Inmediata | Con retardo (Microsoft guarda una copia del ICS) |
| Qué necesita | El Outlook clásico, con tu cuenta | Solo el enlace |
| Crear y cambiar eventos | Sí | No: es de solo lectura |

El Outlook nuevo (`olk.exe`) no admite automatización, así que para leerlo directamente hace falta el clásico. Si el origen que elijas falla, el widget cae en el otro y lo anota en el registro.

## El asistente de configuración

Se abre la primera vez y se puede volver a abrir cuando quieras. Tiene tres apartados y cada uno lleva un enlace azul que abre las instrucciones paso a paso.

1. **De dónde leer los eventos.** Con Outlook instalado, te lista los calendarios que encuentra y cuántos elementos tiene cada uno. Con el enlace ICS, te explica cómo conseguirlo.
2. **Festivos.** Tu comunidad autónoma y, si quieres, los dos festivos de tu municipio.
3. **Cómo verlo.** Días a la vista, tema y antelación de los avisos.

### Conseguir el enlace ICS

Es una dirección que Outlook genera para que otros programas puedan leer tu calendario. Solo permite leer, nunca escribir, y puedes anularlo cuando quieras.

1. Entra en `outlook.live.com/calendar` con tu cuenta.
2. Arriba a la derecha, pulsa el engranaje (Configuración).
3. Ve a Calendario y luego a Calendarios compartidos.
4. En «Publicar un calendario», elige el calendario que quieres mostrar.
5. En permisos, elige «Puede ver todos los detalles». Con menos, el widget solo vería los huecos ocupados, sin títulos.
6. Pulsa «Publicar». Aparecen dos enlaces: copia el que termina en `.ics` (el que acaba en `.html` no sirve).
7. Pégalo en el asistente.

> El enlace permite leer todo tu calendario a quien lo tenga. No lo compartas.

## Las vistas

El botón de vistas de la barra alterna entre cuatro formas de ver lo mismo:

| Vista | Qué enseña |
|---|---|
| Cal | La rejilla por horas, con una columna por día. |
| Lista | Una lista por días, con las tareas y la duración de cada cita. |
| Ambas | Rejilla y lista juntas. Una barra entre las dos se arrastra para repartir el espacio. |
| Mes | El mes completo. |

En la rejilla puedes elegir cuántos días ver: 1, 3, 5, 7, 14 o 21, o cualquier número hasta 365 con el botón `…`. También hay una orientación vertical (días en filas) y otra horizontal. Al cambiar de días la ventana no crece: las columnas se reparten el sitio que ya ocupaba.

La lista puede ir a la derecha, a la izquierda, arriba o abajo del calendario.

### La barra de arriba

| Botón | Qué hace |
|---|---|
| ✕ | Cierra el widget del todo. |
| ‹ › | Va a los días anteriores o siguientes. |
| hoy | Vuelve a hoy. |
| 1, 3, 5, 7, 14, 21 | Cuántos días se ven. |
| Fest | Enciende o apaga cada grupo de festivos. |
| + | Crea un evento. |
| Buscar | Busca eventos por título. |
| Hora | A qué hora empieza y acaba lo que se ve, cada cuántos minutos van las rayas (10, 15, 20, 30, 60, 120 o los que escribas) o ajustarlo a tus eventos. |
| Fondo, Normal, Encima | Si el widget queda detrás de las ventanas, como una ventana más o por encima de todo. |
| 👤 | El perfil activo (ver «Perfiles»). |
| Actualizar y ocultar | Vuelve a leer los eventos o esconde el widget. |

Si la ventana es estrecha, los botones que no caben pasan al menú del botón `⋯`. Al dejar el ratón quieto sobre un botón aparece una explicación breve.

### La franja de abajo

Muestra lo que está pasando ahora y lo siguiente, con una cuenta atrás. Al pulsarla ves el detalle.

## Eventos

### Crear un evento

- Con el botón `+` se abre una ficha con título, día, horas, todo el día, lugar, etiqueta y notas. La ficha guarda el evento directamente en Outlook.
- **Doble clic** en un hueco de la rejilla crea ahí un evento (esta opción viene desactivada; se enciende en el clic derecho).
- **Pintar con el ratón** sobre la rejilla vacía abre la ficha con esas horas ya puestas.
- Hay atajos de duración (15 minutos, 30, 1 hora, 1 hora y media, 2 horas) y de correr el evento un día adelante o atrás.
- Un selector de repetición ofrece todos los días, de lunes a viernes, cada semana, cada dos semanas, cada mes y cada año, y luego pregunta hasta qué fecha o cuántas veces.
- En «Etiqueta» y «Dónde» hay un desplegable con lo que ya has usado.

> Crear y cambiar eventos necesita el Outlook clásico. Con el enlace ICS, el calendario es de solo lectura, y los eventos que se repiten se siguen cambiando desde Outlook.

### Cambiar, mover y alargar

- **Doble clic** sobre un evento (o clic derecho y «Cambiar este evento…») abre la misma ficha ya rellena.
- **Arrastrar** un evento dentro de la rejilla lo cambia de hora o de día y lo guarda en Outlook. Sale un aviso con «deshacer». Esta opción se apaga en el clic derecho.
- **Arrastrar el borde de abajo** de un evento lo alarga o lo acorta (el de la derecha, en la vista vertical).

### Clic derecho sobre un evento

| Opción | Qué hace |
|---|---|
| Alarma antes… | Pone una alarma (ver «Avisos y alarmas»). |
| Tachar | Lo marca como hecho: se queda gris y tachado, sin tocar nada en Outlook. |
| Posponer | +15 minutos, +30, +1 hora, mañana o la semana que viene. |
| Etiqueta y color | Cambia la etiqueta y el color. |
| Ocupado, provisional o libre | Cambia cómo aparece en tu agenda. |
| Duplicar | Crea una copia. |
| Guardar como plantilla | Lo guarda para crear otros iguales. |
| Eliminar | Pregunta antes y lo manda a «Elementos eliminados» de Outlook, así que se puede recuperar. |
| Copiar y filtrar por etiqueta | Copia el evento o deja solo los de su etiqueta. |

### Plantillas

Desde el clic derecho en el fondo, «Crear desde una plantilla…» levanta en dos clics los eventos de siempre, con título, duración, lugar y etiqueta ya puestos.

### Tareas locales

En la lista, el botón `+` junto a un día o una fila crea una tarea privada, sin abrir Outlook. La casilla de la izquierda la completa; `!` indica prioridad alta y `·` prioridad baja. Las urgentes salen en rojo, las normales en naranja y las de prioridad baja en azul. Se guardan en tu configuración, no en Outlook, y no se pierden al actualizar los eventos.

Desde el clic derecho puedes filtrar (todas, pendientes o completadas), activar el modo concentración (solo lo que queda por hacer) y completar de una vez las tareas cuyo horario ya terminó.

## Avisos y alarmas

Hay dos tipos y no se pisan.

### Avisos antes de cada evento

El widget enseña un aviso propio en la esquina, además de la notificación de Windows. Se elige con cuánta antelación (por ejemplo, 60 y 10 minutos antes) en el asistente o en el Panel de control. Los eventos de todo el día tienen su propia hora de aviso, que también se puede quitar.

### Alarmas por evento

Clic derecho en un evento, «Alarma antes…» y eliges 5, 10, 20, 30 o 60 minutos, u otro número. Puedes poner varias en el mismo evento. Al llegar la hora suena la alarma, el calendario se pone encima de todo y sale un aviso grande. Si lo pulsas, te lleva al evento.

### Sonido

El sonido de los avisos se elige en el clic derecho, «Datos y avisos», «Avisos y barra de abajo». Sirve tanto para alarmas como para los avisos de antes. Puedes usar sonidos de Windows, un archivo `.wav` tuyo o ninguno.

## Festivos

Se marcan los festivos nacionales, los de tu comunidad autónoma y, si quieres, los dos de tu municipio (fechas fijas cada año). El botón `Fest` de la barra los enciende y apaga uno a uno.

## Correo dentro del widget

Si usas el Outlook clásico, puedes ver el correo como una columna a la derecha del widget (botón ✉, o clic derecho, o Panel de control). Enseña los correos recientes de todas las carpetas mezclados, con remitente, asunto y hora, y una barra del color de su carpeta (sólida si está sin leer). No sale en la vista de mes.

- **Filtrar por carpeta**: pulsa el chip de una carpeta para ver solo esa; vuelve a pulsarlo para soltarla. «Todas» las enseña todas y «Sin leer» deja solo los no leídos.
- **Excluir carpetas**: clic derecho en el chip, o desde el Panel de control. Las excluidas no salen, y un aviso permite volver a incluirlas.
- **Sobre un correo**: un clic lo lee sin salir del widget. Clic derecho para marcarlo leído o no leído, ponerle bandera, responder, reenviar, archivar, moverlo a otra carpeta, eliminarlo (va a «Elementos eliminados»), crear un evento o una tarea con él o abrirlo en Outlook.
- **Acciones de arriba**: ✎ escribe un correo nuevo, ✓✓ marca como leído todo lo que se ve y 🗀 elige qué carpetas se leen.
- El ancho se cambia arrastrando el borde de la columna; con doble clic vuelve a su ancho por defecto.

### El aviso «un programa intenta obtener acceso…»

Ese cartel lo saca el propio Outlook cuando un programa lee el cuerpo de una cita. Por eso el widget no lee las notas de los eventos de serie. Si las quieres, actívalas en clic derecho, «Leer los eventos de» y «Leer también las notas»; entonces Outlook puede avisar. Si te sale igual, depende de Windows: suele deberse a que no ve un antivirus al día. Se puede ajustar en Outlook, en Archivo, Opciones, Centro de confianza, «Acceso mediante programación».

## Hábitos y cumpleaños

- **Hábitos**: una rejilla de casillas por día que marcas a mano. Se ven unos días antes y después de hoy, y puedes ver puntitos en la vista de mes y recibir un recordatorio para marcarlos.
- **Cumpleaños**: los que guardes salen como eventos de todo el día, cada año.

## Cuentas atrás

Sirven para ver cuántos días faltan para algo que te importa. Hay dos formas:

- **Cuentas atrás**: en el Panel de control, pestaña «Cuenta atrás», pones un nombre y un día (DD/MM/AAAA). Cada una sale con su color: rojo de 0 a 5 días, ámbar de 6 a 10 y verde si quedan más de 10; gris si ya pasó. El botón ⏳ de la barra las muestra.
- **Evento fijado**: un evento que fijas abajo del calendario, con una estrella y el tiempo que falta.

Desde la versión 2.0.1, las cuentas atrás y el evento fijado siguen al evento si lo mueves en el calendario. La app lo reconoce por su identificador: tras cada actualización, si el evento ha cambiado de día, la cuenta atrás cambia con él. En una serie repetida, solo sigue al evento si el más cercano es uno y se ve claro (a menos de una semana). Si el evento se borra o sale de los días que se descargan, la cuenta se queda como estaba.

## El Panel de control

Se abre con el botón ⚙ o con clic derecho y «Panel de control…». Tiene ocho pestañas:

| Pestaña | Para qué sirve |
|---|---|
| Vista | Vista, días, orientación, nivel, tema, tamaño y transparencia. |
| Barra | Qué botones salen arriba y su tamaño (pequeña, media o grande). Los de días, actualizar y ocultar no se pueden quitar. |
| Avisos | La campana, la antelación y la hora de los avisos de todo el día. |
| Agenda | Origen de los eventos, calendarios y festivos. |
| Correo | La bandeja y la gestión de las reglas de Outlook: activar, desactivar, ejecutar ahora y eliminar. |
| Eventos | Los próximos 30 días con buscador y filtro por calendario, y listas de solapes y de eventos repetidos. El menú `⋯` de cada fila permite ir a su día, editar, abrir en Outlook, posponer o eliminar. |
| Cuenta atrás | Los eventos a los que quieres contarles los días (ver «Cuentas atrás»). |
| Sistema | Arranque con Windows, perfiles, copia de la configuración, carpetas y dónde se abre cada panel. |

Los paneles (control, paleta, correo, hábitos, cumpleaños, plantillas y tareas permanentes) pueden ir en una ventana aparte o anclados a la izquierda o a la derecha del widget, siguiéndolo cuando se mueve.

## La paleta de comandos

Con el botón ⌘ o con **Ctrl+K**. Escribe lo que quieras hacer y pulsa Intro: cambiar de vista o de días, abrir un panel, cambiar de perfil, activar los avisos, ir a una fecha (`18/9`, `mañana`) o saltar a un evento por su título.

## Perfiles

Si varias personas comparten la carpeta, cada una guarda sus datos de cuenta en un perfil y se cambia de uno a otro sin volver a escribir nada.

- Arriba a la derecha de la barra pone el perfil en el que estás (por ejemplo, `👤 Ana`). Al pulsarlo sale el menú de perfiles.
- «Guardar estos datos como perfil nuevo…» crea el perfil con tu nombre y abre el asistente para rellenar sus datos.
- Al elegir otro perfil, el widget guarda el actual, carga el nuevo y vuelve a leer el calendario.

Un perfil solo guarda lo que cambia de una persona a otra: el origen de los eventos, el enlace ICS, los calendarios de Outlook, los festivos y la zona horaria. El tamaño, las vistas, los colores y los avisos son comunes a la carpeta.

## Atajos y gestos

| Atajo | Qué hace |
|---|---|
| F5 | Actualiza el calendario y vuelve a descargar los eventos. |
| Ctrl+Alt+C | Muestra u oculta el widget desde cualquier aplicación (se puede cambiar). |
| Ctrl+K | Abre la paleta de comandos. |
| Rueda del ratón | Cambia de días. Sobre la columna de horas, mueve el horario. |
| Ctrl + rueda | Escala el tamaño del widget. |
| Ctrl+Mayús + rueda | Cambia el tamaño de la letra. |

El icono de la bandeja del sistema muestra u oculta el widget con un clic, y su menú de clic derecho incluye «No la encuentro: traerla al centro», por si la ventana quedó fuera de la pantalla.

## Tus datos

| Qué | Dónde |
|---|---|
| Tu configuración, tareas locales, cuentas atrás y avisos | `config.json` en la carpeta de datos del programa (con una copia `config.json.bak`) |
| Perfiles | Carpeta `perfiles` junto a la configuración |
| Caché de eventos, registro de errores | `%LOCALAPPDATA%\WidgetCalendario` (fuera de OneDrive) |

Nada se envía a ningún sitio. Si compartes la carpeta del programa, no incluyas la de datos: lleva tu enlace ICS y deja leer tu calendario entero a quien lo tenga.

### Claves útiles de la configuración

| Clave | Qué hace |
|---|---|
| `origen` | `"ics"`, `"outlook"` o `"auto"`. |
| `avisos_minutos` | Antelación de los avisos, por ejemplo `[60, 10]`. |
| `aviso_todo_dia` | Hora del aviso de lo que dura todo el día (`null` lo quita). |
| `dias_cache_adelante` | Cuántos días se descargan para poder navegar. |
| `atajo_global` | Atajo para mostrar u ocultar, por ejemplo `"ctrl+shift+k"`. |
| `crear_con` | Con qué se crean los eventos: `"auto"`, `"nuevo"` o `"outlook"`. |
| `escala` | Tamaño general, de 0.7 a 2.0. |

## Si algo va mal

1. Cierra el widget del todo: icono de la bandeja, «Salir». Abrir el acceso directo estando ya abierto solo lo muestra u oculta.
2. Mira `registro.txt` en `%LOCALAPPDATA%\WidgetCalendario`: guarda los errores, la posición de la ventana y de dónde se han leído los eventos.
3. Vuelve a ejecutar el instalador en la misma carpeta: lo que ya estaba instalado no se repite y tus datos no se tocan.

| Qué pasa | Qué hacer |
|---|---|
| No veo el widget | Icono de la bandeja, clic derecho, «No la encuentro: traerla al centro». |
| No salen mis eventos | Comprueba el origen en el asistente. Con Outlook, tiene que ser el clásico. Con ICS, el enlace debe terminar en `.ics`. |
| Los eventos tardan en cambiar | Con el enlace ICS, Microsoft guarda una copia con retardo. Con Outlook instalado es inmediato. |
| No puedo crear ni mover eventos | Hace falta el Outlook clásico. Con el enlace ICS el calendario es de solo lectura. |
| Windows avisa al abrir el instalador | Es normal en programas sin firma comercial. Pulsa «Más información» y «Ejecutar de todas formas». |

## Versiones y créditos

**2.0.1**: las cuentas atrás y el evento fijado siguen al evento cuando se mueve en el calendario. **2.0**: alarmas por evento, sonido de los avisos, modo «solo en este escritorio virtual» y la raya blanca de inicio de semana.

Calendario es software libre bajo la licencia GNU GPL v3: puedes usarlo, estudiarlo, modificarlo y compartirlo, y las versiones modificadas que publiques deben seguir siendo libres bajo la misma licencia. El código es de Mario (Kuerb0).
