titulo: Excel avanzado
subtitulo: Un libro de ejercicios con 160.000 precios de vuelos y una guía de funciones para aprender de verdad
version: repositorio
color: #1d7a45
color_oscuro: #135a31

## Qué es este proyecto

Excel avanzado es un repositorio de GitHub con tres ficheros pensados para aprender las funciones modernas de Excel haciendo ejercicios con datos de verdad:

| Fichero | Qué es |
|---|---|
| `Excel.xlsx` | Un libro con seis hojas y cada función explicada con un ejemplo vivo. |
| `Guia_Excel_Avanzado.pptx` | Una presentación de 17 diapositivas que explica cada función, con sus argumentos y un ejemplo. |
| `Data.csv` | Unos 160.000 registros de precios de vuelos, para practicar con una tabla grande. |

![Vista previa del proyecto](img/excel.jpg)

El libro enseña, hoja a hoja, cuatro cosas: trabajar con tablas estructuradas, buscar y referenciar, manipular tablas con matrices dinámicas y operar con condiciones. La presentación sigue el mismo orden y cada función enlaza a su página de Microsoft Support en español.

### Para quién es

Para quien ya usa Excel (sumas, filtros, buscarv) y quiere dar el salto a las funciones nuevas: `FILTRAR`, `ORDENARPOR`, `UNICOS`, `BUSCARX`, `TOMAR`, `APILARV`… Con ellas se hacen en una celda cosas que antes pedían macros o tablas dinámicas.

### Qué necesitas

- **Excel 365 o Excel 2021 en adelante.** Las funciones de matrices dinámicas (`FILTRAR`, `ORDENARPOR`, `UNICOS`, `SECUENCIA`, `TOMAR`, `EXCLUIR`, `APILARV`, `APILARH`, `ENCOL`, `ELEGIRCOLS`, `ELEGIRFILAS`) y `BUSCARX` no existen en Excel 2019 ni en versiones anteriores.
- **Excel en español**, porque los nombres de las funciones están en español. En una instalación en inglés, tienen otros nombres (hay una tabla al final).
- Para `Data.csv`, unos 40 MB libres y paciencia al abrirlo: tiene 163.803 filas y 20 columnas.

## Conseguir los ficheros

1. Abre la página del repositorio (`github.com/Kuerb0/Excel`) con el botón «Ver en GitHub» del portal.
2. Pulsa el botón verde «Code» y «Download ZIP», o abre cada fichero y usa «Download raw file».
3. Descomprime y abre `Excel.xlsx` en Excel.

Si Excel abre el libro en «Vista protegida», pulsa «Habilitar edición» para que las fórmulas se calculen.

## El libro Excel.xlsx

Tiene seis hojas. En todas, cada fórmula aparece escrita en texto junto a su resultado, gracias a la función `FORMULATEXTO`, para que veas qué hay detrás de cada número.

| Hoja | De qué va |
|---|---|
| Data | Una tabla estructurada de ejemplo: letras de la A a la Z, un número, un acumulado y una columna calculada. |
| Tablas | Funciones de resumen sobre otra tabla pequeña. |
| Buscar | Búsquedas y referencias: `BUSCARX`, `INDICE`, `INDIRECTO`, `DESREF`. |
| Manip Tablas | Matrices dinámicas: la hoja más grande, con una función por bloque. |
| Operar Tablas | Funciones con condiciones, que terminan en `.SI.CONJUNTO`. |
| Resto | Hoja vacía para tus propias pruebas. |

## 1. Tablas estructuradas

Hojas «Data» y «Tablas». Se crean seleccionando un rango y pulsando **Ctrl + T**.

Una tabla estructurada tiene tres ventajas sobre un rango normal:

1. **Crece con los datos.** Las fórmulas que usan `Data[...]` incluyen automáticamente las filas nuevas.
2. **Referencias por nombre.** Se escribe `Data[Número]` en lugar de `$B$2:$B$55`.
3. **Columnas calculadas.** La fórmula se escribe una vez y se copia sola a toda la columna.

