titulo: Finanzas Personales
subtitulo: Hipoteca, inversión, ahorro y riesgo en una sola app para Windows y Android
version: 2.0.0
icono: img/iconos/finanzas.png
color: #16824a
color_oscuro: #0f6637

## Qué es esta app

Finanzas Personales reúne en un sitio las cuentas que casi todo el mundo acaba haciendo a mano cuando toma una decisión de dinero: cuánto pagaré de hipoteca, cuánto podría tener dentro de diez años si invierto, qué reparto entre bolsa y renta fija me conviene y cuánto necesito para jubilarme.

Tiene ocho páginas. Cada una responde a una pregunta concreta y todas comparten los mismos datos de mercado reales (bolsa desde 1973, tipos del Banco Central Europeo, inflación), así que los resultados de una página encajan con los de las demás.

| Página | Pregunta que responde |
|---|---|
| Hipoteca | ¿Cuánto pagaré al mes y cuánto me costará el préstamo? |
| Cartera | ¿Cuánto podría tener dentro de unos años si reparto mi dinero entre bolsa y renta fija? |
| Comparador | ¿Qué cambia si elijo otro reparto, otra estrategia o una comisión distinta? |
| Mercado | ¿Cómo se ha comportado la bolsa en el pasado? |
| Plazos y riesgo | ¿Cuántos años hacen falta para que sea raro perder dinero? |
| Ahorrador | ¿Cuánto necesito para jubilarme, y cuánto tardo en llegar a una meta? |
| Asignador | ¿Qué porcentaje de bolsa me conviene según mi perfil y el tiempo que me queda? |
| Test de riesgo | ¿Cuánto riesgo acepto? (13 preguntas) |

![Página de Cartera en el ordenador](guias/img/finanzas-app/d_cartera.jpg)

> Todo lo que calcula la app es orientativo. Se basa en lo que pasó en el pasado, no incluye impuestos ni comisiones (salvo donde se indica) y no es asesoramiento financiero.

### Para quién es

Para cualquiera que quiera entender sus números sin abrir una hoja de cálculo. No hace falta saber de finanzas: cada página explica con una frase corta qué muestra cada gráfico y el glosario de la barra lateral define los términos que salen.

### Qué no hace

No se conecta a tu banco ni guarda cuentas, contraseñas o movimientos. No te recomienda productos concretos. No predice el futuro: reparte miles de futuros posibles a partir de años reales y te enseña cómo de disperso es el resultado.

## Instalación y primer arranque

### En Windows

1. Descarga el instalador (`FinanzasPersonales-2.0.0-Instalador.exe`, unos 90 MB) desde el botón «Instalador» del portal.
2. Ábrelo. Si Windows avisa de que no conoce al editor, pulsa «Más información» y luego «Ejecutar de todas formas».
3. Elige la carpeta y si quieres acceso directo en el Escritorio y en el menú Inicio.
4. Al terminar, abre Finanzas Personales desde el acceso directo.

No necesitas instalar Python ni nada más: el programa lleva el suyo dentro (ocupa unos 260 MB ya instalado). Para actualizar, ejecuta el instalador nuevo: se instala encima y conserva tu perfil de riesgo y tus ajustes.

### En Android

1. Descarga `FinanzasPersonales-2.0.0-Movil.apk` desde el botón «Instalador móvil» del portal.
2. Ábrelo. Android te pedirá permiso para instalar apps de esa fuente.
3. La primera vez tarda un poco más en arrancar porque prepara los cálculos; las siguientes veces es rápido.

La app móvil lleva los datos de mercado de la fecha en que se hizo la versión y no los actualiza sola (ver «Datos de mercado»).

### La ventana y la bandeja

En Windows, al cerrar la ventana la app no se apaga: queda en la bandeja del sistema, junto al reloj. Para abrirla otra vez, haz doble clic en su icono. Para salir del todo, clic derecho en el icono y «Salir». Si lanzas la app estando ya abierta, solo te muestra la ventana que ya existe.

## Recorrido por la pantalla

A la izquierda está el menú. Arriba tiene tres botones: la lupa (buscador, también con Ctrl+K), la paleta (apariencia) y el botón de claro/oscuro. Debajo van las ocho páginas.

![Menú lateral y página de Hipoteca](guias/img/finanzas-app/d_inicio.jpg)

En la parte baja del menú encuentras:

- El usuario activo y su perfil de riesgo, si ya hiciste el test.
- Ajustes de simulación (modo real, inflación y años por bloque).
- El botón «Actualizar datos de mercado», solo en el ordenador.
- El glosario sencillo.
- La versión instalada.

### En el móvil

El menú se abre con el botón de las tres rayas de arriba a la izquierda. Abajo hay una barra con las cuatro páginas de uso más habitual (Hipoteca, Cartera, Mercado y Ahorrador) y un botón «Más» que abre el menú completo.

![Cartera en el móvil](guias/img/finanzas-app/m_cartera.jpg)

### Apariencia

El botón de la paleta abre el panel de apariencia: 10 paletas de color (más el modo automático, que sigue al sistema), varios estilos de esquinas, fondos animados y la opción de reducir las animaciones. Se recuerda lo que elijas.

## Hipoteca

Calcula la cuota mensual de un préstamo y todo lo que rodea a la compra de una vivienda.

### Datos que se piden

| Campo | Qué significa |
|---|---|
| Precio de la vivienda | Lo que cuesta la casa. |
| Entrada (%) | Lo que pones de tu bolsillo. Lo habitual es el 20 %. |
| Plazo (años) | Cuánto tiempo tardas en devolver el préstamo. |
| Tipo de hipoteca | Fijo, variable o mixto. |
| TIN fijo (%) | Interés anual nominal que te ofrece el banco. |

Si eliges **variable**, el tipo es el Euribor más un diferencial y se revisa cada año; tienes que indicar el diferencial, el Euribor que supones y cuánto varía cada año. En la **mixta**, el tipo es fijo durante unos años (los que pongas en «Años a tipo fijo») y después pasa a variable.

### Opciones avanzadas

Despliegan los gastos de la compra y las amortizaciones anticipadas:

- Vivienda nueva o usada: cambia los impuestos. Para usada se aplica el ITP; para nueva, el IVA y el AJD.
- Notaría, registro y gestoría, tasación y comisión de apertura.
- Seguros vinculados al préstamo, en euros al mes.
- Amortización extra mensual y amortización extra anual (cada diciembre), y si con ellas quieres bajar la cuota o acortar el plazo.

### Resultados

Arriba salen la cuota inicial, la TAE, el dinero que necesitas el día de la compra y el coste total de la vivienda. Debajo, el panel «Cómo se calcula la cuota» muestra la fórmula con tus números, cada variable en un color.

La cuota de un préstamo francés (cuotas iguales) sale de:

`C = P · i / (1 − (1 + i)^−n)`

donde P es el capital prestado, i el interés mensual (TIN dividido entre 12) y n el número de cuotas. De cada cuota, una parte son intereses (capital pendiente por i) y el resto amortiza deuda. La TAE es el tipo anual equivalente que iguala lo que recibes con todo lo que pagas, incluidos seguros y comisiones; sirve para comparar ofertas.

La página tiene cuatro pestañas:

| Pestaña | Qué enseña |
|---|---|
| Gráficos | Deuda pendiente año a año, reparto entre préstamo y coste, y capital e intereses de cada año. |
| Compra y gastos | Cuánto dinero necesitas el día de la compra y desglose de impuestos y gastos. |
| Más análisis | Cuota frente a tus ingresos, precio máximo que puedes comprar, qué pasaría con otro Euribor y comparación de plazos. |
| Cuadro de amortización | Mes a mes: lo que pagas, intereses, capital amortizado y deuda que queda. |

> Regla habitual: la cuota no debería pasar del 30 o 35 % de los ingresos netos mensuales del hogar. La pestaña «Más análisis» te dice con qué precio de vivienda llegarías al 35 %.

## Cartera

Simula cuánto podrías tener en el futuro repartiendo tu dinero entre renta variable (bolsa) y renta fija.

### Qué se simula

Hay dos estrategias:

- **Promediar** (DCA): inviertes un capital hoy y vas añadiendo ahorro cada mes o cada año. Compras a precios distintos.
- **Buy and hold**: inviertes todo el primer día y no tocas nada hasta el final.

Y se piden estos datos: dinero que inviertes hoy, ahorro que añades cada año (se reparte en cuotas iguales mensuales o anuales), años de inversión y porcentaje en bolsa. El resto va a renta fija.

Si ya hiciste el test de riesgo, la página te sugiere un reparto. Si no, te recuerda que puedes hacerlo desde el menú.

### Cómo se calcula

La app no adivina el futuro: reutiliza años reales de la bolsa. Hay dos métodos, que eliges en «Opciones avanzadas»:

| Método | Cómo funciona |
|---|---|
| Monte Carlo | Sortea miles de veces tramos de años reales para fabricar futuros posibles. La mediana es el «caso típico»; los percentiles 5 y 95 son los extremos razonables. |
| Ventanas históricas | Repite periodos reales completos: empezar en 1990, en 1991, y así con todos los años posibles. |

En el Monte Carlo se sortean bloques de años seguidos (5 por defecto) en lugar de años sueltos. Así se conservan las rachas reales, como una crisis de varios años o un rebote. Lo cambias en los ajustes de simulación; con 1 vuelve al método clásico de años independientes.

La renta fija puede modelarse de tres formas:

- **Tipo constante**: rinde siempre lo mismo.
- **Carry histórico**: cada año gana el bono a 10 años de ese momento.
- **Vencimiento objetivo**: el primer año compras un bono a H años, el segundo a H−1, y todo vence el último año. Usa la curva histórica del BCE (desde 2004).

### Resultados

Cuatro cifras resumen el resultado: lo que habrás puesto en total, el caso típico (la mitad de los casos acaba por encima y la mitad por debajo), el mal escenario (solo 1 de cada 20 casos acaba peor) y el buen escenario (solo 1 de cada 20 acaba mejor). También sale la probabilidad de acabar con menos de lo que aportaste.

Tres pestañas completan la página:

1. **Tu cartera**: la evolución con su banda de incertidumbre y el histograma de resultados finales.
2. **A distintos plazos**: el mismo reparto mirando 1, 2, 3, 5 años y hasta 30.
3. **Objetivo y riesgos**: escribes la cantidad que te gustaría tener y la app dice en qué parte de los futuros la alcanzas. También enseña cómo habría ido empezando en el peor momento.

## Comparador

Pone dos opciones lado a lado con el mismo dinero, el mismo plazo y las mismas aportaciones.

| Pestaña | Qué compara |
|---|---|
| Reparto bolsa / renta fija | Todos los repartos de 0 a 100 % en bolsa. Cada punto es un reparto; la línea continua es el caso típico y la de puntos el mal escenario. Puedes poner un límite de probabilidad de perder y la app te dice qué reparto lo cumple con más bolsa. |
| Todo de golpe vs promediando | Buy and hold frente a aportaciones periódicas. Todo de golpe suele ganar de media porque el dinero está más tiempo en el mercado, pero promediar reduce el riesgo de entrar justo antes de una caída. |
| Formas de modelar la renta fija | Tipo constante, carry y vencimiento objetivo, con periodos históricos reales. |
| Cartera A vs B | Dos repartos distintos. La línea es el caso típico y la banda cubre 9 de cada 10 casos. |
| Comisiones | Resta a la bolsa la comisión anual del fondo (TER) y compara lo que tendrías al final. Un 1 % parece poco, pero compuesto durante años pesa mucho. |

![Comparador](guias/img/finanzas-app/d_comparador.jpg)

## Mercado

Es la página de los datos reales: la base de todas las simulaciones.

Eliges un índice de bolsa. Los índices están en dólares y con dividendos, sin convertir a euros.

| Índice | Desde |
|---|---|
| Mundo largo: MSCI World hasta 2008 y Vanguard Total World (VT) | 1973 |
| Vanguard Total World (VT) | 2009 |
| Vanguard Total Stock Market EE. UU. (VTSMX) | 1993 |
| S&P 500 con dividendos | 1989 |

El «Mundo largo» empalma el MSCI World (1973 a 2008) con el ETF Vanguard Total World (desde 2009) para tener el historial más largo posible.

Cinco pestañas:

1. **Histórico**: rentabilidad media anual, variación típica de un año, peor año y mayor caída desde máximos. Dos gráficos: cuánto valdrían 100 € invertidos al principio (en escala logarítmica) y cuánto subió o bajó cada año.
2. **Caídas**: cuánto ha estado el índice por debajo de su máximo anterior. Cada hueco es una crisis; importa cuánto cayó y cuánto tardó en recuperarse.
3. **Décadas y plazos**: rentabilidad de cada década y rentabilidad anualizada según el plazo en que mantienes. Con más años la línea se aplana y se estabiliza.
4. **Comparar índices**: el valor de 100 € invertidos a la vez en varios índices.
5. **Tipos de interés**: los tipos del BCE que usa la renta fija de las simulaciones.

