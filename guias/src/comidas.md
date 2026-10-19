titulo: Comidas
subtitulo: Tus platos de comida y cena, con ingredientes, cantidades y alérgenos
version: web
icono: img/iconos/comidas.svg
color: #2f6f4f
color_oscuro: #1f4d37

## Qué es esta web

Comidas es una libreta de platos. Apuntas lo que sueles cocinar, con sus ingredientes y cantidades, y la web te avisa de qué alérgenos lleva cada plato. Después puedes buscar por el nombre del plato o por un ingrediente, y filtrar entre comida y cena.

![La lista de platos](guias/img/comidas/lista.jpg)

Sirve para no tener que acordarte de qué lleva cada receta, para saber qué platos son seguros si alguien en casa tiene una alergia y para tener a mano lo que puedes cocinar con lo que hay en la nevera.

Funciona en el navegador del ordenador y del móvil, y se puede instalar como una app. No necesita cuenta ni conexión permanente.

> Tus platos se guardan en el navegador del aparato donde los escribes. No se sincronizan con otros aparatos ni se copian en ningún servidor. Más abajo se explica qué implica y cómo no perderlos.

## Abrirla e instalarla

La dirección es `kuerb0.github.io/comidas`. Ábrela en cualquier navegador moderno.

### Instalarla como app

La web se puede instalar para que se abra en su propia ventana, sin barra de direcciones, con su icono:

- **En Android (Chrome):** menú de los tres puntos, «Instalar app» o «Añadir a pantalla de inicio».
- **En ordenador (Chrome o Edge):** el icono de instalar que aparece a la derecha de la barra de direcciones.
- **En iPhone (Safari):** botón de compartir y «Añadir a pantalla de inicio».

La app instalada abre a pantalla completa y usa los mismos platos que la web.

### Sin conexión

Después de abrirla una vez, funciona sin internet: guarda una copia de sí misma. Cuando hay conexión, primero intenta bajar la versión nueva (así llegan las actualizaciones) y si no hay red usa la copia guardada.

## La pantalla principal

Arriba, en una franja verde, están el título, el buscador y tres pestañas: **Todos**, **Comida** y **Cena**. Debajo, la lista de platos. Abajo a la derecha, un botón redondo con un **+** para crear un plato nuevo.

Cada plato aparece en una tarjeta con:

- Su nombre y, al lado, para qué es (comida, cena o «comida o cena»).
- Sus ingredientes con las cantidades, separados por puntos.
- Sus alérgenos, como etiquetas de color naranja. Si no lleva ninguno, pone «Sin alérgenos».
- Sus notas, en cursiva, si tiene.

### Buscar

El buscador mira el nombre del plato y también los ingredientes. Escribe «patata» y salen todos los platos que llevan patata, aunque no la tengan en el nombre. No distingue mayúsculas ni acentos: «salmon» encuentra «Salmón».

![Buscar un ingrediente](guias/img/comidas/buscar.jpg)

### Filtrar por momento

Las pestañas **Comida** y **Cena** dejan solo los platos de ese momento. Los platos marcados como «comida o cena» salen en las dos.

![Solo los platos de cena](guias/img/comidas/cena.jpg)

## Crear y cambiar un plato

Pulsa el **+** para crear uno nuevo, o toca un plato de la lista para abrirlo y cambiarlo. Se abre una ventana con estos campos:

| Campo | Qué poner |
|---|---|
| Plato | El nombre, por ejemplo «Lentejas con chorizo». Es obligatorio. |
| Para | Comida, Cena o «Comida o cena». |
| Ingredientes y cantidades | Una fila por ingrediente: nombre, cantidad y unidad. |
| Alérgenos | Casillas que se marcan solas y que puedes corregir. |
| Notas | Lo que quieras: un truco, un tiempo de cocción, de dónde sacaste la receta. |

![Un plato abierto](guias/img/comidas/plato.jpg)

