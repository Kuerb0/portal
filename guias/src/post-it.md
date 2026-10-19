titulo: Post-It
subtitulo: Notas adhesivas para el escritorio de Windows, con tareas que se repiten solas
version: 1.0.1
icono: img/iconos/post-it.png
color: #d9a400
color_oscuro: #8f6d00

## Qué es esta app

Post-It pone notas adhesivas sueltas en el escritorio de Windows. Cada nota es su propia ventana: la mueves, le cambias el tamaño y el color, y escribes en ella como en un papel amarillo. La diferencia con un bloc de notas es que sabe de tareas: cada línea puede llevar una casilla y algunas se vuelven a poner solas cuando toca (la de regar las plantas cada día, el informe cada lunes).

![Una nota con tareas](guias/img/post-it/tareas.png)

Lo que hace:

- Notas de colores, tantas como quieras, cada una en su ventana sin marco.
- Tareas con casilla, que pueden repetirse a diario, a la semana, al mes o un día concreto.
- Líneas periódicas que se copian bajo las fechas que escribas en la nota.
- Notas translúcidas, o que se quedan por encima o por debajo del resto de ventanas.
- Texto con formato (negrita, cursiva, subrayado, tachado, resaltado, títulos y listas).
- Modo de columnas, para notas largas.

## Instalación

1. Descarga el instalador desde el botón «Instalador» del portal (unos 160 MB, porque lleva su propio motor).
2. Ábrelo. Si Windows avisa de que no conoce al editor, pulsa «Más información» y luego «Ejecutar de todas formas».
3. Elige la carpeta y los accesos directos.
4. Al terminar se crea el acceso directo «Post-it» y la app arranca.

No hace falta Node.js ni internet. Para instalar una versión nueva, ejecuta el instalador nuevo encima: conserva tus notas.

### Arranque con Windows

La app se registra para abrirse sola al iniciar sesión, así que tus notas están siempre en el escritorio. No hay un ajuste para desactivarlo desde la app; si no lo quieres, quítala de «Aplicaciones de inicio» en la configuración de Windows.

### La bandeja del sistema

Post-It vive en la bandeja, junto al reloj, con un icono propio. Cerrar todas las notas no cierra la app. Un clic en el icono muestra todas las notas. Con clic derecho aparece un menú:

| Opción | Qué hace |
|---|---|
| Nueva nota | Crea una nota nueva con un color al azar. |
| Mostrar todas | Abre de nuevo las notas que hayas cerrado. |
| Salir | Cierra la app del todo. |

Si lanzas la app estando ya abierta, no abre una segunda copia: solo te enseña las notas.

## La primera nota

La primera vez que arranca, la app crea una nota de bienvenida con un par de ejemplos: una tarea que se repite a diario y otra los lunes. Puedes borrarla cuando quieras.

## Una nota por dentro

Cada nota es una ventana sin marco, de 340 por 340 píxeles al principio. Se arrastra desde la barra de arriba y se redimensiona desde los bordes.

### La barra de arriba

De izquierda a derecha:

| Botón | Qué hace | Atajo |
|---|---|---|
| Más | Nueva nota | Ctrl+N |
| Columnas | Reparte el texto en 2, 3, 4 o 5 columnas, o las quita | Ctrl+Mayús+K |
| Translúcida | Pone la nota semitransparente (65 % de opacidad, texto incluido) | Ctrl+Mayús+G |
| Posición | Alterna entre normal, encima de todo y debajo de las demás ventanas | Ctrl+Mayús+P |
| Color | Abre el selector de color | Ctrl+Mayús+C |
| Atajos | Muestra la lista de atajos | F1 |
| Papelera | Elimina la nota | |
| Cerrar | Cierra la ventana, sin borrar la nota | Ctrl+W |

Un botón se queda marcado mientras su opción está activa.

### La barra de abajo

Aplica formato al texto: negrita (Ctrl+B), cursiva (Ctrl+I), subrayado (Ctrl+U), tachado (Ctrl+T), resaltado (Ctrl+Mayús+H), título (Ctrl+Mayús+1), tarea con casilla, línea periódica, varias fechas, viñetas, lista numerada, sangría y quitar formato (Ctrl+Espacio). Los botones de formato se iluminan cuando el cursor está sobre texto que ya lo tiene.

### Color

Las notas nuevas salen con uno de seis colores pastel (amarillo, melocotón, verde, azul, rosa y lila). Con el botón de color eliges cualquier otro con el selector de Windows; la nota cambia en vivo mientras arrastras y se guarda al cerrar el selector.

### Posición, translúcida y columnas

- **Posición**: «normal» es una ventana más. «Encima de todo» la deja siempre visible. «Debajo» la manda al fondo, tras las demás ventanas, y vuelve al fondo en cuanto dejas de usarla.
- **Translúcida**: sirve para tener la nota sobre otra cosa (una hoja de cálculo, un vídeo) y verla a través.
- **Columnas**: el texto que no cabe por abajo pasa a la columna de la derecha, hasta el máximo que elijas y según el ancho de la nota.

### Eliminar una nota

El botón de la papelera elimina la nota. Si tiene texto, pide confirmación. Si está vacía, se borra sin preguntar. Cerrar con la X no elimina nada: la nota sigue guardada y vuelve con «Mostrar todas».

## Escribir y dar formato

La nota guarda el texto con su formato, pero no admite pegar formato: al pegar, entra solo el texto sin estilos, para que no se cuele nada raro de otra web o de Word.

![Lista de atajos de teclado (F1)](guias/img/post-it/atajos.png)

Atajos útiles:

| Atajo | Qué hace |
|---|---|
| Ctrl+Enter | Crea una tarea o la marca |
| `- ` o `[] ` al inicio de línea | Convierte la línea en tarea |
| `* ` al inicio de línea | Viñetas |
| `1. ` al inicio de línea | Lista numerada |
| Tab y Mayús+Tab | Sangría y quitar sangría |
| Alt+↑ y Alt+↓ | Mover la línea (o las líneas seleccionadas) |
| Ctrl+Mayús+8 y Ctrl+Mayús+7 | Viñetas y numerada |

## Tareas

Una tarea es una línea con casilla. Se crea escribiendo `- ` (guion y espacio) al inicio, o `[] `, o pulsando Ctrl+Enter. Con Enter al final de una tarea, la línea siguiente también es tarea; con Enter en una tarea vacía, sales de la lista.

Con Ctrl+Enter sobre varias líneas seleccionadas, a las que no tienen casilla se la pone; si todas la tienen, marca las pendientes, o las desmarca si estaban todas hechas.

Una tarea marcada queda tachada y más clara.

### Tareas que vuelven a salir

Si escribes una etiqueta en la línea de una tarea, al marcarla se desmarcará sola cuando toque:

| Etiqueta | Cuándo vuelve |
|---|---|
| `@diario` | Al día siguiente |
| `@semanal` | A los 7 días |
| `@mensual` | Al mes siguiente, el mismo día |
| `@lunes` … `@domingo` | El próximo día de la semana que indiques |
| `@cada3d` | A los N días (cambia el 3 por el número que quieras) |

Al marcar la casilla aparece un aviso «vuelve» con la fecha. La app revisa esas fechas al abrir la nota y cada minuto; cuando llega el día, la casilla se desmarca sola.

> Ejemplo: `regar las plantas @diario` se marca hoy y mañana vuelve a aparecer sin marcar. `informe @lunes` se marca el viernes y reaparece el lunes.

## Líneas periódicas y fechas

Esta parte sirve para planificar varios días en una sola nota. Escribes cabeceras de fecha (una línea que es solo una fecha, como `19/10`, `20-10` o `Lunes 19/10`) y una tarea marcada como periódica se copia sola bajo cada fecha.

![Una línea periódica con sus fechas](guias/img/post-it/periodicas.png)

### Cómo se usa

1. Escribe una tarea y pulsa el botón de repetir (o Ctrl+Mayús+R) para marcarla como periódica. Aparece un icono de flechas junto a la casilla. Con otro clic en el icono, deja de ser periódica.
2. Escribe más abajo las cabeceras de fecha. Si la cabecera no lleva día de la semana, la app lo añade («14/10» pasa a «Miércoles 14/10»).
3. La tarea se copia, sin marcar, bajo cada fecha que haya más abajo.

La copia no se duplica: si la tarea ya está bajo esa fecha, no se vuelve a añadir.

### Reglas para elegir cuándo

Sin regla, la tarea se copia bajo todas las fechas. Con una regla escrita en la propia línea, solo bajo las que cumplan:

| Escribe en la línea | Se copia |
|---|---|
| `cada 3 días` | Cada tres días desde la fecha de origen |
| `cada semana` o `cada 2 semanas` | Cada 7 o 14 días |
| `cada mes` | El mismo día de cada mes |
| `cada lunes` o `cada 2 lunes` | Cada lunes, o uno de cada dos |

### Añadir varias fechas de golpe

El botón del calendario (Ctrl+Mayús+D) abre una fila con botones: +2, +3, +5, +7, +14 y +30 días. Añaden esa cantidad de cabeceras de fecha seguidas, empezando desde la última fecha que haya en la nota (o desde hoy si no hay ninguna), y rellenan con las tareas periódicas que correspondan.

## Datos y sincronización

| Qué | Dónde |
|---|---|
| Tus notas (texto, color, posición, columnas, translúcida) | `notes.json`, en la carpeta del programa |
| Posición y tamaño de cada ventana | `pos.json`, en la carpeta de datos de la app de Windows |

La app guarda sola unos 0,4 segundos después de que dejes de escribir. No hay botón de guardar.

Las notas no se envían a ningún sitio y no hay cuenta. Si instalas el programa en una carpeta que ya se sincroniza (por ejemplo, dentro de OneDrive), el fichero `notes.json` viaja con ella y la app recarga las notas cada pocos segundos cuando otro equipo las cambia. Si no, cada equipo tiene sus notas.

Al actualizar con el instalador nuevo se conservan las notas. Para quitar la app, usa «Aplicaciones» de Windows: el instalador deja registrado un desinstalador.

## Problemas frecuentes

| Qué pasa | Qué hacer |
|---|---|
| Cerré una nota y no la encuentro | No se borra al cerrar. Clic en el icono de la bandeja, o clic derecho y «Mostrar todas». |
| No veo el icono de la bandeja | Puede estar en la flecha de «iconos ocultos» junto al reloj. |
| Una nota se quedó debajo de otras ventanas | Está en posición «debajo». Pulsa el botón de posición para volver a «normal». |
| Una tarea no vuelve a salir | Comprueba la etiqueta (`@diario`, `@lunes`…) y que esté en la misma línea que la casilla. |
| El texto pegado no trae formato | Es a propósito: se pega solo el texto. |
| Windows avisa al abrir el instalador | Es normal en programas sin firma comercial. Pulsa «Más información» y «Ejecutar de todas formas». |

## Versiones y créditos

Versión 1.0.1. Cambia respecto a la 1.0.0: el cursor del texto se ve ahora sobre cualquier fondo (una I blanca con contorno negro), porque con las notas oscuras o translúcidas parecía desaparecer.

Post-It está hecha con Electron (Chromium y Node.js). El código es de Mario (Kuerb0).