### Columna calculada

En «Data», la columna D («Mayor Que la Media») usa:

`=[@Número]>PROMEDIO(Data[Número])`

`[@Número]` es el valor de la misma fila. El resultado es VERDADERO si el número es mayor que la media de la columna (14 en este ejemplo). En la barra de fórmulas aparece escrito como `Data[[#Esta fila];[Número]]`.

### Funciones de resumen

En la hoja «Tablas», una tabla con las letras A a F y los números 1 a 6 sirve para estas cuatro:

| Función | Fórmula | Resultado |
|---|---|---|
| SUMA | `=SUMA(Tabla2[Número])` | 21 |
| CONTAR | `=CONTAR(Tabla2[Número])` | 6 |
| PROMEDIO | `=PROMEDIO(Tabla2[Número])` | 3,5 |
| VAR.P | `=VAR.P(Tabla2[Número])` | 2,92 |

### FORMULATEXTO

`=FORMULATEXTO(D2)` devuelve la fórmula de una celda como texto. Se usa en todas las hojas del libro para mostrar cada fórmula junto a su resultado.

## 2. Buscar y referenciar

Hoja «Buscar».

### BUSCARX

Busca un valor en una columna y devuelve lo que hay en la misma fila de otra columna. Sustituye a `BUSCARV` y `BUSCARH`, sin sus manías.

`=BUSCARX(H1#; Data[Letras]; Data[Número])`

| Argumento | Qué es |
|---|---|
| `valor_buscado` | Lo que se busca. `H1#` es la lista completa que devuelve la celda H1. |
| `matriz_buscada` | La columna donde se busca. |
| `matriz_devuelta` | La columna que se devuelve. |
| `[si_no_existe]` | Texto que sale en lugar de `#N/D`. |
| `[modo]` | 0 es coincidencia exacta (por defecto); −1 o 1 son aproximadas. |

En el libro, `H1` vale `=TOMAR(UNICOS(Data[Letras]); 5)`, que da las cinco primeras letras distintas, y `BUSCARX` devuelve el número de cada una. Si el valor aparece varias veces, devuelve la primera coincidencia: la A está dos veces en «Data».

### INDICE, FILAS y COLUMNAS

`=INDICE(Data[]; 25; 2)` devuelve el valor de la fila 25 y la columna 2 de la tabla. Con `FILAS(Data[])` (54) y `COLUMNAS(Data[])` (4) sabes el tamaño de la tabla. Para buscar la posición de un valor se combina con `COINCIDIR`:

`=INDICE(Data[Número]; COINCIDIR("X"; Data[Letras]; 0))`

### INDIRECTO y DESREF

- **INDIRECTO** convierte un texto en una referencia: `=SUMA(INDIRECTO("Data[Número]"))`. Permite elegir la columna desde una celda o un desplegable.
- **DESREF** se desplaza filas y columnas desde una celda: `=DESREF(Data!B1; 5; 0)`. Sirve para crear rangos móviles, por ejemplo los últimos n meses.

> Las dos son volátiles: se recalculan con cualquier cambio del libro, y eso ralentiza los archivos grandes. Úsalas con medida.

## 3. Matrices dinámicas

Hoja «Manip Tablas». Una sola fórmula devuelve varios valores que se desbordan por las celdas de al lado.

### Desbordamiento

1. Escribes una fórmula en una celda, por ejemplo `=SECUENCIA(5)`.
2. El resultado ocupa varias celdas y Excel lo marca con un borde azul.
3. Para referirte a todo el resultado, escribes la celda con una almohadilla: `A1#`. Sirve aunque el tamaño cambie.

Si alguna de las celdas que necesita el resultado ya tiene algo escrito, sale el error `#¡DESBORDAMIENTO!`. Se arregla vaciándolas.