### Ingredientes

Cada ingrediente tiene un nombre, una cantidad (un número, con decimales si hace falta) y una unidad. Las unidades disponibles son:

- `g` (gramos)
- `ml` (mililitros)
- `ud` (unidades)
- `cucharada`
- `taza`

El botón **+ ingrediente** añade una fila nueva y pone el cursor en ella. La **×** de cada fila la quita. Al guardar, las filas sin nombre se descartan.

### Alérgenos

Mientras escribes los ingredientes, la web va marcando sola las casillas de los alérgenos que detecta. Por ejemplo, al escribir «Leche» se marca «Lácteos», y al escribir «Gambas», «Crustáceos». Las casillas están agrupadas en etiquetas con los 14 alérgenos de declaración obligatoria:

| | | |
|---|---|---|
| Gluten | Crustáceos | Huevo |
| Pescado | Cacahuetes | Soja |
| Lácteos | Frutos secos | Apio |
| Mostaza | Sésamo | Sulfitos |
| Altramuces | Moluscos | |

La detección es solo una ayuda: busca palabras clave en el nombre del ingrediente. Reconoce, por ejemplo, harina, pasta, pan y macarrones como gluten; huevo, mayonesa y tortilla como huevo; leche, queso, nata y yogur como lácteos; atún, salmón y merluza como pescado; o vino y vinagre como sulfitos.

> La detección no es infalible. Un ingrediente con un nombre que la web no conoce (una salsa comprada, un embutido) puede llevar alérgenos que no se marquen, y un plato puede marcar uno que en realidad no lleva. Revisa siempre las casillas, y si alguien tiene una alergia grave, mira también la etiqueta de cada producto.

Las casillas que marques o desmarques a mano se respetan: la web solo añade, nunca quita.

### Guardar y borrar

- **Guardar** guarda el plato y cierra la ventana. Si no has puesto nombre, te pide que lo escribas.
- **Cancelar** cierra sin guardar.
- **Borrar** (solo en platos que ya existían) pide confirmación antes de eliminar el plato.

Un plato nuevo se pone al principio de la lista.

## Tus datos

Todo lo que escribes se guarda en el propio navegador, en un espacio llamado almacenamiento local, con el nombre `comidas.v1`. Esto tiene consecuencias que conviene conocer:

- **No hay cuenta ni servidor.** Nadie más ve tus platos y la web no envía nada a ningún sitio.
- **Cada navegador tiene los suyos.** Los platos que apuntes en el móvil no aparecen en el ordenador, y los de Chrome no aparecen en Edge.
- **Borrar los datos del navegador borra los platos.** Si limpias el historial incluyendo «datos de sitios» o «cookies», se pierden. La web pide al navegador que no los borre por su cuenta, pero no puede garantizarlo.
- **No hay copia de seguridad ni exportación.** Si te importan mucho tus platos, haz una captura o apunta los importantes en otro sitio.

Si usas la web como app instalada, los platos son los de la app, que pueden ser distintos de los que tengas en el navegador normal.

## Problemas frecuentes

| Qué pasa | Qué hacer |
|---|---|
| He perdido mis platos | Probablemente se borraron los datos del navegador, o estás en otro navegador o aparato distinto del que usaste. |
| No salen mis platos en el móvil | Cada aparato tiene su propia lista: tendrás que apuntarlos otra vez. |
| La web no marca un alérgeno | La detección solo reconoce palabras conocidas. Marca la casilla a mano. |
| No encuentro la opción de instalar | Algunos navegadores solo la ofrecen tras unas visitas. Prueba en el menú del navegador con «Instalar» o «Añadir a pantalla de inicio». |
| No carga sin internet | Ábrela al menos una vez con conexión para que guarde su copia. |

## Versiones y créditos

Comidas es una página web de un solo archivo, sin librerías externas, que se instala como PWA. El código es de Mario (Kuerb0).
