titulo: Administrador de Tareas+
subtitulo: Un registro del uso del PC, programa a programa, a lo largo del tiempo
version: 1.4.0
icono: img/iconos/logeador.png
color: #0e8f9c
color_oscuro: #0a6b75

## Qué es esta app

El Administrador de Tareas de Windows te dice qué está pasando ahora. Administrador de Tareas+ te dice qué pasó antes: apunta cada pocos segundos cuánto usa de procesador, memoria, disco y tarjeta gráfica cada programa, lo guarda y te lo enseña en gráficos. Así puedes saber qué programa se comió el procesador mientras no mirabas, quién gasta más memoria a lo largo de una hora o cuánto pesa cada cosa en tu día.

Antes se llamaba Logeador. Ahora se llama Administrador de Tareas+, aunque por dentro algunas cosas (la carpeta de datos, el nombre del archivo del programa) conservan el nombre antiguo para que al actualizar no se pierda tu historial.

![Pestaña Procesos](img/logeador-1.jpg)

Mide cuatro cosas por programa:

| Medida | Qué es |
|---|---|
| CPU | Porcentaje del procesador total. Como en el Administrador de Tareas, 100 % es todo el procesador. |
| RAM | Memoria que usa el programa, en MB (o en % de la RAM total). |
| E/S | Lo que lee y escribe en disco, en MB por segundo. |
| GPU | Porcentaje de la tarjeta gráfica. De cada programa se toma su motor más cargado (3D, vídeo, copia…), igual que el Administrador de Tareas. |

## Instalación

1. Descarga el instalador desde el botón «Descargar para Windows» del portal.
2. Ábrelo. Si Windows avisa de que no conoce al editor, pulsa «Más información» y luego «Ejecutar de todas formas».
3. Elige la carpeta y los accesos directos.
4. Abre «Administrador de Tareas+» desde el acceso directo. Empieza a registrar en cuanto abre.

No necesita permisos de administrador, Python ni internet. Para actualizar, ejecuta el instalador nuevo encima: conserva todo el historial y tus ajustes.

> El programa solo registra mientras está abierto. Si lo cierras, no se anota nada. Para tener un historial continuo, déjalo abierto (puedes minimizarlo) o ponlo en el inicio de Windows.

### Una sola copia

Solo puede haber una ventana abierta. Si intentas abrirlo de nuevo, un aviso dice «Administrador de Tareas+ ya está abierto.» Así no se duplican las muestras.

## La ventana

Arriba hay una barra de controles que se ve en todas las pestañas, y debajo tres pestañas: Procesos, Distribución y Estadísticas.

| Control | Qué hace |
|---|---|
| Rango | El periodo que se muestra: 1 min, 2 min, 5 min, 15 min, 1 hora, 24 horas, 7 días o Todo. |
| Registrar cada | Cada cuánto se guarda una muestra: 5 s, 15 s, 30 s, 1 min, 2 min o 5 min. |
| Ver | Casillas CPU, RAM, E/S y GPU: qué medidas se ven. Siempre queda al menos una. |
| RAM en % | Cambia la RAM de MB a porcentaje de la memoria total. |
| Color… y Quitar color | Elige o quita el color del programa seleccionado. |
| Modo oscuro | Cambia entre tema claro y oscuro. |

Todo lo que cambies aquí se recuerda al volver a abrir.

## Pestaña Procesos

A la izquierda, una tabla con todos los programas que hay en marcha ahora, con su CPU, RAM, E/S, GPU y número de instancias. Se actualiza cada 5 segundos. A la derecha, la evolución en el tiempo de lo que selecciones.

![Procesos: tabla en vivo y gráficos](img/logeador-1.jpg)

### Qué es una fila

Los programas se agrupan por nombre. Si Chrome tiene doce procesos abiertos, aparece una sola fila «chrome.exe» con la suma de todos y en la columna «Instancias» el número 12. La fila «[Sistema total]» es la del ordenador entero.

### Ordenar y seleccionar

- Un clic en el título de una columna ordena por ella; otro clic invierte el orden.
- Selecciona un programa para ver su gráfico. Con Ctrl o Mayús seleccionas varios para compararlos (hasta ocho a la vez).
- Al abrir, el gráfico muestra el sistema total.

### Los gráficos

Hay un panel por cada medida que tengas activada, uno encima de otro, con el mismo eje de tiempo. Cada programa conserva siempre su color, en esta pestaña y en las demás. Una leyenda a la derecha dice quién es quién.

### Colores

Cada programa recibe un color la primera vez que sale en un gráfico, y lo conserva para siempre. Para cambiarlo, selecciona el programa y pulsa «Color…» (o haz doble clic en su fila). «Quitar color» devuelve el automático.

## Pestaña Distribución

Responde a «¿quién consume qué?». Dibuja, para cada medida, una gráfica apilada: cada programa es una banda de su color y el alto total es lo que consume el sistema.

![Distribución](img/logeador-2.jpg)

- **Procesos mostrados**: 5, 8, 12 o 20. Los programas que consumen más en el periodo salen con su propia banda; el resto se suma en una banda gris llamada «Otros».
- **Normalizar al 100 %**: en vez de valores absolutos, cada instante se reparte entre el 0 y el 100 %. Sirve para ver quién pesa más en cada momento aunque el total suba y baje.
- **Leyenda con números**: a la derecha, cada programa lleva su media del periodo (o su cuota del total si normalizas). Las bandas lo bastante gruesas llevan además el número escrito encima.