### FILTRAR

`=FILTRAR(Data[]; Data[Número]>H2; "Sin resultados")`

| Argumento | Qué es |
|---|---|
| `matriz` | La tabla que se devuelve. |
| `incluir` | La condición que se evalúa en cada fila. |
| `[si_vacío]` | Texto si ninguna fila la cumple. |

Para combinar condiciones se multiplican (Y) o se suman (O): `(cond1)*(cond2)` es Y y `(cond1)+(cond2)` es O.

### ORDENARPOR

`=ORDENARPOR(Data[]; Data[Mayor Que la Media]; -1; Data[Número]; 1)`

El primer criterio ordena por «Mayor Que la Media» en descendente (VERDADERO primero) y el segundo ordena por «Número» en ascendente dentro de cada grupo. `ORDENAR` usa la posición de la columna; `ORDENARPOR` puede ordenar por cualquier columna, aunque no se devuelva.

### UNICOS

`=UNICOS(Data[[Letras]:[Número]]; FALSO)`

| Argumento | Qué es |
|---|---|
| `matriz` | Las columnas que se comparan. |
| `[por_columna]` | `FALSO` compara filas, que es lo habitual. |
| `[exactamente_una_vez]` | `VERDADERO` devuelve solo lo que aparece una vez. |

En el libro, de las 54 filas de «Data» hay 27 únicas (el 50 %).

### SECUENCIA

`=SECUENCIA(10; 1; 1; 1)` da una columna de 10 números empezando en 1 y de 1 en 1. Los argumentos son filas, columnas (opcional), inicio y paso. Se usa para numerar filas, crear calendarios o generar índices para `INDICE` y `ELEGIRFILAS`. Con `=SECUENCIA(3; 4)` se rellenan 12 celdas por filas, de izquierda a derecha.

### TOMAR y EXCLUIR

- `=TOMAR(Data[]; 10; 1)` devuelve las 10 primeras filas de la primera columna.
- `=EXCLUIR(Data[]; 10; 1)` devuelve la tabla sin las 10 primeras filas ni la primera columna.

Con números negativos se cuenta desde el final: `TOMAR(Data[]; -5)` devuelve las 5 últimas filas.

### APILARV, APILARH y ENCOL

| Función | Qué hace | Ejemplo |
|---|---|---|
| APILARV | Une rangos en vertical | `=APILARV(Data[Letras]; Data[Número])` da 108 filas |
| APILARH | Une rangos en horizontal | `=APILARH(Data[Letras]; Data[Acum]; Data[Número])` da 3 columnas |
| ENCOL | Pasa un rango a una sola columna | `=ENCOL(Data[])` da 216 valores (54 por 4) |

`ENFILA` hace lo mismo que `ENCOL`, pero en una fila.

### ELEGIRCOLS, ELEGIRFILAS y fórmulas anidadas

- `=ELEGIRCOLS(Data[]; 1; 3)` devuelve las columnas 1 y 3.
- `=ELEGIRFILAS(Data[]; 1; -1)` devuelve la primera y la última fila.

Las funciones se anidan: `=TOMAR(ORDENARPOR(Data[]; Data[Número]; -1); 5)` primero ordena la tabla de mayor a menor «Número» y luego se queda con las 5 primeras filas, un top 5 en una sola celda.

## 4. Operar con condiciones

Hoja «Operar Tablas». Son las funciones que terminan en `.SI.CONJUNTO`: operan solo con las filas que cumplen varias condiciones a la vez.

| Función | Argumentos |
|---|---|
| SUMAR.SI.CONJUNTO | `rango_suma; rango_criterios1; criterio1; …` |
| CONTAR.SI.CONJUNTO | `rango_criterios1; criterio1; …` |
| PROMEDIO.SI.CONJUNTO | `rango_promedio; rango_criterios1; criterio1; …` |
| MAX.SI.CONJUNTO y MIN.SI.CONJUNTO | `rango_max; rango_criterios1; criterio1; …` |