![Mercado](guias/img/finanzas-app/d_mercado.jpg)

## Plazos y riesgo

Responde a una pregunta muy práctica: ¿cuántos años hacen falta para que sea raro perder dinero?

La página mira todas las ventanas posibles del pasado (aunque se solapen) de cada duración, desde una semana hasta 30 años, y cuenta en cuántas habrías acabado con menos dinero del que pusiste. Cuanto más largo es el plazo, menos ventanas pierden. La curva se suaviza con una media móvil de 52 semanas y la rentabilidad se expresa como TIR anualizada.

Se elige el reparto entre bolsa y renta fija, la estrategia (buy and hold o DCA con aportaciones iguales cada semana) y, en «Opciones avanzadas», el índice y la renta fija.

| Pestaña | Contenido |
|---|---|
| Probabilidad de perder | Una curva por cada reparto, del azul (0 % bolsa) al naranja (100 % bolsa). Un selector te dice cuántos años necesitas para que la probabilidad de perder sea menor que 0, 1, 2, 5, 10 o 20 %. |
| Tabla de equivalencias | Los años necesarios para cada reparto y cada riesgo aceptado. |
| TIR según el plazo | Rentabilidad anualizada en distintos escenarios: 1 de cada 100, 1 de cada 20, la mitad y los 1 de cada 20 mejores. |
| Más análisis | Probabilidad de acabar con menos de lo invertido menos un X %, y la misma pregunta con otros índices. |

> Con plazos largos casi todas las ventanas comparten años, así que hay pocas realmente distintas. La página lo avisa y lo cuenta: tómalo como una pauta, no como una garantía.

![Plazos y riesgo](guias/img/finanzas-app/d_plazos.jpg)

## Ahorrador

Tiene cuatro pestañas. Todo se calcula en euros de hoy: se descuenta la inflación para que las cifras se entiendan.

### Jubilación

Calcula el capital que necesitas el día que te jubilas y cuánto ahorrar al mes para llegar.

Datos: edad actual, edad de jubilación, hasta qué edad quieres cobrar, salario neto mensual, nivel de vida que quieres mantener (el 70 a 80 % del salario suele bastar, porque en la jubilación ya no ahorras ni pagas ciertos gastos), pensión pública estimada, lo que ya tienes ahorrado y lo que ahorras ahora cada mes. En «Modo de cálculo» eliges la tabla de mortalidad (total, hombres o mujeres) y la edad máxima de la tabla; en «Opciones avanzadas», la rentabilidad antes y después de jubilarte y la inflación.

El capital necesario es el valor, el día que te jubilas, de los gastos mensuales que tu pensión no cubre. Hay dos formas de decidir hasta cuándo cobrar:

- **Edad fija**: aseguras el gasto hasta una edad concreta. Cuantos más años vivas, más capital necesitas.
- **Probabilidad de seguir vivo**: cada mes de gasto se multiplica por la probabilidad de estar vivo, según las tablas de mortalidad del INE, sabiendo que llegas vivo a la jubilación. Es el valor actuarial «de media»: en la mitad de los casos te quedarías corto si vives más.
- **Prudente**: garantiza la renta hasta la edad a la que solo llega 1 de cada 10 de quienes alcanzan la jubilación.

También sale una gráfica de cómo evoluciona tu saldo (sube mientras ahorras, baja al retirar y llega a cero en la edad final), el ahorro mensual necesario según la edad de jubilación y una tabla de sensibilidad: cuánto cambia el ahorro si la rentabilidad antes y después de jubilarte es distinta.

### Meta de ahorro

Cuánto tardas en llegar a una cantidad con un ahorro mensual y una rentabilidad dados. Se supone que aportas a principio de cada mes. La gráfica separa en azul lo que pones tú y en naranja lo que añade la rentabilidad; la línea gris es tu meta.

### Independencia financiera

Tener un capital que, retirando cada año un porcentaje pequeño, cubra tus gastos sin tener que trabajar. La regla clásica es el 4 % (capital igual a 25 veces el gasto anual); para plazos muy largos suele recomendarse el 3 o 3,5 %. La pestaña calcula cuándo lo alcanzas y qué pasa si ahorras más o usas otra tasa de retirada.

### Fondo de emergencia

El colchón para imprevistos, como perder el empleo o una avería. Lo habitual son entre 3 y 6 meses de gastos esenciales, y más si tu ingreso es variable. Calcula la cantidad y cuánto tardas en reunirla con la rentabilidad que supongas (una cuenta remunerada suele dar un 2 o 3 %).