El orden de las bandas es el del total del periodo, de mayor a menor, y es el mismo en la leyenda. Así las capas no se cruzan ni saltan.

## Pestaña Estadísticas

Una tabla con los números de cada programa durante el rango elegido.

![Estadísticas](img/logeador-3.jpg)

| Columna | Qué es |
|---|---|
| CPU prom % y CPU máx % | Media y máximo de procesador. |
| RAM prom y RAM máx | Media y máximo de memoria, en MB o en %. |
| E/S prom MB/s | Media de lectura y escritura en disco. |
| GPU prom % y GPU máx % | Media y máximo de la tarjeta gráfica. |
| Minutos visto | Cuánto tiempo estuvo ese programa en el registro. |

Las estadísticas se recalculan al abrir la pestaña, no solas. Como los programas casi inactivos no se guardan (ver abajo), los promedios son sobre el tiempo en que estuvieron activos.

## Cómo funciona por dentro

### Cuándo y qué se mide

Cada 5 segundos, la app lee el estado de todos los programas. Cada muestra cuesta unos 0,4 segundos de procesador en total, por eso no se baja de ahí. La tabla en vivo se actualiza con esas lecturas.

Lo que se guarda en la base de datos es la media de cada intervalo de registro, ponderada por el tiempo de cada muestra. Con «Registrar cada 1 min», se guarda una fila por programa por minuto, que es la media de las 12 muestras de cinco segundos de ese minuto.

### Qué se guarda y qué no

Para que la base de datos no crezca sin control, solo se guardan los programas que superan un umbral en ese intervalo:

- Más del 0,5 % de CPU, o
- más de 50 MB de RAM, o
- más del 0,5 % de GPU.

El sistema total se guarda siempre. Por eso un programa que apenas hace nada no aparece en los gráficos ni en las estadísticas. En la tabla en vivo sí aparecen todos.

### Cuánto tiempo se guarda

Al arrancar, la app borra lo que tenga más de 30 días. Por eso el rango «Todo» llega, como mucho, a 30 días atrás.

### Cómo se mide cada cosa

- **CPU**: el porcentaje de cada programa se divide entre el número de núcleos, para que 100 % sea todo el procesador.
- **RAM**: la memoria residente del proceso (la que tiene en la RAM). La del sistema es la memoria usada total.
- **E/S**: bytes leídos y escritos por cada proceso entre dos muestras, divididos entre el tiempo. La del sistema sale del contador de disco de Windows, así que no incluye red ni tuberías.
- **GPU**: el contador de rendimiento «GPU Engine» de Windows, sin necesidad de ser administrador. Si tu equipo no tiene ese contador (sin GPU o Windows muy viejo), la columna de GPU sale vacía y todo lo demás sigue funcionando.

### Por qué «Otros» no siempre cuadra

En CPU y RAM, «Otros» es el total del sistema menos lo que se muestra. En E/S y GPU es la suma de los programas restantes, porque el disco del sistema no incluye red ni tuberías, y la GPU del sistema es el motor más cargado, no la suma de los programas.

## Tus datos

| Fichero | Dónde | Contenido |
|---|---|---|
| `logeador.db` | `%LOCALAPPDATA%\Logeador\` | La base de datos del historial (SQLite). |
| `ajustes.json` | La misma carpeta | Rango, intervalo, tema, medidas visibles, colores. |

La carpeta está fuera de OneDrive a propósito: una base de datos que se escribe cada pocos segundos no debe sincronizarse. Nada sale de tu equipo y no hay cuenta ni conexión.

Si quieres empezar de cero, cierra la app y borra `logeador.db` (la app crea una nueva al abrir). Al actualizar con el instalador nuevo se conserva todo. Para quitar la app, usa «Aplicaciones» de Windows; el historial se queda en la carpeta anterior hasta que lo borres.

## Problemas frecuentes

| Qué pasa | Qué hacer |
|---|---|
| El gráfico sale vacío o dice «Sin datos guardados» | Hace falta esperar al primer registro (según el intervalo elegido). Con intervalos largos, tarda más en haber datos. |
| Un programa sale en la tabla pero no en los gráficos | Es normal si usa poco: solo se guardan los que pasan los umbrales. |
| La columna GPU sale a cero | Tu equipo puede no tener el contador de GPU, o ese programa no usa la tarjeta. |
| Faltan datos de unas horas | El programa solo registra mientras está abierto. |
| Windows avisa al abrir el instalador | Es normal en programas sin firma comercial. Pulsa «Más información» y «Ejecutar de todas formas». |
| «Ya está abierto» | Solo se admite una ventana. Búscala en la barra de tareas. |

## Versiones y créditos

Versión 1.4.0: cambia el nombre a Administrador de Tareas+ (ventana, avisos y accesos directos). El historial, los ajustes y la carpeta de datos son los de siempre. Antes: la 1.3.0 ordenó la distribución por el total del periodo y le puso números, y la 1.2.0 añadió la GPU por programa.

Está hecho en Python con tkinter, matplotlib, numpy y psutil. El código es de Mario (Kuerb0).
