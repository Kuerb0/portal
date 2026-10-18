"""Genera los flujogramas de las apps de escritorio del portal (flujogramas/<id>.svg).

Uso: python herramientas/generar_flujogramas.py

Cada app se describe con columnas de cajas y flechas entre ellas (mas abajo, en APPS). El de Viajes (App) es el
Flujograma.svg de su repositorio, copiado tal cual (con width/height para el visor). Para cambiar un diagrama se edita
su descripcion y se vuelve a ejecutar.

Caja:   (id, tipo, titulo, [lineas])      tipos: ext (fuera), proc (proceso), data (datos), ui (interfaz), tool (instalacion), launch (lanzador)
Flecha: (de, a, clase, etiqueta?)         clases: w escribe/genera, r lee, rw lee y escribe, l lanza/abre, c llama a, x consulta externa
"""
import os
import re
import textwrap
from xml.sax.saxutils import escape

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SALIDA = os.path.join(RAIZ, "flujogramas")

COLOR = {"ext": ("#6b7280", "#fff"), "proc": ("#2b6bd6", "#fff"), "data": ("#eef1f6", "#1f2937"),
         "ui": ("#1f9a52", "#fff"), "tool": ("#0f766e", "#fff"), "launch": ("#475569", "#fff")}
FLECHA = {"w": ("#4b8df8", "escribe / genera", ""), "r": ("#1fbf9a", "lee", ""), "rw": ("#f5a623", "lee y escribe", ""),
          "l": ("#a78bfa", "lanza / abre", "6 5"), "c": ("#64748b", "llama a", ""), "x": ("#9ca3af", "consulta externa", "")}
CW, GAP, MARGEN, TOPE = 250, 74, 24, 96          # ancho de columna, hueco entre columnas, margen, y donde empiezan las cajas
CARACTERES = 36                                  # ancho de linea del texto de las cajas


def es_mono(titulo):                              # nombres de fichero y carpetas: letra de codigo
    return bool(re.search(r"\.\w{2,4}$|/$|\|%", titulo))


def _lineas(caja):
    _, _, titulo, cuerpo = caja
    t = textwrap.wrap(titulo, 25 if es_mono(titulo) else 29) or [""]
    c = [l for texto in cuerpo for l in (textwrap.wrap(texto, CARACTERES) or [""])]
    return t, c


def _alto(caja):
    t, c = _lineas(caja)
    return 16 + 19 * len(t) + 17 * len(c) + 12