![Ahorrador](guias/img/finanzas-app/d_ahorrador.jpg)

## Asignador

Traduce tu perfil de riesgo y el tiempo que te queda en un porcentaje de bolsa.

### Cómo se calcula

1. La nota del test de riesgo (Grable y Lytton) se convierte en una **nota T**, la escala estándar de la psicometría, con media 50 y desviación 10. Con cinco desviaciones a cada lado cubre justo de 0 a 100, así que esa nota se lee directamente como porcentaje ideal de renta variable (0 es todo renta fija, 100 es todo bolsa).
2. **El tiempo ajusta ese ideal.** Para cada tramo de años que queda se miran todas las ventanas del pasado y se calcula el mal escenario anualizado (el 1 de cada 20 peor). Si el reparto ideal queda por debajo de un suelo de rentabilidad que aceptas, se recorta la bolsa lo justo.
3. El resultado es el porcentaje de bolsa recomendado hoy y cómo bajaría según te acerques al final.

Puedes usar la nota de un perfil guardado o escribirla a mano. En «Opciones avanzadas» ajustas la media de la escala, el riesgo aceptado, las ventanas peores que se dejan fuera y el suavizado.

### Pestañas

- **Recomendación**: tu nota, el porcentaje de bolsa y la campana de la población donde caes.
- **Simulación dinámica**: cómo evolucionaría una cartera real que se recorta cuando se pasa de riesgo, con ventanas históricas o con miles de futuros posibles. Banda de 8 de cada 10 trayectorias y línea mediana.
- **Perfiles y plazos**: la bolsa recomendada para cada nota y cada plazo, y la comparación entre los perfiles guardados.

## Test de riesgo

Es el cuestionario de Grable y Lytton (1999): 13 preguntas, unos tres minutos. No hay respuestas buenas ni malas. Mide cuánto riesgo aceptas, no cuánto te conviene.

Escribes un nombre de usuario (si ya existe, se actualiza su perfil; si es nuevo, se crea) y respondes todo. Al pulsar «Calcular y guardar perfil» obtienes una puntuación y un nivel:

| Puntos | Nivel | Qué significa | Bolsa orientativa |
|---|---|---|---|
| Hasta 18 | Bajo | Muy conservador: prioriza no perder capital. | 15 % |
| 19 a 22 | Medio-bajo | Prudente: acepta algo de riesgo a cambio de algo más de rentabilidad. | 35 % |
| 23 a 28 | Medio | Equilibrado: tolera oscilaciones moderadas. | 55 % |
| 29 a 32 | Medio-alto | Dinámico: acepta caídas relevantes a cambio de más rentabilidad esperada. | 75 % |
| 33 o más | Alto | Agresivo: tolera fuertes caídas buscando la máxima rentabilidad. | 90 % |

Cuatro pestañas muestran el resultado:

1. **Tu resultado**: tu nota sobre la escala, con las franjas oficiales.
2. **Desglose por pregunta**: cuántos puntos has puesto en cada una. Barras largas son respuestas más arriesgadas; cortas, más prudentes.
3. **Evolución**: si repites el test con el tiempo (mismo usuario), cómo cambia tu tolerancia. Suele moverse tras una crisis, un cambio de trabajo o de situación familiar.
4. **Cómo lo habrías vivido**: qué le habría pasado al reparto sugerido en los peores años de la historia. Si ver esos años te incomoda, probablemente te convenga menos bolsa.

Puedes tener varios usuarios (por ejemplo, tú y tu pareja). El usuario activo se elige en el menú lateral y las demás páginas usan su perfil.

> El reparto sugerido es una referencia orientativa. El test mide tu actitud ante el riesgo; no sustituye a un asesor.

## Ajustes de simulación

Están en el menú lateral y afectan a todas las páginas.

| Ajuste | Qué hace |
|---|---|
| Ver en términos reales | Descuenta la inflación: la bolsa (en dólares) con el IPC de EE. UU. y la renta fija (en euros) con la inflación de la zona euro (HICP del BCE). «Perder» pasa a significar perder poder adquisitivo. |
| Inflación esperada del euro | Se usa para pasar a real la renta fija a tipo constante. El 2 % es el objetivo del BCE. |
| Monte Carlo: años seguidos por bloque | Cuántos años consecutivos se sortean juntos. 1 es el método clásico. |

## Datos de mercado y de usuario

### De dónde salen los datos

