@echo off
chcp 65001 >nul
setlocal EnableExtensions
title Planificador 1.3.0 - Instalador
color 0F

powershell -NoProfile -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; $l=[IO.File]::ReadAllLines('%~f0',[Text.Encoding]::UTF8); $a=[Array]::IndexOf($l,':::BANNERSTART'); $b=[Array]::IndexOf($l,':::BANNEREND'); foreach($t in $l[($a+1)..($b-1)]){ $p=$t.Split([char]0xA7); Write-Host -NoNewline $p[0] -ForegroundColor DarkCyan; if($p.Length -gt 1){ Write-Host -NoNewline 'O' -ForegroundColor DarkYellow; Write-Host $p[1] -ForegroundColor DarkCyan } else { Write-Host '' } }; $a=[Array]::IndexOf($l,':::TITULOSTART'); $b=[Array]::IndexOf($l,':::TITULOEND'); $l[($a+1)..($b-1)] | ForEach-Object { Write-Host $_ -ForegroundColor White }"
echo.
echo Esto va a:
echo   1. Copiar el programa en esta carpeta ^(subcarpetas py, assets...^)
echo   2. Buscar Python o, si no hay, instalar uno EN ESTA CARPETA
echo      ^(no hace falta ser administrador^)
echo   3. Instalar las librerias que necesita el programa
echo   4. Crear un acceso directo en el Escritorio
echo   5. Preguntarte si quieres que arranque solo con Windows
echo   6. Abrir la app
echo.
echo Tus datos ^(csv\, perfiles_riesgo.json...^) no se tocan si ya existen.
echo Todo se queda dentro de esta carpeta. No se manda ni se guarda
echo ningun dato tuyo en ningun sitio ajeno.
echo.
pause

set "SELF=%~f0"
set "SELF_DIR=%~dp0"
if "%SELF_DIR:~-1%"=="\" set "SELF_DIR=%SELF_DIR:~0,-1%"
for %%I in ("%SELF_DIR%") do set "SELF_NAME=%%~nxI"
set "INSTALL_DIR=%SELF_DIR%"
if /i "%SELF_NAME%"=="instaladores" for %%I in ("%SELF_DIR%\..") do set "INSTALL_DIR=%%~fI"
set "WORKDIR=%TEMP%\planificador_instalador_%RANDOM%"

echo prueba > "%INSTALL_DIR%\.prueba_escritura" 2>nul
if not exist "%INSTALL_DIR%\.prueba_escritura" (
    echo.
    echo No puedo escribir en esta carpeta:
    echo   %INSTALL_DIR%
    echo Mueve este instalador a una carpeta tuya ^(por ejemplo, tu carpeta
    echo "Planificador Financiero" de OneDrive^) y vuelve a ejecutarlo.
    pause
    exit /b 1
)
del /f /q "%INSTALL_DIR%\.prueba_escritura" >nul 2>&1

if not exist "%WORKDIR%" mkdir "%WORKDIR%" >nul 2>&1

echo.
echo [1/6] Extrayendo los ficheros del programa...

powershell -NoProfile -ExecutionPolicy Bypass -Command "$l=Get-Content -LiteralPath '%SELF%' -Encoding UTF8; $s=($l | Select-String -SimpleMatch ':::PSSTART' | Select-Object -Last 1).LineNumber; $e=($l | Select-String -SimpleMatch ':::PSEND' | Select-Object -Last 1).LineNumber; $l[$s..($e-2)] | Set-Content -LiteralPath '%WORKDIR%\extraer.ps1' -Encoding UTF8"
if not exist "%WORKDIR%\extraer.ps1" (
    echo No se ha podido preparar el instalador ^(fallo al extraer el script^).
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%WORKDIR%\extraer.ps1" "%SELF%" "%INSTALL_DIR%"
if not exist "%INSTALL_DIR%\py\app_planificador.py" (
    echo No se ha podido extraer py\app_planificador.py.
    pause
    exit /b 1
)
if not exist "%INSTALL_DIR%\py\planificador_app.pyw" (
    echo No se ha podido extraer py\planificador_app.pyw.
    pause
    exit /b 1
)
if not exist "%INSTALL_DIR%\csv" mkdir "%INSTALL_DIR%\csv" >nul 2>&1

echo.
echo [2/6] Buscando Python ^(3.10 o superior^)...

set "PYEXE="
if exist "%INSTALL_DIR%\python\python.exe" call :probar "%INSTALL_DIR%\python\python.exe"
if not defined PYEXE for /f "delims=" %%P in ('py -3 -c "import sys; print(sys.executable)" 2^>nul') do if not defined PYEXE call :probar "%%P"
if not defined PYEXE for /f "delims=" %%P in ('python -c "import sys; print(sys.executable)" 2^>nul') do if not defined PYEXE call :probar "%%P"

if defined PYEXE goto :python_encontrado

echo       No hay un Python valido: se va a descargar e instalar DENTRO
echo       DE ESTA CARPETA ^(subcarpeta "python"^).
echo       ^(puede tardar 1-2 minutos; se necesita conexion a internet^)
set "PYINSTALLER=%WORKDIR%\python-instalador.exe"
powershell -NoProfile -ExecutionPolicy Bypass -File "%INSTALL_DIR%\herramientas\descargar_python.ps1" "%PYINSTALLER%"
if not exist "%PYINSTALLER%" goto :error_descarga_python

"%PYINSTALLER%" /quiet TargetDir="%INSTALL_DIR%\python" InstallAllUsers=0 PrependPath=0 Include_pip=1 Include_tcltk=1 Include_test=0 Include_launcher=0
if exist "%INSTALL_DIR%\python\python.exe" set "PYEXE=%INSTALL_DIR%\python\python.exe"
if not defined PYEXE goto :error_instalacion_python
echo       Python instalado en esta carpeta.
goto :python_encontrado

:error_descarga_python
echo.
echo No se ha podido descargar Python. Revisa la conexion a internet
echo e intentalo de nuevo, o instala Python tu mismo desde python.org
echo ^(marcando "Add python.exe to PATH"^) y vuelve a ejecutar este instalador.
pause
exit /b 1

:error_instalacion_python
echo.
echo Algo ha fallado instalando Python en esta carpeta. Cierra esta
echo ventana y vuelve a ejecutar el instalador: si Python quedo a
echo medias, borra la subcarpeta "python" antes de reintentar.
pause
exit /b 1

:python_encontrado
set "PYWEXE=%PYEXE:python.exe=pythonw.exe%"
echo       Python: %PYEXE%

echo.
echo [3/6] Instalando las librerias necesarias ^(puede tardar un minuto^)...
"%PYEXE%" -m pip install --upgrade pip >nul 2>&1
"%PYEXE%" -m pip install --disable-pip-version-check --no-warn-script-location -r "%INSTALL_DIR%\py\requirements.txt"
if errorlevel 1 (
    echo.
    echo Alguna libreria no se ha podido instalar. Revisa el mensaje de
    echo arriba ^(suele ser falta de conexion a internet^) y vuelve a
    echo ejecutar este instalador: lo que ya se instalo no se repite.
    pause
    exit /b 1
)

echo       Comprobando que todo carga...
"%PYEXE%" -c "import streamlit, plotly, pandas, numpy, yfinance, pystray, PIL" >nul 2>&1
if errorlevel 1 (
    echo.
    echo AVISO: alguna libreria no carga bien. El programa puede arrancar,
    echo pero conviene volver a ejecutar el instalador.
    echo.
)
"%PYEXE%" -c "import webview" >nul 2>&1
if errorlevel 1 (
    echo       Instalando pywebview ^(ventana propia; si falla, se usara Edge^)...
    "%PYEXE%" -m pip install --disable-pip-version-check --no-warn-script-location pywebview >nul 2>&1
)

echo.
echo [4/6] Creando accesos directos ^(Escritorio y menu Inicio^)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$w=New-Object -ComObject WScript.Shell; $s=$w.CreateShortcut((Join-Path $w.SpecialFolders('Desktop') 'Planificador.lnk')); $s.TargetPath='%PYWEXE%'; $s.Arguments='\"%INSTALL_DIR%\py\planificador_app.pyw\"'; $s.WorkingDirectory='%INSTALL_DIR%\py'; $s.IconLocation='%INSTALL_DIR%\assets\planificador.ico'; $s.Description='Planificador 1.3.0'; $s.Save(); Copy-Item -LiteralPath $s.FullName -Destination (Join-Path $w.SpecialFolders('Programs') 'Planificador.lnk') -Force"

echo.
echo [5/6] Arranque con Windows
choice /c SN /n /m "Quieres que Planificador arranque solo al encender el ordenador? [S/N] "
if errorlevel 2 goto :sin_arranque
powershell -NoProfile -ExecutionPolicy Bypass -Command "$w=New-Object -ComObject WScript.Shell; $s=$w.CreateShortcut((Join-Path $w.SpecialFolders('Startup') 'Planificador.lnk')); $s.TargetPath='%PYWEXE%'; $s.Arguments='\"%INSTALL_DIR%\py\planificador_app.pyw\"'; $s.WorkingDirectory='%INSTALL_DIR%\py'; $s.IconLocation='%INSTALL_DIR%\assets\planificador.ico'; $s.WindowStyle=7; $s.Description='Planificador 1.3.0'; $s.Save()"
echo       Hecho: arrancara solo al iniciar sesion.
:sin_arranque

echo.
echo [6/6] Instalacion terminada. Todo ha quedado en esta carpeta:
echo   %INSTALL_DIR%
echo.
pause
start "" "%PYWEXE%" "%INSTALL_DIR%\py\planificador_app.pyw"

rmdir /s /q "%WORKDIR%" >nul 2>&1
exit /b 0

:probar
"%~1" -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)" >nul 2>&1
if not errorlevel 1 set "PYEXE=%~1"
exit /b 0

:::PSSTART
param([string]$self, [string]$dest)
$enc = New-Object System.Text.UTF8Encoding($false)
$lines = [System.IO.File]::ReadAllLines($self, $enc)
$i = 0
while ($i -lt $lines.Length) {
    $l = $lines[$i]
    if ($l.StartsWith(':::BEGIN ')) {
        $partes = $l.Substring(9).Trim().Split('|')
        $rel = $partes[0]
        $modo = $partes[1]
        $j = $i + 1
        $buf = New-Object System.Collections.Generic.List[string]
        while ($j -lt $lines.Length -and -not $lines[$j].StartsWith(':::END')) {
            $buf.Add($lines[$j])
            $j++
        }
        $destino = Join-Path $dest $rel
        $carpeta = Split-Path -Parent $destino
        if (-not (Test-Path -LiteralPath $carpeta)) {
            New-Item -ItemType Directory -Path $carpeta -Force | Out-Null
        }
        if ($modo -eq 'b64') {
            [System.IO.File]::WriteAllBytes($destino, [Convert]::FromBase64String(($buf -join '')))
        } else {
            [System.IO.File]::WriteAllText($destino, (($buf -join "`r`n") + "`r`n"), $enc)
        }
        $i = $j
    }
    $i++
}
:::PSEND

:::BANNERSTART
░▒▓█ ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════ █▓▒░
                                                              *#@@@@@@%#
                                                           *%%%%@@@@%%@%+#########
                                                         *#####%%%%+§+---+#%%@@@@@@@%#
                                                       *#####%%%@@#-+*+#%@@@@@@@@@@@@@%#
                                                      ##*##%##%%%@%*#%#*#%%%%%@@%####*
                                                     %##**#%%%%%%%%%%%*=*###%
                                                   #####**#%%%@@%%%%**#%%%%%
                                               *%@@%%###***##%%@%%%%%%%%%%#
                                            #@@@@@@@@@%%%%##**%#%%%%%%@@%%
                                         #%@@@@@@@@@@@@@@@%%%*##%%%%%%%%%%
                                      *%@@@@@@@@@@@###%%%%%%%##%%%@@%%%%%%#
                                    #@@@@%@%%@%%#*##%%%@%@@@@@%#%%@%%%#%%%
                                  #@@@@%%%#*****#%%@@@@@@@@@@@@##%%%#%#*%%
                                 %%@@%##***##%@@@@%@@@@@@@@@@@%%##%%##*#%
                              +#%%@%###%%%%@@@@@%@@%@@@@@@@@@##%%%%%%%##
                            *##**##%@%%@@@@@@@@@@@@@@@@%@@%%##%%%%%#####
                          ##**+#%@@%%%@@%%@%@@@@@%@%%%%@@@#*%%@%%#%%#%*
                        %###%@@@@%#%%%%%%%#%%#%%#%#*#%%%%*#%%%%@%%%%%
                     *%%%%@@@@%#*#######*##*****+++*#%%+*%%%@%%%#%##
                   *@@@@@@@@###@%@%%%%%%%#####*=*#%#%*+#%%#%%%%%##*
                  %@@@@@@%##%%@@@@@%%%%%%%%%%%#***++=#%%%#%%%###%+                                  ██╗  ██╗ ██╗   ██╗ ███████╗ ██████╗  ██████╗   ██████╗
                %%@@@@%###%@@@@@%#%%@@@@%%%%%#+--=+*#%@%%%%#**%%*                             #     ██║ ██╔╝ ██║   ██║ ██╔════╝ ██╔══██╗ ██╔══██╗ ██╔═████╗
               %@@@%#**%%%@@@%%##%#%@@%%%%#*==+*%%%%%%%%#*****#                             %@      █████╔╝  ██║   ██║ █████╗   ██████╔╝ ██████╔╝ ██║██╔██║
                ###*##%%@%%%%%%%#*#%%%%#+=-=+*#%####%%#+***+**                            #@@*      ██╔═██╗  ██║   ██║ ██╔══╝   ██╔══██╗ ██╔══██╗ ████╔╝██║
                #%%@@@@@@%@%%%#++=*++=====+==*******%**+++*#                             %@@%       ██║  ██╗ ╚██████╔╝ ███████╗ ██║  ██║ ██████╔╝ ╚██████╔╝
              #%%@@@@@@%%%%%*++***=-==++=++=*+=++***==+**#                              %@@#        ╚═╝  ╚═╝  ╚═════╝  ╚══════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═════╝
            *@%@@@%@%%%%#++=**++==+==-=---=-===+=##**##                               #@@%
           %@@@@%%###*++*#+#*+*#+=*= *--====--=**%*                                 *%@@@           Without data, you’re just another person with an opinion
         %@@@@%#***+=*#%#*+**++*+     ***##**++#*                                 #@@@@@@%#%@@@@%
       %@@@%%##* **#%%@*+*+**+          *%%*   *%%*                          *#%@@@@@@@@@@@@####
     %@@@%%%*   #%%%@%*++**+              %%#    #%%#                  ##%@@@@@@@@@@##
   #@@@@%*     %%@%%#++*#*                 #@%     *%@@##  ##**+#@@@@@@@@@@@@@@@#
  #@@@#       %@@%%#+#%%*                   %@@####%%%%%%%%%%@%%@@@@@@@@@@@@@@@@
 %@%*        %@@#%#*%%%*                #%%%%#%@%@%@@@%%%%%@@@@%@@@####        #@%
##          @@%#%#*%%%                 **%%@@@%%%#@#%%@@%%####+**                #@%#
           @@%%#*#%%%                *%@@@@@@@@%%%@@%##                            #%%
         #@@%%**#%@#               #@@@@@@@@@@@%%%%@                                 #
        #@%%#*#%#%              *@@@@@@@@@@%#
       %@%%##%%%              *%@@@@@@@@%*
      %@%%%%%%               %@@@@@@@@@#
      @# ##                #@@@@@@@@@#
                         #@@@@@@@@@%
                        %@@@@@@@@@#
                       @@@@@@@@@@#
                      @@@@@@@@@@#
                     @@@@@@@@@@#
                    @@@@@@@@@@%
                   %@@@@@@@@@%
░▒▓█ ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════ █▓▒░
:::BANNEREND
:::TITULOSTART

                                  ██╗ ███╗   ██╗ ███████╗ ████████╗  █████╗  ██╗       █████╗  ██████╗   ██████╗  ██████╗
                                  ██║ ████╗  ██║ ██╔════╝ ╚══██╔══╝ ██╔══██╗ ██║      ██╔══██╗ ██╔══██╗ ██╔═══██╗ ██╔══██╗
                                  ██║ ██╔██╗ ██║ ███████╗    ██║    ███████║ ██║      ███████║ ██║  ██║ ██║   ██║ ██████╔╝
                                  ██║ ██║╚██╗██║ ╚════██║    ██║    ██╔══██║ ██║      ██╔══██║ ██║  ██║ ██║   ██║ ██╔══██╗
                                  ██║ ██║ ╚████║ ███████║    ██║    ██║  ██║ ███████╗ ██║  ██║ ██████╔╝ ╚██████╔╝ ██║  ██║
                                  ╚═╝ ╚═╝  ╚═══╝ ╚══════╝    ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═════╝  ╚═╝  ╚═╝

                            ██████╗  ██╗       █████╗  ███╗   ██╗ ██╗ ███████╗ ██╗  ██████╗  █████╗  ██████╗   ██████╗  ██████╗
                            ██╔══██╗ ██║      ██╔══██╗ ████╗  ██║ ██║ ██╔════╝ ██║ ██╔════╝ ██╔══██╗ ██╔══██╗ ██╔═══██╗ ██╔══██╗
                            ██████╔╝ ██║      ███████║ ██╔██╗ ██║ ██║ █████╗   ██║ ██║      ███████║ ██║  ██║ ██║   ██║ ██████╔╝
                            ██╔═══╝  ██║      ██╔══██║ ██║╚██╗██║ ██║ ██╔══╝   ██║ ██║      ██╔══██║ ██║  ██║ ██║   ██║ ██╔══██╗
                            ██║      ███████╗ ██║  ██║ ██║ ╚████║ ██║ ██║      ██║ ╚██████╗ ██║  ██║ ██████╔╝ ╚██████╔╝ ██║  ██║
                            ╚═╝      ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═══╝ ╚═╝ ╚═╝      ╚═╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═════╝  ╚═╝  ╚═╝

                                                                    V E R S I Ó N   1.3.0
:::TITULOEND

:::BEGIN py/app_planificador.py|text
"""Planificador financiero — app Streamlit (se abre desde planificador_app.pyw).

Páginas (cada una en py/paginas/): 🏠 Hipoteca · 📈 Cartera · ⚖️ Comparador · 🌍 Mercado · ⏳ Plazos y riesgo ·
💰 Ahorrador · 🧩 Asignador · 🧭 Test de riesgo. Lo común (estilos, formato, ajustes y datos con caché) está en ui.py
y todos los cálculos en finanzas.py.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import streamlit as st  # noqa: E402

from ui import ICONO, VERSION, aplicar_estilos, fin, refrescar_mercado, modo_real  # noqa: E402

st.set_page_config(page_title="Planificador financiero", layout="wide",
                   page_icon=ICONO if os.path.exists(ICONO) else "💶")
aplicar_estilos()

from paginas.hipoteca import pag_hipoteca  # noqa: E402
from paginas.cartera import pag_cartera  # noqa: E402
from paginas.comparador import pag_comparador  # noqa: E402
from paginas.mercado import pag_mercado  # noqa: E402
from paginas.plazos import pag_plazos  # noqa: E402
from paginas.ahorrador import pag_ahorrador  # noqa: E402
from paginas.asignador import pag_asignador  # noqa: E402
from paginas.test_riesgo import pag_test  # noqa: E402


# =====================================================================  NAVEGACIÓN
PAGINAS = [
    st.Page(pag_hipoteca, title="Hipoteca", icon="🏠", default=True),
    st.Page(pag_cartera, title="Cartera", icon="📈", url_path="cartera"),
    st.Page(pag_comparador, title="Comparador", icon="⚖️", url_path="comparador"),
    st.Page(pag_mercado, title="Mercado", icon="🌍", url_path="mercado"),
    st.Page(pag_plazos, title="Plazos y riesgo", icon="⏳", url_path="plazos"),
    st.Page(pag_ahorrador, title="Ahorrador", icon="💰", url_path="ahorrador"),
    st.Page(pag_asignador, title="Asignador", icon="🧩", url_path="asignador"),
    st.Page(pag_test, title="Test de riesgo", icon="🧭", url_path="test"),
]
pg = st.navigation(PAGINAS, position="hidden")
sb = st.sidebar
for _p in PAGINAS:
    sb.page_link(_p)

_perf = fin.leer_perfiles()
if _perf["usuarios"]:
    lista = list(_perf["usuarios"])
    ya = _perf.get("activo") if _perf.get("activo") in lista else lista[0]
    nuevo = sb.selectbox("Usuario", lista, index=lista.index(ya), key="usuario_sel")
    if nuevo != _perf.get("activo"):
        fin.usuario_activo(nuevo)
    pf = _perf["usuarios"][nuevo]
    sb.caption(f"Perfil {pf['nivel']} · {pf['rv_sugerida']} % renta variable sugerido")
else:
    sb.caption("Sin perfil de riesgo: haz el test.")
_cfg = fin.leer_config()
st.session_state.setdefault("g_real", bool(_cfg.get("modo_real", False)))
st.session_state.setdefault("g_infl_eur", float(_cfg.get("inflacion_euro", fin.INFLACION_EURO_DEFECTO * 100)))
st.session_state.setdefault("g_bloque", int(_cfg.get("bloque_mc", fin.BLOQUE_DEFECTO)))


def _guardar_ajustes():
    fin.guardar_config(modo_real=bool(st.session_state["g_real"]), inflacion_euro=float(st.session_state["g_infl_eur"]),
                       bloque_mc=int(st.session_state["g_bloque"]))


with sb.expander("⚙️ Ajustes de simulación", expanded=False):
    st.toggle("Ver en términos reales (descontar inflación)", key="g_real", on_change=_guardar_ajustes,
              help="Bolsa (en dólares) deflactada con el IPC de EE.UU. (FRED); renta fija (en euros) con la inflación "
                   "de la zona euro (HICP del BCE) en los modos históricos y con la inflación esperada en el modo "
                   "de tipo constante. «Perder» pasa a significar perder poder adquisitivo.")
    st.number_input("Inflación esperada del euro (% anual)", 0.0, 10.0, step=0.25, key="g_infl_eur",
                    on_change=_guardar_ajustes, disabled=not modo_real(),
                    help="Se usa para pasar a real la renta fija a tipo constante. 2 % = objetivo del BCE.")
    st.slider("Monte Carlo: años seguidos por bloque", 1, 10, key="g_bloque", on_change=_guardar_ajustes,
              help="Block bootstrap: se sortean tramos de años consecutivos del pasado para conservar las rachas "
                   "(crisis de varios años, rebotes). 1 = años sueltos e independientes (método clásico).")
sb.caption("Modo **real** · dinero de hoy" if modo_real() else "Modo **nominal**")
if sb.button("Actualizar datos de mercado", help="Vuelve a descargar los índices (Yahoo Finance) y los tipos del BCE"):
    refrescar_mercado()
    st.rerun()
with sb.expander("📖 Glosario sencillo"):
    st.markdown(
        "- **TIN**: interés anual que cobra el banco, sin contar comisiones.\n"
        "- **TAE**: coste anual real del préstamo, con comisiones y seguros. Sirve para comparar ofertas.\n"
        "- **Euribor**: tipo de referencia al que se ligan las hipotecas variables.\n"
        "- **Amortizar**: devolver parte del dinero prestado antes de tiempo.\n"
        "- **Renta variable**: bolsa. Rinde más de media pero sube y baja mucho.\n"
        "- **Renta fija**: bonos y depósitos. Más estable y menos rentable.\n"
        "- **Buy and hold**: inviertes todo el primer día y lo dejas sin tocar.\n"
        "- **Promediar (DCA)**: inviertes poco a poco, con aportaciones periódicas.\n"
        "- **Euros de hoy**: cifras sin inflación, para entender cuánto valdría el dinero con los precios actuales.\n"
        "- **Modo real**: todo descontando la inflación (EE.UU. para la bolsa en dólares, zona euro para la renta "
        "fija).\n"
        "- **Block bootstrap**: Monte Carlo que sortea tramos de varios años seguidos en vez de años sueltos.\n"
        "- **Monte Carlo**: miles de simulaciones con años sorteados del pasado.\n"
        "- **Mal / buen escenario**: solo 1 de cada 20 casos sale peor / mejor que eso (percentiles 5 y 95).\n"
        "- **Volatilidad**: cuánto sube y baja una inversión de un año a otro.\n"
        "- **TIR anualizada**: rentabilidad anual constante equivalente a lo que realmente ganaste.\n"
        "- **Nota T**: escala de media 50 y desviación 10; en el Asignador se lee como % de bolsa ideal.\n"
        "- **Mal escenario anualizado**: rentabilidad anual del 1 de cada 20 peor de los casos históricos.\n"
        "- **Caída desde máximos (drawdown)**: cuánto está el índice por debajo de su mejor valor anterior.\n"
        "- **TER / comisión**: coste anual del fondo, que se resta a la rentabilidad.\n"
        "- **Tasa de retirada segura**: % del capital que puedes gastar cada año sin agotarlo (regla del 4 %).")
sb.caption(f"v{VERSION}")
if os.path.exists(ICONO):
    try:
        st.logo(ICONO, size="large")
    except Exception as e:                      # versiones de Streamlit sin st.logo(size=…)
        fin.registrar_error("st.logo", e)
pg.run()
:::END
:::BEGIN py/finanzas.py|text
"""Planificador financiero: toda la lógica de cálculo, sin Streamlit.

- Hipoteca: cuota francesa, tipo fijo / variable / mixto, amortización anticipada, TAE, gastos de compra.
- Datos de mercado: índices de bolsa (Yahoo Finance vía yfinance), tipos del euro (Banco Central Europeo) e
  inflación (IPC de EE.UU. de FRED para la bolsa en dólares; HICP de la zona euro del BCE para la renta fija).
- Modo real: la bolsa se deflacta con la inflación de EE.UU. y la renta fija con la de la zona euro.
- Simulación de cartera: Monte Carlo (block bootstrap de rentabilidades anuales) y ventanas históricas, con tres
  formas de modelar la renta fija (tipo constante, «carry» histórico y vencimiento objetivo).
- Test de tolerancia al riesgo de Grable y Lytton (13 preguntas) y perfiles guardados por usuario.
"""
import io
import json
import math
import os
import re
import time
import urllib.request
from datetime import datetime

import numpy as np
import pandas as pd

CARPETA = os.path.dirname(os.path.abspath(__file__))   # .../Planificador Financiero/py
BASE = os.path.dirname(CARPETA)                          # .../Planificador Financiero
CSV_DIR = os.path.join(BASE, "csv")
PERFILES = os.path.join(BASE, "perfiles_riesgo.json")
CONFIG = os.path.join(BASE, "config_planificador.json")


# =====================================================================  HIPOTECA
def cuota(capital, tin, meses):
    """Cuota mensual constante (sistema francés). tin en tanto por uno anual."""
    if meses <= 0 or capital <= 0:
        return 0.0
    i = tin / 12
    if abs(i) < 1e-12:
        return capital / meses
    return capital * i / (1 - (1 + i) ** -meses)


def n_pagos(capital, tin, pago):
    """Meses que hacen falta para liquidar `capital` pagando `pago` al mes."""
    i = tin / 12
    if pago <= 0:
        return math.inf
    if abs(i) < 1e-12:
        return capital / pago
    x = 1 - capital * i / pago
    return math.inf if x <= 0 else -math.log(x) / math.log(1 + i)


def tin_del_mes(mes, tipo, tin_fijo, diferencial, euribor, paso_euribor, anios_fijos):
    """TIN anual aplicable en el mes `mes` (0 = primer mes). Los tipos solo cambian al empezar un año."""
    anio = mes // 12
    variable = max(euribor + paso_euribor * anio, -diferencial) + diferencial   # nunca por debajo de 0 %
    if tipo == "Fijo":
        return tin_fijo
    if tipo == "Mixto":
        return tin_fijo if anio < anios_fijos else variable
    return variable


def cuadro(capital, anios, tipo="Fijo", tin_fijo=0.03, diferencial=0.01, euribor=0.025, paso_euribor=0.0,
           anios_fijos=5, extra_mensual=0.0, extra_anual=0.0, modo_extra="plazo"):
    """Cuadro de amortización mensual. modo_extra: 'plazo' (mantiene cuota, acorta plazo) o 'cuota'."""
    n = int(round(anios * 12))
    args = (tipo, tin_fijo, diferencial, euribor, paso_euribor, anios_fijos)
    saldo = float(capital)
    tin = tin_del_mes(0, *args)
    pago = cuota(saldo, tin, n)
    filas = []
    mes = 0
    while saldo > 0.005 and mes < n:
        nuevo = tin_del_mes(mes, *args)
        if mes > 0 and abs(nuevo - tin) > 1e-12:           # revisión de tipo: se recalcula la cuota
            if modo_extra == "plazo":
                resto = math.ceil(n_pagos(saldo, tin, pago) - 1e-9)
                resto = min(max(resto, 1), n - mes)
            else:
                resto = n - mes
            pago = cuota(saldo, nuevo, resto)
        tin = nuevo
        interes = saldo * tin / 12
        amort = min(max(pago - interes, 0.0), saldo)
        extra = extra_mensual + (extra_anual if mes % 12 == 11 else 0.0)
        extra = min(extra, saldo - amort)
        saldo = saldo - amort - extra
        if saldo < 0.005:
            saldo = 0.0
        filas.append((mes + 1, tin, interes + amort, interes, amort, extra, saldo))
        mes += 1
        if extra > 0 and modo_extra == "cuota" and saldo > 0 and n - mes > 0:
            pago = cuota(saldo, tin, n - mes)
    df = pd.DataFrame(filas, columns=["mes", "tin", "cuota", "intereses", "amortizacion", "extra", "saldo"])
    df["anio"] = (df["mes"] - 1) // 12 + 1
    return df


def tae(capital, cuadro_df, neto_inicial_resta=0.0, coste_mensual=0.0):
    """TAE (tasa anual equivalente). Flujo inicial = capital - gastos ligados al préstamo; después, cada
    cuota + coste mensual (seguros vinculados). Resuelta por bisección sobre la TIR mensual."""
    flujos = [capital - neto_inicial_resta] + [-(c + coste_mensual) for c in cuadro_df["cuota"]]
    f = np.array(flujos, dtype=float)

    def vp(r):
        return float(np.sum(f / (1 + r) ** np.arange(len(f))))
    lo, hi = -0.02, 0.2
    if vp(lo) * vp(hi) > 0:
        return float("nan")
    for _ in range(200):
        mid = (lo + hi) / 2
        if vp(lo) * vp(mid) <= 0:
            hi = mid
        else:
            lo = mid
    return (1 + (lo + hi) / 2) ** 12 - 1


def gastos_compra(precio, tipo_vivienda="Usada", itp=0.06, iva=0.10, ajd=0.0075, notaria_registro=2500.0,
                  tasacion=400.0, comision_apertura=0.0, capital=0.0):
    """Desglose de gastos de la compra. 'Usada' paga ITP; 'Nueva' paga IVA + AJD."""
    d = {}
    if tipo_vivienda == "Usada":
        d["ITP"] = precio * itp
    else:
        d["IVA"] = precio * iva
        d["AJD"] = precio * ajd
    d["Notaría, registro y gestoría"] = notaria_registro
    d["Tasación"] = tasacion
    d["Comisión de apertura"] = capital * comision_apertura
    return d


# =====================================================================  DATOS DE MERCADO
LOG_ERRORES = os.path.join(BASE, "errores.log")


LOG_MAX_BYTES = 1_000_000


def registrar_error(contexto, exc):
    """Guarda el error completo en errores.log (para saber por qué falla una descarga).
    Cuando el log pasa de 1 MB se renombra a errores.old.log y se empieza uno nuevo."""
    try:
        import traceback
        if os.path.exists(LOG_ERRORES) and os.path.getsize(LOG_ERRORES) > LOG_MAX_BYTES:
            os.replace(LOG_ERRORES, LOG_ERRORES.replace(".log", ".old.log"))
        with open(LOG_ERRORES, "a", encoding="utf-8") as f:
            f.write(f"{datetime.now():%Y-%m-%d %H:%M:%S} {contexto}: {exc!r}\n")
            f.write("".join(traceback.format_exception(exc))[-1500:] + "\n")
    except Exception:
        pass


AGENTE = "Mozilla/5.0 (Planificador)"


def _leer_url(url, timeout=60, agente=AGENTE):
    """Descarga texto probando varias vías: requests (con certifi), urllib normal y urllib con certifi.
    Así funciona aunque el almacén de certificados de Windows o el proxy den problemas."""
    errores = []
    try:
        import requests
        r = requests.get(url, headers={"User-Agent": agente} if agente else {}, timeout=timeout)
        r.raise_for_status()
        return r.text
    except Exception as e:
        errores.append(f"requests: {e!r}")
    req = urllib.request.Request(url, headers={"User-Agent": agente} if agente else {})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.read().decode("utf-8", errors="replace")
    except Exception as e:
        errores.append(f"urllib: {e!r}")
    try:
        import ssl
        import certifi
        ctx = ssl.create_default_context(cafile=certifi.where())
        with urllib.request.urlopen(req, timeout=timeout, context=ctx) as r:
            return r.read().decode("utf-8", errors="replace")
    except Exception as e:
        errores.append(f"urllib+certifi: {e!r}")
    raise RuntimeError(" | ".join(errores))


def _cache_valida(ruta, horas):
    return os.path.exists(ruta) and (time.time() - os.path.getmtime(ruta)) < horas * 3600


def _fin_mes(serie_o_df):
    try:
        return serie_o_df.resample("ME")
    except ValueError:                      # pandas antiguo
        return serie_o_df.resample("M")


def ecb_ultimo(flow, clave):
    """Último dato publicado de una serie del BCE (petición diminuta). Devuelve (valor en tanto por uno, fecha)."""
    url = (f"https://data-api.ecb.europa.eu/service/data/{flow}/{clave}"
           "?format=csvdata&lastNObservations=1&detail=dataonly")
    df = pd.read_csv(io.StringIO(_leer_url(url, 30)))
    return float(df["OBS_VALUE"].iloc[-1]) / 100, pd.to_datetime(str(df["TIME_PERIOD"].iloc[-1]))


def tipos_actuales(forzar=False):
    """Euribor 12m y bono euro a 10 años (AAA, BCE) más recientes. Cada uno falla por separado.
    Devuelve (dict, dict de errores)."""
    ruta = os.path.join(CSV_DIR, "tipos_actuales.json")
    cache = _leer_json(ruta, {})
    out, errs = {"euribor12m": None, "bono10": None}, {}
    fuentes = {"euribor12m": ("FM", "M.U2.EUR.RT.MM.EURIBOR1YD_.HSTA"),
               "bono10": ("YC", "B.U2.EUR.4F.G_N_A.SV_C_YM.SR_10Y")}
    hoy = datetime.now().strftime("%Y-%m-%d")
    for k, (flow, clave) in fuentes.items():
        c = cache.get(k)
        if c and c.get("dia") == hoy and not forzar:
            out[k], out[f"fecha_{k}"] = c["valor"], c["fecha"]
            continue
        try:
            v, f = ecb_ultimo(flow, clave)
            out[k], out[f"fecha_{k}"] = v, f.strftime("%Y-%m-%d")
            cache[k] = {"dia": hoy, "valor": v, "fecha": out[f"fecha_{k}"]}
        except Exception as e:
            registrar_error(f"BCE {k}", e)
            errs[k] = str(e)[:400]
            if c:                               # último valor conocido, aunque sea de otro día
                out[k], out[f"fecha_{k}"] = c["valor"], c["fecha"]
    try:
        os.makedirs(CSV_DIR, exist_ok=True)
        _escribir_json(ruta, cache)
    except Exception as e:
        registrar_error("Guardar tipos_actuales.json", e)
    return out, errs


def curva_bce(forzar=False):
    """Curva de tipos al contado del euro (bonos AAA de la zona euro, BCE). DataFrame mensual:
    índice = fin de mes, columnas = vencimiento en años (1..25), valores en tanto por uno.
    Solo se descarga cuando un modo de renta fija la necesita (son ~6 MB la primera vez)."""
    os.makedirs(CSV_DIR, exist_ok=True)
    ruta = os.path.join(CSV_DIR, "bce_curva_euro.csv")
    if not forzar and _cache_valida(ruta, 24 * 7):
        return pd.read_csv(ruta, index_col=0, parse_dates=True).rename(columns=int)
    try:
        venc = "+".join(f"SR_{m}Y" for m in range(1, 26))
        url = ("https://data-api.ecb.europa.eu/service/data/YC/"
               f"B.U2.EUR.4F.G_N_A.SV_C_YM.{venc}?format=csvdata&startPeriod=2004-09-06&detail=dataonly")
        df = pd.read_csv(io.StringIO(_leer_url(url, 300)))
        df["venc"] = df["KEY"].str.extract(r"SR_(\d+)Y")[0].astype(int)
        df["fecha"] = pd.to_datetime(df["TIME_PERIOD"])
        piv = df.pivot_table(index="fecha", columns="venc", values="OBS_VALUE") / 100
        mensual = _fin_mes(piv).last().dropna(how="all")
        mensual.to_csv(ruta)
        return mensual
    except Exception as e:
        registrar_error("BCE curva", e)
        if os.path.exists(ruta):
            return pd.read_csv(ruta, index_col=0, parse_dates=True).rename(columns=int)
        raise


# Índices de renta variable. Todos en dólares y con dividendos reinvertidos, SIN convertir a euros.
# Cada índice es una lista de tramos (símbolo de Yahoo, primer año que se usa de ese símbolo, dividendo a sumar).
# El MSCI World de Yahoo (^990100-USD-STRD) es de PRECIO, sin dividendos: Yahoo no publica la versión «net return».
# Se le suma una rentabilidad por dividendo neta media aproximada (MSCI World 1972-2008: ~3,5-4 % en los 70,
# ~3 % en los 80 y ~2 % de 1995 a 2008 → ~2,75 % neta de retenciones de media). VT, VTSMX y ^SP500TR ya
# incluyen los dividendos (precio ajustado / índice total return).
DIV_MSCI_WORLD = 0.0275
INDICES = {
    "Mundo largo: MSCI World hasta 2008 + Vanguard Total World (VT)":
        {"tramos": [("^990100-USD-STRD", 1972, DIV_MSCI_WORLD), ("VT", 2009, 0.0)], "desde": 1973},
    "Vanguard Total World (VT)": {"tramos": [("VT", 2009, 0.0)], "desde": 2009},
    "Vanguard Total Stock Market EE.UU. (VTSMX)": {"tramos": [("VTSMX", 1993, 0.0)], "desde": 1993},
    "S&P 500 con dividendos": {"tramos": [("^SP500TR", 1988, 0.0)], "desde": 1989},
}
INDICE_DEFECTO = next(iter(INDICES))


def _descargar_yahoo(simbolo):
    import yfinance as yf
    for intento in range(3):
        try:
            px = yf.download(simbolo, period="max", interval="1d", auto_adjust=True, progress=False)["Close"]
            if isinstance(px, pd.DataFrame):
                px = px.iloc[:, 0]
            px = px.dropna()
            if len(px):
                return px
        except Exception:
            if intento == 2:
                raise
        time.sleep(2 * (intento + 1))
    raise RuntimeError(f"Yahoo Finance no devuelve datos de {simbolo}")


CACHE_VERSION = "v2"     # súbelo si cambia cómo se construyen los índices (invalida las cachés viejas)


def indice_nivel(nombre, freq="M", forzar=False, real=False):
    """Nivel (base 100) del índice elegido, encadenando tramos si hace falta.
    freq: 'M' = fin de mes, 'W' = viernes de cada semana. real=True: deflactado con el IPC de EE.UU.
    (la caché en disco siempre guarda la serie nominal)."""
    nivel = _indice_nominal(nombre, freq, forzar)
    return deflactar(nivel, ipc_eeuu()) if real else nivel


def _indice_nominal(nombre, freq="M", forzar=False):
    os.makedirs(CSV_DIR, exist_ok=True)
    clave = re.sub(r"[^a-z0-9]+", "_", nombre.lower())[:40]
    ruta = os.path.join(CSV_DIR, f"indice_{'sem_' if freq == 'W' else ''}{clave}_{CACHE_VERSION}.csv")
    if not forzar and _cache_valida(ruta, 24):
        return pd.read_csv(ruta, index_col=0, parse_dates=True)["nivel"]
    try:
        tramos = INDICES[nombre]["tramos"]
        pasos = 52 if freq == "W" else 12
        rets = []
        for i, (simbolo, desde, div) in enumerate(tramos):
            px = _descargar_yahoo(simbolo)
            px.index = pd.to_datetime(px.index).tz_localize(None)
            serie = (px.resample("W-FRI").last() if freq == "W" else _fin_mes(px).last()).dropna()
            r = serie.pct_change()
            if div:                                   # índice de precio: se suman los dividendos
                r = (1 + r) * (1 + div) ** (1 / pasos) - 1
            hasta = tramos[i + 1][1] if i + 1 < len(tramos) else 9999
            rets.append(r[(r.index.year >= desde - (1 if i == 0 else 0)) & (r.index.year < hasta)])
        r = pd.concat(rets).dropna()
        nivel = (1 + r).cumprod() * 100
        nivel.name = "nivel"
        nivel.to_frame().to_csv(ruta)
        return nivel
    except Exception as e:
        registrar_error(f"Yahoo {nombre} ({freq})", e)
        if os.path.exists(ruta):
            return pd.read_csv(ruta, index_col=0, parse_dates=True)["nivel"]
        raise


def indice_mensual(nombre, forzar=False, real=False):
    return indice_nivel(nombre, "M", forzar, real)


def indice_semanal(nombre, forzar=False, real=False):
    return indice_nivel(nombre, "W", forzar, real)


def indice_anual(nombre, forzar=False, real=False):
    """Rentabilidades anuales (diciembre a diciembre) del índice. Descarta el año en curso."""
    nivel = indice_mensual(nombre, forzar, real)
    fin_anio = nivel.groupby(nivel.index.year).last()
    ret = fin_anio.pct_change().dropna()
    hoy = datetime.now()
    if ret.index.max() >= hoy.year and hoy.month < 12:
        ret = ret[ret.index < hoy.year]
    desde = INDICES[nombre]["desde"]
    ret = ret[ret.index >= desde]
    ret.name = "ret"
    ret.index.name = "anio"
    return ret


# =====================================================================  INFLACIÓN
INFLACION_EURO_DEFECTO = 0.02      # objetivo del BCE: inflación esperada para la renta fija a tipo constante


def _serie_mensual_cache(nombre_csv, descargar, forzar=False, dias=7):
    """Serie mensual (índice = primer día del mes) con caché en csv/ y respaldo a la última copia."""
    ruta = os.path.join(CSV_DIR, nombre_csv)
    if not forzar and _cache_valida(ruta, 24 * dias):
        return pd.read_csv(ruta, index_col=0, parse_dates=True).iloc[:, 0]
    try:
        s = descargar().dropna().sort_index()
        if s.empty:
            raise RuntimeError(f"{nombre_csv}: serie vacía")
        os.makedirs(CSV_DIR, exist_ok=True)
        s.rename("valor").to_frame().to_csv(ruta)
        return s
    except Exception as e:
        registrar_error(f"Inflación {nombre_csv}", e)
        if os.path.exists(ruta):
            return pd.read_csv(ruta, index_col=0, parse_dates=True).iloc[:, 0]
        raise


def ipc_eeuu(forzar=False):
    """IPC de EE.UU. (CPI-U, todos los artículos, sin desestacionalizar; FRED CPIAUCNS), mensual desde 1913."""
    def bajar():
        # FRED corta las peticiones con agentes inventados: se usa el de la librería (agente=None)
        txt = _leer_url("https://fred.stlouisfed.org/graph/fredgraph.csv?id=CPIAUCNS", 60, agente=None)
        df = pd.read_csv(io.StringIO(txt))
        return pd.Series(pd.to_numeric(df.iloc[:, 1], errors="coerce").values,
                         index=pd.to_datetime(df.iloc[:, 0]), name="valor")
    return _serie_mensual_cache("ipc_eeuu.csv", bajar, forzar)


def hicp_euro(forzar=False):
    """Índice de precios armonizado de la zona euro (HICP, BCE ICP.M.U2.N.000000.4.INX), mensual desde 1996."""
    def bajar():
        url = ("https://data-api.ecb.europa.eu/service/data/ICP/M.U2.N.000000.4.INX"
               "?format=csvdata&detail=dataonly")
        df = pd.read_csv(io.StringIO(_leer_url(url, 60)))
        return pd.Series(df["OBS_VALUE"].astype(float).values, index=pd.to_datetime(df["TIME_PERIOD"]),
                         name="valor")
    return _serie_mensual_cache("hicp_euro.csv", bajar, forzar)


def deflactar(nivel, ipc):
    """Pasa una serie de niveles a términos reales: divide por el IPC del mes de cada fecha (los meses que aún no
    se han publicado usan el último dato) y vuelve a base 100."""
    ipc_m = pd.Series(np.asarray(ipc, dtype=float), index=pd.DatetimeIndex(ipc.index).to_period("M"))
    ipc_m = ipc_m[~ipc_m.index.duplicated(keep="last")]
    periodos = pd.DatetimeIndex(nivel.index).to_period("M")
    rango = pd.period_range(min(ipc_m.index.min(), periodos.min()), max(ipc_m.index.max(), periodos.max()), freq="M")
    p = ipc_m.reindex(rango).ffill().bfill().reindex(periodos).values
    real = np.asarray(nivel, dtype=float) / p
    return pd.Series(real / real[0] * 100, index=nivel.index, name=nivel.name)


def inflacion_anual(ipc):
    """Inflación diciembre a diciembre por año (Series índice = año). El año en curso no se incluye."""
    s = pd.Series(np.asarray(ipc, dtype=float), index=pd.DatetimeIndex(ipc.index))
    dic = s[s.index.month == 12]
    inf = dic.pct_change().dropna()
    inf.index = inf.index.year
    inf.index.name = "anio"
    return inf


def tasa_real(nominal, inflacion):
    """Rentabilidad real (Fisher exacta): (1 + nominal) / (1 + inflación) − 1."""
    return (1 + nominal) / (1 + inflacion) - 1


# =====================================================================  SIMULACIÓN DE CARTERA
MODOS_RF = ["Tipo constante", "Histórico (carry 10 años)", "Vencimiento objetivo"]


def _frac(m):
    """Fracción del año que cada aportación pasa invertida. Anual (m=1): 1. Mensual (m=12): 1, 11/12, ..., 1/12."""
    return np.array([(m - j) / m for j in range(m)])


def trayectoria_mc(R, r_rf, w_rv, inicial, aporte, m=1):
    """R: (N, H) rentabilidades anuales de renta variable; r_rf: escalar, (H,) o (N, H).
    Capital inicial el día 1 y `aporte` al año repartido en m aportaciones iguales (m=1 anual, m=12 mensual).
    Sin rebalanceo: cada aportación se reparte según w_rv y después crece por su cuenta.
    Devuelve (N, H) con el valor de la cartera al final de cada año."""
    N, H = R.shape
    r_rf = np.broadcast_to(np.asarray(r_rf, dtype=float), (N, H)) if np.ndim(r_rf) else np.full((N, H), r_rf)
    fr = _frac(m)
    rv = np.zeros(N)
    rf = np.zeros(N)
    out = np.zeros((N, H))
    for k in range(H):
        gr, gf = 1 + R[:, k], 1 + r_rf[:, k]
        ini = inicial if k == 0 else 0.0
        rv = rv * gr + w_rv * (ini * gr + (aporte / m) * (gr[:, None] ** fr).sum(1))
        rf = rf * gf + (1 - w_rv) * (ini * gf + (aporte / m) * (gf[:, None] ** fr).sum(1))
        out[:, k] = rv + rf
    return out


BLOQUE_DEFECTO = 5     # años seguidos por bloque en el Monte Carlo


def muestras_bloques(ret_hist, n, H, bloque=BLOQUE_DEFECTO, semilla=7):
    """Block bootstrap circular: en vez de sortear años sueltos se sortean tramos de `bloque` años SEGUIDOS del
    histórico (dando la vuelta al final), así se conserva que a un año malo le suele seguir otro malo o un rebote.
    bloque=1 es el bootstrap clásico de años independientes. Devuelve (n, H)."""
    r = np.asarray(ret_hist, dtype=float)
    L = len(r)
    b = int(max(1, min(bloque, L)))
    nb = -(-H // b)                                   # bloques necesarios (redondeo hacia arriba)
    rng = np.random.default_rng(semilla)
    inicios = rng.integers(0, L, size=(n, nb))
    idx = (inicios[:, :, None] + np.arange(b)) % L
    return r[idx.reshape(n, nb * b)[:, :H]]


def montecarlo(ret_hist, H, w_rv, r_rf, inicial, aporte, n=5000, semilla=7, m=1, bloque=BLOQUE_DEFECTO):
    """Monte Carlo con block bootstrap del histórico de rentabilidades anuales. Renta fija a tipo constante."""
    R = muestras_bloques(ret_hist, n, H, bloque, semilla)
    return trayectoria_mc(R, r_rf, w_rv, inicial, aporte, m)


def ventanas_historicas(ret_rv, curva, H, w_rv, modo, inicial, aporte, r_const=0.03, m=1, infl_rf=None):
    """Una simulación por cada año de inicio posible usando los años reales.
    modo: 'Tipo constante' | 'Histórico (carry 10 años)' | 'Vencimiento objetivo'.
    infl_rf: inflación anual de la zona euro por año (Series). Si se pasa, la renta fija de los modos históricos
    se pasa a términos reales con la inflación de cada año (y se descartan los años sin dato).
    Devuelve (DataFrame trayectorias [ventana x año], lista de años de inicio)."""
    fr = _frac(m)
    # rendimiento del bono: tipo vigente a 31-dic del año anterior (el que se pudo comprar el 1 de enero)
    y_ini = curva.groupby(curva.index.year).last() if curva is not None else None
    inicios, trays = [], []
    for s in sorted(ret_rv.index):
        anios = range(s, s + H)
        if any(a not in ret_rv.index for a in anios):
            continue
        if modo != "Tipo constante" and any((a - 1) not in y_ini.index for a in anios):
            continue
        if modo != "Tipo constante" and infl_rf is not None and any(a not in infl_rf.index for a in anios):
            continue
        pi = [float(infl_rf[s + k]) if (infl_rf is not None and modo != "Tipo constante") else 0.0
              for k in range(H)]

        def recursion(tasas, peso):
            v, out = 0.0, np.zeros(H)
            for k in range(H):
                g = 1 + tasas[k]
                ini = inicial if k == 0 else 0.0
                v = v * g + peso * (ini * g + (aporte / m) * np.sum(g ** fr))
                out[k] = v
            return out

        rv_val = recursion([ret_rv[s + k] for k in range(H)], w_rv)      # parte de renta variable
        if modo == "Tipo constante":
            rf_val = recursion([r_const] * H, 1 - w_rv)
        elif modo == "Histórico (carry 10 años)":
            rf_val = recursion([tasa_real(y_ini.loc[s + k - 1, 10], pi[k]) for k in range(H)], 1 - w_rv)
        else:                                  # vencimiento objetivo: compra a (H-k) años y mantiene hasta el final
            rf_val = np.zeros(H)
            for k in range(H):
                y = y_ini.loc[s + k - 1, int(min(H - k, 25))]
                g = np.array([(1 + y) / (1 + pi[j]) for j in range(H)])     # crecimiento real de cada año
                ini = inicial if k == 0 else 0.0
                for t in range(k, H):
                    resto = float(np.prod(g[k + 1:t + 1]))
                    rf_val[t] += (1 - w_rv) * (ini * g[k] * resto + (aporte / m) * np.sum(g[k] ** fr) * resto)
        total = rv_val + rf_val
        if not np.all(np.isfinite(total)):          # faltan tipos de ese vencimiento en esos años
            continue
        trays.append(total)
        inicios.append(s)
    if not trays:
        return pd.DataFrame(), []
    return pd.DataFrame(trays, index=inicios, columns=range(1, H + 1)), inicios


def resumen_trayectorias(tray, aportado, inicial, aporte, H, m=1):
    """Estadísticas del valor final de una tabla [simulación x año]."""
    final = np.asarray(tray)[:, -1]
    p = np.percentile(final, [5, 25, 50, 75, 95])
    return {
        "p5": p[0], "p25": p[1], "mediana": p[2], "p75": p[3], "p95": p[4],
        "minimo": float(final.min()), "maximo": float(final.max()),
        "prob_perdida": float(np.mean(final < aportado)),
        "multiplo_mediana": float(p[2] / aportado) if aportado else float("nan"),
        "tir_mediana": tir_anual(inicial, aporte, H, p[2], m),
    }


def tir_anual(inicial, aporte, H, final, m=1):
    """Rentabilidad anual equivalente (TIR) de un resultado final dado."""
    tiempos = [0.0] + [k + j / m for k in range(H) for j in range(m)]
    importes = [inicial] + [aporte / m] * (H * m)
    if final <= 0 or sum(importes) <= 0:
        return float("nan")

    def vf(r):
        return sum(a * (1 + r) ** (H - t) for t, a in zip(tiempos, importes))
    lo, hi = -0.9, 1.0
    if vf(lo) > final or vf(hi) < final:
        return float("nan")
    for _ in range(200):
        mid = (lo + hi) / 2
        if vf(mid) < final:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


def ventanas_moviles(nivel, horizontes, w_rv, r_rf, pasos_por_anio=12, min_ventanas=None):
    """Ventanas móviles que se solapan. `nivel` es una serie de niveles del índice con `pasos_por_anio` puntos al año
    (1 = niveles de fin de año, con el nivel inicial incluido: N años dan N+1 puntos y N−h+1 ventanas de h años;
    12 = niveles de fin de mes). Para cada horizonte h (años) mira TODAS las ventanas de h años y calcula, para una cartera invertida de golpe el primer
    día (sin rebalanceo) con w_rv en bolsa y el resto en renta fija a r_rf constante:
    probabilidad de perder dinero (acabar por debajo de lo invertido) y rentabilidad anual de las ventanas."""
    v = np.asarray(nivel, dtype=float)
    min_ventanas = min_ventanas or (12 if pasos_por_anio > 1 else 3)
    filas = []
    for h in horizontes:
        k = pasos_por_anio * h
        if len(v) - k < min_ventanas:       # muy pocas ventanas para decir nada
            continue
        rv = v[k:] / v[:-k]                  # múltiplo del índice en cada ventana
        port = w_rv * rv + (1 - w_rv) * (1 + r_rf) ** h
        anual = port ** (1 / h) - 1
        q = np.percentile(anual, [5, 25, 50, 75, 95])
        filas.append({"anios": h, "ventanas": len(port), "independientes": ventanas_independientes(len(v), k),
                      "prob_perder": float(np.mean(port < 1)),
                      "prob_perder_bolsa": float(np.mean(rv < 1)), "peor": float(anual.min()),
                      "p5": q[0], "p25": q[1], "mediana": q[2], "p75": q[3], "p95": q[4],
                      "mejor": float(anual.max())})
    return pd.DataFrame(filas)


def ventanas_independientes(n_puntos, pasos):
    """Ventanas que NO se solapan entre sí: (puntos − 1) // pasos. Las ventanas solapadas comparten casi todos sus
    datos, así que esta cifra es la que dice cuánta información independiente hay detrás de una probabilidad."""
    return max(int((n_puntos - 1) // max(pasos, 1)), 0)


def prob_perder_semanal(v, pesos, r_rf, max_semanas=1560, ma=52, min_ventanas=52, estrategia="hold"):
    """Probabilidad de perder dinero según el plazo en SEMANAS (1, 2, 3 … max_semanas), con ventanas que empiezan
    cada semana y se solapan, para cada reparto de `pesos` (fracción en bolsa; el resto, renta fija a r_rf).
    Inversión de golpe el primer día, sin rebalanceo. Devuelve (sin_suavizar, suavizada): DataFrames con índice =
    plazo en semanas y una columna por reparto. La suavizada es la media móvil centrada de `ma` plazos consecutivos
    y solo contiene los puntos con `ma` plazos completos (se descartan los extremos).
    estrategia='hold': todo el dinero el primer día (buy and hold).
    estrategia='dca': el mismo dinero repartido en aportaciones iguales al inicio de cada semana del plazo."""
    v = np.asarray(v, dtype=float)
    n = len(v)
    horizontes = [h for h in range(1, max_semanas + 1) if n - h >= min_ventanas]
    g = (1 + r_rf) ** (1 / 52)                  # crecimiento semanal de la renta fija
    suma_inv = np.concatenate([[0.0], np.cumsum(1.0 / v)])
    datos = {w: np.empty(len(horizontes)) for w in pesos}
    for i, h in enumerate(horizontes):
        if estrategia == "dca":
            # cada semana j se compra 1/h y se mantiene hasta el final: Σ_j (1/h)·v[fin]/v[j]
            rv = v[h:] * (suma_inv[h:n] - suma_inv[:n - h]) / h
            rf = (h if abs(g - 1) < 1e-12 else g * (g ** h - 1) / (g - 1)) / h
        else:
            rv = v[h:] / v[:-h]
            rf = (1 + r_rf) ** (h / 52)
        for w in pesos:
            datos[w][i] = np.mean(w * rv + (1 - w) * rf < 1)
    raw = pd.DataFrame(datos, index=pd.Index(horizontes, name="semanas"))
    suav = raw.rolling(ma, center=True, min_periods=ma).mean().dropna(how="all")
    return raw, suav


def semanas_para_riesgo(serie, maximo):
    """Menor plazo (semanas) a partir del cual la serie (prob. de perder suavizada) se queda siempre ≤ maximo."""
    s = serie.dropna()
    ok = (s <= maximo).values
    for i in range(len(ok)):
        if ok[i:].all():
            return int(s.index[i])
    return None


def anios_para_riesgo(df, columna, maximo):
    """Menor horizonte a partir del cual la probabilidad de perder se queda siempre ≤ maximo (o None)."""
    ok = (df[columna] <= maximo).values
    for i in range(len(ok)):
        if ok[i:].all():
            return int(df["anios"].iloc[i])
    return None


def riesgo_referencia(ret_rv, w_rv, r_rf):
    """Cartera de referencia con rebalanceo anual: rentabilidad media, volatilidad y peor año históricos."""
    r = w_rv * np.asarray(ret_rv, dtype=float) + (1 - w_rv) * r_rf
    return {"media": float(r.mean()), "vol": float(r.std(ddof=1)), "peor": float(r.min()),
            "mejor": float(r.max())}


def frontera(ret_rv, r_rf, H, inicial, aporte, n=3000, paso=10, m=1, bloque=BLOQUE_DEFECTO):
    """Tabla riesgo/rentabilidad para renta variable 0-100 %: sirve para ver el efecto del reparto."""
    filas = []
    aportado = inicial + aporte * H
    for w in range(0, 101, paso):
        t = montecarlo(ret_rv, H, w / 100, r_rf, inicial, aporte, n=n, m=m, bloque=bloque)
        s = resumen_trayectorias(t, aportado, inicial, aporte, H, m)
        ref = riesgo_referencia(ret_rv, w / 100, r_rf)
        filas.append({"% renta variable": w, "Vol. anual": ref["vol"], "Peor año": ref["peor"],
                      "Mediana final": s["mediana"], "P5 final": s["p5"], "Prob. pérdida": s["prob_perdida"],
                      "TIR mediana": s["tir_mediana"]})
    return pd.DataFrame(filas)


# =====================================================================  AHORRADOR
def r_mensual(nominal, inflacion=0.0, real=True):
    """Rentabilidad mensual equivalente. Con real=True descuenta la inflación (todo en euros de hoy)."""
    anual = (1 + nominal) / (1 + inflacion) - 1 if real else nominal
    return (1 + anual) ** (1 / 12) - 1


def capital_para_renta(d, meses, r_m, pesos=None):
    """Capital que hace falta para retirar `d` al mes durante `meses` (retirada a principio de mes).
    Si se pasa `pesos` (probabilidad de seguir vivo cada mes), cada retirada se pondera por ella."""
    if meses <= 0 or d <= 0:
        return 0.0
    if pesos is not None:
        w = np.asarray(pesos, dtype=float)[:meses]
        return float(d * np.sum(w * (1 + r_m) ** -np.arange(len(w))))
    if abs(r_m) < 1e-12:
        return d * meses
    return d * (1 - (1 + r_m) ** -meses) / r_m * (1 + r_m)


def factor_aportaciones(N, r_m, g=0.0):
    """Valor final de aportar 1 € al mes (a principio de mes) durante N meses, con la aportación subiendo un
    porcentaje `g` cada año. El capital final es: aportación inicial × este factor."""
    t = np.arange(N)
    return float(np.sum((1 + g) ** (t // 12) * (1 + r_m) ** (N - t)))


def trayectoria(ahorro0, aporte, N, n_ret, retirada, r_pre, r_post, g=0.0):
    """Saldo (euros de hoy) al final de cada mes: N meses ahorrando y luego n_ret meses retirando `retirada`."""
    saldo = [float(ahorro0)]
    b = float(ahorro0)
    for t in range(N):
        b = (b + aporte * (1 + g) ** (t // 12)) * (1 + r_pre)
        saldo.append(b)
    ret = np.broadcast_to(np.asarray(retirada, dtype=float), (n_ret,)) if n_ret > 0 else []
    for k in range(n_ret):
        b = max((b - ret[k]) * (1 + r_post), 0.0)
        saldo.append(b)
    return np.array(saldo)


def plan_jubilacion(edad, edad_ret, edad_fin, gasto_mes, pension, ahorro0, aporte_actual,
                    rent_pre, rent_post, inflacion, g=0.0, pesos=None):
    """Todo en euros de hoy. Devuelve capital necesario, aportación mensual necesaria y qué pasa con la actual.
    `pesos`: probabilidad mensual de seguir vivo desde la jubilación (None = vivir hasta `edad_fin` seguro)."""
    N, n_ret = int(round((edad_ret - edad) * 12)), int(round((edad_fin - edad_ret) * 12))
    r_pre, r_post = r_mensual(rent_pre, inflacion), r_mensual(rent_post, inflacion)
    necesidad = max(gasto_mes - pension, 0.0)
    K = capital_para_renta(necesidad, n_ret, r_post, pesos)
    fac = factor_aportaciones(N, r_pre, g)
    crece = ahorro0 * (1 + r_pre) ** N
    P = max((K - crece) / fac, 0.0) if fac > 0 else float("nan")
    cap_actual = crece + aporte_actual * fac
    unidad = capital_para_renta(1.0, n_ret, r_post, pesos)
    return {"N": N, "n_ret": n_ret, "necesidad": necesidad, "capital": K, "aporte": P,
            "crece_ahorro": crece, "capital_actual": cap_actual,
            "renta_actual": cap_actual / unidad if unidad else float("nan"),
            "r_pre": r_pre, "r_post": r_post, "factor": fac}


# --- mortalidad (INE, tablas de mortalidad de España)
EDAD_MAX_TABLA = 110


def _descargar_ine_mortalidad():
    """Riesgo de muerte q(x) por edad (0..100) y sexo, último año disponible. Tabla INE 27153 (por 1.000)."""
    import json
    txt = _leer_url("https://servicios.ine.es/wstempus/js/ES/DATOS_TABLA/27153?nult=1", timeout=90)
    filas = []
    for serie in json.loads(txt):
        n = serie["Nombre"]
        if ". Riesgo de muerte." not in n or not serie.get("Data"):
            continue
        partes = n.split(". ")
        sexo = {"Hombres": "H", "Mujeres": "M", "Total": "T"}.get(partes[1])
        m = re.match(r"(\d+)", partes[2])
        if sexo and m:
            d = serie["Data"][-1]
            filas.append({"sexo": sexo, "edad": int(m.group(1)), "qx": float(d["Valor"]) / 1000.0,
                          "anio": d.get("Anyo")})
    df = pd.DataFrame(filas).sort_values(["sexo", "edad"])
    if df.empty:
        raise RuntimeError("El INE no devolvió la tabla de mortalidad")
    return df


def tabla_mortalidad(forzar=False):
    """DataFrame sexo/edad/qx/anio con caché en csv/mortalidad_ine.csv."""
    ruta = os.path.join(CSV_DIR, "mortalidad_ine.csv")
    if not forzar and os.path.exists(ruta):
        try:
            return pd.read_csv(ruta)
        except Exception as e:
            registrar_error("Leer mortalidad_ine.csv", e)
    try:
        df = _descargar_ine_mortalidad()
        os.makedirs(CSV_DIR, exist_ok=True)
        df.to_csv(ruta, index=False)
        return df
    except Exception as e:
        registrar_error("Mortalidad INE", e)
        if os.path.exists(ruta):
            return pd.read_csv(ruta)
        raise


def qx_por_edad(df, sexo="T"):
    """Array q[0..EDAD_MAX_TABLA]: el INE agrupa 100 y más (q=1), así que de 100 a 110 se extrapola con el
    ritmo de crecimiento de las edades previas y se fuerza q=1 a la edad máxima."""
    t = df[df["sexo"] == sexo].set_index("edad")["qx"]
    q = np.ones(EDAD_MAX_TABLA + 1)
    for a in range(0, 100):
        q[a] = float(t.get(a, 1.0))
    ratio = min(max(q[99] / q[98], 1.0), 1.25) if q[98] > 0 else 1.15
    for a in range(100, EDAD_MAX_TABLA):
        q[a] = min(q[a - 1] * ratio, 0.999)
    q[EDAD_MAX_TABLA] = 1.0
    return q


def pesos_supervivencia(edad_ret, q, edad_max=EDAD_MAX_TABLA):
    """Probabilidad de seguir vivo cada mes desde la jubilación (=1 el primer mes, sabiendo que se llega vivo),
    hasta `edad_max`. Dentro de cada año la supervivencia se interpola de forma exponencial."""
    n = int(round((edad_max - edad_ret) * 12))
    if n <= 0:
        return np.array([])
    p = 1.0
    edad0 = int(np.floor(edad_ret))
    frac0 = edad_ret - edad0
    w = np.empty(n)
    for k in range(n):
        if k > 0:   # el mes k-1 ya se ha vivido: se aplica la mortalidad de esa edad
            a = min(edad0 + int((frac0 * 12 + k - 1) // 12), EDAD_MAX_TABLA)
            p *= (1 - min(q[a], 1.0)) ** (1 / 12)
        w[k] = p
    return w


def edad_prudente(edad_ret, q, umbral=0.10):
    """Edad a la que la probabilidad de seguir vivo (sabiendo que se llega a `edad_ret`) baja de `umbral`.
    Planificar hasta esa edad cubre el riesgo de vivir más de lo esperado en 9 de cada 10 casos."""
    w = pesos_supervivencia(edad_ret, q)
    debajo = np.nonzero(w < umbral)[0]
    k = int(debajo[0]) if debajo.size else len(w)
    return edad_ret + k / 12


def esperanza_vida(edad_ret, q):
    """Años esperados de vida restantes a partir de la jubilación."""
    w = pesos_supervivencia(edad_ret, q)
    return float(w.sum() / 12)


# --- meta de ahorro
def meses_para_meta(objetivo, ahorro0, aporte, i_m):
    """Meses (enteros) hasta llegar a `objetivo` ahorrando `aporte` al mes (a principio de mes) con rentabilidad
    mensual i_m. 0 si ya se alcanza; None si no se alcanzará nunca."""
    if ahorro0 >= objetivo:
        return 0
    if abs(i_m) < 1e-12:
        return int(math.ceil((objetivo - ahorro0) / aporte)) if aporte > 0 else None
    k = aporte * (1 + i_m) / i_m
    if i_m < 0 and aporte <= 0:
        return None
    num_, den = objetivo + k, ahorro0 + k
    if den <= 0 or num_ <= 0 or num_ / den <= 1:
        return None
    return int(math.ceil(math.log(num_ / den) / math.log(1 + i_m) - 1e-9))


def aporte_para_meta(objetivo, ahorro0, meses, i_m):
    """Aportación mensual necesaria para llegar a `objetivo` en `meses`."""
    if meses <= 0:
        return float("nan")
    if abs(i_m) < 1e-12:
        return max((objetivo - ahorro0) / meses, 0.0)
    cre = (1 + i_m) ** meses
    return max((objetivo - ahorro0 * cre) * i_m / ((1 + i_m) * (cre - 1)), 0.0)


def serie_ahorro(ahorro0, aporte, meses, i_m):
    """Evolución mensual: total acumulado, lo aportado (incluye el ahorro inicial) y los intereses."""
    saldo, filas = float(ahorro0), [(0, float(ahorro0), float(ahorro0), 0.0)]
    for m in range(1, meses + 1):
        saldo = (saldo + aporte) * (1 + i_m)
        aportado = ahorro0 + aporte * m
        filas.append((m, saldo, aportado, saldo - aportado))
    return pd.DataFrame(filas, columns=["mes", "total", "aportado", "intereses"])


# =====================================================================  TEST DE RIESGO (Grable y Lytton)
# Cada pregunta: (enunciado, [(texto, puntos), ...]). Adaptación al español y a euros.
TEST = [
    ("¿Cómo te describiría tu mejor amigo cuando se trata de asumir riesgos?",
     [("Un verdadero jugador", 4), ("Dispuesto a arriesgar tras informarse bien", 3), ("Prudente", 2),
      ("Alguien que evita el riesgo a toda costa", 1)]),
    ("Estás en un concurso de la tele y puedes elegir una opción. ¿Cuál?",
     [("1.000 € en efectivo seguros", 1), ("50 % de probabilidad de ganar 5.000 €", 2),
      ("25 % de probabilidad de ganar 10.000 €", 3), ("5 % de probabilidad de ganar 100.000 €", 4)]),
    ("Acabas de reunir el dinero para un viaje único en la vida y, tres semanas antes, te quedas sin trabajo. ¿Qué haces?",
     [("Cancelo el viaje", 1), ("Hago un viaje mucho más modesto", 2), ("Voy tal y como estaba previsto", 3),
      ("Lo alargo: puede que sea la única oportunidad", 4)]),
    ("Si recibieras de forma inesperada 20.000 € para invertir, ¿qué harías?",
     [("Depósito, cuenta remunerada o fondo monetario", 1), ("Bonos seguros de alta calidad o fondos de bonos", 2),
      ("Acciones o fondos de acciones", 3)]),
    ("¿Cómo de cómodo te sientes invirtiendo en acciones o fondos de acciones por tu experiencia?",
     [("Nada cómodo", 1), ("Algo cómodo", 2), ("Muy cómodo", 3)]),
    ("Cuando oyes la palabra «riesgo», ¿cuál es la primera palabra que te viene a la cabeza?",
     [("Pérdida", 1), ("Incertidumbre", 2), ("Oportunidad", 3), ("Emoción", 4)]),
    ("Casi todo tu patrimonio invertido está en bonos del Estado con buen interés. Algunos expertos prevén que "
     "oro, joyas, coleccionismo e inmuebles se revalorizarán y que los bonos podrían caer. ¿Qué harías?",
     [("Mantengo los bonos", 1), ("Vendo y paso la mitad a liquidez y la otra mitad a esos activos", 2),
      ("Vendo todo y lo paso a esos activos", 3),
      ("Vendo todo, lo paso a esos activos y pido dinero prestado para comprar más", 4)]),
    ("Según el mejor y el peor resultado posible de estas cuatro inversiones, ¿cuál preferirías?",
     [("Mejor caso +200 €, peor caso 0 €", 1), ("Mejor caso +800 €, peor caso −200 €", 2),
      ("Mejor caso +2.600 €, peor caso −800 €", 3), ("Mejor caso +4.800 €, peor caso −2.400 €", 4)]),
    ("Además de lo que ya tienes, te regalan 1.000 €. Ahora debes elegir:",
     [("Una ganancia segura de 500 €", 1), ("50 % de ganar 1.000 € y 50 % de no ganar nada", 3)]),
    ("Además de lo que ya tienes, te regalan 2.000 €. Ahora debes elegir:",
     [("Una pérdida segura de 500 €", 1), ("50 % de perder 1.000 € y 50 % de no perder nada", 3)]),
    ("Un familiar te deja 100.000 € de herencia con la condición de invertirlos TODOS en una sola de estas opciones:",
     [("Cuenta de ahorro o fondo monetario", 1), ("Un fondo mixto de acciones y bonos", 2),
      ("Una cartera de 15 acciones", 3), ("Materias primas como oro, plata y petróleo", 4)]),
    ("Si tuvieras que invertir 20.000 €, ¿qué reparto te resultaría más atractivo?",
     [("60 % riesgo bajo, 30 % medio, 10 % alto", 1), ("30 % bajo, 40 % medio, 30 % alto", 2),
      ("10 % bajo, 40 % medio, 50 % alto", 3)]),
    ("Un amigo geólogo de confianza organiza un grupo de inversores para una prospección minera. Si sale bien, "
     "devuelve entre 50 y 100 veces lo invertido; si no, se pierde todo. Calcula un 20 % de probabilidad de éxito. "
     "Si tuvieras el dinero, ¿cuánto pondrías?",
     [("Nada", 1), ("Un sueldo mensual", 2), ("Tres sueldos mensuales", 3), ("Seis sueldos mensuales", 4)]),
]

NIVELES = [  # (puntuación máxima inclusive, nivel, descripción, % renta variable orientativo)
    (18, "Bajo", "Muy conservador: prioriza no perder capital.", 15),
    (22, "Medio-bajo", "Prudente: acepta algo de riesgo a cambio de algo más de rentabilidad.", 35),
    (28, "Medio", "Equilibrado: tolera oscilaciones moderadas.", 55),
    (32, "Medio-alto", "Dinámico: acepta caídas relevantes a cambio de más rentabilidad esperada.", 75),
    (99, "Alto", "Agresivo: tolera fuertes caídas buscando la máxima rentabilidad.", 90),
]


def puntuacion_min_max():
    return sum(min(p for _, p in o) for _, o in TEST), sum(max(p for _, p in o) for _, o in TEST)


# --- asignador de cartera: puntuación del test -> % de renta variable ideal -> ajuste por horizonte
# Escala T (psicometría): media 50 y desviación 10. Con ±5 desviaciones cubre justo de 0 a 100.
# No hay normas publicadas (media/desviación) de la escala de Grable-Lytton en la web oficial; se deducen de los
# tramos oficiales: «normal» 23-28 (centro 25,5) y «bajo» ≤18 / «alto» ≥33 (a ±7 puntos del centro).
NORMA_TEST = (25.5, 6.0)


def t_score(puntos, media=NORMA_TEST[0], sd=NORMA_TEST[1]):
    return 50.0 + 10.0 * (puntos - media) / sd


def rv_ideal_desde_puntos(puntos, media=NORMA_TEST[0], sd=NORMA_TEST[1]):
    """Devuelve (fracción de renta variable ideal 0-1, nota T, percentil 0-1)."""
    z = (puntos - media) / sd
    t = 50.0 + 10.0 * z
    return float(np.clip(t, 0, 100)) / 100.0, t, 0.5 * (1 + math.erf(z / math.sqrt(2)))


def _fila_plazo(suav, semanas):
    idx = suav.index.values
    k = int(np.abs(idx - min(max(semanas, idx.min()), idx.max())).argmin())
    return suav.iloc[k]


def prob_objetivo(suav, w_ideal, h_ref_anios, p_min=0.02):
    """Riesgo que se acepta: la probabilidad de perder del reparto ideal al horizonte de referencia (con un suelo)."""
    return max(float(_fila_plazo(suav, h_ref_anios * 52)[min(suav.columns, key=lambda c: abs(c - w_ideal))]), p_min)


def rv_recomendada(suav, w_ideal, anios, p_obj):
    """Mayor % de bolsa (≤ ideal) cuya probabilidad histórica de perder al plazo `anios` no supera `p_obj`."""
    fila = _fila_plazo(suav, anios * 52)
    ok = [c for c in fila.index if c <= w_ideal + 1e-9 and fila[c] <= p_obj + 1e-12]
    return float(max(ok)) if ok else 0.0


def mal_escenario(v, pesos, r_rf, anios, q=5):
    """TIR anualizada del percentil `q` (5 = «1 de cada 20 peor») de las ventanas semanales solapadas, para cada
    plazo de `anios` y cada reparto de `pesos` (fracción en bolsa; resto en renta fija a r_rf). Todo de golpe el
    primer día del tramo y sin rebalanceo. Devuelve un DataFrame (índice = años, columnas = pesos)."""
    v = np.asarray(v, dtype=float)
    datos = {w: [] for w in pesos}
    ok = []
    for y in anios:
        h = int(round(y * 52))
        if len(v) - h < 52:
            continue
        rv = v[h:] / v[:-h]
        rf = (1 + r_rf) ** y
        ok.append(y)
        for w in pesos:
            datos[w].append(float(np.percentile((w * rv + (1 - w) * rf) ** (1 / y) - 1, q)))
    return pd.DataFrame(datos, index=pd.Index(ok, name="anios"))


def prob_caida_mayor(v, w, r_rf, anios, umbral):
    """Probabilidad (ventanas semanales solapadas, todo de golpe) de acabar con menos de (1-umbral) de lo invertido."""
    v = np.asarray(v, dtype=float)
    out = []
    for y in anios:
        h = int(round(y * 52))
        if len(v) - h < 52:
            out.append(np.nan)
            continue
        val = w * (v[h:] / v[:-h]) + (1 - w) * (1 + r_rf) ** y
        out.append(float(np.mean(val < 1 - umbral)))
    return np.array(out)


def senda_mal_escenario(tabla, w_ideal, suelo, suavizado=2):
    """% de bolsa recomendado según los años que quedan: en cada tramo, la mayor bolsa (≤ ideal) cuyo mal escenario
    anualizado no baja de `suelo`. Se suaviza con una media móvil de ±`suavizado` puntos y nunca sube al acercarse
    el final."""
    cols = [c for c in tabla.columns if c <= w_ideal + 1e-9]
    rv = np.array([max([c for c in cols if tabla.loc[y, c] >= suelo], default=0.0) for y in tabla.index])
    k = 2 * suavizado + 1
    if suavizado > 0 and len(rv) > k:
        rv = np.convolve(np.pad(rv, (suavizado, suavizado), mode="edge"), np.ones(k) / k, mode="valid")
    rv = np.minimum(rv, w_ideal)
    rv = np.minimum.accumulate(rv[::-1])[::-1]
    return pd.DataFrame({"anios": tabla.index.values.astype(float), "rv": rv})


def mal_escenario_de(tabla, w, anios):
    """Mal escenario anualizado (de `tabla`) de una cartera con fracción `w` en bolsa a `anios` años vista."""
    y = tabla.index.values.astype(float)
    fila = tabla.iloc[int(np.abs(y - min(max(anios, y.min()), y.max())).argmin())]
    return float(np.interp(w, fila.index.values.astype(float), fila.values))


def matriz_rentabilidades(v, H, paso=1):
    """Rentabilidades brutas (1+r) de la bolsa año a año para cada ventana semanal solapada que empieza en
    cada semana del histórico (filas = ventanas, columnas = años 1..H)."""
    v = np.asarray(v, dtype=float)
    starts = np.arange(0, len(v) - H * 52, paso)
    if len(starts) == 0:
        raise ValueError("Histórico demasiado corto para ese horizonte")
    return np.column_stack([v[starts + (y + 1) * 52] / v[starts + y * 52] for y in range(H)])


def simular_dinamico(R, w_ideal, r_rf, tabla, suelo):
    """Simulación dinámica con la cartera que realmente se tiene. R: (trayectorias × H) de (1+r) anuales de la bolsa.
    Cada año se mira la cartera con la que se entra (el peso en bolsa se mueve con el mercado, sin rebalancear),
    se calcula su mal escenario con los años que quedan y, si está por debajo de `suelo`, se recorta a la mayor
    bolsa que sí lo cumple. Devuelve dict con valores finales (por 1 € invertido), pesos de cada año, nº de recortes."""
    n, H = R.shape
    g = 1.0 + r_rf
    cols = tabla.columns.values.astype(float)
    yrs = tabla.index.values.astype(float)
    S = np.full(n, float(w_ideal))
    B = 1.0 - S
    W = np.empty((n, H))
    ENT = np.empty((n, H))
    recortes = np.zeros(n)
    for y in range(H):
        rest = H - y
        fila = tabla.iloc[int(np.abs(yrs - min(max(rest, yrs.min()), yrs.max())).argmin())].values
        tot = S + B
        w = S / tot
        ENT[:, y] = w
        me = np.interp(w, cols, fila)
        ok = cols[(cols <= w_ideal + 1e-9) & (fila >= suelo)]
        wmax = float(ok.max()) if ok.size else 0.0
        corte = me < suelo
        w_new = np.where(corte, np.minimum(w, wmax), w)
        recortes += (corte & (w_new < w - 1e-9))
        W[:, y] = w_new
        S = tot * w_new * R[:, y]
        B = tot * (1.0 - w_new) * g
    return {"final": S + B, "pesos": W, "entrada": ENT, "recortes": recortes}


def simular_fijo(R, w, r_rf):
    """Buy and hold con un reparto fijo (sin rebalancear)."""
    H = R.shape[1]
    return w * np.prod(R, axis=1) + (1 - w) * (1.0 + r_rf) ** H


def simular_senda(R, pesos_anuales, r_rf):
    """Plan fijo: cada año se rebalancea a `pesos_anuales[y]` en bolsa."""
    g = 1.0 + r_rf
    v = np.ones(R.shape[0])
    for y, w in enumerate(pesos_anuales):
        v = v * (w * R[:, y] + (1 - w) * g)
    return v


def rv_en(senda, anios):
    return float(np.interp(anios, senda["anios"].values, senda["rv"].values))


def evaluar_test(puntos_por_pregunta):
    total = int(sum(puntos_por_pregunta))
    for tope, nivel, desc, rv in NIVELES:
        if total <= tope:
            return {"puntuacion": total, "nivel": nivel, "descripcion": desc, "rv_sugerida": rv}
    raise ValueError(total)


# ------------------------------------------------------------ perfiles guardados
def _leer_json(ruta, defecto):
    if not os.path.exists(ruta):
        return defecto
    try:
        with open(ruta, encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:                      # fichero corrupto (p. ej. conflicto de OneDrive)
        registrar_error(f"Leer {os.path.basename(ruta)}", e)
        return defecto


def _escribir_json(ruta, obj):
    tmp = ruta + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=1)
    os.replace(tmp, ruta)


def leer_perfiles():
    d = _leer_json(PERFILES, {})
    d.setdefault("usuarios", {})
    return d


def guardar_perfil(usuario, resultado, respuestas):
    d = leer_perfiles()
    previo = d["usuarios"].get(usuario, {})
    hoy = datetime.now().strftime("%Y-%m-%d")
    historial = list(previo.get("historial") or ([{"fecha": previo["fecha"], "puntuacion": previo["puntuacion"]}]
                                                  if previo.get("fecha") else []))
    historial.append({"fecha": hoy, "puntuacion": resultado["puntuacion"]})
    d["usuarios"][usuario] = {**resultado, "respuestas": list(respuestas), "fecha": hoy, "historial": historial}
    d["activo"] = usuario
    _escribir_json(PERFILES, d)


def borrar_perfil(usuario):
    d = leer_perfiles()
    d["usuarios"].pop(usuario, None)
    if d.get("activo") == usuario:
        d["activo"] = next(iter(d["usuarios"]), None)
    _escribir_json(PERFILES, d)


def usuario_activo(nuevo=None):
    d = leer_perfiles()
    if nuevo is not None:
        d["activo"] = nuevo
        _escribir_json(PERFILES, d)
    return d.get("activo")


def leer_config():
    return _leer_json(CONFIG, {})


def guardar_config(**kw):
    c = leer_config()
    c.update(kw)
    _escribir_json(CONFIG, c)
:::END
:::BEGIN py/paginas/__init__.py|text
"""Una página de la app por módulo. Cada una expone su función pag_*()."""
:::END
:::BEGIN py/paginas/ahorrador.py|text
"""Página Ahorrador."""
from ui import *  # noqa: F401,F403  (st, np, pd, go, fin y utilidades comunes)


def _anios_meses(m):
    return f"{m // 12} años y {m % 12} meses" if m % 12 else f"{m // 12} años"


@st.cache_data(show_spinner="Cargando tablas de mortalidad del INE…", ttl=86400 * 30)
def datos_mortalidad():
    return fin.tabla_mortalidad()


def pag_ahorrador():
    titulo_pagina("💰", "Ahorrador", "Cuánto necesitas para jubilarte con tu nivel de vida y cuánto tardas en llegar a una meta")
    with st.expander("ℹ️ Cómo funciona el Ahorrador"):
        st.markdown("- Todo se calcula en **euros de hoy**: se descuenta la inflación para que las cifras se entiendan.\n"
                    "- **Capital necesario** = valor, el día que te jubilas, de los gastos mensuales que tu pensión no cubre.\n"
                    "- **Edad fija**: aseguras el gasto hasta una edad concreta. **Probabilidad de seguir vivo**: cada "
                    "mes de gasto se multiplica por la probabilidad de estar vivo (tablas de mortalidad del INE, "
                    "sabiendo que llegas vivo a la jubilación), sin fijar un tope duro.\n"
                    "- La pestaña **Meta de ahorro** calcula cuántos meses o cuánto al mes para llegar a una cantidad.")
    t_jub, t_meta, t_fire, t_fondo = st.tabs(["🎯 Jubilación", "⏱️ Meta de ahorro", "🔥 Independencia financiera",
                                                "🛟 Fondo de emergencia"])

    # ================================================================ jubilación
    with t_jub:
        with st.container(border=True):
            c1, c2, c3, c4 = st.columns(4)
            edad = c1.number_input("Tu edad actual", 16, 80, 30, 1, key="a_edad")
            edad_ret = c2.number_input("Edad a la que te jubilas", 40, 80, 67, 1, key="a_ret",
                                       help="Cambia la edad para ver cuánto tendrías que ahorrar.")
            edad_fin = c3.number_input("Hasta qué edad quieres cobrar", 60, 110, 90, 1, key="a_fin",
                                       help="Solo se usa en el modo «Edad fija». Cuanto más años vivas, más capital "
                                            "necesitas.",
                                       disabled=st.session_state.get("a_modo_vida", "").startswith(("Según", "Prudente")))
            sueldo = c4.number_input("Salario neto mensual (€)", 300, 50_000, 2_000, 50, key="a_sueldo",
                                     help="Lo que cobras al mes después de impuestos.")
            d1, d2, d3, d4 = st.columns(4)
            pct_vida = d1.slider("Nivel de vida: % de tu salario neto", 30, 150, 80, 5, key="a_pct",
                                 help="El 70-80 % suele ser suficiente porque en la jubilación ya no ahorras ni "
                                      "pagas ciertos gastos.")
            pension = d2.number_input("Pensión pública estimada (€/mes, de hoy)", 0, 10_000, 0, 50, key="a_pen",
                                      help="Lo que esperas cobrar de la Seguridad Social. Se resta de lo que necesitas. "
                                           "Pon 0 si no la conoces.")
            ahorro0 = d3.number_input("Lo que ya tienes ahorrado (€)", 0, 10_000_000, 5_000, 500, key="a_ahorro0")
            aporte_actual = d4.number_input("Lo que ahorras ahora (€/mes)", 0, 50_000, 200, 25, key="a_aporte")
            with st.expander("Modo de cálculo: hasta cuándo necesitas cobrar (edad fija o mortalidad)"):
                e1, e2, e3 = st.columns([2, 1, 1])
                modo_vida = e1.radio("¿Hasta cuándo necesitas cobrar?",
                                     ["Edad fija (seguro que vives hasta esa edad)",
                                      "Según probabilidad de seguir vivo (tablas de mortalidad del INE)",
                                      "Prudente: hasta la edad a la que solo llega 1 de cada 10 (INE)"],
                                     key="a_modo_vida",
                                     help="El modo probabilístico pondera cada mes de gasto por la probabilidad de seguir "
                                          "vivo: es el valor actuarial «de media», así que en la mitad de los casos te "
                                          "quedarías corto si vives más. El prudente garantiza la renta hasta la edad "
                                          "que solo alcanza el 10 % de quienes llegan vivos a la jubilación.")
                usa_mort = modo_vida.startswith("Según")
                prudente = modo_vida.startswith("Prudente")
                sexo_lbl = e2.selectbox("Tabla de mortalidad", ["Total", "Hombres", "Mujeres"], key="a_sexo",
                                        disabled=not (usa_mort or prudente))
                edad_max = e3.number_input("Edad máxima de la tabla", 95, 110, 105, 1, key="a_emax", disabled=not usa_mort,
                                           help="A partir de esta edad se deja de contar el gasto (probabilidad ~0).")
            with st.expander("Opciones avanzadas: rentabilidad, inflación y gasto manual"):
                v1, v2, v3, v4 = st.columns(4)
                rent_pre = v1.number_input("Rentabilidad antes de jubilarte (% anual)", -2.0, 15.0, 5.0, 0.5,
                                           key="a_rpre", help="Nominal, es decir, antes de descontar la inflación.") / 100
                rent_post = v2.number_input("Rentabilidad ya jubilado (% anual)", -2.0, 15.0, 3.0, 0.5,
                                            key="a_rpost", help="Suele ser más baja porque se invierte con más "
                                                                "prudencia.") / 100
                infl = v3.number_input("Inflación (% anual)", 0.0, 10.0, 2.0, 0.25, key="a_inf") / 100
                g_ap = v4.number_input("Subida real anual de tu ahorro (%)", 0.0, 10.0, 0.0, 0.5, key="a_g",
                                       help="Si esperas ahorrar más cada año por encima de la inflación.") / 100
                gasto_man = st.number_input("Gasto mensual deseado (€ de hoy). 0 = usar el % de tu salario", 0, 50_000,
                                            0, 100, key="a_gasto")
                st.caption("Todas las cifras están en euros de hoy: se descuenta la inflación para que se entiendan "
                           "mejor. Referencia: el índice mundial rindió de media un 8-9 % anual nominal en el pasado, "
                           "y la renta fija suele moverse cerca del Euribor.")

        if edad_ret <= edad:
            st.warning("La edad de jubilación debe ser mayor que tu edad actual.")
        elif not (usa_mort or prudente) and edad_fin <= edad_ret:
            st.warning("La edad hasta la que quieres cobrar debe ser mayor que la de jubilación.")
        elif usa_mort and edad_max <= edad_ret:
            st.warning("La edad máxima de la tabla debe ser mayor que la de jubilación.")
        else:
            q_tabla = None
            if usa_mort or prudente:
                try:
                    q_tabla = fin.qx_por_edad(datos_mortalidad(), {"Total": "T", "Hombres": "H", "Mujeres": "M"}[sexo_lbl])
                except Exception as e:
                    st.error(f"No se pudo leer la tabla de mortalidad del INE ({e}). Uso la edad fija mientras tanto.")
                    usa_mort = prudente = False

            def pesos_para(er):
                return fin.pesos_supervivencia(er, q_tabla, edad_max) if usa_mort else None

            def fin_para(er):
                """Edad hasta la que se cobra según el modo elegido."""
                if prudente:
                    return int(np.ceil(fin.edad_prudente(er, q_tabla)))
                return edad_max if usa_mort else edad_fin

            def plan_para(er):
                w = pesos_para(er)
                return fin.plan_jubilacion(edad, er, fin_para(er), gasto, pension, ahorro0,
                                           aporte_actual, rent_pre, rent_post, infl, g_ap, pesos=w), w

            gasto = gasto_man if gasto_man > 0 else sueldo * pct_vida / 100
            p, pesos = plan_para(edad_ret)
            if usa_mort:
                edad_fin_txt = (f"los <b>{edad_max}</b> ponderando por la probabilidad de seguir vivo "
                                f"(esperanza de vida a esa edad: {fin.esperanza_vida(edad_ret, q_tabla):.1f} años más)")
            elif prudente:
                edad_fin_txt = (f"los <b>{fin_para(edad_ret)}</b>, la edad que solo alcanza 1 de cada 10 personas que "
                                f"llegan a los {edad_ret} (esperanza de vida: {fin.esperanza_vida(edad_ret, q_tabla):.1f} "
                                "años más)")
            else:
                edad_fin_txt = f"los <b>{edad_fin}</b>"
            anio_ret = pd.Timestamp.today().year + (edad_ret - edad)
            cap_nom = p["capital"] * (1 + infl) ** (p["N"] / 12)
            llegas = p["capital_actual"] / p["capital"] if p["capital"] else 1.0
            if p["aporte"] <= 0:
                frase_ahorro = "Con lo que ya tienes ahorrado y su rentabilidad <b>ya llegarías</b> sin ahorrar más."
            else:
                frase_ahorro = (f'Tendrías que ahorrar <b>{eur(p["aporte"])} al mes</b> '
                                f'({pct(p["aporte"] / sueldo, 0)} de tu salario neto)')
                frase_ahorro += (f', frente a los {eur(aporte_actual)} que ahorras ahora.' if aporte_actual else '.')
            st.markdown(
                f'<div class="resumen">Para vivir con <b>{eur(gasto)} al mes</b> (en euros de hoy) desde los '
                f'<b>{edad_ret} años</b> (en {anio_ret}) hasta {edad_fin_txt}'
                + (f', y contando con una pensión pública de <b>{eur(pension)}</b>' if pension else '')
                + f', necesitas <b>{eur(p["capital"])}</b> el día que te jubiles. {frase_ahorro}</div>',
                unsafe_allow_html=True)

            m = st.columns(4)
            m[0].metric("Capital necesario", eur(p["capital"]),
                        help=f"En euros de hoy. En euros de {anio_ret}, con inflación, serían unos {eur(cap_nom)}.")
            m[1].metric("Ahorro mensual necesario", eur(p["aporte"]), delta=f"{pct(p['aporte'] / sueldo, 0)} de tu sueldo",
                        delta_color="off")
            m[2].metric("Con tu ahorro actual llegas a", pct(llegas, 0),
                        help="Qué parte del capital necesario tendrás con lo que ahorras ahora.")
            m[3].metric("Renta que te darías", eur(p["renta_actual"] + pension),
                        delta=f"{pct((p['renta_actual'] + pension) / gasto, 0)} de tu objetivo", delta_color="off",
                        help="Lo que podrías gastar al mes (incluida la pensión pública) con tu ahorro actual.")

            g1, g2 = st.columns([3, 2], gap="large")
            with g1:
                st.markdown("**Tu dinero a lo largo de la vida**")
                explica("Sube mientras ahorras y baja cuando empiezas a retirar. Con el ahorro necesario llegas a "
                        "cero justo a la edad final." if not usa_mort else
                        "Saldo esperado: en la jubilación se retira cada mes la renta multiplicada por la probabilidad "
                        "de seguir vivo, por eso la curva baja despacio al final y llega a cero en la edad máxima.")
                retira = p["necesidad"] * pesos if usa_mort else p["necesidad"]
                tr_plan = fin.trayectoria(ahorro0, p["aporte"], p["N"], p["n_ret"], retira, p["r_pre"],
                                          p["r_post"], g_ap)
                tr_act = fin.trayectoria(ahorro0, aporte_actual, p["N"], p["n_ret"], retira, p["r_pre"],
                                         p["r_post"], g_ap)
                edades = edad + np.arange(len(tr_plan)) / 12
                fa = go.Figure()
                fa.add_scatter(x=edades, y=tr_plan, mode="lines", name="Con el ahorro necesario",
                               line=dict(color=C_CAP, width=3.5))
                fa.add_scatter(x=edades, y=tr_act, mode="lines", name="Con lo que ahorras ahora",
                               line=dict(color=C_INT, width=2.5, dash="dash"))
                fa.add_vline(x=edad_ret, line_dash="dot", line_color="#8B93A7", annotation_text="Jubilación",
                             annotation_position="top")
                fa.update_layout(xaxis_title="Edad", yaxis_title="€ de hoy")
                st.plotly_chart(estilo(fa, 420), width="stretch")
            with g2:
                st.markdown("**¿Y si me jubilo antes o después?**")
                explica("Ahorro mensual necesario según la edad de jubilación. La barra naranja es la que has elegido.")
                tope_r = fin_para(edad_ret) - 1
                edades_r = [x for x in range(max(edad + 1, 50), min(tope_r, 75) + 1)]
                aportes_r = [plan_para(x)[0]["aporte"] for x in edades_r]
                fb = go.Figure(go.Bar(x=edades_r, y=aportes_r,
                                      marker_color=[C_INT if x == edad_ret else C_CAP for x in edades_r],
                                      hovertemplate="Jubilación a los %{x}: %{y:,.0f} €/mes<extra></extra>"))
                fb.update_layout(xaxis_title="Edad de jubilación", yaxis_title="€ al mes")
                st.plotly_chart(estilo(fb, 420, "no"), width="stretch")

            with st.expander("Detalle de los cálculos"):
                st.markdown(
                    f"- Años ahorrando: **{p['N'] // 12}**; años de tabla/cobro: **{p['n_ret'] // 12}**"
                    + (f" (gasto ponderado por probabilidad de seguir vivo, tabla INE {sexo_lbl.lower()})" if usa_mort else "")
                    + ".\n"
                    f"- Lo que necesitas cada mes de tu propio dinero: **{eur(p['necesidad'])}** "
                    f"({eur(gasto)} de nivel de vida − {eur(pension)} de pensión).\n"
                    f"- Rentabilidad real (sin inflación): **{pct(p['r_pre'] * 12, 2)}** al año antes de jubilarte y "
                    f"**{pct(p['r_post'] * 12, 2)}** después (aprox.).\n"
                    f"- Tu ahorro actual ({eur(ahorro0)}) crece hasta **{eur(p['crece_ahorro'])}** (euros de hoy).\n"
                    "- Resultado orientativo: no incluye impuestos sobre la rentabilidad ni comisiones.")

            with st.expander("Sensibilidad: ¿y si la rentabilidad es distinta?"):
                explica("Ahorro mensual necesario según la rentabilidad antes (filas) y después de jubilarte (columnas). "
                        "Sirve para ver cuánto depende el plan de un supuesto.")
                var = [-0.02, -0.01, 0.0, 0.01, 0.02]
                filas_s = {}
                for dpre in var:
                    fila_s = {}
                    for dpost in var:
                        pl_s = fin.plan_jubilacion(edad, edad_ret, fin_para(edad_ret), gasto, pension,
                                                   ahorro0, aporte_actual, rent_pre + dpre, rent_post + dpost, infl,
                                                   g_ap, pesos=pesos)
                        fila_s[f"Después {(rent_post + dpost) * 100:.1f} %"] = pl_s["aporte"]
                    filas_s[f"Antes {(rent_pre + dpre) * 100:.1f} %"] = fila_s
                st.dataframe(pd.DataFrame(filas_s).T, width="stretch",
                             column_config={c: st.column_config.NumberColumn(format="%.0f €") for c in
                                            next(iter(filas_s.values()))})

    # ================================================================ independencia financiera
    with t_fire:
        explica("Independencia financiera: tener un capital que, retirando cada año un porcentaje pequeño, cubra tus "
                "gastos sin tener que trabajar. La regla clásica es el 4 % (capital = 25 veces el gasto anual). "
                "Cifras en euros de hoy.")
        with st.container(border=True):
            f1, f2, f3, f4 = st.columns(4)
            gasto_f = f1.number_input("Gasto mensual que quieres cubrir (€)", 300, 50_000, 1_800, 50, key="f_gasto")
            tasa_f = f2.number_input("Tasa de retirada segura (%)", 2.0, 8.0, 4.0, 0.25, key="f_tasa",
                                     help="4 % es la regla clásica. En plazos muy largos suele recomendarse 3-3,5 %.") / 100
            ahorro_f = f3.number_input("Lo que ya tienes (€)", 0, 50_000_000, 10_000, 500, key="f_ini")
            aporte_f = f4.number_input("Lo que ahorras al mes (€)", 0, 100_000, 600, 25, key="f_apo")
            g1, g2, g3 = st.columns(3)
            rent_f = g1.number_input("Rentabilidad anual (%)", -2.0, 15.0, 5.0, 0.5, key="f_rent") / 100
            infl_f = g2.number_input("Inflación (% anual)", 0.0, 10.0, 2.0, 0.25, key="f_infl") / 100
            edad_f = g3.number_input("Tu edad", 16, 80, 30, 1, key="f_edad")
        objetivo_f = gasto_f * 12 / tasa_f
        i_f = fin.r_mensual(rent_f, infl_f, real=True)
        n_f = fin.meses_para_meta(objetivo_f, ahorro_f, aporte_f, i_f)
        mf = st.columns(4)
        mf[0].metric("Capital para ser independiente", eur(objetivo_f), help=f"{gasto_f * 12:,.0f} € al año ÷ {tasa_f * 100:.2f} %".replace(",", "."))
        mf[1].metric("Ya tienes", pct(min(ahorro_f / objetivo_f, 1.0), 0))
        if n_f is None:
            mf[2].metric("Tiempo necesario", "No se llega")
            st.warning("Con ese ahorro y esa rentabilidad no se alcanza nunca. Sube el ahorro mensual.")
        else:
            mf[2].metric("Tiempo necesario", _anios_meses(n_f))
            mf[3].metric("Edad de independencia", f"{edad_f + n_f / 12:.1f} años")
            st.markdown(f'<div class="resumen">Ahorrando <b>{eur(aporte_f)} al mes</b> llegarás a <b>{eur(objetivo_f)}</b> '
                        f'en <b>{_anios_meses(n_f)}</b>, a los <b>{edad_f + n_f / 12:.0f} años</b>. Desde ahí podrías '
                        f'retirar {eur(gasto_f)} al mes de forma sostenible.</div>', unsafe_allow_html=True)
            sf = fin.serie_ahorro(ahorro_f, aporte_f, max(n_f, 1), i_f)
            ff = go.Figure()
            ff.add_scatter(x=edad_f + sf.mes / 12, y=sf.total, mode="lines", name="Tu ahorro", line=dict(color=C_CAP, width=3.5))
            ff.add_hline(y=objetivo_f, line_dash="dash", line_color=C_INT, annotation_text="Independencia")
            ff.update_layout(xaxis_title="Edad", yaxis_title="€ de hoy")
            st.plotly_chart(estilo(ff, 360), width="stretch")
        st.markdown("**¿Y si ahorro más o con otra tasa de retirada?**")
        filas_fi = []
        for ap_ in sorted(set([aporte_f // 2, aporte_f, int(aporte_f * 1.5), aporte_f * 2, aporte_f * 3])):
            fila_fi = {"Ahorro mensual": float(ap_)}
            for t_ in (0.03, 0.035, 0.04, 0.05):
                nn = fin.meses_para_meta(gasto_f * 12 / t_, ahorro_f, ap_, i_f)
                fila_fi[f"Retirada {t_ * 100:.1f} %"] = (nn / 12) if nn is not None else np.nan
            filas_fi.append(fila_fi)
        st.dataframe(pd.DataFrame(filas_fi), hide_index=True, width="stretch", column_config={
            "Ahorro mensual": st.column_config.NumberColumn(format="%.0f €"),
            **{f"Retirada {t_ * 100:.1f} %": st.column_config.NumberColumn(format="%.1f años")
               for t_ in (0.03, 0.035, 0.04, 0.05)}})

    # ================================================================ fondo de emergencia
    with t_fondo:
        explica("Colchón de dinero fácil de sacar para imprevistos (perder el empleo, una avería…). Lo habitual son "
                "3-6 meses de gastos esenciales; más si tu ingreso es variable.")
        with st.container(border=True):
            h1, h2, h3, h4 = st.columns(4)
            gasto_e = h1.number_input("Gastos esenciales al mes (€)", 200, 20_000, 1_400, 50, key="e_gasto")
            meses_e = h2.slider("Meses de colchón", 1, 24, 6, 1, key="e_meses")
            ahorro_e = h3.number_input("Lo que ya tienes en el colchón (€)", 0, 1_000_000, 1_000, 100, key="e_ini")
            aporte_e = h4.number_input("Lo que le dedicas al mes (€)", 0, 20_000, 200, 25, key="e_apo")
            rent_e = st.number_input("Rentabilidad de la cuenta (% anual)", 0.0, 6.0, 2.0, 0.25, key="e_rent") / 100
        objetivo_e = gasto_e * meses_e
        n_e = fin.meses_para_meta(objetivo_e, ahorro_e, aporte_e, fin.r_mensual(rent_e, 0.0, real=False))
        me = st.columns(4)
        me[0].metric("Colchón objetivo", eur(objetivo_e))
        me[1].metric("Cubres ahora", f"{ahorro_e / gasto_e:.1f} meses")
        me[2].metric("Te falta", eur(max(objetivo_e - ahorro_e, 0)))
        me[3].metric("Tiempo para completarlo", "Ya lo tienes" if ahorro_e >= objetivo_e else
                     (_anios_meses(n_e) if n_e else "No se llega"))
        niveles_e = pd.DataFrame({"Meses": [3, 6, 9, 12], "Colchón": [gasto_e * m_ for m_ in (3, 6, 9, 12)]})
        niveles_e["Tiempo"] = [("Ya" if ahorro_e >= c_ else (_anios_meses(fin.meses_para_meta(c_, ahorro_e, aporte_e,
                               fin.r_mensual(rent_e, 0.0, real=False))) if fin.meses_para_meta(c_, ahorro_e, aporte_e,
                               fin.r_mensual(rent_e, 0.0, real=False)) else "No se llega")) for c_ in niveles_e["Colchón"]]
        st.dataframe(niveles_e, hide_index=True, width="stretch",
                     column_config={"Colchón": st.column_config.NumberColumn(format="%.0f €")})

    # ================================================================ meta de ahorro
    with t_meta:
        modo = st.radio("¿Qué quieres calcular?", ["¿Cuántos meses necesito ahorrar?", "¿Cuánto debo ahorrar al mes?"],
                        horizontal=True, key="m_modo")
        with st.container(border=True):
            q1, q2, q3, q4 = st.columns(4)
            objetivo = q1.number_input("Cantidad que quieres conseguir (€)", 100, 50_000_000, 20_000, 500, key="m_obj")
            ahorro_ini = q2.number_input("Lo que ya tienes (€)", 0, 50_000_000, 0, 500, key="m_ini")
            if modo.startswith("¿Cuántos"):
                aporte_m = q3.number_input("Puedes ahorrar al mes (€)", 0, 100_000, 400, 25, key="m_aporte")
                plazo_m = 0
            else:
                plazo_m = q3.number_input("En cuántos meses lo quieres", 1, 1200, 36, 1, key="m_plazo")
                aporte_m = 0
            rent_m = q4.number_input("Rentabilidad anual (%)", -2.0, 15.0, 3.0, 0.5, key="m_rent",
                                     help="0 % si lo guardas sin invertir. Una cuenta remunerada suele dar un 2-3 %.") / 100
            ajusta = st.checkbox("La cantidad está en euros de hoy: tener en cuenta la inflación", key="m_infl",
                                 help="Si lo marcas, la rentabilidad se calcula sin inflación (real) y se supone que "
                                      "ahorras algo más cada año para seguir el ritmo de los precios.")
            infl_m = st.number_input("Inflación (% anual)", 0.0, 10.0, 2.0, 0.25, key="m_infv",
                                     disabled=not ajusta) / 100 if ajusta else 0.0
        i_m = fin.r_mensual(rent_m, infl_m, real=ajusta)

        if modo.startswith("¿Cuántos"):
            n = fin.meses_para_meta(objetivo, ahorro_ini, aporte_m, i_m)
            if n is None:
                st.warning("Con ese ahorro y esa rentabilidad no se llega nunca a la cantidad. Sube el ahorro mensual.")
                return
            aportado_total = ahorro_ini + aporte_m * n
        else:
            n = int(plazo_m)
            aporte_m = fin.aporte_para_meta(objetivo, ahorro_ini, n, i_m)
            aportado_total = ahorro_ini + aporte_m * n
        sa = fin.serie_ahorro(ahorro_ini, aporte_m, max(n, 1), i_m)
        intereses = float(sa.intereses.iloc[-1])
        fecha = pd.Timestamp.today() + pd.DateOffset(months=n)
        if n == 0:
            st.success("¡Ya tienes esa cantidad!")
        else:
            st.markdown(
                f'<div class="resumen">Para llegar a <b>{eur(objetivo)}</b> ahorrando <b>{eur(aporte_m, 2) if not modo.startswith("¿Cuántos") else eur(aporte_m)} '
                f'al mes</b> necesitas <b>{n} meses</b> ({_anios_meses(n)}), es decir, hasta aproximadamente '
                f'<b>{fecha:%m/%Y}</b>. De ese dinero, <b>{eur(aportado_total)}</b> lo pones tú y '
                f'<b>{eur(max(intereses, 0))}</b> lo genera la rentabilidad.</div>', unsafe_allow_html=True)
        k = st.columns(4)
        k[0].metric("Meses necesarios" if modo.startswith("¿Cuántos") else "Plazo", f"{n} meses",
                    delta=_anios_meses(n), delta_color="off")
        k[1].metric("Ahorro mensual", eur(aporte_m, 0 if modo.startswith("¿Cuántos") else 2))
        k[2].metric("Lo pones tú", eur(aportado_total))
        k[3].metric("Lo genera la rentabilidad", eur(max(intereses, 0)))
        sueldo_ref = st.session_state.get("a_sueldo")
        if sueldo_ref and aporte_m:
            st.caption(f"Eso es el {pct(aporte_m / sueldo_ref, 0)} del salario neto que has puesto en «Jubilación» "
                       f"({eur(sueldo_ref)}).")

        h1, h2 = st.columns(2, gap="large")
        with h1:
            st.markdown("**¿Cómo crece tu ahorro?**")
            explica("Azul: lo que pones tú. Naranja: lo que añade la rentabilidad. La línea gris es tu meta.")
            fm = go.Figure()
            fm.add_scatter(x=sa.mes, y=sa.aportado, mode="lines", stackgroup="a", name="Lo que pones tú",
                           line=dict(color=C_CAP, width=0.5), fillcolor="rgba(76,154,255,.55)")
            fm.add_scatter(x=sa.mes, y=sa.intereses.clip(lower=0), mode="lines", stackgroup="a",
                           name="Rentabilidad", line=dict(color=C_INT, width=0.5), fillcolor="rgba(245,165,36,.65)")
            fm.add_hline(y=objetivo, line_dash="dash", line_color="#8B93A7", annotation_text="Meta")
            fm.update_layout(xaxis_title="Meses", yaxis_title="€")
            st.plotly_chart(estilo(fm, 380), width="stretch")
        with h2:
            st.markdown("**¿Y si ahorro más o menos?**")
            explica("Meses necesarios según lo que ahorras al mes.")
            base_ap = aporte_m if aporte_m > 0 else max(objetivo / 60, 50)
            opciones = sorted({max(int(round(base_ap * f / 10) * 10), 10) for f in (.5, .75, 1, 1.5, 2, 3, 4)})
            meses_op = [fin.meses_para_meta(objetivo, ahorro_ini, ap, i_m) for ap in opciones]
            pts = [(ap, mm) for ap, mm in zip(opciones, meses_op) if mm is not None]
            if pts:
                fs = go.Figure(go.Scatter(x=[x for x, _ in pts], y=[y for _, y in pts], mode="lines+markers",
                                          line=dict(color=C_CAP, width=3),
                                          hovertemplate="%{x:,.0f} €/mes: %{y} meses<extra></extra>"))
                fs.update_layout(xaxis_title="Ahorro al mes (€)", yaxis_title="Meses para llegar")
                st.plotly_chart(estilo(fs, 380, "no"), width="stretch")
                st.dataframe(pd.DataFrame({"Ahorro al mes": [x for x, _ in pts], "Meses": [y for _, y in pts],
                                           "Tiempo": [_anios_meses(y) for _, y in pts]}), hide_index=True,
                             width="stretch", column_config={
                                 "Ahorro al mes": st.column_config.NumberColumn(format="%.0f €")})
        st.caption("Orientativo: no incluye impuestos ni comisiones. Se asume que aportas a principio de cada mes.")
:::END
:::BEGIN py/paginas/asignador.py|text
"""Página Asignador de carteras."""
from ui import *  # noqa: F401,F403  (st, np, pd, go, fin y utilidades comunes)


def pag_asignador():
    titulo_pagina("🧩", "Asignador", "Qué porcentaje de bolsa te conviene según tu perfil de riesgo y el tiempo que te queda")
    with st.expander("ℹ️ Cómo se calcula"):
        st.markdown(
            "1. **Tu nota del test** (Grable-Lytton) se convierte en una **nota T**: la escala estándar de la psicometría, "
            "con media 50 y desviación 10. Con ±5 desviaciones cubre justo de 0 a 100, así que esa nota se lee "
            "directamente como **% de renta variable ideal** (0 = todo renta fija, 100 = todo bolsa; los extremos son "
            "muy improbables).\n"
            "2. **El tiempo ajusta ese ideal.** Para cada tramo de años que queda se miran todas las ventanas del "
            "pasado y se calcula el **mal escenario anualizado** (el 1 de cada 20 peor, en TIR anualizada) de cada "
            "reparto. Se recomienda la **mayor bolsa, sin pasar de tu ideal, cuyo mal escenario no baje de un "
            "suelo anual** (2 % por defecto, más o menos la inflación).\n"
            "3. Con pocos años, mucha bolsa tiene un mal escenario muy malo, así que se recorta; con muchos años "
            "el mal escenario mejora y se llega a tu ideal. La curva se suaviza con una media móvil.\n"
            "4. Según te acercas al final, la recomendación **baja sola** (senda de desriesgo).")
    perfiles = fin.leer_perfiles()
    usuarios = list(perfiles["usuarios"])
    mn, mx = fin.puntuacion_min_max()
    tipos, _ = tipos_actuales()
    rf_def = tipos.get("euribor12m") if tipos.get("euribor12m") is not None else 0.025
    with st.container(border=True):
        a1, a2, a3 = st.columns([2, 2, 2])
        opciones = usuarios + ["Introducir la nota a mano"]
        ya = perfiles.get("activo")
        quien = a1.selectbox("Perfil", opciones, index=(opciones.index(ya) if ya in opciones else len(opciones) - 1),
                             key="s_user", help="Usa la nota del test de riesgo guardada para esa persona.")
        if quien in usuarios:
            puntos = int(perfiles["usuarios"][quien]["puntuacion"])
            a2.metric("Nota del test", f"{puntos} / {mx}")
        else:
            puntos = a2.number_input(f"Nota del test ({mn}-{mx})", mn, mx, 25, 1, key="s_pts")
            if not usuarios:
                a2.caption("Aún no hay perfiles: haz el test de riesgo para guardar tu nota.")
        horiz = a3.slider("¿Cuántos años faltan para necesitar el dinero?", 1, 30, 10, 1, key="s_h",
                          help="Tu preferencia temporal: cuanto menos tiempo, menos bolsa conviene.")
        with st.expander("Opciones avanzadas: escala, años hasta el ideal, riesgo aceptado e índice"):
            b1, b2, b3 = st.columns(3)
            media = b1.number_input("Media de la escala", 10.0, 45.0, float(fin.NORMA_TEST[0]), 0.5, key="s_mu",
                                    help="Nota media de la población. No hay normas publicadas de la escala: por "
                                         "defecto se deduce de los tramos oficiales (normal = 23-28).")
            sd = b2.number_input("Desviación de la escala", 2.0, 12.0, float(fin.NORMA_TEST[1]), 0.5, key="s_sd",
                                 help="Cuanto menor, más se acercan las notas extremas al 0 % o al 100 % de bolsa.")
            suelo = b3.number_input("Suelo del mal escenario (% anual)", -5.0, 8.0, 2.0, 0.5, key="s_suelo",
                                    help="El mal escenario de cada reparto, expresado como rentabilidad anual, no "
                                         "puede quedar por debajo de esto. Más alto = más prudente.") / 100
            c1, c2 = st.columns(2)
            q_mal = c1.selectbox("Qué es un «mal escenario»", ["1 de cada 20 (percentil 5)", "1 de cada 10 (percentil 10)",
                                                              "1 de cada 100 (percentil 1)"], key="s_q",
                                 help="Cuántas ventanas históricas peores se dejan fuera.")
            suav_a = c2.slider("Suavizado de la curva (años)", 0, 5, 3, 1, key="s_suav",
                               help="Media móvil sobre los años que quedan. 0 = sin suavizar (puede haber saltos).")
            d1, d2, d3 = st.columns(3)
            indice = d1.selectbox("Índice de bolsa", list(fin.INDICES), key="s_idx")
            r_rf = rf_efectivo(d2.number_input("Rentabilidad de la renta fija (% al año, nominal)", -1.0, 15.0,
                                               round(rf_def * 100, 2), 0.1, key="s_rf") / 100)
            estr = d3.radio("Estrategia al invertir", ["Buy and hold", "DCA (aportaciones semanales)"], key="s_estr")
    w_ideal, t, perc = fin.rv_ideal_desde_puntos(puntos, media, sd)
    w_ideal = round(w_ideal, 4)
    pesos = tuple(sorted(set([i / 50 for i in range(51)] + [w_ideal])))
    raw, suav, err = curvas_plazos(indice, round(r_rf, 6), pesos, "dca" if estr.startswith("DCA") else "hold")
    if suav is None or suav.empty:
        st.error(f"No se han podido calcular las probabilidades: {err or 'histórico demasiado corto'}")
        return
    q_pct = {"1 de cada 20": 5, "1 de cada 10": 10, "1 de cada 100": 1}[q_mal.split(" (")[0]]
    tabla_me = tabla_mal_escenario(indice, round(r_rf, 6), pesos, q_pct)
    if tabla_me is None or tabla_me.empty:
        st.error("No se ha podido calcular el mal escenario: histórico demasiado corto.")
        return
    senda = fin.senda_mal_escenario(tabla_me, w_ideal, suelo, suavizado=int(suav_a) * 2)
    rv_hoy = min(fin.rv_en(senda, horiz), w_ideal)
    pr_ideal = float(fin._fila_plazo(suav, horiz * 52)[min(suav.columns, key=lambda c: abs(c - w_ideal))])
    pr_rec = float(fin._fila_plazo(suav, horiz * 52)[min(suav.columns, key=lambda c: abs(c - rv_hoy))])

    st.markdown(
        f'<div class="resumen">Con tu nota ({puntos}) tu reparto ideal sería <b>{pct(w_ideal, 0)} en bolsa</b>. '
        f'Como solo te quedan <b>{horiz} año{"s" if horiz > 1 else ""}</b>, lo razonable es empezar con '
        f'<b>{pct(rv_hoy, 0)} en bolsa y {pct(1 - rv_hoy, 0)} en renta fija</b>'
        + (", sin recortes." if rv_hoy >= w_ideal - 1e-9 else
           f" (recorte de {pct(w_ideal - rv_hoy, 0)} por el poco tiempo) y bajarlo según te acerques al final")
        + f'. Probabilidad de acabar con menos de lo invertido: <b>{pct(pr_rec, 1)}</b> '
        f'(con el ideal sería {pct(pr_ideal, 1)}).</div>', unsafe_allow_html=True)

    m = st.columns(5)
    m[0].metric("Nota T", f"{t:.0f}", help="Escala estándar: media 50, desviación 10. Se lee como % de bolsa ideal.")
    m[1].metric("Percentil", f"{perc * 100:.0f} %", help="Qué porcentaje de la población tendría una nota menor.")
    m[2].metric("Bolsa ideal", pct(w_ideal, 0))
    m[3].metric("Bolsa recomendada hoy", pct(rv_hoy, 0), delta=f"{(rv_hoy - w_ideal) * 100:+.0f} puntos"
                if rv_hoy < w_ideal - 1e-9 else None, delta_color="off")
    m[4].metric("Suelo del mal escenario", pct(suelo, 1) + " anual",
                help="El mal escenario de tu reparto, en rentabilidad anual, no baja de aquí.")

    t_rec, t_sim, t_mat = st.tabs(["🎯 Recomendación", "🧪 Simulación dinámica", "🗂️ Perfiles y plazos"])
    with t_rec:
        g1, g2 = st.columns(2, gap="large")
        with g1:
            st.markdown("**De tu nota al reparto ideal**")
            explica("La campana es la población; tu nota (línea naranja) se lee directamente como % de bolsa.")
            xs = np.linspace(0, 100, 401)
            dens = np.exp(-0.5 * ((xs - 50) / 10) ** 2) / (10 * np.sqrt(2 * np.pi))
            fb = go.Figure()
            fb.add_scatter(x=xs, y=dens, mode="lines", fill="tozeroy", fillcolor="rgba(76,154,255,.18)",
                           line=dict(color=C_CAP, width=2.5), name="Población", hoverinfo="skip")
            fb.add_vline(x=float(np.clip(t, 0, 100)), line_color=C_INT, line_width=3,
                         annotation_text=f"Tú: {pct(w_ideal, 0)} bolsa", annotation_position="top")
            fb.update_layout(xaxis_title="Nota T = % de renta variable ideal", yaxis=dict(visible=False))
            st.plotly_chart(estilo(fb, 380, "no"), width="stretch")
        with g2:
            st.markdown("**¿Cuánta bolsa según los años que quedan?**")
            explica("Cada punto sale del mal escenario histórico de ese plazo. La línea discontinua es tu ideal; el punto "
                    "marca dónde estás ahora.")
            fs = go.Figure()
            fs.add_scatter(x=senda["anios"], y=senda["rv"] * 100, mode="lines", line=dict(color=C_INT, width=3.5),
                           name="Recomendado")
            fs.add_hline(y=w_ideal * 100, line_dash="dash", line_color="#8B93A7", annotation_text="Tu ideal")
            fs.add_scatter(x=[horiz], y=[rv_hoy * 100], mode="markers", marker=dict(size=13, color=C_CAP,
                           line=dict(width=2, color="white")), name="Tu situación")
            fs.update_layout(xaxis_title="Años que quedan", yaxis_title="% en bolsa", yaxis_range=[0, 100])
            st.plotly_chart(estilo(fs, 380), width="stretch")

        st.markdown("**Tu plan año a año**")
        explica(f"Cada año se mira la cartera con la que entras (la que quedó del año anterior) y se calcula su mal "
                f"escenario con los años que quedan. Si baja del suelo ({pct(suelo, 1)} anual), se recorta justo lo "
                "necesario y esa nueva cartera es la de entrada del año siguiente.")
        filas = []
        w_in = w_ideal
        for k in range(horiz):
            rest = horiz - k
            me = fin.mal_escenario_de(tabla_me, w_in, rest)
            w_out = min(w_in, fin.rv_en(senda, rest), w_ideal)
            filas.append({"Año": k + 1, "Años que quedan": rest, "Entras con": w_in, "Mal escenario de esa cartera": me,
                          "Ajustas a": w_out, "Renta fija": 1 - w_out})
            w_in = w_out
        plan = pd.DataFrame(filas)
        fp = go.Figure()
        fp.add_bar(x=plan["Año"], y=plan["Ajustas a"] * 100, name="Bolsa", marker_color=C_INT)
        fp.add_bar(x=plan["Año"], y=plan["Renta fija"] * 100, name="Renta fija", marker_color=C_CAP)
        fp.update_layout(barmode="stack", xaxis_title="Año del plan", yaxis_title="%", yaxis_range=[0, 100])
        h1, h2 = st.columns([2, 3], gap="large")
        with h1:
            st.plotly_chart(estilo(fp, 340), width="stretch")
        with h2:
            st.dataframe(plan.drop(columns=["Renta fija"]), hide_index=True, width="stretch", height=340, column_config={
                "Entras con": st.column_config.NumberColumn("Entras con (bolsa)", format="percent"),
                "Mal escenario de esa cartera": st.column_config.NumberColumn("Mal escenario (anual)", format="percent",
                                                                              help="Rentabilidad anual del 1 de cada 20 "
                                                                                   "peor a los años que quedan."),
                "Ajustas a": st.column_config.NumberColumn("Ajustas a (bolsa)", format="percent")})

        st.download_button("⬇️ Descargar el plan (CSV)", plan.to_csv(index=False, sep=";", decimal=",").encode("utf-8-sig"),
                           file_name="plan_asignador.csv", mime="text/csv", key="s_dl")

    # ================================================================ simulación dinámica
    with t_sim:
        explica("Aquí la cartera es la que realmente tendrías: cada año su peso en bolsa se mueve con el mercado "
                "(si la bolsa sube, pesa más). Cada año se mira esa cartera, se calcula su mal escenario con los años "
                "que quedan y, si baja del suelo, se recorta a la mayor bolsa que lo cumple. Se prueba con cada "
                "ventana histórica o con miles de futuros posibles.")
        s1, s2, s3 = st.columns(3)
        H_sim = int(s1.slider("Años del plan", 3, 29, min(max(horiz, 3), 29), 1, key="s_hsim"))
        met_sim = s2.radio("Método", ["Ventanas históricas", "Monte Carlo (5.000)"], key="s_msim",
                           help="Ventanas históricas: cada semana de inicio posible del pasado. Monte Carlo: sortea "
                                "años reales de la bolsa.")
        inv = s3.number_input("Dinero invertido (€)", 100, 50_000_000, 10_000, 500, key="s_inv")
        if met_sim.startswith("Ventanas"):
            try:
                R = fin.matriz_rentabilidades(serie_semanal(indice), H_sim)
            except Exception as e:
                st.error(f"No hay histórico suficiente para ese plazo: {e}")
                R = None
        else:
            ret_a, _, err_a = datos_indice(indice)
            R = None if ret_a is None else 1 + fin.muestras_bloques(ret_a.values, 5000, H_sim, bloque_mc())
        if R is not None:
            sim = fin.simular_dinamico(R, w_ideal, r_rf, tabla_me, suelo)
            senda_h = fin.senda_mal_escenario(tabla_me, w_ideal, suelo, suavizado=int(suav_a) * 2)
            pesos_plan = [min(fin.rv_en(senda_h, H_sim - y), w_ideal) for y in range(H_sim)]
            variantes = {"Dinámica (tu cartera real)": sim["final"],
                         "Plan fijo (rebalancea cada año)": fin.simular_senda(R, pesos_plan, r_rf),
                         f"Siempre {pct(w_ideal, 0)} en bolsa": fin.simular_fijo(R, w_ideal, r_rf)}
            filas_v = []
            for nombre, x in variantes.items():
                tir = x ** (1 / H_sim) - 1
                filas_v.append({"Estrategia": nombre, "Mal escenario": inv * float(np.percentile(x, 5)),
                                "Caso típico": inv * float(np.median(x)), "Buen escenario": inv * float(np.percentile(x, 95)),
                                "TIR típica": float(np.median(tir)), "TIR mal escenario": float(np.percentile(tir, 5)),
                                "Prob. de perder": float(np.mean(x < 1))})
            st.markdown("**Resultado final de cada estrategia**")
            st.dataframe(pd.DataFrame(filas_v), hide_index=True, width="stretch", column_config={
                **{c: st.column_config.NumberColumn(format="%.0f €") for c in
                   ["Mal escenario", "Caso típico", "Buen escenario"]},
                **{c: st.column_config.NumberColumn(format="percent") for c in
                   ["TIR típica", "TIR mal escenario", "Prob. de perder"]}})
            k1, k2, k3 = st.columns(3)
            k1.metric("Recortes por trayectoria (media)", f"{sim['recortes'].mean():.1f}",
                      help="Cuántos años, de media, hay que recortar bolsa porque la cartera real se pasa de riesgo.")
            k2.metric("Bolsa media al principio", pct(float(sim["pesos"][:, 0].mean()), 0))
            k3.metric("Bolsa media al final", pct(float(sim["pesos"][:, -1].mean()), 0))
            e1, e2 = st.columns(2, gap="large")
            with e1:
                st.markdown("**¿Cómo evoluciona la bolsa de tu cartera?**")
                explica("Banda: 8 de cada 10 trayectorias. Línea: la mediana. Sube cuando el mercado sube y se recorta "
                        "cuando se pasa de riesgo.")
                anios_x = np.arange(1, H_sim + 1)
                pw = np.percentile(sim["pesos"], [10, 50, 90], axis=0) * 100
                fw = go.Figure()
                fw.add_scatter(x=anios_x, y=pw[2], mode="lines", line=dict(width=0), showlegend=False, hoverinfo="skip")
                fw.add_scatter(x=anios_x, y=pw[0], mode="lines", fill="tonexty", fillcolor="rgba(76,154,255,.25)",
                               line=dict(width=0), name="8 de cada 10 casos")
                fw.add_scatter(x=anios_x, y=pw[1], mode="lines", line=dict(color=C_INT, width=3), name="Mediana")
                fw.add_scatter(x=anios_x, y=np.array(pesos_plan) * 100, mode="lines", line=dict(color="#8B93A7", dash="dash"),
                               name="Plan fijo")
                fw.update_layout(xaxis_title="Año del plan", yaxis_title="% en bolsa", yaxis_range=[0, 100])
                st.plotly_chart(estilo(fw, 380), width="stretch")
            with e2:
                st.markdown("**¿Qué resultados finales son más probables?**")
                explica("Distribución del dinero final de cada estrategia (en múltiplos de lo invertido).")
                fh = go.Figure()
                cols_h = [C_CAP, C_INT, "#8B93A7"]
                for (nombre, x), colr in zip(variantes.items(), cols_h):
                    fh.add_histogram(x=x, nbinsx=40, name=nombre, opacity=0.55, marker_color=colr)
                fh.add_vline(x=1, line_dash="dash", line_color="#D55E00", annotation_text="Lo invertido")
                fh.update_layout(barmode="overlay", xaxis_title="Veces el dinero invertido", yaxis_title="Nº de casos")
                st.plotly_chart(estilo(fh, 380), width="stretch")
            st.caption("Cada trayectoria es una ventana histórica (solapadas) o un futuro sorteado. La renta fija rinde "
                       "un tipo constante. Sin impuestos ni costes de rebalanceo.")

    # ================================================================ perfiles y plazos
    with t_mat:
        st.markdown("**Bolsa recomendada según tu nota y los años que quedan**")
        explica("Cada fila es una nota del test; cada columna, los años que faltan. Así ves de un vistazo cómo "
                "cambian el ideal y el recorte por plazo.")
        notas = [15, 19, 23, 26, 29, 33, 38, 43]
        horizs = [1, 2, 3, 5, 7, 10, 15, 20, 25, 30]
        ideales = {n_: round(fin.rv_ideal_desde_puntos(n_, media, sd)[0], 4) for n_ in notas}
        pesos_m = tuple(sorted(set([i / 50 for i in range(51)] + list(ideales.values()) + [w_ideal])))
        tab_m = tabla_mal_escenario(indice, round(r_rf, 6), pesos_m, q_pct)
        if tab_m is not None and not tab_m.empty:
            z, txt = [], []
            for n_ in notas:
                sd_m = fin.senda_mal_escenario(tab_m, ideales[n_], suelo, suavizado=int(suav_a) * 2)
                fila_m = [min(fin.rv_en(sd_m, h_), ideales[n_]) * 100 for h_ in horizs]
                z.append(fila_m)
                txt.append([f"{v_:.0f}" for v_ in fila_m])
            hm = go.Figure(go.Heatmap(z=z, x=[f"{h_} a." for h_ in horizs], y=[f"Nota {n_} (ideal {ideales[n_] * 100:.0f} %)" for n_ in notas],
                                      text=txt, texttemplate="%{text}", colorscale=[[0, "#14532D"], [1, "#F5A524"]],
                                      zmin=0, zmax=100, colorbar=dict(title="% bolsa"),
                                      hovertemplate="%{y} · %{x}: %{z:.0f} % en bolsa<extra></extra>"))
            hm.update_layout(xaxis_title="Años que quedan", yaxis_autorange="reversed")
            st.plotly_chart(estilo(hm, 420, "no"), width="stretch")
        if usuarios:
            st.markdown("**Perfiles guardados, con tu plazo actual**")
            filas_u = []
            for u in usuarios:
                pu = int(perfiles["usuarios"][u]["puntuacion"])
                wi = round(fin.rv_ideal_desde_puntos(pu, media, sd)[0], 4)
                pw_u = tuple(sorted(set(pesos + (wi,))))
                tab_u = tabla_mal_escenario(indice, round(r_rf, 6), pw_u, q_pct)
                sd_u = fin.senda_mal_escenario(tab_u, wi, suelo, suavizado=int(suav_a) * 2)
                filas_u.append({"Perfil": u, "Nota": pu, "Nivel": perfiles["usuarios"][u]["nivel"],
                                "Bolsa ideal": wi, f"Recomendada a {horiz} años": min(fin.rv_en(sd_u, horiz), wi)})
            st.dataframe(pd.DataFrame(filas_u), hide_index=True, width="stretch", column_config={
                "Bolsa ideal": st.column_config.NumberColumn(format="percent"),
                f"Recomendada a {horiz} años": st.column_config.NumberColumn(format="percent")})
        else:
            st.info("Cuando guardes perfiles en el test de riesgo, aquí podrás compararlos.")

    st.caption("Orientativo: usa probabilidades históricas de perder dinero (ventanas semanales solapadas, suavizadas "
               "con media móvil de 52 semanas), sin impuestos ni comisiones. No es asesoramiento financiero.")
:::END
:::BEGIN py/paginas/cartera.py|text
"""Página Cartera."""
from ui import *  # noqa: F401,F403  (st, np, pd, go, fin y utilidades comunes)


def pag_cartera():
    titulo_pagina("📈", "Cartera", "Cuánto podrías tener en el futuro repartiendo tu dinero entre renta fija y variable")
    with st.expander("ℹ️ Cómo funciona la simulación"):
        st.markdown("- **Monte Carlo**: sortea miles de veces años reales de la bolsa para crear futuros posibles; "
                    "la mediana es el «caso típico» y el P5/P95 los extremos razonables.\n"
                    "- **Ventanas históricas**: repite periodos reales completos (p. ej. empezar en 1990, en 1991…).\n"
                    "- **Buy and hold** invierte todo el primer día; **promediar** va añadiendo ahorro con el tiempo.\n"
                    "- La renta fija usa tipos actuales del BCE o la curva histórica según el modo elegido.")
    tipos, errs_tipos = tipos_actuales()
    if errs_tipos:
        with st.expander("⚠️ No se han podido leer todos los tipos de interés del BCE", expanded=True):
            for k, e in errs_tipos.items():
                st.write(f"**{ {'euribor12m': 'Euribor 12m', 'bono10': 'Bono euro 10 años'}[k] }**: {e}")
            st.caption("Puedes seguir con un tipo manual (en «Opciones avanzadas»). El detalle técnico queda en "
                       "errores.log. Prueba «Actualizar datos de mercado» en la barra lateral.")

    perfiles = fin.leer_perfiles()
    activo = perfiles.get("activo")
    perfil = perfiles["usuarios"].get(activo) if activo else None

    st.session_state.setdefault("c_rv", 60)
    with st.container(border=True):
        e1, e2 = st.columns([3, 2])
        estrategia = e1.radio("Estrategia", ["Promediar (aportaciones periódicas)", "Buy and hold (todo de golpe)"],
                              horizontal=True, key="c_estr",
                              help="Promediar (DCA): inviertes un capital hoy y vas añadiendo ahorro cada año o cada "
                                   "mes, así compras a precios distintos. Buy and hold: inviertes todo el primer día "
                                   "y no tocas nada hasta el final.")
        hold = estrategia.startswith("Buy")
        if hold:
            frecuencia = "Anual"
            e2.caption("Buy and hold: se invierte solo el capital inicial y se deja crecer sin añadir ni vender.")
        else:
            frecuencia = e2.radio("Las aportaciones son", ["Mensuales", "Anuales"], horizontal=True, key="c_frec")
        m_apo = 12 if frecuencia == "Mensuales" else 1
        a1, a2, a3, a4 = st.columns(4)
        inicial = a1.number_input("Dinero que inviertes hoy (€)", 0, 50_000_000, 10_000, 1_000, key="c_ini")
        aporte_in = a2.number_input("Ahorro que añades cada año (€)", 0, 5_000_000, 3_000, 500, key="c_apo",
                                    disabled=hold, help="Se reparte en cuotas iguales según la frecuencia elegida.")
        aporte = 0 if hold else aporte_in
        H = a3.number_input("¿Durante cuántos años?", 1, 30, 10, 1, key="c_H")
        w_pct = a4.slider("% en renta variable (bolsa)", 0, 100, key="c_rv", step=5,
                          help="El resto va a renta fija (más estable, menos rentable).")
        if perfil:
            st.button(f"Usar el reparto sugerido para {activo} ({perfil['nivel']}): {perfil['rv_sugerida']} % bolsa",
                      on_click=lambda: st.session_state.update(c_rv=int(perfil["rv_sugerida"])),
                      help="Basado en tu test de riesgo. Es orientativo.")
        else:
            st.caption("Haz el test de riesgo (menú de la izquierda) y te sugeriré un reparto.")

        with st.expander("Opciones avanzadas: índice, método y renta fija"):
            b1, b2, b3 = st.columns([2, 1, 1])
            indice = b1.selectbox("Índice de bolsa", list(fin.INDICES), key="c_idx",
                                  help="En dólares y con dividendos, sin convertir a euros. El «Mundo largo» "
                                       "empalma MSCI World (1973-2008) con el ETF Vanguard Total World (desde 2009).")
            metodo = b2.selectbox("Método", ["Monte Carlo (bootstrap)", "Ventanas históricas"], key="c_met",
                                  help="Monte Carlo: sortea años del histórico miles de veces. "
                                       "Ventanas: repite periodos reales consecutivos.")
            if metodo.startswith("Monte"):
                modo_rf = "Tipo constante"
                b3.selectbox("Renta fija", ["Tipo constante"], key="c_modo_mc", disabled=True)
            else:
                modo_rf = b3.selectbox("Renta fija", fin.MODOS_RF, key="c_modo",
                                       help="Tipo constante: rinde siempre lo mismo. Carry histórico: cada año gana "
                                            "el bono a 10 años de ese momento. Vencimiento objetivo: el año 1 compras "
                                            "un bono a H años, el 2 a H−1… y todo vence el último año.")
            r1, r2 = st.columns(2)
            fuente = r1.selectbox("¿Cuánto rinde la renta fija?",
                                  ["Euribor 12m actual", "Bono euro 10 años actual", "Manual"], key="c_fuente",
                                  help="Solo se usa en el modo «Tipo constante».")
            if fuente == "Euribor 12m actual" and tipos.get("euribor12m") is not None:
                r_const = tipos["euribor12m"]
            elif fuente == "Bono euro 10 años actual" and tipos.get("bono10") is not None:
                r_const = tipos["bono10"]
            else:
                r_const = r2.number_input("Tipo anual manual (%)", -1.0, 15.0, 2.5, 0.1, key="c_rman") / 100
            r_const_nom = r_const
            r_const = rf_efectivo(r_const)
            if modo_rf == "Tipo constante":
                r2.caption(f"La renta fija rinde un **{pct(r_const_nom)}** al año"
                           + (f" (**{pct(r_const)}** real, con un {pct(infl_euro_esperada(), 1)} de inflación "
                              "esperada del euro)" if modo_real() else "") + ".")
            else:
                r2.caption("En este modo el rendimiento sale de la curva histórica del BCE (desde 2004).")

    ret, nivel, err = datos_indice(indice)
    if err or ret is None:
        st.error(f"No se han podido descargar los datos del índice: {err}")
        return
    curva = None
    if modo_rf != "Tipo constante":
        curva, e2 = datos_curva()
        if curva is None:
            st.error(f"Hace falta la curva de tipos del BCE para este modo: {e2}")
            return
    w = w_pct / 100
    H = int(H)
    aportado = inicial + aporte * H

    if metodo.startswith("Monte"):
        tray = montecarlo(ret.values, H, w, r_const, inicial, aporte, n=5000, m=m_apo)
        etiqueta = f"5.000 simulaciones (bloques de {bloque_mc()} años)"
        idx = None
    else:
        tray_df, idx = fin.ventanas_historicas(ret, curva, H, w, modo_rf, inicial, aporte, r_const, m_apo,
                                               infl_rf=inflacion_rf())
        if tray_df.empty:
            st.warning("No hay años suficientes en el histórico para ese horizonte con estos datos. "
                       "Reduce el horizonte o usa el modo «Tipo constante».")
            return
        tray = tray_df.values
        etiqueta = f"{len(tray_df)} periodos históricos reales"
    res = fin.resumen_trayectorias(tray, aportado, inicial, aporte, H, m_apo)

    if hold:
        intro = (f'Si inviertes <b>{eur(inicial)}</b> hoy, todo de golpe, y lo dejas <b>{H} años</b> sin tocarlo '
                 f'({w_pct} % en bolsa y {100 - w_pct} % en renta fija)')
    else:
        cada = "cada mes" if m_apo == 12 else "cada año"
        intro = (f'Si inviertes <b>{eur(inicial)}</b> hoy y añades <b>{eur(aporte)} al año</b> '
                 f'(repartidos {cada}) durante <b>{H} años</b> ({w_pct} % en bolsa y {100 - w_pct} % en renta fija)')
    st.markdown(
        f'<div class="resumen">{intro}, habrás puesto <b>{eur(aportado)}</b>. En un caso típico tendrías '
        f'<b>{eur(res["mediana"])}</b>; en un mal escenario (1 de cada 20), <b>{eur(res["p5"])}</b>; y en uno '
        f'bueno (1 de cada 20), <b>{eur(res["p95"])}</b>. Probabilidad de acabar con menos de lo que pusiste: '
        f'<b>{pct(res["prob_perdida"], 1)}</b>.</div>', unsafe_allow_html=True)

    m = st.columns(5)
    m[0].metric("Pondrás en total", eur(aportado))
    m[1].metric("Caso típico", eur(res["mediana"]), delta=f"{res['multiplo_mediana']:.2f}× lo aportado",
                delta_color="off", help="La mitad de los casos acaba por encima y la mitad por debajo (mediana).")
    m[2].metric("Mal escenario", eur(res["p5"]), help="Solo 1 de cada 20 casos acaba peor que esto (percentil 5).")
    m[3].metric("Buen escenario", eur(res["p95"]), help="Solo 1 de cada 20 casos acaba mejor que esto (percentil 95).")
    m[4].metric("Prob. de perder", pct(res["prob_perdida"], 1), help="Probabilidad de acabar con menos de lo aportado")

    t_cartera, t_plazos, t_obj = st.tabs(["📈 Tu cartera", "🗓️ A distintos plazos", "🎯 Objetivo y riesgos"])
    st.info("¿Quieres comparar repartos o estrategias, o ver el histórico del índice? Tienes las páginas "
            "**Comparador** y **Mercado** en el menú de la izquierda.", icon="ℹ️")

    # ------------------------------------------------------------ tu cartera
    with t_cartera:
        st.caption(f"{etiqueta}, con datos {ret.index.min()}–{ret.index.max()} (índice en dólares).")
        años = np.arange(1, H + 1)
        fig = go.Figure()
        if idx is not None:
            for fila, s0 in zip(tray, idx):
                fig.add_scatter(x=años, y=fila, mode="lines", line=dict(width=1, color="rgba(76,154,255,.35)"),
                                name=f"Inicio {s0}", hovertemplate=f"Inicio {s0}: %{{y:,.0f}} €<extra></extra>",
                                showlegend=False)
        else:
            p = np.percentile(tray, [5, 25, 75, 95], axis=0)
            fig.add_scatter(x=años, y=p[3], mode="lines", line=dict(width=0), showlegend=False, hoverinfo="skip")
            fig.add_scatter(x=años, y=p[0], mode="lines", fill="tonexty", fillcolor="rgba(76,154,255,.15)",
                            line=dict(width=0), name="9 de cada 10 casos caen aquí")
            fig.add_scatter(x=años, y=p[2], mode="lines", line=dict(width=0), showlegend=False, hoverinfo="skip")
            fig.add_scatter(x=años, y=p[1], mode="lines", fill="tonexty", fillcolor="rgba(76,154,255,.32)",
                            line=dict(width=0), name="La mitad de los casos cae aquí")
        fig.add_scatter(x=años, y=np.median(tray, axis=0), mode="lines", name="Caso típico",
                        line=dict(color=C_MEDIA, width=3))
        ap = np.cumsum(np.full(H, float(aporte))) + inicial
        fig.add_scatter(x=años, y=ap, mode="lines", name="Lo que has puesto", line=dict(color="#8B93A7", dash="dash"))
        fig.update_layout(xaxis_title="Años", yaxis_title="€")
        c1, c2 = st.columns(2, gap="large")
        with c1:
            st.markdown("**¿Cómo crece mi dinero?**")
            explica("La línea naranja es el caso típico. Las zonas azules muestran cuánto puede variar el resultado.")
            st.plotly_chart(estilo(fig, 400), width="stretch")
        with c2:
            st.markdown("**¿Qué resultados finales son más probables?**")
            explica("Cuanto más alta la barra, más veces salió ese resultado. La línea naranja marca lo que pusiste.")
            hh = go.Figure(go.Histogram(x=tray[:, -1], nbinsx=40, marker_color=C_CAP, name="Casos"))
            hh.add_vline(x=aportado, line_dash="dash", line_color=C_INT, annotation_text="Lo que pusiste",
                         annotation_position="top")
            hh.update_layout(xaxis_title="€ al final", yaxis_title="Nº de casos")
            st.plotly_chart(estilo(hh, 400, "no"), width="stretch")

    # ------------------------------------------------------------ percentiles por horizonte
    with t_plazos:
        st.markdown("**¿Cuánto tendría según el plazo?**")
        explica("Monte Carlo con tu mismo reparto, mirando 1, 2, 3, 5… hasta 30 años. Cada grupo de barras es un "
                "plazo: de «mal escenario» (rojizo) a «buen escenario» (verde). La línea gris es lo que habrías puesto.")
        Hmax = max(30, H)
        mc = montecarlo(ret.values, Hmax, w, r_const, inicial, aporte, n=5000, m=m_apo)
        horizontes = [h for h in (1, 2, 3, 5, 7, 10, 15, 20, 25, 30, 35, 40) if h <= Hmax]
        pcts = [(5, "Mal escenario (P5)", "#D55E00"), (25, "Algo peor que lo típico (P25)", "#F5A524"),
                (50, "Caso típico (P50)", "#4C9AFF"), (75, "Algo mejor que lo típico (P75)", "#2EC4A6"),
                (95, "Buen escenario (P95)", "#009E73")]
        etiquetas = [f"{h} años" for h in horizontes]
        pf = go.Figure()
        for q, nombre, color in pcts:
            pf.add_bar(x=etiquetas, y=[float(np.percentile(mc[:, h - 1], q)) for h in horizontes], name=nombre,
                       marker_color=color)
        pf.add_scatter(x=etiquetas, y=[inicial + aporte * h for h in horizontes], mode="lines+markers",
                       name="Lo que habrías puesto", line=dict(color="#8B93A7", dash="dash"))
        pf.update_layout(barmode="group", yaxis_title="€ acumulados", xaxis_title="Plazo")
        st.plotly_chart(estilo(pf, 440), width="stretch")
        tabla = pd.DataFrame({"Plazo": etiquetas,
                              "Pones en total": [inicial + aporte * h for h in horizontes],
                              "Mal escenario": [float(np.percentile(mc[:, h - 1], 5)) for h in horizontes],
                              "Caso típico": [float(np.percentile(mc[:, h - 1], 50)) for h in horizontes],
                              "Buen escenario": [float(np.percentile(mc[:, h - 1], 95)) for h in horizontes],
                              "Prob. de perder": [float(np.mean(mc[:, h - 1] < inicial + aporte * h))
                                                  for h in horizontes]})
        st.dataframe(tabla, hide_index=True, width="stretch", column_config={
            **{c: st.column_config.NumberColumn(format="%.0f €") for c in
               ["Pones en total", "Mal escenario", "Caso típico", "Buen escenario"]},
            "Prob. de perder": st.column_config.NumberColumn(format="percent")})
        st.caption(f"5.000 simulaciones con la renta fija al {pct(r_const)} constante. "
                   f"Sigues añadiendo {eur(aporte)} cada año.")

    # ------------------------------------------------------------ objetivo y riesgos
    with t_obj:
        st.markdown("**¿Qué probabilidad hay de llegar a mi objetivo?**")
        explica("Escribe la cantidad que te gustaría tener al final. Se cuenta en qué parte de los futuros posibles la "
                "alcanzas, y puedes ver todo en euros de hoy descontando la inflación.")
        o1, o2 = st.columns(2)
        meta = o1.number_input("Objetivo al final (€)", 100, 100_000_000, int(max(round(aportado * 1.5, -3), 1000)),
                               1_000, key="c_meta")
        if modo_real():
            infl_c = 0.0
            o2.caption("Estás en **modo real**: todas las cifras ya están en dinero de hoy.")
        else:
            infl_c = o2.number_input("Inflación para ver euros de hoy (% anual)", 0.0, 10.0, 2.0, 0.25,
                                     key="c_infl") / 100
        finales = tray[:, -1]
        deflactor = (1 + infl_c) ** H
        r1 = st.columns(4)
        r1[0].metric("Probabilidad de llegar", pct(float(np.mean(finales >= meta)), 0),
                     help="Parte de las trayectorias que acaba en el objetivo o por encima.")
        r1[1].metric("Caso típico en euros de hoy", eur(res["mediana"] / deflactor),
                     help=f"El caso típico ({eur(res['mediana'])}) descontando una inflación del {pct(infl_c)}.")
        r1[2].metric("Mal escenario en euros de hoy", eur(res["p5"] / deflactor))
        r1[3].metric("Objetivo en euros de hoy", eur(meta / deflactor),
                     help="Lo que valdrían hoy esos euros futuros.")
        pr = [float(np.mean(finales >= x)) for x in np.linspace(finales.min(), np.percentile(finales, 99), 60)]
        xs_o = np.linspace(finales.min(), np.percentile(finales, 99), 60)
        fo = go.Figure(go.Scatter(x=xs_o, y=np.array(pr) * 100, mode="lines", fill="tozeroy",
                                  line=dict(color=C_CAP, width=3), fillcolor="rgba(76,154,255,.15)",
                                  hovertemplate="Llegar a %{x:,.0f} €: %{y:.0f} % de probabilidad<extra></extra>"))
        fo.add_vline(x=meta, line_dash="dash", line_color=C_INT, annotation_text="Tu objetivo")
        fo.update_layout(xaxis_title="Cantidad final (€)", yaxis_title="Probabilidad de llegar (%)", yaxis_range=[0, 100])
        st.markdown("**Probabilidad de alcanzar cada cantidad**")
        st.plotly_chart(estilo(fo, 340, "no"), width="stretch")

        st.markdown("**¿Cómo habría ido empezando en el peor momento?**")
        explica("Con periodos reales: los años de inicio con peor y mejor resultado final (índice en dólares, renta "
                "fija a tipo constante). Sirve para ver el riesgo de «empezar justo antes de una crisis».")
        try:
            tdf, idx_h = fin.ventanas_historicas(ret, None, H, w, "Tipo constante", inicial, aporte, r_const, m_apo)
        except Exception as e:
            fin.registrar_error("Cartera peores inicios", e)
            tdf, idx_h = pd.DataFrame(), None
        if idx_h is not None and not tdf.empty:
            fin_h = pd.DataFrame({"Inicio": idx_h, "Final": tdf.values[:, -1]})
            fin_h["Múltiplo"] = fin_h["Final"] / aportado
            cc1, cc2 = st.columns(2)
            cfg = {"Final": st.column_config.NumberColumn(format="%.0f €"),
                   "Múltiplo": st.column_config.NumberColumn(format="%.2f×")}
            cc1.markdown("Peores inicios")
            cc1.dataframe(fin_h.nsmallest(5, "Final"), hide_index=True, width="stretch", column_config=cfg)
            cc2.markdown("Mejores inicios")
            cc2.dataframe(fin_h.nlargest(5, "Final"), hide_index=True, width="stretch", column_config=cfg)
        else:
            st.info("No hay años suficientes en el histórico para ese plazo.")

        st.markdown("**Exportar**")
        per = pd.DataFrame({"Año": np.arange(1, H + 1)})
        for q_ in (5, 25, 50, 75, 95):
            per[f"P{q_}"] = np.percentile(tray, q_, axis=0)
        per["Aportado"] = inicial + aporte * np.arange(1, H + 1)
        st.download_button("⬇️ Descargar percentiles por año (CSV)", per.to_csv(index=False, sep=";", decimal=",")
                           .encode("utf-8-sig"), "percentiles_cartera.csv", "text/csv", key="c_dl")

    st.caption("Resultados orientativos basados en el pasado; no son asesoramiento financiero. El índice está en "
               f"dólares (sin convertir a euros), sin comisiones ni impuestos, {etiqueta_modo()}.")
:::END
:::BEGIN py/paginas/comparador.py|text
"""Página Comparador."""
from ui import *  # noqa: F401,F403  (st, np, pd, go, fin y utilidades comunes)


def pag_comparador():
    titulo_pagina("⚖️", "Comparador", "Compara repartos bolsa/renta fija, estrategias y formas de modelar la renta fija")
    tipos, _ = tipos_actuales()
    with st.container(border=True):
        a1, a2, a3, a4 = st.columns(4)
        inicial = a1.number_input("Dinero que inviertes hoy (€)", 0, 50_000_000, 10_000, 1_000, key="k_ini")
        aporte = a2.number_input("Ahorro que añades cada año (€)", 0, 5_000_000, 3_000, 500, key="k_apo")
        H = int(a3.number_input("¿Durante cuántos años?", 1, 30, 10, 1, key="k_H"))
        frecuencia = a4.radio("Las aportaciones son", ["Mensuales", "Anuales"], horizontal=True, key="k_frec")
        m_apo = 12 if frecuencia == "Mensuales" else 1
        w_pct = st.slider("% en bolsa (pestañas 2 y 3)", 0, 100, 60, 5, key="k_rv",
                          help="La primera pestaña recorre todos los repartos; las otras usan este.")
        with st.expander("Opciones avanzadas: índice y renta fija"):
            b1, b3 = st.columns(2)
            indice = b1.selectbox("Índice de bolsa", list(fin.INDICES), key="k_idx")
            fuente = b3.selectbox("¿Cuánto rinde la renta fija?",
                                  ["Euribor 12m actual", "Bono euro 10 años actual", "Manual"], key="k_fuente")
            if fuente == "Euribor 12m actual" and tipos.get("euribor12m") is not None:
                r_const = tipos["euribor12m"]
            elif fuente == "Bono euro 10 años actual" and tipos.get("bono10") is not None:
                r_const = tipos["bono10"]
            else:
                r_const = b3.number_input("Tipo anual manual (%)", -1.0, 15.0, 2.5, 0.1, key="k_rman") / 100
            r_const = rf_efectivo(r_const)
    ret, nivel, err = datos_indice(indice)
    if err or ret is None:
        st.error(f"No se han podido descargar los datos del índice: {err}")
        return
    w = w_pct / 100
    aportado = inicial + aporte * H
    t_rep, t_est, t_rf, t_ab, t_fee = st.tabs(["⚖️ Reparto bolsa / renta fija", "🛒 Todo de golpe vs promediando",
                                               "🏦 Formas de modelar la renta fija", "👥 Cartera A vs B",
                                               "💸 Comisiones"])
    with t_rep:
        st.markdown("**¿Y si cambio el reparto entre bolsa y renta fija?**")
        explica("Cada punto es un reparto (0 % a 100 % en bolsa). Más a la derecha = más sube y baja. "
                "La línea continua es el caso típico; la de puntos, el mal escenario.")
        fr = frontera(ret.values, r_const, H, inicial, aporte, m=m_apo)
        f2 = go.Figure()
        f2.add_scatter(x=fr["Vol. anual"] * 100, y=fr["Mediana final"], mode="lines+markers+text",
                       text=[f"{int(x)} %" for x in fr["% renta variable"]], textposition="top center",
                       line=dict(color=C_CAP, width=3), name="Caso típico")
        f2.add_scatter(x=fr["Vol. anual"] * 100, y=fr["P5 final"], mode="lines+markers",
                       line=dict(color="#D55E00", width=2, dash="dot"), name="Mal escenario")
        f2.update_layout(xaxis_title="Cuánto sube y baja al año (%)", yaxis_title="€ al final")
        st.plotly_chart(estilo(f2, 380), width="stretch")
        fr_t = fr.rename(columns={"Vol. anual": "Sube y baja (anual)", "Mediana final": "Caso típico",
                                  "P5 final": "Mal escenario", "TIR mediana": "Rentab. anual típica"})
        st.dataframe(fr_t, hide_index=True, width="stretch", column_config={
            "Sube y baja (anual)": st.column_config.NumberColumn(format="percent"),
            "Peor año": st.column_config.NumberColumn(format="percent"),
            "Caso típico": st.column_config.NumberColumn(format="%.0f €"),
            "Mal escenario": st.column_config.NumberColumn(format="%.0f €"),
            "Prob. pérdida": st.column_config.NumberColumn(format="percent"),
            "Rentab. anual típica": st.column_config.NumberColumn(format="percent")})
        lim_p = st.select_slider("Quiero que la probabilidad de perder sea como mucho…", options=[0, 1, 2, 5, 10, 20],
                                 value=5, key="k_limp", format_func=lambda x: f"{x} %")
        ok_r = fr[fr["Prob. pérdida"] <= lim_p / 100]
        if ok_r.empty:
            st.info("Ningún reparto cumple ese límite con estos datos. Sube el límite o el número de años.")
        else:
            mejor = ok_r.sort_values("% renta variable").iloc[-1]
            st.success(f"Con ese límite, el reparto con más bolsa es **{int(mejor['% renta variable'])} % en bolsa**: "
                       f"caso típico {eur(mejor['Mediana final'])} y mal escenario {eur(mejor['P5 final'])}.")

    with t_est:
        if aporte <= 0:
            st.info("Pon un ahorro anual mayor que 0 para comparar con las aportaciones periódicas.")
        else:
            st.markdown("**¿Todo de golpe (buy and hold) o promediando?**")
            explica(f"Mismo dinero total ({eur(aportado)}) y mismo reparto. Todo de golpe: lo inviertes el primer día "
                    "y no tocas nada. Promediar: tu capital de hoy más las aportaciones periódicas que has elegido. "
                    "Todo de golpe suele ganar de media porque el dinero está más tiempo en el mercado, pero "
                    "promediar reduce el riesgo de entrar justo antes de una caída y no exige tener todo el dinero ya.")
            mc_h = montecarlo(ret.values, H, w, r_const, aportado, 0, n=5000, m=1)
            mc_p = montecarlo(ret.values, H, w, r_const, inicial, aporte, n=5000, m=m_apo)
            cmp_f = go.Figure()
            for nombre, mcx, color in (("Todo de golpe (buy and hold)", mc_h, C_CAP), ("Promediando", mc_p, C_INT)):
                cmp_f.add_bar(x=["Mal escenario", "Caso típico", "Buen escenario"],
                              y=[float(np.percentile(mcx[:, -1], q)) for q in (5, 50, 95)], name=nombre,
                              marker_color=color)
            cmp_f.update_layout(barmode="group", yaxis_title=f"€ al cabo de {H} años")
            st.plotly_chart(estilo(cmp_f, 360), width="stretch")
            st.dataframe(pd.DataFrame({
                "Estrategia": ["Todo de golpe (buy and hold)", "Promediando"],
                "Mal escenario": [float(np.percentile(x[:, -1], 5)) for x in (mc_h, mc_p)],
                "Caso típico": [float(np.percentile(x[:, -1], 50)) for x in (mc_h, mc_p)],
                "Buen escenario": [float(np.percentile(x[:, -1], 95)) for x in (mc_h, mc_p)],
                "Prob. de perder": [float(np.mean(x[:, -1] < aportado)) for x in (mc_h, mc_p)]}),
                hide_index=True, width="stretch", column_config={
                    **{c: st.column_config.NumberColumn(format="%.0f €") for c in
                       ["Mal escenario", "Caso típico", "Buen escenario"]},
                    "Prob. de perder": st.column_config.NumberColumn(format="percent")})

    with t_rf:
        st.markdown("**Tres formas de modelar la renta fija**")
        explica("Con periodos históricos reales. «Tipo constante»: rinde siempre lo mismo. «Carry»: cada año gana "
                "el bono a 10 años de ese momento. «Vencimiento objetivo» compra cada año un bono que vence al "
                "final del plazo (a H años, luego H−1…) con la curva del BCE de ese momento.")
        cv, e_cv = datos_curva()
        filas = []
        for mo in (fin.MODOS_RF if cv is not None else []):
            dd, _ = fin.ventanas_historicas(ret, cv, H, w, mo, inicial, aporte, r_const, m_apo,
                                            infl_rf=inflacion_rf())
            if dd.empty:
                continue
            s1 = fin.resumen_trayectorias(dd.values, aportado, inicial, aporte, H, m_apo)
            filas.append({"Renta fija": mo, "Periodos": len(dd), "Mal escenario": s1["p5"],
                          "Caso típico": s1["mediana"], "Buen escenario": s1["p95"],
                          "Prob. de perder": s1["prob_perdida"]})
        if filas:
            st.dataframe(pd.DataFrame(filas), hide_index=True, width="stretch", column_config={
                **{c: st.column_config.NumberColumn(format="%.0f €") for c in
                   ["Mal escenario", "Caso típico", "Buen escenario"]},
                "Prob. de perder": st.column_config.NumberColumn(format="percent")})
        else:
            st.info(f"No hay datos de la curva del BCE para esta comparación. {e_cv or ''}")

    with t_ab:
        explica("Compara dos repartos con el mismo dinero, plazo y aportaciones. La línea es el caso típico y la banda, "
                "9 de cada 10 casos.")
        u1, u2 = st.columns(2)
        wa = u1.slider("Cartera A: % en bolsa", 0, 100, 40, 5, key="k_wa")
        wb = u2.slider("Cartera B: % en bolsa", 0, 100, 80, 5, key="k_wb")
        mcs = {"A": montecarlo(ret.values, H, wa / 100, r_const, inicial, aporte, n=5000, m=m_apo),
               "B": montecarlo(ret.values, H, wb / 100, r_const, inicial, aporte, n=5000, m=m_apo)}
        pesos_lbl = {"A": wa, "B": wb}
        cols_ab = {"A": C_CAP, "B": C_INT}
        años_ab = np.arange(1, H + 1)
        fab = go.Figure()
        for k_, mcx in mcs.items():
            p_ = np.percentile(mcx, [5, 50, 95], axis=0)
            fab.add_scatter(x=años_ab, y=p_[2], mode="lines", line=dict(width=0), showlegend=False, hoverinfo="skip")
            fab.add_scatter(x=años_ab, y=p_[0], mode="lines", fill="tonexty",
                            fillcolor="rgba(76,154,255,.15)" if k_ == "A" else "rgba(245,165,36,.15)",
                            line=dict(width=0), showlegend=False, hoverinfo="skip")
            fab.add_scatter(x=años_ab, y=p_[1], mode="lines", name=f"{k_} ({pesos_lbl[k_]} % bolsa)",
                            line=dict(color=cols_ab[k_], width=3))
        fab.add_scatter(x=años_ab, y=inicial + aporte * años_ab, mode="lines", name="Lo que pones",
                        line=dict(color="#8B93A7", dash="dash"))
        fab.update_layout(xaxis_title="Años", yaxis_title="€")
        st.plotly_chart(estilo(fab, 380), width="stretch")
        st.dataframe(pd.DataFrame([{
            "Cartera": f"{k_} ({pesos_lbl[k_]} % bolsa)", "Mal escenario": float(np.percentile(x[:, -1], 5)),
            "Caso típico": float(np.median(x[:, -1])), "Buen escenario": float(np.percentile(x[:, -1], 95)),
            "Prob. de perder": float(np.mean(x[:, -1] < aportado)),
            "TIR típica": float(np.median((x[:, -1] / aportado) ** (1 / H) - 1))} for k_, x in mcs.items()]),
            hide_index=True, width="stretch", column_config={
                **{c: st.column_config.NumberColumn(format="%.0f €") for c in
                   ["Mal escenario", "Caso típico", "Buen escenario"]},
                "Prob. de perder": st.column_config.NumberColumn(format="percent"),
                "TIR típica": st.column_config.NumberColumn(format="percent")})

    with t_fee:
        explica("Las comisiones se llevan una parte de la rentabilidad cada año. Aquí se resta a la bolsa la comisión "
                "anual (TER) y se compara lo que tendrías al final. Un 1 % parece poco, pero compuesto durante años "
                "pesa mucho.")
        fees = [0.0, 0.1, 0.5, 1.0, 1.5, 2.0]
        sel_fees = st.multiselect("Comisiones anuales a comparar (%)", fees, default=[0.0, 0.5, 1.5], key="k_fees")
        filas_f, fig_f = [], go.Figure()
        base_med = None
        for fe in sorted(sel_fees):
            mcf = montecarlo(ret.values - fe / 100, H, w, r_const, inicial, aporte, n=5000, m=m_apo)
            med = float(np.median(mcf[:, -1]))
            if base_med is None:
                base_med = med
            filas_f.append({"Comisión": f"{fe:.1f} %", "Caso típico": med, "Mal escenario": float(np.percentile(mcf[:, -1], 5)),
                            "Pierdes por comisiones": base_med - med})
            fig_f.add_scatter(x=np.arange(1, H + 1), y=np.median(mcf, axis=0), mode="lines", name=f"{fe:.1f} %")
        fig_f.update_layout(xaxis_title="Años", yaxis_title="€ (caso típico)")
        if filas_f:
            st.plotly_chart(estilo(fig_f, 360), width="stretch")
            st.dataframe(pd.DataFrame(filas_f), hide_index=True, width="stretch", column_config={
                c: st.column_config.NumberColumn(format="%.0f €") for c in
                ["Caso típico", "Mal escenario", "Pierdes por comisiones"]})
            st.caption("La comisión se aplica a la parte en bolsa. Misma semilla en todos los casos, así la "
                       "diferencia se debe solo a la comisión.")

    st.caption("Resultados orientativos basados en el pasado; no son asesoramiento financiero.")
:::END
:::BEGIN py/paginas/hipoteca.py|text
"""Página Hipoteca."""
from ui import *  # noqa: F401,F403  (st, np, pd, go, fin y utilidades comunes)


def formula_neon(cap, tin, n_meses, c, tipo, df, tin2=None, c2=None, anios_fijos=5, tae_v=None, extra=False):
    i = tin / 12
    span = lambda cls, t: f'<span class="{cls}">{t}</span>'
    P, I, N, C = (span("nc", num(cap, 0)), span("nt", f"{i:.6f}".replace(".", ",")),
                  span("nn", str(n_meses)), span("nq", num(c, 2)))
    bruta = (f'{span("nq", "C")} = {span("nc", "P")} · {span("nt", "i")} / '
             f'(1 − (1 + {span("nt", "i")})<sup>−{span("nn", "n")}</sup>)')
    bloques = [
        ('Cuota mensual · sistema francés',
         f'<div class="f">{bruta}</div>'
         f'<div class="f s">{span("nq", "C")} = {P} · {I} / (1 − (1 + {I})<sup>−{N}</sup>) = <b>{C} €</b></div>'
         f'<span class="tag nc">P capital {num(cap, 0)} €</span>'
         f'<span class="tag nt">i = TIN/12 = {pct(tin)} / 12</span>'
         f'<span class="tag nn">n = {n_meses} meses</span>')]
    if len(df):
        r0 = df.iloc[0]
        bloques.append((
            'Primer recibo',
            f'<div class="f s">Interés = {span("nc", "P")} · {span("nt", "i")} = {P} · {I} = '
            f'<b>{span("nq", num(r0.intereses, 2))} €</b></div>'
            f'<div class="f s">Amortización = {span("nq", "C")} − Interés = {C} − {num(r0.intereses, 2)} = '
            f'<b>{span("nq", num(r0.amortizacion, 2))} €</b></div>'))
    if tipo == "Variable":
        bloques.append((
            'Revisión anual',
            f'<div class="f s">Nuevo {span("nt", "TIN")} = Euribor + diferencial'
            + (f' = <b>{span("nt", pct(tin2))}</b>' if tin2 is not None else '')
            + f'. Se recalcula {span("nq", "C")} con el saldo vivo y los meses que quedan'
            + (f' → <b>{span("nq", num(c2, 2))} €</b>' if c2 is not None else '') + '.</div>'))
    if tipo == "Mixto" and c2 is not None:
        bloques.append((
            'Tras el tramo fijo',
            f'<div class="f s">Desde el mes {anios_fijos * 12 + 1}: {span("nt", "TIN")} = Euribor + diferencial = '
            f'{span("nt", pct(tin2))} → nueva cuota <b>{span("nq", num(c2, 2))} €</b></div>'))
    if tae_v is not None:
        bloques.append((
            'TAE',
            f'<div class="f s">Capital neto = Σ (cuota + seguros)<sub>t</sub> / (1 + TIR<sub>mes</sub>)<sup>t</sup><br>'
            f'{span("na", "TAE")} = (1 + TIR<sub>mes</sub>)<sup>12</sup> − 1 = <b>{span("na", pct(tae_v))}</b></div>'))
    html = ['<div class="neon"><div class="grid">']
    for titulo, cuerpo in bloques:
        html.append(f'<div><h4>{titulo}</h4>{cuerpo}</div>')
    html.append('</div>')
    if extra:
        html.append('<div class="sep"></div><div class="nota">Con amortizaciones anticipadas la cuota se '
                    'recalcula sobre el saldo restante; la TAE se calcula siempre sin ellas, como exige la '
                    'normativa.</div>')
    html.append('</div>')
    st.markdown("".join(html), unsafe_allow_html=True)


def pag_hipoteca():
    titulo_pagina("🏠", "Hipoteca", "Calcula cuánto pagarás al mes y cuánto te costará el préstamo")
    with st.expander("ℹ️ Cómo usar esta página"):
        st.markdown("1. Rellena arriba el precio, lo que aportas de entrada, los años y el tipo de interés.\n"
                    "2. Elige **fija, variable o mixta**: en la variable el tipo es Euribor + diferencial y se revisa cada año.\n"
                    "3. En «Opciones avanzadas» añades gastos de compra, seguros y **amortizaciones anticipadas**.\n"
                    "4. Mira la **TAE**: es el coste real anual, porque incluye comisiones y gastos del préstamo.")
    tipos, err = tipos_actuales()
    eur_def = tipos["euribor12m"] if tipos.get("euribor12m") is not None else 0.025

    with st.container(border=True):
        c1, c2, c3, c4 = st.columns(4)
        precio = c1.number_input("Precio de la vivienda (€)", 20_000, 5_000_000, 250_000, 5_000, key="h_precio")
        entrada_pct = c2.number_input("Entrada (%)", 0.0, 100.0, 20.0, 1.0, key="h_entrada",
                                      help="Lo que pagas tú de tu bolsillo. Lo habitual es el 20 %.")
        anios = c3.number_input("Plazo (años)", 1, 40, 30, 1, key="h_anios")
        tipo = c4.selectbox("Tipo de hipoteca", ["Fijo", "Variable", "Mixto"], key="h_tipo",
                            help="Fijo: el interés no cambia. Variable: sube o baja con el Euribor. "
                                 "Mixto: fijo unos años y luego variable.")

        d1, d2, d3, d4 = st.columns(4)
        tin_fijo = diferencial = euribor = paso = 0.0
        anios_fijos = 5
        if tipo in ("Fijo", "Mixto"):
            tin_fijo = d1.number_input("TIN fijo (%)", 0.0, 15.0, 2.60, 0.05, key="h_tin",
                                       help="Tipo de interés nominal anual que te ofrece el banco.") / 100
        if tipo == "Mixto":
            anios_fijos = d2.number_input("Años a tipo fijo", 1, 39, 5, 1, key="h_afijos")
        if tipo in ("Variable", "Mixto"):
            diferencial = d3.number_input("Diferencial (%)", -1.0, 5.0, 0.80, 0.05, key="h_dif") / 100
            euribor = d4.number_input("Euribor 12m supuesto (%)", -1.0, 10.0, round(eur_def * 100, 2), 0.05,
                                      key="h_eur", help="Por defecto, el último dato del BCE") / 100
            paso = d1.number_input("Variación anual del Euribor (pp)", -2.0, 2.0, 0.0, 0.1, key="h_paso") / 100

        with st.expander("Opciones avanzadas: gastos de compra, seguros y amortizaciones anticipadas"):
            e1, e2, e3, e4 = st.columns(4)
            vivienda = e1.selectbox("Vivienda", ["Usada", "Nueva"], key="h_viv",
                                    help="Usada: paga ITP. Nueva: paga IVA + AJD.")
            if vivienda == "Usada":
                itp = e2.number_input("ITP (%)", 0.0, 12.0, 6.0, 0.5, key="h_itp",
                                      help="Madrid: 6 %. Cambia según comunidad.") / 100
                iva = ajd = 0.0
            else:
                iva = e2.number_input("IVA (%)", 0.0, 21.0, 10.0, 0.5, key="h_iva") / 100
                ajd = e3.number_input("AJD (%)", 0.0, 3.0, 0.75, 0.05, key="h_ajd") / 100
                itp = 0.0
            notaria = e4.number_input("Notaría + registro + gestoría (€)", 0, 20_000, 2_500, 100, key="h_not")
            f1, f2, f3, f4 = st.columns(4)
            tasacion = f1.number_input("Tasación (€)", 0, 3_000, 400, 50, key="h_tas")
            comision = f2.number_input("Comisión de apertura (%)", 0.0, 3.0, 0.0, 0.1, key="h_com") / 100
            seguros = f3.number_input("Seguros vinculados (€/mes)", 0, 500, 0, 5, key="h_seg",
                                      help="Entran en la TAE")
            f4.write("")
            g1, g2, g3 = st.columns(3)
            extra_m = g1.number_input("Amortización extra mensual (€)", 0, 20_000, 0, 50, key="h_exm")
            extra_a = g2.number_input("Amortización extra anual (€, cada diciembre)", 0, 500_000, 0, 500,
                                      key="h_exa")
            modo_extra = g3.radio("Con las amortizaciones…", ["Reducir plazo", "Reducir cuota"],
                                  horizontal=True, key="h_modo")

    entrada = precio * entrada_pct / 100
    capital = precio - entrada
    if capital <= 0:
        st.warning("La entrada cubre todo el precio: no hay hipoteca que calcular.")
        return
    gastos = fin.gastos_compra(precio, vivienda, itp, iva, ajd, notaria, tasacion, comision, capital)
    gastos_total = sum(gastos.values())
    modo = "plazo" if modo_extra == "Reducir plazo" else "cuota"
    args = dict(tipo=tipo, tin_fijo=tin_fijo, diferencial=diferencial, euribor=euribor, paso_euribor=paso,
                anios_fijos=anios_fijos)
    base = fin.cuadro(capital, anios, **args)
    con_extra = (fin.cuadro(capital, anios, extra_mensual=extra_m, extra_anual=extra_a, modo_extra=modo, **args)
                 if (extra_m or extra_a) else base)
    hay_extra = bool(extra_m or extra_a)
    ligados = gastos["Comisión de apertura"] + tasacion          # gastos ligados al préstamo para la TAE
    tae_v = fin.tae(capital, base, ligados, seguros)
    n = anios * 12
    tin0 = fin.tin_del_mes(0, tipo, tin_fijo, diferencial, euribor, paso, anios_fijos)
    c0 = float(base.cuota.iloc[0])

    total_int = con_extra.intereses.sum()
    total_pagado = con_extra.cuota.sum() + con_extra.extra.sum()
    meses_reales = len(con_extra)

    tin2 = c2 = None
    if tipo in ("Variable", "Mixto"):
        mes_cambio = anios_fijos * 12 if tipo == "Mixto" else 12
        if len(base) > mes_cambio:
            tin2 = float(base.tin.iloc[mes_cambio])
            c2 = float(base.cuota.iloc[mes_cambio])
    with st.expander("Cómo se calcula la cuota (fórmula)", expanded=True):
        formula_neon(capital, tin0, n, c0, tipo, base, tin2=tin2, c2=c2, anios_fijos=anios_fijos,
                     tae_v=tae_v, extra=hay_extra)

    desde = "al mes" if tipo == "Fijo" else "al mes al principio (puede cambiar al revisarse el tipo)"
    st.markdown(
        f'<div class="resumen">Pagarás <b>{eur(c0, 2)} {desde}</b> durante <b>{meses_reales // 12} años'
        + (f' y {meses_reales % 12} meses' if meses_reales % 12 else '') + f'</b>. En total devolverás '
        f'<b>{eur(total_pagado)}</b>, de los que <b>{eur(total_int)}</b> son intereses (lo que te cuesta el '
        f'préstamo). Para comprar necesitas tener ahorrados <b>{eur(entrada + gastos_total)}</b> '
        f'(entrada + impuestos y gastos).</div>', unsafe_allow_html=True)

    m = st.columns(4)
    m[0].metric("Cuota mensual" if tipo == "Fijo" else "Cuota inicial", eur(c0, 2))
    m[1].metric("Intereses totales", eur(total_int), help="Lo que pagas de más sobre el dinero prestado")
    m[2].metric("TAE", pct(tae_v), help="Coste anual real del préstamo, incluyendo comisiones y seguros")
    m[3].metric("Ahorro necesario", eur(entrada + gastos_total),
                help="Entrada + gastos de compra (impuestos, notaría, tasación, comisión)")
    if hay_extra:
        a = st.columns(3)
        a[0].metric("Intereses que te ahorras", eur(base.intereses.sum() - total_int))
        a[1].metric("Duración real", f"{meses_reales // 12} a {meses_reales % 12} m",
                    delta=f"{meses_reales - len(base)} meses" if meses_reales != len(base) else None,
                    delta_color="off")
        a[2].metric("Cuota final", eur(float(con_extra.cuota.iloc[-1]), 2))

    t_graf, t_compra, t_mas, t_cuadro = st.tabs(["📊 Gráficos", "🧾 Compra y gastos", "🔍 Más análisis",
                                                 "📋 Cuadro de amortización"])

    with t_graf:
        g1, g2 = st.columns(2, gap="large")
        with g1:
            st.markdown("**¿Cuánto debo en cada momento?**")
            explica("Es el dinero que todavía le debes al banco. Baja despacio al principio y más deprisa al final.")
            saldo = pd.concat([pd.DataFrame({"mes": [0], "saldo": [capital]}), con_extra[["mes", "saldo"]]])
            f1 = go.Figure(go.Scatter(x=saldo.mes / 12, y=saldo.saldo, mode="lines", fill="tozeroy",
                                      line=dict(color=C_SALDO, width=3), fillcolor="rgba(167,139,250,.18)",
                                      name="Deuda pendiente",
                                      hovertemplate="Año %{x:.1f}: debes %{y:,.0f} €<extra></extra>"))
            f1.update_layout(xaxis_title="Años desde la firma", yaxis_title="€ que debes")
            st.plotly_chart(estilo(f1, 340, "no"), width="stretch")
        with g2:
            st.markdown("**¿Qué parte del dinero es interés?**")
            explica("Del total que acabarás pagando al banco, cuánto es el préstamo y cuánto el coste.")
            f2 = go.Figure(go.Pie(labels=["Dinero prestado", "Intereses"], values=[capital, total_int], hole=.62,
                                  marker_colors=[C_CAP, C_INT], sort=False, textinfo="percent",
                                  textfont_size=15,
                                  hovertemplate="%{label}: %{value:,.0f} €<extra></extra>"))
            f2.add_annotation(text=f"<b>{eur(capital + total_int)}</b><br>en total", showarrow=False,
                              font_size=15)
            st.plotly_chart(estilo(f2, 340), width="stretch")

        st.markdown("**Cada año: ¿cuánto pago de capital y cuánto de intereses?**")
        explica("Cada barra es un año. La parte azul reduce tu deuda; la naranja es lo que cobra el banco. "
                "Con los años, el naranja se encoge.")
        anual = con_extra.groupby("anio").agg(intereses=("intereses", "sum"), capital=("amortizacion", "sum"),
                                              extra=("extra", "sum")).reset_index()
        f3 = go.Figure()
        f3.add_bar(x=anual.anio, y=anual.capital, name="Capital (reduce la deuda)", marker_color=C_CAP)
        if hay_extra:
            f3.add_bar(x=anual.anio, y=anual.extra, name="Amortización extra", marker_color=C_EXTRA)
        f3.add_bar(x=anual.anio, y=anual.intereses, name="Intereses (coste del banco)", marker_color=C_INT)
        f3.update_layout(barmode="stack", xaxis_title="Año", yaxis_title="€ pagados en el año")
        st.plotly_chart(estilo(f3, 380), width="stretch")

        if tipo != "Fijo" or (hay_extra and modo == "cuota"):
            st.markdown("**¿Cómo cambia la cuota mensual?**")
            explica("La cuota se recalcula cuando se revisa el tipo de interés o cuando amortizas para reducir cuota.")
            f4 = go.Figure(go.Scatter(x=con_extra.mes / 12, y=con_extra.cuota, mode="lines", line_shape="hv",
                                      line=dict(color=C_INT, width=3), name="Cuota",
                                      hovertemplate="Año %{x:.1f}: %{y:,.2f} €/mes<extra></extra>"))
            f4.update_layout(xaxis_title="Años desde la firma", yaxis_title="€ por mes")
            st.plotly_chart(estilo(f4, 300, "no"), width="stretch")

    with t_compra:
        st.markdown("**Cuánto dinero necesitas el día de la compra**")
        des = pd.DataFrame({"Concepto": ["Entrada"] + list(gastos) + ["Total a aportar"],
                            "Importe": [entrada] + list(gastos.values()) + [entrada + gastos_total]})
        st.dataframe(des, hide_index=True, width="stretch",
                     column_config={"Importe": st.column_config.NumberColumn("Importe", format="%.0f €")})
        st.caption(f"Total que pagarás al banco: {eur(total_pagado)} · coste total de la vivienda "
                   f"(entrada + gastos + banco): {eur(entrada + gastos_total + total_pagado)}")

    with t_mas:
        # ---------------------------------------------------------- asequibilidad
        st.markdown("**¿Puedo permitírmela?**")
        explica("Regla habitual: la cuota no debería pasar del 30-35 % de tus ingresos netos mensuales del hogar.")
        q1, q2 = st.columns([1, 2])
        ingresos = q1.number_input("Ingresos netos al mes (€)", 500, 50_000, 3_000, 100, key="h_ingr",
                                   help="Suma de lo que cobráis al mes después de impuestos.")
        ratio = c0 / ingresos
        estado = "🟢 Cómoda" if ratio <= 0.30 else ("🟠 Ajustada" if ratio <= 0.35 else "🔴 Demasiado alta")
        with q2:
            mm = st.columns(3)
            mm[0].metric("Cuota / ingresos", pct(ratio, 0), delta=estado, delta_color="off")
            cuota_max = ingresos * 0.35
            cap_max = cuota_max / fin.cuota(1.0, tin0, n)
            mm[1].metric("Cuota máxima (35 %)", eur(cuota_max, 0))
            mm[2].metric("Precio máximo aprox.", eur(cap_max / (1 - entrada_pct / 100), 0),
                         help="Precio de vivienda con el que la cuota inicial llegaría al 35 % de tus ingresos, con "
                              "esta entrada, plazo y tipo (sin contar gastos de compra).")

        # ---------------------------------------------------------- estrés del Euribor
        st.markdown("**¿Y si suben los tipos?**")
        if tipo == "Fijo":
            st.info("Con una hipoteca fija el tipo no cambia, así que esta prueba solo tiene sentido en variable o "
                    "mixta. Cambia el tipo arriba para verla.")
        else:
            explica("Cuota y coste total si el Euribor fuese distinto desde el principio (el resto de datos iguales).")
            filas_e = []
            for d_pp in (-1.0, 0.0, 1.0, 2.0, 3.0):
                a_e = dict(args, euribor=euribor + d_pp / 100)
                cu = fin.cuadro(capital, anios, **a_e)
                mes_c = anios_fijos * 12 if tipo == "Mixto" else 12
                filas_e.append({"Euribor": euribor + d_pp / 100, "Cambio": f"{d_pp:+.0f} pp" if d_pp else "Actual",
                                "Cuota inicial": float(cu.cuota.iloc[0]),
                                "Cuota tras la primera revisión": float(cu.cuota.iloc[min(mes_c, len(cu) - 1)]),
                                "Intereses totales": float(cu.intereses.sum())})
            st.dataframe(pd.DataFrame(filas_e), hide_index=True, width="stretch", column_config={
                "Euribor": st.column_config.NumberColumn(format="percent"),
                **{c: st.column_config.NumberColumn(format="%.0f €") for c in
                   ["Cuota inicial", "Cuota tras la primera revisión", "Intereses totales"]}})

        # ---------------------------------------------------------- comparar plazos
        st.markdown("**¿Y si cambio el plazo?**")
        explica("Más años = cuota más baja pero muchos más intereses. Con la misma entrada y tipo.")
        plazos_c = sorted(set([15, 20, 25, 30, 35, int(anios)]))
        filas_p = []
        for a_ in plazos_c:
            cu = fin.cuadro(capital, a_, **args)
            filas_p.append({"Plazo": f"{a_} años", "Cuota inicial": float(cu.cuota.iloc[0]),
                            "Intereses totales": float(cu.intereses.sum()),
                            "Total a devolver": float(cu.cuota.sum())})
        dfp = pd.DataFrame(filas_p)
        fpz = go.Figure()
        fpz.add_bar(x=dfp["Plazo"], y=dfp["Intereses totales"], name="Intereses totales", marker_color=C_INT)
        fpz.add_scatter(x=dfp["Plazo"], y=dfp["Cuota inicial"], name="Cuota mensual", mode="lines+markers",
                        yaxis="y2", line=dict(color=C_CAP, width=3))
        fpz.update_layout(yaxis=dict(title="Intereses totales (€)"),
                          yaxis2=dict(title="Cuota (€/mes)", overlaying="y", side="right"))
        z1, z2 = st.columns([3, 2], gap="large")
        z1.plotly_chart(estilo(fpz, 340), width="stretch")
        z2.dataframe(dfp, hide_index=True, width="stretch", column_config={
            c: st.column_config.NumberColumn(format="%.0f €") for c in
            ["Cuota inicial", "Intereses totales", "Total a devolver"]})

    with t_cuadro:
        explica("Mes a mes: cuánto pagas, cuánto son intereses, cuánto reduce la deuda y cuánto te queda por pagar.")
        t = con_extra.rename(columns={"mes": "Mes", "tin": "TIN", "cuota": "Cuota", "intereses": "Intereses",
                                      "amortizacion": "Amortización", "extra": "Extra", "saldo": "Saldo",
                                      "anio": "Año"})
        st.dataframe(t, hide_index=True, width="stretch", column_config={
            "TIN": st.column_config.NumberColumn(format="%.3f"),
            **{k: st.column_config.NumberColumn(format="%.2f €") for k in
               ["Cuota", "Intereses", "Amortización", "Extra", "Saldo"]}})
        st.download_button("Descargar CSV", t.to_csv(index=False, sep=";", decimal=",").encode("utf-8-sig"),
                           "cuadro_amortizacion.csv", "text/csv")
:::END
:::BEGIN py/paginas/mercado.py|text
"""Página Mercado."""
from ui import *  # noqa: F401,F403  (st, np, pd, go, fin y utilidades comunes)


def pag_mercado():
    titulo_pagina("🌍", "Mercado", "Cómo se ha comportado la bolsa en el pasado: la base de todas las simulaciones")
    st.info("Aquí ves los datos reales que usan Cartera, Comparador y Plazos y riesgo. El pasado no garantiza el "
            "futuro, pero sirve para saber cuánto puede subir y bajar la bolsa.", icon="ℹ️")
    with st.container(border=True):
        indice = st.selectbox("Índice de bolsa", list(fin.INDICES), key="mk_idx",
                              help="En dólares y con dividendos, sin convertir a euros. El «Mundo largo» empalma "
                                   "MSCI World (1973-2008) con el ETF Vanguard Total World (desde 2009).")
    ret, nivel, err = datos_indice(indice)
    if err or ret is None:
        st.error(f"No se han podido descargar los datos del índice: {err}")
        return
    st.caption(f"Datos {ret.index.min()}–{ret.index.max()} (índice en dólares, con dividendos, {etiqueta_modo()}).")
    t_hist, t_caida, t_dec, t_cmp, t_tipos = st.tabs(["📈 Histórico", "📉 Caídas", "🗓️ Décadas y plazos",
                                                      "🆚 Comparar índices", "🏦 Tipos de interés"])
    with t_hist:
        cagr = (nivel.iloc[-1] / nivel.iloc[0]) ** (1 / ((nivel.index[-1] - nivel.index[0]).days / 365.25)) - 1
        caida = (nivel / nivel.cummax() - 1)
        k = st.columns(4)
        k[0].metric("Rentabilidad media anual", pct(cagr, 1), help="Rentabilidad anual compuesta de todo el histórico")
        k[1].metric("Variación típica de un año", pct(float(ret.std(ddof=1)), 1),
                    help="Volatilidad: cuánto se aleja un año de la media. Cuanto más alta, más sube y baja.")
        k[2].metric("Peor año", pct(float(ret.min()), 1), delta=f"en {int(ret.idxmin())}", delta_color="off")
        k[3].metric("Mayor caída desde máximos", pct(float(caida.min()), 1),
                    delta=f"en {caida.idxmin():%m/%Y}", delta_color="off")
        h1, h2 = st.columns([3, 2], gap="large")
        with h1:
            st.markdown("**¿Cómo ha evolucionado el índice?**")
            explica("Lo que valdrían 100 € invertidos al principio. Escala logarítmica: una misma subida en "
                    "porcentaje se ve igual de alta al principio que al final.")
            g = go.Figure(go.Scatter(x=nivel.index, y=nivel.values, mode="lines", line=dict(color=C_CAP, width=2.5),
                                     fill="tozeroy", fillcolor="rgba(76,154,255,.12)", name="Valor de 100 €",
                                     hovertemplate="%{x|%m/%Y}: %{y:,.0f} €<extra></extra>"))
            g.update_layout(yaxis_type="log", yaxis_title="Valor de 100 € invertidos", xaxis_title="")
            st.plotly_chart(estilo(g, 360, "no"), width="stretch")
        with h2:
            st.markdown("**¿Cuánto subió o bajó cada año?**")
            explica("Azul: año de subida. Naranja: año de bajada.")
            b = go.Figure(go.Bar(x=ret.index, y=ret.values * 100,
                                 marker_color=np.where(ret.values >= 0, C_CAP, C_INT)))
            b.update_layout(xaxis_title="", yaxis_title="Rentabilidad del año (%)")
            st.plotly_chart(estilo(b, 360, "no"), width="stretch")

    # ------------------------------------------------------------ caídas
    with t_caida:
        explica("Cuánto ha estado el índice por debajo de su máximo anterior. Cada hueco es una crisis; lo que importa "
                "es cuánto cayó y cuánto tardó en recuperarse.")
        dd = (nivel / nivel.cummax() - 1) * 100
        fd = go.Figure(go.Scatter(x=dd.index, y=dd.values, mode="lines", fill="tozeroy", line=dict(color=C_INT, width=2),
                                  fillcolor="rgba(245,165,36,.25)",
                                  hovertemplate="%{x|%m/%Y}: %{y:.1f} % desde máximos<extra></extra>"))
        fd.update_layout(yaxis_title="Caída desde el máximo (%)", xaxis_title="")
        st.plotly_chart(estilo(fd, 360, "no"), width="stretch")
        # episodios: tramos consecutivos por debajo del máximo
        en_caida = dd < -0.0001
        grupo = (en_caida != en_caida.shift()).cumsum()
        filas_d = []
        for _, tr in dd[en_caida].groupby(grupo[en_caida]):
            ini = tr.index[0]
            fondo_f = tr.idxmin()
            fin_f = nivel.index[nivel.index.get_loc(tr.index[-1]) + 1] if tr.index[-1] != nivel.index[-1] else None
            filas_d.append({"Empieza": ini.strftime("%m/%Y"), "Mínimo": fondo_f.strftime("%m/%Y"),
                            "Caída máxima": float(tr.min()) / 100,
                            "Meses hasta el mínimo": int(round((fondo_f - ini).days / 30.4)),
                            "Recuperado": fin_f.strftime("%m/%Y") if fin_f is not None else "Aún no",
                            "Meses en total": int(round(((fin_f or nivel.index[-1]) - ini).days / 30.4))})
        if filas_d:
            st.markdown("**Las peores caídas**")
            peores = pd.DataFrame(filas_d).sort_values("Caída máxima").head(8)
            st.dataframe(peores, hide_index=True, width="stretch", column_config={
                "Caída máxima": st.column_config.NumberColumn(format="percent")})

    # ------------------------------------------------------------ décadas y ventanas de 10 años
    with t_dec:
        st.markdown("**Rentabilidad media anual por década**")
        explica("Rentabilidad anual compuesta de cada década. Verás que hay décadas «perdidas» y otras muy buenas.")
        dfy = pd.DataFrame({"r": ret.values}, index=ret.index.astype(int))
        dfy["dec"] = (dfy.index // 10) * 10
        dec = dfy.groupby("dec")["r"].agg(lambda x: (1 + x).prod() ** (1 / len(x)) - 1)
        dec_n = dfy.groupby("dec")["r"].size()
        fdc = go.Figure(go.Bar(x=[f"{d}s" + ("*" if dec_n[d] < 10 else "") for d in dec.index], y=dec.values * 100,
                               marker_color=np.where(dec.values >= 0, C_CAP, C_INT),
                               hovertemplate="%{x}: %{y:.1f} % anual<extra></extra>"))
        fdc.update_layout(yaxis_title="Rentabilidad anual (%)", xaxis_title="")
        st.plotly_chart(estilo(fdc, 320, "no"), width="stretch")
        st.caption("* Década incompleta.")
        st.markdown("**Rentabilidad anualizada según el plazo en que mantienes**")
        explica("Cada línea es una ventana móvil de N años: su rentabilidad anualizada según cuándo empiezas. Con más "
                "años la línea se aplana y se vuelve más estable.")
        ventanas_a = st.multiselect("Plazos (años)", [3, 5, 10, 15, 20, 30], default=[5, 10, 20], key="mk_vent")
        fv = go.Figure()
        for h_ in ventanas_a:
            m_ = h_ * 12
            if len(nivel) <= m_:
                continue
            tir_v = (nivel.shift(-m_) / nivel) ** (1 / h_) - 1
            tir_v = tir_v.dropna()
            fv.add_scatter(x=tir_v.index, y=tir_v.values * 100, mode="lines", name=f"{h_} años")
        fv.add_hline(y=0, line_dash="dash", line_color="#8B93A7")
        fv.update_layout(yaxis_title="Rentabilidad anualizada (%)", xaxis_title="Fecha de inicio de la ventana")
        st.plotly_chart(estilo(fv, 380), width="stretch")

    # ------------------------------------------------------------ comparar índices
    with t_cmp:
        explica("Valor de 100 € invertidos a la vez en varios índices (en dólares, con dividendos) desde el primer mes "
                "en que todos tienen datos. Escala logarítmica.")
        elegidos = st.multiselect("Índices", list(fin.INDICES), default=[indice, list(fin.INDICES)[1]]
                                  if len(fin.INDICES) > 1 else [indice], key="mk_cmp")
        series = {}
        for nm in elegidos:
            try:
                series[nm.split(":")[0]] = fin.indice_mensual(nm)
            except Exception as e:
                st.warning(f"{nm}: {str(e)[:120]}")
        if series:
            comun = pd.concat(series, axis=1).dropna()
            if comun.empty:
                st.info("Los índices elegidos no comparten fechas.")
            else:
                comun = comun / comun.iloc[0] * 100
                fc2 = go.Figure()
                for c_ in comun.columns:
                    fc2.add_scatter(x=comun.index, y=comun[c_], mode="lines", name=c_)
                fc2.update_layout(yaxis_type="log", yaxis_title="Valor de 100 €", xaxis_title="")
                st.plotly_chart(estilo(fc2, 400), width="stretch")
                anos_c = (comun.index[-1] - comun.index[0]).days / 365.25
                resumen_c = pd.DataFrame({
                    "Índice": comun.columns,
                    "Rentab. anual": [(comun[c_].iloc[-1] / 100) ** (1 / anos_c) - 1 for c_ in comun.columns],
                    "Mayor caída": [float((comun[c_] / comun[c_].cummax() - 1).min()) for c_ in comun.columns],
                    "Desde": comun.index[0].strftime("%m/%Y")})
                st.dataframe(resumen_c, hide_index=True, width="stretch", column_config={
                    "Rentab. anual": st.column_config.NumberColumn(format="percent"),
                    "Mayor caída": st.column_config.NumberColumn(format="percent")})

    # ------------------------------------------------------------ tipos de interés
    with t_tipos:
        explica("La parte de renta fija de las simulaciones usa estos tipos del BCE. Aquí ves cuánto rinden hoy y cómo "
                "han cambiado.")
        tp, e_tp = tipos_actuales()
        kt = st.columns(2)
        kt[0].metric("Euribor 12 meses", pct(tp["euribor12m"], 2) if tp.get("euribor12m") is not None else "—")
        kt[1].metric("Bono euro a 10 años", pct(tp["bono10"], 2) if tp.get("bono10") is not None else "—")
        cv, e_cv = datos_curva()
        if cv is None:
            st.info(f"No se ha podido descargar la curva histórica del BCE: {e_cv}")
        else:
            fy = go.Figure()
            for venc in (1, 5, 10, 20):
                if venc in cv.columns:
                    fy.add_scatter(x=cv.index, y=cv[venc] * 100, mode="lines", name=f"{venc} año{'s' if venc > 1 else ''}")
            fy.update_layout(yaxis_title="Rendimiento (%)", xaxis_title="")
            st.markdown("**Rendimiento de la deuda por vencimiento**")
            st.plotly_chart(estilo(fy, 340), width="stretch")
            ult = cv.dropna(how="all").iloc[-1]
            hace1 = cv.dropna(how="all").iloc[max(len(cv) - 13, 0)]
            fcv = go.Figure()
            fcv.add_scatter(x=ult.index, y=ult.values * 100, mode="lines+markers", name=f"{cv.index[-1]:%m/%Y}",
                            line=dict(color=C_INT, width=3))
            fcv.add_scatter(x=hace1.index, y=hace1.values * 100, mode="lines", name="Hace un año",
                            line=dict(color="#8B93A7", dash="dash"))
            fcv.update_layout(xaxis_title="Vencimiento (años)", yaxis_title="Rendimiento (%)")
            st.markdown("**Curva de tipos: hoy frente a hace un año**")
            st.plotly_chart(estilo(fcv, 340), width="stretch")
:::END
:::BEGIN py/paginas/plazos.py|text
"""Página Plazos y probabilidad de perder."""
from ui import *  # noqa: F401,F403  (st, np, pd, go, fin y utilidades comunes)


def _color_mezcla(w):
    """Del azul (0 % bolsa) al naranja (100 % bolsa)."""
    c0, c1 = (76, 154, 255), (245, 165, 36)
    return "rgb({},{},{})".format(*[int(c0[k] + (c1[k] - c0[k]) * w) for k in range(3)])


def pag_plazos():
    titulo_pagina("⏳", "Plazos y riesgo", "¿Cuántos años hacen falta para que sea raro perder dinero?")
    with st.expander("ℹ️ Qué significa esta página"):
        st.markdown("Se miran **todas las ventanas posibles del pasado** (aunque se solapen) de cada duración y "
                    "se cuenta en cuántas acabarías con menos dinero del que pusiste. Cuanto más largo el plazo, "
                    "menos ventanas pierden. La curva se suaviza con una media móvil de 52 semanas y la rentabilidad "
                    "se expresa como TIR anualizada.")
    tipos, _ = tipos_actuales()
    rf_def = tipos.get("euribor12m") if tipos.get("euribor12m") is not None else 0.025
    st.session_state.setdefault("p_rv", 60)
    with st.container(border=True):
        p2, p4 = st.columns([2, 3])
        w_pct = p2.slider("Tu reparto: % en bolsa (el resto, renta fija)", 0, 100, key="p_rv", step=5)
        estrategia_ph = p4
        with st.expander("Opciones avanzadas: índice y renta fija"):
            p1, p3 = st.columns(2)
            indice = p1.selectbox("Índice de bolsa", list(fin.INDICES), key="p_idx",
                                  help="En dólares y con dividendos. Cuanto más largo es el histórico, más fiable.")
            r_rf = rf_efectivo(p3.number_input("Rentabilidad de la renta fija (% al año, nominal)", -1.0, 15.0,
                                               round(rf_def * 100, 2), 0.1, key="p_rf") / 100)
        estrategia = estrategia_ph.radio("Estrategia", ["Buy and hold (todo el primer día)",
                                             "DCA (aportaciones iguales cada semana)"], horizontal=True,
                              key="p_estr",
                              help="Buy and hold: inviertes todo el dinero el primer día y esperas. DCA: repartes el "
                                   "mismo dinero en aportaciones iguales cada semana durante todo el plazo.")
    ret, nivel, err = datos_indice(indice)
    if err or nivel is None:
        st.error(f"No se han podido descargar los datos del índice: {err}")
        return
    w = w_pct / 100
    dca = estrategia.startswith("DCA")
    pesos = tuple(sorted(set([i / 10 for i in range(11)] + [w])))
    raw, suav, err2 = curvas_plazos(indice, round(r_rf, 6), pesos, "dca" if dca else "hold")
    if suav is None or suav.empty:
        st.error(f"No se han podido calcular las curvas semanales: {err2 or 'histórico demasiado corto'}")
        return
    nom = "DCA" if dca else "Buy and hold"

    def prob(anios, col=w):
        h = int(round(anios * 52))
        return float(suav.loc[h, col]) if h in suav.index else None
    frases = []
    for h in (1, 5, 10, 20):
        p = prob(h)
        if p is not None:
            frases.append(f"en <b>{h} año{'s' if h > 1 else ''}</b>, el <b>{pct(p, 0)}</b>")
    st.markdown(f'<div class="resumen">{nom} con {w_pct} % en bolsa. Veces que habrías perdido dinero: '
                + "; ".join(frases) + ". Cuanto más tiempo mantienes la inversión, más raro es acabar por debajo de "
                "lo que pusiste.</div>", unsafe_allow_html=True)
    n_sem = len(serie_semanal(indice))
    indep = ", ".join(f"{h} años → {fin.ventanas_independientes(n_sem, h * 52)}" for h in (5, 10, 20)
                      if fin.ventanas_independientes(n_sem, h * 52) > 0)
    st.caption(f"⚠️ Las ventanas se solapan: con {n_sem / 52:.0f} años de historia solo hay estas ventanas que no "
               f"comparten datos: {indep}. Las probabilidades a plazos largos se apoyan en muy pocos casos "
               "independientes; tómalas como orientación, no como certeza.")

    t_prob, t_tabla, t_rent, t_mas = st.tabs(["📉 Probabilidad de perder", "🔢 Tabla de equivalencias",
                                              "📊 TIR según el plazo (buy and hold)", "🔬 Más análisis"])

    with t_prob:
        st.markdown(f"**¿Cuántas veces habrías perdido dinero según el plazo? ({nom})**")
        explica("Una curva por cada reparto entre bolsa y renta fija, del azul (0 % bolsa) al naranja (100 % bolsa). "
                "Se calcula para cada plazo semana a semana (de 1 semana a 30 años) con ventanas que empiezan cada "
                "semana y se solapan, y se suaviza con la media móvil de 52 plazos. Solo se dibujan los puntos con 52 "
                "semanas completas, por eso las curvas empiezan en unos 6 meses.")
        g = go.Figure()
        for c in suav.columns:
            es_tuyo = abs(c - w) < 1e-9
            g.add_scatter(x=suav.index / 52, y=suav[c] * 100, mode="lines",
                          name=f"Tu reparto ({int(round(c * 100))} % bolsa)" if es_tuyo else f"{int(round(c * 100))} % bolsa",
                          line=dict(color=_color_mezcla(c), width=4.5 if es_tuyo else 1.8),
                          hovertemplate=f"{int(round(c * 100))} % bolsa · %{{x:.1f}} años: %{{y:.1f}} %<extra></extra>")
        if st.checkbox("Mostrar también tu reparto sin suavizar", key="p_raw"):
            g.add_scatter(x=raw.index / 52, y=raw[w] * 100, mode="lines", name="Tu reparto sin suavizar",
                          line=dict(color="rgba(255,255,255,.45)", width=1, dash="dot"))
        g.update_layout(xaxis_title="Años que mantienes la inversión", yaxis_title="Veces que habrías perdido dinero (%)",
                        yaxis_range=[0, max(5.0, float(suav.max().max()) * 100 * 1.05)])
        st.plotly_chart(estilo(g, 480), width="stretch")

        st.markdown("**¿Cuántos años necesito?**")
        riesgo = st.select_slider("Quiero que la probabilidad de perder sea como mucho…",
                                  options=[0, 1, 2, 5, 10, 20], value=5, key="p_max", format_func=lambda x: f"{x} %")

        def anios_txt(col):
            sem = fin.semanas_para_riesgo(suav[col], riesgo / 100)
            return num(sem / 52, 1) + " años" if sem else "No se alcanza en el histórico"
        k1, k2 = st.columns(2)
        k1.metric(f"Tu reparto ({w_pct} % bolsa)", anios_txt(w))
        k2.metric("100 % bolsa", anios_txt(1.0))
        st.caption("Con plazos largos casi todas las ventanas comparten años, así que hay pocas realmente distintas. "
                   "Tómalo como una pauta, no como una garantía.")

    with t_tabla:
        explica(f"Años ↔ probabilidad de perder dinero ({nom}), para cada reparto. Cada columna es un porcentaje en bolsa.")
        filas = {}
        for y in range(1, 31):
            h = y * 52
            if h in suav.index:
                filas[y] = {f"{int(round(c * 100))} % bolsa": float(suav.loc[h, c]) for c in suav.columns}
        if filas:
            tabla = pd.DataFrame(filas).T
            tabla.index.name = "Años"
            tabla = tabla.reset_index()
            st.dataframe(tabla, hide_index=True, width="stretch", height=480, column_config={
                c: st.column_config.NumberColumn(format="percent") for c in tabla.columns if c != "Años"})

    with t_rent:
        explica("TIR anualizada de cada ventana (la rentabilidad anual constante que convierte lo invertido en lo "
                "obtenido), con buy and hold, ventanas que empiezan cada año y tu reparto.")
        base_n = np.concatenate([[1.0], np.cumprod(1 + ret.values)])
        df = fin.ventanas_moviles(base_n, list(range(1, 31)), w, r_rf, 1)
        if df.empty:
            st.info("El histórico de este índice es demasiado corto.")
        else:
            x = df.anios
            b = go.Figure()
            b.add_scatter(x=x, y=df.mejor * 100, mode="lines", line=dict(width=0), showlegend=False, hoverinfo="skip")
            b.add_scatter(x=x, y=df.peor * 100, mode="lines", fill="tonexty", fillcolor="rgba(76,154,255,.12)",
                          line=dict(width=0), name="Entre la peor y la mejor ventana")
            b.add_scatter(x=x, y=df.p95 * 100, mode="lines", line=dict(width=0), showlegend=False, hoverinfo="skip")
            b.add_scatter(x=x, y=df.p5 * 100, mode="lines", fill="tonexty", fillcolor="rgba(76,154,255,.28)",
                          line=dict(width=0), name="9 de cada 10 ventanas")
            b.add_scatter(x=x, y=df.mediana * 100, mode="lines", line=dict(color=C_MEDIA, width=3),
                          name="Ventana típica")
            b.add_hline(y=0, line_dash="dash", line_color="#8B93A7")
            b.update_layout(xaxis_title="Años que mantienes la inversión", yaxis_title="TIR anualizada (%)")
            st.plotly_chart(estilo(b, 420), width="stretch")
            ind = df.set_index("anios")["independientes"]
            st.caption("Ventanas sin datos en común detrás de cada plazo: "
                       + ", ".join(f"{h} años → {int(ind[h])}" for h in (5, 10, 20, 30) if h in ind.index)
                       + ". Con tan pocas, los extremos (mejor y peor) dependen de uno o dos episodios concretos.")
    with t_mas:
        v_sem = serie_semanal(indice)
        # ------------------------------------------------ pérdida máxima
        st.markdown("**¿Cuánto podría llegar a perder?**")
        explica(f"Valor de 100 € invertidos con tu reparto ({w_pct} % bolsa) según los años, en distintos escenarios "
                "históricos (1 de cada 100, 1 de cada 20, la mitad, 1 de cada 20 mejores). Buy and hold.")
        ys_m = np.arange(1, 20.01, 0.5)
        fm = go.Figure()
        estilos_m = [(1, "Muy mal (1 de cada 100)", "#D55E00"), (5, "Mal (1 de cada 20)", "#F5A524"),
                     (50, "Típico", "#4C9AFF"), (95, "Muy bien (1 de cada 20)", "#009E73")]
        tablas_m = {}
        for q_, nom_q, col_q in estilos_m:
            tq = fin.mal_escenario(v_sem, [w], r_rf, ys_m, q_)
            if tq.empty:
                continue
            vals = 100 * (1 + tq[w].values) ** tq.index.values
            tablas_m[nom_q] = pd.Series(vals, index=tq.index)
            fm.add_scatter(x=tq.index, y=vals, mode="lines", name=nom_q, line=dict(color=col_q, width=2.5))
        fm.add_hline(y=100, line_dash="dash", line_color="#8B93A7", annotation_text="Lo invertido")
        fm.update_layout(xaxis_title="Años que mantienes la inversión", yaxis_title="Valor de 100 € invertidos")
        st.plotly_chart(estilo(fm, 400), width="stretch")

        # ------------------------------------------------ prob. de caída grande
        st.markdown("**¿Y perder más de un porcentaje concreto?**")
        explica("Probabilidad de acabar con menos de lo invertido menos X %, según los años. Un 10 % significa que "
                "100 € se quedan en menos de 90 €.")
        ys_c = np.arange(1, 10.01, 0.5)
        fc = go.Figure()
        for u_, col_c in ((0.0, "#4C9AFF"), (0.1, "#F5A524"), (0.2, "#D55E00"), (0.3, "#A78BFA")):
            fc.add_scatter(x=ys_c, y=fin.prob_caida_mayor(v_sem, w, r_rf, ys_c, u_) * 100, mode="lines",
                           name="Perder dinero" if u_ == 0 else f"Perder más del {int(u_ * 100)} %",
                           line=dict(color=col_c, width=2.5))
        fc.update_layout(xaxis_title="Años que mantienes la inversión", yaxis_title="Probabilidad (%)")
        st.plotly_chart(estilo(fc, 360), width="stretch")

        # ------------------------------------------------ comparar índices
        st.markdown("**¿Cambia según el índice?**")
        explica("La probabilidad de perder (buy and hold) con tu mismo reparto para otros índices. Con menos "
                "histórico los resultados son menos fiables.")
        elegidos = st.multiselect("Índices a comparar", list(fin.INDICES), default=[indice], key="p_cmp")
        fi = go.Figure()
        for nombre_i in elegidos:
            _, sv_i, e_i = curvas_plazos(nombre_i, round(r_rf, 6), (w,), "hold")
            if sv_i is None or sv_i.empty:
                st.warning(f"{nombre_i}: {e_i or 'sin datos'}")
                continue
            fi.add_scatter(x=sv_i.index / 52, y=sv_i[w] * 100, mode="lines", name=nombre_i.split(":")[0])
        fi.update_layout(xaxis_title="Años que mantienes la inversión", yaxis_title="Veces que habrías perdido (%)")
        st.plotly_chart(estilo(fi, 380), width="stretch")

        if tablas_m:
            exp = pd.DataFrame(tablas_m)
            exp.index.name = "Años"
            st.download_button("⬇️ Descargar valores por plazo (CSV)",
                               exp.reset_index().to_csv(index=False, sep=";", decimal=",").encode("utf-8-sig"),
                               "plazos_escenarios.csv", "text/csv", key="p_dl")

    st.caption(f"Datos: {nivel.index[0]:%m/%Y}–{nivel.index[-1]:%m/%Y} ({len(ret)} años completos, en dólares, con "
               "dividendos). Pérdida = acabar con menos dinero que el total invertido"
               + (" en dinero de hoy (perder poder adquisitivo). " if modo_real() else ", sin contar la inflación. ")
               + "Resultados orientativos; no son asesoramiento financiero.")
:::END
:::BEGIN py/paginas/test_riesgo.py|text
"""Página Test de riesgo."""
from ui import *  # noqa: F401,F403  (st, np, pd, go, fin y utilidades comunes)


def pag_test():
    titulo_pagina("🧭", "Test de riesgo", "Tolerancia al riesgo financiero (cuestionario de Grable y Lytton, 13 preguntas)")
    perfiles = fin.leer_perfiles()
    usuarios = list(perfiles["usuarios"])
    mn, mx = fin.puntuacion_min_max()
    st.markdown('<div class="resumen">Son <b>13 preguntas</b> y tardas unos 3 minutos. No hay respuestas buenas ni '
                'malas: sirve para saber cuánto riesgo aceptas con tu dinero. Al final se guarda tu perfil y la '
                'pestaña Cartera te sugiere un reparto.</div>', unsafe_allow_html=True)

    with st.form("form_test"):
        nombre = st.text_input("Usuario", value=perfiles.get("activo") or "", key="t_nombre",
                               help="Si ya existe, se actualiza su perfil. Si es nuevo, se crea.")
        resp = []
        for i, (preg, opts) in enumerate(fin.TEST, 1):
            sel = st.radio(f"{i}. {preg}", [t for t, _ in opts], index=None, key=f"t_{i}")
            resp.append(dict(opts).get(sel) if sel else None)
        enviado = st.form_submit_button("Calcular y guardar perfil", type="primary")

    if enviado:
        if not nombre.strip():
            st.error("Escribe un nombre de usuario.")
        elif any(r is None for r in resp):
            faltan = [str(i + 1) for i, r in enumerate(resp) if r is None]
            st.error(f"Faltan por responder: {', '.join(faltan)}")
        else:
            res = fin.evaluar_test(resp)
            fin.guardar_perfil(nombre.strip(), res, resp)
            st.success(f"Perfil de {nombre.strip()} guardado: {res['nivel']} ({res['puntuacion']} puntos).")
            perfiles = fin.leer_perfiles()
            usuarios = list(perfiles["usuarios"])

    st.subheader("Perfiles guardados")
    if not usuarios:
        st.info("Aún no hay ningún perfil guardado.")
        return
    filas = []
    for u, p in perfiles["usuarios"].items():
        filas.append({"Usuario": u + (" ★" if u == perfiles.get("activo") else ""), "Fecha": p["fecha"],
                      "Puntos": p["puntuacion"], "Nivel": p["nivel"], "% renta variable sugerido": p["rv_sugerida"]})
    st.dataframe(pd.DataFrame(filas), hide_index=True, width="stretch")

    sel = st.selectbox("Ver / usar usuario", usuarios, index=usuarios.index(perfiles.get("activo"))
                       if perfiles.get("activo") in usuarios else 0, key="t_ver")
    p = perfiles["usuarios"][sel]
    pos = (p["puntuacion"] - mn) / (mx - mn) * 100
    st.markdown(f'<div class="medidor"><i style="left:calc({pos:.1f}% - 2px)"></i></div>'
                '<div style="display:flex;justify-content:space-between;font-size:.85rem;opacity:.75;margin-top:-18px">'
                '<span>Prudente</span><span>Equilibrado</span><span>Arriesgado</span></div>', unsafe_allow_html=True)
    t_res, t_des, t_evo, t_vivir = st.tabs(["📊 Tu resultado", "🧠 Desglose por pregunta", "📈 Evolución",
                                            "🎢 Cómo lo habrías vivido"])
    with t_res:
        k = st.columns(3)
        k[0].metric("Puntuación", f"{p['puntuacion']} / {mx}")
        k[1].metric("Nivel", p["nivel"])
        k[2].metric("% renta variable sugerido", f"{p['rv_sugerida']} %")
        st.write(p["descripcion"])
        b1, b2, _ = st.columns([1, 1, 3])
        if b1.button("Usar este perfil", key="t_usar"):
            fin.usuario_activo(sel)
            st.rerun()
        if b2.button("Borrar perfil", key="t_borrar"):
            fin.borrar_perfil(sel)
            st.rerun()
        st.markdown("**Todos los perfiles**")
        explica("Nota de cada usuario sobre la escala del test. Las franjas son los niveles oficiales de Grable y Lytton.")
        nombres_u = list(perfiles["usuarios"])
        fu = go.Figure()
        for lo, hi, col_n, nm_n in ((mn, 18.5, "rgba(76,154,255,.12)", "Bajo"), (18.5, 22.5, "rgba(46,196,166,.12)", "Medio-bajo"),
                                    (22.5, 28.5, "rgba(128,128,128,.12)", "Medio"), (28.5, 32.5, "rgba(245,165,36,.12)", "Medio-alto"),
                                    (32.5, mx, "rgba(213,94,0,.12)", "Alto")):
            fu.add_hrect(y0=lo, y1=hi, fillcolor=col_n, line_width=0, annotation_text=nm_n, annotation_position="top left")
        fu.add_bar(x=nombres_u, y=[perfiles["usuarios"][u]["puntuacion"] for u in nombres_u], marker_color=C_CAP,
                   hovertemplate="%{x}: %{y} puntos<extra></extra>")
        fu.update_layout(yaxis_range=[mn, mx], yaxis_title="Puntuación")
        st.plotly_chart(estilo(fu, 340, "no"), width="stretch")

    with t_des:
        explica("Cuántos puntos has puesto en cada pregunta (de 1 a 4 o de 1 a 5). Barras largas = respuestas más "
                "arriesgadas; cortas = más prudentes. Sirve para ver en qué situaciones eres más audaz.")
        resp_g = p.get("respuestas")
        if not resp_g or len(resp_g) != len(fin.TEST):
            st.info("Este perfil no guarda las respuestas por pregunta. Repite el test para verlas.")
        else:
            maxs = [max(pp for _, pp in o) for _, o in fin.TEST]
            etiquetas_q = [f"{i}. " + (q_[:48] + "…" if len(q_) > 48 else q_) for i, (q_, _) in enumerate(fin.TEST, 1)]
            fq = go.Figure()
            fq.add_bar(y=etiquetas_q, x=maxs, orientation="h", marker_color="rgba(128,128,128,.25)", name="Máximo posible")
            fq.add_bar(y=etiquetas_q, x=resp_g, orientation="h", marker_color=C_INT, name="Tu respuesta")
            fq.update_layout(barmode="overlay", yaxis_autorange="reversed", xaxis_title="Puntos")
            st.plotly_chart(estilo(fq, 520), width="stretch")
            rel = [(r_ / m_, i) for i, (r_, m_) in enumerate(zip(resp_g, maxs))]
            top = max(rel)[1]
            baj = min(rel)[1]
            st.markdown(f"- Donde más riesgo aceptas: **{fin.TEST[top][0]}**\n- Donde más prudente eres: **{fin.TEST[baj][0]}**")

    with t_evo:
        hist = p.get("historial") or []
        explica("Si repites el test con el tiempo, aquí ves cómo cambia tu tolerancia al riesgo. Suele moverse tras "
                "una crisis, un cambio de trabajo o de situación familiar.")
        if len(hist) < 2:
            st.info("Solo hay un resultado guardado. Cuando repitas el test (mismo usuario) aparecerá aquí la evolución.")
        else:
            hd = pd.DataFrame(hist)
            fe = go.Figure(go.Scatter(x=hd["fecha"], y=hd["puntuacion"], mode="lines+markers",
                                      line=dict(color=C_CAP, width=3), marker=dict(size=10)))
            fe.update_layout(yaxis_range=[mn, mx], yaxis_title="Puntuación", xaxis_title="")
            st.plotly_chart(estilo(fe, 320, "no"), width="stretch")
            st.dataframe(hd.rename(columns={"fecha": "Fecha", "puntuacion": "Puntuación"}), hide_index=True, width="stretch")

    with t_vivir:
        explica("Para ponerle cifras al reparto sugerido: qué le habría pasado en los peores años de la historia "
                "(índice mundial en dólares con la renta fija al Euribor actual, sin rebalanceos).")
        ret_t, _, err_t = datos_indice(fin.INDICE_DEFECTO)
        if ret_t is None:
            st.info(f"No se han podido cargar los datos del índice: {err_t}")
        else:
            tp_t, _ = tipos_actuales()
            rf_t = rf_efectivo(tp_t.get("euribor12m") if tp_t.get("euribor12m") is not None else 0.025)
            w_t = p["rv_sugerida"] / 100
            r_cart = w_t * ret_t + (1 - w_t) * rf_t
            q1_, q2_ = st.columns(2)
            q1_.metric("Peor año de tu cartera sugerida", pct(float(r_cart.min()), 1), delta=f"en {int(r_cart.idxmin())}",
                       delta_color="off")
            q2_.metric("Años con pérdidas", f"{int((r_cart < 0).sum())} de {len(r_cart)}")
            peor = r_cart.nsmallest(5).reset_index()
            peor.columns = ["Año", "Rentabilidad de tu cartera"]
            peor["Con 10.000 € quedarían"] = 10_000 * (1 + peor["Rentabilidad de tu cartera"])
            ft = go.Figure(go.Bar(x=r_cart.index, y=r_cart.values * 100,
                                  marker_color=np.where(r_cart.values >= 0, C_CAP, C_INT)))
            ft.update_layout(xaxis_title="", yaxis_title=f"Rentabilidad del año con {p['rv_sugerida']} % en bolsa (%)")
            st.plotly_chart(estilo(ft, 320, "no"), width="stretch")
            st.dataframe(peor, hide_index=True, width="stretch", column_config={
                "Rentabilidad de tu cartera": st.column_config.NumberColumn(format="percent"),
                "Con 10.000 € quedarían": st.column_config.NumberColumn(format="%.0f €")})
            st.caption("Si ver estos años te incomoda, probablemente te convenga menos bolsa de la sugerida.")
    st.caption("El cuestionario de Grable y Lytton (1999) mide cuánto riesgo aceptas, no cuánto te conviene. "
               "El reparto sugerido es una referencia orientativa; no sustituye a un asesor.")
:::END
:::BEGIN py/ui.py|text
"""Piezas compartidas por todas las páginas: constantes visuales, formato, ajustes globales y datos con caché.
Las páginas hacen `from ui import *`."""
import os
import sys

import numpy as np
import pandas as pd  # noqa: F401  (lo usan las páginas)
import plotly.graph_objects as go  # noqa: F401
import streamlit as st

CARPETA = os.path.dirname(os.path.abspath(__file__))   # .../Planificador Financiero/py
BASE = os.path.dirname(CARPETA)
ASSETS_DIR = os.path.join(BASE, "assets")
os.makedirs(ASSETS_DIR, exist_ok=True)
os.chdir(BASE)
sys.path.insert(0, CARPETA)
import finanzas as fin

with open(os.path.join(CARPETA, "VERSION.txt"), encoding="utf-8-sig") as _f:
    VERSION = _f.read().strip()          # única fuente de la versión (la usa también generar_instaladores.py)
ICONO = os.path.join(ASSETS_DIR, "planificador.png")
COLORES = ["#4C9AFF", "#F5A524", "#2EC4A6", "#A78BFA", "#F472B6", "#EAB308", "#38BDF8", "#FB923C"]
C_CAP, C_INT, C_EXTRA, C_SALDO, C_MEDIA = "#4C9AFF", "#F5A524", "#2EC4A6", "#A78BFA", "#F5A524"
# colores semi-neón de la fórmula: un color por variable, el mismo en los parámetros y en la fórmula
NEON = {"cap": "#22F0FF", "tin": "#FF4FD8", "n": "#A6FF3D", "cuota": "#FFB02E", "tae": "#8C9EFF",
        "gris": "#8B93A7"}


CSS = """<style>
.block-container{padding-top:2.2rem;max-width:1500px}
.cab{display:flex;align-items:center;gap:14px;margin:0 0 10px}
.cab-ico{font-size:1.7rem;line-height:1;display:grid;place-items:center;width:46px;height:46px;
 border-radius:14px;background:rgba(128,128,128,.14);border:1px solid rgba(128,128,128,.2)}
.cab h1{font-size:1.9rem;font-weight:700;margin:0;padding:0;letter-spacing:-.02em}
.cab-sub{margin:2px 0 0;font-size:.9rem;opacity:.62}
.chips{display:flex;flex-wrap:wrap;gap:8px;margin:2px 0 20px}
.chip{display:inline-flex;align-items:center;gap:7px;padding:5px 13px;border-radius:999px;
 background:rgba(128,128,128,.10);border:1px solid rgba(128,128,128,.20);font-size:.84rem;
 line-height:1.45;white-space:nowrap}
.chip b{font-weight:400;font-size:.95em}
[data-testid="stMetric"]{background:rgba(128,128,128,.07);border:1px solid rgba(128,128,128,.16);
 border-radius:14px;padding:14px 16px}
[data-testid="stMetric"]:first-child{border-color:rgba(46,158,91,.45)}
[data-testid="stMetricValue"]{font-size:1.6rem;font-weight:700;letter-spacing:-.02em}
[data-testid="stMetricValue"]>div,[data-testid="stMetricLabel"]>div,[data-testid="stMetricDelta"]>div{
 overflow:visible!important;text-overflow:clip!important;white-space:normal!important;line-height:1.25}
[data-testid="stMetricLabel"] p{font-size:.82rem;opacity:.7;text-transform:uppercase;letter-spacing:.04em}
h2,h3{letter-spacing:-.01em}
[data-testid="stHeadingWithActionElements"] h2{font-size:1.25rem;margin-top:1.6rem;
 padding-bottom:.4rem;border-bottom:1px solid rgba(128,128,128,.18)}
[data-testid="stDataFrame"]{border-radius:12px;overflow:hidden;border:1px solid rgba(128,128,128,.18)}
[data-testid="stElementContainer"] .stButton>button{border-radius:10px}
[data-testid="stSidebar"] [data-testid="stExpander"]{border:none;background:rgba(128,128,128,.06);
 border-radius:12px;margin-bottom:8px}
[data-testid="stCaptionContainer"] p{opacity:.72}
[data-testid="stStatusWidget"]{visibility:hidden}
[data-testid="stMarkdownContainer"] p,[data-testid="stMarkdownContainer"] li{font-size:1.02rem;line-height:1.55}
button:focus-visible,input:focus-visible,[role="tab"]:focus-visible{outline:3px solid #22F0FF!important;outline-offset:2px}
[data-baseweb="tab-list"] button{font-size:1.02rem;padding:.55rem 1rem}
.resumen{background:rgba(76,154,255,.10);border:1px solid rgba(76,154,255,.35);border-radius:14px;
 padding:14px 18px;margin:6px 0 16px;font-size:1.08rem;line-height:1.6}

/* ---- panel de fórmula, colores semi-neón (fondo propio: se ve igual en tema claro y oscuro) ---- */
.neon{background:linear-gradient(160deg,#0c0f1a,#10121f);border:1px solid rgba(34,240,255,.30);
 border-radius:18px;padding:20px 22px;color:#C9D1E6;
 box-shadow:0 0 0 1px rgba(255,79,216,.10) inset,0 0 26px rgba(34,240,255,.10),0 0 40px rgba(255,79,216,.06)}
.neon h4{margin:0 0 12px;font-size:.78rem;letter-spacing:.14em;text-transform:uppercase;color:#8B93A7;font-weight:600}
.neon .f{font-family:'Cambria Math','STIX Two Math','Times New Roman',serif;font-size:1.32rem;line-height:2.1;
 margin:2px 0 14px;overflow-wrap:anywhere}
.neon .f.s{font-size:1.04rem;line-height:1.9;color:#AEB7CF}
.neon .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:6px 34px}
.neon .grid>div{min-width:0}
.neon .sep{height:1px;background:linear-gradient(90deg,rgba(34,240,255,.35),rgba(255,79,216,.35),transparent);
 margin:12px 0}
.neon .nota{font-size:.78rem;color:#7C849A;line-height:1.5}
.nc{color:#22F0FF;text-shadow:0 0 9px rgba(34,240,255,.65)}
.nt{color:#FF4FD8;text-shadow:0 0 9px rgba(255,79,216,.65)}
.nn{color:#A6FF3D;text-shadow:0 0 9px rgba(166,255,61,.55)}
.nq{color:#FFB02E;text-shadow:0 0 9px rgba(255,176,46,.60)}
.na{color:#8C9EFF;text-shadow:0 0 9px rgba(140,158,255,.60)}
.neon .tag{display:inline-block;font-size:.72rem;padding:1px 9px;margin:0 6px 4px 0;border-radius:999px;
 border:1px solid currentColor;opacity:.9}
/* barra del test */
.medidor{position:relative;height:12px;border-radius:99px;margin:10px 0 26px;
 background:linear-gradient(90deg,#2EC4A6,#EAB308 50%,#E5484D)}
.medidor i{position:absolute;top:-6px;width:4px;height:24px;border-radius:3px;background:#fff;
 box-shadow:0 0 0 2px rgba(0,0,0,.45)}
</style>"""


def aplicar_estilos():
    st.markdown(CSS, unsafe_allow_html=True)


# ------------------------------------------------------------------ utilidades
def es_oscuro():
    try:
        return st.context.theme.type == "dark"
    except Exception:
        return True


def estilo(fig, alto=380, leyenda="abajo"):
    """Estilo común. La leyenda va debajo del gráfico para no tapar los datos."""
    oscuro = es_oscuro()
    tinta = "#E8EAED" if oscuro else "#202124"
    rejilla = "rgba(255,255,255,.10)" if oscuro else "rgba(0,0,0,.10)"
    fig.update_layout(
        template="plotly_dark" if oscuro else "plotly_white", colorway=COLORES, height=alto,
        margin=dict(l=8, r=8, t=16, b=8),
        font=dict(family="Inter, Segoe UI, system-ui, sans-serif", size=14, color=tinta),
        paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
        hoverlabel=dict(font_size=14, bordercolor="rgba(0,0,0,0)"),
        legend=dict(orientation="h", yanchor="top", y=-0.2, x=0, title_text="", font_size=13),
        showlegend=leyenda != "no")
    fig.update_xaxes(showgrid=False, zeroline=False, linecolor=rejilla, ticks="outside", tickcolor=rejilla)
    fig.update_yaxes(gridcolor=rejilla, zeroline=False, linecolor="rgba(0,0,0,0)")
    return fig


def explica(texto):
    """Frase corta bajo el título de un gráfico: cómo leerlo."""
    st.caption(texto)


def titulo_pagina(icono, texto, subtitulo=None):
    st.markdown(f'<div class="cab"><span class="cab-ico">{icono}</span><div><h1>{texto}</h1>'
                + (f'<p class="cab-sub">{subtitulo}</p>' if subtitulo else "") + "</div></div>",
                unsafe_allow_html=True)


def chips(lista):
    st.markdown('<div class="chips">' + "".join(f'<span class="chip"><b>{i}</b> {t}</span>' for i, t in lista)
                + "</div>", unsafe_allow_html=True)


def eur(x, dec=0):
    if x is None or (isinstance(x, float) and not np.isfinite(x)):
        return "—"
    s = f"{x:,.{dec}f}"
    return s.replace(",", "§").replace(".", ",").replace("§", ".") + " €"


def pct(x, dec=2):
    if x is None or (isinstance(x, float) and not np.isfinite(x)):
        return "—"
    return f"{x * 100:.{dec}f}".replace(".", ",") + " %"


def num(x, dec=2):
    return f"{x:,.{dec}f}".replace(",", "§").replace(".", ",").replace("§", ".")


# ------------------------------------------------------------------ ajustes globales (barra lateral)
def modo_real():
    """True si el usuario ha elegido ver todo en términos reales (descontando la inflación)."""
    return bool(st.session_state.get("g_real", False))


def infl_euro_esperada():
    return float(st.session_state.get("g_infl_eur", fin.INFLACION_EURO_DEFECTO * 100)) / 100


def bloque_mc():
    return int(st.session_state.get("g_bloque", fin.BLOQUE_DEFECTO))


def rf_efectivo(r):
    """Tipo de la renta fija a usar: el nominal, o el real (con la inflación esperada del euro) en modo real."""
    return fin.tasa_real(r, infl_euro_esperada()) if modo_real() else r


def etiqueta_modo():
    return ("en términos reales (bolsa deflactada con el IPC de EE.UU., renta fija con la inflación del euro)"
            if modo_real() else "en términos nominales (sin descontar la inflación)")


def montecarlo(*args, **kw):
    return fin.montecarlo(*args, bloque=bloque_mc(), **kw)


def frontera(*args, **kw):
    return fin.frontera(*args, bloque=bloque_mc(), **kw)


# ------------------------------------------------------------------ datos de mercado (con caché)
@st.cache_data(ttl=3600, show_spinner="Leyendo tipos del euro (BCE)…")
def datos_tipos_actuales():
    return fin.tipos_actuales()


def tipos_actuales():
    """(dict con euribor12m y bono10, dict de errores por serie)."""
    return datos_tipos_actuales()


@st.cache_data(ttl=3600, show_spinner="Descargando la curva de tipos del euro (BCE), solo la primera vez…")
def datos_curva():
    try:
        return fin.curva_bce(), None
    except Exception as e:
        return None, str(e)[:500]


@st.cache_data(ttl=3600, show_spinner="Descargando el índice (Yahoo Finance)…")
def _datos_indice(nombre, real):
    try:
        return fin.indice_anual(nombre, real=real), fin.indice_mensual(nombre, real=real), None
    except Exception as e:
        fin.registrar_error(f"datos_indice {nombre}", e)
        return None, None, str(e)[:500]


def datos_indice(nombre):
    """(rentabilidades anuales, nivel mensual, error). Respeta el modo nominal / real."""
    return _datos_indice(nombre, modo_real())


@st.cache_data(ttl=3600, show_spinner="Descargando el índice semanal…")
def _serie_semanal(nombre, real):
    return fin.indice_semanal(nombre, real=real).values


def serie_semanal(nombre):
    return _serie_semanal(nombre, modo_real())


@st.cache_data(ttl=3600, show_spinner="Leyendo la inflación de la zona euro (BCE)…")
def _inflacion_euro():
    try:
        return fin.inflacion_anual(fin.hicp_euro())
    except Exception as e:
        fin.registrar_error("HICP zona euro", e)
        return None


def inflacion_rf():
    """Inflación anual del euro por año para la renta fija histórica (solo en modo real)."""
    return _inflacion_euro() if modo_real() else None


@st.cache_data(ttl=3600, show_spinner="Calculando el mal escenario de cada plazo…")
def _tabla_mal_escenario(indice, r_rf, pesos, q, real):
    try:
        v = fin.indice_semanal(indice, real=real).values
        return fin.mal_escenario(v, list(pesos), r_rf, np.arange(1, 30.01, 0.5), q)
    except Exception as e:
        fin.registrar_error(f"mal_escenario {indice}", e)
        return None


def tabla_mal_escenario(indice, r_rf, pesos, q):
    return _tabla_mal_escenario(indice, r_rf, pesos, q, modo_real())


@st.cache_data(ttl=3600, show_spinner="Calculando probabilidades semana a semana…")
def _curvas_plazos(indice, r_rf, pesos, estrategia, real):
    try:
        v = fin.indice_semanal(indice, real=real).values
        raw, suav = fin.prob_perder_semanal(v, list(pesos), r_rf, estrategia=estrategia)
        return raw, suav, None
    except Exception as e:
        fin.registrar_error(f"curvas_plazos {indice}", e)
        return None, None, str(e)[:500]


def curvas_plazos(indice, r_rf, pesos, estrategia):
    return _curvas_plazos(indice, r_rf, pesos, estrategia, modo_real())


def refrescar_mercado():
    for f in (_curvas_plazos, _tabla_mal_escenario, datos_tipos_actuales, datos_curva, _datos_indice,
              _serie_semanal, _inflacion_euro):
        f.clear()
    fin.tipos_actuales(forzar=True)
    for n in fin.INDICES:
        try:
            fin.indice_mensual(n, forzar=True)
            fin.indice_semanal(n, forzar=True)
        except Exception as e:
            fin.registrar_error(f"Actualizar {n}", e)
    for f in (fin.ipc_eeuu, fin.hicp_euro):
        try:
            f(forzar=True)
        except Exception as e:
            fin.registrar_error("Actualizar inflación", e)
:::END
:::BEGIN py/planificador_app.pyw|text
"""
Planificador financiero — lanzador de escritorio con icono en la bandeja del sistema.

- Abre la app (Streamlit) en una ventana propia, sin navegador ni consola.
- Cerrar la ventana solo la OCULTA: la app sigue en segundo plano.
- Para salir del todo: icono junto al reloj → clic derecho → Salir.
- Si ya está abierta, volver a lanzarla solo muestra la ventana.

Requiere: pip install streamlit plotly pandas numpy yfinance pystray pillow pywebview
"""
import os
import socket
import subprocess
import sys
import threading
import time
import urllib.request

CARPETA = os.path.dirname(os.path.abspath(__file__))   # .../Planificador Financiero/py
BASE = os.path.dirname(CARPETA)                          # .../Planificador Financiero
ASSETS_DIR = os.path.join(BASE, "assets")
os.chdir(BASE)
PUERTO = 8601             # servidor de la app
PUERTO_CONTROL = 8611     # para detectar que ya hay una instancia abierta
URL = f"http://localhost:{PUERTO}"
TITULO = "Planificador financiero"
ICONO = os.path.join(ASSETS_DIR, "planificador.ico")
ICONO_PNG = os.path.join(ASSETS_DIR, "planificador.png")
SIN_VENTANA = subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0

CARGANDO = """<html><body style="margin:0;height:100vh;display:flex;flex-direction:column;
align-items:center;justify-content:center;font-family:Segoe UI,sans-serif;background:#111;color:#eee">
<div style="font:700 84px Segoe UI,sans-serif;color:#fff;background:#14532D;border-radius:22px;width:110px;height:110px;display:grid;place-items:center">$</div><h2 style="margin:8px 0">Planificador financiero</h2>
<p id="m" style="color:#aaa">Arrancando la app…</p>
<div style="width:48px;height:48px;border:5px solid #444;border-top-color:#16A34A;border-radius:50%;
animation:g 1s linear infinite"></div>
<style>@keyframes g{to{transform:rotate(360deg)}}</style></body></html>"""

servidor = None
ventana = None
icono_bandeja = None
saliendo = False


# ------------------------------------------------------------ utilidades
def en_marcha():
    try:
        with urllib.request.urlopen(URL + "/_stcore/health", timeout=1) as r:
            return r.status == 200
    except Exception:
        return False


def mensaje_error(texto):
    try:
        import ctypes
        ctypes.windll.user32.MessageBoxW(0, texto, TITULO, 0x10)
    except Exception:
        print(texto)


def matar(pid):
    if os.name == "nt":
        subprocess.run(["taskkill", "/PID", str(pid), "/T", "/F"], capture_output=True,
                       creationflags=SIN_VENTANA)
    else:
        try:
            os.kill(pid, 15)
        except OSError:
            pass


# ------------------------------------------------------------ una sola instancia
def ya_abierta():
    """Si hay otra instancia, le pide que muestre la ventana y devuelve True."""
    try:
        with socket.create_connection(("127.0.0.1", PUERTO_CONTROL), timeout=1) as s:
            s.sendall(b"mostrar")
        return True
    except OSError:
        return False


def escuchar_control():
    srv = socket.socket()
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("127.0.0.1", PUERTO_CONTROL))
    srv.listen()

    def bucle():
        while not saliendo:
            try:
                c, _ = srv.accept()
                if c.recv(32).startswith(b"mostrar"):
                    mostrar()
                c.close()
            except OSError:
                break
    threading.Thread(target=bucle, daemon=True).start()


# ------------------------------------------------------------ servidor de la app
def arrancar_servidor():
    global servidor
    if en_marcha():
        return
    python = sys.executable.replace("pythonw.exe", "python.exe")
    log = open(os.path.join(BASE, "app.log"), "w", encoding="utf-8")
    servidor = subprocess.Popen(
        [python, "-m", "streamlit", "run", "app_planificador.py", "--server.port", str(PUERTO),
         "--server.address", "127.0.0.1",          # solo este ordenador: nada visible desde la red
         "--server.headless", "true", "--browser.gatherUsageStats", "false"],
        stdout=log, stderr=subprocess.STDOUT, cwd=CARPETA, creationflags=SIN_VENTANA)


def esperar_servidor(timeout=60):
    t0 = time.time()
    while time.time() - t0 < timeout:
        if en_marcha():
            return True
        if servidor and servidor.poll() is not None:
            return False
        time.sleep(0.5)
    return False


# ------------------------------------------------------------ ventana
def mostrar(*_):
    if ventana is not None:
        try:
            ventana.show()
            ventana.restore()
        except Exception:
            pass
    else:
        abrir_edge()


def abrir_edge():
    """Alternativa si pywebview no está instalado: Edge en modo aplicación."""
    for edge in (r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
                 r"C:\Program Files\Microsoft\Edge\Application\msedge.exe"):
        if os.path.exists(edge):
            subprocess.Popen([edge, f"--app={URL}", "--window-size=1400,900"])
            return
    import webbrowser
    webbrowser.open(URL)


def al_cerrar_ventana():
    """Cerrar = ocultar. La app sigue en la bandeja."""
    if saliendo:
        return True
    threading.Thread(target=ventana.hide, daemon=True).start()
    return False


# ------------------------------------------------------------ bandeja del sistema
def salir(*_):
    global saliendo
    saliendo = True
    if servidor and servidor.poll() is None:
        matar(servidor.pid)
    if icono_bandeja:
        icono_bandeja.stop()
    if ventana is not None:
        try:
            ventana.destroy()
        except Exception:
            pass
    os._exit(0)


def crear_bandeja():
    global icono_bandeja
    import pystray
    from PIL import Image
    ruta = ICONO_PNG if os.path.exists(ICONO_PNG) else ICONO
    img = Image.open(ruta) if os.path.exists(ruta) else Image.new("RGB", (64, 64), "black")
    menu = pystray.Menu(
        pystray.MenuItem("Abrir Planificador", mostrar, default=True),
        pystray.Menu.SEPARATOR,
        pystray.MenuItem("Salir", salir),
    )
    icono_bandeja = pystray.Icon("planificador", img, TITULO, menu)
    return icono_bandeja


# ------------------------------------------------------------ instalación (desde el instalador)
def instalar():
    """Crea el acceso directo del escritorio y abre la app sin consola."""
    pyw = os.path.join(os.path.dirname(sys.executable), "pythonw.exe")
    if not os.path.exists(pyw):
        pyw = sys.executable
    script = os.path.abspath(__file__)
    icono = ICONO if os.path.exists(ICONO) else os.environ.get("SystemRoot", r"C:\Windows") + r"\System32\shell32.dll,13"
    ps = (
        "$l = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Planificador.lnk';"
        "$s = (New-Object -ComObject WScript.Shell).CreateShortcut($l);"
        f"$s.TargetPath = '{pyw}';"
        f"$s.Arguments = '\"{script}\"';"
        f"$s.WorkingDirectory = '{CARPETA}';"
        f"$s.IconLocation = '{icono}';"
        "$s.Description = 'Planificador financiero';"
        "$s.Save()"
    )
    r = subprocess.run(["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps],
                       capture_output=True, text=True)
    print("      Acceso directo 'Planificador' creado en el escritorio" if r.returncode == 0
          else f"      No se pudo crear el acceso directo: {r.stderr.strip()[:200]}")
    subprocess.Popen([pyw, script], cwd=CARPETA, close_fds=True,
                     creationflags=0x00000008 | 0x00000200)  # DETACHED_PROCESS | NEW_PROCESS_GROUP


# ------------------------------------------------------------ principal
def main():
    global ventana
    if ya_abierta():
        return
    escuchar_control()
    arrancar_servidor()
    bandeja = crear_bandeja()

    try:
        import webview
    except ImportError:
        webview = None

    if webview is None:
        threading.Thread(target=lambda: esperar_servidor() and abrir_edge(), daemon=True).start()
        bandeja.run()          # bloquea hasta "Salir"
        return

    threading.Thread(target=bandeja.run, daemon=True).start()
    webview.settings["OPEN_EXTERNAL_LINKS_IN_BROWSER"] = True
    webview.settings["ALLOW_DOWNLOADS"] = True
    ventana = webview.create_window(TITULO, html=CARGANDO, width=1400, height=900,
                                    min_size=(900, 600), maximized=True, background_color="#111111")
    ventana.events.closing += al_cerrar_ventana

    def cargar():
        if esperar_servidor():
            ventana.load_url(URL)
        else:
            ventana.evaluate_js("document.getElementById('m').innerText = "
                                "'No se ha podido arrancar la app. Mira app.log en la carpeta del programa.'")
    webview.start(cargar, icon=ICONO if os.path.exists(ICONO) else None)
    salir()


if __name__ == "__main__" and "--instalar" in sys.argv:
    instalar()
elif __name__ == "__main__":
    try:
        main()
    except Exception as e:
        mensaje_error(f"Error al abrir la app:\n{e}")
        salir()
:::END
:::BEGIN py/requirements.txt|text
# Rangos acotados: se aceptan parches y versiones menores, pero no saltos de versión mayor que puedan romper la app.
# Probado con: streamlit 1.64 · plotly 7.1 · pandas 3.0 · numpy 2.5 · yfinance 1.7 (Python 3.13/3.14).
streamlit>=1.40,<2
plotly>=5.20,<8
pandas>=2.2,<4
numpy>=1.26,<3
yfinance>=0.2.50,<2
requests>=2.31,<3
certifi>=2024.2.2
pystray>=0.19,<1
pillow>=10,<13
pywebview>=5,<7
:::END
:::BEGIN py/VERSION.txt|text
1.3.0
:::END
:::BEGIN assets/planificador.ico|b64
AAABAAcAEBAAAAAAIAAGAwAAdgAAABgYAAAAACAAZgUAAHwDAAAgIAAAAAAgAIQHAADiCAAAMDAA
AAAAIAAyDAAAZhAAAEBAAAAAACAA9BEAAJgcAACAgAAAAAAgAJUmAACMLgAAAAAAAAAAIADnUAAA
IVUAAIlQTkcNChoKAAAADUlIRFIAAAAQAAAAEAgGAAAAH/P/YQAAAs1JREFUeJx9kl9o1nUUxj/n
+/vzvu/mWthoOK2wZgWGQeXSMBldjOwiqXRdBXmzWkHgjYIXFVhgQiAhVBcR3hj9g6CCLiLBBTql
cBejommWsZeNtZT9ed2+33NOF+/7Zled6/M8PM/nHAHoG3n42WpZfYFAj6sV/M9IFiLG3PW48t70
+2c/kfUjA3vLULy1tLqy3lRzQNrLIQQAzOy/Hh5Cph2Vyp8xxQN5QTm6uLx0m5rlckNLlmU0Gg0c
6KzUUFPcmyGSxrCkentntfOlYCmt06gZ6rgark5OYHZmmt1bh9izbRcz9StoVLy1gzoaNWhM63JP
4NqyBtSV1ZUVtmzczHODT1EtK/z6xxT1q3PML1xFJNzokpzc1fDU6ihCjJHjLx9m39AwAKsx8v3b
XzBx6Se2799NtajgrS4URt6M5YQQWFxe4oH++9g3NMxnp79mavoya6qdHD35Do9tHaQSSjQpbVat
BK3uBqIQVyMAD969hb5beqnPz5JJzokvT7Kmq5ssZDjNxG5OIDmeHI1KLa8wefEXDp84xq039/DI
5od45tEn+O3jc3z+xodkHtDUgpkcS0Yw0xZ9w9QQF1499hq9j9/LB199xLfnTzM2Mc7TO3cxeP92
FhcWCC7/aoKnJgMMGssN7tlwJwdHDtKVlVxbXODs5I+MXRhvMnaBZLQ1niB3czwZEgIaE9Ws5Mjo
IY6MHiJpIs9yAL45c4pT58aoVTrQmJqXMCNvu6kqtaLKhZ8n2fjkAJt6+9j//CuIwOvH32Ti94uY
GXleYN6CmIwc87oYm5JpFkQQhPrsDJd/OM+OgZ1UywrjY9/RdUc/SRKWFHcnC5njUpfuHf178qw4
uny9scHUMgQJEsCNtd1rEYG//p7HRdoP5CEE66jVriSNBwTgpm13DZdF+aI7PbjlBiIixLgKDkVZ
4u4EcCQkEeZiiu9eOzP16T9XMpVzgThm+QAAAABJRU5ErkJggolQTkcNChoKAAAADUlIRFIAAAAY
AAAAGAgGAAAA4Hc9+AAABS1JREFUeJyVlVuMXVUZx39r7bVv55yZ6ZzDDENrh2nBCK3UFhGKYBqS
hkq0ESQiEhtrRU1aiD5oNEpyMjE+ITESL7FRLkFe9KUvJpQXK4lGMdNyKZiWdsKUtlLmcqYzZ87e
5+y91ufDPp057VgTVvI97Kxvf//1/383Rb2uGR93/Xu37Bqs9O/xfX9UOWJENB/mKOVEk2RZdqbR
XHhh4bk3DlOvawVQ27vt24N9A/tRSiWdtOqsjQD1oQBAtOelsR81QOx8c+HXM88ePagGHrll59Bg
9al2J+tvZq0x/X/iqu6dIFf1cQgVE58Jw6Ax3Zj7nqmUyo+63PnN9tKYRtmrSaMA6ywAWl9dPU/h
mp3WqG9Mqz8u7zOBMtcnaVJVDpEiuOrlIN3gDiiHJRTQaif/W6PCtFJI0kpqcRRdb5QjcLnzxYlS
Xe69AmitMdrjwvwMzzzxJKUw5rP1PdT6BrusHCKXSyYKZcUZcQRGRBBX2JXSelqzuNQEwCiP4YEa
5TAm9AJaSUIrbVGJK/jGXAYiiuLbCkasgAj0AEg3+EJzkbs2f4rHdn+NLRtuZnR4HVppTv3uFd59
/yyvTb7FLw49w/m5CwTGXwFRgBZwYBBWMdBas9hssmPLdv78k+fxjYFukkWEof4qa6vX8ulNn+Sl
fx3h1PkpwrKPc7LCAEHEYXCC2MJ6T55lfOf+ffjG0ExaPDj+TX7w8AGqfQPsfmIvmzfcxL23foaZ
+TkMGmdXcrEMYAWDdWCBHgDnLIEJGF5zDc45QJg4+SZJmpAGIWdPHufs++d4+dW/0lcqE5sQm7vL
O8gTRAR9SZ5eUyjSVsLk+TNorQn9kGO/PcwdN2/jutoIj37lce7YdBuh55NneSHtqjjFw9X6L90+
sZS2xjp5VlXdstdKk3ZSPrZ+I4d++iwbrlu/quZzm/PSq0c48PMfMT0/R+D7uEIiEVC+5zX64spp
I65bQW5FIiuW0IScmJrk7gP389A9u9mxdTs7tt7JQKUfrRTGM3z+zp1kec6DP/4GgQnAuZ4GEhCH
Rgo6vfQQweWWLMv4YHaGp//0ex747sMcO/kmb5x6mwd++HVmFxpYZ7nr47cxvGaITrsNrqcireCs
oLGC5IJYt1xNYgun+26/h3W1EZQDWgnWOprJEodefI7T56aWh58StfLA5RggDgyOVRIppWi1U556
vM7QYI2/TPyN1/79OmMjH8H3fQ7+8g984oZNaK05duI4H0xfoFyu4GyPRKoAUus+t22imSx1k6y6
SVa00pQXxp/mkV1fXJXgS+efx4+yp/4YU/95jyCIcOKWkxx4plEulU6rtfdtnVhMlsayHgC6bkop
Prp+I7fceBNrq0Ps//I+tNY8+fyvOPHeJK8c/QdZnhOFUdEvy3+ifGMafaXSaTVy75a/J+10Y5q1
h1WhqhIpZrYIpJ0Ucgtz07z8xyOU4pi7v7AdasNEUYxWGudc4c8lACHyw5k4it8xadqeisJoTStJ
rvWUtgIaus4KSkGMKRlazhH6AaEfYgauoRT30bE5Tool1DNonBPnRaVorp2231Xe1uGdQ7WRn7U7
7cHFZGlUq9UrUymFyy03jG5Aa8U7U5No7V2xOhUgOBEqUelsFIYz07Oz31cA/q3rvlXrr+53iEna
SdVZF9Kz9KULkrZTQIjCGBG5cnuL9nQ7DuOGVqoze3HuN9nRcwcVdTTjODYP7RroX/PVMAhHgRDQ
iFw+v7q72PZ2bEFRAAcqbWfpmYsX51/krenD1NH/BZv6x+7/vmbKAAAAAElFTkSuQmCCiVBORw0K
GgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAHS0lEQVR4nK2XaaxdVRmGnzXsM9/h3KmDkJS0
QIUytBREbDVqISWUWFOvf2wTKU6RWEbRRCP+wP5oSHGK4FBJKcbExoHYaFOVpMahaVo60JbSCvXa
8RbucO6Zz95rff7Y595a7jlwE9zJytlnD+v71vu977u+rQAYHDRs3+461i28JkinH8qY1JLA2KxC
af4Ph1fiIheVK1Ht5bBa/V5x2/ETkzHV5EnXuhvXd3RkH+3tyJ/3kZd6VM+JkyQKeU/RBaWMqieC
RNkYw8jE+OxiqbS5sO3wzxkcNAqgY+0Nn+3JdW7q7cz/89z4xVsbUTgHBQig3uPyJ+cQSBg7PLd7
YO9oaXzpSLHwjeILR55TybXXLehJ5nbO6e4/MjRydhUoozz+PYZtnYtGi4jM65+7Y3hs5No3KxOr
bBrzWG82f/bMyIVl4jFKRARmVHujDQDOu5ll4BAU6szF4eWz8n2HyvXKIzZtk7d470qhi3q1x6Nm
FhyB8UoBBHLpLEopEHm3kinl8aGOusMoUhmbWmytDjL1Rl1EBBHFzCgnKBT3Ll2BNYaXDv+DyLlm
EjN4W0Tq9XousIG12oM4MXhhJpWPYRessWzZsIlcKsOCz3+YYrWE0QbvPd6/60QKLxoB6wW0COIF
aZe9gFIKpRTFcolao4a1ARPlIs453iqMUSpPYIIEgbGkgiRKq7YqEgERjwjY5j/w0hY+rTSNMKQR
Nrh94RKWXX8rC+bOo7czT2ADtjy4iVMXTnPy3CmODZ3k9fNDNKLwEi9aLCiOCxYB8c3R4lmlFPWw
QWcmxw8f3cwn71g57ZlPL181de6845kd29jw7Lfp7egmctMVIkrwjmYCrhm1FQJN+KIoYutjT7Ni
8TKc9xitaUQhRmuUUowVC3RlO7DGYrRhdn4AidwlZKdB2rwmHhvXQhOrYDr0xXKJj9xwOysWL6MR
hgTWsmv/X3n8pxv548bnyaYyLH9kDZlkikXzFvKJD97FhdGLGKXxTpAWsIqPOTdVArxviYBWEDVC
Fl45P04QQSnFd3/9Mw4d2oNWceJjEwXeKA1x4ORRXvjTb8h3dJFL5XBRNH31AGoSGcGKn0JjGgKi
ABHCMIzfU3FNvrL6Pv5z4SzOO0SEiVKRerVKJtNBOpGkEYZNU2rtC6LieFymApmOgHeewCbYf+IV
lFIYrXHecfdtH2XFkuUopfDe8cxDG9l7/CB7ju7n0OuvYo0hlUy9gx9MMh/U3DW3HDXa1EbL40u0
KM/b9gGjNRPlIpsfeIIHP/W5OLEmbPpt7UIYRezat5vHn32Sf535N+lUulUS3ivR+WznQS+i9RRT
2wznPNlkhq/+6Em++NTXOHjyCAo1LXjkIqy13HP7x9m56Rf0d/bQaDRQQuu5nYAD3UTi8kr87/Ae
hSKTTPOT3z7Ph768mtu+cA9feurrjJcmiFzEqfOnscaigHrY4MqBuay9aw3VUrFJ1Pbzx3ddewSU
KGr1OrV6nd7uPhImwYETR/jx77ZRrJSo1KosvX8lG57+JiKCVgoR4ab514GoWG6tRjMDjSeWmJem
F1waCISNBvNmXcGcngFGhs8zXhhHo+nKdDTLoKjUamz5/S+p1KsENmhyx8Rck+nzigjex0S0eA9K
t3QsYzSlUokVS5fzxP2Psv3PL/KX/X/n2KkTFMpFFLHSZnX1snblGjLJNPVGnWQiyfGhkxBFKM/0
uZVM1b25G06p4nKxNH1ARBjI9/LA4HoeGFxPuVphrFhgoKcPrTQHtu4i39mN845kIslYscDWHb8i
kcriIjfdX7jkA00V+JYMEe8x2jJ07jSnh89OTZBNZ7hiYA7WWLTW5Du7p2A/fPIY9z68jlNnhkgE
iViGrdg3acXiY4uNfy8/Iu9IprPs2rObmz9zJzdffT2Lr13E/CuvYk5vP3ff8TG01ry4eycnht5g
z5GXeWnf3yhXK2QzOVzUuleUphGJgOpfcf2RILCVkcL4rZrpRgSxBUfO0ajXwEUxYskkZ/5wgGw6
w8CdiwgnCpBKkUpnm51R20bVe0TnO7tfFuetbYSNSiaZqcSbTeuOUkQwSpPN5NBa47wnMGbqfneu
m5K2GGNwzuFa9ABTiyHmQEIH5UKtGOhKubrfaK0CZUfFe40XaaVb8YKLHFEYEYURLnQkgwSpZBIX
Na9Frr3u4yHei7aYgjXGV0rlA4r3913d2ZPfMbu3/7VT50+vUqCapWi7hsltecnCRRht2P/qKzjv
2rdgk9iD9niumnPFjoujo/MLb42ujjG/adZ9PV093+nryu87c/HcB8IoGmjTT07hKAJRrRprOZ3h
nT4LJlMKrH3zff2z945NjN80Uhj7FoeGn1MMYtiO48ZZ6ztznQ/35fMXwsjpeqPe4Z0E7XLQgDYx
X7175285bYiSiVQx0Ma9VRgbmChNfJ/Dw1sYJP44nUpiYd81JhVsyCSzNycCm1Uo1ZaZMz1UbGVh
FJXKteohV639gNdGXpuM+V8rxmiBRPn/mAAAAABJRU5ErkJggolQTkcNChoKAAAADUlIRFIAAAAw
AAAAMAgGAAAAVwL5hwAAC/lJREFUeJy9mnuMXNV9xz/nnDt33rPrfXmNbdYv8GKMDcYu4CIKDSUh
aZsa16IiDZSQQEuSkgQ1UpDSSkFVCgKS0oQEQmLSlAoKOFCk0pLwjkyJH9jGYBbTNcbGeFnvc2Z2
XvecX/+4d8a7ppVn15Z/qyOt7pzH93d+5/f9fc+dUUy2DRsMjz1mATq/cv7vBuXgS+LUJ4zSc5VW
ilNo4sRZ3AdKyfOe7z04eN+23xyLEeAoqOiD076wdmlZl7+vlfpULpHe15Zp3ZWIJQfjnrECSoGc
Cgdq1uqJSqlzeGL0nHypuMg692xCkrcc+tnmvslOqMngO29YfZVV9tGWVO7Asu5Fj4+Xiy0fjn50
bqlSmm+tzZwK4HXT2hRT8eTB7tbOna2p7NCew/3rRopjC42Yqwd/unVTHbOq/9N1/Zp1Ni6bTm/t
fmp2pqNv58G+z5WDylwlUG+nZOsJd1XU0ZYwscMr5i19eKg8dvq+oQ826DLrBx8KnVCAmn/j2kWF
2sQ7Pe1z/2NWMvvBjkNv36SdQgtWBBXNeUpzgHC/RCnEKYzTcFbXoo0Vqeb6Bw6sy8RSZx54YHO/
BqQwUfhxSyJ7sDvX/taOg303mZpyyiLiMAgaQYXTndKmELQ4jLKICbB7Bvqvb0+17J+VyvXny4Uf
A6Larlt1IUpevWDRiru273vrL2q21qEE4dTv+PFMRIGnvfHVS5bf/9rend90jrXaBrWbs7HU/rGJ
fFvFVTuUYE/KjgMq+guXP+GmtOCqErQMjY/OycXTewNb/bIn1l3enmnZMjA8uFI5BCcnZedFBOsc
AFpp1EkoIyIhjR8eHjyvM9e2cyg/cpnWSs9OxpMfFculeTiUCEoETqQ5ETztkUtmySWzxLwYTuSE
5oyaxqFKlfJpST85opWZrZVS2sOz1tpU1EudyApGafLFAleuupQtd/87W+5+mmsu+SzjhTye1ifs
gXKCtUFKIYEWjNcgdwHcCUcZBJxzpOMpulo7AMgmMjjnpuTHSTEBT0SiiQWRmc+ulUYrhVYK54TA
Bo35qkEVsbbRT6n6UXMzWlNRD4gwNQIzwB9qPEWhVKRSq5KKJzBKkYwlGombiadJ+knKlQrF0gRW
HJ42JPw4MS82/UXrJuAh0dmpn7Nmxwp4xlCqlKnZGhf2ruLK1Zex+owVzOvoprutq9H3G+tu4NpP
XMXA6BH2HT7AngN72bXvbXbv72NgZHAGDKXAhZg9cTC5NWtGa/ITBXq65nHnDbfx2Yuu+H/7JuNJ
5ncmmd95GqvPWNF4XigV+foD32Hjfz3KrGwLgW0OgCjCPXeNCAA0HwGtNRPlEkvmLOA///4XzOuY
gxPBufBMa60w2nxsnHUOawOEkFIzyTRdLe1Yaxt52JxF/Ro54JhWDogLE/8nt9zBvI45VIMavhdD
Gd2ovKVqmaSfACBfKiLOkUtnMdqf4lClWj2KaTo5GGGOWMhFheb4MxitGSvmueL8S7ho2flYZ/Gj
QqWVYvveN7jl3m+xZvnvcM9NfwvAPU88wI+efIjenjNZdFoPF/aex8XL17Cs50xSiSTYMHLNMpIg
ONzMWEihsLWAi846P1o0pDMF5CcKXHfn19m987/pXbisMaZcqTBw5DDj5Qle2vUaG595hGwqy+Wr
LiZfKpLwEzjrpheBCK+HkygcTeaAhCPntHU12EMI6TRfKnJoaIBYazsx4zWGGK3RxicTT0X0CoG1
PLX5WWLGIxlPhIVuWuhDLFqOwd9Mw0E1qDWm00rhxDGnrYvP/f46aoMDjBULjc+DwIY7HOWHtWEO
taSyJP0kzk1fJ9WZ34tK4vQiIEL/of1THisVSud7v/IdLl1xISjVyIt0IgkIw+Mj2FqAH4+TSiQR
J7jpcPeUCLhJLARHmeg45qzg+wl+ve03WGcjWSBTitFVl3w6Wiac8BsbbmTdxVey5/29bN69lRde
38zufW+jtSaTzIQ0OhO1PVkLNcsCViypeJKde3fzT5s28rU//SLWWXBhfUARHhelMFoDkE6kWL5w
KcsXLmXD7/0hlVqVZ7e8xHcf/gGvvrmNlmwuGtMsbokKcaivmW5z1pJNZvnW/d/lvl/+HKMNxhiU
UogTBJmCRaIiZ53FWks85vNHa/+AF7//ONdesZ7x8fGw8E0HR3SK9Me0UBNNXAgwZjy+/L3buPxr
V/Nvzz/N0NgIWms844XROMYJhcIYgxCqVT8W48Fv3sXKxcuYmCiGwrBZHFHeeiINXTQdLdc49y3p
Fp5/fTPPbXuF07vns3rpSlYu7uWTF1zKBctWNfoZY6aM84xHzQbEvBg3/8l13PgPt5JKpJrjkQaG
GUaAet5E2iaXTNOSbuGj4UGefOUZ/u7u27j3sZ81FvzJ0w/zxdu/ypY9O8JjFqE0SiMiXHTOalKp
DEEQTCMCoQd6pm8JxDmMMmilsdZhrSVmYsxKt+C1dpBOpoCQXt/e/y4//df7ueyrG9j29i6UUjjn
QupViq7WdnKpLDawoZZqBkMUCl3fDZGjeqSZ5hmPsfFRCsVCeLa1QaFwzmJtgLONF8jEY3FiXXOY
mCjyqy0vA0zhf611VAybXJ+jEmbaatRoQ358hNv/6ja62zr5weMb2b2vj6BcAs8jkUgiwdHrJIC1
llo+DyL0dM+LnqqIrRRj+XHyE0WM0mFyHs8mRcCraxuavA8oQIKAtlwrN/zxNVz76Q1seWsHz219
hd+++TrvfXiQfQf6QzCRJWI+c9s6+fz661h/6WeiCBoCG6CMZlvfLvJjI+Rys8KaclwHJlXiKB+b
VxIudKNSrVINamilWLtiDWtXrAGgUq1wZHQYb5KYu/Wav+Rv/vxmMsl041kjB4D7nvhntPaoq9tp
4K9roWl4gIB1ZFJpfC9GYAOqtRpOHEYb4n6cuV1zpozIpbMA1IJaQzPVafXb99/JS799mUyuFRs0
KSnqOEXwPlbhjgvf4fkJnnvtZdb0ruTsxb34Me/4A2HKG4j+D/Zz+4P38NDTj5DJtIRJ32QeNvLW
RVoovN3QlBYKrMVPJHnk2af45YvPcPbCpVyw/DxWLzuX3p4lnNbZTUsmSzqZwo+F18dypcxIfowP
jwywa+8efv3aSzzz6gsMjxwhnW0Jxdw0LNRCk29kx/Lr8SYQIZ1M45xje99utr+xDQAVT9CazWGC
gC+sv5Y7/vrbANz1ix9xx4P3EBiPciEPCuKpDJls67TBH+MJnljrgqBmjFITgUg2cuO4J7HO8+lE
Eh0VLeuEarVKcWiQwZGhRt+xYp7C+Bi5zm68ltZwvHPYIJgJZrRRJSVixNrAC6wdKJbKHQk/cahU
rXZpVFMO1M1ax+Q9jBkP5cXwJr1WMdqgjBe9cjyBHQfnEBX34x9OlEuzatYOaJDnhkaGVs5p79op
4pQ6elOfURNxiHMENpTO1trwvLqZ6K2pTYmIE6dmz+rYMTg8fA4iL2rfj/1wvFBY2JZtHYxrf8SJ
6LBWMyONFDKE4HsxjAnvCfGYH8nfE5hTECeifeUVuts6D4yOj/XG/NgPFYBeNfdXbS2ti3t7Fm96
9a3tt8bQVkAzg4ueUoqgWmXBvB7WnH0uCti59y3e6d+L8f2mmO7/MFHgajizpnflvfsOHfjk4PDQ
Qbf9g8sVoOJrlywKquV3lsxd8GQy4Y+98T/vXG9QaKXqjtC0MxI6Ua1VceVS+CyeIOHHQ/DNb4lE
izonYizCmfMWPKy0Nn3v91/t+YkzKpvf7VdswPAYNrmmZ11NuU1L5vY81p6bdeD1vt2fr9SqnXry
F3XTMK1U41bmxOGaEWkf80BwCL7nD688s/df8oVCR9/B966JiV5f2rp/Exsw0U8NQif81T1XBTZ4
tL219d3li856anD0yOwPBwfOLVXK8511qTCSp8KUaK1LyUTi4OyOrh3dbR2H3uzf+5kjI0NnGWP+
rLr1/SfqmCf92CN8kF29YGkhqP5jTOvLWzO5d9tntb+RTiaHQJ2ML6CmYaInSqVZR0ZHzhktjC6p
Wfd8xvNvyW99r6+OFY49kZM+SJw//+JKtfolhbpMazNHK9Wc4DlJ5kRqztnDgrxgYv6DwfYDrxyL
EeB/AZFfTWDok6EkAAAAAElFTkSuQmCCiVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHe
AAARu0lEQVR4nNWbe5xV1XXHv3vvcx9z5/1gYEAGB4QhgCCiqEQC0YiK0RhbSSJpE21rY5tYm6af
TzQPpCZNUptXTdI8avykRmNCSh6KGtQgahBEfICgIIK8B5hh3nNfZ+/VP865d+4wYyJ3mKhrPvsz
995z9mM99lq/tfY5iqFoGZrluODzMj227XcX+L5/hbOywDnXjKdioIbs+taRgC8ZrfR27anHPR35
zcFRi9awfHnIRwFPBTSYi6uvNqxYYVm2TI85/NBS69xNTnOmMgovq1Il0fiukkisTWvtI6JQSkae
uT9C4RqcE5PyU7WpTLop40lCnEM7njNKf6tl9KX3sHy5y/NWQAMFEN4w5tq501zEfd/F9HydFsZW
1t//rvGT1pfHy/pau9sr+pI9NQ68wfJ8i0gD4JeWJDpqy6s7kqlU/OUDu84+cOzQVTau0Gn3pM7q
T7Tc9cy244XQL4AFCzzWrvVHXzfnMjHqpy5CVX28ZvXFM+evfOXQrtO2H9h5cXdf31RnJBKo/K1V
/GBSKAHt8EtLSnc0j21aPXP8u15evfmJ9x/oO3q5ztCpRa5puXPTgzleg16Q13zd3511qUJ+68Cb
2zTrq6Mra9oe2fKHT/XZdKNyoB0gOKXedtwDIIJCoZ0G0RDX0UMLp5/7nXQmFVn7ysZblcKCurz1
R88+lONZsWyZZvlyV3vdWc1ay3qHVF5+5oU372s9eMpze7Z9UjvQoqwEwtJvP80fTwpAFDinxDgD
Mxom/3jq2EmbV2763X8qVI84dW7bj5/dzrJlWrEMDQt03d7utS6q5s0dP/0/Mr5f9vz+l//BZLEE
O+zt5vLfLAkK5xsx00af9pOxVXW717y28VaVkXWtjeULYK3TLMfV7+9ZIjE9b0y0+tEx1fVHn9+z
LWBe0AiBwb8zm8JhvKzyX27Z+TGljJySGPUbiel59ft7lrAcp+dcPyfiZ+3NKiuZi2cv+OXvNj3x
aeUQcaIFUcI7/E8EETHKR57Ytv6mi86Yv0pn6fMz9pY518+J6P0ZM188NWNsWd2jW/ftaE66dIN2
OHhHa76/BaS04NLiV298dfOcxsoxD0iE6fszZr621v+gUoppp055asf+1xYpi8g72+yHbCJobZW8
dnDPxdMnTNmo0ViXvcpzzl/g+V4y4ZWku5O9zVpQICPu9IwOfasKFmid/VNdhktKCdKXSU4AiDrd
kbTphZ510lzuxXe2dbVXWPC04MhhqxGkjt6ePNNaKcpLykZ6SpTCWYVp62ivS8QSO/vSqVkemmg8
GmvrSyWrBIdCicifHmw4q7DW8sUP3cip9eMQ4Fh3J/++4jtkshmU1jBSCxBACT3Jnuq4F2vFqIiH
gFbat86PMJKMh6QA5xxLzr+MyWObAOjs7eZrv/weIoKGkVtG6A+y1jcalQXwAHCggoh3vPcckUUo
oKuvBz/cAu29nYHS/xzz59chCgEviJMu/E0QGTkLVEoFYF1pPO3haQOA0QatNFqpwCcKyEhIQRXw
GGIEb8A8I6ABrQPGrHNks1l865PKZAZ4fSeO9u5O0tk08WgMow2eMWitgy0jeUAz/AVJwX9HKIDw
y8kUgNYKUPT09ZL2M5TGEoypHsXoqlqqy6qoLqvM31seL+XD73k/+1tbONLRytHONtp7ukhmUgBE
vUgoGD1868zxGn72QMAVSmD4Exhj6EslyVqfc6eeyQfOu4gFp5/DaQ1NVJaWo9RAmFFTXsWdN90O
QDqb4Vh3B/uOHmDb3p28sGsbL+zayvZ9r9GXSeFpE1hCsUjFDdS4Jy746ABxYStm4BDQeMbQ3t3F
tMbTuO2vP8MHzl00aLFOHErpAT9b59BKEYtEaaipp6GmnrnNs/PX9x09yDVfu5GNO16kNJ7AueLK
URIiHGcDXr08uw6KtwAFTjDG0N7dweK5F/K/n/kGVWWViAjWBswppULwpwYpUIdWkdvnuX2vVOA8
x48aS01ZJb7vh32LXav0bwGkwAfkxixqXEFrTU9fD+c0z+YXt3yXeDSOb3084+EZ08+Uc5jQ+xdS
blsIgnMOkUAoSitEBCeCb0PmAzdeHB3n9L2T5QDFCUZ7fPuG5SHzFs94/ddFAi0rQzqTxhQIxreW
9u4OSksSJGIlgwSUtT6eNoHdDNdRH4c3AhwQfuuPkSdGRhs6e7tYfM4FnDVlJta5PHMQaF4rxest
+/jSvXewbssGfvaF/2bWxGkAtBw7wsLPXI0xhnG1Y5g89lTOnHw657xrNjNOnUrUiwRrLwiHxYZE
EcEROL6BOKDQCk6QlALr+7zvjPMHLS7IraHl2FEuueWv2P76DrxYnKzv99+D0NHTTU+yl90t+1nz
wjoQoSxRyuRTJnLR7Pl89H1XAWogYixKAhwfBocxWG4cJxjj0Tx+UoD2CjxczhpWbXiM7a/vYEzd
GHqSvYNCoWc8YpFosG3ipSiCFHnb66/y/PbN/HDVPcQiMUrjJdgiI8BQ5OEkiAdQtHNxzhHRhqqy
ivCXwUE6YFjBG5iviEOcw4UVmRwlonHK4gl836cv1YcebraY6xtifi/33bkAIxQjA4XCOhlg1jkK
0Jtw6dkLaWqYwO4Du4nESgZNYpRBoUHUAAFYcVjngtCpho8EJdwC4oLPwYiu4GoRTQHZbIaDrYcD
h1qwypypN9SO5sGv3s3SRVdzSvWofNyHwII6ujvpS/VhncUojacNOu/1Q6s5WS1gNrCAIXOBEyQV
cMGmHZtZsvD9g4ZQKtDq1PGT+Okt/0VXbzexaAwhOMqpSJRz1fmXsHX3K+xvO0xbZzviLLFYCYlY
HEEVjfwGkdAPd4XjgFCR6YCzjlishAfWPcryj/8LES8Sorh+LSulcBIAnIrS8gH9q8sr+enn7iDr
++w/epAXX9vG4y88zWObnmLrnh0YbShPlAUZpJCH3SeDvFz9HBz9iODEyIqQiMbZtvsV7lh5F//6
4U+Q8bNEjDdACFrpfE5+fBRwzhHxPJoaGmlqaOTK8y8hmU7x8DNr+OaKH/HkixuoKA+c7HDSYnES
5j4OccHJT3hleM1aS3lpBct+fDv/t/ZBol4EpRS+tYPM93jmIagbCAHktc5iraUkFueD8y/l8W//
kq9cfzN9yWTgc4a51sLtro8HBsW2IENVaGW45t/+kc//6Gu0d3fkCxsQCMkOIZC8YFBopTDaYIxB
EKwNCiefXfpJvn7DF+nu7QksaTgCoF8IOu8ZnRu2dw0SHU0sGuPLP/kWZ19/Gcvv+jpbdr0CBHUC
UyCQQrLO4uQ4S0FhTJAD+Nbnxr+8jsXnXkBXTxdGqeLX6kIp5HBA3iJy9wypnzdHuWJFVUU1+48c
4tb/uZ3b7/sBM5qaOW/6HM5qnsn0pmamN00hEmJ8IJ8AOcnF/IEONBdJPvUXf8NDT/++6NplfseH
/b2B7J4k1yoK3/eJRqKUhGnxsy+/yIbNG0FrIl6EDT9cxewpMxARepN9PLl5A1PGT2TSuFOHHFIr
jVKK86bPoXHMKRxqO0I0EkXkRMNjyGNY/9AD9kVO/cNuwYDiHL4N0GFpPEFVZTVV5VVorbES7G2l
FG1d7Vz1ub9l9scvYskXrufwsaODkqqcBVSUljGxoZFMJhMcXxXtBwJe++sBwwBCOTI69KlDODkn
DufCCBA6zBxpralMlNObSrLigZ8T82LcvewOnHMDtoITwShFXWUNYi2IGuZ+BS8wocJzgeIq8kop
Onu6UEpTnigLUmTn3iDxGehoRISsDZKgkpo61r30LH2pJIl4yXGYIehktAmcLideF3AEzjqIXIVb
YFhhReFnfW5acj3zZ86lq6uDzo4Oslkfowye9jAqwPYqfJprkADDPwktcSiskPutu7eHoA5Z7Hop
DIMFMxQpAI0ilU5xzaIrWfu9lTzw9bv56OKrGVVRRVd3J53trXT1dJFMp/F9HzeE1nzfJ5VOkTp6
mMXnXUBJLB5kgQW1Qq00mWyG3Qf24nmRwAEW458KfJ7XfyXEAcVsgDD0dXR3AXDZuy/isndfxNGO
NtZv2cQfNm/kxZ3b2HNoH23dnXR1dwyIYUopKhNljKuu48qlN/D5a28iX0PMKcwFFeItr73Czn27
iEdiRSZIEu748Fwgh3+cGyygNz1kmJzkYnnGz2C0YVRVLZfPX8Tl8xcBkMqkae/qpKO7nQkNjfn+
DbWj2XDnKmora4h43lBT5HOF7//qbtKpJNFYHGdP/KGKAQEviAIyuB5wwqMGUrPOYp1FK40JT3By
GaDWing0RkNdPQ119QO6e8Ywpjb4zVobnAkWnBP41ifiRXj46TX85P77KC2rwPo55k9YXQPWXXA4
WiCIE6Ug9lFZVp63AutssDOUwuiBhx4iMggO567pfCgN+nvGEPEirN7wOEs/fwNaG5Rwwt5/IPX7
Dl3oAop1giJCxET45j0/YPX6tXT1dudPeE2oTaUUQbbnBoEcIP+7Uv0JkWcMLW1HuPm7X+aKT3+M
3lSSiBfBORle1CrAPV7hYnJnBCdsVFaIRKLc9/CvuG/1r5k4bgLnTD+TebPOZnbzDCaOm0BdVU2A
/d/gUDNnOb7vc7C1hee3v8RD637P/U+s5mDLPkrKK9FK57PDYkmQHOrBBVEgvCDDezJMnFBWVoGI
sKflILv27OJnD/wCFYtRV1nDmJpRNNSPYVRlDVVl5dx83T8xrr4BgGNd7Xz2219iX2sLh462sPfw
Qdrb28BZIokyyitq8F2YRg/3+bV+SxckhMLirNFov5gIWEg57cQiUXQ0jlKB9+7s6aa1o50tr24N
wk3W59oPfCQvgO7eHu68/z5cOo2OxYh4EcrKKlDhgxV+odaHuUYAzxgnIgYHnrIuk0ymahPxeIcS
kJPwjKCIYAs8qmdMWB6Lg9I46w84/9NKU1NRRV8yidYaJ27Ypv5GpBBK4yXtB9KHzsC5rIfo7X3p
1KS66trO8LH4wUe3wyQpBFhKsL4/wAkK4PsW31pM/v6TTwJaoamvrG19rm/LJOBVrbVam3F+ojfZ
Fy0rSex04oKnpk5mHX5QG4LJEZ0vmNCJUBKN7VNau5SfqTGYNdqgfyXOsfXVHec2T5i42omoYSaZ
f5SUBA7TukDjflgnHLkZw3nBWXFq4rjGR7bu3D7bOodReqXuzVQ/qS0v7T966OIzps58qcSLtloR
jUPy8fJkNgARKssq8EwQ62sqq4L6QM5Dn/x5xTlRMeV1zztj7vpdh/ZeYXzZ1pupflIBxM+deI2v
7D2NNfWrZjZPe/r+px77UgTtCwwNzIelCYV1lg8tuoIxtfUIQldvD/c+tJKs76OVLgKJ/Kk58TM4
78Kz5n1536GDk3ce3rvEc97S1Ppd9wavzDy+QMeSu5+wWs67YNa7bzva2Tr+hZ0vfzymjJURemUm
3dsDYbkMrYmWVjBECWC4JApsButNOaVpxbQJk5/77frHvmIcT6dLmt7DwrUuAORr1/ri6WuNUx2P
P7fulmlNk1+YNWnqXRlxRkSUEiyFx0YnoSXKKymtqqW0qpZERXX47M9Ja6IEKyIqI9abMq7p5+ed
PnvNqnWPLdOOTnH62uNem8OwAhs9a8KlCvdbAfO+c95zq+cZ9+iGJ29MZdOjDDqs6JysBwpHhgSM
I8AhMRNtnz/nnO+Wx0t7HnjqkdtAaRF1eebZPQ/leC54cRKPtfjRORMWo9y9FiqbRo9becn8Cx/e
sOX5Wa++vvPi3mTyNId723IfvNenKInHd5/WOPGReaef/ewjzzzx3p0HX/+IdnQp9Ecym/Y8mOM1
16efcpYwt3Eaju9b5eZHxLimcY2/mDF56iallBxpa6vt7eupzfpZT73V7w2HJCLKGGPLysqPja6p
O6oUsvXVV854bf+eD6WxUU/0U2j+PvPM3m05HnN9h3h5On+Djp/VuNS37p8dbrbRhpiJtJeWlO5K
xONHFPj8GV6teXOkRMBLpVOjupO9TWk/W2udRaNf8Iz+RurZvfcA7njm4Y29uyYXtZehYw9OfK/Y
7JXW2oXipBmtIm+7VykFcOIrpbYbz6xRJvLr9OJdawpeme/nqYD+H8gXLY/fwFReAAAAAElFTkSu
QmCCiVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAmXElEQVR4nO2deZxcRdX3v6fu
7e7Z1+wrkA1CICQEAgiJkcU8yI6DICAqAoqAD4soPmpUfFBRQQUCCDzAyyISQRbRGGQJIUAIYQ0h
hCxknWSSyexb96067x+3u6cnTJJJgExPyG8+NdPTffveqjqnTp06dc4p4eNBmDzZY/bsIPVG8Xlj
S3IKY+Ndqz0EYTxGhomjvyrloLGP+bzPCKRNhGo1VOJ0GcrrJseb39rQ9nrdvW/Vpi+bPNln9mwL
6E4/aae/V1FhmDHDApR/84hCE40fJ3CCOr4ghv6IiQDgHDhA1X2cin6mIADiYQBjwvfUJdRRKYZn
Ff7h4tFZ1f/3UgMAFRUeM2bsVP/uOAOED7MAvS48uL8x3oWonitGhqkAgYNAnYqqgqcCmGTNZOce
+ZmDathLCuJAwIqK4ImRSNiZ6nQZIvc5Z/+86c8LKoEOtOkqdoQaQgWGGdjSin2KI+Xll6F8RzzT
XxMWtZoAFTX4zggG8JzXnBuLrcrPzVtbEM2tyc/J37xHCGwDqmJUtDFoKW5oaylram0a0NoaHxwQ
FDkBcYpxWBAnnkQk4qHWVSLcmqiu/lPNjOV1VOAxgy5Lg64xwDQMP8cB9Lno4JMRc50YGa1xizri
ikadBwYhP5q7dK8+g2YfNmLcSz845TtLSnML65J38RMkckkE23jQHhDxiRBpBRLJdwqu/dtNw55f
/OrhK6pWTWpsaRpjDRgLosTFSFSiBnW6CHU/qrp9weNAB5ptC9tngJRYqRgd7VuWd50iV+IUDWwC
xLM+xldpGdir/6wzP3fSjKtPuOBtIHrd32/a74XFC8avr9m4b0Nr44B4EJQHQaKkS8/8jMMzXn0k
EqkuzM1b16ew1weHDDtgwa+++oNFQOPds/8+6vanHzj9w42rjk+oLfHC8RQX30QxgqC/37C5+UfM
WBTvypSwbWKE4sSWfn3C4Iiv90vETHJtgUVxzpOIAIPL+z82/fyfTT9sxIRVv3/qjvEPz33q1DWb
N0xKuHhfC0h6PttD9x2CKCqghNNpBK+mb1mfuSeMn/L3a8+48uV1NVXlFTd+51tLK1eeZdGosRog
iIn5nibcC4lAzqm557XVKRpu9TFbrUCSe/pddOhop+4RRPbVtiCBiOd8TGEs770Ljj3ruh+ddPEr
V9336y88+dqs8zc31R3qRDFOEAURrELYij0jf0ehSDhs1GHUIGoUUaEor/CdY8Yeec/t5//yqQde
+Pu+P3/kph9vbq6bYCyKaiAxP4LqYiPm9PW3v7poW5LAdProadMMM2bYsvPH7WfVzlTY17UFCRWJ
OIMZ1nvIQytumvOViSPGbxh95XF33D17xu2bmuoOxYFnJawG4BRPFU/BKCFP7CldLkYVzymeCoKi
xorFobVN9Qf87ZV//X74f3/+gdZ43F/yx2e/OmbQiOnOgAoR12bjCvtatTPLzh+3HzNmWKZN65TW
Hx2ViiBo2UWHDfRc4lmQkRq3CTUSEQ971H4Tf/noFdPvOfPG75373PuvXJkIEsW+FdV2abUHnz4c
Cs7DGJG2g/YaPf3p//l/t1x53y+n3vfi479ygS0UJ3GJmCjoEmsiX9h8+ytrU7TNvNGWDCBUVJjh
DW/4NQOKnza+OUpbg4QafPG8lm9MOu3713/tmmcO/dEp05ZVrTpLLBjEKni7sPF7kISAVfCspwwq
6zfr7ev/efWfZt476rpHp98cBIne4iQuMS/qAjendF3dsUsLxwVbGow6jtikda+mf9F1JiJHaVsi
gcHDw3198qlXX/+1a54Zc9XUW5ZWrTzLWKyAKuqF99tTdnVJ9r36Frtmc+Vxw747+d7Lpp639JqT
v/NdzzMNalxEWxMJE5GjavoXXReu5io60LxdAiS1xfJvTjjJGB7XRBCIiFiDN2Xfib/42/dvfWDM
FVOnr6tbf7RvzZ5Rn2UQCAIPvzSn8K1lt8z+xjUP/Grinc/MuClUJVUl4vvOcXL1/732RObKwKS/
PxotO/vQInC/wzlQUWvU26f34If/9v1b755w9YnXrqvfsIf4WQoF37fYmtb6sftfftyNvzr7mlkH
Dh093Rr1UAn3ZHC/Kzv70CJGoyQHf8gAFRWGn+NM1H7P+GaEJlzCeUTyI3lL5v/68WvPvOGSr63Y
tOYMP0jO990v/faUToqC5wcSVNZvnHzUT77y/Wem3X9T34Kyl5xRXwONG9+MMFH7PX6OS00FkjQZ
av75E/vk2sTbqPZGcWrgv4//+jcO3/fQ9Wf/4dJHg8DmJ+eLPev57IYCqh76g5Mu/toBe4+s/tqf
rnzEBTZXBBDZ1OJFDmy6a14V0xDDogoBNGYT38aXPupcEBjnDSrv99SPKy57+bt3/PgncZcoEFVV
VJQ9P1n+I6ji1Hk3z7z7J1PHTlq9/6Bh9zmjRp2z+NInZhPfBpRFFSIAvStGF9jc6EIjMkStQ3y/
5e9X33bKIy/9e9i9c2bcaqy4PWv8ngVRnI2ombLvYdc+cvVtTww4/5Cn2hKJ3sYYnOoqryU+ZuOM
RY0GwObHjjMRb6haF1gfGVTa55kj95uw6okFsy4I79atbdmDnYAKYNFXl7x5HhAfMWDY352HYF1g
It5Qmx87DpJKoHGcSDh3iHHCV4444eHrH71tQm1T/ThjRQFDFig5e8oOFDCeE20MWod865YfHnvd
Vy5/1HOmzSkeoEmaY4rPG1uiqkeTcOLAz4vmLP/hly9+6+GXnjrZoSJJs+Me9DAohDsI6IvvzT/1
c2Mmri4vKH7DeRgSTlT16OLzxpYYX7zxIgzAqlNP2bvvoOeB6JrqDZ83Coqa7mfnPWVniqp6nkOq
62smLFj2bv/9Bo34DwJY50QY4Is33hDYQzDiqTpnFA4dPvaln8/40+iEjfeW0GosWdCWPWUnizic
FRf7w+N3HHLO5FPm+RbnVMGIR2APMcA4FFTwffym/zn9e+/PXTh/vBMFtu5IsAc9BAZVlCWVK8Z/
+Yjj18SisbUqSZ0OxvkqMhyrKBCLxtaUFhbWV9ZuHKVJbzLV7qv7JwoBFIwxiGxlWaOKVQe7S5sJ
hQAWqho2DweC/NyC5U1trYPVKioy3Mdpf1RwBvKjeWsBbWhuHCSQ9k7eLaAgIjS3tZAIgiQTpCgd
vjZiyIvldmMlPwUoIiK0tbYOBGLFuYXrNtRtCmM1RPv7KOXJoA2Tn5tfDUTiQbwsPf/vJiwgCIkg
YMyQUfQv7Y11jpQgCKdEoamthTeXvxtKvd2k3QAoJGxQVFmzMb80r2Bj+J46oNxHNYZgUaUomlOT
SCRygnhQEg4O3W3EoTGGptYmLj/pm5w56STChnWk8tJ1H3L490/B7VaiL+Rz5zTn5fdeLSzMK9wU
OukqQMzv1qp1A6xzqCrWWTwT7mo7VYwI8SCR5PfdTQRsHX6HEa4Zf3eTkZ+GAioYCZXAVIGQ1On/
d8e2ZyLlEJZs42dqgyckdHfXIrvgb5Xbd7dRkG7PdjhAt/i7OyJDAvianvU0HUimGu4s705QFFXd
ug2g/ardru3t8HA4VB0pA+9nagoAMHumgA7YMwVsec1nTAncbZeBIoKQ0vbBMx4R42Nk20LPMwaD
JB2glDDkKZw+dLexi7ejowRIKwH0uFEgIqGdH8GpI2EDEkGCwAZYZxEMtqGWeBDv5Nvhul9VaWhq
oDWRSN/T9zx84+H7EXzPwzNeMr6qnSk+whiZVuZsREcJ0NniP9s5oL2HjTEYMSSCBA3NjSSCBLFo
lLLCUvr1G8LA8r4MKOtL39Le5MVyOWTE2PAOGZIgZe8e0ncQD/1wOtUNtVTVVbN64zrWbVrP2s3r
2Vi3mZqGWhqaGglcgCce0UiEqB8l4vuIhAzk0gyRaUzKtr5sr08PnQI0PdobW5poS7TRu7gXhx00
jkkHHMa4ffZn/6Ej6Vfam4gf6fQOJmM1kFoZFOTkcfLhx33k2sBa6prq+bBqLSvWr2L5+pW88+H7
LFmzjFUb17G5oZZ4IkHE98mJxIhGopCURNmOzpXArBYAoVhubGkkHgRMGHEgX51yCscfMoXhA/b6
yNXpUYmCaijCt7EUtM6mt8BFwIjB9zzKi0opLyrl4OFj0tcGNmBt9QbeWbGYt1Ys4pXFb/Deyg9Y
W70eRMiL5WSn3tDRDtD+XiefZxWMMahzbKzbzCEjD+T7Fd/m1MOn4nuhTT+08btQHxABCUe3twPm
v9T+QCY0uSnWPu+HEsT3fIb2GcjQPgM5YeLRAFTX1/D6soXc/MQ9/HvBbPJz83EuuyRB5mLHT78y
nVyRJVDA9zxa2loREX5x7pV8/8sXkRMN804G1uIlHT1SzPBJQkgyU/Jve71CxkjN+54xlBWVcuy4
o3hz2bs88dIsCnMLs2sq6HnLQCXi+TS0NNGvtDf3Xnkjkw+cCISE9z3vUyF6V5BiiEwJkwgCjDE0
t7X0iI0HPz3hqWYsA133+4IlFX3P82hsaWJwr/784xd3M2rQMAIb4HUj4bcFEQltCWLa+7G7+zKN
pIunag+QAMl5Nh6PU5JXxGPT7kwT3/eyt9ppZAvNt4Ps7kkRWuKt3PP9G9l/6EgSNiDyMYi//c0g
Omjt27t2d0D7MjDL7ECe51HTUMs5R5/GaZ+bSmDtThE/tTLwtuUNnIEtr3HOhS5i0tG83LWHkxV9
mUYqSWtPUAKDIKA4v5BrzrwERTsYbrqKFOFTukJrvA3PM0S8zo1DrfE21lavpyivkMK8AqJ+JLQ0
bnFdiqmMCGKkR3vO+imR51RxSS3QdefGh4BvPDY31HL2F05l38HDcM5hzI7tXLvksmx55Sr+Nucp
Xl70OguXvcuvLvwfvnzUlzr1CVy+fhVTrqogFo1RlFdIeVEJg8r7M2LgPgwfuBf7Dh7GqMHDKMzN
76CAWmcBwWTsNWtS+cumTSQL4EjbMkI7QLZBwwoahNOPPH6HOzB0Zg4J+pu/Tue3M26nunYT0WgO
8ZZGmltbtvnltkScxtYWNtVuZsma5QQ2QK0F41GYm0e/sr7sP3QER+x/CEeMHs/44QeQG8tJ3yKw
tp0RsoPu20TWMYCI0JZIMKBXP47Y/+D0Ll+XkVT0rrztF9zw0C0UlpTTq6QXYgybrN3uvYx4RHzB
hGbE9JyvKNZa1m6qZFnlSh57cSZ5ObnsM3AvPn/g4Xzp0ClMOmAieTl5YTV6AvXZUgnMgu1gI0Jb
vI0RA/ahT0mv5KZa1+bYlFh/8pX/cMOM2+nVqx+BtSSC0G6gbvthXymJE3bFRy+O+lFyIjmICNZZ
lq75kIXLFvPnJ+9nxKB9OP6wL3D+F79CxPjZpwSmkM1KoIgQBAEjBu0FgFWLJ10z+KSUsfv/8wjG
85M2mE+291UVq+0xs7nRHPJz8nDqWFa5kt8+eAv3znyYovwiCvOLkvpB9qKjJTCNbrReKeAcg3v1
D//tYjWUcLMosJYP168h4vk4Z1NKQdctcl223IXM5tSFzwFyozEKcvJojbfR2LqeqB8JpU42wdn2
9unWJEAWiKySgqLkqx2rTGonsH3kf1qN+eh9nXPpFUvUmKzR/reFjhpRFjFr+1q9a/N/GP8Wrvv3
7j+EIAhCRa4bkE1Lv60iWT2jGdKxgyFQu6+gSsIGHWvapTaF11ZMOgFnA5AwgX7aQ0u3f7fubPen
3q+ZbUz+zdq4gNrG+h3+jmc8VJWTP3cc5039CtVV60CEiOdvOzHEZxjty8BM8Z+xTNjlUAWEdZvW
Ax2dN7sKQbj9iuvpXVzGbU/eT11TAzk5eWgi0VHMdfr8bXy2uyCjjVt4BW/JBbseqg7jeyxd9yHA
dv34t0TKOzcWifDbb/+Ec449nRmzn2Luwvm8ueTt7ZgUNB0XENYlu0y5nww6HinYLgEyfdm7cRQ4
p8T8GB+sXk5NQx2lhcV0ZRs3E6lrnXOMHTaascNGowobaqrIiYZm244WwVDqoEpDYx2JRBw8n4gf
IepHiCQ3hVQVl8wv0EG/7En8sVWXsMxGdGODwtEbZXVVJfPee4MvHjIZp67LxqBMhHlxHc4pvufR
r6xP+rNMhkoZkPbqN4SHfnobi1YtZfHKD1iydgWrq9ZRXbuZRKIN40fIieYQi0QRaU820ZORdZZA
CMV+ECR4fO6/mXro5/k4Zw4aMaQcfVMjd8vt2xQz5OXkctqk4zkt+b61lvU1VbyzfDFvLn2Xue/M
581l77FuUyVOHXk5eeREc5JMlkVr6B1AVoaG2SCgILeAR1/4F9ecfQmDew/YqS3hLdGVaSQVF2BE
8DyPgb36M7BXf6YeOgWAqppNvPD2PP4171n+89ocVm1YQyQSoyAvPz1FZD0y1ACTmWk+he7OeO9Q
IpEIVZur+M1fpiOy66JsPBM6mxqTzI+tofNHYC2qSp/SXnx58pe46+rfM//P/+L2q67n4JFjqKmv
obm1Jdx0ytKfdtq3/3TMAt7OAd1bCKNuigtKuPOJB5g57zl8zyewu/bg6VTuoJRXUWqFYZ3FOkef
knIuPPEcXrz5cf7yk+mMGrQ3NbXV6TxE6T7t7v7cgr6ZhrHsNASlKijg+T7f/M2VLPpwSbcwwZYI
GcLDS64KUkEpZx59Mi/e/BhXnvkdGpobcdYlXcO7tbod0cnGZNbuBQA464hFYmyqr+H4q8/l9SXv
4Ht+etOlu5EZiRRYS1F+Ib+7+Kfce80fwDkCG2QXE3h8hMbZOQVk1MdaS0Esj8rNGzn28jO586m/
hI6axmQNI0AYuhZKhIBzjj2N+358EzYRoE47pp/Lgikg871OzgIIsqCmHWsduIC8WA5tNsEFv7mK
k675OvMWvZFmBAhHYHfH4EkyYDRhA045air/e9EPqW+sxTNhtpEQ2cUBW5EA2v10T5ewLtZaPDGU
FBbz5NynOfq/z+Ccay/l+Tdewmlo6EmZjQNru9VI43se1lkur7iA4w6dQn1DXWjI6u5+TekAGe9l
pxK4FaiGjpklhcUYY3hg1iNMvepsPn/pafzh4Tt4b+UHaJIZMgNBrLOhhHCO1HLo04TQ7kz6s29c
ge9HQunUnZuRW2m2n+EdhEu9VrrmFbWrkezAILAgUFJYglXH3IULmPP6yxQXl3LgsH2ZMu5zTBw9
jvEjD6BvWe9OY/4/baTM0IePmcDRBx/JzFeeo7CgKPQn7I6+Tfado52+SpaagreKLaaxwIYyrSA3
H5NXSCJIMPedBcx5/SX8SJTepb0ZPnAoY/bZjwOG7cvIgXsxYfQ4ivMLt7rBFIaCpZJMfDwfAucc
xjOcMeVE/jn3Px9tw67E1iTArq3FpwPnHI4wVKsgLx8jYVKGmsb6UDq88TIYA21t3PfLOzjni6eF
7mOdhJeHoWCmw71T7+8oUt+ZfNARlJf2oiXeGr7XndJ1Cz253Ss4s1Yp5auHQQG1FpfUdiKeR9TP
w+QV4Hke1TXVna4UUtJg5frVTLvjt+wzeG8O2HsUE0ePZ0DvfgA7tReRsgEM7TeQkYP2Yt6iNynI
y+/21Uqm/99uIQG2hvYgj6Typ65TPUwJp8j65ibu/fffIEhgIlH6lPbmCwcfwVVfvZhxI8bsFBNY
DR1V9x0ygpffno8RySp7W8dlYGduYbtL6UpnGENJYQnFpb0ozC+ivrmRB2c+yqRvn8xfn3kirdjt
CDR5/d4DhoBzhI4n3dwH210G9jzpv310kRGstQRBENodjEdpSTmBKhf++ioWrViCEbNT1sc+pb1A
Jev6tkfZAXY1VJVEkCAvlkt9fS13PPFA+v2uI+lsEs0BI7vEDrEjSOcH0PQc4KNoUnR1n+UipS1/
UgpTOl5/2xd16gSasAEmGmPeu6+H7mmel9YbtofUNcYz6Xp0qxuZc6jTtEDMSgkgIjS1ttAab8X3
t5/h+1OHht7CmxvqiCcTSe/oKimwFlz2nUbWearYjp7DuxRGhLa2NibuN466xjoWvf8OkbwCcnNy
Qdn5aNuuKoRbuWZnB23qa00tTaESmC16QLIOWScBjPGINzdy6uSpzLvzKa67dBojBg6lvq6W+mS0
kJ+M9NllEIOzln6lvYhFoknn0h0by2s2rv+UKvfx0PkysLuXbGJoam6iIDefa867jFfvnsmD197K
8YdNQYC6mk00NTcDITN0SAC95UjfmdG2xZIp4vm41haOm/j5ZGKIzu0JncFLTl8frFwGppt3BDPb
lyxbRAZBuz/Alj2xqxAqa0ZCB4t4IkF+Th5nHXcqZx13Km998C5Pvvg0/3hxFu8sW0xdfS0Yn2gs
TNPubaFsqWiGD9z22yPJwW0QJLmjuLl6A/uPHMNFp5xDKidw11qiiBFa2lpZuPx9/EgU67prfu08
ksXv7M3sQGie9ZKeNikr3NgR+zN2xP5cc95lvPXBu8x+42VeWDCXN5a+x4ZNG2hsaQ7b6vv4XliM
ZxDx0gTdFqw6rA3tAEEiDs5xxEGHcfdP/kh5cdkORSk5F/oFvvH+QlasXUlOLJY2DGULsu+8gE6e
nWIEoEOkz/hRBzB+1AFcfuaF1DbWs3Dpeyxc8T7vLn+fD1YtY3XVeqrra2lqaSLRFkcbG8Owr48+
InwOEPN8Ijl59C0p58Bh+3LipC9y+tEn4hsvnU5uRyAiPD5nJm3NTeTEcglc9zq1Ah0svh3OC8iG
uJDtTT6pSB8FNJnF0zOGkoIijjxoIkceNDF9bVsiTk1DHZtqqqlpqKOmbjNjRx4A0EGMp4i6z8C9
eOWupyjML6SsqJRYpD2hpFO3Q8vRkFkM1XU1PDTrMaJ5BWHQSZfv8OkhUy3IXgmwnecLIBlZPNMb
PxqutY0xxCJR+pX1pl9Z749+v5ORnBONMXLIsPT/qUBQk+Fu1lU45/A9j5sevotVa1ZSVFoWOrJ0
F1LNzRzlbC04tAcidfhzh5jfTCunhn+35+SReXT8zi41bfIcgzeXLOSGB24jr6AI253E3wY6yQ/g
Z7zuDrvVJyd+2k8Hly43ZWdyEmfCJh1Nqutq+PrPLqO5rZm83IIsSBendMwWHSL7jo9PPrtb8xXv
JFInmNQ01FHxw2/x1pJ3KSoq6fZopg7oEcfHq5IbjYVBoc5hk4GZ2QrrbHrOX7JqGcddeibPzZ+T
fcTvBFmnBKoqJhLl3eWLWV9dRb/yPh0+S6dplx3I2/8p1TMl7lNex/c8+Vd+dPMvqdy8iaKiUoIg
y4i/ZVwAWegSZq0lN6+Ah2Y9ztPzXmDK+CM4/shj+PzBRzC474AOadrTx8RBe95++XSy92euMjJP
KFPg3y8/xw3338qsV54nmpNLYUFh9hF/K/BTO+SKoi5lCG6PJ+8OqFNi0Rg1DXU8NPMRHpr5N3r1
6suEkWOYNOFIDhsznoNGjaG0sLjTg6NSy7ewDeHh0Sm22N4BD9aFBz2lvmtSZxJvscpYs2Ed/3rp
GR7816PMeWteGMNYWIxTFxI/2/Z903Bp6manHSCJcE71iRaVAFDf1MjMV55n5pynieTk0q93f8bs
PZyDRo9lzN6jGDV0GHsPHEpxQeHHCgTpzM5vnaO6djPvLn+fBYvf5oXX5vLyojfZVFUJfoS8/AIM
grUZmn72qizZPQVkIhUKBuGuXzS/KJ2mvbJ6A6srV/OvF2aBMeTmFVBaUsbgXn0Y3HcgA/sNZFCf
AfQqLqW0qJiSgiLyc3IZMXQYxQVFHWz6qddNLc28+OY8aurr2NxQy5qq9axc+yHL165ixYa1bN68
iURrC/gRojk5FJaUp/MDdfcib2fRuQSArONgVcVmdHNm3n4lZJSq6k2sq6pk3tsLIDUaRRA/QiwS
JdHazF9/dzenH3Nih8AQRRGED9eu4qTLziYeJJLOGxpu4fo+kUiESDSHnJx8lHBzqqfM8x/B1iWA
aBAEWTt7ZWLLvP0A0UiEWDSaPt0LkvqMhgae1ngrtlPGTjbZCNG8fCJoOjoo/H57yfZl3bZgrRMR
6dADRtW1keyB5ubm4sLc3FbfM/Wa2j/vCSWJcNvYYoOAIEgQBAlsEOBcEIr5tGPAlsi4h3Pt37cJ
rA1wbgs7RHe3d8eKqiqCxCceOKGhvqmxLG0iV9dmUKoBI05pamkoB+JRP7IZss+Bcavo0ODOPg9/
pTyDt34fOn6umeWjDNdToCi+59Xv3X9wU219fe9kGwxKtTGeqYRwmdTQ3DwAkMK8gkoX9lp2eS98
Auj2uLxdDwXIjeVUAm21jbUDwklAMJ6p9NWyFE8ORqG5pWUIkN+vvM/7q6oqj8mC1eAnhpT0394A
7qGDfKsQUItSXly2DJC6hsa9UMLkq5alxqJvaHihDVxQeM0tvxo+Yb9xb3ihv2h27hXswY5ARIS9
Bg1589kFc/u1trUNFcQpYNE3jGDmY50VRKxTnp8/97A/XvXzhb7n16qqdDAb7RZleyJg9yoKxlOx
l375G/P++OAdhwRqPYMQ0tzMN21R+7qi6xCMUVi6esUUoKl/rz5zHU4Fdd3eik+sN8I0tNtGFtTz
EyqCOqtWS4uK35x6xJTVby9ZdAxOQTCKrmuL2tcNs1fWCvIMRtSAbWxuGnXrI/eMOmnSsY+FVvTd
bBr4zOmAIoeMPuiJD1av6F21edMhHuIwooI8w+yVtQbAOX1SFRHEWXVm+l/v/fLvL//ZS8W5BYut
OiQ1cHp86cImV7fX8ZMpojirKrmRWNXjN9zzz/N/ccWJcWvzRcWpIs7pk5Ac3fGc/Flq3UpEfE9F
V6xd9V+rqtaVffHIyXcpO+BP1QPgVEP7fadlO8zRoyCqqBw4Yv8HgfjCD96rMIriiafWrYzn5M8C
MFTgMXtRo3hytxoRQYJ4kCg+4dJzLrrvF9OfLCsoeStw1uwuUiDihdHGET8SupiLwTfhe7nRWLfX
75Mb/c7Li+WunnPX3+895qIzzm5saR5ikAAREU/uZvaiRirwfGaggLTa5tuimnOxIL0NYpesWl5x
12P3PTLtgiuuveIPP3vQOU15i/ZIceDUgRFWVq5mycpltLS14Se3fh2K7/ksW7UC6F5fiE8Aqog6
lK9OPe3XVZur8l9euOACCdNAei6wVXFpvQ0QZqTOYqnAYwY2OnHIT8SYX0jg4gEuWl5cumD902+f
dfh5J1wy/723LouICXRbO4jZDGn/44npIO4l+St0RKXjAVo9CQKi2ATOGzFor4ffe3TOD4efdPgt
K9ev+S8fk1DfRNS5n8bnrbo2RXNp/yrCocMLcjT+moqMENUgwPkHDt/vtgUPzvrt3l+a+OfVVeuO
johnFd31qTc/QaRP/UoROfX6U3In21UQxAZYr7Sg+J2qZxd+5cRLzz1j5ivP/8wXE6iIJ6pLWyU6
gVeXNpKcMNKBNYDw6tJ6Z/QqTHjcqofYhR8svvDb/3vN8SuemndleUHJWwmsJ0jP3RMl3BqWlLuX
CCb5umcTH2txXl4sd9WLdz763Rvu+/OY/8yfc7UnEgo7I+KMXsWrS+vJYP/MNb6lAi8+b/UTBO4G
fOOj4gC594mHfv27+28bteG5d75Znl/0VsIFvqhYeqiVMHNfoMMmXw8tothAnZcby1n11I0Pnrds
/crotOnX32yty0PF4hufwN0Qn7f6CSrwyDg7ZEumFyowvDHcj5bEnzaeHKXWxRWinm82/fKiH1x8
xde/88HQ4yfcsLZq/RRfjEq43DDtt+qJk2dPQns/p2z6gVpTXlTy5nN3PnrZyvVro2f+4KK7Wlpb
h3oQxzNRZ3VOvDZ6LOOWBszomABoSyufMgPH0qVtnu/OUuuWiJGoKHGbsL3+Z/pv7rz8Vz89bOU/
X7vgoFH7T1dwVq0RcJLajM+CEbF7l/CXgLXqjFVrRg7d5y8bnl149tNzn+93xlXfur+ltWWop8Qx
ElXrlni+O4ulS9u2JH5nDBAywTRMyytr1qo1p6iyGiNRQeLO2qLpj9x98xHnfumS1x74943TLrry
a0X5RQsDp8aqiihOujXF1O6NcKDhnKoknPNyc3JXXFjxtYsXPfLCj0/63jmn//Cm6/6vLR7v56nE
1UhUldVqzSktr6xZyzQyjy3JvOdWkFoaHjpktCqPCLKvOJdQiFgcfct6v3jXz2745dQjpqw+8dJz
K+a8+eq5jS1Nw9BkDD+4MOGKirY/pyfrWbsSCqmksuk+NDZ56ERuNKdy7MjRf3nxnifuX1dVlT/p
myf/4MP1q0/wwmMq4mpMVNHFIpwef3XVohQtO3vQ9ggSKgwTBgyOqH+/GJmEdVYUDcT5EeM3Hjhy
9P+b98A/7wHazvnxJcc8N/+lk6qrqycG6nJUNTyJW1KnaOxBVxBK+9SMGg4fDxOUFZe8fuiB4594
/A/3zAQSR19wxlkvv/Pat9ri8V5JGw14xlenLyQkOIfX1q2Gjkrfltg+TVLcM3p0NJLXeJ0IV4Zj
W+MOjTpVcmOx9aOHDX/s+it//ujkcYetXbB4Yd/f3HnjhEXLl02o2rxpWEtb68AgCIqdupw9TLBt
KGBEEp7n1+XEYuv6lPZats/gIW9ectb5r049YsrqFatX9zrvp5ec9PaSxac2tjbtY1QwInEViWJA
ld8nmgt+xKJF8W2N/BS6Sg9DciM1evDgkxWuEyOjsZpmBIsSMaatvKTstTHDRj77rYqvz6s45ktr
CaPNojU1Nfn/mfdCUY82IOwCOOdk4oHjGocP2qsRaAPk2Xkv9PvTg3dNeH3xu0dv3LxpYsIm8kXB
ExMS3hPU6SKBH8UXrH48eas0zbaFHRmQKd8Ay8H7FEeJX6bId0SkvzgFpwmHeg41CHjiuVg0tqYw
P39FWXHputKCwo2FBYUb9eMcBf4ZgCDa2NxcVttQ16emobZ/fUPj0Na21qGBWh8Fg6hBAoxE1BhU
XaWgt8aJ/okFy+toPx6yS4r4jhMjQ6zkHTykf6BcqOrOFWOGiRBuObgwHbHT5OHUAsl16w4/7rMI
Tf4WTZ0+hhpEk9uX4YLbuWUi5j5f+HPzglWVAF0R+VtiZykSGoxSDxtVXhjNyzkOvBNQ9wWQ/hiJ
hHTXVKsse0Z/FyGQCkQWCRnCaQK0EjHPgv1HvLl1Fu9XNwApwu/U8vvjEkSYjMds2qf2scUlnlc8
3rP2EETGYxiG0/4g5UAsWck9jNA5Un3TBlqNkUocS1F9w3refGvrXuetutr01ZPxmY3lY9hd/j+V
1xL7iTEQ1wAAAABJRU5ErkJggolQTkcNChoKAAAADUlIRFIAAAEAAAABAAgGAAAAXHKoZgAAUK5J
REFUeJztnXecFeXVx3/neea27Q1YytJBinTBggpGsfeINWisRGM3URNjEN+o0Zho1MSIvSZK7GAv
YIsgTem9LbDA9nZ3753nOe8fM3O3sLtsY3eB58tn2OUyd2bu3DnnOc855zmH0FGZBgFMEJg+VwHg
6v+VfNmIlIAUg7Ule4IwihSngjAGGhqE7iSoG2tmANQ+F284wGASRKx5OxjbICDAWMiSCsBYLGy1
pVLplUUv/lhY632EaRMkMFdjOnR7XPje6FgCwiBMnCAxt6bQp157WJZP8RhmOgbgkcw8hECZZAlA
kLOnZoAA1uz8bjC0NoJA3vMmyJEezWBbg8E5RLQCoCVE/HVU0sKCJxdsrfZuwoQJEnPmKhA6zAPa
MRTA5MkSADBzpvJeypw6boiCPhWaz2VgpPDJEBGBNYOVdoScoUHs3Ewm57MQCB3lcxkONBjsCm/1
544gIAgkBUgQmBk6qsIELIGgtyTEBzlPzV8RO0odz3t70b6CMnmyxBsztacR064a10OSvpCIz2HG
4cJvSdYabGuAWYHBjoCTaPdrNxhqwgDr2DNKJMkSICGgI7Yiwjxmelux+E/+M/Oz3XcQzp8s2lMR
tI8QTZ4sMWQme/OizlPHTAJjCgNnCZ+VxFqDoxpgtlsg8B3GzDIcMDTlGaymEMgin6sMonYxAe+C
8PKupxZ+CsDxd62YTO2hCNpWAUyDwD1gb8TvfOWYSSzotyRoEiSBIwrQTRJ6BsDurAxctb9gYx8Y
WhFyhhMNOK6mmi/vddpZpQwEWeSXgGKw5k9J8192PesqAgbhHlBbOgzbSkwIk6tMnRqCTwSOKA0w
g/Yq9LqasEsmV/rJm5YRAIbQpC1hlTJYkLEEDC2BQSDSilVAEQeA6s+b88x5yoEAdgch0eARmTVA
RH4pwHUogsmTJWbO1GiDZ3ffKwDnwygA6HLFYYdqwQ+RJU4BXMEnZoBkA0fwbqxgAmnh3BOpSAcs
/664YCg7PSFlY2IgPn9Qz36r/dJn90nvWTB+0GG7S6OlUkppFICh2SilKMEXVKt2bkmYv3pJD8sn
1fItawYUV5al5BbmDyyLhDMrohWZChxkYhAThAYIUHtXBqzAriIAg239odB0+87nFiwDUEN29hX7
VgFMm2Bh+lw79ZoxyRbTbwDcTlL4GyH4TI6fPyb0QhPi/cGNGUlpy/p37fPj8YeOX3HK8GN39sjI
LAHghQ2943k33Qi/oTXw5ERX+8kAZDgcjvtsxXdpsxZ+Pmjp1jUjdxblHloSLh2kBMtayqAB67ZK
EbDSEQAP2cQPF8xYWOTJ0L7+YK3LNFcAp0N3+uXok+ATjwm/HKgrbMebT/UIPoOJoDUgtWAIJsT7
Qxuz0rt+d8KoY+b+/vRfrfL5fGXu3j73p4LzhWgAlvua//v1i5P3yWczHJQc0q1/eWoosQyOzNio
Gt29LQrnGQw8/cUbfd7+4aMj127bOKEoXDJUCZZCE4R2M1SoHqvAlQ0RtKAjag2i+sbdLyz6uLo8
tfbnan0FUM1s6XzV6GkQ8h4wwLayXcGv65xMDNaChRaAn6yCrLRuc88ae/zs28+Yutrn85XCEW4L
VTfa+mrlvE6fLf0ua9W2dT1zSwo75RblDai0o/G2UvHlkfIexg9oaDHsmKN+6c8PBQK7CECn5E4r
k4MJBUN69Vs3uu+IHRccceo2ABH3HX44z2cUQOD5r97s9ercd45fs2PjiWV2uBcxIDSxGy6sSxEw
mBVZ0nISjdQ9u55ZNB3APpkStK6MuBeYccmYriKI58kvT9KVtnZcI1TnhyVAa3JG/ERfaMOQrEGz
7jzrmk+OHXz4Njg30wJQCUAsWvdj+rNf/nfY4s3LD8stKRhQWl7WLwKV5JgOVS5ZgKr9bjC0Dp7z
z4swERMkqCIhEL8hNSFpwyHd+iy++JhzFp426rhdACoABOFMFSrD4XDiNc/8/rgf1v94am5Z4TgA
kJrqnxowaxBBBCzBEfWxrsDlua8u3NHaSqD1FIA7V+l02Yjx5LNmwhJdudK2QWTVtTsxNBOEkox4
Gdx69KDDXnzxur9+4vP5SgDEwdGikc07t6X+/j8PHbt488qfFZYVDYtoO9lxtsQ8sExVc7PqoUBj
ABhak2rDS42ws9CiSjlYLCqSQglr+2f2nXvTKVM+O3nUcdlwhNwPIAxA3PHaA0e8Pf/Ty/LKCw8T
miAYiqv8V7XOyjYFLAu23sFRe/LuF3/8tjX9Aq0hJLEQX8YVo68Wkv4JhsVK1zfXZwCsJAsLsmxY
1iGvPXvNg6/36tI9LxwOJ4VCoTAA/Ovjlwc+O+e/k7cX7DyyUkU6AzGBrx5uMWm/hvamKhfFeTCl
Fs6o5IcsS0tMXXTKyAn/fXjKXQsAVESj0XifzxcGIC957MbTvl654JdlqiJLKgKcgWxPS5lZkRQS
BFsrvi73uUVPt1aosKXCQ5g2jTB9us64fPTNwiceYZsB1hpEArXW4xFDa4Jgweie0uXTO8/89YyL
jjl9DYAkOGY+//al+498f/EXl+QVF4zVgoXQMaFHTOiNyBs6Et5zzrF/MRGYXWc2mJDoj1s3bsDI
11+/5fGPAJS7iqAkOzcnbcoTt/xiefaaSzVBSg3FDFnteO6xWYOEIIugo/qW3OcXPYpp0wSmT2e0
QAm0RJRiI3+ny0fNEEH/1boiqsAQdYkoAUoJln7pzztp+LGPPv/rh2bDmSMBQOS3L91/1PuLvvhF
bmnBODeZpxHhE4OhQ8PEYCbHeNWCkeiP33DUwFGvvXbTYx8BiESj0aDP5yt6+N2nxvzz09d+U1RZ
MkQq0qjLunUch1oEfVJXRJ7e/fzia1pqCTRXsAjTnJTF9MtHzZBB39U6HI2CyLfnjmB2Tf7OcWnz
Z1x1373HDjt8e25pYXJGQkrh699+0O++dx6fuq1g1ySAITUx3MSfZl6bwdDhIECDAS0gtGCkBBOX
X3TkGf+87+LffBeNRhN9Pl8lAHnUXefetHrnpguICYKdXJg9DsYcFSGfT1VEn857fvE1mAaB6WiW
JdAcBeAUOZg+164m/PU5+zSTk5c/oschz35xz2tPoVqY5KwHp174v/WLfmWzine1HmAE33BgwwRo
JVgCwIDM3jPfuXnGk5kZGcUF4ZKE1FBiwZVP3nn6rMWf32lrlehGCvb0pTHbIuSzqpTABKuu4jl7
o+kKwPVAZlw++mYR8j2iyyN1j/wEpYilT1gllxx5xt1/vfzuL3NLC9MyElIK//31rP73vPXob3aX
5h++Vy+owXBgogFASRbxVnDrBYef9vDDv7xrjicjb3//Ud9bX7n/vqLK0kGWqlcJREWc36fDUdcn
0PToQNMUgBfnnzLiagr6ZrCtbTBqJvc4zgutBYTfsvJvPvWK39xx1tSF2bk5GT0yMnOv/Medp89e
8vkdEVZJlibFns/AFPAyHGywN1A6wj0iy7GSXb9A5YZtG5JOeODyRworSg6VmpQrazWPQFBkCYsr
otfkvvzj003NE2i8yLkHTp0y6kjLL79lzY57o9YxCFC2ZJniT1j931sfv3l0/xH5cMz+8qN+f97t
q3duvIAYZtQ3GKqIWQOd4tPmf3j7c3f17d6zCEAAQGTM7Wf+YWN+9hn1WAIMIiZBZEfU+IKXF/+v
KUqgsQpAAODOVx7aWWv/TyDqBKXd5btVMRACaVuySAokrP5m+mvX9cjoUQ6ANu/cFnf6Q1feta1o
13FVHk4mM+QbDIAnQwTYtmQrMRC39nenT53+q1OmrCopKUlITEwsPuz2M6dvyM8+w7EEWFbFHckJ
EUpBYN4tRGT4rmeX7YJbsXBvZ26cw23yZALA2va9TD7RGUppJ4/Z8zcwiKGV0CIlEL9q7h9f/nWP
jB5huMI/8d4Ln9hWtPM4S8EGWFQlU7LZzGY2AACDwZaloEorygZMe/Oxfz381lPDExMTi3MKc1MW
PPTetN6p3WZp0pIAVf19IAgopcknOmvb9zIAdmV2r+xdAUybYGHmTJV+2ah7RNCa5Kb31jZDtJIQ
fuEr/M8tT9zSq0uvMgCUnZsTmnDvhf9wHRk2V63WMxgMdcCAlJqU0irhLx8889jDbz01MjMlozC3
tDB50V9m/TE9LnWhLVkSoaaJTyS50rZF0JqUftmoezBzpsK0CXuVt4a1hDuXSL9s1PHCEp+y0hp1
OCKYAEvKklvOuOrmO86auhyAtXnnttCE6Rf+o7iy9BDX2Wfm+wZD49EsICTJ0t+edtWNvzl36o/R
aDR+466tgZPvu+zxoorSQULTnqnDBEVSCG3rSXkvLv58b/6AhhQAYRoobd24BOGLLiIh+rGt9B6r
+ghKE+RlR599y9+u+OMX0Wg0eXv+Lv/E6Rc+UVRROsiqL45pMBgahl0lIGTp7Wdcc8NtZ1+9HID4
fvXitHP+MvXVqLJTvOpkVe9hTZYUrPV6HfWNzu8/v7ShJKH6pwBvTBaYDk0ieocIWP3c9fw19vfS
e4f3OOSFv13xx8+zc3MyfD5f6WkPXHF3UWXpIEuTbYTfYGgmBEEMbbOd8LfZz96/ZtuGZAC+Iw4Z
tfOio06/lwkEquXoIxJsK1sErH4kondgOjTemFyvnNdtATiLDHT6JYcdQn79E5gleI+cfK0Fi/T4
1AVrHv/i2pzC3MTMlIzco3537t2rdm2cbOb8BkPr4A20KcGkFev/OffK3NLCYEZCSt5xf7zo1h+3
rfplHeFBBkGDSHFEDM97dcFqT6ZrH7sezeAUICHLfoyk8MNpglJd+JkJ5Be+guevfWgagEBmSkbB
5Y/fftbqnRsnu+mLRvgNhlbAcwwWVBYPOeLOc27LSEjJyynMzfjy3n//IyOUutBNK64u3ARmkBR+
suzHnJem13nsPRXA5MkS06HTLxszkSx5IkeUApOsFbXQDKYTho7/+/ghh20HoF//9v1+Hy7+8nbS
xNAQ7R5ZMZvZDqCNGVIqUmt3bj7v8sd/c1ZmSkYhAN/0C276s2SrnAHAa1zGAJgkR5QiS56YftmY
iZgOHWtJVo09FcCQmQwApNW06oucPZx4P8tuSZ3nvHzLI+/mlhamAIjc/dojv4uwnUjOJZgMH4Oh
tWEIYvBHS7667fvVizMByIuOOWvN4f2Gz9CCBWoLqyuKjiwjJtvVqakAqo/+PjnRadhRI+bPTIAP
Vukfzr/+CQBxGQkpBWfed/UlueGCMRaT2uOYBoOhtSDB0JUcTbnmyd/9FkBpQbgk9f0/PPtGii9x
tRa1s/9IckRp8smJ9VkBNYXV1RCs1TSn445mRtUfgLUttRjSre9/Lxh/xloAeP3b9/v/b93CqUJD
a2ZRfX/zx/wxf1r3jwZLqaGyi3KOu/Tvt52RGkosARA958iT/+FWy6v5hzQzOTJdXcb3VACx0X/E
ROETdY7+mljEy8C2Z2742yvRaDQZQOWf3nj8ept0nLua35j+BsM+ht2pwOfLvvlVdm5OSjQaDf31
l7//rntS5y9twQK8pxUgfGJi+mUj9rACqikA96fGNSABMGvUdESwBmj8wLEv9uvSPc/n81Xc+tx9
47cV7poolVveuAM4S8xmtoNgI6FJl9uV3aY8etMUn89XDMB385lXzpCaooC7vD62sQYJR7aBKllH
zRLanHHJoK5aBNcQUXyt0J9mAsX7Q5u3PP3dlJJoWCT6QuUDr5s4I7e8cFSdKYkGg2Ff4vjjhFX8
zp0zLjrikFElAEpH33ra/Rvzt50iuUb9AAYRmLlM6IqBua+u2gFX5h2hnTZBAgDL4CUiYCVAa4Vq
5jwBrIlpaNaA2QBKE32h8K3P3XdUbpkRfoOhnfAcgsm/e+XByQBKAfjPOmLS2+RaCdX3hdZKBKwE
lsFLAMRk3hXcuY4QM86D5tqFt1kTRIB8Rb8757oPAcQDwKwFn15mZvwGQ/vBgBBMvDJ7/bnfr17c
FYBv2vk3/5gRn7LYDQtW+QIIBM0A4zwAwpV5CGCawHTo9EuGDYCgURxVXMv5pzUx9Ujr8tWxww7f
BkA99v4Lg/LLikYIp4KvGf0NhvYhZgU89Pa/JgIoB2CPHTDifWbUao9HkqOKIWhU+iXDBjiNRqcJ
gWtmucIuziRL+qFZ7elwAJ8+9vhZcEp7RV748r/nK7AEo7aj0GxmM1sbbuwUBMOCdUvPh2OdB6ed
f9PXQeHL0wQBJxro7K9ZkSX9gDgTAHDNLCnQdaFy2g/Tz+sy/1lAxPtCW+/6+fUrAVjrd25O3ZG/
8yjhFPUxo7/B0L4IoaHLIuW97vnPI0MA2AO7983vmpIxXxOD6poGgH6OaRDoulA55v/WUZkQGM62
BlC15JcArcHIyuj6rduiu/IPL/91QqWOpgkNr3uJwWBoTwisCTRr/uenA7ABiHEDRs0hBrhmcz7B
tgYEhqdvHZWJ6dCOsFfwWPKJELim95+dOQafMOLouXBW94nFG5dN8kp6GgyGDgBDCCZsy985ftmW
lRkA5E2nX744IH15TDXWCBBYK/KJECp4LOCa8Jr0BHKqi7IT/2cAzExaxPuC2X+YfMMKAHL+uh/T
C0uLhjrOBaZ2nwCZzWxmA5iJNOtKHUl77rO3BgFQg3sOyMtMzvjBmQawdvcDmJlA0KQnAIDANAgC
RrNmwBv92e3kCyAjKXWZz+crA2A/98nM4RFtJ5CGBtfONjKb2czWLhtiPTgxb83CwwGnYOjA7v0W
1d4PALFmEDAa0yBE6oq+iWAMZFVz/u/Rv2vfJe6vevGGpeOYQFT9cAaDod1hgAjAttycwwCEAMiJ
w49cLplsTdWd9SRYaYAxMHVF30Qh/EkDSVInaGZUm/9rgpBM0eNGHLUMgA+AlVdSMMCtEGA8AAZD
x4KICeWRyu5fLp2XCkBe9bPzt8b5gtuZaiwTJmhmktRJ+JMGCggMICEs1BzVGQAFrUDeGWOOzwGA
r5bO61RaUd6LHO+fUQAGQ8eC3AKice/N/6Q/ANvn85Unxyeur8NgZxLCgsAAixUPgxRgZnaMiKrc
/1AguL1HRmYpAP3xT19nRVQ0mUDabehpMBg6EMRO2v7SzasGA/gKANIS0zZvLdoFwW4nTwBwZZ2V
HmYBnBYzDqoUBTMDqfGpG+DEFbE6e10vDUCyu5fxAhgMHQt3AVBuUX4vuBG+Ppk91/20ZZUzba8u
sxoAOE0wY5wTHqA9xvSkuPg8uD7E3YUFmTDtPA2Gjosrn6Xhskw4CoC6pXbOR+3hmongRPzHCSKE
ax+HnfkEBmcNXO0eyMotyutLsdMY9heICJa0mrVJYXq67E+w5wisrOjqNhERPxs+fqufrFJ2IgE1
FAERwhYDvYi59hoAAICkqvVElXYkcd9/BENrQkSI2FGUhAtQV4XnBt4JgOGTFpLiEp35oGG/QWkV
XxgusQBwyOfXmrmmJienbwADvSwi6ubmANQoICBIRPp165ULxwLwKaWCtRIKDB0YQYRwpBKDevTD
+eNPc/0+jTPeNDMEEbbs3o6XvnwTfstvlMB+A7OGFltysuPG9R+RP6TPIWVBn393WTTcizjmBiBW
GiSom1UV/+eqIwDkI1Fx3LBxuwDg2xULUsoqwj2dxQVmFcD+AJFAZaQCh3Tri9t//qtmHePHjSvx
zCf/RsDyg43m3x9wQoFQcd8s/6HneUeftjk1lFgeCgR3lUbLe8EN78f21swW6pvTM6iotMwCACkl
E7lr/w37DUSEqIrCVja01hCicau3ldaQQqCwrKjRVoOhYyGkiCX+aK3ra9NHDfbvk1Iakd+PYQBC
CFjSgqbGKwAiRwEYJ+CBARHVK8emoMeBTDXfrtHkhrqw6n0yar9uHID7F+73VUdwp1nHMd/9foxG
vd+hsQAOcMwc3tAQRgEc4BgFYGgIowAOcIz8GxrCKIADnBb7AAwHNMYJeKDifl8tXrfNtX4a9j8Y
VY7AWlh1ZXg5z06tBUTgPV4zdFy8bvItnQNU7zVv2D+o/V05JTy5zjHcTAEOcMwEwNAQRgEc4FRF
AcwIbtgTowAOYBgmDGhoGOMEPFBpjUzAOurPG/ZDGvgOjQVwgGMsAENDGAVwINMaawEMBzRGARzg
GAvA0BAN1gMw7AfUrPECr7MDgSCIGl0DoC6ICJaQkELCbTXtRJN5z1izYf/EOAH3Q4gcASeiWDdH
p/GrhmKG1gpaa9iVlYhGo80+T9SOoqwoHxE7CmY4ykA6CsEpGCIAuM0iXaXAbBREh0DX+nc98mss
gA4OwRV4EiByynXZykbEjiJq21BagQBIKeGTPoQCQcSH4hAXiENKfBJ6dOra5HMKd9rQt2tP/Obi
m1BQUoRdRXkoKC1CfkkhCsuKURouQ2lFGZRS0MyxCkI+ywdLSlhCxq7Z6Trv5hMavdChsOof1o0J
0F4QEYQ7tNvaRmVlBJXRSjADoUAQ6Ykp6JHRFT07d0efzCxkZXRD9/RMdEnNQHJ8ElLiExEfjIPP
8iFg+QGgSeW9PL9Bz07d8Zcr76rxf+WVYRSWFWNXYS52FeYhO3cHsnN3YGPOVmzN3Y4d+buQV1yA
ovISRKIRaGZY0lEMfssHS1gQgmpYDKbicGvTeNk1FkAHobrQV0YrUV4ZBjMjJSEZw/oMwqi+QzGm
/zAM7zsYvbtkoXNy+j538DEzlNauBQIIEogLhBAXCKFbWpc631NeGcbuojxs3b0Da7ZtwLrtm7B2
+yZszNmCbXk5KCgtQiQaAZGAz7IQ8Pnhk74qpcAMzbXtV8O+wiiA9oQBIRzBj9hRFFWUgOCMvEcO
GYMTRh2NIweNRv9uvescwbXWblV3b82PI6jVQ38tURJOV6Ga5/VG69omvaPACHGBEHp17oFenXvg
6KFjY++LKhs78ndhw47NWL5lDZZtWo0VW9ZiQ84W5BbloyJSCSEEgj4/Ar4ApJROT+tq0wdD62Oc
gO2EIAEShHBlGOWVFeickoFTx/4M544/BROGHYFOyWk19ldaOQ0bXEGD6+Fv6ziup1DqUyyOsKKG
aS+I4JMWenbqhp6dumHi8CNj++cU7Maa7A34ccMKLFy3DD9tXIlNO7civ6QQzIyA5UfQH4Alrdjx
jYXQRBrIBDQWQBtDRJBCoKwijIpIBQb3HIBLjjsHF044E30ys2L7Ka3BzBCC3PfsHyW6nQgF9liG
7FkLzNpVZI5fIjO1EzJTO+HYYYcDACJ2FOu2b8Li9cswb9USLFq3FKuzNyC/tBBgRsAfQNAXaPPP
daBi1TWo16UsjAHQciwpURGJoDRchhF9B+O60y/FRRPPQmIoHoBj0jMYgrwQ24EDudMT0J5TCs/M
JwL8lg9Deg7AEFcxMgPrd2zC/DVL8M3yHzBv1RJs2LHZ1DprgPpkty4ZNhZAG+CZ7LnFBejZqRv+
79LbcPXJFyM+GALgmPdEokVJO/srRARZTZhrRwakkOjfrTf6d+uNiyeejR35OzHmxtNRGi6DJS0T
QWgh9fsA6sLc6yZjSYlwpBKV0QiumHQBpk+5BT0ynNi80sod7fcP874t8BKcqmc3atbQbjRCCulE
S8wqxcbTQF8AYwHsQyxpobC0CN0zMvHXq+/Gz48+BQBgK2VabzUBz2FKRE7Uwwh9q2EUwD7CkhK5
Rfk4YdTReOaWB9Grc4/YiF87tGZoPGbm37oYBdCqOCtzpBDILcrHNadegn/8+v9gSQu2UkbwDR0O
kwrcykhByCvOx10X3Yg/XfZbx8uttRH+VsWUKmqYpqQCG/lvNaSQyCvKxx9/cQumT7k1ZvIfjN79
fYqR/6ZhSoLteyxpIa84HzedcyWmT7kVtnKE3xTkMHRkjAJoBSwpkV9SiDOOmIRHpk6D0hpSGOE3
dHyMAmghggTKKyvQNzMLz976F8QW5BjhN+wHGAXQCti2jX/ecD86JadDs4ot6zUYOjoNOwGV+7uC
cbjUgSUl8ooLMPW0KZg0+hgT6msrjBNw76ha/zaZgK0LEaEyGkH39EzcM+Vmd+Vexxr5vTX0zS0N
7i3UidUacH6YUuMHEEYBNBMpBApKSvGHi29El9ROUEpBtvPor1mDtSP2La0IDOy5UMej+go+Z7+q
HH7j+9i/MAqgGRARKiIR9M7MwpUnX9Suo79XIEOQcHwP1XSQZo2obSPg8zf5mESEorJirNy6Dslx
SUgMxSMpPgEhfwg+y6pTMVS/nurFS4xS6LhYdZVaYgB6jx7jpiyThxQSpeES3HDWL5GelAKlVbss
7PHCjdJdY79u+ybMW7UYi9ctx4YdW7Amez2OGnoYZtz8ILTWjVZSmjUkSSxevwLH3XYe0pLT4LMs
xAVCSIlPQnpSKjqnZsQq/PTp2hM9O3dHj4xMJMUlxq7Hw8uGBMFZ9txChcC1/hhqwmDoWnXBvTu1
Zz0AkwnYZGzbRlJcEn5x/DmxWXZbwmCwdkpxV0QqMfOrWXjl87exYM1PyC8pBJjh8/kRLS9Fv269
mn0eSwj4fQFo1igPh1FSXobtuTuhtHJKlGkNgCClhYRQHDKS0tCrS3cM6NEXI/oOxvA+gzGwRx90
Sk7fY3pkKxUrNNpkC8E4AZuGKQnWekghUFxeiuNGHIUhvQaC3Zr4bYVnnpMgvPPdx5j+8iNYsn45
pLQQHwghLTHFFSyJAtbwWb7mn8s9nwABUkJCgix/jQKk3jUprbEjfxc278rGF0u+dct3BdE5JR0D
uvfF6AGH4sghYzC6/6Ho3aVHjWiJ0o7L2mROtj1GATQRIoJtR3Ha4ccDcB5er2DlvsYTflvZuPVf
9+KJ916E3/IhPSk1ZmZ7wiSFW2KsFSrmeIrA+b3+9fh+nw8Bvz9m4mutkV9ShK+Wfo8vFn8NISUy
ktIwpOcAjD90LI4bcSTGDhyBpPjE2DGql0UzymDfYxRAE7GVQkIoARNHHAEAbZb04813I9EoLn7g
Brw15z2kpXYCg2Gr2kHf9sEr5VV99umzLPh9Pghy6v6HIxX4dsUCzPnxOzz0xpPo3aUHjhp6GE45
bCKOGXY4uqVX9RuIWQYdLLx6IGEUQBMQRAhXVmBgj34YnNUfAECibUYp7c75b/zHH/HWnPfQKb0L
InbUK0HQYamtFCRJJATjIUIJ0MzYlpuDFz/5L1765L/olt4FRx86DmcddSJOGHU0OqWkx44TVTak
rKYIzNy/VTBOwCZAJFAZiWBY70Hw+/xN8qy3BC/K8NY3H2LGrFeQntoZkepNPxsq7dyS72wfONu8
op+eQvBbfgR9QQBAUVkJ3pg7C6/PeR89O3fHiWOOwXnHnobjRh4Fv+vL0FpXXYt5JhuHcQK2DkQA
a43hfQcBcMJlbdGaw+sc9Of//BN+f+CAaozBzFDsmPqWtJCakAwAyCsuwDMf/gcvfPJfDOs7COeO
Pxm/OP4cZCSngYiM3LcSRgE0AWZASIlDsvoBaJsVf97o//2KRViyfjkSQvHOKHgAUl0Z+CwLaUkp
YGas2LQGi1f/iMffeR5HHzoOSiknMmFKgrcYowCagGaNUCCIrM7d3Ff2vQLwnvGvls5DNBqBiEvY
o/X7gQgzQ7nOzbhACAmheIQjFXj3u48RH4yDEMJYAa2Aca82EgJBKYXEYDw6JzvOqZZmtDXqvO45
1m3bBCJxUA56mjVs24YkgeT4ROeeHIT3YV9g1ftE1X7daey276+oo0KAUgpxwVCNuHUbnBYAUFRW
7Pze2O+htb4v7zgd4LtnRswqcF5ov2vp2NS6Mdr7Dvfc01gAjYRA0KyREIpr8uKa1sCS0jzvhlbH
KIAmoFkj6AvC52X+tUH83Vvskp6UBj6AvP+GjoFRAI2FALAzEnux/7YojOFZ3gO69wFixTkMhtbB
JAI1lnb6/J4T8KihYxDwBaF1I3vjtVYCj1l1t39S21isLxGooSSyRrz/oIEZYHLWAngFOBi8z60A
KQSYGWMGDsfQPodg2cbViAuG9poLYOT/4KU+2a3rezRTgEbjrFCriFTCtm3vpTZBaw2/5cP1Z/8S
kYpwmy4/NhzYmCepkXh19koryp1FOG2IlAJaa1w66ec45ahJyCvMi+XGGwwtwSiAJiCERFlFOYrL
S9v4zAS4RT6f++3DGN5vKHIL8+CzfGbNvKFFiD0mCPVNFhra7yDYWDMkCZSFy5FbVODckjZMjnHW
0zMyUzvhwz+/jONHH4O8vF2wbQVLWM6ipMZ8j02lA9x7szVja+R3aCyARuNU/i2vCGNb7g73lbZT
AICzKlCzRrf0LvjowVfw52vvRmJcPPILc1FeGYYggiVlrC+hsQ0Me6OBYaMJauSg2ABBgFZRrN22
0bkjbSv/7jUIaGZYUuKOC6/Dgidn494rb8fgXv1RXhlGfmEeCsuKUBmpgGbdwryB9r7nZmvJ81qF
rnc/sxqwyRCWbVzt/NZOQ6wgAsOpAdg9IxN3T7kZd150PeatWoy5P36P+asWY8P2zVizZT0qo5H2
uUjDfoFRAE1Aa6fc9tINK6G0hmiHXgAeBIIUMlaR12dZOPrQsTj60LEAgHBlBbJ3b0dUNb+uHhHB
kpbT84DZXU/SDmaPYZ9RfyZg7TwTz4o4iGFoBH0BrNm6EVt2ZqNP156xpKD2gtx5v2MROOW2BBFC
gSAG9OjbomNHo1FUFOQiaifDkhb8lg9Syqqqv269v7Z0hhqaQX0zAxgLoEkwA5ZlIb84H98s+wG9
u2ZBa0Y7GgIxHIugak7CXNU1p6kKytt/YI++uPOqO7Bqy3qs3bYROfm7UFRaAtuOACBIy0LA54fP
8jkZi4DTm5BNx579BaMAmgGB8MH3X2DKpJ+3SVGQ5uBEAZp3bV5uQfdOXfHA1b8DAFREKrE9byc2
52Rj1dZ1WLZxNVZtWYcNO7YgJ383KirCAACf34+gLwBLWiBypk0HUg3DAw2jAJqI1hpxoXh8ueR/
2JG/C13TOscadhxoeP4FQYSgP4C+XXuib9eeOG7UUbF9CkqLsG7bJixZtxwLVv2IxeuWYf32zcgv
LgSY4fcHEPIHIKV0m5cY66AjYRRAE2FmBHw+7MzNwZtzP8D15/wSSusara4OFDz/AlA1pWDXGej1
9UtNSMbYQ0Zg7CEjcPVpF0NrjQ07tuCHVT/i66Xz8P2KRVi9dQOKSoogLR/igk53Ye01DDW0K2Y5
cDPQiuH3B/Hch6/j6tMvht/yoS1WBrYnsSlFrY8Ya/zh1iqQQqJ/997o3703Ljr+LNjKxtINq/HF
om/w4fwvsWjNMuQX5sOy/IgPxUEKAdVKLcwM9WCcgK2LVxps8ZqlePOrD3Dx8WdDKbVHB9yDASIC
EcVSSmNWgmaAnFr/owYMxagBQ3HbBVOxJnsDZv/vc7zzzcf4YdUShCvKERdKQNDvN/6CdsCqaz7m
KAuu9ZqZu1VHaQ2/348HXn0C5xx9MgI+/wHrC2gKBEchwNWFXitz7XZRHtijLwZO7otbJl+NeSsX
49+fv4M3v/oQ2Tu3IhAIubUOjCJoCfXJbl1GgFkL0Ew0a8QHQ1i2fjn+OnMGhBCxZpaGKgjOKkZL
ShA5hVW9ZqaHDx6FR6+fjh/+NRt/u/5e9O3WCwVFBaiIVsb2N7QO9Q3dRgG0AKU0EuOT8edXn8Di
tctgScsogb0gSMQci1prKKWQmdbJsQienIV/3Ppn9OrcHQWF+dBau1mIMP6nfYRZDtyCjV2zNhKJ
4IoHb0NpuCy2WMewd4QQsfCgUgqJoXhcd9almPfkLNxzxe2whIWikmLHGgC1+/e9X2311QSstRkL
oIUorZEQl4Ala5bhqod+6zSuNOmxTYKIaiiClIQkTPvlLfjmibdw0rgJKCjKB4PbpBPzwYa5o62A
rWykJqfi9c/exk2PT4MUjhVgLIGmUV0R2EphaO9D8OFDr+DBa+9GNBpFZaTSmRIYWg2jAFoJW9lI
SUnDY2/MwM2uEhBEUCbZpcl4CUhaa2jWuP2i6/D+n19AamIyysJlB2TSVXthfACtuClbISU5DX9/
fQZ+cd+NCFdWQAoBW9mN/DoM1RFCQJBz/04Ycww+f+QN9M7MQklZaU3noNn23KpTfz0QYwG0Nkop
pKak4dWPZuL4Wy7Ais1rYUkLmrVJfW0mlrRgKxuDe/bHxw+/it6ZWSgLl5npQCtgFMA+wFYKqcnp
mLdyMY694ed46r1XIEg4uQJKGd9AM3CUgEKfrj3xzv3PITUhBZXRynatxXAgYO7ePsJWUSTFJaKi
sgK/+svtOPWOKVi0ZmmsoIZRBE3HkhK2sjG090C8dNejsG0bJju1ZeylKKg3d7Ub2Mds9U3ClLYh
pUBqcgo++v5LTLzx57jx73djU052lSLQyjgKm4A3HThp3ETcdemNKC4ugCUF2v/77mhb4xIBjBNw
H2+sGbatkJyQBIDw+MxncPjU03D7k3/Cum2bIIWMtfqyjVXQKKSQUFrh97+4EUcMG+c4BWkvY9nB
tlWngf3MFKCNUEqBAKQmp6I0XI6/vPoEDp96Oq788234+sd5ANzW426+vJki1I+3RsBnWXj4urtN
9mVtmnArjAJoQxjOKG9JidTkNFRGI3hu9ms44ZYLcez15+LxN5/H5pxsCBKxKYKXFKPNmvkaSCGh
lML4YWNx/s/ORHFpsckPaAZGAbQDnlBLIZCalIpgIIDvli3AjY/8DmOvORXn3nUVXvxoJjbnZMeS
YoTb7UdpZRSCh6sgb7/oWsSF4mKrDA2Nx6rrEWpoGmFoPZgZ2n1oE+LiQZSAsoow3v76Q7w9dzYy
UjthzKDhOGHM0Zgw8kgM7zcYAZ+/xjGcbDmnGo+3Fv9gWUYrhdM1eVi/wTjliOPx1pxZSEpIPuhX
ZNaW09p5QNUxJcE6CEo5XlspJJLjkwECyivD+HjeHHz87WcIhOLQr3tvjDlkOI4eNhZjB4/AwKx+
iA+G9jDjnKQj58sSgg7oWLlXq/CKUy/A23Nmw+1eYqhOfdIPUxKsw8HMUOyMYI4ySHRNf4212Rux
YsMqvPzB6wiG4pDVuRuG9h6IEQOGYmT/oRjUqz96dumGuECoQ/QqaAuEFCAQfjZ6PA7pPQDrsjch
5A8Yp2AjMQqgA+Mog6oHOeQPIC4YAsGxGDbnbMParRvwzpzZgLSQFJ+Aruld0L9HbwzuNQCDevbD
kYeOwZDeAw/YcmUEgq0Ugv4ATh43EY+sexLxwVBsamVoGKMA9iM0M1DtwQ74/QgFgrEaBLa2sXHH
Fqzesh6zv/0MKCvGqZPOxeyHXmyWAvD6AhBVVQXuiErEu6STxk3E3994xjhHm4BRAPsxjoVgw6vV
LeA08AgFgrCkhUIpEfD7Gz5IA1TvC+BR5XQkiA7icPR8HGMHDUfXTl2QV1QAn2W1S/v2Dks996L+
u1T7deY9XzN0EDj2d2z0Y0ApG9yMNGPPWti6azs+mjcHA3r0QY9OXdG9UyZCgWANp6NSCtTOjkbP
AkpLSsXQXgPx6Q9zEbASoQ7aysIMqFr/rkd2jQVg2APNGpIk1mZvxDXTroWVlIKEUBwy0zpjUK/+
GDd4FI4deTjGDhoBvxuWVFpBkGg3i8DrzjRq4KH45H+fg0hgz3x4Q22MAjDUi8/ywZ+cirhQHKLR
KDZs34xVm9finS9nwRcIYmDPfjhz/CRcdsr5OKRnPwDOFKE9a/cd2neQkyBkYoGN4sANEBtaTPU0
ZCEEgv4AkhOSkZKShlAgiDVbN+CBFx7F4dechhsfvRt5xQXt1h/BMzz6d+8Nnz9oiq80EqMADI3C
6/8XS0VmRsgfREpKOmyl8Ph/nsKR15yBBat+dFfrta0AkuuD6JrRBUnxCY5vogM4KDs6ZjnwwbC1
hAaOq7WGbdsQIKSmdsKG7Ztx8q0XY/GaZbE03bbCE/X0xBQkxydCKdX+972jfOcN7GcsAEOLYQBR
O4rE+EQUlhRjyr03oLisNLZYp01wNUAoGEJqYgpspQ7obs2thVEAhlbDtm0kJSRh+ZplePSNp53a
Bm1kBRAo1qkpMS7BOa+R/71iFIChVbGVjWB8Ip6f/TqKSotjjT7aAu888cEQmLWxABqBUQAHMm1k
fdc4pWYE/AFs3r4Fc5d8DwBtZgV4HzfgC7TLZ98fserSzjE/QrWaoAyYHOv9CHYzN1sUD3d7HDan
1yErG9/+9APOPPrEll1DM7AsCbA+aHs0MrhmIqB2v0PsqReNBWBokOYILzMDUmLVlnUA0OZpwgej
0DcXowAMrQ6DQUIitzAfANo8MzBqVy2QMjSMUQBNhOF2sT1YKm40EyEEwpUVTjwezbMkmoon8uHK
Cjc10FgCe8OUBGsi0n2w7WgECfGJVamvHe3e7ItEoCa8xzHDqSpHtw3wLI3S8jIQCWcBXEf7XtqD
Bu6DsQAaCRHBthUS4xLw3/tm4NzjTkdFRRjFxYUAOzX9TeppFVprJITiIIVwlhfvY5Pcm/dHohEU
lhZVdQ82NIhRAE2AyGn3NWncBLx5/9P4/ImZOH/S2QAzigrz3Zr/1gFdhLMxEAhQCt07ZQJwlhe3
FcVlJcgvLnTyD4wG2CtmOXATIRCKSksQ9Adw7MgjcOzII7Bk7XLMeOdlvDnnA+zanQMZCCI+GALg
dPk52LzSRARojVEDDwWANqkj4xUx2ZG3G4WlJU4lo4PsvjeHg3uoaiZSiKoOv1pj5ICh+Odv/4yF
z3+E+2/4Iwb3HoDi0hIUlxTFClW05xr5tkZphUAoHieOnQAAEG0wNfKU7IbtmxEuL4MU0oz/jcCs
BmzO5t08ISDcVW9KK/To3A2/m3I9fnj2Q7z70Av4+c/OQNDnR1FBPkrLygAAlqg2RWjj620WTTyX
FBJlpaU4duQRGDFgCDS3TYEQz9xfum4V4C0Eau/npD23xjUHNlOA1sB7wJkZWmsE/X6cecyJOPOY
E7Fh+2a8M/djvDlnNhatXoqy4iKQz4+4YAiWmyevD5CMNSICu8VDpl15K8hbDNQGvlFPqS5c/RPg
Oh4Ne8eqf4iorUK8BkMHMw0PqUQUW/yi3cUofbv1wq0XXYNbL7oGi9csw3tff4wP/vcFlq1fhaLC
QkBaCAaD8Ft+ECGmDFr+ALfG8F/9OA0fy+tdWJy3C/fdNB3jh4+F0rpN8iWYGUIIFJeVYsnaZfAH
AtCs9nrNBy61P3f935+xAPYBRARJzoPvtenyClaOGngopl15G5auX4lP5s3FZz98jcVrlmFn3k7H
dPX5EfQH4LMsN5bNYNZux6uO90ALISBIoLwijGhlGHdNvRO/v+xGKK3aLFnKK2K6aPVSbM3JRlwo
3pQEayRGAexjBIlYmy6vpr4lJYb1G4xh/Qbjtot/he25OzFv+SJ8vWQe5i1fhNVb1iOvMB+wo4C0
YPn88Pt8sZbhANwq7e5inzZQDgRy8nqqNSBVWqG8IgxVEUafnv1w/3W/x4UnnOUIZBtmSnrG0uzv
PoOKRCDiEkw94EZiMgGbQgvvgRAiFnbxlIEUAt0yuuCcCafgnAmnAAA252Rj2fpVWLDqJyxZswyr
t6zHtl05KC4tcZQCAEgJIS34LAtSyNhI7AmpFBKWsCBbkJNAIAg4vfeUVlBaw7ajUHYU0Bq+YAjD
+g7CRSeejavOvARpSSmu2d92EQ8GIKVERaQSs7/9HFYgBK20eVar08BzayyAdqK6MvCch4DzMPfK
7IFemT1w2vgTAACVkUps2bkdG7ZvxpotG7Bmy3ps2rEV23bvxK6CXJSWl6EsXA7bjgCaAVYASaCk
CEVlpc2+Rlvb0BXliPr98Fs+pITi0CWtE/p1743DBo/AsSOPwLihI2OjfVua/R5aKUgp8dkPX2PV
hlVITEhq84Kk+zNWXYqhLoVhDIB9dw8856GHrjbvF0QI+AMYkNUHA7L64KTDJ8b2U1qjuKwYeUUF
yC3MR25hAfKLC5BXXIDScDnyCvIwoFf/2Dkai+dRHzVwGL567kPEh+KQGJeAtKQUpCQm7zHC20pB
CtEuC6S8z/XUOy8DIDDIPKd1/Ls+V66xADoggsgZwV28ub7jEHSias6KRIHUxBSkJqagf48+DR6z
KQrA2zclIQnHjDx8j/9XWjslt0hAiD37B7YV3nRj3vLF+Pi7LxEXn9AuPQn2Z4wC2A/wOvPWjqdX
dwA6K988V6Cn550Gns1NxKkezvR8CyC4FkBHyGx0Puf/Pf8ootEIgsEQFBsF0BSME7ApdLB7UFsw
W/341cKZHQ1bK1hC4r2vP8Hsrz5GQkJyrPaAoRYNPLcdQY0bDE1CM0OAUFxWgt88di98Pj86lGbe
jzAKwLDfoZWCEAK3/n061m5YjVAwBG3m/s2igVRgMwfYE3MP2puosuGzLDz73r/x7NsvITE5Fbby
yleb78aBAdRWiHXfG2MBGPYbbNuGT1r4YsG3uP6hOxHndQAyNBvjBGwK5h60G7ayYVkWflixBJPv
vBIMQAhpFEBjaGAdn7EADB0eW9mwpIXvli7AqTdfgpLyMvh9fiP8rYBRAIYOi7OSUsOSFt6Z+xFO
vfEipxxbIGTSfVsJowCagVLOwhgzG9h32Eo5KymFwAMvPIbz7rgSFdEoAoGAyfZrRUwmYFNwJT4t
OSWWD+88qAQSZLrRtgJKO4JvSYmN27fi5r/ejfe+mIX4pBSnwpAybb9bE1MTsJEba4aUEqVlZbjl
b9Pw9ZJ5UFrFCn4SCLZSUFqZclTNQGnH3PcWFP3rrZdw1BWn4b05HyApJR3gal2GO8Dz0OE3UxNw
38AAnnz9Gcx4+2UMHzAEpx71M5xx7Ik4bPDIGotiHEUACEEHfZ+A+vCWQQshYhbVJ/Pm4k/PPoqv
F3wDfygeiUkp1eL8htbGKIBmkJScCqU1lqxZjsVLF+Ghl5/Eof0OwQljj8HJR/0M44aOQkIorsZ7
vDx1OsgVgrfACOzUPvCWQX86by4ee/1ZzP72M7Dm2D02+f37FquuUlKOdcDw9K7t/rsj1qRrD6LK
BgGIC4Ug4uKhtMKSNcuweNlCPPzqk+jbvRfGjxiH48cejSOHH4YBPfrUWO8POAqB4Sz99UpsHaho
ZnC1gifeAqP84kK89/UneOG9/2Duku8BpRCfkAgCIWpG/WZTW04ZOia9tSXYJAI1EwbASkPDcUrF
BeMgQvHQzNi0fSvWb1yLl955FYnJaRjadyCOHHYYxo8chzGDhqF316w9FAIzx0JbRACRiK3735/g
alWNGVVNVOB+3nBlGN/9uABvffkBZn3zKbZs2wwIifj4BKfOoBnxW58GZNdMAVoDdmPW7j+D/gAo
GAIARO0ovl+6EN8v+h8eeVkiJTUdA7L6YPQhwzBu6EiMGDgUA7L6ICk+sc7CGlrrWEEQcrvtkrcE
GO2jIDwnZ1WhEud1r/ZA7WvK3rUD3y9biM/mf405C7/D6k3rgGgEVigOCUkpQDXlZ2hbjALYB2hm
wB3JhBCIj4uHoAQwA+GKMH5Yvhg/LJmPpwD44uLQNaMLBmT1wZA+A3Fo/0EY0nsgenXtgS5pGfD7
/A2ey2ssAq4+RasKSFILC4I4MXf3eESxKYt37NqEKyuwacdWLFu3Cj+sXIJ5yxZj+YbVyMvfDSgF
EQzF7oeZ47c/RgHsYzxz2BvfpJSuADjCo7TG9t052LJtCz7/9nMAAPmDSElKQtf0LuiZ2R19uvVE
vx690DOzB3p07oouaRlIS05FQigelpSQ+8gKICJYcs9HJBKNorisBDvzd2P77hys3boR67ZuwqrN
67AuexO27dqB8tJiQGvA8sEfCCIhIdlpfOKG+8x43zEwCqCNqa0QAMDvNgPxRlStNcrDYazctBYr
1q1wrAlmpxS4z4+EuAQkxsUjPSUN6UkpSEtKQae0DKdoZ0ISUhKTkRSfiJDfj/49+2JIn4Gx7rmN
vUYiwrZdO/DCrDdQWlGOgqJC7CrIdQqQFuUjr7AAxWUlCIfLnVLlDMByrs9v+ZCQmAKiKgvFZO91
TIwTsAPAzFC1bq4UEnEBCxSM82b7YDhx88pIBOUVYWzfvROsbGekZXZ+AoAQgGUBRYWYcvHVeGn6
406STSOLd3qddlZvXo8/PHA7EJ/o/AcRICRISljSgiUl4uMSqpqVAG41YzamfUfCOAH3PxrqDyhJ
QFoC5PYTBCj20303pJAo0YyAP9jsa/BZPlhpnRAflwDtJjbBdfo5BUnZmPP7OU1QAGTG/w5CjXZg
9XwrDCcbMZY+2ww3ATPDVjZsZZult/sZRI2TV4F6HyFiv9+vAUApRcxsrIX9ELMu4eAkErU9eWUi
qk97s6hnCRsza2vd5o0JAGh4/6FlQb9/lxOLNp6A/QmTvXlQwQyQJKoc0mfALjgDvC9iR+PrNAAJ
ZLHS20lQN/dJcZLPAG0rO+67RfOyLj7p7E2piYnloYA/tyRc2tuUENhP8HIDWmS6s9tr0N0M+wMk
hIyMH3FYLgDMXfx9Snl5eU9ypoxVTiICseLtgsCbXQ/SHt+w3+fzErKJjA/AYNgvIJCKKEUAKCEU
UqA6SgQTgcCbBQOhPQ8A1mD8uG7lADiKIdolNWMNe2827DcYH8DBgyO3GglxcVuPHDq6AAC//+XH
WbZS8e7UvcZMgIGQANF8IqpzslhUWpQO941JCcl5+9eyFIPh4CQUCObDaQygt+7emcJgieoDN4PJ
WXE2X5Cm/DqOQQRgd2F+PzihQhrSZ+B6clovGz2wH6HZhO8OIpgBdE7N2ABXAazbsr6frsd5T5ry
LYZY6naVrdVYnVBaFu5aEg6HEkOhisOHj9n+3Pv/CWutg6jDnDB0LNjN/mqJ/Lt5P8YHuP9ABELf
bj03wPXW7yzMy/LSRap9heTIvFgqiHgtK7ZRTaDZPVA4Es6c/c2nGQDEL045Nzs+FNqiwWRCgfsL
ZMKABw+sASFJVpx9/GnL4Vju/vyiggHeWs5q+xIrtol4rQhGaA0z73ZXisTWkxKgbdaBWXM/HgQg
CiCSkpS8UcfGBcN+gRm6Dwoc4WUE/P7dJx91fB4Anvn5rMyycDir1tSdQUTMvDsYoTWiYOGGEhDW
QJBTO6jqgMxgLF2/aiRcgR/Sa+BCY/fvXxjxP2jQGowu6RlLE0OhUgDq3S8/HBzVKkROjWBvxZaG
IICwpmDhhhIBQBNokWsAVH9eSICwY/fuYQD8APyXnvbzhRZZFRqo6VU0dFhMGPDgwJu2jx084hs4
wq6Xblg1Ys/sXWYiAoEWAdACALTCXNbs5Acxe44fIZi4pLyk3xMzn+8LQJ97/Ok5iXHxGzRrkFf0
zWwdemuxAugAn8Fse92YmYWPZPnPjz91JQArGo0mZG/ffoRgArPX/4MBBrFmaIW5gOsplJb6AVqF
QeSO7M5RCaxtVr43Pnr3aDh+gIpDevWb4zqWuC0+mdla/GSgZbT/ZzBbwxuBWUMjPTllydkTT80G
oKf96y9DyirLswSgAfaMAAaRhFZhaakfAEBgGkR40tYcZv4JsqYfAK5ZsXrL+mMBBAAEf3Pp1E/8
wirXDa4kNHQUzBTgwMf5hgknjDv2Xfcl+6P/zZmgakfsGBqSwMw/hSdtzcE0CIFZYySmQxPEm+6S
AK52YCFBXFxWMnDGWy/3BsBnHntydnpy6o8a2oQD9wOqFwo1HJAwAyJg+fPvvOKGRXD8dfGbd2wZ
7xSWr756j9mpKC3exHRozBojBRYuVACgbbzHto4AVKNulBsO9D337n8mAagAIM485sQ3iMmMLfsD
JhHwgIYAraAxpM+A9wb27JsHIHrDg3eNLg2HswRIcw3NT5JtHdE23gMALFyoBACNaRCRBZvWsubF
kIKg3RJ1ziYEE1ZvXH9SOBxOAhB44ncPzE8IxG3RzIKctiPtPQ0yWz1bixKBOsD1m63hTTOEBRGd
et6UDwEEAdgffvv5GRpMVL0dkIaCFMSaF0cWbFqLaRDwogCYM8ENB+K/dUwDSIJ0WaS8+5Q/Xn88
gHIAFUePHvuayTLr+BgfwIELAUpBU1aX7p9fceZFawHguff+PWDb7pxjJQSzE6538cx//BeAdmXe
nR/MnasAQATwqrZ1KUjUGef/7seFZwAQJeFwwruPvPRBYjBui+toMIamwdDGMEAWieiNl1z1MpzR
v/yp/75yss3aL2rKJIOE1LYuFQG8CqBK5mM7TJ4sy7/esgPg98kiArOqdiIhIXReccGoGx6866jE
UKgcQNnRo8a9qp0qI2aY6YiQWQ14oEKAsqFFVufuX1w/+fLlAOT85Yu6Ll+/+lx39K9y/jErsogA
fr/86y07MHlybICv5iGc6R16BmsGQKL6XIPYMSff/GzW5XCsgMR3H3lpdmooaY1ilsYX0EG3lsp/
e1+/2eraWDPIJ6yyu6+88VkA8QBKr7vvdxdX2pFk4cgixfYHCVemZzhfqifr1RXATChMg6ict3kO
bD0HUggwalgBFoTaXVww8qybf3lWYihUDCBy6Wnn/d39f4ahw6FZQ2nVrM2UAu+YuJ5/MbL/kH9P
OfOC1QD0jJkvD1q+YfWFFoTmGqM/FKQQsPWcynmb52AaBGZWyXXNUt8rnJABC5pOrCdWKyLoIQjg
uYv+d1l2bs5n6fHJ6uHf3PPdh99/+c7qrRvO9kEqt/qIoZ3xGndIaUEKCSka/7V4+ybExbtHqt54
1NCeEEjb0DI5LnHtdy/Ner6gpCA1NTG1+M8vPn6NzcpnQepackvEGixoOoCYjHvUVACeFTB98xz/
2Kw5ZMmJsLUCOd5EBkhCqNLK8u5n3zjligWvffpQOBxOnfvMm3/vf+b4seWV4e7SiT2a0sHtDDND
WBI783djzoLvoJljLbz2hmYNQQI/rV0BIaSJJHQc2G0Tb998yZUPALBTE1Mrpt772+O27s45TkJo
Btcc/S0hta3mRH7Y6oz+02sWCN3ziZgMiZlQgcN7TYTAl7A5pgBihwWYCeruq26a+oerbl0OQF13
/51HP/Pua48IkEaN8IOh3SCCUjbsysrmvV8IBALNby1maF0IpKJQcsyAQ5+f98qHj4bDJSlllZWi
/5njXymvDHeTtUv2MRQsktA4rnLe5jmebNc8Zt0IANo/tufHJMWJ1a0A903ahhbJcUlrc+csvzS3
MDeYkZKRf/gvTrll4Zplv/RB2gzTSagjQESN7gpcF8YP0DFwvf6yc0r6gm2fLLk2JzcnMTMjM3fo
uRPuXZ294WxfXXN/S0hW+pPID1tOgivTtY9bt6k+zTuIuBFaR2KlBGLHhrAgdGF58YBh5x13W0ZK
Rl5Obk76vFc+fKJLcvrCKJRF2KMWuaEdYK+BZzM3Q/vjOP1Y+qW/8LUH/zUNQCAzI7PgojunnrUm
e+PZFoSqNe1mpyKAjoDFjQCqZLoWdSuA6dCYPFlGFmxaDcbDZAlZPS/AOYMTFVi1ef15F9059azM
jMyCaDQa99UL796RHErYYENLAhklYDC0AK9HhySquPPy626bMOqI3QDUfz56u++7cz65XTgDc005
ZlaOzOLhyIJNqzF5ssT0ugPCDdmGBIAwrn+CnyOLSFA/KNagmpqGwZBClj53z99/eeHJZ2YD4Mde
e3rgnY/d/y9bqwTjFDQYmg0DYAUtThv/s/veeeTFN8LhkpRQKLGi83FDXygoKx5cR9hPQ5Jgzesj
5B+N+etKvePUdYKGBJMxGYT564oJmArEUguqQwLEUW0n3vDn392/ftvmxGg0Grzx4qtX/f6qG260
hCxVYGFShQ2GJhMT/pPGHvvgO4+8+EZ2TnZGKJRYNujso+/OLy0eXIfp7xX3ZwKmYv66YkxGg5m6
e/cOTZhgYe5cOzAm6x7yyWkcVTaIajj4CFBRaJmWkLxi15fLLi8oKQilJqYW/+mpv428//nHH7OV
sQQMhsbiFOR1hX/csQ/O+serr6zftrlLv+69ckZMPm7ask1rJ/shFdeOtjHb5JMWR9X0yoVb7/Fk
t6Fz7V0g5861MRmycuHWe7StP4UlreoZggDAgPRBqvzSoiGDzjr67tTE1OKc3JyUP0y9dcnvL3cs
ARtaGJ+AwdAw5FT3pTqEf+cpv7740pWb1k/21Sn8ULCkpW39aeXCrfdgMuTehN89X6Nwyn8d2qdz
IKR+AqgTNHMtf4BrCSg5oFuv91e+++203MLC5IyUlKI/P/34iAdefOxP5ZUV3V2zxeQJGAy1cJb3
spQkwicdOfGv7/z9hZnrt23u1K97r52n//qSX3w8/6s7JIRX4rt6vF87WV68uzIsh2PZxl3u/+91
6t34ALGbRGCN6nak9Fnfgt2kpFrHqFICvd9f+e6306LRaILP56tYuWFtyoSrzvlrfnHBMB9Jr1KJ
qVNlMKAqzu/3+fPunPLr2+++9rYFObk56ZkZmbtO/fUlUz6dP7du4fd8c0SkovZ4e/H2/9WV8NPA
eZuAlyU4uvvVsOQMKLbdBKE9lICbtDD/y6fevmtg374lAHwA1PDzfnbTyk1rLhBEEBBm7YDhoIYA
zYCwWaFLasb8V/705L3HHX7ULrcnZ9nI83722+Wb11xQr/AzFCRZsNU1lYu2Pd0U4QeaMwJPgIW5
sP2js24WfvEIR3UUjnDXOjCpKNsyNSF51fuPvnjrEaPG7iwoKUlMTUwsuPiOX53x7lef3FIZiaT7
SBhrwHAwwgTSNispiPSowcOf+/7l2TPgFPVUAHjwWePvWpO96Qy/YzHX5a+Lkk/4dETfElm09VFP
NptyEU33ys+FwgRYkUVbH9VR/TRZwgfe86QMlj6SqrCseNAJ117wynX/d+cxqYmJBbmFhWmvPfiv
Dz55/LVLe2V2/9RmLZyGo6RglhQbDgLcZ52irGRKYtKKu6++5arvX579eE5uTgKAstc+eKd75+MO
fWZt9uYz/CT3DPUBAMMmS/h0VD9dTfib7GRv7qhLmAbCdGj/mKwZwhJXs12fJQCtwYIBjB449Nnv
X/voKTirEAWA8ovv+NWps7/5YmpZRVmWJAkBUu6KJmMRGA4oCFAMSJsV/NJXNnLQoa9899KslwFE
w+FwMBQKFV5857Wnv/PFh3dGtZ3YgMM8SpbwaVs/HVm49Rp3lV+9yT57uaYWfJ7JTnEB/5isGeQT
V3NUKziCXdsnwAywDS26pKTPf+DmP/zlstMnry0oKUlJTUwsWb9tc+rFt//qwmXrV59bEY2kSdc/
ADCZ3AHD/ozTO4M0g6XNGhYJu1fXrI/uvvrGl6acecGaknA4OTEUKsvJzUk6YeqF167evG4ygSDq
zpthAJp8QnLUFX5nzq/RTOu5paNslSVwWNbNIHoETo/B2inD7s6kbFbSklbZ0aPG/euzp954E07L
sSCA0v/9uCjz5ofv+vmytY4iECAIIvYcJa1wvQZDWxDrxaWZhQLDEiLaKzPr45umXPnar8+/YiWA
EJx9IlPvvePY/3z89q2lFeVZFtXp7KuSKUEA8y2RBVsfbcnI79EaAhWzBHyje15NhH8CsKD3qCPg
ndD1emqkJSYvv+iUc5587M4/zYMzLbAAlH6z+IeuDzzz92P+99OCySXlZf01MxyrgLRbnZCM49DQ
gfDSbxkAaUB4xVhD/uCuIf0GvDf1vEs/veKci9bBcfJJAGVPznx50EPPPX7F1l3bJxEIsr6oGENB
kARgM+O66KItT7d05PdoPQFyPZDWiJ7jyeKZJERX2NoGoa66AEwAK2bBxMjq3P3T26+4/rlrJ09Z
DcePYAGoiEaj8fc89ddD3vx01unZO3ccVRGJdGI4lW2cP9DkKATA0Qw1SiG12mczGBycBy22uIbg
TVM12M2NA3zSKstITVt0/OHHvv/7q29c7HbsCThvRXj+j4syr/vz789fumbFFMXashqKhDFsWMJi
rXewTZPtH7d82xxvf320rpC4Mci4MT27RsHPkxQnwdZOteA6pwROppLNWkgSdu9uWR+df9JZ7/7f
9bcvRdXUwAZgL1m5MuPZ914Z+M3C74/IztkxuqwinBVVdoJ30wG4Ja+cfwnH0jBawNAivGeIAcHu
K9otgev9n0/IimAgtKNzevqyccNGfXvuCaevOue4k7e5h/DDeZbtp9/+94Bn3nzlhGVrV55XEY2k
WiRAjn+gLi+/BgGwhGClP/aBLi9fuGVHU+P8e6P15aPaBfpH95wGgXsAAEq7SUPVy9M4t9CZFrBQ
rEFE6JSaNv/IEWM/eOjWP37Tr3uvAjjzfwknPqoAhL6c913qzE/e6//TmmWDdhbk9SopL+tUHi7P
spUdYs3+KKugEX5Da8AMWCS0lLIUBE4MJWwKBgKFXTK6rO2T1XPj5ElnrDjxqOPyE0OhUlQ9qxrO
4BV3/f2/H/3Rd1+ekp2z7YSoVj5Jwo12QVapkWpncyr5Opazxj2RRVucgp6tLPzAvhsgPY2mA6N7
nKQJj5EQA6E03IVEMrZIsepnzNmnWBMAhHyBXV07dZk/fvQRc3931bVLBvYcmO++Q7rnsN1NAqA1
WzaklBSXyLXZG+K/Xji/xz76bIaDDA2NAT365k8Yc8TuiFJ05IjRBagajAScaSvDeRZ1OBpN+L9/
/WXQ7LmfT9iyY+tRpeHyPhoMCwJEcOL6XE32qhbsOn4zKcBarxGMGysXZX+MavLU2p9t3w6S3lxl
TGqyjxN+Q+DbIYQftnacF3U4Cd2L0gCgwUK5Jn7I7yiDwX0HLj7xyAkrrzlvSrbP5yuHs68XIahu
SrXYQWIwuNR+tjzPu3L/z//m5x9kvv357EE/rV4xIjtn2+El4fI+XiVmgb1Estg9jiUEtI4w6KEo
lT6MhQVFrTnfr++D7VuqmS2+4T0OhYWHiOgUEAFKa3D9igBuuiTA5CkDALBIqLhQaEtKYtKmTmkZ
G/p2772xe2bX/FOO/NnWYCiohvbvX56amFoGk0NgaB00AP/cBd+nhHx+/f7Xn/XIyd2ZtHL96gG7
C/J65BUX9i0rK+sb1SrIQDWhJ69Gf93PIUOBQE4THgYzfwgbt0d/yl4GYJ+Y/LVpq2lyLFQIAIEx
WZM082+JaFItRdBQrJ89y4ABqcHugkTXfUoEn7RKAXDQ788PBUK7NGsLxgowtBAioaPRaEJZRXkP
AnRU2Umaq1qleFEppyEncYNC7yzg0bUE/1NB9JfKhVs/BYDWCvE16rPt6xPUwqkr4H6wOhSBE/ag
mMnV0PVpqhmKIefGk9PHxjSzMLQiRBR7GL0QNPYMQdc7eAHwBjkLUqBOwa86RpuV0GsfR7mj4Zyb
AiAwMmsSC54CxlmQIgnMTtZ045WBhyf1e/Q0MxhaSrU8k8Y+i9WEnuAOcsUgvEuaXq5cEhN8gcmg
fW3u10X7ykktUyc0rHsPJelCEM4B43BYQkIz3PRib7Ug7WWqYDC0B45pX/WMSghyumk6jXXmgfG2
VPyf8NJt2e57akyN24OOIUSTXSdgtRvhH9lzCIQ+FRrnAjwSUoZi4RLtNL6Ep2EBN53A/a2jfC7D
gUZV3n3N506AXGH3nlGlwgAtgcBb0OKDyJItK2JHqeN5by86mqAQJkC665pjk/jgYd2ydFSMYcIx
AEYSeAhAmc4NJ08ZODidC9v8wg0HAUS1ks3dZ08zAM5h0AoAS4jxtfDphRULtm+tvnddz3Z709EU
QHUEJkDUecNG9EqxRHQwQfYE8ygCUgGMAbNmoDsJ6oaqAIHB0FIYBGLN2wnYBiIBYCEDBSBazFBb
bO1biR83F9Z6nyf0Gh20N8b/AyAsBqhc3MRDAAAAAElFTkSuQmCC
:::END
:::BEGIN assets/planificador.png|b64
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
ICwGqFzcxEMAAAAASUVORK5CYII=
:::END
:::BEGIN herramientas/descargar_python.ps1|text
# Descarga el instalador de Python para Windows (64 bits) a la ruta indicada.
# Busca en python.org la version 3.13 mas reciente que tenga instalador y,
# si no puede, prueba con una lista de versiones conocidas.
param([string]$Destino)

$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$base = 'https://www.python.org/ftp/python/'

$candidatas = @()
try {
    $html = (Invoke-WebRequest -UseBasicParsing -Uri $base -TimeoutSec 30).Content
    $candidatas = @([regex]::Matches($html, '3\.13\.\d+(?=/)') |
        ForEach-Object { $_.Value } |
        Sort-Object { [version]$_ } -Descending -Unique)
} catch { }

$respaldo = @('3.13.9', '3.13.7', '3.13.5', '3.13.3', '3.12.10')
$versiones = @($candidatas) + @($respaldo) | Select-Object -Unique

foreach ($v in $versiones) {
    $url = "$base$v/python-$v-amd64.exe"
    try {
        Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $Destino -TimeoutSec 600
        if ((Test-Path -LiteralPath $Destino) -and ((Get-Item -LiteralPath $Destino).Length -gt 1MB)) {
            Write-Host "      Descargado Python $v"
            exit 0
        }
    } catch { }
    if (Test-Path -LiteralPath $Destino) { Remove-Item -LiteralPath $Destino -Force }
}
exit 1
:::END