def generar(app):
    cols, flechas = app["cols"], app["flechas"]
    pos = {}                                     # id -> [col, x, y, w, h, caja]
    fin = 0
    for i, (nombre, cajas) in enumerate(cols):
        x = MARGEN + i * (CW + GAP)
        y = TOPE
        for caja in cajas:
            h = _alto(caja)
            pos[caja[0]] = [i, x, y, CW, h, caja]
            y += h + 18
        fin = max(fin, y)
    ancho = MARGEN * 2 + len(cols) * CW + (len(cols) - 1) * GAP
    alto = fin + 70

    # puntos de anclaje: en cada lado de cada caja se reparten las flechas segun la altura del otro extremo
    lado = {}
    for k, (a, b, *_r) in enumerate(flechas):
        A, B = pos[a], pos[b]
        if A[0] < B[0]: sa, sb = "d", "i"
        elif A[0] > B[0]: sa, sb = "i", "d"
        elif A[2] < B[2]: sa, sb = "b", "t"
        else: sa, sb = "t", "b"
        lado.setdefault((a, sa), []).append((B[2], k, "o"))
        lado.setdefault((b, sb), []).append((A[2], k, "e"))
    punto = {}
    for (idc, s), lst in lado.items():
        _, X, Y, W, H, _c = pos[idc]
        lst.sort()
        for j, (_o, k, extremo) in enumerate(lst):
            f = (j + 1) / (len(lst) + 1)
            punto[(k, extremo)] = ((X + W, Y + H * f, 1, 0) if s == "d" else (X, Y + H * f, -1, 0) if s == "i"
                                   else (X + W * f, Y + H, 0, 1) if s == "b" else (X + W * f, Y, 0, -1))

    s = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{ancho}" height="{alto}" viewBox="0 0 {ancho} {alto}" '
         f'font-family="Segoe UI, Inter, system-ui, sans-serif"><title>{escape(app["titulo"])}</title>',
         "<defs>" + "".join(f'<marker id="f{c}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto">'
                            f'<path d="M0 1 10 5 0 9z" fill="{FLECHA[c][0]}"/></marker>' for c in FLECHA) + "</defs>",
         f'<rect width="{ancho}" height="{alto}" fill="#fff"/>',
         f'<text x="{MARGEN}" y="30" font-size="16" font-weight="700" fill="#9aa3b2">{escape(app["titulo"])}</text>']
    for i, (nombre, _c) in enumerate(cols):      # contenedores de las columnas
        x = MARGEN + i * (CW + GAP) - 10
        s.append(f'<rect x="{x}" y="64" width="{CW + 20}" height="{fin - 64}" rx="14" fill="none" stroke="#d6dbe5" stroke-width="1.5" stroke-dasharray="6 5"/>'
                 f'<text x="{x + (CW + 20) / 2}" y="54" font-size="15" font-weight="600" text-anchor="middle" fill="#9aa3b2">{escape(nombre)}</text>')
    etiquetas = []
    for k, f in enumerate(flechas):              # flechas (debajo de las cajas)
        a, b, clase = f[:3]
        x1, y1, d1, v1 = punto[(k, "o")]
        x2, y2, d2, v2 = punto[(k, "e")]
        dx, dy = max(40, abs(x2 - x1) * .45), max(40, abs(y2 - y1) * .45)
        c1 = (x1 + d1 * dx, y1 + v1 * dy)
        c2 = (x2 + d2 * dx, y2 + v2 * dy)
        color, _t, trazo = FLECHA[clase]
        s.append(f'<path d="M{x1:.1f} {y1:.1f} C{c1[0]:.1f} {c1[1]:.1f} {c2[0]:.1f} {c2[1]:.1f} {x2:.1f} {y2:.1f}" fill="none" stroke="{color}" '
                 f'stroke-width="2" {f"stroke-dasharray={chr(34)}{trazo}{chr(34)}" if trazo else ""} marker-end="url(#f{clase})"/>')
        if len(f) > 3:
            mx = (x1 + 3 * c1[0] + 3 * c2[0] + x2) / 8
            my = (y1 + 3 * c1[1] + 3 * c2[1] + y2) / 8
            w = 6.3 * len(f[3]) + 10
            etiquetas.append(f'<rect x="{mx - w / 2:.1f}" y="{my - 9:.1f}" width="{w:.1f}" height="17" rx="5" fill="#fff" opacity=".92"/>'
                             f'<text x="{mx:.1f}" y="{my + 4:.1f}" font-size="11.5" text-anchor="middle" fill="{color if clase != "x" else "#6b7280"}">{escape(f[3])}</text>')
    for idc, (_i, x, y, w, h, caja) in pos.items():  # cajas
        _, tipo, _t, _b = caja
        fondo, texto = COLOR[tipo]
        borde = ' stroke="#c9d1e0" stroke-width="1.5"' if tipo == "data" else ""
        t, c = _lineas(caja)
        s.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="{fondo}"{borde}/>')
        yy = y + 24
        mono = ' font-family="Consolas, monospace"' if es_mono(caja[2]) else ""
        for l in t:
            s.append(f'<text x="{x + 14}" y="{yy}" font-size="14.5" font-weight="700" fill="{texto}"{mono}>{escape(l)}</text>')
            yy += 19
        for l in c:
            s.append(f'<text x="{x + 14}" y="{yy}" font-size="12.5" fill="{texto}" opacity=".93">{escape(l)}</text>')
            yy += 17
    s.extend(etiquetas)
    usadas = [c for c in FLECHA if any(f[2] == c for f in flechas)]   # leyenda
    lx = MARGEN
    for c in usadas:
        color, texto, trazo = FLECHA[c]
        s.append(f'<line x1="{lx}" y1="{alto - 28}" x2="{lx + 34}" y2="{alto - 28}" stroke="{color}" stroke-width="2.5"'
                 f'{f" stroke-dasharray={chr(34)}{trazo}{chr(34)}" if trazo else ""}/>'
                 f'<text x="{lx + 42}" y="{alto - 24}" font-size="12.5" fill="#9aa3b2">{texto}</text>')
        lx += 70 + 7 * len(texto)
    s.append("</svg>")
    return "\n".join(s)