`SUMAR`, `PROMEDIO` y `MAX`/`MIN` empiezan por el rango con el que se opera. `CONTAR` no lo lleva.

> Para usar una celda en un criterio hay que concatenarla: `">"&H2`. Con `">H2"` se compara con el texto «H2».

### Por lista y por intervalo

- **Por lista**: `=SUMAR.SI.CONJUNTO(Data[Número]; Data[Letras]; H2:H4)`. Como `H2:H4` tiene tres valores, la fórmula devuelve tres resultados, uno por letra.
- **Por intervalo**: `=SUMAR.SI.CONJUNTO(Data[Número]; Data[Número]; "<10"; Data[Número]; ">5")` suma los números menores de 10 y mayores de 5 (en el ejemplo: 60 de suma, 8 de cuenta, 7,5 de promedio y 9 de máximo).

> Pendiente de corregir en el libro: en «Operar Tablas», las celdas I12, L12, I16 y L16 usan los criterios de arriba (H2:H4, H6 y H7) en lugar de los suyos, así que cambiar H12 o H16 no altera el resultado.

## Practicar con Data.csv

Con el libro ya sabes las funciones; con `Data.csv` las usas a escala real: 163.803 filas con precios de vuelos de un año.

### Qué contiene

Cada fila es un vuelo de solo ida: un trayecto Madrid a un destino o la vuelta, con el precio más barato de ese día. Las 20 columnas:

| Columna | Qué es |
|---|---|
| `fecha`, `dia_semana`, `mes` | Día del vuelo (de 2026-09-29 a 2027-09-26), día de la semana y mes. |
| `sentido` | `IDA` o `VUELTA`. |
| `codigo`, `ciudad` | Código del aeropuerto de destino y nombre de la ciudad (221 destinos). |
| `origen`, `destino` | Aeropuertos de salida y de llegada. |
| `precio_eur` | Precio en euros: de 14 € a 5.868 €, con una media de unos 250 €. |
| `precio_anterior` | Precio de la descarga anterior, para ver cómo ha cambiado. |
| `aerolinea` | Aerolínea (673 distintas). |
| `escalas` | Número de escalas (de 0 a 4). |
| `duracion_min`, `duracion` | Duración en minutos y en texto («2h 45m»). |
| `hora_salida`, `hora_llegada` | Horas, en formato HH:MM. |
| `llega_dia_siguiente` | `sí` o `no` (a veces vacío). |
| `n_opciones` | Cuántas opciones había ese día. |
| `ultima_descarga` | Cuándo se bajó el dato. |
| `enlace_reserva` | Enlace a Google Flights para esa búsqueda. |

### Cargarlo en Excel

1. En Excel: pestaña «Datos», «Obtener datos», «Desde un archivo», «Desde texto o CSV».
2. Elige `Data.csv`. El separador es el punto y coma y la codificación, UTF-8.
3. Pulsa «Cargar». Excel pone los datos en una hoja nueva.
4. Con una celda de los datos seleccionada, pulsa **Ctrl + T** y ponle a la tabla el nombre `Vuelos` en la pestaña «Diseño de tabla».

### Ejercicios

Con la tabla `Vuelos` puedes probar todo lo que has visto:

| Quiero saber… | Fórmula |
|---|---|
| El precio medio | `=PROMEDIO(Vuelos[precio_eur])` |
| El vuelo más barato | `=MIN(Vuelos[precio_eur])` |
| Cuántos destinos distintos hay | `=CONTARA(UNICOS(Vuelos[ciudad]))` |
| Los vuelos de ida a Lisboa por menos de 60 € | `=FILTRAR(Vuelos; (Vuelos[ciudad]="Lisboa")*(Vuelos[sentido]="IDA")*(Vuelos[precio_eur]<60); "Sin resultados")` |
| Los 10 vuelos más baratos | `=TOMAR(ORDENARPOR(Vuelos; Vuelos[precio_eur]; 1); 10)` |
| El precio medio a Lisboa | `=PROMEDIO.SI.CONJUNTO(Vuelos[precio_eur]; Vuelos[ciudad]; "Lisboa")` |
| Cuántos vuelos son directos | `=CONTAR.SI.CONJUNTO(Vuelos[escalas]; 0)` |
| El máximo que cuesta volar a Lisboa en ida | `=MAX.SI.CONJUNTO(Vuelos[precio_eur]; Vuelos[ciudad]; "Lisboa"; Vuelos[sentido]; "IDA")` |
| El precio de la primera fila de una ciudad | `=BUSCARX("Lisboa"; Vuelos[ciudad]; Vuelos[precio_eur])` |

Retos para ir más allá:

1. Una lista con las 5 ciudades más baratas de media. Pista: `UNICOS` para las ciudades, `PROMEDIO.SI.CONJUNTO` para cada una, y `ORDENARPOR` y `TOMAR` para el top 5.
2. Los vuelos que han bajado de precio respecto a la descarga anterior. Pista: compara `precio_eur` con `precio_anterior` dentro de `FILTRAR`.
3. El día de la semana más barato para volar. Pista: `PROMEDIO.SI.CONJUNTO` por `dia_semana`.

> Con 163.000 filas, las fórmulas que usan `INDIRECTO` o `DESREF` se vuelven lentas. Prefiere las referencias directas a la tabla.

## Nombres en inglés

Si tu Excel está en inglés, las funciones se llaman así:

| Español | Inglés |
|---|---|
| FILTRAR | FILTER |
| ORDENARPOR | SORTBY |
| ORDENAR | SORT |
| UNICOS | UNIQUE |
| SECUENCIA | SEQUENCE |
| TOMAR | TAKE |
| EXCLUIR | DROP |
| APILARV | VSTACK |
| APILARH | HSTACK |
| ENCOL | TOCOL |
| ENFILA | TOROW |
| ELEGIRCOLS | CHOOSECOLS |
| ELEGIRFILAS | CHOOSEROWS |
| BUSCARX | XLOOKUP |
| INDICE | INDEX |
| COINCIDIR | MATCH |
| INDIRECTO | INDIRECT |
| DESREF | OFFSET |
| FORMULATEXTO | FORMULATEXT |
| SUMAR.SI.CONJUNTO | SUMIFS |
| CONTAR.SI.CONJUNTO | COUNTIFS |
| PROMEDIO.SI.CONJUNTO | AVERAGEIFS |
| MAX.SI.CONJUNTO y MIN.SI.CONJUNTO | MAXIFS y MINIFS |
| PROMEDIO | AVERAGE |
| CONTAR | COUNT |
| SUMA | SUM |

En inglés los argumentos se separan con comas en vez de puntos y comas.

## Problemas frecuentes

| Qué pasa | Qué hacer |
|---|---|
| Sale `#¿NOMBRE?` | Tu Excel no tiene esa función (es anterior a 2021) o está en otro idioma. Mira la tabla de nombres en inglés. |
| Sale `#¡DESBORDAMIENTO!` | Hay algo escrito en las celdas donde debería caer el resultado. Vacíalas. |
| `Data.csv` sale en una sola columna | Elige el separador punto y coma al importarlo. |
| Los acentos salen mal | Elige la codificación UTF-8 al importarlo. |
| Va muy lento | Evita `INDIRECTO` y `DESREF` con tablas grandes, y cierra otros libros. |
| Windows o Excel avisan al abrir el libro | Es un archivo descargado de internet. Pulsa «Habilitar edición» si confías en él. |

## Créditos

El libro, la presentación y los datos son de Mario (Kuerb0). Los precios de `Data.csv` salen de Google Flights, descargados con la app Viajes. Cada función enlaza a su página de ayuda de Microsoft Support.