| Dato | Fuente |
|---|---|
| Índices de bolsa | Yahoo Finance (MSCI World hasta 2008 con su rentabilidad por dividendos, ETF y S&P 500 con dividendos) |
| Tipos de interés del euro (Euribor, curva de bonos) | Banco Central Europeo |
| Inflación de EE. UU. | FRED (IPC) |
| Inflación de la zona euro | BCE (HICP) |
| Mortalidad | Tablas del INE |

### Actualizar

En el ordenador, el botón «Actualizar datos de mercado» vuelve a descargar los índices y los tipos. Si la descarga falla, la app usa la última copia guardada y te lo avisa. En el móvil no hay actualización: los datos van incluidos en cada versión de la app.

### Dónde se guardan tus cosas

Todo se guarda en la carpeta del programa, nunca en un servidor:

| Fichero | Contenido |
|---|---|
| `perfiles_riesgo.json` | Los usuarios, sus notas y sus respuestas del test. |
| `config_planificador.json` | Tus ajustes de simulación. |
| `csv/` | Copia de los datos de mercado descargados. |
| `errores.log` | Detalle técnico si alguna descarga falla. |

Al actualizar con el instalador nuevo se conservan tus perfiles y ajustes. Al desinstalar desde «Aplicaciones» de Windows, tus datos se guardan en una carpeta `FinanzasPersonales_datos` junto a la del programa.

## Problemas frecuentes

| Qué ves | Qué hacer |
|---|---|
| «No se han podido leer todos los tipos del BCE» | Sin conexión a internet o el BCE no responde. Puedes seguir con un tipo manual en «Opciones avanzadas». Prueba «Actualizar datos de mercado» más tarde. |
| «No se han podido descargar los datos del índice» | Misma causa. La app usa la última copia guardada si la tiene. |
| «No hay años suficientes en el histórico para ese horizonte» | Reduce el horizonte, elige un índice con más historia o usa el modo de tipo constante. |
| Windows avisa al abrir el instalador | Es normal en programas sin firma comercial. Pulsa «Más información» y «Ejecutar de todas formas». |
| La app no se abre al segundo intento | Ya estaba abierta, en la bandeja. Busca su icono junto al reloj. |
| En el móvil tarda en arrancar | La primera vez prepara los cálculos. Las siguientes veces es más rápido. |

## Glosario

| Término | Significado |
|---|---|
| TIN | Interés anual que cobra el banco, sin contar comisiones. |
| TAE | Coste anual real del préstamo, con comisiones y seguros. Sirve para comparar ofertas. |
| Euribor | Tipo de referencia al que se ligan las hipotecas variables. |
| Amortizar | Devolver parte del dinero prestado antes de tiempo. |
| Renta variable | Bolsa. Rinde más de media pero sube y baja mucho. |
| Renta fija | Bonos y depósitos. Más estable y menos rentable. |
| Buy and hold | Invertir todo el primer día y dejarlo sin tocar. |
| Promediar (DCA) | Invertir poco a poco, con aportaciones periódicas. |
| Euros de hoy | Cifras sin inflación, para entender cuánto valdría el dinero con los precios actuales. |
| Monte Carlo | Miles de simulaciones con años sorteados del pasado. |
| Mal y buen escenario | Solo 1 de cada 20 casos sale peor o mejor que eso (percentiles 5 y 95). |
| Volatilidad | Cuánto sube y baja una inversión de un año a otro. |
| TIR anualizada | Rentabilidad anual constante equivalente a lo que realmente ganaste. |
| Nota T | Escala de media 50 y desviación 10. En el Asignador se lee como porcentaje de bolsa ideal. |
| Caída desde máximos | Cuánto está el índice por debajo de su mejor valor anterior. |
| TER | Coste anual del fondo, que se resta a la rentabilidad. |
| Tasa de retirada segura | Porcentaje del capital que puedes gastar cada año sin agotarlo (regla del 4 %). |

## Versiones y créditos

La versión 2.0.0 cambia la interfaz por la misma que usan Estadística y Viajes: una ventana propia en el ordenador y una app para Android. Las ocho páginas y sus cálculos son los de la versión anterior. Antes funcionaba con un servidor local de Streamlit; ahora no hace falta ninguno.

El cuestionario del test es el de Grable y Lytton (1999). Los índices, tipos e inflación pertenecen a sus proveedores (Yahoo Finance, BCE, FRED e INE). El código es de Mario (Kuerb0).