APPS = {
    "apagador": dict(titulo="Apagador · flujograma v1.0.0", cols=[
        ("Instalación", [
            ("inst", "tool", "Instalador.bat", ["Lleva el programa dentro", "Busca Python 3.10+ con tkinter; si no hay, lo instala en la carpeta de la app (sin administrador)"]),
            ("act", "tool", "Actualizar.bat", ["Guarda la versión anterior en anteriores/ y pone la nueva", "Actualiza los accesos directos"]),
            ("acc", "tool", "Crear_acceso_directo.vbs", ["Acceso directo del Escritorio con el icono"])]),
        ("Programa", [
            ("app", "ui", "apagador_app.py", ["Ventana tkinter siempre encima", "Elige duración en minutos o hora exacta", "Botones Programar y Cancelar"]),
            ("calc", "proc", "calcular_segundos()", ["Duración → segundos", "Hora exacta → segundos hasta hoy (o mañana si ya pasó)"]),
            ("cuenta", "proc", "cuenta atrás", ["Cada segundo resta y enseña el tiempo que queda", "Cancelar la detiene en cualquier momento"])]),
        ("Windows", [
            ("sd", "ext", "shutdown /s /f /t 0", ["Apaga el equipo al llegar a cero"]),
            ("ab", "ext", "shutdown /a", ["Cancela el apagado programado"])])],
        flechas=[("inst", "app", "w", "instala"), ("act", "app", "rw", "actualiza"), ("acc", "app", "l", "abre"),
                 ("app", "calc", "c", "Programar"), ("calc", "cuenta", "w", "segundos"),
                 ("cuenta", "sd", "x", "al llegar a 0"), ("app", "ab", "x", "Cancelar")]),

    "post-it": dict(titulo="Post-It · flujograma v1.0.0", cols=[
        ("Instalación", [
            ("inst", "tool", "instalar.bat", ["Comprueba que está Node.js", "npm install electron en %LOCALAPPDATA%\\PostIt (fuera de OneDrive, ~300 MB)", "Crea el acceso directo «Post-its» y el arranque con Windows"]),
            ("act", "tool", "actualizar.bat", ["git pull del código y reinicia la app", "No toca tus notas: notes.json queda fuera de git"])]),
        ("Proceso principal", [
            ("main", "launch", "main.js (Electron)", ["Una sola instancia", "Una ventana de 340×340 por nota; recuerda su posición", "Bandeja: Nueva nota · Mostrar todas · Salir", "Arranca con Windows"]),
            ("ps", "tool", "PowerShell auxiliar", ["Electron no tiene «siempre debajo»: llama a SetWindowPos(HWND_BOTTOM) con cada ventana"])]),
        ("Cada nota", [
            ("pre", "proc", "preload.js", ["Puente con el proceso principal: get, save, color, z, glass, cols, new, del, close"]),
            ("nota", "ui", "note.html", ["Editor de la nota con casillas de tarea", "Tareas repetibles: @diario @semanal @lunes…", "Color, cristal (65 %), encima o debajo, columnas"])]),
        ("Datos", [
            ("notes", "data", "notes.json", ["Las notas, en OneDrive: se sincronizan entre equipos", "Se vigila cada 3 s: si OneDrive trae cambios, se recargan"]),
            ("pos", "data", "pos.json", ["Posición y tamaño de cada ventana (en este equipo)"])])],
        flechas=[("inst", "main", "w", "instala y lanza"), ("act", "main", "rw", "actualiza"),
                 ("main", "pre", "l", "abre cada nota"), ("pre", "nota", "c", "IPC"),
                 ("main", "ps", "c", "ventanas «debajo»"), ("main", "notes", "rw", "guarda y recarga"), ("main", "pos", "rw")]),

    "calendario": dict(titulo="Calendario · flujograma v2.0", cols=[
        ("Instalación", [
            ("inst", "tool", "Instalador.bat", ["Crea app/ y datos/", "Usa tu Python (3.9+) o instala uno en python/", "Instala las librerías de requirements.txt", "Acceso directo y arranque con Windows (si quieres)"]),
            ("conf", "ui", "configurar.py", ["Asistente: de dónde leer los eventos, festivos y cómo verlos"]),
            ("act", "tool", "Actualizar.bat", ["Sustituye app/, instala las librerías que falten", "Conserva tu configuración y tus perfiles"])]),
        ("Fuentes", [
            ("outlook", "ext", "Outlook clásico", ["Calendarios, correo y reglas, por COM"]),
            ("ics", "ext", "Enlace ICS", ["Calendario publicado en Outlook web"]),
            ("fest", "ext", "Festivos", ["Oficiales por comunidad autónoma y municipio (con copia en caché)"])]),
        ("Widget", [
            ("cal", "ui", "calendario.py", ["Ventana tkinter de escritorio", "Rejilla por horas, lista, ambas o mes", "Descarga los eventos, reparte columnas y detecta solapes", "Avisos previos y alarmas por evento"]),
            ("aviso", "ext", "Windows", ["Avisos, sonido y bandeja del sistema"])]),
        ("Módulos", [
            ("extras", "proc", "extras.py", ["Panel de control (7 pestañas) y paleta de comandos Ctrl+K"]),
            ("correo", "proc", "correo_columna.py", ["Correo dentro del widget: filtros por carpeta, leer, responder"]),
            ("menus", "proc", "menus.py", ["Menú de clic derecho"])]),
        ("Datos", [
            ("config", "data", "datos/config.json", ["Ajustes y tareas permanentes", "+ .bak, perfiles/ y anteriores/"]),
            ("local", "data", "%LOCALAPPDATA%\\WidgetCalendario", ["cache.pkl, registro.txt y alternar.senal", "Fuera de OneDrive porque cambian a cada momento"])])],
        flechas=[("inst", "cal", "w", "instala"), ("act", "cal", "rw", "actualiza"), ("inst", "conf", "l", "abre al terminar"),
                 ("outlook", "cal", "x"), ("ics", "cal", "x"), ("fest", "cal", "x"), ("outlook", "correo", "x", "correo y reglas"),
                 ("cal", "aviso", "w", "avisos y alarmas"), ("cal", "extras", "l"), ("cal", "correo", "l"), ("cal", "menus", "l"),
                 ("conf", "config", "w", "guarda"), ("cal", "config", "rw"), ("cal", "local", "rw"), ("extras", "config", "rw")]),

    "planificador": dict(titulo="Planificador financiero · flujograma v1.3.0", cols=[
        ("Instalación", [
            ("inst", "tool", "Instalador.bat", ["Copia el programa; si falta Python, descarga uno portable (descargar_python.ps1)"]),
            ("act", "tool", "Actualizar.bat", ["Guarda py/ en anteriores/ y pone la versión nueva"]),
            ("acc", "tool", "Accesos directos.bat", ["Escritorio, menú Inicio y arranque con Windows"])]),
        ("Lanzador", [
            ("lan", "launch", "planificador_app.pyw", ["¿Ya abierta? Por el socket :8611 le dice «mostrar» y sale", "Si no: lanza streamlit run en :8601 (app.log)", "Ventana pywebview, o Edge --app si no está", "Icono de bandeja: Abrir / Salir. Cerrar = ocultar"])]),
        ("App Streamlit", [
            ("app", "ui", "app_planificador.py", ["Barra lateral: usuario activo, Actualizar datos, Glosario", "st.navigation hacia las páginas"]),
            ("pags", "ui", "paginas/", ["Hipoteca · Cartera · Comparador · Mercado", "Plazos y riesgo · Ahorrador · Asignador · Test de riesgo", "Datos en caché 1 h (@st.cache_data)"])]),
        ("Cálculo", [
            ("fin", "proc", "finanzas.py", ["Sin Streamlit, probado con tests", "Hipoteca: cuota, cuadro, TAE, gastos de compra", "Mercado: índices, curva del BCE, tipos actuales", "Simulación: Monte Carlo, ventanas históricas, frontera", "Riesgo por plazo y plan de jubilación (mortalidad INE)", "Test de tolerancia al riesgo (Grable-Lytton)"])]),
        ("Fuentes externas", [
            ("yf", "ext", "Yahoo Finance", ["yfinance: índices y fondos (VT, S&P 500…)"]),
            ("bce", "ext", "API del BCE", ["Euribor 12 m, bono a 10 años, curva de 1 a 25 años"]),
            ("ine", "ext", "API del INE", ["Tabla 27153 de mortalidad"])]),
        ("Datos locales (OneDrive)", [
            ("csv", "data", "csv/", ["Índices (caché 24 h), curva (7 días)", "tipos_actuales.json (diario), mortalidad_ine.csv", "Si falla internet, se usa la última copia"]),
            ("cfg", "data", "perfiles y ajustes", ["perfiles_riesgo.json, config_planificador.json"]),
            ("log", "data", "registros", ["app.log y errores.log"])])],
        flechas=[("inst", "lan", "w", "instala"), ("act", "lan", "rw", "actualiza"), ("acc", "lan", "l"), ("lan", "app", "l", "streamlit run"),
                 ("app", "pags", "l"), ("pags", "fin", "c"), ("yf", "fin", "x"), ("bce", "fin", "x"), ("ine", "fin", "x"),
                 ("fin", "csv", "rw", "caché y copia"), ("fin", "cfg", "rw"), ("fin", "log", "w", "errores")]),

    "atlas": dict(titulo="Atlas del conocimiento · flujograma v1.15", cols=[
        ("Instalación", [
            ("inst", "tool", "Instalador.bat", ["Con motor.ps1: instala Python y librerías", "Prepara la IA local y enseña con ✓/✗ qué hay"]),
            ("act", "tool", "Actualizar.bat", ["Pone el código nuevo y no pisa tus datos", "(catalogo.json, fichas_mias.json…)"]),
            ("acc", "launch", "Acceso directo", ["Del Escritorio; con --vivo enseña los cambios al instante"])]),
        ("Ventana", [
            ("app", "launch", "arbol_app.pyw", ["pywebview (Edge WebView2), o Edge --app si no está", "Api: lo que el visor puede pedir a Python"]),
            ("visor", "ui", "visor_arbol.html", ["Pestañas: Universo (mapa 3D), Aprender, Importar, Eclipses, Telescopio e IA", "Buscador único y fichas de propiedades 0-10"])]),
        ("Código", [
            ("arbol", "proc", "arbol_estadistica", ["13 ramas: preprocesado, selección, modelos, diagnóstico, ml, actuarial, finanzas…", "Cada función: origen, equivalente SAS y advertencias"]),
            ("build", "tool", "construir_visor.py", ["Regenera el visor desde el índice, los conceptos, las propiedades y las rutas de aprendizaje"]),
            ("cuad", "proc", "cuaderno/", ["Ejemplo ejecutable por celdas de cada función, con datos simulados"]),
            ("conoc", "proc", "conocimiento/", ["Buscador SQLite FTS5 (BM25)", "Importa libros, código, datos y apuntes", "Clasifica por reglas, parecido y LLM", "Sala de clasificación y cola de revisión"])]),
        ("Fuera del código", [
            ("llm", "ext", "Ollama (local)", ["qwen2.5:3b para los casos dudosos; embeddings locales"]),
            ("tel", "ext", "Telescopio", ["Google Books, Open Library, Gutenberg, arXiv, OpenAlex, Archive: solo obras abiertas o de dominio público"]),
            ("wiki", "ext", "Wikipedia y Wikidata", ["Información web de cada obra (APIs oficiales)"])]),
        ("Datos", [
            ("cat", "data", "conceptos/ y teoria/", ["catalogo.json (tuyo), guías y ejemplos"]),
            ("idx", "data", "conocimiento/", ["indice.db, referencias.json (sin rutas del equipo)", "Los PDF y EPUB no suben a GitHub"]),
            ("fich", "data", "propiedades y aprender", ["fichas.json, medidas.json, rutas de aprendizaje, fichas_mias.json"])])],
        flechas=[("inst", "app", "w", "instala"), ("act", "app", "rw", "actualiza"), ("acc", "app", "l"), ("app", "visor", "l", "abre"),
                 ("visor", "cuad", "l", "Probar"), ("visor", "conoc", "rw", "buscar / importar"), ("build", "visor", "w", "genera"),
                 ("arbol", "build", "r"), ("cat", "build", "r", "conceptos"), ("fich", "build", "r"),
                 ("llm", "conoc", "x"), ("tel", "conoc", "x"), ("wiki", "conoc", "x"), ("conoc", "idx", "rw")]),

    "estadistica-app": dict(titulo="Estadística (App) · flujograma v1.0.0", cols=[
        ("Instalación", [
            ("inst", "tool", "Instalador.exe", ["Asistente con ventana, sin consola, que lleva el programa dentro", "Copia a %LOCALAPPDATA%\\Programs\\Estadistica, crea accesos directos y se registra en Aplicaciones instaladas"]),
            ("des", "tool", "Desinstalar.exe", ["Quita la carpeta, los accesos directos y el registro", "No borra nada si no tiene Estadistica.exe al lado"])]),
        ("Ventana", [
            ("app", "launch", "Estadistica.exe", ["pywebview + WebView2: una ventana nativa de Windows", "El título lleva la versión; icono propio en la barra de tareas"]),
            ("ui", "ui", "web/ (HTML + JS)", ["12 páginas: Conceptos, Descriptiva, Distribuciones, Contrastes, Bayes, Regresiones, Clasificación, Supervivencia, Clustering, Actuarial, Índice y Apariencia", "Gráficos en canvas con animaciones y buscador global Ctrl+K"])]),
        ("Cálculo", [
            ("py", "proc", "py/ (Python)", ["Solo calcula: numpy, scipy y statsmodels", "Un módulo por página: regresiones.py, clustering.py, reservas.py…"]),
            ("cod", "proc", "Código equivalente", ["Cada resultado trae su código en Python, R y SAS para copiar"])]),
        ("Datos", [
            ("csv", "data", "Tu CSV", ["Regresiones, Clustering y Reservas aceptan tus propios datos", "No se envía nada a ningún sitio"]),
            ("pref", "data", "Apariencia guardada", ["Paleta, estilo y fondo animado se recuerdan al cerrar"])])],
        flechas=[("inst", "app", "w", "instala"), ("des", "app", "rw", "quita"), ("app", "ui", "l", "carga"), ("ui", "py", "c", "pywebview.api"),
                 ("py", "cod", "w"), ("csv", "py", "r"), ("ui", "pref", "rw")]),
}


def main():
    os.makedirs(SALIDA, exist_ok=True)
    for nombre, app in APPS.items():
        with open(os.path.join(SALIDA, nombre + ".svg"), "w", encoding="utf-8") as f:
            f.write(generar(app))
        print("flujogramas/" + nombre + ".svg")


if __name__ == "__main__":
    main()
