titulo: Apagador
subtitulo: Programa el apagado de Windows con una cuenta atrás y cancélalo cuando quieras
version: 1.0.0
icono: img/iconos/apagador.png
color: #d6453d
color_oscuro: #a8322b

## Qué es esta app

El Apagador apaga el ordenador por ti a una hora o dentro de un rato. Sirve para esas veces en que dejas una descarga, una película o una copia de seguridad en marcha y no quieres esperar a que termine para apagar el equipo.

Es una ventana pequeña con dos formas de programar el apagado, una cuenta atrás visible y un botón para cancelar. No guarda nada y no tiene ajustes.

![El Apagador, en modo duración](guias/img/apagador/duracion.png)

> El apagado es forzado. Cuando llega la hora, Windows cierra todos los programas sin preguntar y sin guardar lo que tengas abierto. Guarda tu trabajo antes de que acabe la cuenta atrás.

## Instalación

1. Descarga el instalador desde el botón «Descargar para Windows» del portal.
2. Ábrelo. Si Windows avisa de que no conoce al editor, pulsa «Más información» y luego «Ejecutar de todas formas».
3. Elige la carpeta y los accesos directos que quieras.
4. Abre el Apagador desde el acceso directo.

No hace falta tener Python ni conexión a internet: el programa lleva todo dentro. Para instalar una versión nueva, ejecuta el instalador nuevo encima.

## Cómo se usa

La ventana se abre siempre por encima del resto de ventanas para que no la pierdas. Arriba eliges cómo quieres programar el apagado.

### Duración (minutos)

Es la opción que aparece al abrir. Un deslizador va de 0 a 360 minutos (seis horas) de 10 en 10. Empieza en 50 minutos. Mueve la barra hasta los minutos que quieras esperar.

Si dejas el deslizador en 0, el equipo se apaga en un minuto.

### Hora exacta

Eliges una hora (de 0 a 23) y unos minutos (de 0 a 59). Los dos selectores dan la vuelta al llegar al final, de modo que después de 23 viene 0.

![Modo hora exacta](guias/img/apagador/hora.png)

Si la hora que eliges ya ha pasado hoy, el apagado se programa para esa hora de mañana. Por ejemplo, si son las 23:50 y pones las 00:10, se apagará en veinte minutos.

### Confirmar y continuar

Al pulsar «Confirmar y Continuar» pasan tres cosas:

1. Se bloquean los controles, para que no cambies la hora sin querer.
2. Empieza la cuenta atrás.
3. La ventana se minimiza. La puedes recuperar desde la barra de tareas.

### La cuenta atrás

La ventana muestra «Apagando en» y el tiempo que queda, con horas, minutos y segundos si falta más de una hora, y solo minutos y segundos si falta menos. Se actualiza cada segundo.

![Cuenta atrás en marcha](guias/img/apagador/cuenta.png)

### Cancelar el apagado

Pulsa «Cancelar Apagado» en cualquier momento, incluso con la cuenta atrás corriendo. El mensaje cambia a «Apagado cancelado.», los controles se desbloquean y puedes programar otro apagado si quieres.

## Cómo funciona por dentro

Esta parte es para quien quiera saber qué hace exactamente el programa con su equipo.

- La cuenta atrás la lleva la propia ventana, no Windows. Cuando llega a cero, la app ejecuta `shutdown /s /f /t 0`, que apaga el equipo de inmediato y fuerza el cierre de los programas.
- Al cancelar, la app ejecuta `shutdown /a`, que anula cualquier apagado pendiente de Windows, y detiene su cuenta atrás.
- Como la cuenta atrás depende de la ventana, el apagado solo ocurre si la app sigue abierta. Si la cierras (aunque sea con la cuenta atrás en marcha), no se apaga nada.
- El ordenador tampoco debe suspenderse ni hibernar mientras tanto: la cuenta atrás se detiene con él.

## Datos y privacidad

El Apagador no guarda nada: ni ajustes, ni historial, ni la última hora que usaste. No se conecta a internet ni envía datos a ningún sitio.

Para quitarlo, usa «Aplicaciones» de Windows: el instalador deja registrado un desinstalador.

## Problemas frecuentes

| Qué pasa | Qué hacer |
|---|---|
| El equipo no se apagó | Comprueba que la app seguía abierta y que el equipo no se suspendió. Si cerraste la ventana, la cuenta atrás se canceló. |
| No encuentro la ventana tras confirmar | Se minimiza al confirmar. Búscala en la barra de tareas. |
| Me equivoqué de hora | Pulsa «Cancelar Apagado» y programa otra vez. |
| Perdí un documento | El apagado es forzado y cierra todo sin guardar. Guarda antes de que acabe la cuenta atrás. |
| Windows avisa al abrir el instalador | Es normal en programas sin firma comercial. Pulsa «Más información» y «Ejecutar de todas formas». |

## Versiones y créditos

Versión 1.0.0. Es una ventana de Python con tkinter, sin dependencias externas. El código es de Mario (Kuerb0).
