@echo off
chcp 65001 >nul
setlocal EnableExtensions
title Viajes 1.7.0 - Instalador
color 0F

set "SELF=%~f0"
set "SELF_DIR=%~dp0"
if "%SELF_DIR:~-1%"=="\" set "SELF_DIR=%SELF_DIR:~0,-1%"
for %%I in ("%SELF_DIR%") do set "SELF_NAME=%%~nxI"
set "INSTALL_DIR=%SELF_DIR%"
if /i "%SELF_NAME%"=="instaladores" for %%I in ("%SELF_DIR%\..") do set "INSTALL_DIR=%%~fI"
set "WORKDIR=%TEMP%\viajes_instalador_%RANDOM%"
mkdir "%WORKDIR%" >nul 2>&1
set "VJ_WORK=%WORKDIR%"
set "VJ_SELF=%SELF%"
set "VJ_DIR=%INSTALL_DIR%"
rem Con ventana (lo normal): PowerShell extrae el asistente y lo abre oculto; esta consola se cierra y el cuervo va en la ventana.
rem Con -Silencioso se instala aqui mismo, en la consola, con el banner.
set "VJ_GUI=1"
echo %* | findstr /i /c:"-Silencioso" >nul && set "VJ_GUI="

powershell -NoProfile -ExecutionPolicy Bypass -Command "$l=Get-Content -LiteralPath '%SELF%' -Encoding UTF8; $s=($l | Select-String -SimpleMatch ':::PSSTART' | Select-Object -Last 1).LineNumber; $e=($l | Select-String -SimpleMatch ':::PSEND' | Select-Object -Last 1).LineNumber; $l[$s..($e-2)] | Set-Content -LiteralPath '%WORKDIR%\instalador.ps1' -Encoding UTF8; if ($env:VJ_GUI) { $q=[char]34; $a=('-NoProfile -ExecutionPolicy Bypass -STA -File '+$q+$env:VJ_WORK+'\instalador.ps1'+$q+' -Self '+$q+$env:VJ_SELF+$q+' -DirPorDefecto '+$q+$env:VJ_DIR+$q+' -LimpiarTemp'); $i=New-Object Diagnostics.ProcessStartInfo('powershell',$a); $i.UseShellExecute=$false; $i.CreateNoWindow=$true; [void][Diagnostics.Process]::Start($i) }"
if not exist "%WORKDIR%\instalador.ps1" (
    echo No se ha podido preparar el instalador ^(fallo al extraer el script^).
    pause
    exit /b 1
)

if defined VJ_GUI exit /b 0

:consola
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; $l=[IO.File]::ReadAllLines('%~f0',[Text.Encoding]::UTF8); $a=[Array]::IndexOf($l,':::BANNERSTART'); $b=[Array]::IndexOf($l,':::BANNEREND'); foreach($t in $l[($a+1)..($b-1)]){ $p=$t.Split([char]0xA7); Write-Host -NoNewline $p[0] -ForegroundColor DarkCyan; if($p.Length -gt 1){ Write-Host -NoNewline 'O' -ForegroundColor DarkYellow; Write-Host $p[1] -ForegroundColor DarkCyan } else { Write-Host '' } }; $a=[Array]::IndexOf($l,':::TITULOSTART'); $b=[Array]::IndexOf($l,':::TITULOEND'); $l[($a+1)..($b-1)] | ForEach-Object { Write-Host $_ -ForegroundColor White }"
echo.
powershell -NoProfile -ExecutionPolicy Bypass -STA -File "%WORKDIR%\instalador.ps1" -Self "%SELF%" -DirPorDefecto "%INSTALL_DIR%" %*
set "RC=%ERRORLEVEL%"
rmdir /s /q "%WORKDIR%" >nul 2>&1
if not "%RC%"=="0" pause
exit /b %RC%

:::PSSTART
# Asistente de instalacion de Viajes 1.7.0 (Windows PowerShell 5.1, ventana WinForms).
# Lo arranca el .bat con:  -Self <ruta del .bat> -DirPorDefecto <carpeta>   (el .bat lleva los ficheros del programa dentro).
# Opciones para pruebas o instalacion sin ventana:
#   -Silencioso -Destino <carpeta>   instala sin ventana, con las opciones por defecto
#   -SinRed       no descarga Python ni instala librerias      -SinAccesos   ni accesos directos ni desinstalador
#   -NombreAcceso <texto>   nombre de los accesos directos (por defecto, el del programa)
#   -Captura <carpeta>      guarda una imagen de cada pagina de la ventana y sale
#   -LimpiarTemp            (lo pone el .bat) borra al terminar la carpeta temporal donde esta este script
param(
    [string]$Self, [string]$DirPorDefecto, [string]$Destino,
    [switch]$Silencioso, [switch]$SinRed, [switch]$SinAccesos,
    [string]$NombreAcceso, [string]$Captura, [switch]$LimpiarTemp)

$App = @{ Nombre = 'Viajes'; Version = '1.7.0'; Comprueba = 'py\app_vuelos.py'; Lanzador = 'py\vuelos_app.pyw'
          Reqs = 'py\requirements.txt'; Icono = 'assets\vuelos.ico'; Imports = 'streamlit, plotly, pandas, pyarrow, fast_flights, primp, pystray, PIL, selectolax'; PipExtra = 'pywebview'; ExtraImport = 'webview'
          Datos = 'csv\, config_vuelos.json...'; Carpetas = @('csv'); Programa = @('py', 'assets', 'herramientas') }
if (-not $NombreAcceso) { $NombreAcceso = $App.Nombre }
$CuervoPng = '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'      # el cuervo del banner (lo dibuja generar_instaladores.py a partir de plantillas/cuervo.txt)
$NombrePng = 'iVBORw0KGgoAAAANSUhEUgAAAYoAAABgCAYAAAAD1jVAAAAEnElEQVR42u3dMW4cNxQG4F+GuvgqEVIG0AKB2611C7lwZx/BPsCewqnVRgEkwKWxp0mXFJIBx1CysndmyUd+XyMVAobz9GbfEuTwnV3c3fyd47zab7a3aaT1+HuP3wLjW1vT/GltgPzNyPklPg9eBAAUCgAUCgAUCgAUCgA6c7bSqv79frPdpMaukaPG33v8iu7aOFn+pP6upx7zd5j8Ep8H51l4e9XF3c1Vkjcpuj2swfirx8/9i5/4DB6fJQrFHxd3N19+3yW5LRao1uOvHj/3L37iM3h8XixUkc6SfChcUVuOv3r83L/4ic/g8bGYDUAUCgAUCgAUCgAaWGLX0y95WCn/LclPSf5K8nOhGLQe/1HXH2Cf99e7LpLk+pv7mvp02Qmev1MRnyPiY0YBwOozis+PP/9M8jLJpyS/FopB6/G3vv7s/TCqGzp/FiQ+R8THjAKAWMwGQKEAQKEAQKEAIAPueiJD9EV4n+Rt+n/PIpmoX4X8WdROfH4sPgoF/0qU/Wb7urPtsfoJTJw/K3xgX4nP98dHoeCpRPmonwCD5M9T7sXn++KjUNB7K9ZX+8329nHq/tK/Ritb8YnFbAAUCgAUCgAUCgDiPYroRzHB9Q/1g9BvQf62zJ/q/Uh6f76eFV8zCgD0o9CPIvotiA/EGgUACgUACgUACgUACgUAsesJIPqRzBBfhQLomX4kHcRXoQCqfOPVj6RRfK1RAL1/4z1L8kEo2sVXoQAgCgUACgUACgUAqfkexaHz1o86T/6E57bP2o8iI/dbWCB/eu+HMEv+eD4a5o8ZBQD/P6N43BqVi7ub93k4z/42yZsvb+Z11Ilp7W+Es/ajWPUb8wL5o9/CxPnT+vk89PnY2qmeLzMKAGIxGwCFAgCFAgCFAoAUeY/icsHdTl2cJ/+4a+HtgT/bzZoIz4wPtMyfXp7PywF2gx5XKPab7e9JztZ6YanxefK7/Wb7+kDCX038vB+MT8cvTDJg/vT2fH77+TjA9tgfKhTXF3c31xn4PPnHRPt44M/uJ/5m+Jz4QMv8afV8rvH5WGtGsd9s3yV5t9YRCF+9sNIDrRRPFB8zCvkzgv/6fJxlRmExGwCFAgCFAgCFAoAU7UeRI/tVZPLz7Fv3E+i9n0Hr8T31HlD0a+ju+c4ap9tOsBlDPwoATjCjKNCvovd+E+m8n8DnkeMzQL+V6vlN6vczMaMAIBazAVAoAFAoAFAoAMgg71F0dx67fhOM3E9Afqd0P5zpCsUK/Sqi3wRp1E+gWMGQ3yndD2eaQtH9eez6TTByPwH5XbsfzvCFYsV+FXEePq36CRQ9okF+1+6HE4vZACgUACgUAKBQAJAu+lFk8n4TVcbfe/yq/3/dv/iVjY8ZBQDrzigOnfd/Qk3O41/w/lfpt9A6fhONr2R+F7r/JvETHzMKAGIxGwCFAgCFAgCFAoBM9R5Fq/P+d8X7HewGuf6s4xslvy+LHpbY+/NVNj7na5/3nzbHMKeXfgenHn/r688+vur53fv9t47frPE5H/S8//vi/Q7ui17f+Grnd/l+HUWer1nzCwAAAAAAAAAAAAB68A8hTQQ+ifwm1wAAAABJRU5ErkJggg=='      # el nombre del programa en letras grandes
$Pasos = @('Extraer los ficheros del programa', 'Buscar Python 3.10+ (o instalarlo en la carpeta)', 'Instalar las librerías necesarias',
           'Comprobar que todo carga', 'Crear los accesos directos', 'Registrar el desinstalador')

# ---- desinstalador: se escribe en %LOCALAPPDATA% al instalar (con @DIR@ etc. ya sustituidos), asi no ensucia la carpeta del programa
$PlantillaDes = @'
param([switch]$Silencioso, [switch]$ConDatos)
Add-Type -AssemblyName System.Windows.Forms
$Dir = '@DIR@'; $Nombre = '@NOMBRE@'; $Acceso = '@ACCESO@'; $Programa = @(@PROGRAMA@); $Reg = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\@NOMBRE@'
$git = Test-Path -LiteralPath (Join-Path $Dir '.git')
if (-not $Silencioso) {
    $t = "Se van a quitar los accesos directos de $Nombre y su entrada en Aplicaciones de Windows."
    if ($git) { $t += "`n`nEsta carpeta es de desarrollo (tiene git): sus ficheros no se borran." } else { $t += "`n`nTambién se borrará el programa de:`n$Dir`n`nTus datos se conservan salvo que lo pidas en la siguiente pregunta." }
    if ([Windows.Forms.MessageBox]::Show($t + "`n`n¿Desinstalar?", "Desinstalar $Nombre", 'YesNo', 'Question') -ne 'Yes') { return }
    if (-not $git -and [Windows.Forms.MessageBox]::Show("¿Borrar también tus datos (descargas, ajustes...)?`nSi dices que no, se quedan en la carpeta.", "Desinstalar $Nombre", 'YesNo', 'Warning') -eq 'Yes') { $ConDatos = $true }
}
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -and $_.CommandLine -like "*$Dir*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
$w = New-Object -ComObject WScript.Shell
foreach ($c in 'Desktop', 'Programs', 'Startup') { $f = Join-Path $w.SpecialFolders($c) "$Acceso.lnk"; if (Test-Path -LiteralPath $f) { Remove-Item -LiteralPath $f -Force } }
Remove-Item -Path $Reg -Recurse -Force -ErrorAction SilentlyContinue
if (-not $git -and (Test-Path -LiteralPath $Dir)) {
    if ($ConDatos) { Remove-Item -LiteralPath $Dir -Recurse -Force -ErrorAction SilentlyContinue }
    else {
        foreach ($p in $Programa + 'python') { $r = Join-Path $Dir $p; if (Test-Path -LiteralPath $r) { Remove-Item -LiteralPath $r -Recurse -Force -ErrorAction SilentlyContinue } }
        if (-not (Get-ChildItem -LiteralPath $Dir -Force)) { Remove-Item -LiteralPath $Dir -Force -ErrorAction SilentlyContinue }
    }
}
if (-not $Silencioso) { [void][Windows.Forms.MessageBox]::Show("$Nombre se ha desinstalado.", "Desinstalar $Nombre", 'OK', 'Information') }
'@

# ---- el trabajo de instalar corre en otro hilo (runspace) y avisa a la ventana por una cola
$Trabajo = {
    param($Q, $O, $App, $Self, $PlantillaDes, $Acceso)
    $ErrorActionPreference = 'Continue'
    $ProgressPreference = 'SilentlyContinue'
    try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }
    $env:PYTHONIOENCODING = 'utf-8'
    $R = @{ rc = 0 }
    function Msg($t, $a, $b) { $Q.Enqueue([pscustomobject]@{ T = $t; A = $a; B = $b }) }
    function Log($s) { Msg 'log' $s }
    function Paso($i, $e) { Msg 'paso' $i $e }
    function Prog($p) { Msg 'prog' $p }
    function Ejecutar($exe, [string[]]$a) { & $exe @a 2>&1 | ForEach-Object { $s = "$_".TrimEnd(); if ($s) { Log $s } }; $R.rc = $LASTEXITCODE }
    function Probar($e) { if (-not $e -or -not (Test-Path -LiteralPath $e)) { return $false }; try { & $e -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)" 2>$null | Out-Null; return ($LASTEXITCODE -eq 0) } catch { return $false } }
    $dest = $O.Dest
    $paso = 0
    try {
        # 1. extraer
        Paso 0 'curso'; Prog 3
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        $prueba = Join-Path $dest '.prueba_escritura'
        Set-Content -LiteralPath $prueba -Value 'x' -ErrorAction Stop; Remove-Item -LiteralPath $prueba -Force
        $enc = New-Object Text.UTF8Encoding($false)
        $lineas = [IO.File]::ReadAllLines($Self, $enc)
        $i = 0; $n = 0
        while ($i -lt $lineas.Length) {
            $l = $lineas[$i]
            if ($l.StartsWith(':::BEGIN ')) {
                $p = $l.Substring(9).Trim().Split('|'); $rel = $p[0]; $modo = $p[1]
                $j = $i + 1; $buf = New-Object System.Collections.Generic.List[string]
                while ($j -lt $lineas.Length -and -not $lineas[$j].StartsWith(':::END')) { $buf.Add($lineas[$j]); $j++ }
                $d = Join-Path $dest $rel
                $c = Split-Path -Parent $d
                if (-not (Test-Path -LiteralPath $c)) { New-Item -ItemType Directory -Path $c -Force | Out-Null }
                if ($modo -eq 'b64') { [IO.File]::WriteAllBytes($d, [Convert]::FromBase64String(($buf -join ''))) }
                else { [IO.File]::WriteAllText($d, (($buf -join "`r`n") + "`r`n"), $enc) }
                $n++; Log "  $rel"
                $i = $j
            }
            $i++
        }
        if (-not (Test-Path -LiteralPath (Join-Path $dest $App.Comprueba))) { throw "No se ha podido extraer $($App.Comprueba)." }
        foreach ($c in $App.Carpetas) { New-Item -ItemType Directory -Path (Join-Path $dest $c) -Force | Out-Null }
        Log "$n ficheros en $dest"; Paso 0 'ok'; Prog 15

        # 2. python
        $paso = 1; Paso 1 'curso'
        $py = $null
        $cand = @(Join-Path $dest 'python\python.exe')
        if (Get-Command py -ErrorAction SilentlyContinue) { $cand += ("$(& py -3 -c 'import sys; print(sys.executable)' 2>$null)").Trim() }
        if (Get-Command python -ErrorAction SilentlyContinue) { $cand += ("$(& python -c 'import sys; print(sys.executable)' 2>$null)").Trim() }
        foreach ($e in $cand) { if (-not $py -and (Probar $e)) { $py = $e } }
        if (-not $py) {
            if ($O.SinRed) { throw 'No hay un Python 3.10 o superior (y está activado -SinRed).' }
            Log 'No hay un Python válido: se descarga e instala DENTRO de la carpeta (subcarpeta python).'
            Log '(puede tardar 1-2 minutos; hace falta internet)'
            $inst = Join-Path $env:TEMP 'python-instalador.exe'
            & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $dest 'herramientas\descargar_python.ps1') $inst 2>&1 | ForEach-Object { Log "$_" }
            if (-not (Test-Path -LiteralPath $inst)) { throw 'No se ha podido descargar Python. Revisa la conexión a internet y vuelve a intentarlo.' }
            Start-Process -FilePath $inst -ArgumentList @('/quiet', "TargetDir=$dest\python", 'InstallAllUsers=0', 'PrependPath=0', 'Include_pip=1', 'Include_tcltk=1', 'Include_test=0', 'Include_launcher=0') -Wait
            $py = Join-Path $dest 'python\python.exe'
            if (-not (Test-Path -LiteralPath $py)) { throw 'Ha fallado la instalación de Python en la carpeta. Borra la subcarpeta python y vuelve a intentarlo.' }
        }
        Log "Python: $py"; Paso 1 'ok'; Prog 30

        # 3. librerias
        $paso = 2; Paso 2 'curso'
        if ($O.SinRed) { Log 'Omitido (-SinRed).'; Paso 2 'aviso' }
        else {
            Ejecutar $py @('-m', 'pip', 'install', '--upgrade', 'pip', '--disable-pip-version-check', '-q')
            Ejecutar $py @('-m', 'pip', 'install', '--disable-pip-version-check', '--no-warn-script-location', '-r', (Join-Path $dest $App.Reqs))
            if ($R.rc -ne 0) { throw 'Alguna librería no se ha podido instalar (suele ser falta de conexión). Vuelve a ejecutar el instalador: lo ya instalado no se repite.' }
            Paso 2 'ok'
        }
        Prog 70

        # 4. comprobar
        $paso = 3; Paso 3 'curso'
        Ejecutar $py @('-c', "import $($App.Imports)")
        if ($R.rc -ne 0) { Log 'Alguna librería no carga bien: el programa puede arrancar, pero conviene volver a ejecutar el instalador.'; Paso 3 'aviso' }
        elseif ($App.PipExtra) {
            Ejecutar $py @('-c', "import $($App.ExtraImport)")
            if ($R.rc -ne 0 -and -not $O.SinRed) { Log "Instalando $($App.PipExtra) (ventana propia; si falla se usará Edge)..."; Ejecutar $py @('-m', 'pip', 'install', '--disable-pip-version-check', '--no-warn-script-location', $App.PipExtra) }
            Paso 3 'ok'
        } else { Paso 3 'ok' }
        Prog 80

        # 5. accesos
        $paso = 4; Paso 4 'curso'
        $pyw = $py -replace 'python\.exe$', 'pythonw.exe'
        $lanza = Join-Path $dest $App.Lanzador
        if ($O.SinAccesos) { Log 'Omitido (-SinAccesos).'; Paso 4 'aviso' }
        else {
            $w = New-Object -ComObject WScript.Shell
            function Acceso($carpeta, $oculto) {
                $s = $w.CreateShortcut((Join-Path $w.SpecialFolders($carpeta) "$Acceso.lnk"))
                $s.TargetPath = $pyw; $s.Arguments = '"' + $lanza + '"'; $s.WorkingDirectory = (Split-Path -Parent $lanza)
                $s.IconLocation = (Join-Path $dest $App.Icono); $s.Description = "$($App.Nombre) $($App.Version)"
                if ($oculto) { $s.WindowStyle = 7 }
                $s.Save(); Log "Acceso: $carpeta\$Acceso.lnk"
            }
            if ($O.Escritorio) { Acceso 'Desktop' $false }
            if ($O.Inicio) { Acceso 'Programs' $false }
            if ($O.Arranque) { Acceso 'Startup' $true }
            Paso 4 'ok'
        }
        Prog 92

        # 6. desinstalador (en %LOCALAPPDATA%) y entrada en Aplicaciones de Windows
        $paso = 5; Paso 5 'curso'
        if ($O.SinAccesos) { Paso 5 'aviso' }
        else {
            $dd = Join-Path $env:LOCALAPPDATA "$($App.Nombre)\Desinstalar"
            New-Item -ItemType Directory -Path $dd -Force | Out-Null
            $prog = ($App.Programa | ForEach-Object { "'$_'" }) -join ', '
            $txt = $PlantillaDes.Replace('@DIR@', $dest).Replace('@NOMBRE@', $App.Nombre).Replace('@ACCESO@', $Acceso).Replace('@PROGRAMA@', $prog)
            [IO.File]::WriteAllText((Join-Path $dd 'desinstalar.ps1'), $txt, (New-Object Text.UTF8Encoding($true)))
            [IO.File]::WriteAllText((Join-Path $dd 'Desinstalar.bat'), "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -STA -File `"%~dp0desinstalar.ps1`" %*`r`n", (New-Object Text.UTF8Encoding($false)))
            $k = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$($App.Nombre)"
            New-Item -Path $k -Force | Out-Null
            $v = @{ DisplayName = "$($App.Nombre) $($App.Version)"; DisplayVersion = $App.Version; Publisher = 'Kuerb0'; InstallLocation = $dest
                    DisplayIcon = (Join-Path $dest $App.Icono); UninstallString = '"' + (Join-Path $dd 'Desinstalar.bat') + '"' }
            foreach ($nombre in $v.Keys) { Set-ItemProperty -Path $k -Name $nombre -Value $v[$nombre] }
            Set-ItemProperty -Path $k -Name NoModify -Value 1 -Type DWord; Set-ItemProperty -Path $k -Name NoRepair -Value 1 -Type DWord
            Log "Desinstalador: $dd"; Paso 5 'ok'
        }
        Prog 100
        Msg 'fin' $true $pyw
    } catch {
        Log "ERROR: $($_.Exception.Message)"
        Paso $paso 'fallo'
        Msg 'fin' $false $null
    }
}

# ---- opciones de partida
$dir0 = if ($Destino) { $Destino } else { $DirPorDefecto }
$Opc = @{ Dest = $dir0; Escritorio = $true; Inicio = $true; Arranque = $false; SinRed = [bool]$SinRed; SinAccesos = [bool]$SinAccesos }
$Q = New-Object 'System.Collections.Concurrent.ConcurrentQueue[object]'

function Lanzar-Trabajo {
    $script:ps = [powershell]::Create()
    [void]$script:ps.AddScript($Trabajo.ToString()).AddArgument($Q).AddArgument($Opc).AddArgument($App).AddArgument($Self).AddArgument($PlantillaDes).AddArgument($NombreAcceso)
    $script:h = $script:ps.BeginInvoke()
}

if ($Silencioso) {
    Lanzar-Trabajo
    $ok = $false
    while (-not $h.IsCompleted -or -not $Q.IsEmpty) {
        $m = $null
        while ($Q.TryDequeue([ref]$m)) {
            switch ($m.T) { 'log' { Write-Host "  $($m.A)" } 'paso' { if ($m.B -ne 'curso') { Write-Host ("[{0}] {1}" -f $m.B, $Pasos[$m.A]) } } 'fin' { $ok = $m.A } }
        }
        Start-Sleep -Milliseconds 150
    }
    exit $(if ($ok) { 0 } else { 1 })
}

# ---- ventana
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
$cFondo = [Drawing.Color]::FromArgb(11, 15, 20); $cPanel = [Drawing.Color]::FromArgb(17, 23, 30); $cCian = [Drawing.Color]::FromArgb(46, 196, 182)
$cOro = [Drawing.Color]::FromArgb(224, 165, 38); $cBlanco = [Drawing.Color]::FromArgb(242, 245, 247); $cGris = [Drawing.Color]::FromArgb(139, 152, 165)
$cVerde = [Drawing.Color]::FromArgb(61, 220, 132); $cRojo = [Drawing.Color]::FromArgb(255, 92, 92)
$fMono = { param($t, $s) New-Object Drawing.Font('Consolas', [single]$t, [Drawing.FontStyle]$s) }

$f = New-Object Windows.Forms.Form
$f.Text = "Instalador de $($App.Nombre) $($App.Version)"; $DW = 780; $DH = 570                                  # tamano de diseno: todo se dibuja a este tamano y se escala segun la ventana
$pantalla = [Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$s0 = [Math]::Min(2.0, [Math]::Min($pantalla.Width * 0.92 / $DW, $pantalla.Height * 0.92 / $DH))      # al abrir: lo mas grande que cabe (hasta el doble)
$f.ClientSize = New-Object Drawing.Size([int]($DW * $s0), [int]($DH * $s0)); $f.StartPosition = 'CenterScreen'
$f.FormBorderStyle = 'Sizable'; $f.MaximizeBox = $true; $f.MinimumSize = New-Object Drawing.Size(($DW + $f.Width - $f.ClientSize.Width), ($DH + $f.Height - $f.ClientSize.Height)); $f.BackColor = $cFondo; $f.ForeColor = $cGris; $f.Font = & $fMono 10 'Regular'
$ico = Join-Path (Split-Path -Parent $Self) $App.Icono
if (Test-Path -LiteralPath $ico) { try { $f.Icon = New-Object Drawing.Icon($ico) } catch { } }

function Etiqueta($texto, $x, $y, $w, $h, $color, $fuente) {
    $l = New-Object Windows.Forms.Label; $l.Text = $texto; $l.Location = New-Object Drawing.Point($x, $y); $l.Size = New-Object Drawing.Size($w, $h)
    $l.ForeColor = $color; $l.BackColor = [Drawing.Color]::Transparent; if ($fuente) { $l.Font = $fuente }; return $l
}
function Boton($texto, $x) {
    $b = New-Object Windows.Forms.Button; $b.Text = $texto; $b.Size = New-Object Drawing.Size(130, 34); $b.Location = New-Object Drawing.Point($x, 530)
    $b.FlatStyle = 'Flat'; $b.FlatAppearance.BorderColor = $cCian; $b.BackColor = $cFondo; $b.ForeColor = $cCian; $b.Cursor = 'Hand'
    $b.FlatAppearance.MouseOverBackColor = [Drawing.Color]::FromArgb(20, 44, 48); return $b
}

# cabecera: el cuervo a la izquierda; a la derecha el nombre en letras grandes, que es el instalador y la version
function Imagen($b64, $x, $y) {
    $i = [Drawing.Image]::FromStream((New-Object IO.MemoryStream(, [Convert]::FromBase64String($b64))))
    $p = New-Object Windows.Forms.PictureBox; $p.Image = $i; $p.SizeMode = 'Zoom'; $p.Size = $i.Size; $p.Location = New-Object Drawing.Point($x, $y); $p.BackColor = $cFondo; $f.Controls.Add($p); return $i
}
$iCuervo = Imagen $CuervoPng 18 10
$xd = 18 + $iCuervo.Width + 26
$null = Imagen $NombrePng $xd 28
$f.Controls.Add((Etiqueta 'INSTALADOR' $xd 142 200 30 $cBlanco (& $fMono 18 'Bold')))
$f.Controls.Add((Etiqueta "V E R S I Ó N   $($App.Version)" ($xd + 200) 150 300 22 $cCian (& $fMono 11 'Regular')))
$f.Controls.Add((Etiqueta "KUERB0  ·  Without data, you’re just another person with an opinion" $xd 178 (762 - $xd) 18 $cGris (& $fMono 8.5 'Italic')))
$linea = New-Object Windows.Forms.Panel; $linea.Location = New-Object Drawing.Point(18, 202); $linea.Size = New-Object Drawing.Size(744, 2); $linea.BackColor = $cCian; $linea.Anchor = 'Top,Left,Right'; $f.Controls.Add($linea)

function Pagina { $p = New-Object Windows.Forms.Panel; $p.Location = New-Object Drawing.Point(18, 214); $p.Size = New-Object Drawing.Size(744, 300); $p.BackColor = $cFondo; $p.Anchor = 'Top,Left,Right,Bottom'; $p.Visible = $false; $f.Controls.Add($p); return $p }
$p1 = Pagina; $p2 = Pagina; $p3 = Pagina; $p4 = Pagina

# pagina 1: bienvenida
$p1.Controls.Add((Etiqueta "Bienvenido al instalador de $($App.Nombre). Esto va a:" 4 4 730 24 $cBlanco (& $fMono 11 'Bold')))
$p1.Controls.Add((Etiqueta ("  [1] Copiar el programa en la carpeta que elijas`r`n  [2] Buscar Python 3.10+ o, si no hay, instalar uno EN ESA CARPETA`r`n        (no hace falta ser administrador)`r`n  [3] Instalar las librerías que necesita el programa`r`n  [4] Crear los accesos directos que quieras`r`n  [5] Dejar un desinstalador en «Aplicaciones» de Windows") 4 44 730 130 $cGris $null))
$p1.Controls.Add((Etiqueta ("Tus datos ($($App.Datos)) no se tocan si ya existen.`r`nTodo se queda en la carpeta elegida. No se manda ni se guarda`r`nningún dato tuyo en ningún sitio ajeno.") 4 200 730 70 $cVerde $null))

# pagina 2: opciones
$p2.Controls.Add((Etiqueta 'Carpeta de instalación' 4 4 730 24 $cBlanco (& $fMono 11 'Bold')))
$tbDir = New-Object Windows.Forms.TextBox; $tbDir.Location = New-Object Drawing.Point(4, 38); $tbDir.Size = New-Object Drawing.Size(590, 26); $tbDir.Text = $Opc.Dest
$tbDir.BackColor = $cPanel; $tbDir.ForeColor = $cBlanco; $tbDir.BorderStyle = 'FixedSingle'; $tbDir.Anchor = 'Top,Left,Right'; $p2.Controls.Add($tbDir)
$bExam = Boton 'Examinar...' 604; $bExam.Location = New-Object Drawing.Point(604, 34); $bExam.Size = New-Object Drawing.Size(130, 30); $bExam.Anchor = 'Top,Right'; $p2.Controls.Add($bExam)
$bExam.Add_Click({ $d = New-Object Windows.Forms.FolderBrowserDialog; $d.SelectedPath = $tbDir.Text; if ($d.ShowDialog() -eq 'OK') { $tbDir.Text = $d.SelectedPath } })
$p2.Controls.Add((Etiqueta 'Elige una carpeta donde puedas escribir (una de OneDrive también vale).' 4 70 730 20 $cGris (& $fMono 9 'Italic')))
$p2.Controls.Add((Etiqueta 'Accesos directos' 4 118 730 24 $cBlanco (& $fMono 11 'Bold')))
function Casilla($texto, $y, $marcada) { $c = New-Object Windows.Forms.CheckBox; $c.Text = $texto; $c.Location = New-Object Drawing.Point(8, $y); $c.Size = New-Object Drawing.Size(720, 26); $c.Checked = $marcada; $c.ForeColor = $cBlanco; $c.FlatStyle = 'Flat'; $c.Cursor = 'Hand'; $p2.Controls.Add($c); return $c }
$ckEsc = Casilla 'Acceso directo en el Escritorio' 150 $true
$ckIni = Casilla 'Entrada en el menú Inicio' 180 $true
$ckArr = Casilla "Arrancar $($App.Nombre) solo al encender el ordenador" 210 $false

# pagina 3: instalando
$lbPasos = @()
for ($k = 0; $k -lt $Pasos.Count; $k++) { $l = Etiqueta "" 4 (4 + 26 * $k) 730 22 $cGris $null; $p3.Controls.Add($l); $lbPasos += $l }
$pista = New-Object Windows.Forms.Panel; $pista.Location = New-Object Drawing.Point(4, 168); $pista.Size = New-Object Drawing.Size(690, 16); $pista.BackColor = $cPanel; $pista.Anchor = 'Top,Left,Right'; $p3.Controls.Add($pista)
$relleno = New-Object Windows.Forms.Panel; $relleno.Location = New-Object Drawing.Point(0, 0); $relleno.Size = New-Object Drawing.Size(0, 16); $relleno.BackColor = $cCian; $pista.Controls.Add($relleno)
$lbPct = Etiqueta '0 %' 700 166 44 20 $cCian $null; $lbPct.Anchor = 'Top,Right'; $p3.Controls.Add($lbPct)
$rtLog = New-Object Windows.Forms.RichTextBox; $rtLog.Location = New-Object Drawing.Point(4, 196); $rtLog.Size = New-Object Drawing.Size(730, 100); $rtLog.ReadOnly = $true
$rtLog.BackColor = [Drawing.Color]::FromArgb(7, 10, 14); $rtLog.ForeColor = $cGris; $rtLog.Font = & $fMono 8.5 'Regular'; $rtLog.BorderStyle = 'None'; $rtLog.Anchor = 'Top,Left,Right,Bottom'; $p3.Controls.Add($rtLog)

# pagina 4: fin
$lbFin = Etiqueta '' 4 4 730 30 $cVerde (& $fMono 14 'Bold'); $p4.Controls.Add($lbFin)
$lbFin2 = Etiqueta '' 4 50 730 120 $cGris $null; $p4.Controls.Add($lbFin2)
$ckAbrir = New-Object Windows.Forms.CheckBox; $ckAbrir.Text = "Abrir $($App.Nombre) al terminar"; $ckAbrir.Location = New-Object Drawing.Point(8, 190); $ckAbrir.Size = New-Object Drawing.Size(500, 26)
$ckAbrir.Checked = $true; $ckAbrir.ForeColor = $cBlanco; $ckAbrir.FlatStyle = 'Flat'; $ckAbrir.Cursor = 'Hand'; $p4.Controls.Add($ckAbrir)

$bAtras = Boton '< Atrás' 328; $bSig = Boton 'Siguiente >' 468; $bCan = Boton 'Cancelar' 632
foreach ($b in $bAtras, $bSig, $bCan) { $b.Anchor = 'Bottom,Right' }
$f.Controls.AddRange(@($bAtras, $bSig, $bCan))
$estado = @{ pagina = 1; pyw = $null; trabajando = $false; pct = 0 }
$pista.Add_Resize({ $relleno.Size = New-Object Drawing.Size([int]($pista.Width * $estado.pct / 100), $pista.Height) })

# escalado: cada control guarda su tamano de diseno; al cambiar la ventana todo se redimensiona por igual (letra incluida) y se centra
function Registrar($c) { foreach ($h in $c.Controls) { if ($h -eq $relleno) { continue }; $h.Tag = @{ B = $h.Bounds; F = $h.Font.Size }; $h.Anchor = 'Top,Left'; Registrar $h } }
function Escalar($c, $s, $ox) {
    foreach ($h in $c.Controls) {
        if ($h.Tag -isnot [hashtable]) { continue }
        $b = $h.Tag.B
        $x = [int]($b.X * $s) + $(if ($c -eq $f) { $ox } else { 0 })
        $h.Bounds = New-Object Drawing.Rectangle($x, [int]($b.Y * $s), [int]($b.Width * $s), [int]($b.Height * $s))
        $tam = [single]($h.Tag.F * $s)
        if ([Math]::Abs($h.Font.Size - $tam) -gt 0.05) { $h.Font = New-Object Drawing.Font($h.Font.FontFamily, $tam, $h.Font.Style) }
        Escalar $h $s 0
    }
}
function Reajustar {
    $w = $f.ClientSize.Width; $h = $f.ClientSize.Height
    if ($w -lt 50 -or $h -lt 50) { return }
    $s = [Math]::Min($w / $DW, $h / $DH)
    $f.SuspendLayout(); Escalar $f $s ([int](($w - $DW * $s) / 2)); $f.ResumeLayout()
}
Registrar $f
$f.Add_Resize({ Reajustar })
$f.Add_Shown({ Reajustar })

function Pintar-Paso($k, $e) {
    $glifo, $col = switch ($e) { 'ok' { '[ OK ]', $cVerde } 'curso' { '[ >> ]', $cCian } 'fallo' { '[FAIL]', $cRojo } 'aviso' { '[WARN]', $cOro } default { '[    ]', $cGris } }
    $lbPasos[$k].Text = "$glifo  $($Pasos[$k])"; $lbPasos[$k].ForeColor = $col
}
function Ir($n) {
    $estado.pagina = $n
    $p1.Visible = ($n -eq 1); $p2.Visible = ($n -eq 2); $p3.Visible = ($n -eq 3); $p4.Visible = ($n -eq 4)
    $bAtras.Visible = ($n -eq 2); $bCan.Visible = ($n -le 2); $bSig.Enabled = ($n -ne 3)
    $bSig.Text = switch ($n) { 2 { 'Instalar' } 4 { 'Terminar' } default { 'Siguiente >' } }
}
for ($k = 0; $k -lt $Pasos.Count; $k++) { Pintar-Paso $k 'pend' }

function Terminar-Pagina($ok) {
    if ($ok) {
        $lbFin.Text = '[ OK ]  Instalación terminada'; $lbFin.ForeColor = $cVerde
        $lbFin2.Text = "$($App.Nombre) $($App.Version) está instalado en:`r`n  $($Opc.Dest)`r`n`r`nPuedes desinstalarlo desde «Aplicaciones» de Windows."; $ckAbrir.Visible = $true
    } else {
        $lbFin.Text = '[FAIL]  La instalación no se ha completado'; $lbFin.ForeColor = $cRojo
        $lbFin2.Text = "Mira el registro de la página anterior (última línea ERROR).`r`nSuele bastar con volver a ejecutar el instalador: lo ya hecho no se repite."; $ckAbrir.Visible = $false
    }
    Ir 4
}

$timer = New-Object Windows.Forms.Timer; $timer.Interval = 120
$timer.Add_Tick({
    $m = $null
    while ($Q.TryDequeue([ref]$m)) {
        switch ($m.T) {
            'log' { $rtLog.AppendText("$($m.A)`r`n"); $rtLog.ScrollToCaret() }
            'paso' { Pintar-Paso $m.A $m.B }
            'prog' { $estado.pct = $m.A; $relleno.Width = [int]($pista.Width * $m.A / 100); $lbPct.Text = "$($m.A) %" }
            'fin' { $estado.trabajando = $false; $estado.pyw = $m.B; $timer.Stop(); Terminar-Pagina $m.A }
        }
    }
})

$bCan.Add_Click({ $f.Close() })
$bAtras.Add_Click({ Ir 1 })
$bSig.Add_Click({
    switch ($estado.pagina) {
        1 { Ir 2 }
        2 {
            $d = $tbDir.Text.Trim()
            if (-not $d -or -not [IO.Path]::IsPathRooted($d)) { [void][Windows.Forms.MessageBox]::Show('Escribe o elige una carpeta (ruta completa).', 'Carpeta', 'OK', 'Warning'); return }
            $Opc.Dest = $d; $Opc.Escritorio = $ckEsc.Checked; $Opc.Inicio = $ckIni.Checked; $Opc.Arranque = $ckArr.Checked
            $estado.trabajando = $true; Ir 3; $timer.Start(); Lanzar-Trabajo
        }
        4 { if ($ckAbrir.Checked -and $ckAbrir.Visible -and $estado.pyw) { Start-Process -FilePath $estado.pyw -ArgumentList ('"' + (Join-Path $Opc.Dest $App.Lanzador) + '"') }; $f.Close() }
    }
})
$f.Add_FormClosing({ if ($estado.trabajando) { $_.Cancel = $true } })

if ($Captura) {
    New-Item -ItemType Directory -Path $Captura -Force | Out-Null
    $f.Show(); [Windows.Forms.Application]::DoEvents()
    function Foto($nombre) { [Windows.Forms.Application]::DoEvents(); $b = New-Object Drawing.Bitmap($f.Width, $f.Height); $f.DrawToBitmap($b, (New-Object Drawing.Rectangle(0, 0, $f.Width, $f.Height))); $b.Save((Join-Path $Captura "$nombre.png")); $b.Dispose() }
    Ir 1; Foto '1-bienvenida'; Ir 2; Foto '2-opciones'
    Ir 3; 0..5 | ForEach-Object { Pintar-Paso $_ $(if ($_ -lt 3) { 'ok' } elseif ($_ -eq 3) { 'curso' } else { 'pend' }) }; $relleno.Width = 380; $lbPct.Text = '55 %'
    $rtLog.Text = "  py\app_vuelos.py`r`n  py\vuelos_app.pyw`r`n12 ficheros en C:\Programas\$($App.Nombre)`r`nPython: C:\Programas\$($App.Nombre)\python\python.exe`r`nCollecting streamlit`r`nSuccessfully installed streamlit-1.50.0"
    Foto '3-instalando'; Terminar-Pagina $true; Foto '4-fin'; Terminar-Pagina $false; Foto '5-error'
    $f.Dispose(); exit 0
}
Ir 1
[void]$f.ShowDialog()
if ($LimpiarTemp) { Remove-Item -LiteralPath (Split-Path -Parent $PSCommandPath) -Recurse -Force -ErrorAction SilentlyContinue }   # el .bat ya se ha cerrado: limpia su carpeta temporal
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

                                                     ██╗   ██╗ ██╗  █████╗       ██╗ ███████╗ ███████╗
                                                     ██║   ██║ ██║ ██╔══██╗      ██║ ██╔════╝ ██╔════╝
                                                     ██║   ██║ ██║ ███████║      ██║ █████╗   ███████╗
                                                     ╚██╗ ██╔╝ ██║ ██╔══██║ ██   ██║ ██╔══╝   ╚════██║
                                                      ╚████╔╝  ██║ ██║  ██║ ╚█████╔╝ ███████╗ ███████║
                                                       ╚═══╝   ╚═╝ ╚═╝  ╚═╝  ╚════╝  ╚══════╝ ╚══════╝

                                                                    V E R S I Ó N   1.7.0
:::TITULOEND

:::BEGIN py/app_vuelos.py|text
"""
Viajes — app tipo "Power BI" para elaborar presupuestos de viaje (vuelos, trenes y alojamiento)

Se abre con el acceso directo "Viajes" del escritorio.
Manual:  streamlit run app_vuelos.py
"""

VERSION = "1.7.0"

import base64
import json
import logging
import os
import re
import signal
import subprocess
import sys
import tempfile
import time
from datetime import date, datetime, time as dt_time, timedelta

import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st

try:
    import psutil
except ImportError:          # sin psutil la app funciona igual, solo sin el monitor de CPU/RAM
    psutil = None

CARPETA = os.path.dirname(os.path.abspath(__file__))   # .../Vuelos/py
BASE = os.path.dirname(CARPETA)                          # .../Vuelos
CSV_DIR = os.path.join(BASE, "csv")
ASSETS_DIR = os.path.join(BASE, "assets")
os.makedirs(CSV_DIR, exist_ok=True)
os.makedirs(ASSETS_DIR, exist_ok=True)
os.chdir(BASE)
CSV = os.path.join(CSV_DIR, "vuelos_madrid.csv")
CSV_OPC = os.path.join(CSV_DIR, "vuelos_opciones.csv")
CSV_HOT = os.path.join(CSV_DIR, "hoteles.csv")
CSV_HOT_HIST = os.path.join(CSV_DIR, "historico_hoteles.csv")
CSV_HOT_SONDEO = os.path.join(CSV_DIR, "sondeo_meses_hoteles.csv")
SCRIPT_HOT = os.path.join(CARPETA, "hoteles_madrid.py")
CSV_TREN = os.path.join(CSV_DIR, "trenes.csv")
CSV_TREN_HIST = os.path.join(CSV_DIR, "historico_trenes.csv")
SCRIPT_TREN = os.path.join(CARPETA, "trenes_madrid.py")
ESTADO_TREN = os.path.join(BASE, "trenes_estado.json")
TARIFAS = os.path.join(CSV_DIR, "tarifas_maletas.csv")
CONFIG = os.path.join(BASE, "config_vuelos.json")
FAVORITOS = os.path.join(BASE, "favoritos.json")
PID = os.path.join(BASE, "descarga.pid")
ERRORES = os.path.join(CSV_DIR, "errores_descarga.csv")
HISTORICO = os.path.join(CSV_DIR, "historico_precios.csv")
SONDEOS = os.path.join(CSV_DIR, "sondeo_meses.csv")
ORIGEN = "MAD"
SCRIPT = os.path.join(CARPETA, "vuelos_madrid.py")
LOG = os.path.join(BASE, "descarga.log")
SEG_POR_CONSULTA = 2.0     # estimación aproximada (sin contar pausas por captcha)
MAX_FILAS_TABLA = 1000
MAX_PUNTOS_MAPA = 4000      # puntos por mapa
MAX_PUNTOS_DISPERSION = 8000
DIAS = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]
CORTO = [d[:3] for d in DIAS]

ICONO = os.path.join(ASSETS_DIR, "vuelos.png")
# los filtros se restauran desde el fichero de configuración: ese aviso interno sobra
logging.getLogger("streamlit.elements.lib.policies").setLevel(logging.ERROR)

sys.path.insert(0, CARPETA)
import mantenimiento


@st.cache_resource(show_spinner=False)
def _limpieza_conflictos_onedrive():
    """Se ejecuta una sola vez por sesión del servidor (no en cada recarga de Streamlit)."""
    try:
        mantenimiento.fusionar_conflictos(BASE, log=lambda m: print(m, flush=True))
    except Exception as e:
        print(f"[mantenimiento] error al comprobar duplicados: {e}", flush=True)
    return True


_limpieza_conflictos_onedrive()

st.set_page_config(page_title="Viajes", layout="wide",
                   page_icon=ICONO if os.path.exists(ICONO) else "🧳")
st.markdown("""<style>
.block-container{padding-top:2.2rem;max-width:1500px}

/* ---- cabecera de página ---- */
.cab{display:flex;align-items:center;gap:14px;margin:0 0 10px}
.cab-ico{font-size:1.7rem;line-height:1;display:grid;place-items:center;width:46px;height:46px;
 border-radius:14px;background:rgba(128,128,128,.14);border:1px solid rgba(128,128,128,.2)}
.cab h1{font-size:1.9rem;font-weight:700;margin:0;padding:0;letter-spacing:-.02em}
.cab-sub{margin:2px 0 0;font-size:.9rem;opacity:.62}

/* ---- etiquetas de filtros ---- */
.chips{display:flex;flex-wrap:wrap;gap:8px;margin:2px 0 20px}
.chip{display:inline-flex;align-items:center;gap:7px;padding:5px 13px;border-radius:999px;
 background:rgba(128,128,128,.10);border:1px solid rgba(128,128,128,.20);font-size:.84rem;
 line-height:1.45;white-space:nowrap}
.chip b{font-weight:400;font-size:.95em}

/* ---- tarjetas de cifras ---- */
[data-testid="stMetric"]{background:rgba(128,128,128,.07);border:1px solid rgba(128,128,128,.16);
 border-radius:14px;padding:14px 16px}
[data-testid="stMetric"]:first-child{border-color:rgba(46,158,91,.45)}
[data-testid="stMetricValue"]{font-size:1.75rem;font-weight:700;letter-spacing:-.02em}
[data-testid="stMetricLabel"] p{font-size:.82rem;opacity:.7;text-transform:uppercase;
 letter-spacing:.04em}

/* ---- títulos de sección ---- */
h2,h3{letter-spacing:-.01em}
[data-testid="stHeadingWithActionElements"] h2{font-size:1.25rem;margin-top:1.6rem;
 padding-bottom:.4rem;border-bottom:1px solid rgba(128,128,128,.18)}

/* ---- tablas y controles ---- */
[data-testid="stDataFrame"]{border-radius:12px;overflow:hidden;border:1px solid rgba(128,128,128,.18)}
[data-testid="stElementContainer"] .stButton>button,[data-testid="stLinkButton"] a{border-radius:10px}
[data-testid="stSidebar"] [data-testid="stExpander"]{border:none;background:rgba(128,128,128,.06);
 border-radius:12px;margin-bottom:8px}
[data-testid="stSidebarNav"]{padding-top:.2rem}
[data-testid="stCaptionContainer"] p{opacity:.72}
</style>""", unsafe_allow_html=True)



def dur(m):
    return f"{m // 60} h {m % 60:02d} min" if m >= 60 else f"{m} min"


# ------------------------------------------------------------------ sistema visual
COLORES = ["#4C9AFF", "#F5A524", "#2EC4A6", "#E5484D", "#A78BFA", "#F472B6", "#22C55E", "#EAB308",
           "#38BDF8", "#FB923C"]
ESCALA_PRECIO = [[0.0, "#1B9E77"], [0.35, "#7FC97F"], [0.6, "#F4C542"], [0.8, "#EE8A3C"],
                 [1.0, "#D64545"]]
VERDE, AMBAR, ROJO, GRIS = "#2E9E5B", "#F5A524", "#D64545", "#9AA0A6"


def es_oscuro():
    try:
        return st.context.theme.type == "dark"
    except Exception:
        return True


def estilo(fig, alto=420, leyenda="arriba"):
    """Mismo aire para todos los gráficos: tipografía, rejilla suave y leyenda ordenada."""
    oscuro = es_oscuro()
    tinta = "#E8EAED" if oscuro else "#202124"
    rejilla = "rgba(255,255,255,.08)" if oscuro else "rgba(0,0,0,.08)"
    fig.update_layout(
        template="plotly_dark" if oscuro else "plotly_white",
        colorway=COLORES, height=alto,
        margin=dict(l=8, r=8, t=36 if leyenda == "arriba" else 16, b=8),
        font=dict(family="Inter, Segoe UI, system-ui, sans-serif", size=13, color=tinta),
        paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
        hoverlabel=dict(font_size=13, bordercolor="rgba(0,0,0,0)"),
        legend=(dict(orientation="h", yanchor="bottom", y=1.02, x=0, title_text="")
                if leyenda == "arriba" else dict(title_text="")),
        showlegend=leyenda != "no",
    )
    fig.update_xaxes(showgrid=False, zeroline=False, linecolor=rejilla, ticks="outside",
                     tickcolor=rejilla, title_font_size=12)
    fig.update_yaxes(gridcolor=rejilla, zeroline=False, linecolor="rgba(0,0,0,0)",
                     title_font_size=12)
    return fig


def titulo_pagina(icono, texto, subtitulo=None):
    st.markdown(f'<div class="cab"><span class="cab-ico">{icono}</span>'
                f'<div><h1>{texto}</h1>'
                + (f'<p class="cab-sub">{subtitulo}</p>' if subtitulo else "")
                + "</div></div>", unsafe_allow_html=True)


MESES_CORTO = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]
ORDEN_MES = {}


def mes_legible(ym):
    """'2027-08' -> 'ago 2027' (y guarda el orden para no ordenar alfabéticamente)."""
    a, m = str(ym).split("-")[:2]
    txt = f"{MESES_CORTO[int(m) - 1]} {a}"
    ORDEN_MES[txt] = str(ym)
    return txt


def eur(x):
    return f"{x:,.0f} €".replace(",", ".")

def tamano_bytes(ruta):
    try:
        return os.path.getsize(ruta)
    except OSError:
        return 0


def tamano_legible(b):
    if not b:
        return "—"
    for u in ["B", "KB", "MB", "GB"]:
        if b < 1024:
            return f"{b:.0f} {u}" if u == "B" else f"{b:.1f} {u}"
        b /= 1024
    return f"{b:.1f} TB"


def comprimir_historico(ruta, dias_mantener, claves, dias_retener=0):
    """Para las filas más antiguas que 'dias_mantener', se queda solo con la última consulta
    de cada día (agrupando por 'claves' + día), en vez de todas las consultas de ese día.
    Lo reciente se deja intacto. Si dias_retener > 0, lo anterior a esos días se borra del todo.
    Devuelve (filas_antes, filas_después)."""
    try:
        h = pd.read_csv(ruta, sep=";", encoding="utf-8-sig", on_bad_lines="skip")
    except Exception:
        return 0, 0
    if h.empty or "consulta" not in h.columns:
        return 0, 0
    n_antes = len(h)
    h["_dt"] = pd.to_datetime(h["consulta"], errors="coerce")
    if int(dias_retener or 0) > 0:
        h = h[h["_dt"] >= pd.Timestamp.today().normalize() - pd.Timedelta(days=int(dias_retener))]
    corte = pd.Timestamp.today().normalize() - pd.Timedelta(days=int(dias_mantener))
    recientes = h[h["_dt"] >= corte].drop(columns=["_dt"])
    antiguas = h[h["_dt"] < corte].copy()
    if not antiguas.empty:
        antiguas["_dia"] = antiguas["_dt"].dt.date
        antiguas = (antiguas.sort_values("consulta")
                   .drop_duplicates(subset=[c for c in claves if c in antiguas.columns] + ["_dia"], keep="last")
                   .drop(columns=["_dt", "_dia"]))
    final = pd.concat([antiguas, recientes], ignore_index=True).sort_values("consulta")
    tmp = ruta + ".tmp"
    final.to_csv(tmp, sep=";", index=False, encoding="utf-8-sig")
    os.replace(tmp, ruta)
    return n_antes, len(final)

# ======================================================================= DATOS
@st.cache_data(show_spinner=False)
def ritmo(mt_):
    """Segundos por consulta según tus últimas descargas."""
    try:
        d = pd.read_csv(CSV, sep=";", encoding="utf-8-sig", on_bad_lines="skip", usecols=["ultima_descarga"])
        por_minuto = d["ultima_descarga"].value_counts()
        por_minuto = por_minuto[por_minuto > 1]
        if len(por_minuto) >= 5:
            return float(min(max(60 / por_minuto.median(), 0.15), 20))
    except Exception:
        pass
    return SEG_POR_CONSULTA


HIST_COMPACTAR_DEFECTO = 180      # días de detalle completo antes de compactar a 1 fila/día


def politica_historico():
    """(días de detalle completo antes de compactar, días máximos de histórico; 0 = sin límite)."""
    cfg = leer_config()
    return (int(cfg.get("hist_compactar_dias", HIST_COMPACTAR_DEFECTO)), int(cfg.get("hist_retener_dias", 0)))


def politica_historico_ui():
    """Los dos parámetros del histórico, editables y guardados en la configuración."""
    comp, ret = politica_historico()
    with st.container(border=True):
        st.markdown("**⚙️ Política del histórico** (vale para vuelos, trenes y hoteles)")
        c1, c2 = st.columns(2)
        n_comp = int(c1.number_input("Compactar lo anterior a (días)", 7, 3650, comp, key="pol_comp",
                                     help="Los últimos N días se guardan con todas las consultas; lo más antiguo "
                                          "se reduce a una fila por vuelo/tren/alojamiento y día. Por defecto 180."))
        n_ret = int(c2.number_input("Conservar como máximo (días, 0 = sin límite)", 0, 3650, ret, key="pol_ret",
                                    help="Lo anterior a estos días se borra al comprimir. 0 = no se borra nada."))
        if n_ret and n_ret < n_comp:
            st.warning("Conservas menos días de los que dejas sin compactar: al comprimir se borrará lo anterior "
                       f"a {n_ret} días y no habrá nada que compactar.")
        if (n_comp, n_ret) != (comp, ret):
            guardar_config(hist_compactar_dias=n_comp, hist_retener_dias=n_ret)
        st.caption("Se aplica con los botones «🗜️ Comprimir» de cada pestaña (o el de «🎒 Completo» para todo a la vez).")
    return n_comp, n_ret


@st.cache_data(show_spinner=False)
def consultas_por_dia(ruta, mt_, col_consulta="consulta", col_dest="codigo"):
    """Consultas y destinos distintos por día de descarga, a partir de un histórico (se calcula una
    sola vez mientras el fichero no cambie: el de hoteles pesa cientos de MB)."""
    try:
        h = pd.read_csv(ruta, sep=";", encoding="utf-8-sig", on_bad_lines="skip", usecols=[col_consulta, col_dest])
    except Exception:
        return pd.DataFrame(columns=["dia", "filas", "destinos"])
    h["dia"] = pd.to_datetime(h[col_consulta], errors="coerce").dt.date
    h = h.dropna(subset=["dia"])
    return h.groupby("dia").agg(filas=(col_dest, "size"), destinos=(col_dest, "nunique")).reset_index()


def mtime(ruta):
    try:
        return os.path.getmtime(ruta)
    except OSError:
        return 0.0


def mt_estable(ruta, clave):
    """Como mtime(), pero durante el intervalo configurado en "Refrescar cada" (por defecto
    2 minutos) sigue devolviendo el mismo valor aunque el fichero cambie mientras tanto. Se usa
    como clave de caché para cargar()/cargar_hoteles(): sin esto, mientras hay una descarga en
    curso el fichero va cambiando en cada consulta y CADA clic en la app (cualquiera, no solo
    los del diálogo de descarga) obliga a releer y reprocesar el CSV entero -de cientos de miles
    de filas-, lo que puede tardar bastante y da sensación de que la app se queda colgada. Con
    esto, los precios se refrescan solos como mucho una vez por intervalo, en vez de en cada
    clic."""
    real = mtime(ruta)
    guardado = st.session_state.get(clave)
    if guardado is None or (real != guardado[0] and time.time() - guardado[1] >= intervalo_refresco()):
        st.session_state[clave] = (real, time.time())
        return real
    return guardado[0]


def leer_tabla(ruta, mt_, **kw):
    """Lee el CSV, pero guarda una copia en Parquet: la próxima vez la lectura es 3 veces
    más rápida. Los CSV siguen ahí para abrirlos con Excel."""
    cache = f"{ruta}.parquet"
    try:
        if os.path.exists(cache) and os.path.getmtime(cache) >= mt_:
            return pd.read_parquet(cache)
    except Exception:
        pass
    d = pd.read_csv(ruta, sep=";", encoding="utf-8-sig", on_bad_lines="skip", **kw)
    try:
        d.to_parquet(cache, index=False)
    except Exception:      # sin pyarrow o sin permisos: se sigue leyendo el CSV y ya está
        pass
    return d


def leer_columnas(ruta, mt_, cols):
    """Lee SOLO unas columnas de la copia Parquet (milisegundos, en vez de cargar toda la tabla).
    Devuelve None si no hay copia al día; entonces hay que cargar la tabla entera."""
    cache = f"{ruta}.parquet"
    try:
        if os.path.exists(cache) and os.path.getmtime(cache) >= mt_:
            import pyarrow.parquet as pq
            existentes = set(pq.ParquetFile(cache).schema_arrow.names)
            return pd.read_parquet(cache, columns=[c for c in cols if c in existentes])
    except Exception:
        pass
    return None


@st.cache_data(show_spinner="Cargando precios…", persist="disk", ttl="7d")
def cargar(ruta, mt_):
    """Lee el CSV (aunque se esté escribiendo) y deja una fila por día/sentido/destino."""
    df = leer_tabla(ruta, mt_, dtype={"precio_anterior": "Int64", "hora_salida": str,
                                      "hora_llegada": str})
    if df.empty:
        return df
    df = df.drop_duplicates(["fecha", "sentido", "codigo"], keep="last")
    df["fecha"] = pd.to_datetime(df["fecha"], errors="coerce").dt.date
    df["precio_eur"] = pd.to_numeric(df["precio_eur"], errors="coerce")
    df["escalas"] = pd.to_numeric(df["escalas"], errors="coerce")
    df = df.dropna(subset=["fecha"])
    return df[df["fecha"] > date.today()].reset_index(drop=True)


# Tarifas orientativas de equipaje por trayecto y persona (edítalas en la página 🧳 Maletas)
TARIFAS_DEFECTO = [
    ("Ryanair", 30, 20), ("easyJet", 30, 25), ("Vueling", 30, 15), ("Iberia Express", 30, 0),
    ("Iberia", 30, 0), ("Air Europa", 30, 0), ("Volotea", 25, 15), ("Wizz Air", 40, 25),
    ("Transavia", 35, 15), ("Tap Air Portugal", 35, 0), ("Lufthansa", 45, 0), ("Air France", 35, 0),
    ("KLM", 35, 0), ("ITA", 65, 0), ("Aegean", 25, 0), ("SAS", 40, 25), ("British Airways", 55, 0),
    ("Aer Lingus", 40, 0), ("Brussels Airlines", 35, 0), ("LOT", 25, 0), ("Swiss", 40, 0),
    ("Austrian", 40, 0), ("Otras", 35, 0),
]
# Fecha de la última revisión de los valores anteriores y enlaces oficiales para comprobarlos.
# fiabilidad: "alta" = coincide en varias guías recientes; "media" = varía mucho según ruta/fecha;
# "baja" = no confirmado en la web oficial (suele ser solo JavaScript).
TARIFAS_REVISADO = "2026-10-01"
TARIFAS_FUENTES = {
    "Ryanair": ("https://www.ryanair.com/es/es/useful-info/help-centre/baggage", "media", "Precio según ruta/fecha; 10 kg y bolso pequeño según tarifa"),
    "easyJet": ("https://www.easyjet.com/es/politica-de-equipaje", "media", "Varía por ruta; cabina grande con «Up Front»/Plus"),
    "Vueling": ("https://www.vueling.com/es/vuelos-vueling/equipaje", "media", "Tarifa Basic sin maleta; «Fly Light» cambia por ruta"),
    "Iberia Express": ("https://www.iberiaexpress.com/es/informacion-util/equipaje", "media", "Billete Básico sin maleta facturada"),
    "Iberia": ("https://www.iberia.com/es/equipaje/", "media", "Tarifa Básica sin maleta; Classic/Optima la incluyen"),
    "Air Europa": ("https://www.aireuropa.com/es/es/aea/informacion-util/equipaje.html", "media", "Tarifa Lite sin maleta facturada"),
    "Volotea": ("https://www.volotea.com/es/informacion-util/equipaje/", "media", "Precio dinámico según ruta"),
    "Wizz Air": ("https://wizzair.com/es-es/informacion-y-servicios/equipaje", "media", "Precio dinámico; trolley 10 kg de pago"),
    "Transavia": ("https://www.transavia.com/es-ES/informacion-util/equipaje/", "media", "Varía por ruta"),
    "Tap Air Portugal": ("https://www.flytap.com/es-es/equipaje", "media", "Tarifa Discount sin maleta"),
    "Lufthansa": ("https://www.lufthansa.com/es/es/equipaje", "media", "Light sin maleta facturada"),
    "Air France": ("https://wwws.airfrance.es/informacion/equipaje", "media", "Light sin maleta facturada"),
    "KLM": ("https://www.klm.es/information/baggage", "media", "Light sin maleta facturada"),
    "ITA": ("https://www.ita-airways.com/es_es/informacion-y-asistencia/equipaje", "baja", "Valor muy variable por ruta"),
    "Aegean": ("https://es.aegeanair.com/informacion-de-viaje/equipaje/", "baja", "Web oficial solo JavaScript"),
    "SAS": ("https://www.flysas.com/es-es/travel-info/baggage/", "baja", "SAS Go: trolley grande de pago"),
    "British Airways": ("https://www.britishairways.com/es-es/information/baggage-essentials", "media", "Tarifa básica sin maleta facturada"),
    "Aer Lingus": ("https://www.aerlingus.com/travel-information/baggage-information/", "baja", "Varía por ruta"),
    "Brussels Airlines": ("https://www.brusselsairlines.com/es-es/informacion-de-viaje/equipaje", "baja", "Light sin maleta facturada"),
    "LOT": ("https://www.lot.com/es/es/equipaje", "baja", "Varía por ruta"),
    "Swiss": ("https://www.swiss.com/es/es/prepare/baggage", "baja", "Light sin maleta facturada"),
    "Austrian": ("https://www.austrian.com/es/es/equipaje", "baja", "Light sin maleta facturada"),
    "Otras": ("", "baja", "Valor genérico para el resto de aerolíneas"),
}


def leer_tarifas():
    try:
        t = pd.read_csv(TARIFAS, sep=";", encoding="utf-8-sig")
        t = t[["aerolinea", "facturada_eur", "cabina_grande_eur"]]
    except Exception:
        t = pd.DataFrame(TARIFAS_DEFECTO, columns=["aerolinea", "facturada_eur", "cabina_grande_eur"])
    return t.fillna(0)


def leer_config():
    try:
        with open(CONFIG, encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def guardar_config(**kw):
    c = leer_config() | kw
    try:
        tmp = CONFIG + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(c, f, ensure_ascii=False, indent=1)
        os.replace(tmp, CONFIG)
    except OSError:
        pass


def leer_favoritos():
    """{"vuelos": [...], "hoteles": [...]}: vuelos/alojamientos concretos para volver a
    descargar solo esos, sin bajar todo el destino."""
    try:
        with open(FAVORITOS, encoding="utf-8") as f:
            d = json.load(f)
    except Exception:
        d = {}
    d.setdefault("vuelos", [])
    d.setdefault("hoteles", [])
    d.setdefault("trenes", [])
    return d


def guardar_favoritos(fav):
    try:
        tmp = FAVORITOS + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(fav, f, ensure_ascii=False, indent=1)
        os.replace(tmp, FAVORITOS)
    except OSError:
        pass


def pares_vuelos_de(filas):
    """filas: iterable de (codigo, fecha_ida_iso, fecha_vuelta_iso). Pares 'CODIGO:SENTIDO:FECHA'
    para --pares de vuelos_madrid.py, sin duplicados."""
    vistos, pares = set(), []
    for cod, ida, vuelta in filas:
        for sentido, f in (("IDA", ida), ("VUELTA", vuelta)):
            k = (cod, sentido, f)
            if k not in vistos:
                vistos.add(k)
                pares.append(f"{cod}:{sentido}:{f}")
    return pares


def pares_hoteles_de(filas):
    """filas: iterable de (codigo, fecha_entrada_iso). Pares 'CODIGO:FECHA' para --pares de
    hoteles_madrid.py, sin duplicados."""
    vistos, pares = set(), []
    for cod, fecha in filas:
        k = (cod, fecha)
        if k not in vistos:
            vistos.add(k)
            pares.append(f"{cod}:{fecha}")
    return pares


def pares_de(filas):
    """filas: iterable de (codigo, sentido, fecha_iso). Pares 'CODIGO:SENTIDO:FECHA' para
    --pares de vuelos_madrid.py, uno por trayecto concreto (no por ida+vuelta), sin duplicados."""
    vistos, pares = set(), []
    for cod, sentido, fecha in filas:
        k = (cod, sentido, fecha)
        if k not in vistos:
            vistos.add(k)
            pares.append(f"{cod}:{sentido}:{fecha}")
    return pares


TMP_DIR = os.path.join(BASE, "tmp")


def args_pares(pares):
    """Args de línea de comandos para --pares. Con pocas consultas se pasan tal cual; a partir
    de cierto número se escriben en un fichero temporal y se usa --pares-fichero en su lugar,
    para no toparse con el límite de longitud de la línea de comandos de Windows (WinError 206,
    "el nombre del archivo o la extensión es demasiado largo") cuando hay cientos o miles de
    consultas concretas (p. ej. al redescargar con un grupo grande como «Europa (todos)»)."""
    if len(pares) <= 200:
        return ["--pares", *pares]
    os.makedirs(TMP_DIR, exist_ok=True)
    fd, ruta = tempfile.mkstemp(suffix=".txt", prefix="pares_", dir=TMP_DIR)
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        f.write("\n".join(pares))
    return ["--pares-fichero", ruta]


def a_minutos(hhmm):
    t = hhmm.fillna("").str.split(":", expand=True)
    if t.shape[1] < 2:
        return pd.Series(pd.NA, index=hhmm.index)
    return pd.to_numeric(t[0], errors="coerce") * 60 + pd.to_numeric(t[1], errors="coerce")


@st.cache_data(show_spinner=False)
def codigos_con_datos(mt_):
    return set(cargar(CSV, mt_)["codigo"].unique())


@st.cache_data(show_spinner=False)
def aeropuertos_disponibles(mt_):
    """{etiqueta: código} con todos los aeropuertos que hay en los datos. La etiqueta junta código,
    ciudad y (si está instalado airportsdata) nombre del aeropuerto, para poder buscar por
    cualquiera de los tres al escribir en el desplegable."""
    d = cargar(CSV, mt_)
    if d.empty:
        return {}
    base = d[["codigo", "ciudad"]].drop_duplicates()      # todos los que hay en los datos
    con_precio = set(d.loc[d["precio_eur"].notna(), "codigo"])
    nombres = {}
    try:
        import airportsdata
        nombres = {k: v.get("name", "") for k, v in airportsdata.load("IATA").items()}
    except Exception:
        pass
    out = {}
    for cod, ciudad in zip(base["codigo"], base["ciudad"]):
        et = (f"{cod} · {ciudad}" + (f" · {nombres[cod]}" if nombres.get(cod) else "")
              + ("" if cod in con_precio else " · (sin vuelos con precio)"))
        out[et] = cod
    return dict(sorted(out.items()))


@st.cache_data(show_spinner=False)
def aerolineas_disponibles(mt_):
    a = cargar(CSV, mt_)["aerolinea"].dropna().astype(str).str.split("/").explode().str.strip()
    return sorted(a[a != ""].unique())


@st.cache_data(show_spinner="Cargando todas las opciones de vuelos…", persist="disk", ttl="7d")
def cargar_opciones(mt_o, mt_m):
    """Todos los vuelos de cada día. Si un día solo está en el CSV antiguo (el más barato),
    se usa ese como única opción."""
    main = cargar(CSV, mt_m).dropna(subset=["precio_eur"])
    o = pd.DataFrame()
    if mt_o:
        o = leer_tabla(CSV_OPC, mt_o, dtype={"hora_salida": str, "hora_llegada": str})
    if not o.empty:
        o["fecha"] = pd.to_datetime(o["fecha"], errors="coerce").dt.date
        o = o.dropna(subset=["fecha"])
        o = o[o["fecha"] > date.today()]
        # comparar números en vez de texto acelera muchísimo el agrupado
        c_num = pd.to_datetime(o["consulta"], errors="coerce").astype("int64")
        ultima = c_num.groupby([o["fecha"], o["sentido"], o["codigo"]], sort=False).transform("max")
        o = o[c_num.values == ultima.values]
        for c in ("precio_eur", "escalas", "duracion_min", "escala_max_min", "co2_kg"):
            o[c] = pd.to_numeric(o[c], errors="coerce")
        o["ultima_descarga"] = o["consulta"].str[:16]
    llave = ["fecha", "sentido", "codigo"]
    if o.empty:
        faltan = main
    else:   # índice vectorizado en vez de recorrer fila a fila
        faltan = main[~pd.MultiIndex.from_frame(main[llave]).isin(pd.MultiIndex.from_frame(o[llave]))]
    o = pd.concat([o, faltan.assign(escala_max_min=pd.NA, co2_kg=pd.NA)], ignore_index=True)
    o = o.dropna(subset=["precio_eur"])
    o["sal_min"] = a_minutos(o["hora_salida"])
    o["llega_sig"] = o["llega_dia_siguiente"].eq("sí")
    return o


@st.cache_data(show_spinner="Cargando precios de alojamiento…")
def cargar_hoteles(mt_):
    """Un alojamiento por fila, con sus atributos (precio, nota, estrellas, servicios)."""
    if not mt_:
        return pd.DataFrame()
    h = leer_tabla(CSV_HOT, mt_)
    if h.empty:
        return h
    # columnas pesadas que ninguna página usa (los servicios ya están uno por columna)
    h = h.drop(columns=[c for c in ("servicios", "direccion") if c in h.columns])
    fe = h["fecha_entrada"].astype(str)
    h["fecha_entrada"] = pd.to_datetime(fe, errors="coerce", format="%Y-%m-%d").fillna(
        pd.to_datetime(fe, errors="coerce", dayfirst=True))
    for c in ("precio_noche", "precio_total", "valoracion", "resenas", "estrellas", "noches",
              "lat", "lon", "km_centro", "min_andando", "min_coche", "min_transporte",
              "km_aeropuerto", "min_coche_aeropuerto", "min_andando_aeropuerto"):
        if c in h.columns:
            h[c] = pd.to_numeric(h[c], errors="coerce")
    # si Google solo dio el precio total de la estancia (pasa en estancias de varias noches),
    # se calcula el precio por noche a partir de ahí en vez de descartar la fila
    if "precio_total" in h.columns and "noches" in h.columns:
        h["precio_noche"] = h["precio_noche"].fillna(h["precio_total"] / h["noches"].replace(0, pd.NA))
    h = h.dropna(subset=["fecha_entrada", "precio_noche"])
    h = h[h["fecha_entrada"] > pd.Timestamp.today().normalize()]
    # a partir de ahora se baja noche a noche; si hay datos así, se ignoran las estancias
    # largas antiguas (no son comparables: llevan descuento por número de noches)
    sueltas = h[h["noches"] == 1]
    if not sueltas.empty:
        h = sueltas
    h = h.reset_index(drop=True)
    est = estaciones_por_codigo()
    if est and {"lat", "lon", "codigo"} <= set(h.columns):
        km = np.full(len(h), np.nan)
        nom = np.full(len(h), None, dtype=object)
        for cod, lista in est.items():
            m = ((h["codigo"] == cod) & h["lat"].notna() & h["lon"].notna()).to_numpy()
            if not m.any():
                continue
            la, lo = np.radians(h.loc[m, "lat"].to_numpy(float)), np.radians(h.loc[m, "lon"].to_numpy(float))
            mejor, nombres = np.full(m.sum(), np.inf), np.full(m.sum(), None, dtype=object)
            for n_, y, x in lista:
                yr, xr = np.radians(y), np.radians(x)
                a = np.sin((yr - la) / 2) ** 2 + np.cos(la) * np.cos(yr) * np.sin((xr - lo) / 2) ** 2
                d = 2 * 6371 * np.arcsin(np.sqrt(a))
                mk = d < mejor
                mejor[mk], nombres[mk] = d[mk], n_
            km[m], nom[m] = mejor, nombres
        h["km_estacion"] = np.round(km, 2)
        h["estacion"] = nom
        h["min_andando_estacion"] = np.round(km * 1.3 / 4.8 * 60)   # recta ×1,3 a 4,8 km/h
    return h


@st.cache_data(show_spinner="Filtrando alojamientos…")
def hoteles_filtrados(mt_, fh):
    """Aplica los filtros de alojamiento (nota, estrellas, tipo, servicios, precio)."""
    h = cargar_hoteles(mt_)
    if h.empty:
        return h
    nota, estrellas, tipos, servicios, precio_max, ubicacion, minutos, resenas_min, min_transp = fh[:9]
    min_est = fh[9] if len(fh) > 9 else 0
    if nota:
        h = h[h["valoracion"].fillna(0) >= nota]
    if estrellas:
        h = h[h["estrellas"].fillna(0) >= estrellas]
    if tipos:
        h = h[h["tipo"].isin(tipos)]
    for s_ in servicios:
        h = h[h[s_] == "sí"]
    if precio_max:
        h = h[h["precio_noche"] <= precio_max]
    if ubicacion:
        h = h[h["buena_ubicacion"] == "sí"]
    if minutos and "min_andando" in h.columns:
        h = h[h["min_andando"].fillna(9999) <= minutos]
    if min_transp and "min_transporte" in h.columns:
        h = h[h["min_transporte"].fillna(9999) <= min_transp]
    if min_est and "min_andando_estacion" in h.columns:
        h = h[h["min_andando_estacion"].fillna(9999) <= min_est]
    if resenas_min:
        h = h[h["resenas"].fillna(0) >= resenas_min]
    return h


@st.cache_data(show_spinner="Calculando precios típicos por ciudad…")
def indice_hoteles(mt_, fh, n_baratos=10):
    """Precio típico por ciudad y fecha: mediana de los N más baratos que cumplen los filtros.
    Es la 'cesta estándar': así dos ciudades son comparables."""
    h = hoteles_filtrados(mt_, fh)
    if h.empty:
        return h
    h = h.sort_values("precio_noche")
    llave = ["codigo", "ciudad", "fecha_entrada"]
    agg = dict(precio_noche=("precio_noche", "median"),
               mas_barato=("precio_noche", "min"),
               opciones=("precio_noche", "size"),
               nota_media=("valoracion", "mean"))
    if "min_andando" in h.columns:
        agg["min_andando"] = ("min_andando", "median")
        agg["km_centro"] = ("km_centro", "median")
    ind = (h.groupby(llave, as_index=False, observed=True).head(n_baratos)
           .groupby(llave, as_index=False, observed=True).agg(**agg))
    ind["mes"] = ind["fecha_entrada"].dt.strftime("%Y-%m")
    ind["dia_sem"] = ind["fecha_entrada"].dt.dayofweek.map(dict(enumerate(DIAS)))
    return ind


@st.cache_data(show_spinner="Calculando coste de la estancia…")
def coste_estancia(mt_, fh, n_baratos, noches):
    """Precio de una estancia de N noches = suma de las N noches sueltas desde la entrada.
    Igual que con los vuelos: se baja noche a noche y las duraciones se componen después."""
    vacio = pd.DataFrame(columns=["codigo", "fecha_entrada", "noches", "hotel_base", "hotel_noche"])
    ind = indice_hoteles(mt_, fh, n_baratos)
    if ind.empty:
        return vacio
    m = ind.pivot_table(index="codigo", columns="fecha_entrada", values="precio_noche")
    m = m.reindex(columns=pd.date_range(m.columns.min(), m.columns.max(), freq="D"))
    trozos = []
    for nn in sorted({int(x) for x in noches if int(x) > 0}):
        if nn > m.shape[1]:
            continue
        # suma de nn noches consecutivas, referida al día de entrada
        acum = m.T.rolling(window=nn, min_periods=nn).sum().T.shift(-(nn - 1), axis=1)
        d = (acum.reset_index()
             .melt(id_vars="codigo", var_name="fecha_entrada", value_name="hotel_base")
             .dropna(subset=["hotel_base"]))
        d["noches"] = nn
        trozos.append(d)
    if not trozos:
        return vacio
    r = pd.concat(trozos, ignore_index=True)
    r["fecha_entrada"] = pd.to_datetime(r["fecha_entrada"])
    r["hotel_noche"] = r["hotel_base"] / r["noches"]
    return r


@st.cache_data(show_spinner="Calculando precios típicos de la estancia…")
def indice_estancias(mt_, fh, n_baratos, noches):
    """Precio típico por ciudad y fecha de entrada para una estancia de N noches, sumando
    noches sueltas contiguas. Mismas columnas que indice_hoteles, para que las páginas no
    tengan que distinguir entre 1 noche y varias."""
    ind = indice_hoteles(mt_, fh, n_baratos)
    est = coste_estancia(mt_, fh, n_baratos, noches)
    if est.empty:
        return est
    nombres = ind[["codigo", "ciudad"]].drop_duplicates()
    est = est.merge(nombres, on="codigo", how="left")
    est["mes"] = est["fecha_entrada"].dt.strftime("%Y-%m")
    est["dia_sem"] = est["fecha_entrada"].dt.dayofweek.map(dict(enumerate(DIAS)))
    return est.rename(columns={"hotel_noche": "precio_noche", "hotel_base": "precio_total"})


# ============================================================== TRENES (datos)
TREN_COORDS = {
    "71801": (41.379, 2.140), "79300": (41.979, 2.817), "78400": (41.620, 0.631), "04104": (41.153, 1.173),
    "04307": (42.266, 2.944), "71400": (41.151, 1.104), "04040": (41.659, -0.911), "70600": (41.353, -1.643),
    "74200": (42.135, -0.408), "67200": (40.349, -1.107), "80100": (42.810, -1.646), "81202": (42.063, -1.605),
    "03216": (39.458, -0.382), "60911": (38.344, -0.497), "65300": (39.987, -0.052), "61200": (37.984, -1.129),
    "61307": (37.603, -0.985), "62103": (38.265, -0.697), "60600": (38.999, -1.857), "64100": (38.990, -0.521),
    "03213": (39.493, -1.100), "60902": (38.634, -0.863), "51003": (37.392, -5.975), "54413": (36.711, -4.432),
    "50500": (37.889, -4.791), "05000": (37.183, -3.609), "56312": (36.831, -2.457), "51405": (36.528, -6.291),
    "51300": (36.684, -6.129), "43019": (37.258, -6.940), "03100": (37.778, -3.795), "50300": (38.030, -3.690),
    "02003": (37.020, -4.560), "55007": (36.744, -5.167), "55020": (36.131, -5.450), "02002": (37.383, -4.763),
    "13200": (43.258, -2.926), "11511": (43.305, -1.983), "11208": (42.849, -2.684), "14223": (43.462, -3.809),
    "15211": (43.365, -5.851), "15410": (43.534, -5.668), "81100": (42.466, -2.443), "11014": (42.356, -3.651),
    "11200": (42.686, -2.945), "11600": (43.338, -1.790), "31400": (42.870, -8.543), "31412": (43.353, -8.412),
    "22308": (42.209, -8.727), "22100": (42.338, -7.863), "23004": (42.432, -8.638), "20309": (43.008, -7.559),
    "21010": (43.488, -8.225), "20200": (42.548, -6.596), "10600": (41.644, -4.725), "15100": (42.595, -5.576),
    "30100": (40.954, -5.668), "14100": (42.009, -4.534), "30200": (41.503, -5.743), "08004": (40.911, -4.127),
    "10400": (40.658, -4.699), "82100": (41.764, -2.466), "10500": (41.310, -4.914), "92102": (39.863, -4.019),
    "04007": (40.653, -3.163), "03208": (40.034, -2.141), "37200": (38.985, -3.925), "37300": (38.690, -4.104),
    "35200": (39.963, -4.836), "37606": (38.878, -6.972), "35400": (39.477, -6.375), "37500": (38.916, -6.338),
    "30002": (40.030, -6.090), "40100": (38.421, -6.415),
    # Europa (AVE internacional directo desde Madrid)
    "87374": (42.696, 2.879), "87088": (43.181, 3.000), "MONTP": (43.605, 3.881), "NIMES": (43.833, 4.366),
    "87814": (43.922, 4.786), "87912": (43.455, 5.317), "87089": (43.303, 5.381),
    "LYON-": (45.760, 4.860), "VALFR": (44.989, 4.979),
    "PARIS": (48.844, 2.374), "MILAN": (45.486, 9.205), "TURIN": (45.062, 7.678),
}
MADRID_COORDS = (40.406, -3.689)
TARIFAS_TREN_INFO = pd.DataFrame([
    {"compania": "Renfe (AVE/Larga distancia)", "tarifa": "Básico / Elige / Prémium",
     "equipaje": "Hasta 3 bultos (máx. 25 kg cada uno, suma de lados 290 cm; el mayor 85×55×35)",
     "extra": "Incluido", "cambios": "Básico: 1 cambio con coste; Elige/Prémium: más flexibles",
     "reembolso": "Básico no; Elige parcial; Prémium sí", "fiabilidad": "alta",
     "enlace": "https://www.renfe.com/es/es/viajar/informacion-util/equipaje"},
    {"compania": "Renfe Avlo", "tarifa": "Avlo",
     "equipaje": "Más restrictivo que AVE: 1 maleta + 1 bulto de mano",
     "extra": "Maleta extra: 10–15 €", "cambios": "Sin cambios", "reembolso": "No reembolsable",
     "fiabilidad": "media", "enlace": "https://www.renfe.com/es/es/viajar/informacion-util/equipaje"},
    {"compania": "Ouigo", "tarifa": "Básica",
     "equipaje": "1 bolso (27×36×15) + 1 equipaje de cabina (55×35×25) incluidos",
     "extra": "Maleta grande (máx. 200 cm / 25 kg): 25 € a bordo; desde 6 € reservando antes",
     "cambios": "Flex ≈ 7 €", "reembolso": "No reembolsable", "fiabilidad": "alta",
     "enlace": "https://www.ouigo.com/es/equipaje"},
    {"compania": "iryo", "tarifa": "Básico / Elige / Singular",
     "equipaje": "Según billete (hasta 3 piezas en condiciones antiguas; consulta tu tarifa)",
     "extra": "Depende de la tarifa", "cambios": "Según tarifa", "reembolso": "Según tarifa",
     "fiabilidad": "baja", "enlace": "https://iryo.eu/es/informacion-util/equipaje"},
    {"compania": "Trenitalia France", "tarifa": "Base / Economy",
     "equipaje": "Sin límite estricto de piezas (norma de 2024 suspendida)",
     "extra": "Bagaglio Facile: 25–28 €", "cambios": "Según tarifa", "reembolso": "Según tarifa",
     "fiabilidad": "baja", "enlace": "https://www.trenitalia.com/es/informacion/equipaje.html"},
])


def _modulo_trenes():
    try:
        sys.path.insert(0, CARPETA)
        import trenes_madrid
        return trenes_madrid
    except Exception:
        return None


def _norm_ciudad(s):
    import unicodedata
    s = unicodedata.normalize("NFKD", str(s)).encode("ascii", "ignore").decode().lower()
    return re.sub(r"\s*\(.*\)", "", s).strip()


@st.cache_data(show_spinner=False)
def estaciones_por_codigo():
    """Código de destino de hoteles -> [(estación, lat, lon)] de las estaciones de tren de tu lista que
    están en esa misma ciudad (por nombre; se descartan ciudades con país entre paréntesis)."""
    m = _modulo_trenes()
    if not m:
        return {}
    por_nombre = {}
    for cod, nom in m.DESTINOS.items():
        if cod in TREN_COORDS:
            por_nombre.setdefault(_norm_ciudad(nom), []).append(
                (m.ESTACION.get(cod, nom).title(), *TREN_COORDS[cod]))
    out = {}
    for iata, nom in destinos_script().items():
        if "(" in nom:
            continue
        if _norm_ciudad(nom) in por_nombre:
            out[iata] = por_nombre[_norm_ciudad(nom)]
    return out


def destinos_tren():
    m = _modulo_trenes()
    return dict(m.DESTINOS) if m else {}


def grupos_tren():
    m = _modulo_trenes()
    return {g: list(d) for g, d in m.GRUPOS_TREN.items()} if m else {}


@st.cache_data(show_spinner="Cargando precios de tren…", persist="disk", ttl="7d")
def cargar_trenes(mt_):
    """Un tren por fila, solo la consulta más reciente de cada destino/día/sentido/compañía."""
    if not os.path.exists(CSV_TREN):
        return pd.DataFrame()
    t = leer_tabla(CSV_TREN, mt_, dtype={"codigo": str, "hora_salida": str, "hora_llegada": str,
                                         "tren": str, "tarifas": str, "tipo_tren": str})
    if t.empty:
        return t
    t["fecha"] = pd.to_datetime(t["fecha"], errors="coerce")
    t["consulta"] = pd.to_datetime(t["consulta"], errors="coerce")
    for c in ("precio_eur", "precio_max", "duracion_min", "plazas", "distancia_km", "directo", "disponible"):
        t[c] = pd.to_numeric(t[c], errors="coerce")
    t = t.dropna(subset=["fecha"])
    t = t[t["hora_salida"].notna() & (t["hora_salida"].str.len() > 0)]
    if t.empty:
        return t
    ult = t.groupby(["fecha", "sentido", "codigo", "compania"])["consulta"].transform("max")
    t = t[t["consulta"] == ult]
    t = t[t["fecha"] >= pd.Timestamp.today().normalize()]
    hm = t["hora_salida"].str.split(":", expand=True)
    t["salida_h"] = pd.to_numeric(hm[0], errors="coerce") + pd.to_numeric(hm[1], errors="coerce") / 60
    t["dia"] = t["fecha"].dt.dayofweek.map(dict(enumerate(DIAS)))
    t["mes"] = t["fecha"].dt.strftime("%Y-%m")
    t["antelacion"] = (t["fecha"] - t["consulta"].dt.normalize()).dt.days
    t = t.reset_index(drop=True)
    # un precio por tarifa (Básico, Elige, Prémium, Esencial…) para poder elegir la tarifa
    partes = t["tarifas"].fillna("").str.split(" | ", regex=False).explode()
    r = partes.str.rpartition(" ")
    p = pd.to_numeric(r[2], errors="coerce")
    ok = p.notna() & ~r[2].str.startswith("+") & (r[0] != "")
    tar = pd.DataFrame({"n": r[0][ok], "p": p[ok]})
    if not tar.empty:
        piv = tar.groupby([tar.index, "n"])["p"].min().unstack()
        piv = piv.loc[:, piv.notna().sum() >= 5]
        piv.columns = ["pt_" + c for c in piv.columns]
        t = t.join(piv)
    return t


@st.cache_data(show_spinner=False)
def meta_hoteles(mt_):
    """Datos pequeños de hoteles que necesita el menú lateral (hay datos, tipos, estaciones).
    Se leen solo 6 columnas de la copia Parquet: no hace falta cargar la tabla entera (cientos
    de MB) para dibujar el menú, y eso es lo que hacía lenta cada página al abrirla."""
    c = leer_columnas(CSV_HOT, mt_, ["tipo", "codigo", "lat", "lon", "fecha_entrada",
                                     "precio_noche", "precio_total", "noches"])
    if c is not None:
        if c.empty or "fecha_entrada" not in c.columns:
            return {"hay": False, "tipos": [], "estacion": False}
        fe = pd.to_datetime(c["fecha_entrada"].astype(str), errors="coerce", format="%Y-%m-%d").fillna(
            pd.to_datetime(c["fecha_entrada"].astype(str), errors="coerce", dayfirst=True))
        pn = pd.to_numeric(c["precio_noche"], errors="coerce")
        if "precio_total" in c.columns and "noches" in c.columns:
            pn = pn.fillna(pd.to_numeric(c["precio_total"], errors="coerce")
                           / pd.to_numeric(c["noches"], errors="coerce").replace(0, np.nan))
        ok = (fe > pd.Timestamp.today().normalize()) & pn.notna()
        c = c[ok.to_numpy()]
        est = estaciones_por_codigo()
        con_est = bool(len(c) and "lat" in c.columns and
                       c.loc[c["lat"].notna() & c["lon"].notna(), "codigo"].isin(list(est)).any())
        return {"hay": not c.empty,
                "tipos": sorted(x for x in c["tipo"].dropna().unique() if x) if "tipo" in c.columns else [],
                "estacion": con_est}
    h = cargar_hoteles(mt_)
    return {"hay": not h.empty,
            "tipos": sorted(x for x in h["tipo"].dropna().unique() if x) if "tipo" in h.columns else [],
            "estacion": bool("min_andando_estacion" in h.columns and h["min_andando_estacion"].notna().any())}


@st.cache_data(show_spinner=False)
def meta_trenes(mt_):
    t = cargar_trenes(mt_)
    if t.empty:
        return {"hay": False, "tarifas": [], "companias": [], "tipos": []}
    return {"hay": True,
            "tarifas": sorted(c[3:] for c in t.columns if c.startswith("pt_")),
            "companias": sorted(t["compania"].dropna().unique()),
            "tipos": sorted(x for x in t["tipo_tren"].dropna().unique() if x)}


@st.cache_data(show_spinner=False)
def claves_trenes(mt_):
    """(codigo, fecha_iso, sentido) ya descargados (aunque ese día no hubiera trenes)."""
    try:
        d = leer_tabla(CSV_TREN, mt_, dtype=str)
    except Exception:
        return set()
    if d.empty or "compania" not in d.columns:
        return set()
    d = d[d["compania"] .isin(["Renfe", "Combinado"])]
    return set(zip(d["codigo"], d["fecha"].astype(str), d["sentido"]))


@st.cache_data(show_spinner=False, ttl="6h")
def leer_historico_trenes(mt_hist):
    try:
        h = leer_tabla(CSV_TREN_HIST, mt_hist, dtype={"codigo": str, "hora_salida": str, "tren": str})
    except Exception:
        return pd.DataFrame()
    if h.empty:
        return h
    h["consulta"] = pd.to_datetime(h["consulta"], errors="coerce")
    h["fecha"] = pd.to_datetime(h["fecha"], errors="coerce")
    h["precio_eur"] = pd.to_numeric(h["precio_eur"], errors="coerce")
    return h.dropna(subset=["consulta", "fecha", "precio_eur"])


def grupo_tarifa(nombre):
    l = nombre.lower()
    if any(k in l for k in ("básico", "basico", "esencial", "basic")):
        return "basica"
    if any(k in l for k in ("prémium", "premium", "flex")):
        return "premium"
    return "media"


FLEX_TREN = ["Cualquiera", "Permite cambios (Elige o superior)", "Reembolsable / flexible (Prémium)"]


def reprecio_tarifas(t, tarifas, flex):
    """Pone como precio el de las tarifas elegidas (y/o con la flexibilidad pedida): el más barato
    entre ellas. Los trenes que no tienen esa tarifa se quitan."""
    if not tarifas and flex == "Cualquiera":
        return t
    cols = [c for c in t.columns if c.startswith("pt_")]
    sel = [c[3:] for c in cols if (not tarifas or c[3:] in tarifas)]
    if flex == FLEX_TREN[1]:
        sel = [n for n in sel if grupo_tarifa(n) != "basica"]
    elif flex == FLEX_TREN[2]:
        sel = [n for n in sel if grupo_tarifa(n) == "premium"]
    if not sel:
        return t.iloc[0:0]
    sub = t[["pt_" + n for n in sel]]
    precio = sub.min(axis=1)
    usada = sub.fillna(np.inf).idxmin(axis=1).str[3:]
    t = t.assign(precio_eur=precio, tarifa_min=usada)
    return t[precio.notna()]


def filtro_trenes(t, ft):
    """Filtros de 🚆 Tren: tarifa, compañía, tipo, horas, duración, directos, plazas y precio."""
    comps, tipos, hida, hvta, dur_max, directos, solo_disp, pmax = ft[:8]
    t = reprecio_tarifas(t, ft[8] if len(ft) > 8 else (), ft[9] if len(ft) > 9 else "Cualquiera")
    m = pd.Series(True, index=t.index)
    if comps:
        m &= t["compania"].isin(comps)
    if tipos:
        m &= t["tipo_tren"].isin(tipos)
    ida = t["sentido"] == "ida"
    m &= np.where(ida, t["salida_h"].between(hida[0], hida[1]), t["salida_h"].between(hvta[0], hvta[1]))
    if dur_max:
        m &= t["duracion_min"].isna() | (t["duracion_min"] <= dur_max * 60)
    if directos:
        m &= t["directo"] == 1
    if solo_disp:
        m &= t["disponible"] == 1
    if pmax:
        m &= t["precio_eur"].notna() & (t["precio_eur"] <= pmax)
    return t[m]


def coste_maletas(aerolineas, tarifas, n_fact, cabina):
    """€ de equipaje por persona y trayecto según la aerolínea (la más cara si hay varias)."""
    if not n_fact and not cabina:
        return pd.Series(0.0, index=aerolineas.index)
    tab = [(a.lower(), f, c) for a, f, c in tarifas if a != "Otras"]
    otras = next(((f, c) for a, f, c in tarifas if a == "Otras"), (0, 0))
    cache = {}

    def una(s):
        if s not in cache:
            costes = []
            for a in str(s).split("/"):
                a = a.strip().lower()
                f, c = next(((f, c) for n, f, c in tab if n == a),
                            next(((f, c) for n, f, c in tab if n in a), otras))
                costes.append(n_fact * f + (c if cabina else 0))
            cache[s] = max(costes) if costes else 0
        return cache[s]
    return aerolineas.map(una).astype(float)


@st.cache_data(show_spinner="Calculando los vuelos más baratos…", persist="disk", ttl="7d")
def mejores_tramos(mt_o, mt_m, fv, maletas, tarifas):
    """Para cada día/sentido/destino, el vuelo más barato (con maletas) que cumple los filtros."""
    o = cargar_opciones(mt_o, mt_m)
    max_esc, incl, excl, dur_max, esc_max, evitar_sig, win_ida, win_vta = fv
    if max_esc is not None:
        o = o[o["escalas"] <= max_esc]
    if incl:
        o = o[o["aerolinea"].fillna("").str.contains("|".join(map(re.escape, incl)))]
    if excl:
        o = o[~o["aerolinea"].fillna("").str.contains("|".join(map(re.escape, excl)))]
    if dur_max:
        o = o[o["duracion_min"] <= dur_max * 60]
    if esc_max:
        o = o[(o["escalas"] == 0) | (o["escala_max_min"].fillna(0) <= esc_max * 60)]
    if evitar_sig:
        o = o[~o["llega_sig"]]
    ok_ida = (o["sentido"] == "IDA") & o["sal_min"].between(win_ida[0] * 60, win_ida[1] * 60)
    ok_vta = (o["sentido"] == "VUELTA") & o["sal_min"].between(win_vta[0] * 60, win_vta[1] * 60)
    o = o[ok_ida | ok_vta]
    if o.empty:
        return o
    o = o.assign(maletas=coste_maletas(o["aerolinea"], tarifas, *maletas))
    o["coste"] = o["precio_eur"] + o["maletas"]
    idx = o.groupby(["fecha", "sentido", "codigo"])["coste"].idxmin()
    return o.loc[idx].reset_index(drop=True)


@st.cache_data(show_spinner=False)
def combinar(mt_o, mt_m, fv, maletas, tarifas, noches):
    """Empareja cada IDA con la VUELTA N días después, para cada N elegido.
    Solo cruza las claves y los números: el detalle (aerolínea, horas…) se añade después,
    y únicamente para las filas que se van a enseñar."""
    base = mejores_tramos(mt_o, mt_m, fv, maletas, tarifas)
    if base.empty:
        return pd.DataFrame()
    b = base.reset_index(drop=True)
    b["fila"] = b.index
    dia0 = (pd.to_datetime(b["fecha"]) - pd.Timestamp("1970-01-01")).dt.days   # días desde 1970
    b = b.assign(dia=dia0)
    ida = b.loc[b["sentido"] == "IDA", ["codigo", "ciudad", "dia", "coste", "fila"]]
    vta = b.loc[b["sentido"] == "VUELTA", ["codigo", "dia", "coste", "fila"]]
    partes = []
    for n in noches:
        m = (ida.assign(dia_v=ida["dia"] + n)
             .merge(vta, left_on=["codigo", "dia_v"], right_on=["codigo", "dia"],
                    suffixes=("_ida", "_vta")))
        m["dias"] = n
        partes.append(m)
    c = pd.concat(partes, ignore_index=True) if partes else pd.DataFrame()
    if c.empty:
        return c
    # todo vectorizado: sin texto ni objetos por fila (son cientos de miles)
    ida_dt = pd.to_datetime(c["dia_ida"], unit="D")
    vta_dt = pd.to_datetime(c["dia_vta"], unit="D")
    c["ida"], c["vuelta"] = ida_dt, vta_dt
    c["pp"] = c["coste_ida"] + c["coste_vta"]          # por persona, vuelos + maletas
    c["dia_ida_sem"] = pd.Categorical.from_codes(ida_dt.dt.dayofweek, DIAS)
    c["dia_vuelta"] = pd.Categorical.from_codes(vta_dt.dt.dayofweek, DIAS)
    meses = ida_dt.dt.year * 12 + ida_dt.dt.month - 1
    únicos = np.unique(meses)
    etiquetas = [f"{m // 12:04d}-{m % 12 + 1:02d}" for m in únicos]
    c["mes"] = pd.Categorical.from_codes(np.searchsorted(únicos, meses), etiquetas)
    c = c.drop(columns=["dia_v", "dia_ida", "dia_vta"])      # se quitan los días numéricos
    return c.rename(columns={"dia_ida_sem": "dia_ida"})


def con_detalle(c, mt_o, mt_m, fv, maletas, tarifas):
    """Añade a esas filas el detalle de cada vuelo (aerolínea, horas, escalas, maletas…)."""
    if c.empty:
        return c
    base = mejores_tramos(mt_o, mt_m, fv, maletas, tarifas).reset_index(drop=True)
    det = ["precio_eur", "maletas", "aerolinea", "escalas", "hora_salida", "hora_llegada",
           "duracion_min", "aeropuerto_llegada", "co2_kg", "ultima_descarga"]
    out = c.copy()
    for lado in ("ida", "vta"):
        trozo = base.loc[c[f"fila_{lado}"].values, det].reset_index(drop=True)
        trozo.columns = [f"{x}_{lado}" for x in det]
        out = pd.concat([out.reset_index(drop=True), trozo], axis=1)
    out["maletas_pp"] = out["maletas_ida"] + out["maletas_vta"]
    out["co2"] = out["co2_kg_ida"] + out["co2_kg_vta"]
    out["aeropuerto"] = out["aeropuerto_llegada_ida"]
    out["descarga"] = out[["ultima_descarga_ida", "ultima_descarga_vta"]].min(axis=1)
    return out


def url_ida_vuelta(dest, f_ida, f_vta, personas):
    try:
        from fast_flights import FlightQuery, Passengers, create_query
        return create_query(
            flights=[FlightQuery(date=f_ida.isoformat(), from_airport=ORIGEN, to_airport=dest),
                     FlightQuery(date=f_vta.isoformat(), from_airport=dest, to_airport=ORIGEN)],
            trip="round-trip", passengers=Passengers(adults=personas),
            language="es", currency="EUR").url()
    except Exception:
        return (f"https://www.google.com/travel/flights?q=Flights%20from%20{ORIGEN}%20to%20{dest}"
                f"%20on%20{f_ida}%20returning%20{f_vta}&hl=es&curr=EUR")


def detallar(t, personas):
    """Detalle de los vuelos + enlace de reserva, solo para las filas que se muestran."""
    t = con_detalle(t, mt_opc, mt, F["fv"], F["maletas"], F["tarifas"])
    return con_enlaces(t, personas)


def con_enlaces(t, personas):
    t = t.copy()
    t["reservar"] = [url_ida_vuelta(r.codigo, r.ida, r.vuelta, personas)
                     for r in t[["codigo", "ida", "vuelta"]].itertuples()]
    return t


# ==================================================================== DESCARGA
TIPOS_DESCARGA = ("vuelos", "hoteles", "trenes")
NOMBRE_TIPO = {"vuelos": "✈️ Vuelos", "hoteles": "🏨 Hoteles", "trenes": "🚆 Trenes"}
ICONO_TIPO = {"vuelos": "✈️", "hoteles": "🏨", "trenes": "🚆"}
COLOR_TIPO = {"vuelos": "#38BDF8", "hoteles": "#FB923C", "trenes": "#34D399"}
LOGS = {t: os.path.join(BASE, f"descarga_{t}.log") for t in TIPOS_DESCARGA}
PIDS = {t: os.path.join(BASE, f"descarga_{t}.pid") for t in TIPOS_DESCARGA}


META = {t: os.path.join(BASE, f"descarga_{t}.meta.json") for t in TIPOS_DESCARGA}
HISTORIAL_DESCARGAS = os.path.join(BASE, "descargas_historial.json")


def _leer_json(ruta, defecto):
    try:
        with open(ruta, encoding="utf-8") as f:
            return json.load(f)
    except (OSError, ValueError):
        return defecto


def _escribir_json(ruta, obj):
    try:
        tmp = ruta + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(obj, f, ensure_ascii=False)
        os.replace(tmp, ruta)
    except OSError:
        pass


def leer_meta(tipo):
    """Datos de la descarga en curso (cuándo empezó y cuántas consultas se esperan)."""
    return _leer_json(META[tipo], {})


def seg_previo(tipo, defecto=None):
    """Segundos por consulta según tus últimas descargas de este tipo (estimación lineal)."""
    h = _leer_json(HISTORIAL_DESCARGAS, {}).get(tipo, [])[-5:]
    v = [x["seg"] / x["n"] for x in h if x.get("n", 0) >= 20 and x.get("seg", 0) > 0]
    return float(np.median(v)) if v else defecto


def registrar_historial(tipo, hechos, seg):
    """Guarda cuánto ha tardado esta descarga para estimar las siguientes."""
    if hechos < 20 or seg <= 0:
        return
    h = _leer_json(HISTORIAL_DESCARGAS, {})
    h.setdefault(tipo, []).append({"n": int(hechos), "seg": round(seg, 1),
                                   "fecha": datetime.now().strftime("%Y-%m-%d %H:%M")})
    h[tipo] = h[tipo][-20:]
    _escribir_json(HISTORIAL_DESCARGAS, h)


@st.cache_resource
def proceso(tipo):
    """Proceso de descarga en curso de este tipo (sobrevive a recargas y cambios de página)."""
    return {"p": None}


def descargando(tipo=None):
    """True si hay una descarga de ese tipo en marcha, lanzada desde esta misma
    sesion (proceso(t)) o desde la tarea programada / otra sesion (fichero .pid:
    vease mantenimiento.pid_en_marcha). Comprobar tambien el .pid es lo que evita
    que se pueda arrancar una descarga manual mientras la programada ya esta
    corriendo, y viceversa."""
    tipos = [tipo] if tipo else list(TIPOS_DESCARGA)
    for t in tipos:
        p = proceso(t)["p"]
        if p is not None and p.poll() is None:
            return True
        if mantenimiento.pid_en_marcha(PIDS[t]) is not None:
            return True
    return False


def _modulo_script():
    try:
        sys.path.insert(0, CARPETA)
        import vuelos_madrid
        return vuelos_madrid
    except Exception:
        return None


def destinos_script():
    m = _modulo_script()
    return getattr(m, "DESTINOS", {}) if m else {}


def grupos_script():
    m = _modulo_script()
    return getattr(m, "GRUPOS", {}) if m else {}

def _modulo_hoteles():
    try:
        sys.path.insert(0, CARPETA)
        import hoteles_madrid
        return hoteles_madrid
    except Exception:
        return None


@st.cache_data(show_spinner=False)
def coords_aeropuertos(codigos):
    """lat/lon del aeropuerto de cada código (y de Madrid), reutilizando hoteles_madrid.py."""
    m = _modulo_hoteles()
    if not m:
        return {}
    out = {}
    for cod in set(codigos) | {"MAD"}:
        try:
            lat, lon = m.coords_aeropuerto(cod)
        except Exception:
            lat, lon = None, None
        if lat:
            out[cod] = (lat, lon)
    return out

def pendientes(ruta, codigos, dias, horas):
    total = len(codigos) * dias * 2
    if not os.path.exists(ruta):
        return total
    d = pd.read_csv(ruta, sep=";", encoding="utf-8-sig", on_bad_lines="skip",
                    usecols=["fecha", "sentido", "codigo", "ultima_descarga"])
    d = d.drop_duplicates(["fecha", "sentido", "codigo"], keep="last")
    fin = (date.today() + timedelta(days=dias)).isoformat()
    d = d[d["codigo"].isin(codigos) & (d["fecha"] > date.today().isoformat()) & (d["fecha"] <= fin)]
    if horas is not None:
        edad = (datetime.now() - pd.to_datetime(d["ultima_descarga"])).dt.total_seconds() / 3600
        d = d[edad <= horas]
    return max(total - len(d), 0)


def lanzar(args, script=None, tipo="vuelos", n=None):
    env = dict(os.environ, PYTHONIOENCODING="utf-8", PYTHONUNBUFFERED="1")
    log = open(LOGS[tipo], "w", encoding="utf-8")
    python = sys.executable.replace("pythonw.exe", "python.exe")
    flags = (subprocess.CREATE_NO_WINDOW | subprocess.CREATE_NEW_PROCESS_GROUP) if os.name == "nt" else 0
    proceso(tipo)["p"] = subprocess.Popen([python, "-u", script or SCRIPT, *args], stdout=log,
                                          stderr=subprocess.STDOUT, env=env, creationflags=flags)
    try:
        with open(PIDS[tipo], "w") as f:       # para que el icono de la bandeja sepa que hay descarga
            f.write(str(proceso(tipo)["p"].pid))
    except OSError:
        pass
    # cuándo empieza y cuántas consultas se esperan: sirve para estimar el progreso mientras el script
    # prepara los datos (antes de que escriba la primera línea de progreso)
    _escribir_json(META[tipo], {"inicio": time.time(), "n": int(n or 0),
                                "seg_est": seg_previo(tipo) or 0.7})


MODOS = ["Solo lo que falta",
         "Refrescar lo de hace más de 24 h",
         "Solo el próximo mes (refrescar)",
         "Solo los meses que hayan cambiado (sondeo)",
         "Todo de nuevo"]
HORAS_MODO = {MODOS[0]: None, MODOS[1]: 24, MODOS[2]: 0, MODOS[3]: 0, MODOS[4]: 0}

VELOCIDADES = {   # etiqueta: (hilos, consultas/s al empezar, techo de consultas/s)
    "🐢 Prudente": (3, 0.7, 2),
    "🚶 Normal": (6, 2, 6),
    "🏃 Rápida": (10, 5, 10),
    "🚀 Máxima": (16, 8, 16),
}


# Hoteles y trenes: la de siempre = los valores por defecto de cada script (no se pasa nada)
VEL_TH = {   # etiqueta: {tipo: (hilos, consultas/s al empezar, techo)}; None = valores del script
    "🚶 Normal": None,
    "🏃 Rápida": {"hoteles": (12, 2, 12), "trenes": (6, 1.5, 4.5)},
    "🚀 Máxima": {"hoteles": (16, 3, 16), "trenes": (8, 2, 6)},
}
AVISO_VEL_TH = {
    "hoteles": "«Máxima»: 16 hilos y hasta 16 consultas/s. A 8/s (Normal) no hubo bloqueos en 35.000 "
               "consultas; por encima no está probado y Google puede pedir captcha (se pausa 2 min).",
    "trenes": "«Máxima»: 8 hilos y hasta 6 consultas/s. Con Normal (hasta 3/s) Ouigo ya pidió pausas de "
              "2 min; más rápido hay riesgo claro de bloqueo.",
}


PAUSAS_AVISO = 3    # pausas por bloqueo a partir de las cuales se avisa / se baja la velocidad


@st.cache_data(show_spinner=False)
def _pausas(ruta, mt_):
    try:
        with open(ruta, "rb") as f:
            return f.read().count(b"demasiadas consultas")
    except OSError:
        return 0


def pausas_bloqueo(tipo):
    """Pausas por bloqueo de la última descarga (lanzar() vacía el log al empezar cada una)."""
    return _pausas(LOGS[tipo], mtime(LOGS[tipo]))


def selector_velocidad_th(tipo, clave):
    """Selectbox de velocidad para hoteles/trenes. Devuelve los argumentos --hilos/--velocidad/
    --velocidad-max ([] = valores por defecto del script)."""
    vel = st.selectbox("Velocidad", list(VEL_TH), key=clave)
    por_defecto = leer_config().get(f"auto_vel_{tipo}", True)
    auto = st.checkbox("Bajar la velocidad si la última descarga tuvo bloqueos", value=por_defecto,
                       key=clave + "_auto")
    if auto != por_defecto:
        guardar_config(**{f"auto_vel_{tipo}": auto})
    if auto and vel != "🚶 Normal" and (n := pausas_bloqueo(tipo)) >= PAUSAS_AVISO:
        niveles = list(VEL_TH)
        nivel = niveles[niveles.index(vel) - 1]
        st.caption(f"⬇️ La última descarga tuvo {n} pausas por bloqueo: se usará «{nivel}» en vez de «{vel}».")
        vel = nivel
    v = (VEL_TH[vel] or {}).get(tipo)
    if v:
        st.caption(f"{v[0]} hilos · empieza prudente y sube sola hasta {v[2]:g} consultas/s si no hay "
                   f"bloqueos. " + (AVISO_VEL_TH[tipo] if vel == "🚀 Máxima" else ""))
    return ["--hilos", str(v[0]), "--velocidad", str(v[1]), "--velocidad-max", str(v[2])] if v else []


def construir_args(destinos, prio, peso, vel, dias, horas, sondeo_n=0):
    """Argumentos para vuelos_madrid.py (los usan el botón y las descargas periódicas)."""
    hilos, cps, cps_max = VELOCIDADES.get(vel, VELOCIDADES[list(VELOCIDADES)[1]])
    cfg = leer_config()
    args = ["--dias", str(int(dias)), "--salida", CSV, "--opciones", CSV_OPC, "--destinos", *destinos,
            "--hilos", str(hilos), "--velocidad", str(cps), "--velocidad-max", str(cps_max)]
    if prio:
        args += ["--prioritarios", *prio, "--peso", str(peso / 100)]
    if cfg.get("umbral"):
        args += ["--umbral", str(int(cfg["umbral"]))]
    if sondeo_n:
        args += ["--sondeo", str(int(sondeo_n))]
    if horas is not None:
        args += ["--actualizar", str(horas)]
    return args


# Oculta la ventana (st.dialog) al instante: st.rerun() la cierra, pero solo cuando termina de ejecutarse
# la página entera, y con datos grandes eso tarda unos segundos durante los que parecía no hacer nada.
OCULTAR_DIALOGO = "<style>[data-testid='stDialog']{display:none!important}</style>"


def confirmar_descarga(args, n, codigos, seg=None, script=None, tipo="vuelos", nota=None):
    """Lanza la descarga directamente, sin ventana de confirmación (el nombre se conserva porque
    lo llaman todos los botones). El aviso indica cuántas consultas son y cuánto se estima."""
    seg_ef = seg_previo(tipo) or seg or ritmo(mtime(CSV))
    minutos = int(n * seg_ef / 60)
    lanzar(args, script=script, tipo=tipo, n=n)
    st.session_state["aviso"] = ("🚀", f"Descarga iniciada: {n:,} consultas".replace(",", ".")
                                 + (f" · ~{dur(minutos)}" if minutos >= 1 else " · menos de 1 min"))
    st.rerun()


@st.dialog("¿Detener la descarga?")
def confirmar_parada(tipo):
    st.write("Lo ya descargado se conserva. Podrás continuar más tarde desde donde se quedó.")
    c1, c2 = st.columns(2)
    if c1.button("Sí, detener", type="primary", width="stretch"):
        st.html(OCULTAR_DIALOGO)
        st.toast("Deteniendo la descarga…", icon="⏹️")
        if True:
            p = proceso(tipo)["p"]
            if p and p.poll() is None:
                try:
                    p.send_signal(signal.CTRL_BREAK_EVENT if os.name == "nt" else signal.SIGINT)
                    p.wait(timeout=12)
                except Exception:
                    pass
                if p.poll() is None:
                    p.terminate()
                    try:
                        p.wait(timeout=8)
                    except Exception:
                        pass
        st.rerun()
    if c2.button("Seguir descargando", width="stretch"):
        st.html(OCULTAR_DIALOGO)
        st.rerun()


def leer_log(tipo):
    try:
        with open(LOGS[tipo], encoding="utf-8", errors="replace") as f:
            return f.read().splitlines()
    except OSError:
        return []


def etiqueta(o, d, f):
    nombres = {**destinos_script(), ORIGEN: "Madrid"}
    dt = pd.to_datetime(f)
    return f"{nombres.get(o, o)} → {nombres.get(d, d)} · {CORTO[dt.dayofweek]} {dt:%d/%m/%y}"


def etiqueta_hotel(ciudad, f):
    dt = pd.to_datetime(f)
    return f"{ciudad} · {CORTO[dt.dayofweek]} {dt:%d/%m/%y}"


def estado_descarga(tipo):
    """Interpreta el log de descarga de este tipo."""
    lineas = leer_log(tipo)
    e = dict(hechos=0, total=0, errores=0, resta=None, activos={}, resultados=[], fallos=[],
             pausa=None, parada=None, cps=None, historial_ritmo=[], lineas=lineas)
    for l in lineas:
        m = re.search(r"(\d+)/(\d+)\s+\((\d+) errores\)\s+~(\d+) min", l)
        if m:
            e.update(hechos=int(m[1]), total=int(m[2]), errores=int(m[3]), resta=int(m[4]))
            v = re.search(r"\[([\d.]+) consultas/s([^\]]*)\]", l)
            if v:
                e["cps"] = v[1] + " consultas/s" + v[2]
                e["historial_ritmo"].append((int(m[4]), float(v[1])))
            continue
        m = re.search(r"pendientes: (\d+)", l)
        if m and not e["total"]:
            e["total"] = int(m[1])
        if tipo == "vuelos":
            m = re.match(r"\s+([>=!])\s+(\w{3})->(\w{3}) (\d{4}-\d\d-\d\d):?\s*(.*)", l)
            if m:
                sig, o, d, f, resto = m.groups()
                if sig == ">":
                    e["activos"][(o, d, f)] = True
                    e["pausa"] = None
                else:
                    e["activos"].pop((o, d, f), None)
                    (e["resultados"] if sig == "=" else e["fallos"]).append((o, d, f, resto))
        else:
            m = re.match(r"\s+([>=!])\s+(.+?) (\d{4}-\d\d-\d\d)(?: \((?:\d+n|ida|vuelta)\))?:?\s*(.*)", l)
            if m:
                sig, ciudad, f, resto = m.groups()
                if sig == ">":
                    e["activos"][(ciudad, f)] = True
                    e["pausa"] = None
                else:
                    e["activos"].pop((ciudad, f), None)
                    (e["resultados"] if sig == "=" else e["fallos"]).append((ciudad, f, resto))
        if l.strip().startswith("?"):
            e.setdefault("sondeo", []).append(l.strip(" ?"))
        elif l.strip().startswith("~"):
            e["pausa"] = l.strip(" ~")
        elif l.strip().startswith("!!"):
            e["parada"] = l.strip(" !")
    e["hechos"] = max(e["hechos"], len(e["resultados"]) + len(e["fallos"]))
    return e


def fin_de_descarga(e, codigo, tipo):
    proceso(tipo)["p"] = None
    meta = leer_meta(tipo)
    if meta.get("inicio"):        # cuánto ha tardado: sirve para estimar las próximas
        registrar_historial(tipo, e["hechos"], time.time() - meta["inicio"])
    try:
        os.remove(META[tipo])
    except OSError:
        pass
    try:
        os.remove(PIDS[tipo])
    except OSError:
        pass
    cargar.clear()
    combinar.clear()
    if tipo == "trenes":
        cargar_trenes.clear()
        claves_trenes.clear()
        leer_historico_trenes.clear()
    if tipo == "hoteles":
        cargar_hoteles.clear()
        hoteles_filtrados.clear()
        indice_hoteles.clear()
        coste_estancia.clear()
        indice_estancias.clear()
    if e["parada"] or (e["total"] and e["errores"] >= max(1, e["hechos"]) * 0.8):
        motivo = e["fallos"][-1][3] if e["fallos"] else "errores repetidos"
        st.session_state["aviso"] = ("⚠️", f"La descarga se ha detenido: {motivo}. Prueba más tarde.")
    elif codigo == 0:
        st.session_state["aviso"] = ("✅", f"Descarga terminada: {e['total']} consultas"
                                     + (f", {e['errores']} con error (vuelve a descargar para reintentarlas)"
                                        if e["errores"] else ""))
    else:
        st.session_state["aviso"] = ("⏹️", "Descarga detenida. Lo descargado se ha guardado.")
    # Al terminar/detener, que se vean los datos definitivos ya mismo, sin esperar al margen
    # normal de mt_estable() (que existe para no releer en cada clic mientras se descarga).
    st.session_state.pop("_mt_vuelos_estable", None)
    st.session_state.pop("_mt_opciones_estable", None)
    st.session_state.pop("_mt_hoteles_estable", None)
    st.session_state.pop("_mt_trenes_estable", None)
    st.rerun(scope="app")


INTERVALOS = {"5 segundos": 5, "15 segundos": 15, "30 segundos": 30, "1 minuto": 60,
              "2 minutos": 120, "5 minutos": 300, "10 minutos": 600}


def intervalo_refresco():
    """Cada cuántos segundos se refrescan el progreso y los datos (configurable)."""
    return int(leer_config().get("refresco", 120))


def auto_refresco(func, segundos):
    """Refresca solo mientras hay una descarga; si no, la app se queda quieta."""
    if descargando():
        st.fragment(run_every=segundos)(func)()
    else:
        func()


def mini_progreso(tipo):
    """Barra lateral: detecta el final de la descarga y avisa de que hay precios nuevos. El progreso
    en sí se ve en el recuadro fijo de abajo a la derecha (widget_descarga)."""
    p = proceso(tipo)["p"]
    if p is None:
        return
    if p.poll() is not None:
        fin_de_descarga(estado_descarga(tipo), p.poll(), tipo)
        return
    if tipo == "vuelos":
        nuevos = (mtime(CSV), mtime(CSV_OPC)) != st.session_state.get("mt_cargado")
        if nuevos:
            if st.session_state.get("auto"):
                if time.time() - st.session_state.get("t_carga", 0) > intervalo_refresco():
                    st.session_state.pop("_mt_vuelos_estable", None)
                    st.session_state.pop("_mt_opciones_estable", None)
                    st.rerun(scope="app")
            elif st.button("🔄 Ver precios nuevos", width="stretch", key="ver_nuevos_vuelos"):
                # Fuerza la recarga ya mismo, saltándose el margen normal de mt_estable(): el
                # usuario ha pedido explícitamente ver los precios nuevos ahora.
                st.session_state.pop("_mt_vuelos_estable", None)
                st.session_state.pop("_mt_opciones_estable", None)
                st.rerun(scope="app")


def progreso_detallado(tipo):
    p = proceso(tipo)["p"]
    if p is None:
        return
    e = estado_descarga(tipo)
    if p.poll() is not None:
        fin_de_descarga(e, p.poll(), tipo)
        return
    info = datos_progreso(tipo, {**e, "hay_progreso": e["resta"] is not None})
    titulo = {"vuelos": "Descargando vuelos", "hoteles": "Descargando hoteles",
              "trenes": "Descargando trenes"}[tipo]
    with st.status(f"{titulo}… {info['cuenta']}".rstrip("… "), expanded=True, state="running"):
        st.progress(info["frac"],
                    text=info["texto"]
                    + (" restantes (ritmo de los últimos 5 min)" if not info["estimado"] and e["resta"] is not None else "")
                    + (f" · ⚠️ {e['errores']} errores" if e["errores"] else "")
                    + (f" · {e['cps']}" if e.get("cps") else ""))
        if e["pausa"]:
            st.warning(f"⏸️ {e['pausa']}. Se reanuda sola.")
        if tipo != "vuelos" and (n := sum("demasiadas consultas" in l for l in e["lineas"])) >= PAUSAS_AVISO:
            st.warning(f"🚧 {n} pausas por bloqueo en esta descarga. Si sigue, detenla y lánzala con una "
                       "velocidad menor.")
        if e.get("sondeo"):
            with st.expander(f"🔎 Sondeo por meses ({len(e['sondeo'])} meses comprobados)", expanded=True):
                for l in e["sondeo"][-14:]:
                    st.markdown("✅ " + l if "mantener" in l else "🔁 " + l)
        pts = curva_descarga(tipo)
        if len(pts) >= 3:
            st.caption("📈 Avance de la descarga: % del total (eje vertical) según los minutos transcurridos")
            st.plotly_chart(fig_curva_descarga(tipo, pts), width="stretch", key=f"curva_{tipo}")
        c1, c2 = st.columns(2)
        with c1:
            st.markdown("**🔄 Consultando ahora**")
            for k in list(e["activos"])[-4:]:
                st.markdown(f"✈️ {etiqueta(*k)}" if tipo == "vuelos"
                            else f"{ICONO_TIPO[tipo]} {etiqueta_hotel(*k)}")
            if not e["activos"]:
                st.caption("Esperando entre consultas…")
        with c2:
            st.markdown("**✅ Últimos resultados**")
            if tipo == "vuelos":
                for o, d, f, resto in reversed(e["resultados"][-6:]):
                    st.markdown(f"{etiqueta(o, d, f)} — _sin vuelos_" if "sin vuelos" in resto
                                else f"{etiqueta(o, d, f)} — **{resto.replace(' EUR', ' €')}**")
            else:
                for ciudad, f, resto in reversed(e["resultados"][-6:]):
                    st.markdown(f"{etiqueta_hotel(ciudad, f)} — _sin resultados_"
                                if ("sin resultados" in resto or "sin trenes" in resto)
                                else f"{etiqueta_hotel(ciudad, f)} — **{resto.replace(' EUR', ' €')}**")
            if not e["resultados"]:
                st.caption("Todavía ninguno")
        if e["fallos"]:
            if tipo == "vuelos":
                o, d, f, resto = e["fallos"][-1]
                st.caption(f"⚠️ Último error: {etiqueta(o, d, f)} — {resto}")
            else:
                ciudad, f, resto = e["fallos"][-1]
                st.caption(f"⚠️ Último error: {etiqueta_hotel(ciudad, f)} — {resto}")


# ------------------------------------------------------------ recuadro fijo de progreso y recursos
RE_PROGRESO = re.compile(r"(\d+)/(\d+)\s+\((\d+) errores\)\s+~(\d+) min restantes(?:\s+\[([\d.]+) consultas/s)?")


def _extremos_log(ruta, cola=200_000, cabeza=6_000):
    """Principio y final del log sin leerlo entero (puede pesar decenas de MB)."""
    try:
        with open(ruta, "rb") as f:
            cab = f.read(cabeza)
            f.seek(0, os.SEEK_END)
            f.seek(max(0, f.tell() - cola))
            col = f.read()
    except OSError:
        return "", ""
    return cab.decode("utf-8", "replace"), col.decode("utf-8", "replace")


def estado_ligero(tipo):
    """Como estado_descarga(), pero solo con lo necesario para el recuadro fijo y leyendo
    únicamente el final del log: es barato y se puede llamar cada pocos segundos."""
    cab, col = _extremos_log(LOGS[tipo])
    e = dict(hechos=0, total=0, errores=0, resta=None, cps=None, activo=None, pausa=None,
             hay_progreso=False)
    m = re.search(r"pendientes: (\d+)", cab)
    if m:
        e["total"] = int(m[1])
    lineas = col.splitlines()
    for l in reversed(lineas):
        m = RE_PROGRESO.search(l)
        if m:
            e.update(hechos=int(m[1]), total=int(m[2]), errores=int(m[3]), resta=int(m[4]),
                     hay_progreso=True, cps=(m[5] + " consultas/s") if m[5] else None)
            break
    for l in lineas[-80:]:
        s = l.strip()
        if s.startswith(">"):
            e["activo"], e["pausa"] = s[1:].strip(), None
        elif s.startswith("~"):
            e["pausa"] = s.strip(" ~")
    return e


def datos_progreso(tipo, e):
    """Fracción, texto y contador de una descarga. Mientras el script todavía prepara los datos
    (y no hay líneas de progreso en el log) no se queda en 0 %: se estima de forma lineal con
    lo que tardaron tus descargas anteriores."""
    meta = leer_meta(tipo)
    total = e.get("total") or int(meta.get("n") or 0)
    if e.get("hay_progreso") and total:
        frac = min(e["hechos"] / total, 1.0)
        resta = e.get("resta")
        texto = f"{frac:.0%}" + (f" · ~{dur(resta)}" if resta is not None else "")
        return dict(frac=frac, cuenta=f"{e['hechos']:,}/{total:,}".replace(",", "."),
                    texto=texto, estimado=False)
    if total and meta.get("inicio"):
        seg_est = meta.get("seg_est") or seg_previo(tipo) or 0.7
        total_seg = total * seg_est
        trans = max(time.time() - meta["inicio"], 0)
        frac = min(trans / total_seg, 0.95) if total_seg else 0.0
        resta = int(max(total_seg - trans, 0) / 60)
        return dict(frac=frac, cuenta=f"{total:,} consultas".replace(",", "."),
                    texto=f"Preparando · ≈{frac:.0%} (estimado) · ~{dur(resta)}", estimado=True)
    return dict(frac=0.0, cuenta="", texto="Arrancando…", estimado=True)


RE_CURVA = re.compile(r"(\d+)/(\d+)\s+\(\d+ errores\).*?\bt=(\d+)s")


@st.cache_resource
def _curvas():
    return {}


def curva_descarga(tipo, max_pts=300):
    """Avance de la descarga en curso: [(minutos transcurridos, % del total hecho)]. Lee el log solo
    desde donde se quedó la última vez (puede pesar varios MB) y reduce los puntos para dibujarlos."""
    ruta = LOGS[tipo]
    inicio = leer_meta(tipo).get("inicio")
    c = _curvas().setdefault(tipo, {"off": 0, "pts": [], "inicio": None})
    try:
        tam = os.path.getsize(ruta)
    except OSError:
        return []
    if c["inicio"] != inicio or tam < c["off"]:       # descarga nueva: se empieza de cero
        c.update(off=0, pts=[], inicio=inicio)
    try:
        with open(ruta, "rb") as f:
            f.seek(c["off"])
            datos = f.read()
    except OSError:
        return []
    fin = datos.rfind(b"\n")
    if fin >= 0:
        c["off"] += fin + 1
        for l in datos[:fin].decode("utf-8", "replace").splitlines():
            m = RE_CURVA.search(l)
            if m and int(m[2]):
                c["pts"].append((int(m[3]) / 60, 100 * int(m[1]) / int(m[2])))
    pts = [(0.0, 0.0)] + c["pts"]
    if len(pts) > max_pts:
        paso = len(pts) / max_pts
        pts = [pts[int(i * paso)] for i in range(max_pts)] + [pts[-1]]
    return pts


def fig_curva_descarga(tipo, pts, alto=230):
    """Gráfico grande para la página Descargas: % del total (y) frente a minutos transcurridos (x)."""
    d = pd.DataFrame(pts, columns=["min", "pct"])
    fig = px.line(d, x="min", y="pct")
    fig.update_traces(line_color=COLOR_TIPO[tipo], line_width=3, hovertemplate="%{x:.1f} min · %{y:.1f} %<extra></extra>")
    fig.update_layout(xaxis_title="Minutos transcurridos", yaxis_title="% del total descargado",
                      yaxis=dict(range=[0, 100], ticksuffix=" %"))
    estilo(fig, alto=alto, leyenda="no")
    return fig


def _curva_svg(series, alto=104):
    """Mini-gráfico del recuadro: una línea por descarga (% del total frente a minutos)."""
    W, H, L, B, T = 340, alto, 30, 16, 6
    xmax = max([p[-1][0] for _, p in series if p] + [1.0])
    pf = lambda x, y: f"{L + x / xmax * (W - L - 8):.1f},{T + (100 - y) / 100 * (H - T - B):.1f}"
    g = []
    for y in (0, 50, 100):
        yy = T + (100 - y) / 100 * (H - T - B)
        g.append(f'<line x1="{L}" x2="{W - 8}" y1="{yy:.1f}" y2="{yy:.1f}" stroke="currentColor" '
                 f'stroke-opacity=".18"/><text x="{L - 4}" y="{yy + 3:.1f}" text-anchor="end" font-size="9" '
                 f'fill="currentColor" fill-opacity=".6">{y}%</text>')
    for x in (0, xmax / 2, xmax):
        xx = L + x / xmax * (W - L - 8)
        g.append(f'<text x="{xx:.1f}" y="{H - 3}" text-anchor="{"start" if x == 0 else "end" if x == xmax else "middle"}" '
                 f'font-size="9" fill="currentColor" fill-opacity=".6">{x:.0f} min</text>')
    for color, pts in series:
        if len(pts) < 2:
            continue
        g.append(f'<polyline fill="none" stroke="{color}" stroke-width="2" stroke-linejoin="round" '
                 f'points="{" ".join(pf(x, y) for x, y in pts)}"/>')
        x, y = pts[-1]
        g.append(f'<circle cx="{pf(x, y).split(",")[0]}" cy="{pf(x, y).split(",")[1]}" r="3" fill="{color}"/>')
    return f'<svg class="mw-gr" viewBox="0 0 {W} {H}" width="100%">{"".join(g)}</svg>'


@st.cache_resource
def _historial_monitor():
    from collections import deque
    return {"cpu": deque(maxlen=45), "ram": deque(maxlen=45), "procs": {}}


def monitor_recursos():
    """CPU y RAM del sistema y de esta app (servidor, descargas y lanzador)."""
    if psutil is None:
        return None
    try:
        yo = psutil.Process(os.getpid())
        grupo = [yo] + yo.children(recursive=True)
        try:
            padre = yo.parent()
            if padre and "vuelos_app" in " ".join(padre.cmdline()):
                grupo.append(padre)
        except Exception:
            pass
        hist = _historial_monitor()
        vivos, cpu_app, ram_app = {}, 0.0, 0
        for p in grupo:
            q = hist["procs"].get(p.pid, p)       # el mismo objeto entre llamadas: así cpu_percent() mide
            vivos[p.pid] = q
            try:
                cpu_app += q.cpu_percent(interval=None)
                ram_app += q.memory_info().rss
            except psutil.Error:
                continue
        hist["procs"] = vivos
        mem = psutil.virtual_memory()
        r = dict(cpu_sis=psutil.cpu_percent(interval=None), cpu_app=min(cpu_app / (psutil.cpu_count() or 1), 100.0),
                 ram_sis=mem.percent, ram_app=ram_app, ram_total=mem.total,
                 h_cpu=list(hist["cpu"]), h_ram=list(hist["ram"]))
        hist["cpu"].append(r["cpu_sis"])
        hist["ram"].append(r["ram_sis"])
        return r
    except Exception:
        return None


def _bytes_legibles(b):
    return f"{b / 2**30:.1f} GB" if b >= 2**30 else f"{b / 2**20:.0f} MB"


def _color_carga(pct):
    return ROJO if pct >= 85 else AMBAR if pct >= 60 else VERDE


def _spark(vals, color):
    if len(vals) < 2:
        return ""
    paso = 100 / (len(vals) - 1)
    pts = " ".join(f"{i * paso:.1f},{16 - min(max(v, 0), 100) * 0.16:.1f}" for i, v in enumerate(vals))
    return (f'<svg class="mw-sp" viewBox="0 0 100 16" preserveAspectRatio="none">'
            f'<polyline fill="none" stroke="{color}" stroke-width="1.4" stroke-linejoin="round" '
            f'vector-effect="non-scaling-stroke" points="{pts}"/></svg>')


def _fila_barra(titulo, frac, derecha, sub="", estimado=False, color="#38BDF8", frac2=None,
                extra="", ayuda=""):
    capa2 = (f'<b style="width:{min(max(frac2, 0), 1) * 100:.1f}%;background:{color}"></b>'
             if frac2 is not None else "")
    alfa = ' style="opacity:.45"' if frac2 is not None else ""
    return (f'<div class="mw-row" title="{ayuda}"><div class="mw-t"><span>{titulo}</span>'
            f'<span>{derecha}</span></div>'
            f'<div class="mw-b{" est" if estimado else ""}"><i{alfa} style="width:{min(max(frac, 0), 1) * 100:.1f}%;'
            f'background:{color}"></i>{capa2}</div>{extra}'
            + (f'<div class="mw-s">{sub}</div>' if sub else "") + "</div>")


def css_widget():
    oscuro = es_oscuro()
    fondo = "rgba(17,20,27,.97)" if oscuro else "rgba(255,255,255,.98)"
    borde = "rgba(255,255,255,.16)" if oscuro else "rgba(0,0,0,.16)"
    st.markdown(f"""<style>
.st-key-widget_dl{{position:fixed;right:18px;bottom:16px;width:376px;z-index:999990;background:{fondo};
 border:1px solid {borde};border-radius:14px;padding:9px 12px 7px;box-shadow:0 6px 24px rgba(0,0,0,.30)}}
.st-key-widget_dl [data-testid="stVerticalBlock"]{{gap:.25rem}}
.st-key-widget_dl [data-testid="stHorizontalBlock"]{{gap:.3rem;align-items:center}}
.st-key-widget_dl .stMarkdown p{{margin:0}}
.st-key-wd_toggle button{{min-height:1.5rem;padding:0 .45rem;border-radius:8px;line-height:1}}
.mw-h{{font-size:.8rem;font-weight:600;letter-spacing:.01em}}
.mw-row{{margin:3px 0 5px}}
.mw-t{{display:flex;justify-content:space-between;gap:8px;font-size:.78rem}}
.mw-t span:last-child{{opacity:.8;white-space:nowrap}}
.mw-b{{position:relative;height:6px;border-radius:99px;background:rgba(128,128,128,.25);overflow:hidden;margin:3px 0}}
.mw-b i,.mw-b b{{position:absolute;left:0;top:0;height:100%;border-radius:99px;transition:width .6s ease}}
.mw-b.est i{{background-image:repeating-linear-gradient(45deg,rgba(255,255,255,.35) 0 5px,transparent 5px 10px)!important}}
.mw-s{{font-size:.7rem;opacity:.62;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}}
.mw-sp{{display:block;width:100%;height:38px;margin-top:2px;opacity:.9}}
.mw-gr{{display:block;margin:4px 0 2px}}
.mw-gt{{font-size:.72rem;opacity:.7;margin-top:4px}}
.mw-min{{font-size:.76rem;opacity:.9}}
[data-testid="stStatusWidget"]{{visibility:hidden}}
/* la animación de entrada de la página deja el contenedor con «transform» y eso ancla los elementos
   fijos a él en vez de a la ventana: sin «forwards» el recuadro queda siempre abajo a la derecha */
[data-testid="stMain"] .block-container{{animation-fill-mode:backwards!important}}
</style>""", unsafe_allow_html=True)


@st.fragment(run_every=2)
def widget_descarga():
    """Recuadro fijo abajo a la derecha (en todas las páginas): progreso de las descargas y
    consumo de CPU/RAM. Se actualiza solo, sin recargar la página que estás mirando."""
    activos = [t for t in TIPOS_DESCARGA if descargando(t)]
    for t in TIPOS_DESCARGA:                    # descarga lanzada desde aquí que ya ha terminado
        p = proceso(t)["p"]
        if p is not None and p.poll() is not None:
            fin_de_descarga(estado_descarga(t), p.poll(), t)   # recarga los datos y refresca la app
    antes = st.session_state.get("_wd_activos", [])
    st.session_state["_wd_activos"] = activos
    if antes and not activos:                          # terminó una lanzada desde otro sitio
        st.rerun(scope="app")
    con_monitor = st.session_state.get("monitor_on", True)
    if not activos and not con_monitor:
        return

    filas, resumen = [], []
    for t in activos:
        e = estado_ligero(t)
        info = datos_progreso(t, e)
        if e["pausa"]:
            sub = "⏸️ Pausa por captcha, se reanuda sola"
        else:
            sub = ""
            if e["activo"]:
                m = re.match(r"(\w{3})->(\w{3}) (\d{4}-\d\d-\d\d)", e["activo"])
                try:
                    sub = "🔄 " + (etiqueta(*m.groups()) if m else e["activo"].split(" (")[0])
                except Exception:
                    sub = "🔄 " + e["activo"]
        if e["errores"]:
            sub = (sub + " · " if sub else "") + f"⚠️ {e['errores']} errores"
        nombre_t = NOMBRE_TIPO[t]
        filas.append(_fila_barra(nombre_t, info["frac"], info["texto"],
                                 (info["cuenta"] + " · " if info["cuenta"] else "") + sub,
                                 estimado=info["estimado"], color=COLOR_TIPO[t]))
        resumen.append(f"{ICONO_TIPO[t]} {info['frac']:.0%}")

    mon = monitor_recursos() if con_monitor else None
    if con_monitor:
        if mon:
            c_cpu, c_ram = _color_carga(mon["cpu_sis"]), _color_carga(mon["ram_sis"])
            filas.append(_fila_barra(
                "CPU", mon["cpu_sis"] / 100, f"{mon['cpu_sis']:.0f} % · app {mon['cpu_app']:.0f} %",
                color=c_cpu, frac2=mon["cpu_app"] / 100, extra=_spark(mon["h_cpu"], c_cpu),
                ayuda="Barra clara: todo el ordenador · barra sólida: esta app (servidor y descargas)"))
            filas.append(_fila_barra(
                "RAM", mon["ram_sis"] / 100,
                f"{mon['ram_sis']:.0f} % · app {_bytes_legibles(mon['ram_app'])}",
                color=c_ram, frac2=mon["ram_app"] / max(mon["ram_total"], 1), extra=_spark(mon["h_ram"], c_ram),
                ayuda=f"Barra clara: RAM usada en el ordenador ({_bytes_legibles(mon['ram_total'])} en total) "
                      "· barra sólida: esta app"))
            resumen.append(f"CPU {mon['cpu_sis']:.0f} %")
            resumen.append(f"RAM {mon['ram_sis']:.0f} %")
        else:
            filas.append('<div class="mw-s">Para ver CPU y RAM hace falta psutil: '
                         'ejecuta «Actualizar» para instalarlo.</div>')

    minimizado = st.session_state.get("wd_min", False)
    with st.container(key="widget_dl"):
        c1, c2 = st.columns([8, 1], vertical_alignment="center")
        c1.markdown(f'<div class="mw-h">{"⬇️ Descargas" if activos else "🖥️ Recursos"}</div>'
                    if not minimizado else f'<div class="mw-min">{" · ".join(resumen)}</div>',
                    unsafe_allow_html=True)
        c2.button("▴" if minimizado else "▾", key="wd_toggle",
                  on_click=lambda: st.session_state.update(wd_min=not st.session_state.get("wd_min", False)),
                  help="Mostrar u ocultar el detalle")
        if not minimizado:
            st.markdown("".join(filas), unsafe_allow_html=True)
            if activos:
                series = [(COLOR_TIPO[t], curva_descarga(t)) for t in activos]
                if any(len(p) >= 3 for _, p in series):
                    st.markdown('<div class="mw-gt">📈 Avance: % del total · minutos transcurridos</div>'
                                + _curva_svg(series), unsafe_allow_html=True)
                st.page_link(PAGINA_DESCARGAS, label="Ver detalle", icon="⬇️")


# ============================================================ CARGA Y FILTROS
if "aviso" in st.session_state:
    icono, txt = st.session_state.pop("aviso")
    st.toast(txt, icon=icono)

mt = mt_estable(CSV, "_mt_vuelos_estable")
mt_opc = mt_estable(CSV_OPC, "_mt_opciones_estable")
mt_hot = mt_estable(CSV_HOT, "_mt_hoteles_estable")
mt_tren = mt_estable(CSV_TREN, "_mt_trenes_estable")
# Aviso visible aunque haya un diálogo (st.dialog) abierto: un st.spinner en el cuerpo
# principal queda oculto detrás del fondo del diálogo, así que para la recarga (potencialmente
# lenta si hay una descarga en curso cambiando el fichero) usamos también un toast, que sí se
# ve por encima. Solo se dispara cuando el fichero ha cambiado de verdad (posible recálculo),
# no en cada rerun.
if mt and st.session_state.get("_mt_csv_visto") != mt:
    st.toast("Cargando precios de vuelos…", icon="⏳")
st.session_state["_mt_csv_visto"] = mt
if mt_hot and st.session_state.get("_mt_hot_visto") != mt_hot:
    st.toast("Cargando precios de alojamiento…", icon="⏳")
st.session_state["_mt_hot_visto"] = mt_hot
df = pd.DataFrame()
if mt:
    try:
        with st.spinner("Cargando precios…"):
            df = cargar(CSV, mt)
    except Exception as ex:
        if not descargando():
            st.error(f"No he podido leer {CSV}: {ex}")
st.session_state["mt_cargado"] = (mt, mt_opc)
st.session_state["t_carga"] = time.time()
hay_datos = not df.empty and df["precio_eur"].notna().any()

sb = st.sidebar
MODO = "completo"  # Ya no hay selector de modo: cada página combina vuelos y hoteles en pestañas.

PAGINAS_LISTA = [
    st.Page(lambda: pag_resumen_todo(), title="Resumen", icon="🏠", default=True),
    st.Page(lambda: pag_buscador_todo(), title="Buscador", icon="🔎", url_path="buscador"),
    st.Page(lambda: pag_favoritos_todo(), title="Favoritos", icon="⭐", url_path="favoritos"),
    st.Page(lambda: pag_evolucion_todo(), title="Evolución", icon="📈", url_path="evolucion"),
    st.Page(lambda: pag_calendario_todo(), title="Calendario", icon="🗓️", url_path="calendario"),
    st.Page(lambda: pag_mapa_todo(), title="Mapa", icon="🗺️", url_path="mapa"),
    st.Page(lambda: pag_distribucion_todo(), title="Distribución", icon="📊", url_path="distribucion"),
    st.Page(lambda: pag_antelacion_todo(), title="Antelación", icon="📉", url_path="antelacion"),
    st.Page(lambda: pag_maletas_todo(), title="Maletas", icon="🧳", url_path="maletas"),
    st.Page(lambda: pag_gestion_datos_completo(), title="Gestión de datos", icon="🗄️", url_path="gestion"),
]
PAGINA_DESCARGAS = st.Page(lambda: pag_descargas(), title="Descargas", icon="⬇️", url_path="descargas")
pg = st.navigation(PAGINAS_LISTA + [PAGINA_DESCARGAS], position="hidden")
for _p in PAGINAS_LISTA:
    sb.page_link(_p)
sb.page_link(PAGINA_DESCARGAS)
sb.toggle("Monitor de CPU / RAM", value=bool(leer_config().get("monitor", True)), key="monitor_on",
          on_change=lambda: guardar_config(monitor=bool(st.session_state.get("monitor_on", True))),
          help="Muestra en el recuadro de abajo a la derecha cuánta CPU y RAM usa el ordenador y esta app")
sb.caption(f"v{VERSION}")
css_widget()
widget_descarga()


# ---- identidad visual del modo: icono arriba a la izquierda + transición al cambiar
def dibujar_logo(modo, ruta):
    """Genera el icono del modo (maleta o cama) en blanco sobre fondo transparente."""
    from PIL import Image, ImageDraw
    E = 8                                    # se dibuja en grande y se reduce: bordes suaves
    im = Image.new("RGBA", (128 * E, 40 * E), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    B, G = (255, 255, 255, 255), 3 * E       # blanco y grosor de línea
    def r(x, y, x2, y2, **kw): d.rounded_rectangle([x*E, y*E, x2*E, y2*E], **kw)
    if modo == "hoteles":
        d.line([(5*E, 8*E), (5*E, 32*E)], fill=B, width=G)                    # poste
        r(5, 20, 34, 32, radius=3*E, outline=B, width=G)                      # base de la cama
        r(9, 14, 20, 21, radius=2*E, outline=B, width=G)                      # almohada
        d.line([(20*E, 20.5*E), (34*E, 20.5*E)], fill=B, width=G)
    else:                                                                     # maleta con mango extendido
        d.line([(14*E, 13*E), (14*E, 2.5*E), (26*E, 2.5*E), (26*E, 13*E)], fill=B, width=G, joint="curve")
        r(6, 13, 34, 34, radius=6*E, outline=B, width=G)                      # cuerpo de esquinas curvas
        d.line([(14*E, 18*E), (14*E, 30*E)], fill=B, width=G)                 # franjas
        d.line([(26*E, 18*E), (26*E, 30*E)], fill=B, width=G)
        r(9, 34, 13, 37.5, radius=1.5*E, fill=B)                              # ruedas
        r(27, 34, 31, 37.5, radius=1.5*E, fill=B)
    im.resize((128, 40), Image.LANCZOS).save(ruta)
    return ruta


@st.cache_resource(show_spinner=False)
def logo_modo(modo):
    ruta = os.path.join(ASSETS_DIR, f"icono_{modo}.png")
    try:
        return dibujar_logo(modo, ruta)
    except Exception:
        return ICONO if modo == "vuelos" and os.path.exists(ICONO) else None


_logo = logo_modo(MODO)
if _logo:
    try:
        st.logo(_logo, size="large")
    except Exception:
        pass
st.markdown(f"""<style>
[data-testid="stMain"] .block-container{{animation:entra-{MODO} .40s cubic-bezier(.22,.7,.3,1) both}}
[data-testid="stSidebar"] [data-testid="stExpander"],
[data-testid="stSidebarNav"]{{animation:entra-{MODO} .40s ease both}}
[data-testid="stLogo"]{{animation:logo-{MODO} .45s ease both}}
@keyframes entra-{MODO}{{from{{opacity:0;transform:translateY(10px)}}to{{opacity:1;transform:none}}}}
@keyframes logo-{MODO}{{from{{opacity:0;transform:scale(.82) rotate(-8deg)}}
 to{{opacity:1;transform:none}}}}
</style>""", unsafe_allow_html=True)
hay_hoteles = mt_hot > 0 and meta_hoteles(mt_hot)["hay"]
hay_trenes = mt_tren > 0 and meta_trenes(mt_tren)["hay"]

with sb:
    _seg = intervalo_refresco()
    if MODO != "hoteles":
        auto_refresco(lambda: mini_progreso("vuelos"), _seg)
    if MODO != "vuelos":
        auto_refresco(lambda: mini_progreso("hoteles"), _seg)
    auto_refresco(lambda: mini_progreso("trenes"), _seg)
    if descargando():
        etq = [k for k, v in INTERVALOS.items() if v == _seg]
        st.session_state.setdefault("f_refresco", etq[0] if etq else "2 minutos")
        nuevo_int = st.selectbox("Refrescar cada", list(INTERVALOS), key="f_refresco",
                                 help="Cada cuánto se recargan los precios nuevos en las páginas. "
                                      "El recuadro de progreso se actualiza solo cada 2 s sin recargar nada.")
        if INTERVALOS[nuevo_int] != _seg:
            guardar_config(refresco=INTERVALOS[nuevo_int])
            st.rerun()
        st.toggle("Actualizar datos automáticamente", key="auto",
                  help=f"Recarga los precios nuevos cada {nuevo_int} mientras descarga")

CLAVES_FILTRO = ["f_ciudades", "f_grupos", "f_aeropuertos", "f_trayecto", "f_personas", "f_modo", "f_dias", "f_rango",
                 "f_modo_fecha", "f_dia_fecha", "f_rango_fecha",
                 "f_modo_vuelta", "f_dia_vuelta", "f_rango_vuelta",
                 "f_dsem", "f_pres", "f_hida", "f_hvta", "f_esc", "f_dur", "f_escmax",
                 "f_sig", "f_aer", "f_aerx", "f_fact", "f_cab",
                 "h_nota", "h_estrellas", "h_tipos", "h_servicios", "h_precio", "h_ubi",
                 "h_min", "h_min_transp", "h_resenas", "h_n", "h_modo_noches", "h_noches",
                 "h_noches_rango", "h_min_est",
                 "t_tar", "t_flex", "t_comp", "t_tipos", "t_hida", "t_hvta", "t_dur", "t_dir", "t_disp", "t_pmax"]


def _serializa(v):
    if isinstance(v, (list, tuple)):
        return [_serializa(x) for x in v]
    if isinstance(v, (date, datetime)):
        return v.isoformat()
    return v


def _deserializa(v):
    if isinstance(v, list):
        return tuple(_deserializa(x) for x in v)
    if isinstance(v, str) and len(v) == 10 and v[4] == "-" and v[7] == "-":
        try:
            return date.fromisoformat(v)
        except ValueError:
            return v
    return v


def restaurar_filtros():
    """Deja los filtros como estaban la última vez (se guardan en config_vuelos.json)."""
    if st.session_state.get("_filtros_restaurados"):
        return
    st.session_state["_filtros_restaurados"] = True
    for k, v in (leer_config().get("filtros") or {}).items():
        if k in CLAVES_FILTRO and k not in st.session_state:
            st.session_state[k] = _deserializa(v)


SECCIONES = {
    "Viaje": ["f_ciudades", "f_grupos", "f_aeropuertos", "f_trayecto", "f_personas", "f_modo", "f_dias", "f_rango",
              "f_modo_fecha", "f_dia_fecha", "f_rango_fecha",
              "f_modo_vuelta", "f_dia_vuelta", "f_rango_vuelta", "f_dsem", "f_pres"],
    "Vuelos": ["f_hida", "f_hvta", "f_esc", "f_dur", "f_escmax", "f_sig", "f_aer", "f_aerx"],
    "Equipaje": ["f_fact", "f_cab"],
    "Alojamiento": ["h_nota", "h_estrellas", "h_tipos", "h_servicios", "h_precio", "h_ubi",
                    "h_min", "h_min_transp", "h_resenas", "h_n", "h_modo_noches", "h_noches",
                    "h_noches_rango", "h_min_est"],
    "Tren": ["t_tar", "t_flex", "t_comp", "t_tipos", "t_hida", "t_hvta", "t_dur", "t_dir", "t_disp", "t_pmax"],
}
VACIOS = ([], (), None, "", 0, False, "Todas", "Todos", "Exactos", "Cualquiera", "Ida y vuelta")


def borrar_filtros(seccion=None):
    """Deja los filtros (de una sección o todos) como recién instalada la app."""
    claves = SECCIONES.get(seccion, CLAVES_FILTRO)
    for k in claves:
        st.session_state.pop(k, None)
    guardar_config(filtros={k: v for k, v in (leer_config().get("filtros") or {}).items()
                            if k not in claves})
    st.session_state["aviso"] = ("🧹", f"Filtros de {seccion} borrados" if seccion
                                 else "Todos los filtros borrados")


def hay_filtros(claves):
    return any(k in st.session_state and st.session_state[k] not in VACIOS for k in claves)


def boton_borrar(seccion):
    """Botón de limpiar dentro de cada sección; solo si hay algo que limpiar."""
    if hay_filtros(SECCIONES[seccion]):
        st.button(f"🧹 Borrar filtros de {seccion.lower()}", width="stretch",
                  key=f"b_limpiar_{seccion}", on_click=borrar_filtros, args=(seccion,))


def guardar_filtros():
    actual = {k: _serializa(st.session_state[k]) for k in CLAVES_FILTRO if k in st.session_state}
    if actual != (leer_config().get("filtros") or {}):
        guardar_config(filtros=actual)


def sincronizar_filtros():
    """Los filtros de cada página (claves m_f_x) son un espejo de la barra lateral (f_x). Si el usuario
    ha tocado el espejo, el valor pasa a la barra lateral antes de que ésta se dibuje."""
    ss = st.session_state
    prev = ss.setdefault("_sync_f", {})
    for k in CLAVES_FILTRO:
        m = "m_" + k
        if k not in ss:
            continue
        if m in ss and k in prev and _serializa(ss[m]) != prev[k] and _serializa(ss[k]) == prev[k]:
            ss[k] = ss[m]
        prev[k] = _serializa(ss[k])


restaurar_filtros()
sincronizar_filtros()
# valores por defecto: así las páginas de hoteles funcionan aunque no haya (o no se usen) vuelos
_hoy = date.today()
F = {"ciudades": [], "trayecto": "Ida y vuelta", "personas": 1, "noches": tuple(range(1, 15)), "dias_sem": [],
     "presupuesto": 0, "fecha_libre": True, "vuelta_libre": True, "noches_estancia": (1,),
     "rango": (_hoy, _hoy + timedelta(days=400)), "rango_vuelta": (_hoy, _hoy + timedelta(days=400)),
     "maletas": (0, False), "tarifas": ()}
def bloque_viaje(p, cont):
    with cont:
        ciudades = sorted(df.loc[df["precio_eur"].notna(), "ciudad"].unique())
        con_datos = codigos_con_datos(mt)          # se calcula una vez, no por cada aeropuerto
        grupos_dis = {g: [c for c in d if c in con_datos] for g, d in grupos_script().items()}
        grupos_dis = {g: d for g, d in grupos_dis.items() if d}
        cg, cd = st.columns(2)
        sel_g = cg.multiselect("Zonas", list(grupos_dis), key=p + "f_grupos", placeholder="Todas",
                               format_func=lambda g: f"{g} ({len(grupos_dis[g])})",
                               help="Elige zonas enteras, destinos sueltos, o las dos cosas a la vez")
        sel_d = cd.multiselect("Destinos", ciudades, key=p + "f_ciudades", placeholder="Todos")
        de_grupos = sorted(df.loc[df["codigo"].isin({c for g in sel_g for c in grupos_dis[g]}),
                                  "ciudad"].unique())
        aer_dis = aeropuertos_disponibles(mt)
        if p + "f_aeropuertos" in st.session_state:      # etiquetas guardadas que ya no existan
            st.session_state[p + "f_aeropuertos"] = [a for a in st.session_state[p + "f_aeropuertos"]
                                                 if a in aer_dis]
        sel_a = st.multiselect("Aeropuerto (nombre o código)", list(aer_dis), key=p + "f_aeropuertos",
                               placeholder="Todos",
                               help="Escribe un código (BCN), una ciudad o parte del nombre del "
                                    "aeropuerto para buscarlo. Se suma a las zonas y destinos elegidos.")
        de_aero = {df.loc[df["codigo"] == aer_dis[a], "ciudad"].iloc[0] for a in sel_a
                   if (df["codigo"] == aer_dis[a]).any()}
        F["ciudades"] = sorted(set(sel_d) | set(de_grupos) | de_aero)
        if sel_g or sel_d:
            st.caption(f"🎯 {len(F['ciudades'])} destino(s) con datos: "
                       + ", ".join(F["ciudades"][:6]) + ("…" if len(F["ciudades"]) > 6 else ""))
        F["personas"] = st.number_input("Personas", 1, 9, 1, key=p + "f_personas")
        F["trayecto"] = st.radio("Trayecto", ["Ida y vuelta", "Solo ida", "Solo vuelta"],
                                 horizontal=True, key=p + "f_trayecto",
                                 help="Solo ida / solo vuelta muestra los vuelos sueltos (el más barato "
                                      "de cada día) en 🔎 Buscador y 📈 Evolución, sin emparejarlos.")
        modo = st.radio("Días de viaje", ["Exactos", "Rango"], horizontal=True, key=p + "f_modo",
                        help="Días entre la ida y la vuelta: 5 días = sale el 1 y vuelve el 6")
        if modo == "Exactos":
            F["noches"] = (int(st.number_input("Días", 1, 30, 5, key=p + "f_dias")),)
        else:
            a, b = st.slider("Días", 1, 30, (3, 7), key=p + "f_rango")
            F["noches"] = tuple(range(a, b + 1))
        fmin, fmax = df["fecha"].min(), df["fecha"].max()

        def filtro_fecha(titulo, clave, ayuda):
            """Devuelve (rango, es_libre, dia_exacto)."""
            modo_f = st.radio(titulo, ["Todas", "Entre fechas", "Día exacto"], horizontal=True,
                              key=f"{p}f_modo_{clave}", help=ayuda)
            if modo_f == "Todas":
                return (fmin, fmax), True, None
            if modo_f == "Día exacto":
                d = st.date_input("Día", fmin, min_value=fmin, max_value=fmax,
                                  format="DD/MM/YYYY", key=f"{p}f_dia_{clave}")
                return (d, d), False, d
            r = st.date_input("Entre", (fmin, fmax), min_value=fmin, max_value=fmax,
                              format="DD/MM/YYYY", key=f"{p}f_rango_{clave}")
            r = tuple(r) if isinstance(r, (tuple, list)) else (r,)
            rango = (r[0], r[1]) if len(r) == 2 else ((r[0], fmax) if len(r) == 1 else (fmin, fmax))
            return rango, False, None

        F["rango"], F["fecha_libre"], dia_ida = filtro_fecha(
            "Fecha de salida", "fecha", "Cuándo quieres salir de Madrid")
        F["rango_vuelta"], F["vuelta_libre"], dia_vta = filtro_fecha(
            "Fecha de vuelta", "vuelta", "Cuándo quieres volver a Madrid")
        if dia_ida and dia_vta:
            _d = (dia_vta - dia_ida).days
            if _d > 0:
                F["noches"] = (_d,)
                st.caption(f"Fechas exactas: {_d} días de viaje (se ignora el filtro de días).")
            else:
                st.warning("La vuelta tiene que ser posterior a la ida.")
        F["dias_sem"] = st.multiselect("Día de salida", DIAS, key=p + "f_dsem", placeholder="Cualquiera")
        F["presupuesto"] = st.number_input("Presupuesto máximo total (€)", 0, 20000, 0, step=50,
                                           key=p + "f_pres", help="Para todas las personas. 0 = sin límite")
        if not p:
            boton_borrar("Viaje")


if hay_datos:
    if hay_filtros(CLAVES_FILTRO):
        sb.button("🧹 Borrar todos los filtros", width="stretch", on_click=borrar_filtros,
                  help="Vuelve a los valores de inicio: todos los destinos, todas las fechas, "
                       "1 persona y sin restricciones de vuelo ni equipaje")
    bloque_viaje("", sb.expander("🎛️ Viaje", expanded=True))

def bloque_vuelos(p, cont):
    with cont:
        win_ida = st.slider("Hora de salida (ida)", 0, 24, (0, 24), key=p + "f_hida")
        win_vta = st.slider("Hora de salida (vuelta)", 0, 24, (0, 24), key=p + "f_hvta")
        esc = st.selectbox("Escalas (cada trayecto)", ["Cualquiera", "Solo directos", "Máx. 1"], key=p + "f_esc")
        max_esc = {"Cualquiera": None, "Solo directos": 0, "Máx. 1": 1}[esc]
        dur_max = st.slider("Duración máxima por trayecto (h)", 1, 24, 24, key=p + "f_dur")
        esc_max = st.slider("Espera máxima en escala (h)", 1, 24, 24, key=p + "f_escmax")
        evitar_sig = st.checkbox("Evitar llegar al día siguiente", key=p + "f_sig")
        aer = aerolineas_disponibles(mt)
        incl = st.multiselect("Solo estas aerolíneas", aer, key=p + "f_aer", placeholder="Todas")
        excl = st.multiselect("Excluir aerolíneas", aer, key=p + "f_aerx", placeholder="Ninguna")
        F["fv"] = (max_esc, tuple(incl), tuple(excl), dur_max if dur_max < 24 else None,
                   esc_max if esc_max < 24 else None, evitar_sig, win_ida, win_vta)
        if not p:
            boton_borrar("Vuelos")


def bloque_equipaje(p, cont):
    with cont:
        n_fact = st.radio("Maletas facturadas por persona", [0, 1, 2], horizontal=True, key=p + "f_fact")
        cabina = st.checkbox("Maleta de cabina grande (trolley)", key=p + "f_cab")
        F["maletas"] = (n_fact, cabina)
        st.caption("Se suma la tarifa de cada aerolínea por trayecto. Ajusta las tarifas en **🧳 Maletas**.")
        if not p:
            boton_borrar("Equipaje")


if hay_datos and MODO != "hoteles":
    bloque_vuelos("", sb.expander("🕐 Vuelos"))

    bloque_equipaje("", sb.expander("🧳 Equipaje"))
if F.get("fv") is None:          # en modo hoteles no hay filtros de vuelo
    F["fv"] = (None, (), (), None, None, False, (0, 24), (0, 24))
    F["maletas"] = (0, False)
F["tarifas"] = tuple(map(tuple, leer_tarifas().itertuples(index=False)))

ICONOS_SERV = {
    "desayuno": "🍳 Desayuno", "desayuno_pago": "🍳 Desayuno (de pago)",
    "wifi": "📶 Wi-Fi", "wifi_pago": "📶 Wi-Fi (de pago)", "parking": "🅿️ Parking",
    "parking_gratis": "🅿️ Parking gratis", "parking_pago": "🅿️ Parking (de pago)",
    "aire": "❄️ Aire acondicionado", "piscina": "🏊 Piscina", "restaurante": "🍽️ Restaurante",
    "bar": "🍸 Bar", "gimnasio": "🏋️ Gimnasio", "spa": "💆 Spa", "jacuzzi": "🛁 Jacuzzi",
    "cocina": "🍲 Cocina", "lavadora": "🧺 Lavadora", "lavanderia": "🧺 Lavandería",
    "mascotas": "🐾 Admite mascotas", "ninos": "🧸 Para niños", "no_fumadores": "🚭 Sin humo",
    "traslado_aeropuerto": "🚐 Traslado al aeropuerto",
    "servicio_habitaciones": "🛎️ Servicio de habitaciones", "accesible": "♿ Accesible",
}


@st.cache_data(show_spinner=False)
def servicios_disponibles(mt_):
    """Solo los servicios que de verdad aparecen en los datos descargados."""
    c = leer_columnas(CSV_HOT, mt_, list(ICONOS_SERV))
    h = c if c is not None else cargar_hoteles(mt_)
    return [k for k in ICONOS_SERV if k in h.columns and (h[k] == "sí").any()]


def bloque_hoteles(p, cont):
    with cont:
        nota = st.slider("Valoración mínima", 0.0, 5.0, 8.0 / 2, step=0.5, key=p + "h_nota",
                         help="Google puntúa sobre 5. 4,0 equivale a un 8 sobre 10")
        resenas_min = st.number_input("Reseñas mínimas", 0, 5000, 0, step=25, key=p + "h_resenas",
                                      help="Descarta alojamientos con muy pocas opiniones. "
                                           "0 = da igual")
        estrellas = st.selectbox("Estrellas mínimas", [0, 1, 2, 3, 4, 5], key=p + "h_estrellas",
                                 format_func=lambda x: "Cualquiera" if not x else f"{x}★ o más")
        tipos = st.multiselect("Tipo", mh_["tipos"],
                               key=p + "h_tipos", placeholder="Todos")
        disp = servicios_disponibles(mt_hot)
        servicios = st.multiselect("Tiene que incluir", disp, key=p + "h_servicios",
                                   placeholder="Lo que sea",
                                   format_func=lambda x: ICONOS_SERV.get(x, x))
        precio_max = st.number_input("Precio máximo por noche (€)", 0, 1000, 0, step=10,
                                     key=p + "h_precio", help="0 = sin límite")
        minutos = st.slider("Máximo andando al centro (min)", 0, 90, 0, step=5, key=p + "h_min",
                            help="Se calcula con las coordenadas del alojamiento y las del centro "
                                 "de la ciudad. 0 = sin límite")
        min_transp = st.slider("Máximo en transporte público al centro (min)", 0, 90, 0, step=5,
                               key=p + "h_min_transp",
                               help="Metro, bus o tren hasta el centro (Transitous; estimado si esa "
                                    "ciudad no tiene datos reales todavía). 0 = sin límite")
        min_est = 0
        if mh_["estacion"]:
            min_est = st.slider("Máximo andando a la estación de tren (min)", 0, 60, 0, step=5, key=p + "h_min_est",
                                help="Estación de tren de tu lista de destinos en esa misma ciudad. Distancia en "
                                     "línea recta ×1,3 a 4,8 km/h. Solo hay datos en ciudades españolas con "
                                     "estación en la lista de trenes. 0 = sin límite")
        ubicacion = st.checkbox("Solo «excelente ubicación»", key=p + "h_ubi")
        n_baratos = st.slider("Cuántos de los más baratos promedio", 3, 25, 10, key=p + "h_n",
                              help="El precio típico de cada ciudad es la mediana de los N más "
                                   "baratos que cumplen los filtros")
        modo_n = st.radio("Noches de estancia", ["Exactas", "Rango"], horizontal=True, key=p + "h_modo_noches")
        if modo_n == "Exactas":
            F["noches_estancia"] = (int(st.number_input("Noches", 1, 14, 1, key=p + "h_noches")),)
        else:
            a, b = st.slider("Noches", 1, 14, (1, 3), key=p + "h_noches_rango")
            F["noches_estancia"] = tuple(range(a, b + 1))
        F["fh"] = (nota, estrellas, tuple(tipos), tuple(servicios), precio_max, ubicacion,
                   minutos, int(resenas_min), min_transp, min_est)
        F["n_baratos"] = n_baratos
        if not p:
            boton_borrar("Alojamiento")


if MODO in ("hoteles", "completo") and hay_hoteles:
    mh_ = meta_hoteles(mt_hot)
    bloque_hoteles("", sb.expander("🏨 Alojamiento", expanded=MODO == "hoteles"))
else:
    F["fh"] = (0, 0, (), (), 0, False, 0, 0, 0, 0)
    F["n_baratos"] = 10

# filtros de tren: compañía, tipo, horas, duración, directos, plazas, precio
F["ft"] = ((), (), (0, 24), (0, 24), None, False, False, 0, (), "Cualquiera")
def bloque_tren(p, cont):
    with cont:
        t_nomtar = mtr_["tarifas"]
        t_tar = st.multiselect("Tarifa", t_nomtar, key=p + "t_tar", placeholder="La más barata de cada tren",
                               help="Compara los trenes con esa tarifa concreta (Básico, Elige, Prémium, "
                                    "Esencial…) en vez de con la más barata. Los trenes que no la tengan se ocultan.")
        t_flex = st.radio("Flexibilidad", FLEX_TREN, key=p + "t_flex",
                          help="Permite cambios = tarifas por encima de Básico/Esencial; reembolsable = Prémium.")
        t_comps = st.multiselect("Compañía", mtr_["companias"], key=p + "t_comp",
                                 placeholder="Todas")
        t_tipos = st.multiselect("Tipo de tren", mtr_["tipos"],
                                 key=p + "t_tipos", placeholder="Todos")
        t_hida = st.slider("Hora de salida (ida)", 0, 24, (0, 24), key=p + "t_hida")
        t_hvta = st.slider("Hora de salida (vuelta)", 0, 24, (0, 24), key=p + "t_hvta")
        t_dur = st.slider("Duración máxima (h)", 1, 24, 24, key=p + "t_dur")
        t_dir = st.checkbox("Solo directos", key=p + "t_dir")
        t_disp = st.checkbox("Solo con plazas y precio", key=p + "t_disp",
                             help="Oculta los trenes completos o sin tarifa disponible")
        t_pmax = st.number_input("Precio máximo por tren (€)", 0, 1000, 0, step=10, key=p + "t_pmax",
                                 help="0 = sin límite. Por persona y trayecto")
        F["ft"] = (tuple(t_comps), tuple(t_tipos), tuple(t_hida), tuple(t_hvta),
                   t_dur if t_dur < 24 else None, bool(t_dir), bool(t_disp), int(t_pmax),
                   tuple(t_tar), t_flex)
        if not p:
            boton_borrar("Tren")


if hay_trenes:
    mtr_ = meta_trenes(mt_tren)
    bloque_tren("", sb.expander("🚆 Tren"))

if hay_datos:
    guardar_filtros()


def combinaciones():
    """Combinaciones ida+vuelta con todos los filtros aplicados."""
    if not hay_datos:
        return pd.DataFrame()
    with st.spinner("Calculando combinaciones…"):
        c = combinar(mt_opc, mt, F["fv"], F["maletas"], F["tarifas"], F["noches"])
    if c.empty:
        return c
    if F["ciudades"]:
        c = c[c["ciudad"].isin(F["ciudades"])]
    r0, r1 = map(pd.Timestamp, F["rango"])
    v0, v1 = map(pd.Timestamp, F["rango_vuelta"])
    c = c[(c["ida"] >= r0) & (c["ida"] <= r1) & (c["vuelta"] >= v0) & (c["vuelta"] <= v1)]
    if F["dias_sem"]:
        c = c[c["dia_ida"].isin(F["dias_sem"])]
    c = c.assign(total=c["pp"] * F["personas"])
    c["por_dia"] = (c["total"] / c["dias"]).round(1)
    if F["presupuesto"]:
        c = c[c["total"] <= F["presupuesto"]]
    return c.sort_values("total").reset_index(drop=True)


def sin_datos():
    if descargando():
        st.info("⏳ Descargando los primeros precios… Aparecerán aquí en cuanto haya ida y vuelta "
                "para algún destino. Mientras tanto puedes ver el progreso en **⬇️ Descargas**.")
    else:
        st.info("Todavía no hay precios. Ve a **⬇️ Descargas** para lanzar la primera descarga.")


def sin_resultados():
    st.warning("No hay combinaciones con estos filtros. Prueba a ampliar fechas, días, destinos o presupuesto.")


def cabecera(titulo, subtitulo=None):
    icono, _, texto = titulo.partition(" ")
    titulo_pagina(icono, texto, subtitulo)
    if not hay_datos:
        return
    n = F["personas"]
    noches = F["noches"]
    chips = [("👥", f"{n} persona{'s' if n > 1 else ''}"),
             ("📍", ", ".join(F["ciudades"]) if F["ciudades"] else "Todos los destinos"),
             ("📆", f"{noches[0]}–{noches[-1]} días" if len(noches) > 1 else f"{noches[0]} días"),
             ("🛫", "Cualquier fecha" if F["fecha_libre"]
              else (f"{F['rango'][0]:%d/%m/%y}" if F["rango"][0] == F["rango"][1]
                    else f"{F['rango'][0]:%d/%m/%y} – {F['rango'][1]:%d/%m/%y}"))]
    if not F["vuelta_libre"]:
        chips.append(("🛬", f"{F['rango_vuelta'][0]:%d/%m/%y}" if F["rango_vuelta"][0] == F["rango_vuelta"][1]
                      else f"{F['rango_vuelta'][0]:%d/%m/%y} – {F['rango_vuelta'][1]:%d/%m/%y}"))
    if F.get("trayecto", "Ida y vuelta") != "Ida y vuelta":
        chips.append(("↔️", F["trayecto"]))
    if F["dias_sem"]:
        chips.append(("📅", ", ".join(d[:3] for d in F["dias_sem"])))
    if F["maletas"][0]:
        chips.append(("🧳", f"{F['maletas'][0]} maleta{'s' if F['maletas'][0] > 1 else ''} facturada"
                            f"{'s' if F['maletas'][0] > 1 else ''}"))
    if F["maletas"][1]:
        chips.append(("🎒", "Trolley"))
    if F["fv"][0] == 0:
        chips.append(("➡️", "Solo directos"))
    if F["presupuesto"]:
        chips.append(("💶", f"Máx. {F['presupuesto']:,} €".replace(",", ".")))
    if descargando():
        chips.append(("⏳", "Datos parciales"))
    st.markdown('<div class="chips">' + "".join(
        f'<span class="chip"><b>{i}</b> {t}</span>' for i, t in chips) + "</div>",
        unsafe_allow_html=True)


COLS = {
    "ciudad": "Destino",
    "ida": st.column_config.DateColumn("Ida", format="DD/MM/YY"),
    "vuelta": st.column_config.DateColumn("Vuelta", format="DD/MM/YY"),
    "dia_ida": "Día ida", "dia_vuelta": "Día vuelta", "dias": "Días",
    "total": st.column_config.NumberColumn("Total €", format="%d €"),
    "pp": st.column_config.NumberColumn("€/persona", format="%d €"),
    "por_dia": st.column_config.NumberColumn("€/día", format="%.0f €"),
    "precio_eur_ida": st.column_config.NumberColumn("Ida €/p", format="%d €"),
    "precio_eur_vta": st.column_config.NumberColumn("Vuelta €/p", format="%d €"),
    "aerolinea_ida": "Aerolínea ida", "aerolinea_vta": "Aerolínea vuelta",
    "hora_salida_ida": "Sale ida", "hora_salida_vta": "Sale vuelta",
    "escalas_ida": "Esc. ida", "escalas_vta": "Esc. vuelta", "descarga": "Descargado",
    "maletas_pp": st.column_config.NumberColumn("Maletas €/p", format="%d €",
                                                help="Estimación con las tarifas de 🧳 Maletas"),
    "aeropuerto": "Aeropuerto", "co2": st.column_config.NumberColumn("CO₂ kg/p", format="%d"),
    "hora_llegada_ida": "Llega ida", "hora_llegada_vta": "Llega vuelta",
    "reservar": st.column_config.LinkColumn("Reservar", display_text="✈️ Reservar"),
}


def panel_filtros():
    """Desplegable con los mismos filtros que la barra lateral, para cambiarlos sin salir de la página.
    Solo se dibuja abierto; cerrado no cuesta nada."""
    if not (hay_datos or hay_hoteles or hay_trenes):
        return
    try:
        ex = st.expander("🎚️ Filtros de esta página (los mismos que la barra lateral)", key="panel_filtros",
                         on_change="rerun")
        abierto = bool(ex.open)
    except TypeError:
        ex, abierto = st.expander("🎚️ Filtros de esta página (los mismos que la barra lateral)"), True
    if not abierto:
        return
    ss = st.session_state
    for k in CLAVES_FILTRO:                      # el espejo arranca con el valor de la barra lateral
        if k in ss:
            ss["m_" + k] = ss[k]
    nombres, funciones = [], []
    if hay_datos:
        nombres += ["🎛️ Viaje", "🕐 Vuelos", "🧳 Equipaje"]
        funciones += [bloque_viaje, bloque_vuelos, bloque_equipaje]
    if MODO in ("hoteles", "completo") and hay_hoteles:
        nombres.append("🏨 Alojamiento")
        funciones.append(bloque_hoteles)
    if hay_trenes:
        nombres.append("🚆 Tren")
        funciones.append(bloque_tren)
    with ex:
        tt = st.tabs(nombres)
        for t, fn in zip(tt, funciones):
            fn("m_", t)
        st.caption("Estos controles y los de la barra lateral son el mismo filtro: cambiar uno cambia el otro.")


# ===================================================================== PÁGINAS
def pag_resumen():
    cabecera("🏠 Resumen")
    if not hay_datos:
        return sin_datos()
    c = combinaciones()
    if c.empty:
        return sin_resultados()
    m = c.iloc[0]
    k = st.columns(5)
    k[0].metric("Opción más barata", eur(m.total), f"{m.ciudad} · {m.ida:%d/%m} → {m.vuelta:%d/%m}",
                delta_color="off", delta_arrow="off")
    k[1].metric("Por persona", eur(m.pp))
    k[2].metric("Total mediano", eur(c["total"].median()))
    k[3].metric("Combinaciones", f"{len(c):,}".replace(",", "."))
    k[4].metric("Destinos", c["ciudad"].nunique())
    st.link_button(f"✈️ Reservar la más barata ({eur(m.total)})",
                   url_ida_vuelta(m.codigo, m.ida, m.vuelta, F["personas"]), type="primary")

    st.subheader("Mejor opción por destino")
    mejor = detallar(c.drop_duplicates("ciudad"), F["personas"])
    izq, der = st.columns([3, 2])
    with izq:
        st.dataframe(mejor[["ciudad", "total", "pp", "ida", "dia_ida", "vuelta", "dias",
                            "aerolinea_ida", "aerolinea_vta", "reservar"]],
                     hide_index=True, width="stretch", column_config=COLS)
    with der:
        m2 = mejor.sort_values("total")
        fig = px.bar(m2, x="total", y="ciudad", orientation="h", text="total",
                     color="total", color_continuous_scale=ESCALA_PRECIO,
                     labels={"total": "Total más barato (€)", "ciudad": ""})
        fig.update_traces(texttemplate="<b>%{text:.0f} €</b>", textposition="outside",
                          cliponaxis=False, textfont_size=13,
                          textfont_color="#E8EAED" if es_oscuro() else "#202124",
                          hovertemplate="%{y}<br>%{x:.0f} €<extra></extra>")
        estilo(fig, alto=max(230, 42 * len(m2)), leyenda="no")
        fig.update_layout(coloraxis_showscale=False, yaxis=dict(autorange="reversed"),
                          xaxis=dict(showticklabels=False, title="", range=[0, m2["total"].max() * 1.18]),
                          bargap=.35, margin=dict(l=0, r=10, t=6, b=0))
        st.plotly_chart(fig, width="stretch")

    st.subheader("Precio mínimo por destino y mes")
    piv = c.assign(mes_txt=c["mes"].map(mes_legible)).pivot_table(
        index="ciudad", columns="mes_txt", values="total", aggfunc="min")
    piv = piv[sorted(piv.columns, key=lambda m: ORDEN_MES[m])]
    fig = px.imshow(piv, text_auto=".0f", color_continuous_scale=ESCALA_PRECIO, aspect="auto",
                    labels=dict(x="Mes de salida", y="", color="€"))
    fig.update_xaxes(type="category", side="top", tickangle=0, showgrid=False)
    fig.update_traces(xgap=4, ygap=4, hovertemplate="%{y} · %{x}<br>%{z:.0f} €<extra></extra>",
                      textfont_size=13)
    estilo(fig, alto=max(240, 46 * len(piv)), leyenda="no")
    fig.update_layout(margin=dict(t=34, b=6), coloraxis_colorbar=dict(title="€", thickness=10,
                      outlinewidth=0, len=.85))
    fig.update_yaxes(showgrid=False, title="")
    st.plotly_chart(fig, width="stretch")


def tramos_filtrados():
    """Vuelos sueltos (el más barato de cada día/sentido/destino) con los filtros actuales.
    Respeta el filtro «Trayecto»: solo ida o solo vuelta (o los dos si es ida y vuelta)."""
    d = mejores_tramos(mt_opc, mt, F["fv"], F["maletas"], F["tarifas"])
    if d.empty:
        return d
    if F["ciudades"]:
        d = d[d["ciudad"].isin(F["ciudades"])]
    sentido = {"Solo ida": "IDA", "Solo vuelta": "VUELTA"}.get(F.get("trayecto"))
    if sentido:
        d = d[d["sentido"] == sentido]
    r_ida, r_vta = F["rango"], F["rango_vuelta"]
    en_rango = np.where(d["sentido"] == "IDA",
                        (d["fecha"] >= r_ida[0]) & (d["fecha"] <= r_ida[1]),
                        (d["fecha"] >= r_vta[0]) & (d["fecha"] <= r_vta[1]))
    d = d[en_rango]
    if F["dias_sem"]:
        d = d[pd.to_datetime(d["fecha"]).dt.dayofweek.map(dict(enumerate(DIAS))).isin(F["dias_sem"])]
    d = d.assign(total=d["coste"] * F["personas"])
    if F["presupuesto"]:
        d = d[d["total"] <= F["presupuesto"]]
    return d.sort_values("total").reset_index(drop=True)


def pag_buscador_tramos():
    """Buscador de vuelos sueltos (solo ida o solo vuelta)."""
    d = tramos_filtrados()
    if d.empty:
        return sin_resultados()
    orden = st.segmented_control("Ordenar por", ["Total", "Fecha"], default="Total",
                                 key="orden_tramos")
    d = d.sort_values(["fecha", "total"] if orden == "Fecha" else ["total", "fecha"])
    d = d.assign(dia=pd.to_datetime(d["fecha"]).dt.dayofweek.map(dict(enumerate(DIAS))),
                 trayecto=np.where(d["sentido"] == "IDA", "Ida", "Vuelta"))
    if "enlace_reserva" not in d.columns:
        d["enlace_reserva"] = [f"https://www.google.com/travel/flights?q=Flights%20from%20{r.origen}"
                               f"%20to%20{r.destino}%20on%20{r.fecha}&hl=es&curr=EUR"
                               for r in d.itertuples()]
    cols = [c for c in ["ciudad", "trayecto", "total", "fecha", "dia", "origen", "destino",
                        "precio_eur", "maletas", "aerolinea", "hora_salida", "hora_llegada",
                        "escalas", "duracion_min", "enlace_reserva"] if c in d.columns]
    if not (F["maletas"][0] or F["maletas"][1]) and "maletas" in cols:
        cols.remove("maletas")
    vista = d.head(MAX_FILAS_TABLA)
    st.dataframe(vista[cols], hide_index=True, width="stretch", height=620, row_height=34,
                 column_config={
                     "ciudad": "Destino", "trayecto": "Trayecto",
                     "total": st.column_config.NumberColumn("Total €", format="%d €"),
                     "fecha": st.column_config.DateColumn("Fecha", format="DD/MM/YY"),
                     "dia": "Día", "origen": "Origen", "destino": "Destino (código)",
                     "precio_eur": st.column_config.NumberColumn("€/persona", format="%d €"),
                     "maletas": st.column_config.NumberColumn("Maletas €/p", format="%d €"),
                     "aerolinea": "Aerolínea", "hora_salida": "Sale", "hora_llegada": "Llega",
                     "escalas": "Escalas",
                     "duracion_min": st.column_config.NumberColumn("Duración (min)", format="%d"),
                     "enlace_reserva": st.column_config.LinkColumn("Reservar", display_text="✈️ Reservar")})
    extra = f" (se muestran los {MAX_FILAS_TABLA} primeros)" if len(d) > MAX_FILAS_TABLA else ""
    st.caption(f"{len(d):,} vuelos sueltos{extra}. Total = (vuelo + maletas) por persona × "
               f"{F['personas']}. Es el más barato de cada día que cumple los filtros de 🕐 Vuelos."
               .replace(",", "."))
    st.download_button("💾 Exportar a CSV (Excel)",
                       d.head(5000)[cols].to_csv(sep=";", decimal=",", index=False).encode("utf-8-sig"),
                       "vuelos_sueltos_filtrados.csv", "text/csv",
                       on_click=lambda: st.toast("Tabla exportada", icon="💾"))


def pag_buscador():
    cabecera("🔎 Buscador de vuelos")
    if not hay_datos:
        return sin_datos()
    if F.get("trayecto", "Ida y vuelta") != "Ida y vuelta":
        return pag_buscador_tramos()
    c = combinaciones()
    if c.empty:
        return sin_resultados()
    orden = st.segmented_control("Ordenar por", ["Total", "€/día", "Fecha de ida"], default="Total",
                                 key="orden")
    col = {"Total": "total", "€/día": "por_dia", "Fecha de ida": "ida"}.get(orden or "Total")
    c = c.sort_values([col, "total"])
    vista = detallar(c.head(MAX_FILAS_TABLA), F["personas"])
    cols_tabla = ["ciudad", "total", "reservar", "ida", "dia_ida", "vuelta", "dia_vuelta",
                  "dias", "pp", "maletas_pp", "por_dia", "aeropuerto",

                  "precio_eur_ida", "aerolinea_ida", "hora_salida_ida", "hora_llegada_ida",
                  "escalas_ida", "precio_eur_vta", "aerolinea_vta", "hora_salida_vta",
                  "hora_llegada_vta", "escalas_vta", "co2", "descarga"]
    if not (F["maletas"][0] or F["maletas"][1]):
        cols_tabla.remove("maletas_pp")
    st.dataframe(vista[cols_tabla], hide_index=True, width="stretch", height=620,
                 column_config=COLS, row_height=34)
    extra = f" (se muestran las {MAX_FILAS_TABLA} primeras)" if len(c) > MAX_FILAS_TABLA else ""
    st.caption(f"{len(c):,} combinaciones{extra}. Total = (vuelos + maletas) por persona × {F['personas']}. "
               "Los enlaces abren Google Flights con esa búsqueda; el precio puede haber cambiado "
               "desde la descarga.".replace(",", "."))
    exportable = detallar(c.head(5000), F["personas"]).drop(
        columns=[x for x in ["fila_ida", "fila_vta", "enlace_reserva_ida", "enlace_reserva_vta"]
                 if x in c.columns or True], errors="ignore")
    st.download_button("💾 Exportar a CSV (Excel)",
                       exportable.to_csv(sep=";", decimal=",", index=False).encode("utf-8-sig"),
                       "vuelos_filtrados.csv", "text/csv",
                       on_click=lambda: st.toast("Tabla exportada", icon="💾"))

    st.divider()
    opciones_fav = {f"{r.ciudad} · {r.ida:%d/%m/%y}→{r.vuelta:%d/%m/%y} · {r.total:.0f} €":
                    (r.codigo, r.ida.date().isoformat(), r.vuelta.date().isoformat(),
                     r.ciudad, round(float(r.total)))
                    for r in c.head(100).itertuples()}
    elegidos = st.multiselect("⭐ Marcar como favoritos (de los 100 primeros de la lista): se podrán "
                              "volver a descargar solo esos, sin bajar todo el destino",
                              list(opciones_fav), key="elegir_fav_vuelos")
    if st.button("⭐ Guardar como favoritos", disabled=not elegidos, key="guardar_fav_vuelos"):
        fav = leer_favoritos()
        existentes = {(f["codigo"], f["ida"], f["vuelta"]) for f in fav["vuelos"]}
        n = 0
        for e in elegidos:
            cod, ida_s, vta_s, ciudad, total = opciones_fav[e]
            if (cod, ida_s, vta_s) not in existentes:
                fav["vuelos"].append({"codigo": cod, "ciudad": ciudad, "ida": ida_s, "vuelta": vta_s,
                                      "total": total, "personas": F["personas"],
                                      "guardado": datetime.now().isoformat()})
                n += 1
        guardar_favoritos(fav)
        st.session_state["aviso"] = ("⭐", f"{n} favorito(s) nuevo(s) guardado(s)" if n
                                     else "Ya estaban guardados")
        st.rerun()


def pag_evolucion_tramos():
    """Evolución de vuelos sueltos (solo ida o solo vuelta): el más barato de cada día y destino."""
    d = tramos_filtrados()
    if d.empty:
        return sin_resultados()
    multi = d["ciudad"].nunique() > 1
    g = d.groupby(["fecha"] + (["ciudad"] if multi else []), as_index=False)["total"].min()
    solo = "ida" if F.get("trayecto") == "Solo ida" else "vuelta"
    fig = px.line(g.sort_values("fecha"), x="fecha", y="total", color="ciudad" if multi else None,
                  markers=len(g) < 120, color_discrete_sequence=COLORES,
                  labels={"fecha": "", "total": f"Total solo {solo} más barato (€, {F['personas']} pers.)", "ciudad": ""})
    fig.update_traces(line_width=2.2, marker_size=5, hovertemplate="%{y:.0f} €<extra>%{fullData.name}</extra>")
    estilo(fig, alto=460)
    fig.update_layout(hovermode="x unified")
    st.plotly_chart(fig, width="stretch")
    st.caption(f"Para cada fecha, el vuelo de solo {solo} más barato que cumple los filtros (con maletas si las has elegido).")
    st.subheader("Por día de la semana")
    d = d.assign(dia=pd.to_datetime(d["fecha"]).dt.dayofweek.map(dict(enumerate(DIAS))))
    s = d.groupby(["dia"] + (["ciudad"] if multi else []), as_index=False)["total"].median()
    s["orden"] = s["dia"].map({x: i for i, x in enumerate(DIAS)})
    fig = px.bar(s.sort_values("orden"), x="dia", y="total", color="ciudad" if multi else None, barmode="group",
                 color_discrete_sequence=COLORES, labels={"dia": "", "total": "Total mediano (€)", "ciudad": ""})
    estilo(fig, alto=330, leyenda="arriba" if multi else "no")
    fig.update_layout(bargap=.3)
    st.plotly_chart(fig, width="stretch")


def pag_evolucion():
    cabecera("📈 Evolución del precio")
    if not hay_datos:
        return sin_datos()
    if F.get("trayecto", "Ida y vuelta") != "Ida y vuelta":
        return pag_evolucion_tramos()
    c = combinaciones()
    if c.empty:
        return sin_resultados()
    color = "ciudad" if c["ciudad"].nunique() > 1 else ("dias" if len(F["noches"]) > 1 else None)
    g = c.groupby(["ida"] + ([color] if color else []), as_index=False)["total"].min()
    if color == "dias":
        g["dias"] = g["dias"].astype(str) + " días"
    fig = px.line(g, x="ida", y="total", color=color, markers=len(g) < 120,
                  color_discrete_sequence=COLORES,
                  labels={"ida": "", "total": f"Total más barato (€, {F['personas']} pers.)",
                          "ciudad": "", "dias": ""})
    fig.update_traces(line_width=2.2, marker_size=5, hovertemplate="%{y:.0f} €<extra>%{fullData.name}</extra>")
    estilo(fig, alto=460)
    fig.update_layout(hovermode="x unified")
    st.plotly_chart(fig, width="stretch")
    st.caption("Para cada fecha de salida, el total más barato entre los días de viaje elegidos.")
    st.subheader("Por día de la semana de salida")
    s = c.groupby(["dia_ida"] + (["ciudad"] if color == "ciudad" else []), as_index=False)["total"].median()
    s["orden"] = s["dia_ida"].map({d: i for i, d in enumerate(DIAS)})
    fig = px.bar(s.sort_values("orden"), x="dia_ida", y="total", color_discrete_sequence=COLORES,
                 color="ciudad" if color == "ciudad" else None, barmode="group",
                 labels={"dia_ida": "", "total": "Total mediano (€)", "ciudad": ""})
    fig.update_traces(hovertemplate="%{x}<br>%{y:.0f} €<extra>%{fullData.name}</extra>")
    estilo(fig, alto=330, leyenda="arriba" if color == "ciudad" else "no")
    fig.update_layout(bargap=.3)
    st.plotly_chart(fig, width="stretch")


def pag_calendario():
    cabecera("🗓️ Calendario")
    if not hay_datos:
        return sin_datos()
    c = combinaciones()
    if c.empty:
        return sin_resultados()
    cal = c.groupby("ida", as_index=False).agg(total=("total", "min"))
    cal["ida"] = pd.to_datetime(cal["ida"])
    cal["semana"] = cal["ida"] - pd.to_timedelta(cal["ida"].dt.dayofweek, unit="D")
    cal["dia"] = cal["ida"].dt.dayofweek.map(dict(enumerate(CORTO)))
    piv = cal.pivot_table(index="dia", columns="semana", values="total", aggfunc="min").reindex(CORTO)
    fig = px.imshow(piv, color_continuous_scale=ESCALA_PRECIO, aspect="auto",
                    labels=dict(x="Semana (lunes)", y="", color="€"))
    fig.update_xaxes(tickformat="%d %b", showgrid=False)
    fig.update_traces(xgap=3, ygap=3, hovertemplate="%{y} · semana del %{x|%d %b}<br>%{z:.0f} €<extra></extra>")
    estilo(fig, alto=320, leyenda="no")
    fig.update_yaxes(showgrid=False, title="")
    fig.update_layout(coloraxis_colorbar=dict(title="€", thickness=10, outlinewidth=0, len=.85))
    st.plotly_chart(fig, width="stretch")
    st.caption("Verde = más barato. Cada celda es el mejor total saliendo ese día (con los filtros actuales).")

def pag_mapa():
    cabecera("🗺️ Mapa")
    if not hay_datos:
        return sin_datos()
    c = combinaciones()
    if c.empty:
        return sin_resultados()
    precios = c.groupby(["ciudad", "codigo"], as_index=False)["total"].min()
    aero = coords_aeropuertos(list(precios["codigo"]))
    precios = precios[precios["codigo"].isin(aero)]
    if precios.empty:
        st.info("No tengo coordenadas de aeropuerto para estos destinos (revisa que "
                "esté instalado el paquete airportsdata).")
        return
    precios["lat"] = precios["codigo"].map(lambda c: aero[c][0])
    precios["lon"] = precios["codigo"].map(lambda c: aero[c][1])
    lat_mad, lon_mad = aero.get("MAD", (40.4983, -3.5676))
    fig = go.Figure()
    fig.add_trace(go.Scattermap(
        lat=precios["lat"], lon=precios["lon"], mode="markers+text",
        marker=dict(size=14, color=precios["total"], colorscale=ESCALA_PRECIO,
                   colorbar=dict(title="Total €", thickness=10)),
        text=precios["ciudad"], textposition="top center",
        hovertext=precios["ciudad"] + "<br>desde " + precios["total"].round(0).astype(int).astype(str) + " €",
        hoverinfo="text", name="Destinos"))
    fig.add_trace(go.Scattermap(
        lat=[lat_mad], lon=[lon_mad], mode="markers+text",
        marker=dict(size=16, color="#202124"), text=["Madrid"], textposition="bottom center",
        hoverinfo="text", name="Madrid"))
    fig.update_layout(map=dict(style="open-street-map", center=dict(lat=lat_mad, lon=lon_mad), zoom=2.2),
                      height=560, margin=dict(l=0, r=0, t=0, b=0), showlegend=False)
    st.plotly_chart(fig, width="stretch")
    st.caption("Cada punto es un destino, coloreado por el total más barato con tus filtros actuales.")

def pag_maletas():
    titulo_pagina("🧳", "Tarifas de equipaje", "Lo que cobra cada aerolínea por maleta y trayecto")
    st.write("Precio **por persona y trayecto** que cobra cada aerolínea. Google Flights no las da, "
             "así que son **valores orientativos**: revísalos en la web de la aerolínea y corrígelos aquí. "
             "Se usan al elegir maletas en el filtro 🧳 Equipaje. «Otras» se aplica a las aerolíneas que no estén en la lista.")
    t = st.data_editor(leer_tarifas(), num_rows="dynamic", hide_index=True, width="stretch", key="ed_tarifas",
                       column_config={
                           "aerolinea": st.column_config.TextColumn("Aerolínea", required=True),
                           "facturada_eur": st.column_config.NumberColumn("Maleta facturada (€)", min_value=0, format="%d €"),
                           "cabina_grande_eur": st.column_config.NumberColumn(
                               "Cabina grande / trolley (€)", min_value=0, format="%d €",
                               help="0 si la tarifa básica ya incluye el trolley")})
    meta = pd.DataFrame([(k, v[0] or None, v[1], v[2]) for k, v in TARIFAS_FUENTES.items()],
                        columns=["aerolinea", "enlace", "fiabilidad", "nota"])
    with st.expander(f"🔗 Enlaces para comprobar cada tarifa (revisado {TARIFAS_REVISADO})"):
        st.dataframe(meta, hide_index=True, width="stretch", column_config={
            "aerolinea": "Aerolínea",
            "enlace": st.column_config.LinkColumn("Web oficial", display_text="Abrir ↗"),
            "fiabilidad": "Fiabilidad", "nota": "Nota"})
        st.caption("Fiabilidad «baja»: la web oficial se carga con JavaScript y no se pudo confirmar el importe; "
                   "los precios reales varían por ruta y fecha. Revísalos con el enlace y corrígelos arriba.")
    c1, c2 = st.columns([1, 1])
    if c1.button("💾 Guardar tarifas", type="primary"):
        try:
            t.dropna(subset=["aerolinea"]).fillna(0).to_csv(TARIFAS, sep=";", index=False, encoding="utf-8-sig")
            mejores_tramos.clear()
            combinar.clear()
            st.toast("Tarifas guardadas", icon="💾")
            st.rerun()
        except OSError as e:
            st.error(f"No se han podido guardar: {e}")
    if c2.button("↩️ Volver a los valores orientativos"):
        confirmar_reset_tarifas()


@st.dialog("¿Restablecer tarifas?")
def confirmar_reset_tarifas():
    st.write("Se perderán los cambios que hayas hecho en la tabla.")
    a, b = st.columns(2)
    if a.button("Sí, restablecer", type="primary", width="stretch"):
        try:
            os.remove(TARIFAS)
        except OSError:
            pass
        mejores_tramos.clear()
        combinar.clear()
        st.session_state.pop("ed_tarifas", None)
        st.rerun()
    if b.button("Cancelar", width="stretch"):
        st.rerun()


def desplegable(titulo, fn, clave):
    """Sección plegada: no calcula ni dibuja nada hasta que se abre, y mientras carga se ve una
    rueda. Evita que tablas y gráficos pesados retrasen la página entera."""
    try:
        ex = st.expander(titulo, key=clave, on_change="rerun")
        abierto = bool(ex.open)
    except TypeError:       # Streamlit antiguo: se muestra siempre
        ex, abierto = st.expander(titulo), True
    with ex:
        if abierto:
            with st.spinner("Cargando…"):
                fn()


def cobertura():
    """Tarta: combinaciones ida+vuelta que cumplen los filtros y cuántas ya están descargadas."""
    todos = destinos_script()
    if not todos:
        return
    por_nombre = {v: k for k, v in todos.items()}
    ciudades = F.get("ciudades") or []
    codigos = [por_nombre.get(c, c) for c in ciudades] or list(todos)
    manana = date.today() + timedelta(days=1)
    tope = manana + timedelta(days=364)
    if not F or F.get("fecha_libre", True):
        ini, fin = manana, tope
    else:
        ini, fin = max(F["rango"][0], manana), min(F["rango"][1], tope)
    noches = F.get("noches", (5,))
    dias_sem = F.get("dias_sem") or DIAS

    hechos = set()
    if not df.empty:
        hechos = set(zip(df["fecha"], df["sentido"], df["codigo"]))
    salidas = [ini + timedelta(days=i) for i in range((fin - ini).days + 1)]
    salidas = [d for d in salidas if DIAS[d.weekday()] in dias_sem]
    filas = []
    for cod in codigos:
        comp = parc = pend = 0
        for d in salidas:
            ok_i = (d, "IDA", cod) in hechos
            for n in noches:
                v = d + timedelta(days=n)
                if v > tope:
                    continue
                ok_v = (v, "VUELTA", cod) in hechos
                if ok_i and ok_v:
                    comp += 1
                elif ok_i or ok_v:
                    parc += 1
                else:
                    pend += 1
        filas.append((todos.get(cod, cod), comp, parc, pend))
    t = pd.DataFrame(filas, columns=["destino", "completas", "parciales", "pendientes"])
    tot = t[["completas", "parciales", "pendientes"]].sum()
    total = int(tot.sum())
    if total == 0:
        st.info("Con estos filtros no hay combinaciones posibles en los próximos 365 días.")
        return

    c1, c2 = st.columns([1, 1])
    with c1:
        tarta = pd.DataFrame({
            "estado": ["Descargadas (ida y vuelta)", "Solo un trayecto", "Pendientes"],
            "n": [int(tot["completas"]), int(tot["parciales"]), int(tot["pendientes"])]})
        fig = px.pie(tarta, names="estado", values="n", hole=0.45, color="estado",
                     color_discrete_map={"Descargadas (ida y vuelta)": VERDE,
                                         "Solo un trayecto": AMBAR, "Pendientes": GRIS})
        fig.update_traces(textinfo="percent+value", sort=False, textposition="inside",
                          insidetextorientation="horizontal", marker_line_width=0)
        estilo(fig, alto=330, leyenda="no")
        fig.update_layout(uniformtext_minsize=11, uniformtext_mode="hide", showlegend=True,
                          legend=dict(orientation="h", y=-0.08, x=0, title_text=""),
                          margin=dict(t=6, b=6, l=6, r=6),
                          annotations=[dict(text=f"<b>{tot['completas'] / total:.0%}</b>",
                                            showarrow=False, font_size=26)])
        st.plotly_chart(fig, width="stretch")
    with c2:
        st.metric("Combinaciones que cumplen los filtros", f"{total:,}".replace(",", "."))
        st.metric("Ya se pueden consultar", f"{int(tot['completas']):,}".replace(",", "."),
                  f"{tot['completas'] / total:.0%}", delta_arrow="off", delta_color="off")
        falta = {(d, "IDA", c) for c in codigos for d in salidas if (d, "IDA", c) not in hechos}
        falta |= {(d + timedelta(days=n), "VUELTA", c) for c in codigos for d in salidas for n in noches
                  if d + timedelta(days=n) <= tope and (d + timedelta(days=n), "VUELTA", c) not in hechos}
        st.metric("Trayectos por descargar", f"{len(falta):,}".replace(",", "."),
                  f"~{dur(int(len(falta) * ritmo(mtime(CSV)) / 60))}" if falta else "¡completo!",
                  delta_arrow="off", delta_color="off")
    st.caption(f"{len(codigos)} destino(s) · {'-'.join(map(str, (noches[0], noches[-1]))) if len(noches) > 1 else noches[0]} días · "
               f"salidas {ini:%d/%m/%y}–{fin:%d/%m/%y}"
               + (f" · {', '.join(d[:3] for d in dias_sem)}" if len(dias_sem) < 7 else "")
               + ". Sigue los filtros de 🎛️ Viaje; los de 🕐 Vuelos y 🧳 Equipaje no cambian lo que hay que descargar.")
    if len(t) > 1:
        t["% descargado"] = t["completas"] / (t[["completas", "parciales", "pendientes"]].sum(axis=1)).clip(lower=1)
        with st.expander("Por destino"):
            st.dataframe(t.sort_values("% descargado", ascending=False), hide_index=True, width="stretch",
                         column_config={"destino": "Destino", "completas": "Descargadas",
                                        "parciales": "Solo un trayecto", "pendientes": "Pendientes",
                                        "% descargado": st.column_config.ProgressColumn(
                                            "% descargado", format="percent", min_value=0, max_value=1)})


@st.cache_data(show_spinner=False)
def estancias_largas(mt_):
    """Filas antiguas de estancias de varias noches, que ya no se usan para el índice."""
    if not mt_:
        return 0
    h = leer_tabla(CSV_HOT, mt_)
    if h.empty or "noches" not in h.columns:
        return 0
    n = pd.to_numeric(h["noches"], errors="coerce")
    return int((n > 1).sum()) if (n == 1).any() else 0


def aviso_noches():
    n = estancias_largas(mt_hot)
    if n:
        st.info(f"Se ignoran {n:,} filas antiguas de estancias de varias noches: ahora se baja "
                "noche a noche y las duraciones se suman después, como con los vuelos. Vuelve a "
                "descargar esas ciudades para recuperarlas.".replace(",", "."))


def sin_hoteles():
    st.info("Todavía no hay precios de alojamiento. Ve a **⬇️ Descargas → 🏨 Hoteles** para "
            "bajarlos de los destinos que te interesen.")


def pag_hoteles_resumen():
    cabecera("🏠 Resumen")
    if not hay_hoteles:
        return sin_hoteles()
    aviso_noches()
    ind = indice_estancias(mt_hot, F["fh"], F["n_baratos"], F["noches_estancia"])
    if F["ciudades"]:
        ind = ind[ind["ciudad"].isin(F["ciudades"])]
    if not F["fecha_libre"]:
        ind = ind[(ind["fecha_entrada"] >= pd.Timestamp(F["rango"][0]))
                  & (ind["fecha_entrada"] <= pd.Timestamp(F["rango"][1]))]
    if ind.empty:
        return sin_resultados()
    mejor = ind.loc[ind["precio_noche"].idxmin()]
    k = st.columns(4)
    k[0].metric("Noche más barata", eur(mejor.precio_noche),
                f"{mejor.ciudad} · {mejor.fecha_entrada:%d/%m}", delta_color="off", delta_arrow="off")
    k[1].metric("Mediana por noche", eur(ind["precio_noche"].median()))
    k[2].metric("Ciudades", ind["ciudad"].nunique())
    k[3].metric("Fechas con datos", f"{ind['fecha_entrada'].nunique():,}".replace(",", "."))

    st.subheader("Precio típico por ciudad")
    porc = (ind.groupby("ciudad", as_index=False)
            .agg(mediana=("precio_noche", "median"), minimo=("precio_noche", "min"),
                 fechas=("precio_noche", "size"))
            .sort_values("mediana"))
    izq, der = st.columns([3, 2])
    with izq:
        st.dataframe(porc, hide_index=True, width="stretch", column_config={
            "ciudad": "Ciudad",
            "mediana": st.column_config.NumberColumn("€/noche típico", format="%d €"),
            "minimo": st.column_config.NumberColumn("Mínimo", format="%d €"),
            "fechas": "Fechas"})
    with der:
        fig = px.bar(porc, x="mediana", y="ciudad", orientation="h", text="mediana",
                     color="mediana", color_continuous_scale=ESCALA_PRECIO, labels={"ciudad": ""})
        fig.update_traces(texttemplate="<b>%{text:.0f} €</b>", textposition="outside",
                          cliponaxis=False, textfont_color="#E8EAED" if es_oscuro() else "#202124")
        estilo(fig, alto=max(230, 40 * len(porc)), leyenda="no")
        fig.update_layout(coloraxis_showscale=False, yaxis=dict(autorange="reversed"),
                          xaxis=dict(showticklabels=False, title="",
                                     range=[0, porc["mediana"].max() * 1.2]), bargap=.35)
        st.plotly_chart(fig, width="stretch")

    st.subheader("Precio típico por ciudad y mes")
    piv = ind.pivot_table(index="ciudad", columns="mes", values="precio_noche", aggfunc="min")
    fig = px.imshow(piv, text_auto=".0f", color_continuous_scale=ESCALA_PRECIO, aspect="auto",
                    labels=dict(x="Mes", y="", color="€"))
    fig.update_xaxes(type="category", side="top", tickangle=0, showgrid=False)
    fig.update_traces(xgap=4, ygap=4, hovertemplate="%{y} · %{x}<br>%{z:.0f} €<extra></extra>",
                      textfont_size=13)
    estilo(fig, alto=max(240, 46 * len(piv)), leyenda="no")
    fig.update_layout(margin=dict(t=34, b=6), coloraxis_colorbar=dict(title="€", thickness=10,
                      outlinewidth=0, len=.85))
    fig.update_yaxes(showgrid=False, title="")
    st.plotly_chart(fig, width="stretch")


def pag_hoteles_buscador():
    cabecera("🔎 Buscador de alojamiento")
    if not hay_hoteles:
        return sin_hoteles()
    h = hoteles_filtrados(mt_hot, F["fh"])
    if F["ciudades"]:
        h = h[h["ciudad"].isin(F["ciudades"])]
    if not F["fecha_libre"]:
        h = h[(h["fecha_entrada"] >= pd.Timestamp(F["rango"][0]))
              & (h["fecha_entrada"] <= pd.Timestamp(F["rango"][1]))]
    if h.empty:
        return sin_resultados()
    orden = st.segmented_control("Ordenar por", ["Precio/noche", "Nota", "Fecha de entrada"],
                                 default="Precio/noche", key="orden_hot")
    col = {"Precio/noche": "precio_noche", "Nota": "valoracion",
           "Fecha de entrada": "fecha_entrada"}.get(orden or "Precio/noche")
    h = h.sort_values(col, ascending=col != "valoracion")
    cols_tabla = [c for c in ["ciudad", "fecha_entrada", "nombre", "precio_noche", "valoracion",
                              "resenas", "estrellas", "tipo", "km_centro", "min_andando",
                              "min_transporte", "estacion", "km_estacion", "min_andando_estacion", "min_coche",
                              "km_aeropuerto", "min_coche_aeropuerto",
                              "min_andando_aeropuerto", "desayuno",
                              "wifi", "parking", "buena_ubicacion", "enlace"] if c in h.columns]
    st.dataframe(h[cols_tabla].head(MAX_FILAS_TABLA),
                 hide_index=True, width="stretch", height=620, row_height=34, column_config={
                     "ciudad": "Ciudad",
                     "fecha_entrada": st.column_config.DateColumn("Entrada", format="DD/MM/YY"),
                     "nombre": "Alojamiento",
                     "precio_noche": st.column_config.NumberColumn("€/noche", format="%d €"),
                     "valoracion": st.column_config.NumberColumn("Nota", format="%.1f"),
                     "resenas": st.column_config.NumberColumn("Reseñas", format="%d"),
                     "estrellas": st.column_config.NumberColumn("★", format="%d"),
                     "km_centro": st.column_config.NumberColumn("km centro", format="%.1f"),
                     "min_andando": st.column_config.NumberColumn("🚶 min", format="%d"),
                     "min_transporte": st.column_config.NumberColumn("🚌 min", format="%d"),
                     "estacion": "🚆 Estación",
                     "km_estacion": st.column_config.NumberColumn("km estación", format="%.1f"),
                     "min_andando_estacion": st.column_config.NumberColumn("🚆🚶 min", format="%d"),
                     "min_coche": st.column_config.NumberColumn("🚗 min", format="%d"),
                     "km_aeropuerto": st.column_config.NumberColumn("km aeropuerto", format="%.1f"),
                     "min_coche_aeropuerto": st.column_config.NumberColumn("✈️🚗 min", format="%d"),
                     "min_andando_aeropuerto": st.column_config.NumberColumn("✈️🚶 min", format="%d"),
                     "tipo": "Tipo", "desayuno": "🍳", "wifi": "📶", "parking": "🅿️",
                     "buena_ubicacion": "Buena zona",
                     "enlace": st.column_config.LinkColumn("Ver", display_text="🔗")})
    extra = f" (se muestran las {MAX_FILAS_TABLA} primeras)" if len(h) > MAX_FILAS_TABLA else ""
    st.caption(f"{len(h):,} alojamientos{extra}.".replace(",", "."))
    exportable = h[cols_tabla].head(5000)
    st.download_button("💾 Exportar a CSV (Excel)",
                       exportable.to_csv(sep=";", decimal=",", index=False).encode("utf-8-sig"),
                       "hoteles_filtrados.csv", "text/csv",
                       on_click=lambda: st.toast("Tabla exportada", icon="💾"))

    st.divider()
    opciones_fav = {f"{r.ciudad} · {r.nombre} · {r.fecha_entrada:%d/%m/%y} · {r.precio_noche:.0f} €/noche":
                    (r.codigo, r.fecha_entrada.date().isoformat(), r.ciudad, r.nombre,
                     round(float(r.precio_noche)))
                    for r in h.head(100).itertuples()}
    elegidos = st.multiselect("⭐ Marcar como favoritos (de los 100 primeros de la lista): se podrán "
                              "volver a descargar solo esos, sin bajar toda la ciudad",
                              list(opciones_fav), key="elegir_fav_hoteles")
    if st.button("⭐ Guardar como favoritos", disabled=not elegidos, key="guardar_fav_hoteles"):
        fav = leer_favoritos()
        existentes = {(f["codigo"], f["fecha_entrada"], f["nombre"]) for f in fav["hoteles"]}
        n = 0
        for e in elegidos:
            cod, fecha_s, ciudad, nombre, precio = opciones_fav[e]
            if (cod, fecha_s, nombre) not in existentes:
                fav["hoteles"].append({"codigo": cod, "ciudad": ciudad, "nombre": nombre,
                                       "fecha_entrada": fecha_s, "precio_noche": precio,
                                       "guardado": datetime.now().isoformat()})
                n += 1
        guardar_favoritos(fav)
        st.session_state["aviso"] = ("⭐", f"{n} favorito(s) nuevo(s) guardado(s)" if n
                                     else "Ya estaban guardados")
        st.rerun()


def pag_hoteles_evolucion():
    cabecera("📈 Evolución del precio")
    if not hay_hoteles:
        return sin_hoteles()
    ind = indice_estancias(mt_hot, F["fh"], F["n_baratos"], F["noches_estancia"])
    if F["ciudades"]:
        ind = ind[ind["ciudad"].isin(F["ciudades"])]
    if not F["fecha_libre"]:
        ind = ind[(ind["fecha_entrada"] >= pd.Timestamp(F["rango"][0]))
                  & (ind["fecha_entrada"] <= pd.Timestamp(F["rango"][1]))]
    if ind.empty:
        return sin_resultados()
    color = "ciudad" if ind["ciudad"].nunique() > 1 else None
    g = ind.groupby(["fecha_entrada"] + ([color] if color else []), as_index=False)["precio_noche"].min()
    fig = px.line(g.sort_values("fecha_entrada"), x="fecha_entrada", y="precio_noche", color=color,
                  markers=len(g) < 120, color_discrete_sequence=COLORES,
                  labels={"fecha_entrada": "", "precio_noche": "€/noche más barato", "ciudad": ""})
    fig.update_traces(line_width=2.2, marker_size=5, hovertemplate="%{y:.0f} €<extra>%{fullData.name}</extra>")
    estilo(fig, alto=460)
    fig.update_layout(hovermode="x unified")
    st.plotly_chart(fig, width="stretch")
    st.caption(f"Para cada fecha de entrada, el precio por noche más barato (mediana de los "
               f"{F['n_baratos']} más baratos) entre las ciudades elegidas.")
    st.subheader("Por día de la semana de entrada")
    s = ind.groupby(["dia_sem"] + (["ciudad"] if color else []), as_index=False)["precio_noche"].median()
    s["orden"] = s["dia_sem"].map({d: i for i, d in enumerate(DIAS)})
    fig = px.bar(s.sort_values("orden"), x="dia_sem", y="precio_noche", color_discrete_sequence=COLORES,
                 color="ciudad" if color else None, barmode="group",
                 labels={"dia_sem": "", "precio_noche": "€/noche mediano", "ciudad": ""})
    fig.update_traces(hovertemplate="%{x}<br>%{y:.0f} €<extra>%{fullData.name}</extra>")
    estilo(fig, alto=330, leyenda="arriba" if color else "no")
    fig.update_layout(bargap=.3)
    st.plotly_chart(fig, width="stretch")


def pag_hoteles_calendario():
    cabecera("🗓️ Calendario")
    if not hay_hoteles:
        return sin_hoteles()
    ind = indice_estancias(mt_hot, F["fh"], F["n_baratos"], F["noches_estancia"])
    if F["ciudades"]:
        ind = ind[ind["ciudad"].isin(F["ciudades"])]
    if ind.empty:
        return sin_resultados()
    cal = ind.groupby("fecha_entrada", as_index=False).agg(precio_noche=("precio_noche", "min"))
    cal["fecha_entrada"] = pd.to_datetime(cal["fecha_entrada"])
    cal["semana"] = cal["fecha_entrada"] - pd.to_timedelta(cal["fecha_entrada"].dt.dayofweek, unit="D")
    cal["dia"] = cal["fecha_entrada"].dt.dayofweek.map(dict(enumerate(CORTO)))
    piv = cal.pivot_table(index="dia", columns="semana", values="precio_noche", aggfunc="min").reindex(CORTO)
    fig = px.imshow(piv, color_continuous_scale=ESCALA_PRECIO, aspect="auto",
                    labels=dict(x="Semana (lunes)", y="", color="€"))
    fig.update_xaxes(tickformat="%d %b", showgrid=False)
    fig.update_traces(xgap=3, ygap=3, hovertemplate="%{y} · semana del %{x|%d %b}<br>%{z:.0f} €<extra></extra>")
    estilo(fig, alto=320, leyenda="no")
    fig.update_yaxes(showgrid=False, title="")
    fig.update_layout(coloraxis_colorbar=dict(title="€", thickness=10, outlinewidth=0, len=.85))
    st.plotly_chart(fig, width="stretch")
    st.caption("Verde = más barato. Cada celda es la mejor noche entrando ese día (con los filtros actuales).")

@st.cache_data(show_spinner="Preparando el mapa de alojamientos…")
def hoteles_mapa_datos(mt_, fh, ciudades, fecha_libre, rango):
    """Un punto por alojamiento (su noche más barata), como mucho MAX_PUNTOS_MAPA. Se calcula una
    vez por combinación de filtros y se guarda: la tabla completa (cientos de miles de filas) no
    se vuelve a tocar al volver a la pestaña, y al navegador solo llegan unos miles de puntos."""
    h = hoteles_filtrados(mt_, fh)
    if h.empty:
        return h, 0
    if ciudades:
        h = h[h["ciudad"].isin(ciudades)]
    if not fecha_libre:
        h = h[(h["fecha_entrada"] >= pd.Timestamp(rango[0])) & (h["fecha_entrada"] <= pd.Timestamp(rango[1]))]
    cols = [c for c in ("codigo", "ciudad", "nombre", "lat", "lon", "precio_noche", "km_aeropuerto",
                        "min_andando_aeropuerto") if c in h.columns]
    h = h[cols].dropna(subset=["lat", "lon", "precio_noche"])
    if h.empty:
        return h, 0
    h = h.loc[h.groupby(["codigo", "nombre"], sort=False)["precio_noche"].idxmin()]
    total = len(h)
    return h.nsmallest(MAX_PUNTOS_MAPA, "precio_noche").reset_index(drop=True), total


def pag_hoteles_mapa():
    cabecera("🗺️ Mapa")
    if not hay_hoteles:
        return sin_hoteles()
    h, total = hoteles_mapa_datos(mt_hot, F["fh"], tuple(F["ciudades"]), F["fecha_libre"], tuple(F["rango"]))
    if h.empty:
        return sin_resultados()
    if total > len(h):
        st.caption(f"Se dibujan los {len(h):,} alojamientos más baratos de {total:,} "
                   "(afina los filtros para ver otros).".replace(",", "."))
    codigos = h["codigo"].unique().tolist()
    aero = coords_aeropuertos(codigos)
    _extra_aero = np.where(
        h["km_aeropuerto"].notna() if "km_aeropuerto" in h.columns else False,
        "<br>✈️ " + h["km_aeropuerto"].round(1).astype(str) + " km · "
        + h["min_andando_aeropuerto"].fillna(0).round(0).astype(int).astype(str) + " min andando",
        "") if "km_aeropuerto" in h.columns else ""
    fig = go.Figure()
    fig.add_trace(go.Scattermap(
        lat=h["lat"], lon=h["lon"], mode="markers",
        marker=dict(size=9, color=h["precio_noche"], colorscale=ESCALA_PRECIO,
                   colorbar=dict(title="€/noche", thickness=10)),
        hovertext=h["nombre"] + "<br>" + h["precio_noche"].round(0).astype(int).astype(str) + " €/noche"
                  + _extra_aero,
        hoverinfo="text", name="Hoteles"))
    for cod in codigos:
        if cod in aero:
            lat, lon = aero[cod]
            fig.add_trace(go.Scattermap(
                lat=[lat], lon=[lon], mode="markers+text",
                marker=dict(size=16, color="#E5484D"), text=[f"✈️ {cod}"], textposition="top center",
                hoverinfo="text", name=f"Aeropuerto {cod}"))
        for n_, y, x in estaciones_por_codigo().get(cod, []):
            fig.add_trace(go.Scattermap(
                lat=[y], lon=[x], mode="markers+text", marker=dict(size=16, color="#2B6CD4"),
                text=[f"🚆 {n_}"], textposition="top center", hoverinfo="text", name=n_))
    fig.update_layout(map=dict(style="open-street-map",
                               center=dict(lat=h["lat"].mean(), lon=h["lon"].mean()),
                               zoom=11 if len(codigos) == 1 else 4),
                      height=560, margin=dict(l=0, r=0, t=0, b=0), showlegend=False)
    st.plotly_chart(fig, width="stretch")
    st.caption("Colores: alojamiento (según precio) · rojo = aeropuerto · azul = estación de tren de tu lista.")


UMBRAL_PROBABLE_VUELOS = 25    # €
UMBRAL_PROBABLE_HOTELES = 10   # €/noche


@st.cache_data(show_spinner=False, ttl="6h")
def _leer_historico_vuelos(mt_hist):
    try:
        return leer_tabla(HISTORICO, mt_hist)
    except Exception:
        return pd.DataFrame()


@st.cache_data(show_spinner=False, ttl="6h")
def _precios_favoritos_vuelos(mt_hist, favs):
    """Precio ahora / mínimo / al guardar / cambio de cada favorito de vuelos (favs: tupla de
    (codigo, ida, vuelta, guardado))."""
    import modelo_precios as mp
    hist = _leer_historico_vuelos(mt_hist)
    return pd.DataFrame([mp.precio_favorito(hist, *f) for f in favs],
                        columns=["ahora", "minimo", "al_guardar", "cambio_pct"])


def precios_favoritos():
    """(lista de favoritos de vuelos, DataFrame con sus precios) leídos del histórico."""
    lista = leer_favoritos()["vuelos"]
    if not lista:
        return lista, pd.DataFrame()
    favs = tuple((f["codigo"], f["ida"], f["vuelta"], f.get("guardado", "")) for f in lista)
    return lista, _precios_favoritos_vuelos(mtime(HISTORICO), favs)


@st.cache_data(show_spinner=False, ttl="6h")
def _precios_viajes(mt_hist, mt_hot, viajes):
    """Vuelo + alojamiento elegido: ahora / al asignarlo / cambio (viajes: tupla de
    (codigo, ida, vuelta, viaje_guardado, hotel, personas))."""
    import modelo_precios as mp
    hv, hh = _leer_historico_vuelos(mt_hist), _leer_historico_hoteles(mt_hot)
    filas = []
    for cod, ida, vta, guardado, hotel, personas in viajes:
        if not hotel:
            filas.append((np.nan, np.nan, np.nan))
            continue
        v = mp.precio_favorito(hv, cod, ida, vta, guardado)
        h = mp.precio_estancia(hh, cod, hotel, ida, vta, guardado)
        hab = int(np.ceil(personas / 2))
        a, b = (v[k] * personas + h[k] * hab for k in ("ahora", "al_guardar"))
        filas.append((a, b, a / b - 1))
    return pd.DataFrame(filas, columns=["ahora", "al_guardar", "cambio_pct"])


def precios_viajes(lista):
    """DataFrame (mismo orden que lista) con el total del viaje: vuelo×personas + alojamiento elegido."""
    viajes = tuple((f["codigo"], f["ida"], f["vuelta"], f.get("viaje_guardado") or f.get("guardado", ""),
                    f.get("hotel"), f.get("personas") or 1) for f in lista)
    return _precios_viajes(mtime(HISTORICO), mtime(CSV_HOT_HIST), viajes)


def favoritos_bajados():
    """(favoritos que han bajado un 5 % o más, favoritos en su precio objetivo, viajes completos
    que han bajado un 5 % o están en su objetivo)."""
    lista, p = precios_favoritos()
    if p.empty:
        return 0, 0, 0
    obj = lambda k: pd.to_numeric(pd.Series([f.get(k) for f in lista]), errors="coerce")
    v = precios_viajes(lista)
    return (int((p["cambio_pct"] <= -0.05).sum()), int((p["ahora"] <= obj("objetivo")).sum()),
            int(((v["cambio_pct"] <= -0.05) | (v["ahora"] <= obj("objetivo_viaje"))).sum()))


def texto_aviso_favoritos(bajados, objetivo, viajes=0):
    partes = [t for n, t in ((bajados, f"📉 {bajados} favorito(s) han bajado"),
                             (objetivo, f"🎯 {objetivo} en tu precio objetivo"),
                             (viajes, f"🎒 {viajes} viaje(s) completo(s) han bajado")) if n]
    return " · ".join(partes)


def aviso_favoritos_bajados():
    if t := texto_aviso_favoritos(*favoritos_bajados()):
        st.success(t)


def barra_eta(titulo):
    """(avanza, cerrar) para el parámetro progreso= de modelo_precios: barra con el % y el
    tiempo restante estimado (lo ya transcurrido y la fracción hecha)."""
    barra, t0 = st.progress(0, text=f"{titulo}…"), time.time()

    def avanza(frac, texto):
        seg = time.time() - t0
        resto = f" · quedan ~{int(seg * (1 - frac) / frac)} s" if frac >= 0.05 and seg >= 2 else ""
        barra.progress(min(max(frac, 0.0), 1.0), text=f"{titulo}: {texto} {frac:.0%}{resto}")
    return avanza, barra.empty


@st.cache_data(show_spinner=False, ttl="6h")
def _modelo_anticipacion_vuelos(mt_hist, controles=False):
    import modelo_precios as mp
    hist = _leer_historico_vuelos(mt_hist)
    if hist.empty:
        return pd.DataFrame(), {"error": "Todavía no hay histórico: se va llenando con cada descarga."}
    avanza, cerrar = barra_eta("Modelo de antelación")
    try:
        return mp.modelo_anticipacion(hist, controles=controles, progreso=avanza)
    finally:
        cerrar()


@st.cache_data(show_spinner=False, ttl="6h")
def _volatilidad_vuelos(mt_hist):
    import modelo_precios as mp
    hist = _leer_historico_vuelos(mt_hist)
    if hist.empty:
        return pd.DataFrame(), {"error": "Todavía no hay histórico: se va llenando con cada descarga."}
    return mp.volatilidad(hist)


@st.cache_data(show_spinner=False, ttl="6h")
def _mejor_momento_vuelos(mt_hist):
    import modelo_precios as mp
    return mp.mejor_momento(_leer_historico_vuelos(mt_hist))


@st.cache_data(show_spinner=False, ttl="6h")
def _probabilidad_vuelos(mt_hist, controles=False):
    try:
        import modelo_precios as mp
    except ImportError:
        return pd.DataFrame(), pd.DataFrame(), {"error": "Falta modelo_precios.py"}
    hist = _leer_historico_vuelos(mt_hist)
    if hist.empty:
        return pd.DataFrame(), pd.DataFrame(), {"error": "Todavía no hay histórico."}
    avanza, cerrar = barra_eta("Probabilidad de subida")
    try:
        return mp.probabilidad_subida(hist, claves=["codigo", "sentido", "fecha_vuelo"],
                                      col_fecha_objetivo="fecha_vuelo", col_precio="precio_eur",
                                      controles=controles, progreso=avanza)
    finally:
        cerrar()


def vuelos_probable_marcados(umbral=UMBRAL_PROBABLE_VUELOS, controles=False):
    """Vuelos activos con subida esperada >= umbral €, combinando lo que suele moverse en su
    tramo de antelación con cuánto hace que no se refresca cada uno. Devuelve (activos,
    marcados, tsub); los tres vacíos si no hay histórico suficiente. Se reutiliza tanto en
    📉 Antelación y volatilidad (para el análisis) como en ⬇️ Descargas (para el botón)."""
    if not hay_datos:
        return pd.DataFrame(), pd.DataFrame(), pd.DataFrame()
    import modelo_precios as mp
    tsub, curva, isub = _probabilidad_vuelos(mtime(HISTORICO), controles)
    if tsub.empty or "subida_media" not in tsub.columns:
        return pd.DataFrame(), pd.DataFrame(), tsub
    hoy = date.today()
    activos = df.dropna(subset=["precio_eur", "fecha", "codigo", "sentido", "ultima_descarga"]).copy()
    activos["dias"] = activos["fecha"].map(lambda f: max((f - hoy).days, 0))
    activos["tramo"] = activos["dias"].map(mp.tramo_de)
    activos["ultima_descarga_dt"] = pd.to_datetime(activos["ultima_descarga"], errors="coerce")
    activos = activos.dropna(subset=["ultima_descarga_dt"])
    activos["dias_desde_descarga"] = (
        (pd.Timestamp.now() - activos["ultima_descarga_dt"]).dt.total_seconds() / 86400
    ).clip(lower=0)
    tasa_tramo = {tr: mp.tasa_diaria(pct, gap) for tr, pct, gap in
                 zip(tsub["tramo"], tsub["pct_subio"], tsub["dias_gap_medio"])}
    subida_tramo = tsub.set_index("tramo")["subida_media"].to_dict()
    activos["tasa_diaria"] = activos["tramo"].map(tasa_tramo)
    activos["subida_media_pct"] = activos["tramo"].map(subida_tramo)
    activos = activos.dropna(subset=["tasa_diaria", "subida_media_pct"]).copy()
    if activos.empty:
        return activos, pd.DataFrame(), tsub
    activos["prob_subida"] = [mp.prob_en_espera(t, d) for t, d in
                              zip(activos["tasa_diaria"], activos["dias_desde_descarga"])]
    activos["subida_esperada_eur"] = (activos["prob_subida"] * activos["subida_media_pct"]
                                      * activos["precio_eur"])
    marcados = activos[activos["subida_esperada_eur"] >= umbral].sort_values(
        "subida_esperada_eur", ascending=False)
    return activos, marcados, tsub


@st.cache_data(show_spinner=False, ttl="6h")
def _leer_historico_hoteles(mt_hist):
    try:
        return leer_tabla(CSV_HOT_HIST, mt_hist)
    except Exception:
        return pd.DataFrame()


CLAVES_HOT = ["codigo", "ciudad", "fecha_entrada", "nombre"]


@st.cache_data(show_spinner=False, ttl="6h")
def _modelo_anticipacion_hoteles(mt_hist, controles=False):
    import modelo_precios as mp
    hist = _leer_historico_hoteles(mt_hist)
    if hist.empty:
        return pd.DataFrame(), {"error": "Todavía no hay histórico: se va llenando con cada descarga."}
    avanza, cerrar = barra_eta("Modelo de antelación")
    try:
        return mp.modelo_anticipacion(hist, claves=CLAVES_HOT, col_fecha_objetivo="fecha_entrada",
                                      col_precio="precio_noche", controles=controles, progreso=avanza)
    finally:
        cerrar()


@st.cache_data(show_spinner=False, ttl="6h")
def _volatilidad_hoteles(mt_hist):
    import modelo_precios as mp
    hist = _leer_historico_hoteles(mt_hist)
    if hist.empty:
        return pd.DataFrame(), {"error": "Todavía no hay histórico: se va llenando con cada descarga."}
    return mp.volatilidad(hist, claves=CLAVES_HOT, col_fecha_objetivo="fecha_entrada",
                          col_precio="precio_noche")


@st.cache_data(show_spinner=False, ttl="6h")
def _probabilidad_hoteles(mt_hist, controles=False):
    try:
        import modelo_precios as mp
    except ImportError:
        return pd.DataFrame(), pd.DataFrame(), {"error": "Falta modelo_precios.py"}
    hist = _leer_historico_hoteles(mt_hist)
    if hist.empty:
        return pd.DataFrame(), pd.DataFrame(), {"error": "Todavía no hay histórico."}
    avanza, cerrar = barra_eta("Probabilidad de subida")
    try:
        return mp.probabilidad_subida(hist, claves=CLAVES_HOT, col_fecha_objetivo="fecha_entrada",
                                      col_precio="precio_noche", controles=controles, progreso=avanza)
    finally:
        cerrar()


def hoteles_probable_marcados(umbral=UMBRAL_PROBABLE_HOTELES, controles=False):
    """Igual que vuelos_probable_marcados() pero para alojamientos (precio por noche)."""
    if not hay_hoteles:
        return pd.DataFrame(), pd.DataFrame(), pd.DataFrame()
    import modelo_precios as mp
    tsub, curva, isub = _probabilidad_hoteles(mtime(CSV_HOT_HIST), controles)
    if tsub.empty or "subida_media" not in tsub.columns:
        return pd.DataFrame(), pd.DataFrame(), tsub
    hoy_ts = pd.Timestamp.today().normalize()
    activos = cargar_hoteles(mt_hot).dropna(
        subset=["precio_noche", "fecha_entrada", "codigo", "consulta"]).copy()
    activos["dias"] = (activos["fecha_entrada"] - hoy_ts).dt.days.clip(lower=0)
    activos["tramo"] = activos["dias"].map(mp.tramo_de)
    activos["consulta_dt"] = pd.to_datetime(activos["consulta"], errors="coerce")
    activos = activos.dropna(subset=["consulta_dt"])
    activos["dias_desde_descarga"] = (
        (pd.Timestamp.now() - activos["consulta_dt"]).dt.total_seconds() / 86400
    ).clip(lower=0)
    tasa_tramo = {tr: mp.tasa_diaria(pct, gap) for tr, pct, gap in
                 zip(tsub["tramo"], tsub["pct_subio"], tsub["dias_gap_medio"])}
    subida_tramo = tsub.set_index("tramo")["subida_media"].to_dict()
    activos["tasa_diaria"] = activos["tramo"].map(tasa_tramo)
    activos["subida_media_pct"] = activos["tramo"].map(subida_tramo)
    activos = activos.dropna(subset=["tasa_diaria", "subida_media_pct"]).copy()
    if activos.empty:
        return activos, pd.DataFrame(), tsub
    activos["prob_subida"] = [mp.prob_en_espera(t, d) for t, d in
                              zip(activos["tasa_diaria"], activos["dias_desde_descarga"])]
    activos["subida_esperada_noche"] = (activos["prob_subida"] * activos["subida_media_pct"]
                                        * activos["precio_noche"])
    marcados = activos[activos["subida_esperada_noche"] >= umbral].sort_values(
        "subida_esperada_noche", ascending=False)
    return activos, marcados, tsub


def vuelos_candidatos_muestreo():
    """Vuelos activos que cumplen los filtros actuales (⭐ Buscador), con su probabilidad
    estimada de haber subido desde la última descarga (prob_subida) — independiente de si
    superan o no el umbral de subida esperada. Devuelve (candidatos, tsub)."""
    activos, _, tsub = vuelos_probable_marcados()
    if activos.empty or "prob_subida" not in activos.columns:
        return activos.iloc[0:0] if not activos.empty else pd.DataFrame(), tsub
    c_f = combinaciones()
    if c_f.empty:
        return activos.iloc[0:0], tsub
    claves = set()
    for r in c_f.itertuples():
        claves.add((r.codigo, "IDA", r.ida.date().isoformat()))
        claves.add((r.codigo, "VUELTA", r.vuelta.date().isoformat()))
    mask = [(r.codigo, r.sentido, r.fecha.isoformat()) in claves for r in activos.itertuples()]
    return activos[mask], tsub


def hoteles_candidatos_muestreo():
    """Igual que vuelos_candidatos_muestreo() pero para alojamientos (filtros de ⭐ Buscador de
    hoteles). Devuelve (candidatos, tsub)."""
    activos, _, tsub = hoteles_probable_marcados()
    if activos.empty or "prob_subida" not in activos.columns:
        return activos.iloc[0:0] if not activos.empty else pd.DataFrame(), tsub
    h_f = hoteles_filtrados(mt_hot, F["fh"])
    if F["ciudades"]:
        h_f = h_f[h_f["ciudad"].isin(F["ciudades"])]
    if not F["fecha_libre"]:
        h_f = h_f[(h_f["fecha_entrada"] >= pd.Timestamp(F["rango"][0]))
                  & (h_f["fecha_entrada"] <= pd.Timestamp(F["rango"][1]))]
    if h_f.empty:
        return activos.iloc[0:0], tsub
    claves = set(zip(h_f["codigo"], h_f["fecha_entrada"].dt.date))
    mask = [(r.codigo, r.fecha_entrada.date()) in claves for r in activos.itertuples()]
    return activos[mask], tsub


LINEAS_ANTELACION_CTRL = [
    "- **δ_d(t)**: efecto fijo del día de consulta *d* — lo que se mueve el mercado entero ese día "
    "(combustible, ofertas...) y que, sin él, se atribuiría a la antelación.",
    "- **θ_h**: franja horaria de la consulta (<9 h, 9-11 h, 12-14 h, 15 h o más).",
    "- Con δ, los días hasta la salida (= fecha de salida − fecha de consulta) serían colineales con "
    "el vuelo y el día; para identificarlos se supone que el tramo más lejano es plano, por eso "
    "120-179 y 180+ se funden en la referencia **120+ días**.",
]
LATEX_ANTELACION_CTRL = (r"\log(\text{precio}_{it}) = \alpha_i + \sum_{k} \beta_k \cdot \mathbb{1}[\text{tramo}_{it}=k] "
                         r"+ \delta_{d(t)} + \sum_{h} \theta_h \cdot \mathbb{1}[\text{franja}_{t}=h] + \varepsilon_{it}")
LATEX_SUBIDA_CTRL = (r"+ \delta \cdot \log(\Delta t_{it}) + \rho \cdot \tilde p_{i,t-1} "
                     r"+ \mathbf{x}_{it}'\boldsymbol{\lambda} ")
LINEAS_SUBIDA_CTRL = [
    "- **Δt**: hueco entre las dos consultas comparadas (en log) · **p̃**: precio previo relativo a la "
    "media (log) de ese mismo vuelo/alojamiento — reversión a la media: si estaba por encima de su "
    "media, es más probable que baje.",
    "- **x**: día de la semana y franja horaria de la consulta, día de la semana y mes de la fecha "
    "de salida/entrada y, en vuelos, el sentido.",
    "- Las barras de arriba muestran la probabilidad **ajustada** del modelo por tramo (con el resto "
    "de variables como se observaron y el hueco medio global), no el porcentaje bruto.",
]
NOTA_VOLATILIDAD_CTRL = ("Este punto no cambia con el modelo elegido: es un promedio por tramo, sin "
                         "regresión, y no hay una forma limpia de «controlar» sin rediseñarlo.")


def comparar_antelacion(tabla, tabla_actual):
    """Las dos tablas de antelación apiladas (con su margen de error) para dibujarlas juntas."""
    c = pd.concat([tabla_actual.assign(modelo="Actual"), tabla.assign(modelo="Con más variables")],
                  ignore_index=True)
    c["ic"] = 1.96 * c["se"] * (1 + c["efecto"])
    return c


def selector_modelo(clave):
    """Dos botones («Modelo actual» / «Modelo con más variables»); el activo, resaltado.
    Devuelve True si está elegido el modelo con más variables."""
    ctrl = st.session_state.get(clave, False)
    c1, c2, _ = st.columns([1, 1.4, 1])
    for col, texto, valor in ((c1, "Modelo actual", False), (c2, "Modelo con más variables", True)):
        if col.button(texto, key=f"{clave}_{int(valor)}", width="stretch",
                      type="primary" if ctrl == valor else "secondary") and ctrl != valor:
            st.session_state[clave] = valor
            st.rerun()
    return ctrl


def pag_hoteles_antelacion():
    titulo_pagina("📉", "Antelación y volatilidad",
                  "Con qué antelación sube el precio y cada cuánto conviene refrescar cada tramo")
    if not hay_hoteles:
        return sin_hoteles()
    try:
        import modelo_precios as mp
    except ImportError:
        return st.error("Falta el fichero modelo_precios.py en la carpeta de la app.")

    mt_hist = mtime(CSV_HOT_HIST)
    clave = "modelo_ctrl_hoteles"
    ctrl = selector_modelo(clave)
    st.caption("**Modelo con más variables**: además del efecto fijo por alojamiento, descuenta lo que "
               "se mueve el mercado cada día de consulta y la franja horaria (y amplía el modelo del "
               "punto 3). Con tantos alojamientos puede tardar varios minutos: la barra de progreso "
               "indica el tiempo restante." if ctrl else
               "**Modelo actual**: compara cada alojamiento consigo mismo según el tramo de antelación.")

    st.subheader("1. ¿Cuánto encarece acercarse a la fecha?")
    tabla, info = _modelo_anticipacion_hoteles(mt_hist, ctrl)
    if tabla.empty:
        st.info(info.get("error", "No hay datos suficientes."))
    else:
        k = st.columns(4)
        k[0].metric("Umbral estimado", f"{info['umbral']} días" if info["umbral"] else "sin efecto claro")
        k[1].metric("Precios usados", f"{info['n']:,}".replace(",", "."))
        k[2].metric("Alojamientos comparados", f"{info['grupos']:,}".replace(",", "."))
        k[3].metric("R² del modelo", f"{info['r2']:.2f}")
        t = tabla.copy()
        t["ic"] = 1.96 * t["se"] * (1 + t["efecto"])          # margen aproximado en %
        comp = None
        if ctrl and st.checkbox("Superponer el modelo actual", key=f"{clave}_comp"):
            comp = comparar_antelacion(tabla, _modelo_anticipacion_hoteles(mt_hist, False)[0])
        datos = t if comp is None else comp
        fig = px.bar(datos, x="tramo", y="efecto", error_y="ic", barmode="group",
                     color=(t["p"].lt(mp.ALFA) & t["efecto"].abs().ge(mp.EFECTO_MIN)) if comp is None
                     else datos["modelo"],
                     color_discrete_map={True: ROJO, False: GRIS, "Actual": GRIS, "Con más variables": ROJO},
                     labels={"tramo": "Días hasta la entrada", "efecto": "Diferencia de precio", "color": ""})
        fig.update_traces(hovertemplate="%{x}<br>%{y:+.1%}<extra></extra>")
        estilo(fig, alto=360, leyenda="no" if comp is None else "arriba")
        fig.update_layout(yaxis_tickformat=".0%", bargap=.3)
        st.plotly_chart(fig, width="stretch")
        st.dataframe(t[["tramo", "n", "efecto", "se", "p"]], hide_index=True, width="stretch", column_config={
            "tramo": "Días hasta la entrada", "n": "Precios",
            "efecto": st.column_config.NumberColumn(f"Dif. frente a «{info['base']}»", format="percent"),
            "se": st.column_config.NumberColumn("Error estándar", format="%.4f",
                                                help="Agrupado por alojamiento: varias consultas del mismo alojamiento no cuentan como independientes"),
            "p": st.column_config.NumberColumn("p-valor", format="%.3f",
                                               help="Menor de 0,05 = diferencia estadísticamente significativa")})
        st.caption(f"Compara cada alojamiento consigo mismo en distintos momentos (efectos fijos, "
                   f"{info['grupos']} alojamientos vistos en al menos dos tramos), así se descuenta la "
                   "ciudad y el mes de entrada. En rojo, los tramos con efecto significativo (p < 0,05, "
                   "con errores agrupados por alojamiento) y de al menos el 5 %. El umbral es el punto a "
                   "partir del cual la antelación deja de importar.")
        with st.expander("📐 Formalización del modelo"):
            st.latex(LATEX_ANTELACION_CTRL if ctrl else
                     r"\log(\text{precio}_{it}) = \alpha_i + \sum_{k} \beta_k \cdot \mathbb{1}[\text{tramo}_{it}=k] + \varepsilon_{it}")
            if ctrl:
                st.markdown("\n".join(LINEAS_ANTELACION_CTRL))
            st.markdown("\n".join([
                "- **i** = alojamiento concreto (nombre + ciudad + fecha de entrada) · **t** = cada consulta histórica de ese alojamiento.",
                "- **αᵢ**: efecto fijo por alojamiento — descuenta todo lo que no cambia para ese alojamiento (ciudad, mes...).",
                f"- **βₖ** (exponenciado, exp(β)-1): cambio porcentual de precio en el tramo *k* frente al tramo de referencia «{info['base']}».",
                "- Estimado por mínimos cuadrados sobre las variables centradas por alojamiento (*within estimator*), equivalente a incluir una variable ficticia por alojamiento.",
                f"- Errores estándar agrupados (*cluster-robust*) por alojamiento: **{info['grupos']}** grupos, **{info['n']}** observaciones, R² = **{info['r2']:.3f}**.",
            ]))

    st.subheader("2. ¿Cuánto se mueve el precio de verdad?")
    if ctrl:
        st.caption(NOTA_VOLATILIDAD_CTRL)
    vol, vinfo = _volatilidad_hoteles(mt_hist)
    umbral_vol = 0
    if vol.empty:
        st.info(vinfo.get("error", "") + " Hacen falta al menos dos descargas del mismo alojamiento, "
                "separadas en el tiempo (por ejemplo, un día).")
    else:
        umbral_vol = vinfo["umbral"]
        c1, c2 = st.columns(2)
        c1.metric("Umbral por volatilidad", f"{umbral_vol} días" if umbral_vol else "estable")
        c2.metric("Comparaciones", f"{vinfo['pares']:,}".replace(",", "."),
                  f"desde {pd.to_datetime(vinfo['desde_cuando']):%d/%m}", delta_arrow="off", delta_color="off")
        vm = vol.melt(id_vars=["tramo", "desde"], value_vars=["tendencia_dia", "volatilidad_dia"],
                      var_name="serie", value_name="valor")
        vm["serie"] = vm["serie"].map({"tendencia_dia": "Tendencia (con signo)", "volatilidad_dia": "Volatilidad (magnitud)"})
        fig = px.bar(vm.sort_values("desde"), x="tramo", y="valor", color="serie", barmode="group",
                     labels={"tramo": "Días hasta la entrada", "valor": "Cambio al día", "serie": ""},
                     color_discrete_sequence=[COLORES[0], ROJO])
        fig.update_traces(hovertemplate="%{x}<br>%{y:.2%} al día<extra></extra>")
        estilo(fig, alto=320)
        fig.update_layout(yaxis_tickformat=".1%", bargap=.3)
        st.plotly_chart(fig, width="stretch")
        st.dataframe(vol[["tramo", "pares", "tendencia_dia", "volatilidad_dia", "pct_movidos", "dias_refresco"]],
                     hide_index=True, width="stretch", column_config={
                         "tramo": "Días hasta la entrada", "pares": "Comparaciones",
                         "tendencia_dia": st.column_config.NumberColumn(
                             "Tendencia al día", format="percent",
                             help="Cambio medio CON signo, por día: ¿sube o baja de media en ese tramo?"),
                         "volatilidad_dia": st.column_config.NumberColumn(
                             "Volatilidad al día", format="percent",
                             help="Magnitud del movimiento típico, escalada con la raíz del tiempo (paseo aleatorio)"),
                         "pct_movidos": st.column_config.NumberColumn("% que cambió ≥5 %", format="percent"),
                         "dias_refresco": st.column_config.NumberColumn(
                             "Refrescar cada (días)", format="%d",
                             help="Días que tarda el precio, de media, en moverse un 5 %")})
        st.caption("Compara cada precio con el de la descarga anterior del mismo alojamiento (mismo "
                   "nombre). La tendencia lleva signo (sube o baja de media); la volatilidad es la "
                   "magnitud del movimiento, sin signo. Los tramos con menos de 30 comparaciones son "
                   "poco fiables.")
        with st.expander("📐 Formalización del modelo"):
            st.latex(r"\text{tendencia}_{it} = \frac{\Delta p_{it}/p_{i,t-1}}{\Delta t_{it}} "
                     r"\qquad \text{volatilidad}_{it} = \frac{|\Delta p_{it}/p_{i,t-1}|}{\sqrt{\Delta t_{it}}}")
            st.markdown("\n".join([
                "- **Δt**: tiempo (en días) transcurrido entre dos consultas consecutivas del mismo alojamiento.",
                "- La volatilidad se escala con la **raíz** de Δt, no linealmente, como en un paseo aleatorio: así no se sobrestima cuánto se moverá el precio dentro de varios días a partir de cambios vistos en pocas horas.",
                "- `dias_refresco` = los días que hacen falta, dentro de ese tramo, para que la volatilidad acumulada (volatilidad_dia × √días) alcance el 5 % — ese es el ritmo de refresco recomendado.",
            ]))

    st.subheader("3. ¿Sube o baja según se acerca la fecha?")
    tsub, curva, isub = _probabilidad_hoteles(mt_hist, ctrl)
    if tsub.empty:
        st.info(isub.get("error", "Todavía no hay histórico suficiente. Hacen falta al menos dos "
                                  "descargas del mismo alojamiento en fechas distintas."))
        return
    st.metric("Comparaciones", f"{isub['pares']:,}".replace(",", "."))
    fig = px.bar(tsub, x="tramo", y="pct_subio",
                 labels={"tramo": "Días hasta la entrada", "pct_subio": "% de veces que subió"})
    fig.update_traces(marker_color=ROJO, hovertemplate="%{x}<br>%{y:.0%}<extra></extra>")
    estilo(fig, alto=320, leyenda="no")
    fig.update_layout(yaxis_tickformat=".0%", yaxis_range=[0, 1], bargap=.3)
    fig.add_hline(y=0.5, line_dash="dash", line_color="#888")
    st.plotly_chart(fig, width="stretch")
    if isub["modelo_ok"] and not curva.empty:
        st.caption(f"Curva estimada por un modelo (regresión logística, {isub['pares']} comparaciones, "
                   f"{isub['grupos']} alojamientos, cambios menores del {isub['umbral_ruido']:.0%} descartados "
                   "como ruido): probabilidad de subida según los días que faltan.")
        fig2 = px.line(curva, x="dias", y="probabilidad",
                       labels={"dias": "Días hasta la entrada", "probabilidad": "Probabilidad de subida"})
        fig2.update_traces(line_color=ROJO)
        estilo(fig2, alto=260, leyenda="no")
        fig2.update_layout(yaxis_tickformat=".0%", yaxis_range=[0, 1])
        st.plotly_chart(fig2, width="stretch")
        with st.expander("📐 Formalización del modelo"):
            st.latex(r"\text{logit}\big(P(\text{subió}_{it})\big) = \beta_0 + \beta_1 \cdot \text{días}_{it} "
                     + (LATEX_SUBIDA_CTRL if ctrl else "")
                     + r"+ \sum_j \gamma_j \cdot \mathbb{1}[\text{ciudad}_{it}=j]")
            lineas = [
                f"- Solo cuenta cambios de al menos el {isub['umbral_ruido']:.0%} frente a la consulta "
                "anterior; los menores se descartan como ruido de redondeo, no una subida/bajada real.",
                "- Se controla por ciudad (**γⱼ**) para no confundir «esta ciudad siempre sube» con "
                "«sube porque falta poco».",
            ]
            lineas += LINEAS_SUBIDA_CTRL if ctrl else []
            or_dia = np.exp(isub["b1"]) if isub.get("b1") is not None and not pd.isna(isub.get("b1")) else None
            if or_dia is not None:
                lineas.append(f"- **β₁ = {isub['b1']:.4f}** → cada día menos multiplica la "
                             f"probabilidad de subir por exp(β₁) ≈ **{or_dia:.3f}** (odds ratio diario).")
            lineas.append(f"- Ajustado por Newton-Raphson (IRLS); errores agrupados por alojamiento "
                          f"(**{isub['grupos']}** grupos, **{isub['pares']}** comparaciones).")
            st.markdown("\n".join(lineas))
    st.caption("La línea del 50% marca 'sube o baja según toque'. Por encima, sube más veces de "
               "las que baja al acercarse esa antelación; por debajo, al revés. Compara siempre el "
               "mismo alojamiento (mismo nombre) frente a su consulta anterior.")

    st.subheader("4. ¿Cuánto sube si contrato más tarde?")
    st.caption("Con los alojamientos que cumplen tus filtros actuales (⭐ Buscador) y el modelo del "
               "punto 1: cuánto pagarías de más, de media por noche, si contratas en la fecha que "
               "elijas en vez de hoy.")
    if tabla.empty:
        st.info("Hace falta el modelo del punto 1 para esto.")
    else:
        h_f = hoteles_filtrados(mt_hot, F["fh"])
        if F["ciudades"]:
            h_f = h_f[h_f["ciudad"].isin(F["ciudades"])]
        if not F["fecha_libre"]:
            h_f = h_f[(h_f["fecha_entrada"] >= pd.Timestamp(F["rango"][0]))
                      & (h_f["fecha_entrada"] <= pd.Timestamp(F["rango"][1]))]
        if h_f.empty:
            st.info("No hay alojamientos con los filtros actuales (revisa ⭐ Buscador).")
        else:
            hoy2 = date.today()
            fecha_futura_h = st.date_input(
                "Fecha en la que contratarías", value=hoy2 + timedelta(days=30),
                min_value=hoy2 + timedelta(days=1), key="fecha_estimador_hoteles")
            efecto_tramo_h = tabla.set_index("tramo")["efecto"].to_dict()
            tr_ant = mp.TRAMOS_CTRL if ctrl else mp.TRAMOS
            est = h_f.assign(fecha_ref=h_f["fecha_entrada"].dt.date).dropna(subset=["precio_noche"])
            est["dias_hoy"] = est["fecha_ref"].map(lambda f: max((f - hoy2).days, 0))
            est["dias_futuro"] = est["fecha_ref"].map(lambda f: (f - fecha_futura_h).days)
            est = est[est["dias_futuro"] >= 0]
            if est.empty:
                st.info(f"La fecha elegida ({fecha_futura_h:%d/%m/%y}) es posterior a todos los "
                        "alojamientos filtrados.")
            else:
                est["efecto_hoy"] = est["dias_hoy"].map(lambda d: mp.tramo_de(d, tr_ant)).map(efecto_tramo_h)
                est["efecto_futuro"] = est["dias_futuro"].map(lambda d: mp.tramo_de(d, tr_ant)).map(efecto_tramo_h)
                est = est.dropna(subset=["efecto_hoy", "efecto_futuro"]).copy()
                if est.empty:
                    st.info("No hay suficientes tramos con datos para estimar esto.")
                else:
                    est["incremento_noche"] = est["precio_noche"] * (
                        (1 + est["efecto_futuro"]) / (1 + est["efecto_hoy"]) - 1)
                    media_h = est["incremento_noche"].mean()
                    k1, k2 = st.columns(2)
                    k1.metric("Alojamientos comparados", f"{len(est):,}".replace(",", "."))
                    signo, verbo = (("más caro", "subiría") if media_h >= 0
                                   else ("más barato", "bajaría"))
                    k2.metric(f"Si contratas el {fecha_futura_h:%d/%m/%y}",
                              f"{abs(media_h):,.0f} €/noche {signo}".replace(",", "."))
                    st.caption(f"El precio medio por noche {verbo} unos {abs(media_h):.0f} € frente a "
                               f"contratarlo hoy, según cómo cambia el efecto de antelación entre el "
                               f"tramo de hoy y el tramo en el que estaría cada alojamiento el "
                               f"{fecha_futura_h:%d/%m/%y}, aplicado sobre su precio actual.")


def viaje_con_hotel(c):
    """A las combinaciones de vuelos ya filtradas, les añade el alojamiento (noche a noche)
    para las mismas fechas y destino. Vacío si no hay solape entre vuelos y hoteles."""
    if c.empty or not hay_hoteles:
        return pd.DataFrame()
    est = coste_estancia(mt_hot, F["fh"], F["n_baratos"],
                         tuple(sorted({int(x) for x in c["dias"].unique()})))
    if est.empty:
        return pd.DataFrame()
    est = est.rename(columns={"fecha_entrada": "ida", "noches": "dias"})
    v = c.merge(est[["codigo", "ida", "dias", "hotel_base", "hotel_noche"]],
                on=["codigo", "ida", "dias"], how="inner")
    if v.empty:
        return v
    habitaciones = int(np.ceil(F["personas"] / 2))
    v["hotel"] = v["hotel_base"] * habitaciones
    v["viaje"] = v["total"] + v["hotel"]
    return v.sort_values("viaje").reset_index(drop=True)

def pag_completo():
    cabecera("🎒 Viaje completo", "Vuelos y alojamiento sumados, listos para comparar")
    if not hay_datos:
        return sin_datos()
    if not hay_hoteles:
        return sin_hoteles()
    c = combinaciones()
    if c.empty:
        return sin_resultados()
    v = viaje_con_hotel(c)
    if v.empty:
        st.warning("Hay vuelos y hay hoteles, pero no para las mismas fechas y destinos. "
                   "Descarga hoteles de esos días o amplía los filtros.")
        return
    habitaciones = int(np.ceil(F["personas"] / 2))
    m = v.iloc[0]
    k = st.columns(4)
    k[0].metric("Viaje más barato", eur(m.viaje),
                f"{m.ciudad} · {m.ida:%d/%m} → {m.vuelta:%d/%m}", delta_color="off", delta_arrow="off")
    k[1].metric("Vuelos", eur(m.total))
    k[2].metric("Alojamiento", eur(m.hotel), f"{habitaciones} habitación(es) · {m.dias} noches",
                delta_color="off", delta_arrow="off")
    k[3].metric("Combinaciones", f"{len(v):,}".replace(",", "."))
    vista = detallar(v.head(300), F["personas"])
    st.dataframe(vista[["ciudad", "viaje", "total", "hotel", "hotel_noche", "ida", "dia_ida",
                        "vuelta", "dias", "reservar", "aerolinea_ida", "aerolinea_vta"]],
                 hide_index=True, width="stretch", height=520, row_height=34, column_config={
                     **COLS,
                     "viaje": st.column_config.NumberColumn("Viaje total €", format="%d €"),
                     "total": st.column_config.NumberColumn("Vuelos €", format="%d €"),
                     "hotel": st.column_config.NumberColumn("Alojamiento €", format="%d €"),
                     "hotel_noche": st.column_config.NumberColumn("€/noche", format="%d €")})
    st.subheader("Reparto del gasto por destino")
    g = (v.groupby("ciudad", as_index=False).agg(Vuelos=("total", "min"), Alojamiento=("hotel", "min"))
         .sort_values("Vuelos"))
    fig = px.bar(g.melt(id_vars="ciudad", var_name="concepto", value_name="euros"),
                 x="euros", y="ciudad", color="concepto", orientation="h",
                 color_discrete_sequence=[COLORES[0], COLORES[1]], labels={"ciudad": "", "euros": "€"})
    estilo(fig, alto=max(240, 40 * len(g)))
    fig.update_layout(barmode="stack", yaxis=dict(autorange="reversed"))
    st.plotly_chart(fig, width="stretch")
    st.caption("El alojamiento se calcula noche a noche: se suman las noches concretas de cada "
               f"estancia ({m.dias} en la más barata) × {habitaciones} habitación(es), con el "
               "precio típico de la ciudad ese día. Así una entrada en viernes cuesta lo que "
               "cuesta el viernes, no una media del mes.")
    st.subheader("🗺️ Mapa")
    hv = hoteles_filtrados(mt_hot, F["fh"])
    hv = hv[hv["codigo"].isin(v["codigo"].unique()) & hv["lat"].notna()]
    if not hv.empty:
        aero = coords_aeropuertos(hv["codigo"].unique().tolist())
        fig = go.Figure()
        fig.add_trace(go.Scattermap(
            lat=hv["lat"], lon=hv["lon"], mode="markers",
            marker=dict(size=8, color=hv["precio_noche"], colorscale=ESCALA_PRECIO,
                       colorbar=dict(title="€/noche", thickness=10)),
            hovertext=hv["nombre"] + "<br>" + hv["precio_noche"].round(0).astype(int).astype(str) + " €/noche",
            hoverinfo="text", name="Hoteles"))
        for cod, (lat, lon) in aero.items():
            if cod == "MAD":
                continue
            fig.add_trace(go.Scattermap(
                lat=[lat], lon=[lon], mode="markers+text",
                marker=dict(size=16, color="#E5484D"), text=[f"✈️ {cod}"], textposition="top center",
                hoverinfo="text", name=f"Aeropuerto {cod}"))
        fig.update_layout(map=dict(style="open-street-map",
                                   center=dict(lat=hv["lat"].mean(), lon=hv["lon"].mean()), zoom=5),
                          height=560, margin=dict(l=0, r=0, t=0, b=0), showlegend=False)
        st.plotly_chart(fig, width="stretch")    

def pag_completo_mapa():
    cabecera("🗺️ Mapa", "Alojamiento y aeropuertos de los destinos con vuelo y hotel para las mismas fechas")
    if not hay_datos:
        return sin_datos()
    if not hay_hoteles:
        return sin_hoteles()
    c = combinaciones()
    if c.empty:
        return sin_resultados()
    v = viaje_con_hotel(c)
    if v.empty:
        st.warning("Hay vuelos y hay hoteles, pero no para las mismas fechas y destinos.")
        return
    hv = hoteles_filtrados(mt_hot, F["fh"])
    hv = hv[hv["codigo"].isin(v["codigo"].unique()) & hv["lat"].notna()]
    if hv.empty:
        return sin_resultados()
    aero = coords_aeropuertos(hv["codigo"].unique().tolist())
    _extra_aero = np.where(
        hv["km_aeropuerto"].notna() if "km_aeropuerto" in hv.columns else False,
        "<br>✈️ " + hv["km_aeropuerto"].round(1).astype(str) + " km · "
        + hv["min_andando_aeropuerto"].fillna(0).round(0).astype(int).astype(str) + " min andando",
        "") if "km_aeropuerto" in hv.columns else ""
    fig = go.Figure()
    fig.add_trace(go.Scattermap(
        lat=hv["lat"], lon=hv["lon"], mode="markers",
        marker=dict(size=8, color=hv["precio_noche"], colorscale=ESCALA_PRECIO,
                   colorbar=dict(title="€/noche", thickness=10)),
        hovertext=hv["nombre"] + "<br>" + hv["precio_noche"].round(0).astype(int).astype(str) + " €/noche"
                  + _extra_aero,
        hoverinfo="text", name="Hoteles"))
    for cod, (lat, lon) in aero.items():
        if cod == "MAD":
            continue
        fig.add_trace(go.Scattermap(
            lat=[lat], lon=[lon], mode="markers+text",
            marker=dict(size=16, color="#E5484D"), text=[f"✈️ {cod}"], textposition="top center",
            hoverinfo="text", name=f"Aeropuerto {cod}"))
    fig.update_layout(map=dict(style="open-street-map",
                               center=dict(lat=hv["lat"].mean(), lon=hv["lon"].mean()), zoom=5),
                      height=600, margin=dict(l=0, r=0, t=0, b=0), showlegend=False)
    st.plotly_chart(fig, width="stretch")
    st.caption("Azul = alojamiento en un destino con vuelo y hotel para las mismas fechas. Rojo = aeropuerto.")

def pag_completo_buscador():
    cabecera("🔎 Buscador del viaje completo")
    if not hay_datos:
        return sin_datos()
    if not hay_hoteles:
        return sin_hoteles()
    c = combinaciones()
    if c.empty:
        return sin_resultados()
    v = viaje_con_hotel(c)
    if v.empty:
        st.warning("Hay vuelos y hay hoteles, pero no para las mismas fechas y destinos. "
                   "Descarga hoteles de esos días o amplía los filtros.")
        return
    orden = st.segmented_control("Ordenar por", ["Viaje total", "Solo vuelos", "Solo alojamiento", "Fecha de ida"],
                                 default="Viaje total", key="orden_completo")
    col = {"Viaje total": "viaje", "Solo vuelos": "total", "Solo alojamiento": "hotel",
           "Fecha de ida": "ida"}.get(orden or "Viaje total")
    v = v.sort_values([col, "viaje"])
    vista = detallar(v.head(MAX_FILAS_TABLA), F["personas"])
    habitaciones = int(np.ceil(F["personas"] / 2))
    st.dataframe(vista[["ciudad", "viaje", "total", "hotel", "hotel_noche", "ida", "dia_ida",
                        "vuelta", "dias", "reservar", "aerolinea_ida", "aerolinea_vta",
                        "hora_salida_ida", "hora_salida_vta"]],
                 hide_index=True, width="stretch", height=620, row_height=34, column_config={
                     **COLS,
                     "viaje": st.column_config.NumberColumn("Viaje total €", format="%d €"),
                     "total": st.column_config.NumberColumn("Vuelos €", format="%d €"),
                     "hotel": st.column_config.NumberColumn(f"Alojamiento € ({habitaciones} hab.)", format="%d €"),
                     "hotel_noche": st.column_config.NumberColumn("€/noche", format="%d €")})
    extra = f" (se muestran las {MAX_FILAS_TABLA} primeras)" if len(v) > MAX_FILAS_TABLA else ""
    st.caption(f"{len(v):,} combinaciones{extra}. Viaje = vuelos (ida+vuelta, {F['personas']} "
               f"persona(s)) + alojamiento ({habitaciones} habitación(es), noche a noche, precio "
               "típico de la ciudad ese día — no un alojamiento concreto).".replace(",", "."))
    exportable = detallar(v.head(5000), F["personas"])
    st.download_button("💾 Exportar a CSV (Excel)",
                       exportable.to_csv(sep=";", decimal=",", index=False).encode("utf-8-sig"),
                       "viaje_completo_filtrado.csv", "text/csv",
                       on_click=lambda: st.toast("Tabla exportada", icon="💾"))

def pag_gestion_datos_vuelos():
    titulo_pagina("🗄️", "Gestión de datos", "Cuánto se ha descargado cada día y cuánto pesa")
    st.subheader("Tamaño de los archivos")
    archivos = [(CSV, "Vuelos (precios)"), (CSV_OPC, "Vuelos (todas las opciones)"),
                (HISTORICO, "Histórico de precios"), (SONDEOS, "Sondeos por mes"),
                (ERRORES, "Historial de errores")]
    filas_tam = [{"Archivo": et, "Tamaño": tamano_legible(tamano_bytes(r))}
                for r, et in archivos if os.path.exists(r)]
    st.dataframe(pd.DataFrame(filas_tam), hide_index=True, width="stretch")
    total = sum(tamano_bytes(r) for r, _ in archivos)
    st.metric("Total en disco", tamano_legible(total))

    por_dia = consultas_por_dia(HISTORICO, mtime(HISTORICO))
    if por_dia.empty:
        st.info("Todavía no hay histórico de descargas.")
        return

    hoy = date.today()
    fila_hoy = por_dia[por_dia["dia"] == hoy]
    c1, c2 = st.columns(2)
    c1.metric("Consultas hoy", f"{int(fila_hoy['filas'].iloc[0]):,}".replace(",", ".") if not fila_hoy.empty else "0")
    c2.metric("Destinos distintos hoy", int(fila_hoy["destinos"].iloc[0]) if not fila_hoy.empty else 0)

    st.subheader("Descargas por día")
    fig = px.bar(por_dia.sort_values("dia"), x="dia", y="filas", labels={"dia": "", "filas": "Consultas"})
    fig.update_traces(marker_color=COLORES[0])
    estilo(fig, alto=280, leyenda="no")
    fig.update_layout(bargap=.15)
    st.plotly_chart(fig, width="stretch")
    st.dataframe(por_dia.sort_values("dia", ascending=False), hide_index=True, width="stretch",
                 column_config={"dia": st.column_config.DateColumn("Día", format="DD/MM/YY"),
                                "filas": "Consultas", "destinos": "Destinos distintos"})

    st.subheader("Reducir el histórico")
    st.caption("`historico_precios.csv` guarda una fila por cada consulta, para poder calcular "
               "volatilidad y probabilidad de subida. Puedes recortar lo más antiguo a una sola "
               "fila por vuelo y día (la última consulta de ese día) sin perder la granularidad "
               "de días que usan esos modelos; lo reciente se deja intacto.")
    dias_mantener, dias_retener = politica_historico()
    if st.button(f"🗜️ Comprimir histórico de vuelos anterior a {dias_mantener} días"):
        with st.spinner("Comprimiendo histórico de vuelos…"):
            n0, n1 = comprimir_historico(HISTORICO, dias_mantener, ["codigo", "sentido", "fecha_vuelo"],
                                         dias_retener)
        consultas_por_dia.clear()
        st.toast(f"Histórico comprimido: {n0:,} → {n1:,} filas".replace(",", "."), icon="🗜️")
        st.rerun()

def pag_maletas_todo():
    ejecutar_pestanas(["✈️ Vuelos", "🚆 Trenes"], [pag_maletas, pag_trenes_equipaje], "tabs_pag_maletas_todo")


def _secciones_datos():
    """Ficheros de datos agrupados por sección, con su caché rápida (.parquet) si existe."""
    base = {
        "✈️ Vuelos": [(CSV, "Vuelos (precios)"), (CSV_OPC, "Vuelos (todas las opciones)"),
                      (HISTORICO, "Histórico de vuelos"), (SONDEOS, "Sondeos de vuelos"),
                      (ERRORES, "Historial de errores")],
        "🚆 Trenes": [(CSV_TREN, "Trenes (precios)"), (CSV_TREN_HIST, "Histórico de trenes"),
                      (ESTADO_TREN, "Estado de Ouigo")],
        "🏨 Hoteles": [(CSV_HOT, "Hoteles (precios)"), (CSV_HOT_HIST, "Histórico de hoteles"),
                       (CSV_HOT_SONDEO, "Sondeos de hoteles")],
    }
    sec = {}
    for nombre, fich in base.items():
        filas = []
        for ruta, et in fich:
            filas.append((ruta, et))
            if os.path.exists(ruta + ".parquet"):
                filas.append((ruta + ".parquet", et + " · caché rápida"))
        sec[nombre] = filas
    otros = []
    for n in sorted(os.listdir(BASE)):
        if n.endswith((".json", ".log")) and n != os.path.basename(CONFIG) or n.startswith("rutas_"):
            otros.append((os.path.join(BASE, n), n))
    sec["📦 Otros (rutas, logs, ajustes)"] = otros
    return sec


def pag_gestion_datos_todo():
    """Gestión de datos de todo junto: peso por sección (tarta), descargas por día y compresión."""
    sec = _secciones_datos()
    filas = [{"Sección": nom, "Archivo": et, "bytes": tamano_bytes(r)}
             for nom, fich in sec.items() for r, et in fich if os.path.exists(r)]
    d = pd.DataFrame(filas)
    if d.empty:
        return st.info("Todavía no hay datos descargados.")
    total = int(d["bytes"].sum())
    por_sec = d.groupby("Sección", as_index=False)["bytes"].sum().sort_values("bytes", ascending=False)
    cols = st.columns(1 + len(por_sec))
    cols[0].metric("Total en disco", tamano_legible(total))
    for c, r in zip(cols[1:], por_sec.itertuples()):
        c.metric(r.Sección, tamano_legible(int(r.bytes)), f"{r.bytes / max(total, 1):.0%}", delta_color="off")

    st.subheader("Peso por sección")
    vista = st.segmented_control("Clasificar por", ["Sección", "Archivo"], default="Sección", key="ges_tarta")
    col_color = {"✈️ Vuelos": COLOR_TIPO["vuelos"], "🚆 Trenes": COLOR_TIPO["trenes"],
                 "🏨 Hoteles": COLOR_TIPO["hoteles"], "📦 Otros (rutas, logs, ajustes)": GRIS}
    if vista == "Archivo":
        g = d[d["bytes"] > 0]
        fig = px.pie(g, names="Archivo", values="bytes", hole=.45, color_discrete_sequence=COLORES)
    else:
        fig = px.pie(por_sec, names="Sección", values="bytes", hole=.45, color="Sección",
                     color_discrete_map=col_color)
    fig.update_traces(textinfo="label+percent", hovertemplate="%{label}<br>%{percent}<extra></extra>")
    estilo(fig, alto=380, leyenda="no")
    st.plotly_chart(fig, width="stretch")
    t = d.assign(Tamaño=d["bytes"].map(lambda b: tamano_legible(int(b))),
                 Porcentaje=d["bytes"] / max(total, 1)).sort_values("bytes", ascending=False)
    st.dataframe(t[["Sección", "Archivo", "Tamaño", "Porcentaje"]], hide_index=True, width="stretch",
                 column_config={"Porcentaje": st.column_config.ProgressColumn("Del total", format="percent",
                                                                              min_value=0, max_value=1)})

    st.subheader("Descargas por día (vuelos + trenes + hoteles)")
    partes = []
    for nom, ruta, c_con, c_dest in (("✈️ Vuelos", HISTORICO, "consulta", "codigo"),
                                    ("🚆 Trenes", CSV_TREN_HIST, "consulta", "codigo"),
                                    ("🏨 Hoteles", CSV_HOT_HIST, "consulta", "codigo")):
        if os.path.exists(ruta):
            x = consultas_por_dia(ruta, mtime(ruta), c_con, c_dest)
            if not x.empty:
                partes.append(x.assign(Sección=nom))
    if partes:
        por_dia = pd.concat(partes, ignore_index=True)
        hoy = date.today()
        hoy_n = int(por_dia.loc[por_dia["dia"] == hoy, "filas"].sum())
        k1, k2 = st.columns(2)
        k1.metric("Consultas hoy (todo)", f"{hoy_n:,}".replace(",", "."))
        k2.metric("Días con descargas", int(por_dia["dia"].nunique()))
        fig = px.bar(por_dia.sort_values("dia"), x="dia", y="filas", color="Sección",
                     color_discrete_map=col_color, labels={"dia": "", "filas": "Consultas"})
        estilo(fig, alto=300)
        fig.update_layout(bargap=.15)
        st.plotly_chart(fig, width="stretch")
        piv = (por_dia.pivot_table(index="dia", columns="Sección", values="filas", aggfunc="sum")
               .fillna(0).astype(int).sort_index(ascending=False).reset_index())
        piv["Total"] = piv.drop(columns="dia").sum(axis=1)
        st.dataframe(piv, hide_index=True, width="stretch",
                     column_config={"dia": st.column_config.DateColumn("Día", format="DD/MM/YY")})
    else:
        st.info("Todavía no hay histórico de descargas.")

    st.subheader("Reducir todos los históricos")
    comp, ret = politica_historico()
    st.caption(f"Aplica la política de arriba ({comp} días de detalle completo"
               + (f", conservando como máximo {ret} días" if ret else ", sin límite de antigüedad") + ") a los tres históricos.")
    if st.button("🗜️ Comprimir todos los históricos", key="ges_comp_todo"):
        res = []
        with st.spinner("Comprimiendo históricos…"):
            for et, ruta, claves in (("vuelos", HISTORICO, ["codigo", "sentido", "fecha_vuelo"]),
                                     ("trenes", CSV_TREN_HIST, ["codigo", "sentido", "fecha", "compania", "hora_salida"]),
                                     ("hoteles", CSV_HOT_HIST, ["codigo", "ciudad", "fecha_entrada", "nombre"])):
                if os.path.exists(ruta):
                    n0, n1 = comprimir_historico(ruta, comp, claves, ret)
                    res.append(f"{et}: {n0:,} → {n1:,}".replace(",", "."))
        consultas_por_dia.clear()
        leer_historico_trenes.clear()
        st.toast("Históricos comprimidos · " + " · ".join(res), icon="🗜️")
        st.rerun()


def pag_gestion_datos_completo():
    """Gestión de datos de vuelos, trenes y hoteles, más la vista agregada."""
    politica_historico_ui()
    ejecutar_pestanas(["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles", "🎒 Completo"],
                      [pag_gestion_datos_vuelos, pag_gestion_datos_trenes, pag_gestion_datos_hoteles,
                       pag_gestion_datos_todo],
                      "tabs_gestion")


def pag_resumen_todo():
    panel_filtros()
    aviso_favoritos_bajados()
    ejecutar_pestanas(["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles", "🎒 Completo"], [pag_resumen, pag_trenes_resumen, pag_hoteles_resumen, pag_completo], "tabs_pag_resumen_todo")


# ============================================================ DISTRIBUCIÓN (histogramas y dispersión)
_PAISES_REGION = {
    "España": "ES",
    "Europa": "AD AL AT BA BE BG BY CH CY CZ DE DK EE FI FO FR GB GG GI GR HR HU IE IM IS IT JE LI "
              "LT LU LV MC MD ME MK MT NL NO PL PT RO RS RU SE SI SK SM UA VA XK",
    "Norte de África": "DZ EG LY MA MR TN EH",
    "África (resto)": "AO BF BI BJ BW CD CF CG CI CM CV DJ ER ET GA GH GM GN GQ GW KE KM LR LS MG "
                      "ML MU MW MZ NA NE NG RE RW SC SD SL SN SO SS ST SZ TD TG TZ UG YT ZA ZM ZW",
    "Oriente Medio": "AE AM AZ BH GE IL IQ IR JO KW LB OM PS QA SA SY TR YE",
    "Asia": "AF BD BN BT CN HK ID IN JP KG KH KP KR KZ LA LK MM MN MO MV MY NP PH PK SG TH TJ TM "
            "TW UZ VN",
    "Norteamérica": "US CA MX GL",
    "Centroamérica y Caribe": "AG AW BB BS BZ CR CU CW DM DO GD GT HN HT JM KN KY LC NI PA PR SV "
                              "TT VC VG VI",
    "Sudamérica": "AR BO BR CL CO EC GY PE PY SR UY VE",
    "Oceanía": "AU FJ NZ PF PG NC WS TO VU",
}
_REGION_DE_PAIS = {c: r for r, cs in _PAISES_REGION.items() for c in cs.split()}
_REGION_CODIGOS_METRO = {"PAR": "Europa", "ROM": "Europa", "MIL": "Europa", "LON": "Europa",
                         "STO": "Europa"}      # códigos de ciudad que no están en airportsdata
REGIONES = list(_PAISES_REGION) + ["Otras"]
REGION_COLOR = dict(zip(REGIONES, COLORES + ["#8B8F94"]))


@st.cache_data(show_spinner=False)
def regiones_de(codigos):
    """{código IATA: región} usando el país del aeropuerto (airportsdata) para agrupar en Europa,
    Norte de África, Sudamérica, etc. Los que no se puedan clasificar van a «Otras»."""
    try:
        import airportsdata
        ap = airportsdata.load("IATA")
    except Exception:
        ap = {}
    return {c: _REGION_CODIGOS_METRO.get(c) or _REGION_DE_PAIS.get(ap.get(c, {}).get("country"), "Otras")
            for c in codigos}


def con_region(d):
    """Añade la columna «zona» (región del destino) a una tabla con columna «codigo»."""
    mapa = regiones_de(tuple(sorted(d["codigo"].dropna().unique())))
    return d.assign(zona=d["codigo"].map(mapa).fillna("Otras"))


def ejes_log(clave):
    """Dos casillas para pasar el eje X y/o el Y de un gráfico a escala logarítmica."""
    a, b, _ = st.columns([1, 1, 3])
    return (a.checkbox("Eje X logarítmico", key=f"{clave}_lx",
                       help="Útil cuando hay pocos valores muy altos que aplastan al resto"),
            b.checkbox("Eje Y logarítmico", key=f"{clave}_ly"))


def aplicar_log(fig, lx, ly):
    if lx:
        fig.update_xaxes(type="log")
    if ly:
        fig.update_yaxes(type="log")
    return fig


def selector_color(clave, extra=None):
    opciones = ["Región", *([extra] if extra else []), "Sin color"]
    return st.radio("Colorear por", opciones, horizontal=True, key=clave,
                    help="Región = Europa, Norte de África, Sudamérica… según el país del destino")


@st.cache_data(show_spinner="Preparando vuelos únicos…", ttl="6h")
def vuelos_unicos(mt_o, mt_m, fv, maletas, tarifas):
    """Cada vuelo (fecha, sentido, destino, aerolínea, horas y escalas) UNA sola vez, con su dato
    más reciente, y con los filtros de 🕐 Vuelos y 🧳 Equipaje aplicados. Es la base de los
    histogramas: así un mismo vuelo nunca cuenta dos veces."""
    o = cargar_opciones(mt_o, mt_m)
    max_esc, incl, excl, dur_max, esc_max, evitar_sig, win_ida, win_vta = fv
    if max_esc is not None:
        o = o[o["escalas"] <= max_esc]
    if incl:
        o = o[o["aerolinea"].fillna("").str.contains("|".join(map(re.escape, incl)))]
    if excl:
        o = o[~o["aerolinea"].fillna("").str.contains("|".join(map(re.escape, excl)))]
    if dur_max:
        o = o[o["duracion_min"] <= dur_max * 60]
    if esc_max:
        o = o[(o["escalas"] == 0) | (o["escala_max_min"].fillna(0) <= esc_max * 60)]
    if evitar_sig:
        o = o[~o["llega_sig"]]
    ok_ida = (o["sentido"] == "IDA") & o["sal_min"].between(win_ida[0] * 60, win_ida[1] * 60)
    ok_vta = (o["sentido"] == "VUELTA") & o["sal_min"].between(win_vta[0] * 60, win_vta[1] * 60)
    o = o[ok_ida | ok_vta]
    if o.empty:
        return o
    o = o.assign(maletas=coste_maletas(o["aerolinea"], tarifas, *maletas))
    o["coste"] = o["precio_eur"] + o["maletas"]
    clave = ["fecha", "sentido", "codigo", "aerolinea", "hora_salida", "hora_llegada", "escalas",
             "duracion_min"]
    o = (o.sort_values("ultima_descarga", na_position="first")
         .drop_duplicates(clave, keep="last"))
    return con_region(o).reset_index(drop=True)


def vuelos_distribucion():
    """Vuelos únicos con los filtros de la barra lateral (destino, fechas, día, trayecto…)."""
    d = vuelos_unicos(mt_opc, mt, F["fv"], F["maletas"], F["tarifas"])
    if d.empty:
        return d
    if F["ciudades"]:
        d = d[d["ciudad"].isin(F["ciudades"])]
    sentido = {"Solo ida": "IDA", "Solo vuelta": "VUELTA"}.get(F.get("trayecto"))
    if sentido:
        d = d[d["sentido"] == sentido]
    r_ida, r_vta = F["rango"], F["rango_vuelta"]
    en_rango = np.where(d["sentido"] == "IDA",
                        (d["fecha"] >= r_ida[0]) & (d["fecha"] <= r_ida[1]),
                        (d["fecha"] >= r_vta[0]) & (d["fecha"] <= r_vta[1]))
    d = d[en_rango]
    if F["dias_sem"]:
        d = d[pd.to_datetime(d["fecha"]).dt.dayofweek.map(dict(enumerate(DIAS))).isin(F["dias_sem"])]
    d = d.assign(total=d["coste"] * F["personas"],
                 trayecto=np.where(d["sentido"] == "IDA", "Ida", "Vuelta"))
    if F["presupuesto"]:
        d = d[d["total"] <= F["presupuesto"]]
    return d


def hist_ligero(d, x, nbins, **kw):
    """Como px.histogram, pero con muchas filas cuenta en Python y solo envía las barras al
    navegador (enviar cientos de miles de valores consumía toda su memoria)."""
    if len(d) <= 20000:
        return px.histogram(d, x=x, nbins=nbins, **kw)
    v = pd.to_numeric(d[x], errors="coerce")
    ok = v.notna()
    d, v = d[ok], v[ok]
    lo, hi = float(v.min()), float(v.max())
    if hi <= lo:
        hi = lo + 1
    bordes = np.linspace(lo, hi, int(nbins) + 1)
    centros = (bordes[:-1] + bordes[1:]) / 2
    cat = np.clip(np.searchsorted(bordes, v.to_numpy(), side="right") - 1, 0, len(centros) - 1)
    color = kw.pop("color", None)
    labels = kw.pop("labels", {})
    claves = {"barmode": kw.pop("barmode", "relative"), "opacity": kw.pop("opacity", None)}
    if color:
        g = (pd.DataFrame({"c": cat, color: d[color].to_numpy()}).groupby(["c", color], observed=True)
             .size().reset_index(name="count"))
    else:
        g = pd.Series(cat).value_counts().rename_axis("c").reset_index(name="count")
    g[x] = centros[g["c"].to_numpy()]
    fig = px.bar(g, x=x, y="count", color=color, labels={**labels, "count": labels.get("count", "count")},
                 barmode=claves["barmode"], opacity=claves["opacity"], **kw)
    fig.update_traces(width=float(bordes[1] - bordes[0]))
    return fig


def _color_arg(modo, col_extra=None):
    if modo == "Región":
        return dict(color="zona", color_discrete_map=REGION_COLOR,
                    category_orders={"zona": REGIONES})
    if col_extra and modo == col_extra[0]:
        return dict(color=col_extra[1], color_discrete_sequence=COLORES)
    return {}


def pag_distribucion_vuelos():
    cabecera("📊 Distribución de precios de vuelos")
    if not hay_datos:
        return sin_datos()
    d = vuelos_distribucion()
    if d.empty:
        return sin_resultados()
    k = st.columns(4)
    k[0].metric("Vuelos únicos", f"{len(d):,}".replace(",", "."))
    k[1].metric("Más barato", eur(d["total"].min()))
    k[2].metric("Mediana", eur(d["total"].median()))
    k[3].metric("Destinos", d["ciudad"].nunique())

    st.subheader("Histograma de precios")
    c1, c2 = st.columns([2, 1])
    modo = c1.radio("Colorear por", ["Región", "Trayecto", "Sin color"], horizontal=True,
                    key="dist_v_color",
                    help="Región = Europa, Norte de África, Sudamérica… según el país del destino")
    barras = c2.slider("Nº de barras", 10, 120, 40, key="dist_v_barras")
    lx, ly = ejes_log("dist_v_hist")
    fig = hist_ligero(d, "total", barras, barmode="stack",
                       labels={"total": f"Precio (€, {F['personas']} pers.)", "zona": "", "trayecto": ""},
                       **_color_arg(modo, ("Trayecto", "trayecto")))
    fig.update_traces(marker_line_width=0)
    estilo(fig, alto=400, leyenda="no" if modo == "Sin color" else "arriba")
    fig.update_layout(yaxis_title="Nº de vuelos", bargap=.04)
    aplicar_log(fig, lx, ly)
    st.plotly_chart(fig, width="stretch")

    st.subheader("Precio y duración")
    dd = d.dropna(subset=["duracion_min"]).assign(horas=lambda x: x["duracion_min"] / 60)
    if dd.empty:
        st.info("Los vuelos filtrados no tienen duración registrada.")
    else:
        if len(dd) > MAX_PUNTOS_DISPERSION:
            dd = dd.sample(MAX_PUNTOS_DISPERSION, random_state=1)
            st.caption(f"Se dibujan {MAX_PUNTOS_DISPERSION:,} vuelos elegidos al azar (hay más con estos filtros).".replace(",", "."))
        modo2 = st.radio("Colorear por", ["Región", "Trayecto", "Sin color"], horizontal=True,
                         key="dist_v_color2")
        lx2, ly2 = ejes_log("dist_v_disp")
        fig = px.scatter(dd, x="horas", y="total", opacity=.55, render_mode="webgl",
                         hover_data={"ciudad": True, "aerolinea": True, "escalas": True,
                                     "fecha": True, "horas": ":.1f", "total": ":.0f", "zona": False},
                         labels={"horas": "Duración (h)", "total": f"Precio (€, {F['personas']} pers.)",
                                 "zona": "", "trayecto": ""},
                         **_color_arg(modo2, ("Trayecto", "trayecto")))
        fig.update_traces(marker_size=6)
        estilo(fig, alto=460, leyenda="no" if modo2 == "Sin color" else "arriba")
        aplicar_log(fig, lx2, ly2)
        st.plotly_chart(fig, width="stretch")
    st.caption("Cada punto/barra es un vuelo concreto (fecha, destino, aerolínea, horas y escalas) "
               "contado una sola vez, con su dato más reciente. Respeta los filtros de la barra "
               "lateral, incluidos 🕐 Vuelos, 🧳 Equipaje y Trayecto.")


def hoteles_distribucion():
    """Alojamientos únicos (uno por hotel y fecha, el dato más reciente) con los filtros actuales."""
    h = hoteles_filtrados(mt_hot, F["fh"])
    if h.empty:
        return h
    if F["ciudades"]:
        h = h[h["ciudad"].isin(F["ciudades"])]
    if not F["fecha_libre"]:
        h = h[(h["fecha_entrada"] >= pd.Timestamp(F["rango"][0]))
              & (h["fecha_entrada"] <= pd.Timestamp(F["rango"][1]))]
    if h.empty:
        return h
    if "consulta" in h.columns:
        h = h.sort_values("consulta", na_position="first")
    h = h.drop_duplicates(["codigo", "nombre", "fecha_entrada"], keep="last")
    return con_region(h).reset_index(drop=True)


def pag_distribucion_hoteles():
    cabecera("📊 Distribución de precios de alojamiento")
    if not hay_hoteles:
        return sin_hoteles()
    h = hoteles_distribucion()
    if h.empty:
        return sin_resultados()
    k = st.columns(4)
    k[0].metric("Alojamientos únicos", f"{len(h):,}".replace(",", "."))
    k[1].metric("Más barato", eur(h["precio_noche"].min()) + "/noche")
    k[2].metric("Mediana", eur(h["precio_noche"].median()) + "/noche")
    k[3].metric("Ciudades", h["ciudad"].nunique())

    st.subheader("Histograma de precios por noche")
    c1, c2 = st.columns([2, 1])
    modo = c1.radio("Colorear por", ["Región", "Sin color"], horizontal=True, key="dist_h_color")
    barras = c2.slider("Nº de barras", 10, 120, 40, key="dist_h_barras")
    lx, ly = ejes_log("dist_h_hist")
    fig = hist_ligero(h, "precio_noche", barras, barmode="stack",
                       labels={"precio_noche": "Precio por noche (€)", "zona": ""},
                       **_color_arg(modo))
    fig.update_traces(marker_line_width=0)
    estilo(fig, alto=400, leyenda="no" if modo == "Sin color" else "arriba")
    fig.update_layout(yaxis_title="Nº de alojamientos", bargap=.04)
    aplicar_log(fig, lx, ly)
    st.plotly_chart(fig, width="stretch")

    modo2 = st.radio("Colorear los gráficos de dispersión por", ["Región", "Sin color"],
                     horizontal=True, key="dist_h_color2")
    tope = MAX_PUNTOS_DISPERSION
    base = h if len(h) <= tope else h.sample(tope, random_state=1)
    if len(h) > tope:
        st.caption(f"Se dibujan {tope:,} alojamientos elegidos al azar (hay más con estos filtros).".replace(",", "."))
    hover = {"nombre": True, "ciudad": True, "precio_noche": ":.0f", "zona": False}

    st.subheader("Precio y valoración")
    lx3, ly3 = ejes_log("dist_h_val")
    v = base.dropna(subset=["valoracion"])
    if v.empty:
        st.info("Los alojamientos filtrados no tienen valoración.")
    else:
        fig = px.scatter(v, x="valoracion", y="precio_noche", opacity=.55, render_mode="webgl",
                         hover_data=hover,
                         labels={"valoracion": "Valoración (sobre 5)", "precio_noche": "€ por noche",
                                 "zona": ""}, **_color_arg(modo2))
        fig.update_traces(marker_size=6)
        estilo(fig, alto=440, leyenda="no" if modo2 == "Sin color" else "arriba")
        aplicar_log(fig, lx3, ly3)
        st.plotly_chart(fig, width="stretch")

    st.subheader("Precio y minutos al centro")
    medios = {"🚌 Transporte público": "min_transporte", "🚶 Andando": "min_andando",
              "🚗 Coche": "min_coche"}
    medios = {k_: c for k_, c in medios.items() if c in base.columns and base[c].notna().any()}
    if not medios:
        st.info("Los alojamientos filtrados no tienen tiempo al centro calculado todavía.")
    else:
        eleg = st.radio("Cómo llegas al centro", list(medios), horizontal=True, key="dist_h_medio")
        lx4, ly4 = ejes_log("dist_h_min")
        col = medios[eleg]
        m = base.dropna(subset=[col])
        fig = px.scatter(m, x=col, y="precio_noche", opacity=.55, render_mode="webgl",
                         hover_data={**hover, col: ":.0f"},
                         labels={col: "Minutos al centro", "precio_noche": "€ por noche", "zona": ""},
                         **_color_arg(modo2))
        fig.update_traces(marker_size=6)
        estilo(fig, alto=440, leyenda="no" if modo2 == "Sin color" else "arriba")
        aplicar_log(fig, lx4, ly4)
        st.plotly_chart(fig, width="stretch")
    st.caption("Cada punto/barra es un alojamiento concreto en una fecha de entrada, contado una sola "
               "vez con su dato más reciente. Respeta los filtros de 🏨 Alojamiento y de destino/fechas.")


def pag_distribucion_todo():
    ejecutar_pestanas(["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles"], [pag_distribucion_vuelos, pag_trenes_distribucion, pag_distribucion_hoteles], "tabs_pag_distribucion_todo")


def pag_buscador_todo():
    panel_filtros()
    ejecutar_pestanas(["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles", "🎒 Completo"], [pag_buscador, pag_trenes_buscador, pag_hoteles_buscador, pag_completo_buscador], "tabs_pag_buscador_todo")


def ejecutar_pestanas(etiquetas, funciones, clave):
    """Pestañas que solo ejecutan la que está abierta. Streamlit ejecuta todas a la vez y, con
    cinco mapas/gráficos por página, la ventana de la app se quedaba sin memoria."""
    try:
        tt = st.tabs(etiquetas, key=clave, on_change="rerun")
        abiertas = [bool(t.open) for t in tt]
    except TypeError:       # Streamlit antiguo: se ejecutan todas
        tt = st.tabs(etiquetas)
        abiertas = [True] * len(tt)
    for tab, activa, fn in zip(tt, abiertas, funciones):
        with tab:
            if activa:
                fn()


def pag_mapa_todo():
    panel_filtros()
    ejecutar_pestanas(["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles", "🎒 Completo", "🧭 Recorrido"],
                      [pag_mapa, pag_trenes_mapa, pag_hoteles_mapa, pag_completo_mapa, pag_recorrido], "tabs_mapa")


def pag_evolucion_todo():
    panel_filtros()
    ejecutar_pestanas(["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles"], [pag_evolucion, pag_trenes_evolucion, pag_hoteles_evolucion], "tabs_pag_evolucion_todo")


def pag_calendario_todo():
    panel_filtros()
    ejecutar_pestanas(["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles"], [pag_calendario, pag_trenes_calendario, pag_hoteles_calendario], "tabs_pag_calendario_todo")


def pag_antelacion_todo():
    ejecutar_pestanas(["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles"], [pag_anticipacion, pag_trenes_antelacion, pag_hoteles_antelacion], "tabs_pag_antelacion_todo")


def pag_favoritos_vuelos():
    titulo_pagina("⭐", "Favoritos de vuelos",
                  "Vuelos concretos para volver a descargar solo esos, sin bajar todo el destino")
    fav = leer_favoritos()
    lista = fav["vuelos"]
    if not lista:
        st.info("Todavía no tienes vuelos favoritos. Márcalos desde 🔎 Buscador.")
        return
    aviso_favoritos_bajados()
    t = pd.DataFrame(lista).join(precios_favoritos()[1]).join(precios_viajes(lista).add_prefix("viaje_"))
    for c in ("objetivo", "hotel", "objetivo_viaje"):
        if c not in t:
            t[c] = None
    t["ida"] = pd.to_datetime(t["ida"])
    t["vuelta"] = pd.to_datetime(t["vuelta"])
    t["guardado"] = pd.to_datetime(t["guardado"])
    t["cambio_pct"] *= 100
    t["viaje_cambio_pct"] *= 100
    for c in ("objetivo", "objetivo_viaje"):
        t[c] = pd.to_numeric(t[c], errors="coerce")
    t["hotel"] = t["hotel"].map(lambda h: h if isinstance(h, str) and h else None)
    codigos_hotel = {}
    for h in fav["hoteles"]:
        codigos_hotel.setdefault(h["nombre"], set()).add(h["codigo"])
    cols = ["ciudad", "ida", "vuelta", "total", "ahora", "minimo", "al_guardar", "cambio_pct", "objetivo",
            "hotel", "objetivo_viaje", "viaje_ahora", "viaje_cambio_pct", "guardado"]
    ed = st.data_editor(
        t.sort_values("ida")[cols], hide_index=True, width="stretch", key="fav_vuelos_ed",
        disabled=[c for c in cols if c not in ("objetivo", "hotel", "objetivo_viaje")], column_config={
            "ahora": st.column_config.NumberColumn("Precio ahora", format="%.0f €"),
            "minimo": st.column_config.NumberColumn("Mínimo", format="%.0f €"),
            "al_guardar": st.column_config.NumberColumn("Al guardar", format="%.0f €"),
            "cambio_pct": st.column_config.NumberColumn("Cambio", format="%+.0f %%"),
            "objetivo": st.column_config.NumberColumn(
                "Objetivo €/pers.", min_value=0, format="%.0f €",
                help="Precio base por persona, ida+vuelta. Avisa cuando «Precio ahora» llegue a este valor o baje de él."),
            "hotel": st.column_config.SelectboxColumn(
                "Alojamiento", options=sorted(set(codigos_hotel) | set(t["hotel"].dropna()))),
            "objetivo_viaje": st.column_config.NumberColumn("Objetivo viaje €", min_value=0, format="%.0f €"),
            "viaje_ahora": st.column_config.NumberColumn("Viaje ahora", format="%.0f €"),
            "viaje_cambio_pct": st.column_config.NumberColumn("Cambio viaje", format="%+.0f %%"),
            "ciudad": "Destino",
            "ida": st.column_config.DateColumn("Ida", format="DD/MM/YY"),
            "vuelta": st.column_config.DateColumn("Vuelta", format="DD/MM/YY"),
            "total": st.column_config.NumberColumn("Guardado a", format="%d €"),
            "guardado": st.column_config.DatetimeColumn("Añadido", format="DD/MM/YY HH:mm")})
    st.caption("Escribe un objetivo en € por persona (ida+vuelta, sin maletas). Avisa al bajar de él. "
               "Con alojamiento, el viaje suma vuelo×personas + noches×habitaciones.")
    if any(h and lista[i]["codigo"] not in codigos_hotel.get(h, ()) for i, h in ed["hotel"].items()):
        st.caption("El alojamiento debe ser de la misma ciudad que el vuelo")
    num = lambda x: None if pd.isna(x) else float(x)
    cambios = False
    for i, r in ed.iterrows():
        nuevo = {"objetivo": num(r["objetivo"]), "objetivo_viaje": num(r["objetivo_viaje"]),
                 "hotel": r["hotel"] if isinstance(r["hotel"], str) and r["hotel"] else None}
        if nuevo["hotel"] != lista[i].get("hotel"):
            nuevo["viaje_guardado"] = datetime.now().isoformat()
        if any(lista[i].get(k) != v for k, v in nuevo.items()):
            lista[i].update(nuevo)
            cambios = True
    if cambios:
        guardar_favoritos(fav)
        st.rerun()
    c1, c2 = st.columns(2)
    with c1:
        if descargando("vuelos"):
            st.caption("Hay una descarga de vuelos en marcha; espera a que termine.")
        elif st.button("🔄 Actualizar precios de estos favoritos", type="primary",
                      key="fav_actualizar_vuelos"):
            pares = pares_vuelos_de((f["codigo"], f["ida"], f["vuelta"]) for f in lista)
            args = ["--salida", CSV, "--opciones", CSV_OPC, *args_pares(pares),
                   "--hilos", "4", "--velocidad", "1", "--velocidad-max", "4", "--actualizar", "0"]
            with st.spinner("Iniciando descarga…"):
                lanzar(args)
            st.session_state["aviso"] = ("⭐", f"Actualizando {len(lista)} favorito(s) de vuelos")
            st.rerun()
    with c2:
        etiquetas = {f"{f['ciudad']} · {pd.Timestamp(f['ida']):%d/%m/%y}→{pd.Timestamp(f['vuelta']):%d/%m/%y}": i
                     for i, f in enumerate(lista)}
        quitar = st.multiselect("Quitar de favoritos", list(etiquetas), key="quitar_fav_vuelos")
        if st.button("🗑️ Quitar seleccionados", disabled=not quitar, key="fav_quitar_vuelos"):
            idx = {etiquetas[e] for e in quitar}
            fav["vuelos"] = [f for i, f in enumerate(lista) if i not in idx]
            guardar_favoritos(fav)
            st.rerun()


def pag_favoritos_hoteles():
    titulo_pagina("⭐", "Favoritos de hoteles",
                  "Alojamientos concretos para volver a descargar solo esos, sin bajar toda la ciudad")
    fav = leer_favoritos()
    lista = fav["hoteles"]
    if not lista:
        st.info("Todavía no tienes alojamientos favoritos. Márcalos desde 🔎 Buscador.")
        return
    t = pd.DataFrame(lista)
    t["fecha_entrada"] = pd.to_datetime(t["fecha_entrada"])
    t["guardado"] = pd.to_datetime(t["guardado"])
    st.dataframe(t.sort_values("fecha_entrada")[["ciudad", "nombre", "fecha_entrada", "precio_noche",
                                                 "guardado"]],
                 hide_index=True, width="stretch", column_config={
                     "ciudad": "Ciudad", "nombre": "Alojamiento",
                     "fecha_entrada": st.column_config.DateColumn("Entrada", format="DD/MM/YY"),
                     "precio_noche": st.column_config.NumberColumn("Guardado a", format="%d €/noche"),
                     "guardado": st.column_config.DatetimeColumn("Añadido", format="DD/MM/YY HH:mm")})
    c1, c2 = st.columns(2)
    with c1:
        if descargando("hoteles"):
            st.caption("Hay una descarga de hoteles en marcha; espera a que termine.")
        elif st.button("🔄 Actualizar precios de estos favoritos", type="primary",
                      key="fav_actualizar_hoteles"):
            pares = pares_hoteles_de([(f["codigo"], f["fecha_entrada"]) for f in lista]
                                     + [(v["codigo"], n.date().isoformat()) for v in fav["vuelos"] if v.get("hotel")
                                        for n in pd.date_range(v["ida"], pd.Timestamp(v["vuelta"]) - timedelta(days=1))])
            args = ["--salida", CSV_HOT, *args_pares(pares), "--hilos", "4", "--velocidad", "1",
                   "--velocidad-max", "4", "--actualizar", "0"]
            with st.spinner("Iniciando descarga…"):
                lanzar(args, script=SCRIPT_HOT, tipo="hoteles")
            st.session_state["aviso"] = ("⭐", f"Actualizando {len(lista)} favorito(s) de hoteles")
            st.rerun()
    with c2:
        etiquetas = {f"{f['ciudad']} · {f['nombre']} · {pd.Timestamp(f['fecha_entrada']):%d/%m/%y}": i
                     for i, f in enumerate(lista)}
        quitar = st.multiselect("Quitar de favoritos", list(etiquetas), key="quitar_fav_hoteles")
        if st.button("🗑️ Quitar seleccionados", disabled=not quitar, key="fav_quitar_hoteles"):
            idx = {etiquetas[e] for e in quitar}
            fav["hoteles"] = [f for i, f in enumerate(lista) if i not in idx]
            guardar_favoritos(fav)
            st.rerun()


def pag_favoritos_todo():
    ejecutar_pestanas(["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles"], [pag_favoritos_vuelos, pag_favoritos_trenes, pag_favoritos_hoteles], "tabs_pag_favoritos_todo")


# ============================================================== TRENES (páginas)
COLS_TREN = {
    "ciudad": "Destino",
    "fecha": st.column_config.DateColumn("Fecha", format="DD/MM/YY"),
    "dia": "Día", "sentido": "Sentido", "hora_salida": "Sale", "hora_llegada": "Llega",
    "duracion_min": st.column_config.NumberColumn("Min", format="%d"),
    "compania": "Compañía", "tipo_tren": "Tipo", "tren": "Tren",
    "directo": st.column_config.CheckboxColumn("Directo"),
    "precio_eur": st.column_config.NumberColumn("Desde €", format="%d €"),
    "tarifa_min": "Tarifa", "precio_max": st.column_config.NumberColumn("Hasta €", format="%d €"),
    "tarifas": "Todas las tarifas", "plazas": st.column_config.NumberColumn("Plazas", format="%d"),
    "distancia_km": st.column_config.NumberColumn("km", format="%d"),
    "enlace": st.column_config.LinkColumn("Comprar", display_text="🚆 Ver"),
    "consulta": st.column_config.DatetimeColumn("Descargado", format="DD/MM HH:mm"),
}
SENTIDOS_TREN = {"ida": "Madrid → destino", "vuelta": "Destino → Madrid"}


def sin_trenes():
    if descargando("trenes"):
        st.info("⏳ Descargando los primeros trenes… Aparecerán aquí enseguida. Puedes ver el progreso en "
                "**⬇️ Descargas**.")
    else:
        st.info("Todavía no hay precios de tren. Ve a **⬇️ Descargas → 🚆 Trenes** para lanzar la primera descarga.")


def sin_resultados_tren():
    st.warning("No hay trenes con estos filtros. Prueba a ampliar fechas, destinos u horarios.")


def cabecera_tren(titulo, subtitulo=None):
    icono, _, texto = titulo.partition(" ")
    titulo_pagina(icono, texto, subtitulo)
    if not hay_trenes:
        return
    ft = F["ft"]
    chips = [("👥", f"{F['personas']} persona{'s' if F['personas'] > 1 else ''}"),
             ("📍", ", ".join(F["ciudades"]) if F["ciudades"] else "Todos los destinos"),
             ("🛫", "Cualquier fecha" if F["fecha_libre"]
              else f"{F['rango'][0]:%d/%m/%y} – {F['rango'][1]:%d/%m/%y}")]
    if not F["vuelta_libre"]:
        chips.append(("🛬", f"{F['rango_vuelta'][0]:%d/%m/%y} – {F['rango_vuelta'][1]:%d/%m/%y}"))
    if F.get("trayecto", "Ida y vuelta") != "Ida y vuelta":
        chips.append(("↔️", F["trayecto"]))
    if F["dias_sem"]:
        chips.append(("📅", ", ".join(d[:3] for d in F["dias_sem"])))
    if ft[0]:
        chips.append(("🚆", ", ".join(ft[0])))
    if ft[1]:
        chips.append(("🏷️", ", ".join(ft[1])))
    if len(ft) > 8 and ft[8]:
        chips.append(("🎟️", ", ".join(ft[8])))
    if len(ft) > 9 and ft[9] != "Cualquiera":
        chips.append(("🔁", ft[9]))
    if ft[5]:
        chips.append(("➡️", "Solo directos"))
    if ft[7]:
        chips.append(("💶", f"Máx. {ft[7]} € por tren"))
    if descargando("trenes"):
        chips.append(("⏳", "Datos parciales"))
    st.markdown('<div class="chips">' + "".join(
        f'<span class="chip"><b>{i}</b> {t}</span>' for i, t in chips) + "</div>", unsafe_allow_html=True)


def trenes_filtrados(respetar_trayecto=False):
    """Trenes con los filtros de 🚆 Tren y los del Viaje (destino, fechas, día de salida)."""
    t = cargar_trenes(mt_tren)
    if t.empty:
        return t
    t = filtro_trenes(t, F["ft"])
    if F["ciudades"]:
        t = t[t["ciudad"].isin(F["ciudades"])]
    ida = t["sentido"] == "ida"
    m = pd.Series(True, index=t.index)
    if not F["fecha_libre"]:
        m &= ~ida | t["fecha"].between(pd.Timestamp(F["rango"][0]), pd.Timestamp(F["rango"][1]))
    if not F["vuelta_libre"]:
        m &= ida | t["fecha"].between(pd.Timestamp(F["rango_vuelta"][0]), pd.Timestamp(F["rango_vuelta"][1]))
    if F["dias_sem"]:
        m &= ~ida | t["dia"].isin(F["dias_sem"])
    t = t[m]
    if respetar_trayecto and F.get("trayecto") == "Solo ida":
        t = t[t["sentido"] == "ida"]
    elif respetar_trayecto and F.get("trayecto") == "Solo vuelta":
        t = t[t["sentido"] == "vuelta"]
    return t


def _eje_fechas(fig, desde, hasta):
    """Un tick por día si el rango es corto (evita ticks repetidos a las 12:00)."""
    fig.update_xaxes(tickformat="%d %b")
    if (hasta - desde).days <= 14:
        fig.update_xaxes(dtick=86400000)


def tren_precios(t):
    """Solo trenes con plazas y precio."""
    return t[t["precio_eur"].notna()] if not t.empty else t


def tren_mejor_por(t, claves):
    """Fila del tren más barato de cada grupo."""
    p = tren_precios(t)
    if p.empty:
        return p
    return p.loc[p.groupby(claves)["precio_eur"].idxmin()]


def tren_combinaciones():
    """Ida + vuelta más baratas: el tren más barato de cada día emparejado con el de la vuelta
    de N días después (N = «Días de viaje» del filtro Viaje)."""
    t = trenes_filtrados()
    p = tren_precios(t)
    if p.empty:
        return pd.DataFrame()
    mj = tren_mejor_por(p, ["codigo", "sentido", "fecha"])
    cols = ["codigo", "ciudad", "fecha", "precio_eur", "compania", "tipo_tren", "hora_salida", "hora_llegada",
            "duracion_min"]
    a = mj[mj["sentido"] == "ida"][cols].rename(columns=lambda c: c + "_ida" if c not in ("codigo", "ciudad") else c)
    b = mj[mj["sentido"] == "vuelta"][cols].rename(columns=lambda c: c + "_vta" if c not in ("codigo", "ciudad") else c)
    c = a.merge(b, on=["codigo", "ciudad"])
    c["dias"] = (c["fecha_vta"] - c["fecha_ida"]).dt.days
    c = c[c["dias"].isin(F["noches"])]
    if c.empty:
        return c
    c["pp"] = c["precio_eur_ida"] + c["precio_eur_vta"]
    c["total"] = c["pp"] * F["personas"]
    c["dia_ida"] = c["fecha_ida"].dt.dayofweek.map(dict(enumerate(DIAS)))
    c["mes"] = c["fecha_ida"].dt.strftime("%Y-%m")
    if F["presupuesto"]:
        c = c[c["total"] <= F["presupuesto"]]
    return c.sort_values("total").reset_index(drop=True)


# ---------------------------------------------------------------- Resumen
def pag_trenes_resumen():
    cabecera_tren("🏠 Resumen de trenes")
    if not hay_trenes:
        return sin_trenes()
    t = trenes_filtrados()
    p = tren_precios(t)
    if p.empty:
        return sin_resultados_tren()
    m = p.loc[p["precio_eur"].idxmin()]
    k = st.columns(5)
    k[0].metric("Tren más barato", eur(m.precio_eur * F["personas"]),
                f"{m.ciudad} · {m.fecha:%d/%m} · {m.compania}", delta_color="off", delta_arrow="off")
    k[1].metric("Precio mediano", eur(p["precio_eur"].median() * F["personas"]))
    k[2].metric("Trenes", f"{len(t):,}".replace(",", "."))
    k[3].metric("Destinos", p["ciudad"].nunique())
    k[4].metric("Con plazas", f"{(t['disponible'] == 1).mean():.0%}")
    st.link_button(f"🚆 Comprar el más barato ({m.compania})",
                   m.enlace if isinstance(m.enlace, str) and m.enlace else "https://www.renfe.com",
                   type="primary")

    st.subheader("Mejor opción por destino")
    ida = tren_mejor_por(p[p["sentido"] == "ida"], ["ciudad"]).set_index("ciudad")
    vta = tren_mejor_por(p[p["sentido"] == "vuelta"], ["ciudad"]).set_index("ciudad")
    r = pd.DataFrame({
        "ida_eur": ida["precio_eur"], "ida_fecha": ida["fecha"], "ida_comp": ida["compania"],
        "vta_eur": vta["precio_eur"], "vta_fecha": vta["fecha"], "vta_comp": vta["compania"],
        "min_medios": p.groupby("ciudad")["duracion_min"].median(),
        "trenes_dia": t.groupby("ciudad").size() / t.drop_duplicates(["ciudad", "fecha", "sentido"])
        .groupby("ciudad").size()})
    r["ida_vuelta"] = (r["ida_eur"] + r["vta_eur"]) * F["personas"]
    r = r.reset_index().sort_values(["ida_vuelta", "ida_eur"])
    izq, der = st.columns([3, 2])
    with izq:
        st.dataframe(r[["ciudad", "ida_vuelta", "ida_eur", "ida_fecha", "ida_comp", "vta_eur", "vta_fecha",
                        "vta_comp", "min_medios", "trenes_dia"]],
                     hide_index=True, width="stretch", column_config={
                         "ciudad": "Destino",
                         "ida_vuelta": st.column_config.NumberColumn("Ida+vuelta €", format="%d €",
                                                                     help="Los dos trenes más baratos (cada uno en su día)"),
                         "ida_eur": st.column_config.NumberColumn("Ida €", format="%d €"),
                         "ida_fecha": st.column_config.DateColumn("Día ida", format="DD/MM/YY"),
                         "ida_comp": "Comp. ida",
                         "vta_eur": st.column_config.NumberColumn("Vuelta €", format="%d €"),
                         "vta_fecha": st.column_config.DateColumn("Día vuelta", format="DD/MM/YY"),
                         "vta_comp": "Comp. vuelta",
                         "min_medios": st.column_config.NumberColumn("Min (mediana)", format="%d"),
                         "trenes_dia": st.column_config.NumberColumn("Trenes/día", format="%.1f")})
    with der:
        r2 = r.assign(v=r["ida_vuelta"].fillna(r["ida_eur"] * F["personas"])).dropna(subset=["v"]).head(25)
        fig = px.bar(r2, x="v", y="ciudad", orientation="h", text="v", color="v",
                     color_continuous_scale=ESCALA_PRECIO, labels={"v": "€", "ciudad": ""})
        fig.update_traces(texttemplate="<b>%{text:.0f} €</b>", textposition="outside", cliponaxis=False,
                          textfont_color="#E8EAED" if es_oscuro() else "#202124",
                          hovertemplate="%{y}<br>%{x:.0f} €<extra></extra>")
        estilo(fig, alto=max(230, 34 * len(r2)), leyenda="no")
        fig.update_layout(coloraxis_showscale=False, yaxis=dict(autorange="reversed"),
                          xaxis=dict(showticklabels=False, title="", range=[0, r2["v"].max() * 1.2]),
                          bargap=.3, margin=dict(l=0, r=10, t=6, b=0))
        st.plotly_chart(fig, width="stretch")

    st.subheader("Precio mínimo por destino y mes")
    piv = p.assign(mes_txt=p["mes"].map(mes_legible)).pivot_table(
        index="ciudad", columns="mes_txt", values="precio_eur", aggfunc="min")
    piv = piv[sorted(piv.columns, key=lambda x: ORDEN_MES[x])]
    fig = px.imshow(piv, text_auto=".0f", color_continuous_scale=ESCALA_PRECIO, aspect="auto",
                    labels=dict(x="Mes", y="", color="€"))
    fig.update_xaxes(type="category", side="top", tickangle=0, showgrid=False)
    fig.update_traces(xgap=4, ygap=4, hovertemplate="%{y} · %{x}<br>%{z:.0f} €<extra></extra>")
    estilo(fig, alto=max(240, 34 * len(piv)), leyenda="no")
    fig.update_yaxes(showgrid=False, title="")
    st.plotly_chart(fig, width="stretch")

    st.subheader("Por compañía")
    g = (p.groupby(["compania", "tipo_tren"]).agg(trenes=("precio_eur", "size"), mediana=("precio_eur", "median"),
                                                  minimo=("precio_eur", "min"))
         .reset_index().sort_values("mediana"))
    st.dataframe(g, hide_index=True, width="stretch", column_config={
        "compania": "Compañía", "tipo_tren": "Tipo", "trenes": "Trenes",
        "mediana": st.column_config.NumberColumn("Mediana €", format="%d €"),
        "minimo": st.column_config.NumberColumn("Mínimo €", format="%d €")})
    st.caption("El precio es por persona y trayecto, la tarifa más barata con plazas de cada tren "
               "(Renfe: Básico/Elige…; Ouigo: Esencial). iryo no se consulta: exige navegador real.")


# ---------------------------------------------------------------- Buscador
def pag_trenes_buscador():
    cabecera_tren("🔎 Buscador de trenes")
    if not hay_trenes:
        return sin_trenes()
    t = trenes_filtrados(respetar_trayecto=True)
    if t.empty:
        return sin_resultados_tren()
    orden = st.segmented_control("Ordenar por", ["Precio", "Fecha", "Duración", "Hora de salida"],
                                 default="Precio", key="orden_tren")
    col = {"Precio": "precio_eur", "Fecha": "fecha", "Duración": "duracion_min",
           "Hora de salida": "salida_h"}.get(orden or "Precio")
    t = t.sort_values([col, "precio_eur"], na_position="last")
    t = t.assign(directo=t["directo"] == 1)
    cols = ["ciudad", "fecha", "dia", "sentido", "hora_salida", "hora_llegada", "duracion_min", "compania",
            "tipo_tren", "tren", "directo", "precio_eur", "tarifa_min", "precio_max", "tarifas", "plazas",
            "consulta", "enlace"]
    st.dataframe(t[cols].head(MAX_FILAS_TABLA), hide_index=True, width="stretch", height=620, row_height=34,
                 column_config=COLS_TREN)
    extra = f" (se muestran los {MAX_FILAS_TABLA} primeros)" if len(t) > MAX_FILAS_TABLA else ""
    st.caption(f"{len(t):,} trenes{extra}. Precio por persona y trayecto; los enlaces abren la web de la "
               "compañía (el precio puede haber cambiado desde la descarga).".replace(",", "."))
    st.download_button("💾 Exportar a CSV (Excel)",
                       t[cols].head(5000).to_csv(sep=";", decimal=",", index=False).encode("utf-8-sig"),
                       "trenes_filtrados.csv", "text/csv",
                       on_click=lambda: st.toast("Tabla exportada", icon="💾"))
    st.divider()
    base = tren_precios(t).head(100)
    opciones = {f"{r.ciudad} · {SENTIDOS_TREN[r.sentido]} · {r.fecha:%d/%m/%y} {r.hora_salida} · "
                f"{r.compania} · {r.precio_eur:.0f} €": (r.codigo, r.fecha.date().isoformat(), r.sentido,
                                                         r.ciudad, round(float(r.precio_eur)))
                for r in base.itertuples()}
    elegidos = st.multiselect("⭐ Marcar como favoritos (de los 100 primeros): se podrá volver a descargar solo "
                              "ese destino y día, sin bajar todo", list(opciones), key="elegir_fav_trenes")
    if st.button("⭐ Guardar como favoritos", disabled=not elegidos, key="guardar_fav_trenes"):
        fav = leer_favoritos()
        existentes = {(f["codigo"], f["fecha"], f["sentido"]) for f in fav["trenes"]}
        n = 0
        for e in elegidos:
            cod, fecha_s, sentido, ciudad, precio = opciones[e]
            if (cod, fecha_s, sentido) not in existentes:
                fav["trenes"].append({"codigo": cod, "ciudad": ciudad, "fecha": fecha_s, "sentido": sentido,
                                      "precio": precio, "guardado": datetime.now().isoformat()})
                existentes.add((cod, fecha_s, sentido))
                n += 1
        guardar_favoritos(fav)
        st.session_state["aviso"] = ("⭐", f"{n} favorito(s) nuevo(s) guardado(s)" if n else "Ya estaban guardados")
        st.rerun()


# ---------------------------------------------------------------- Favoritos
def pag_favoritos_trenes():
    titulo_pagina("⭐", "Favoritos de trenes",
                  "Destinos y días concretos para volver a descargar solo esos, sin bajar todo")
    fav = leer_favoritos()
    lista = fav["trenes"]
    if not lista:
        st.info("Todavía no tienes trenes favoritos. Márcalos desde 🔎 Buscador.")
        return
    t = pd.DataFrame(lista)
    t["fecha"] = pd.to_datetime(t["fecha"])
    t["guardado"] = pd.to_datetime(t["guardado"])
    t["trayecto"] = t["sentido"].map(SENTIDOS_TREN)
    st.dataframe(t.sort_values("fecha")[["ciudad", "trayecto", "fecha", "precio", "guardado"]],
                 hide_index=True, width="stretch", column_config={
                     "ciudad": "Destino", "trayecto": "Trayecto",
                     "fecha": st.column_config.DateColumn("Día", format="DD/MM/YY"),
                     "precio": st.column_config.NumberColumn("Guardado a", format="%d €"),
                     "guardado": st.column_config.DatetimeColumn("Añadido", format="DD/MM/YY HH:mm")})
    c1, c2 = st.columns(2)
    with c1:
        if descargando("trenes"):
            st.caption("Hay una descarga de trenes en marcha; espera a que termine.")
        elif st.button("🔄 Actualizar precios de estos favoritos", type="primary", key="fav_actualizar_trenes"):
            pares = pares_trenes_de((f["codigo"], f["fecha"], f["sentido"]) for f in lista)
            args = ["--salida", CSV_TREN, *args_pares(pares), "--actualizar", "0"]
            with st.spinner("Iniciando descarga…"):
                lanzar(args, script=SCRIPT_TREN, tipo="trenes", n=len(pares))
            st.session_state["aviso"] = ("⭐", f"Actualizando {len(lista)} favorito(s) de trenes")
            st.rerun()
    with c2:
        etiquetas = {f"{f['ciudad']} · {SENTIDOS_TREN.get(f['sentido'], f['sentido'])} · "
                     f"{pd.Timestamp(f['fecha']):%d/%m/%y}": i for i, f in enumerate(lista)}
        quitar = st.multiselect("Quitar de favoritos", list(etiquetas), key="quitar_fav_trenes")
        if st.button("🗑️ Quitar seleccionados", disabled=not quitar, key="fav_quitar_trenes"):
            idx = {etiquetas[e] for e in quitar}
            fav["trenes"] = [f for i, f in enumerate(lista) if i not in idx]
            guardar_favoritos(fav)
            st.rerun()


# ---------------------------------------------------------------- Evolución
def pag_trenes_evolucion():
    cabecera_tren("📈 Evolución del precio de tren")
    if not hay_trenes:
        return sin_trenes()
    t = tren_precios(trenes_filtrados())
    if t.empty:
        return sin_resultados_tren()
    sent = st.radio("Trayecto", list(SENTIDOS_TREN), format_func=SENTIDOS_TREN.get, horizontal=True,
                    key="evo_tren_sent")
    s = t[t["sentido"] == sent]
    if s.empty:
        return sin_resultados_tren()
    color = "ciudad" if s["ciudad"].nunique() > 1 else "compania"
    g = s.groupby(["fecha", color], as_index=False)["precio_eur"].min()
    fig = px.line(g, x="fecha", y="precio_eur", color=color, markers=len(g) < 150,
                  color_discrete_sequence=COLORES,
                  labels={"fecha": "", "precio_eur": "Tren más barato (€/persona)", color: ""})
    fig.update_traces(line_width=2.2, marker_size=5, hovertemplate="%{y:.0f} €<extra>%{fullData.name}</extra>")
    estilo(fig, alto=460)
    _eje_fechas(fig, g["fecha"].min(), g["fecha"].max())
    fig.update_layout(hovermode="x unified")
    st.plotly_chart(fig, width="stretch")
    st.caption("Para cada día, el tren más barato con los filtros actuales.")
    st.subheader("Por día de la semana")
    d = s.groupby(["dia"] + (["ciudad"] if color == "ciudad" else []), as_index=False)["precio_eur"].median()
    d["orden"] = d["dia"].map({x: i for i, x in enumerate(DIAS)})
    fig = px.bar(d.sort_values("orden"), x="dia", y="precio_eur", color="ciudad" if color == "ciudad" else None,
                 barmode="group", color_discrete_sequence=COLORES,
                 labels={"dia": "", "precio_eur": "Precio mediano (€)", "ciudad": ""})
    estilo(fig, alto=320, leyenda="arriba" if color == "ciudad" else "no")
    fig.update_layout(bargap=.3)
    st.plotly_chart(fig, width="stretch")

    st.subheader("Cómo ha cambiado el precio de un día concreto")
    h = leer_historico_trenes(mtime(CSV_TREN_HIST))
    if h.empty:
        st.caption("Todavía no hay histórico: aparece tras descargar el mismo día más de una vez.")
        return
    c1, c2, c3 = st.columns(3)
    ciu = c1.selectbox("Destino", sorted(h["ciudad"].unique()), key="evo_tren_ciu")
    hs = h[(h["ciudad"] == ciu) & (h["sentido"] == sent)]
    n_cons = hs.assign(d=hs["consulta"].dt.date).groupby("fecha")["d"].nunique()
    fechas = [f.date() for f in n_cons[n_cons > 1].index] or [f.date() for f in n_cons.index]
    fechas = sorted(fechas)
    if not fechas:
        return st.caption("Sin histórico para ese destino y sentido.")
    dia = c2.selectbox("Día del viaje", fechas, key="evo_tren_dia", format_func=lambda x: f"{x:%d/%m/%Y}")
    hd = hs[hs["fecha"].dt.date == dia]
    trenes = sorted((hd["compania"] + " " + hd["hora_salida"]).unique())
    sel = c3.multiselect("Trenes", trenes, default=trenes[:6], key="evo_tren_trenes")
    hd = hd.assign(tren_txt=hd["compania"] + " " + hd["hora_salida"])
    hd = hd[hd["tren_txt"].isin(sel)]
    if hd.empty:
        return
    fig = px.line(hd.sort_values("consulta"), x="consulta", y="precio_eur", color="tren_txt", markers=True,
                  color_discrete_sequence=COLORES, labels={"consulta": "", "precio_eur": "€", "tren_txt": ""})
    estilo(fig, alto=380)
    fig.update_layout(hovermode="x unified")
    st.plotly_chart(fig, width="stretch")


# ---------------------------------------------------------------- Calendario
def pag_trenes_calendario():
    cabecera_tren("🗓️ Calendario de trenes")
    if not hay_trenes:
        return sin_trenes()
    t = tren_precios(trenes_filtrados())
    if t.empty:
        return sin_resultados_tren()
    sent = st.radio("Trayecto", list(SENTIDOS_TREN), format_func=SENTIDOS_TREN.get, horizontal=True,
                    key="cal_tren_sent")
    s = t[t["sentido"] == sent]
    if s.empty:
        return sin_resultados_tren()
    cal = s.groupby("fecha", as_index=False).agg(precio=("precio_eur", "min"))
    cal["semana"] = cal["fecha"] - pd.to_timedelta(cal["fecha"].dt.dayofweek, unit="D")
    cal["dia_s"] = cal["fecha"].dt.dayofweek.map(dict(enumerate(CORTO)))
    piv = cal.pivot_table(index="dia_s", columns="semana", values="precio", aggfunc="min").reindex(CORTO)
    fig = px.imshow(piv, color_continuous_scale=ESCALA_PRECIO, aspect="auto",
                    labels=dict(x="Semana (lunes)", y="", color="€"))
    fig.update_xaxes(tickformat="%d %b", showgrid=False)
    fig.update_traces(xgap=3, ygap=3, hovertemplate="%{y} · semana del %{x|%d %b}<br>%{z:.0f} €<extra></extra>")
    estilo(fig, alto=320, leyenda="no")
    fig.update_yaxes(showgrid=False, title="")
    st.plotly_chart(fig, width="stretch")
    st.caption("Verde = más barato. Cada celda es el tren más barato de ese día (entre los destinos elegidos).")


# ---------------------------------------------------------------- Mapa
def pag_trenes_mapa():
    cabecera_tren("🗺️ Mapa de trenes")
    if not hay_trenes:
        return sin_trenes()
    t = tren_precios(trenes_filtrados())
    if t.empty:
        return sin_resultados_tren()
    sent = st.radio("Trayecto", list(SENTIDOS_TREN), format_func=SENTIDOS_TREN.get, horizontal=True,
                    key="mapa_tren_sent")
    pr = t[t["sentido"] == sent].groupby(["ciudad", "codigo"], as_index=False).agg(
        precio=("precio_eur", "min"), minutos=("duracion_min", "median"))
    pr = pr[pr["codigo"].isin(TREN_COORDS)]
    if pr.empty:
        return sin_resultados_tren()
    pr["lat"] = pr["codigo"].map(lambda c: TREN_COORDS[c][0])
    pr["lon"] = pr["codigo"].map(lambda c: TREN_COORDS[c][1])
    fig = go.Figure()
    fig.add_trace(go.Scattermap(
        lat=pr["lat"], lon=pr["lon"], mode="markers+text",
        marker=dict(size=14, color=pr["precio"], colorscale=ESCALA_PRECIO,
                    colorbar=dict(title="€", thickness=10)),
        text=pr["ciudad"], textposition="top center",
        hovertext=pr["ciudad"] + "<br>desde " + pr["precio"].round(0).astype(int).astype(str) + " €"
        + "<br>~" + pr["minutos"].fillna(0).round(0).astype(int).astype(str) + " min",
        hoverinfo="text", name="Destinos"))
    fig.add_trace(go.Scattermap(lat=[MADRID_COORDS[0]], lon=[MADRID_COORDS[1]], mode="markers+text",
                                marker=dict(size=16, color="#202124"), text=["Madrid"],
                                textposition="bottom center", hoverinfo="text", name="Madrid"))
    fig.update_layout(map=dict(style="open-street-map", center=dict(lat=40.0, lon=-3.7), zoom=4.8),
                      height=600, margin=dict(l=0, r=0, t=0, b=0), showlegend=False)
    st.plotly_chart(fig, width="stretch")
    st.caption("Cada punto es una estación, coloreada por el tren más barato con tus filtros.")


# ---------------------------------------------------------------- Distribución
def pag_trenes_distribucion():
    cabecera_tren("📊 Distribución de precios de tren")
    if not hay_trenes:
        return sin_trenes()
    t = tren_precios(trenes_filtrados(respetar_trayecto=True))
    if t.empty:
        return sin_resultados_tren()
    c1, c2 = st.columns(2)
    color = c1.selectbox("Color", ["Compañía", "Tipo de tren", "Sentido", "Sin color"], key="dis_tren_color")
    col = {"Compañía": "compania", "Tipo de tren": "tipo_tren", "Sentido": "sentido", "Sin color": None}[color]
    y = c2.selectbox("Comparar precio con", ["Duración (min)", "Antelación (días)", "Hora de salida"],
                     key="dis_tren_y")
    eje = {"Duración (min)": "duracion_min", "Antelación (días)": "antelacion", "Hora de salida": "salida_h"}[y]
    fig = hist_ligero(t, "precio_eur", 50, color=col, color_discrete_sequence=COLORES, barmode="overlay",
                       opacity=.75, labels={"precio_eur": "Precio (€/persona)", "count": "Trenes"})
    estilo(fig, alto=360, leyenda="arriba" if col else "no")
    st.plotly_chart(fig, width="stretch")
    m = t.dropna(subset=[eje])
    if len(m) > 6000:
        m = m.sample(6000, random_state=1)
    fig = px.scatter(m, x=eje, y="precio_eur", color=col, opacity=.55, color_discrete_sequence=COLORES,
                     hover_data=["ciudad", "fecha", "hora_salida", "compania"],
                     labels={eje: y, "precio_eur": "Precio (€/persona)"})
    estilo(fig, alto=420, leyenda="arriba" if col else "no")
    st.plotly_chart(fig, width="stretch")
    st.subheader("Por destino")
    orden = t.groupby("ciudad")["precio_eur"].median().sort_values().index.tolist()
    fig = px.box(t, x="ciudad", y="precio_eur", color=col, category_orders={"ciudad": orden},
                 color_discrete_sequence=COLORES, labels={"ciudad": "", "precio_eur": "€/persona"})
    estilo(fig, alto=440, leyenda="arriba" if col else "no")
    st.plotly_chart(fig, width="stretch")
    st.caption("Cada punto es un tren concreto en un día, con su dato más reciente.")


def pag_trenes_antelacion():
    cabecera_tren("📉 Antelación de compra (tren)")
    if not hay_trenes:
        return sin_trenes()
    t = tren_precios(trenes_filtrados(respetar_trayecto=True))
    if t.empty:
        return sin_resultados_tren()
    st.subheader("Precio según los días que faltan para el viaje")
    g = t.assign(rango=pd.cut(t["antelacion"], [-1, 2, 6, 13, 20, 30, 45, 60, 90, 400],
                              labels=["0-2", "3-6", "7-13", "14-20", "21-30", "31-45", "46-60", "61-90", "90+"]))
    g = g.groupby(["rango", "compania"], observed=True).agg(mediana=("precio_eur", "median"),
                                                              trenes=("precio_eur", "size")).reset_index()
    fig = px.bar(g, x="rango", y="mediana", color="compania", barmode="group", color_discrete_sequence=COLORES,
                 labels={"rango": "Días que faltan para salir", "mediana": "Precio mediano (€)", "compania": ""})
    estilo(fig, alto=360)
    fig.update_layout(bargap=.25)
    st.plotly_chart(fig, width="stretch")
    st.caption("Foto de hoy: cada barra mezcla destinos distintos, así que sirve para ver la tendencia "
               "general (¿los trenes cercanos son más caros?). Con histórico, abajo se ve el mismo tren a lo largo del tiempo.")
    h = leer_historico_trenes(mtime(CSV_TREN_HIST))
    if h.empty:
        return st.info("Todavía no hay histórico: repite la descarga en días distintos para ver cómo sube el precio.")
    h = h[h["ciudad"].isin(t["ciudad"].unique())]
    h["antel"] = (h["fecha"] - h["consulta"].dt.normalize()).dt.days
    clave = ["codigo", "sentido", "fecha", "compania", "hora_salida"]
    h["minimo"] = h.groupby(clave)["precio_eur"].transform("min")
    h = h[h.groupby(clave)["consulta"].transform("nunique") >= 2]
    if h.empty:
        return st.info("Aún no hay trenes consultados en dos momentos distintos.")
    h["indice"] = h["precio_eur"] / h["minimo"]
    h["rango"] = pd.cut(h["antel"], [-1, 2, 6, 13, 20, 30, 45, 60, 90, 400],
                        labels=["0-2", "3-6", "7-13", "14-20", "21-30", "31-45", "46-60", "61-90", "90+"])
    a = h.groupby("rango", observed=True).agg(indice=("indice", "median"), obs=("indice", "size")).reset_index()
    st.subheader("Cuánto más caro que su mínimo, según la antelación (mismo tren)")
    fig = px.bar(a, x="rango", y="indice", text="obs", labels={"rango": "Días que faltan", "indice": "Precio / mínimo"})
    fig.update_traces(marker_color=COLORES[0], texttemplate="%{text} obs.", textposition="outside")
    estilo(fig, alto=340, leyenda="no")
    fig.update_yaxes(tickformat=".2f")
    st.plotly_chart(fig, width="stretch")
    st.caption("1,00 = el precio más bajo que ha tenido ese tren. Más de 1,00 = más caro que su mejor momento.")


# ---------------------------------------------------------------- Equipaje y tarifas
def pag_trenes_equipaje():
    titulo_pagina("🧳", "Equipaje y tarifas de tren", "Qué incluye cada compañía y cuánto cuesta subir de tarifa")
    st.dataframe(TARIFAS_TREN_INFO, hide_index=True, width="stretch", column_config={
        "compania": "Compañía", "tarifa": "Tarifa", "equipaje": "Equipaje incluido", "extra": "Equipaje extra",
        "cambios": "Cambios", "reembolso": "Reembolso", "fiabilidad": "Fiabilidad",
        "enlace": st.column_config.LinkColumn("Comprobar", display_text="Abrir ↗")})
    st.caption(f"Condiciones orientativas (revisadas {TARIFAS_REVISADO}); revísalas al comprar con el enlace de cada compañía. "
               "A diferencia del avión, Renfe incluye equipaje en todas las tarifas y Ouigo lleva cabina en la básica.")
    if not hay_trenes:
        return sin_trenes()
    t = cargar_trenes(mt_tren)
    t = t[(t["disponible"] == 1) & t["tarifas"].notna()]
    if t.empty:
        return
    filas = []
    for r in t[["compania", "tarifas"]].itertuples(index=False):
        for trozo in r.tarifas.split(" | "):
            nombre, _, precio = trozo.rpartition(" ")
            try:
                filas.append((r.compania, nombre, float(precio)))
            except ValueError:
                continue
    f = pd.DataFrame(filas, columns=["compania", "tarifa", "precio"])
    g = f.groupby(["compania", "tarifa"]).agg(trenes=("precio", "size"), mediana=("precio", "median"),
                                               minimo=("precio", "min")).reset_index()
    st.subheader("Precio de cada tarifa en tus datos")
    st.dataframe(g.sort_values(["compania", "mediana"]), hide_index=True, width="stretch", column_config={
        "compania": "Compañía", "tarifa": "Tarifa", "trenes": "Trenes",
        "mediana": st.column_config.NumberColumn("Mediana €", format="%d €"),
        "minimo": st.column_config.NumberColumn("Mínimo €", format="%d €")})
    fig = px.bar(g[g["trenes"] >= 5], x="tarifa", y="mediana", color="compania", barmode="group",
                 color_discrete_sequence=COLORES, labels={"tarifa": "", "mediana": "Precio mediano (€)", "compania": ""})
    estilo(fig, alto=340)
    st.plotly_chart(fig, width="stretch")


# ---------------------------------------------------------------- Gestión de datos
def pag_gestion_datos_trenes():
    titulo_pagina("🗄️", "Gestión de datos", "Cuánto se ha descargado cada día y cuánto pesa")
    st.subheader("Tamaño de los archivos")
    archivos = [(CSV_TREN, "Trenes (precios)"), (CSV_TREN_HIST, "Histórico de precios de tren"),
                (ESTADO_TREN, "Estado de Ouigo (destinos con servicio)")]
    filas = [{"Archivo": et, "Tamaño": tamano_legible(tamano_bytes(r))} for r, et in archivos if os.path.exists(r)]
    st.dataframe(pd.DataFrame(filas), hide_index=True, width="stretch")
    st.metric("Total en disco", tamano_legible(sum(tamano_bytes(r) for r, _ in archivos)))
    h = leer_historico_trenes(mtime(CSV_TREN_HIST))
    if h.empty:
        st.info("Todavía no hay histórico de descargas de trenes.")
    else:
        h = h.assign(dia=h["consulta"].dt.date)
        por_dia = h.groupby("dia").agg(filas=("codigo", "size"), destinos=("codigo", "nunique")).reset_index()
        hoy = date.today()
        fh = por_dia[por_dia["dia"] == hoy]
        c1, c2 = st.columns(2)
        c1.metric("Precios guardados hoy", f"{int(fh['filas'].iloc[0]):,}".replace(",", ".") if not fh.empty else "0")
        c2.metric("Destinos distintos hoy", int(fh["destinos"].iloc[0]) if not fh.empty else 0)
        st.subheader("Descargas por día")
        fig = px.bar(por_dia.sort_values("dia"), x="dia", y="filas", labels={"dia": "", "filas": "Precios"})
        fig.update_traces(marker_color=COLORES[0])
        estilo(fig, alto=280, leyenda="no")
        st.plotly_chart(fig, width="stretch")
        st.dataframe(por_dia.sort_values("dia", ascending=False), hide_index=True, width="stretch",
                     column_config={"dia": st.column_config.DateColumn("Día", format="DD/MM/YY"),
                                    "filas": "Precios", "destinos": "Destinos distintos"})
        st.subheader("Reducir el histórico")
        st.caption("`historico_trenes.csv` guarda un precio por tren y consulta. Puedes recortar lo más antiguo a "
                   "una fila por tren y día; lo reciente se deja intacto.")
        dias_m, dias_ret = politica_historico()
        if st.button(f"🗜️ Comprimir histórico de trenes anterior a {dias_m} días"):
            with st.spinner("Comprimiendo histórico de trenes…"):
                n0, n1 = comprimir_historico(CSV_TREN_HIST, dias_m,
                                             ["codigo", "sentido", "fecha", "compania", "hora_salida"], dias_ret)
            leer_historico_trenes.clear()
            st.toast(f"Histórico comprimido: {n0:,} → {n1:,} filas".replace(",", "."), icon="🗜️")
            st.rerun()
    est = _leer_json(ESTADO_TREN, {})
    with st.expander("🚆 Destinos con Ouigo"):
        st.write("Ouigo no llega a todas las estaciones. La app lo aprende sola: si tras 4 días seguidos no "
                 "hay ningún tren Ouigo a un destino (y nunca lo hubo), deja de consultarlo.")
        nombres = destinos_tren()
        st.write("**Con servicio:** " + (", ".join(nombres.get(c, c) for c in est.get("ouigo_ok", [])) or "—"))
        st.write("**Sin servicio (no se consulta):** "
                 + (", ".join(nombres.get(c, c) for c in est.get("ouigo_sin", [])) or "—"))
        if st.button("↩️ Volver a probar Ouigo en todos los destinos", key="reset_ouigo",
                     disabled=not est.get("ouigo_sin")):
            est["ouigo_sin"], est["ouigo_vacios"] = [], {}
            _escribir_json(ESTADO_TREN, est)
            st.rerun()


# ---------------------------------------------------------------- Descargas
def pares_trenes_de(filas):
    """filas: iterable de (codigo, fecha, sentido). Pares 'CODIGO:FECHA:SENTIDO' para --pares."""
    vistos, pares = set(), []
    for cod, fecha, sentido in filas:
        f = pd.Timestamp(fecha).date().isoformat()
        if (cod, f, sentido) not in vistos:
            vistos.add((cod, f, sentido))
            pares.append(f"{cod}:{f}:{sentido}")
    return pares


def existentes_trenes():
    return claves_trenes(mt_tren) if mt_tren else set()


def universo_trenes(sel, dias, sentidos):
    manana = date.today() + timedelta(days=1)
    fechas = [(manana + timedelta(days=k)).isoformat() for k in range(int(dias))]
    return {(c, f, s) for c in sel for f in fechas for s in sentidos}


def universo_trenes_filtrado(sel, dias, sentidos):
    """Filtros del Buscador aplicables a trenes aún sin descargar: destino, fechas, día de salida y días de viaje."""
    cods = [c for c, n in destinos_tren().items() if n in set(F["ciudades"])] if F["ciudades"] else list(sel)
    manana = date.today() + timedelta(days=1)
    fin = manana + timedelta(days=int(dias) - 1)
    noches = tuple(F["noches"]) or (1,)
    i0, i1 = (manana, fin) if F["fecha_libre"] else (max(F["rango"][0], manana), min(F["rango"][1], fin))
    v0, v1 = (manana, fin + timedelta(days=max(noches))) if F["vuelta_libre"] else (
        max(F["rango_vuelta"][0], manana), F["rango_vuelta"][1])
    tray = F.get("trayecto", "Ida y vuelta")
    pares = set()
    d = i0
    while d <= i1:
        if not F["dias_sem"] or DIAS[d.weekday()] in F["dias_sem"]:
            if tray == "Solo ida":
                pares |= {(c, d.isoformat(), "ida") for c in cods}
            elif tray != "Solo vuelta":
                for n in noches:
                    v = d + timedelta(days=n)
                    if v0 <= v <= v1:
                        for c in cods:
                            pares.add((c, d.isoformat(), "ida"))
                            pares.add((c, v.isoformat(), "vuelta"))
        d += timedelta(days=1)
    if tray == "Solo vuelta":
        d = max(v0, manana)
        while d <= min(v1, fin):
            pares |= {(c, d.isoformat(), "vuelta") for c in cods}
            d += timedelta(days=1)
    return {p for p in pares if p[2] in sentidos}


def descargas_trenes():
    """Descarga de trenes: 4 modos de un clic (todo / solo lo nuevo, con o sin filtros)."""
    if not os.path.exists(SCRIPT_TREN):
        return st.info(f"Falta {SCRIPT_TREN} en la carpeta de la app.")
    cfg = leer_config()
    todos = destinos_tren()
    nombre = lambda k: f"{todos.get(k, k)}"
    en_curso = descargando("trenes")
    SEG = 1.5
    with st.container(border=True):
        st.markdown("**Destinos y días**")
        grupos = grupos_tren()
        st.session_state.setdefault("td_destinos", [k for k in cfg.get("trenes_destinos", list(todos)) if k in todos])
        sel = st.multiselect("Destinos", list(todos), format_func=nombre, key="td_destinos")
        if grupos:
            g1, g2, g3 = st.columns([3, 1, 1])
            elegidos = g1.multiselect("Zonas", list(grupos), key="td_grupos", placeholder="Añadir o quitar zonas enteras",
                                      format_func=lambda g: f"{g} ({len(grupos[g])})")
            cods_g = [c for g in elegidos for c in grupos[g]]

            def _anadir():
                st.session_state["td_destinos"] = sorted(set(st.session_state["td_destinos"]) | set(cods_g),
                                                         key=list(todos).index)

            def _quitar():
                st.session_state["td_destinos"] = [c for c in st.session_state["td_destinos"] if c not in cods_g]
            g2.button("➕ Añadir", width="stretch", on_click=_anadir, disabled=not elegidos, key="td_g_add")
            g3.button("➖ Quitar", width="stretch", on_click=_quitar, disabled=not elegidos, key="td_g_del")
            st.caption(f"{len(sel)} de {len(todos)} destinos seleccionados.")
        c1, c2 = st.columns([3, 2])
        dias = c1.slider("Días hacia delante", 7, 180, int(cfg.get("trenes_dias", 60)), step=7, key="td_dias",
                         help="Renfe suele abrir la venta con 2–6 meses de antelación; más allá no hay trenes.")
        sentidos = c2.multiselect("Sentidos", ["ida", "vuelta"], default=["ida", "vuelta"], key="td_sent",
                                  format_func=SENTIDOS_TREN.get)
        vel_args = selector_velocidad_th("trenes", "td_vel")
        n_todo = len(sel) * dias * len(sentidos)
        seg_ef = seg_previo("trenes") or SEG
        st.caption(f"{n_todo:,}".replace(",", ".") + " consultas en total (cada una pregunta a Renfe y a Ouigo a la vez) · "
                   f"~{dur(int(n_todo * seg_ef / 60)) if n_todo else '0 min'}"
                   + (" según tus últimas descargas" if seg_previo("trenes") else " a ritmo prudente"))

    bloqueado = en_curso or not sel or not sentidos
    base = ["--salida", CSV_TREN, *vel_args]
    sent_args = ["--sentidos", *sentidos]
    with st.container(border=True):
        st.markdown("**Descargar**")
        if en_curso:
            st.caption("⏳ Hay una descarga de trenes en curso: los botones se activan cuando termine (o si la "
                       "detienes). Mientras tanto puedes usar toda la app.")
        st.caption("«Con filtros» usa los filtros del Buscador (barra lateral) → " + resumen_filtros_descarga(sel, hoteles=False))
        b1, b2 = st.columns(2)
        b3, b4 = st.columns(2)
        if b1.button("📦 Descargar todo", type="primary", width="stretch", key="dl_t_todo", disabled=bloqueado,
                     help="Vuelve a bajar TODOS los trenes de los destinos y días elegidos, estén o no ya descargados."):
            guardar_config(trenes_destinos=sel, trenes_dias=dias)
            confirmar_descarga(["--destinos", *sel, "--dias", str(dias), *sent_args, *base, "--actualizar", "0"],
                               n_todo, sel, seg=SEG, script=SCRIPT_TREN, tipo="trenes")
        b1.caption(f"{n_todo:,} consultas".replace(",", "."))
        if b2.button("🎯 Descargar todo con filtros", width="stretch", key="dl_t_todo_f",
                     disabled=bloqueado or not hay_trenes,
                     help="Vuelve a bajar los destinos y días que ves ahora mismo en el Buscador (con sus filtros)."):
            t_f = trenes_filtrados()
            if t_f.empty:
                st.toast("No hay trenes con los filtros actuales", icon="⚠️")
            else:
                pares = pares_trenes_de((r.codigo, r.fecha, r.sentido)
                                        for r in t_f[["codigo", "fecha", "sentido"]].drop_duplicates().itertuples())
                confirmar_descarga([*base, *args_pares(pares), "--actualizar", "0"], len(pares),
                                   sorted(t_f["codigo"].unique()), seg=SEG, script=SCRIPT_TREN, tipo="trenes")
        b2.caption("Lo que ves en el Buscador, refrescado")
        if b3.button("🆕 Descargar solo lo nuevo", width="stretch", key="dl_t_nuevo", disabled=bloqueado,
                     help="Solo los destinos y días que todavía no están descargados. No toca lo que ya tienes."):
            with st.spinner("Calculando lo que falta…"):
                nuevos = universo_trenes(sel, dias, sentidos) - existentes_trenes()
            if not nuevos:
                st.toast("Ya está todo descargado con esas opciones", icon="✅")
            else:
                guardar_config(trenes_destinos=sel, trenes_dias=dias)
                confirmar_descarga(["--destinos", *sel, "--dias", str(dias), *sent_args, *base], len(nuevos),
                                   sorted({c for c, _, _ in nuevos}), seg=SEG, script=SCRIPT_TREN, tipo="trenes")
        b3.caption("Lo que falta, sin repetir nada")
        if b4.button("🆕 Descargar solo lo nuevo con filtros", width="stretch", key="dl_t_nuevo_f", disabled=bloqueado,
                     help="Lo que falta dentro de los filtros del Buscador aplicables a trenes aún sin descargar: "
                          "destino, fechas, día de salida y días de viaje."):
            with st.spinner("Calculando lo que falta con esos filtros…"):
                nuevos = universo_trenes_filtrado(sel, dias, sentidos) - existentes_trenes()
            if not nuevos:
                st.toast("No falta nada dentro de esos filtros", icon="✅")
            else:
                pares = pares_trenes_de(sorted(nuevos))
                confirmar_descarga([*base, *args_pares(pares)], len(pares), sorted({c for c, _, _ in nuevos}),
                                   seg=SEG, script=SCRIPT_TREN, tipo="trenes")
        b4.caption("Lo que falta dentro de tus filtros")
    bloque_region("dl_t", grupos_tren(), dias, len(sentidos) or 1, en_curso,
                  lambda cods, n: confirmar_descarga(["--destinos", *cods, "--dias", str(dias), *sent_args, *base,
                                                      "--actualizar", "0"], n, cods, seg=SEG,
                                                     script=SCRIPT_TREN, tipo="trenes"))

    with st.expander("⚙️ Otros modos: refrescar lo antiguo, solo el próximo mes"):
        modo = st.radio("Qué descargar", ["Refrescar lo de hace más de 24 h", "Solo el próximo mes (refrescar)"],
                        key="td_modo")
        if st.button("Descargar con este modo", key="dl_t_otro", disabled=bloqueado):
            guardar_config(trenes_destinos=sel, trenes_dias=dias)
            args = ["--destinos", *sel, *sent_args, *base]
            if modo.startswith("Refrescar"):
                args += ["--dias", str(dias), "--actualizar", "24"]
                n = n_todo
            else:
                args += ["--dias", "30", "--actualizar", "0"]
                n = len(sel) * 30 * len(sentidos)
            confirmar_descarga(args, n, sel, seg=SEG, script=SCRIPT_TREN, tipo="trenes")
    st.caption("ℹ️ Fuentes: Renfe (venta.renfe.com) y Ouigo (API pública de su web). Son gratuitas y no necesitan "
               "clave, pero Renfe tarda ~3 s por consulta: la primera descarga completa puede llevar un rato.")


# ============================================================== MAPA · RECORRIDO (tren y vuelo)
RUTAS_TREN = os.path.join(BASE, "rutas_tren.json")
OPENRAIL = ("https://routing.openrailrouting.org/route?point={},{}&point={},{}"
            "&profile=all_tracks&points_encoded=false")


def _km_ruta(lat, lon):
    """Kilómetros acumulados a lo largo de una polilínea (haversine)."""
    lat, lon = np.radians(np.asarray(lat, float)), np.radians(np.asarray(lon, float))
    a = (np.sin(np.diff(lat) / 2) ** 2
         + np.cos(lat[:-1]) * np.cos(lat[1:]) * np.sin(np.diff(lon) / 2) ** 2)
    return np.concatenate([[0], np.cumsum(2 * 6371 * np.arcsin(np.sqrt(a)))])


def ruta_tren(codigo):
    """Trazado por vía Madrid → estación (OpenRailRouting + OpenStreetMap, gratis). Se guarda en
    rutas_tren.json para no repetir la consulta. Devuelve (lat[], lon[], km, es_real)."""
    cache = _leer_json(RUTAS_TREN, {})
    if codigo in cache:
        p = cache[codigo]
        return [x[0] for x in p["p"]], [x[1] for x in p["p"]], p["km"], True
    d = TREN_COORDS.get(codigo)
    if not d:
        return [], [], 0.0, False
    try:
        import urllib.request
        req = urllib.request.Request(OPENRAIL.format(MADRID_COORDS[0], MADRID_COORDS[1], d[0], d[1]),
                                     headers={"User-Agent": "Mozilla/5.0 vuelos-app"})
        with urllib.request.urlopen(req, timeout=20) as r:
            j = json.loads(r.read().decode("utf-8"))
        c = j["paths"][0]["points"]["coordinates"]
        paso = max(1, len(c) // 600)
        pts = [[round(y, 5), round(x, 5)] for x, y in c[::paso]]
        if pts[-1] != [round(c[-1][1], 5), round(c[-1][0], 5)]:
            pts.append([round(c[-1][1], 5), round(c[-1][0], 5)])
        km = j["paths"][0]["distance"] / 1000
        cache[codigo] = {"p": pts, "km": round(km, 1)}
        _escribir_json(RUTAS_TREN, cache)
        return [x[0] for x in pts], [x[1] for x in pts], km, True
    except Exception:
        lat, lon = [MADRID_COORDS[0], d[0]], [MADRID_COORDS[1], d[1]]
        return lat, lon, float(_km_ruta(lat, lon)[-1]), False


def arco_vuelo(o, d, n=80):
    """Círculo máximo entre dos puntos (lat, lon) para dibujar el vuelo."""
    a1, o1, a2, o2 = map(np.radians, (o[0], o[1], d[0], d[1]))
    p1 = np.array([np.cos(a1) * np.cos(o1), np.cos(a1) * np.sin(o1), np.sin(a1)])
    p2 = np.array([np.cos(a2) * np.cos(o2), np.cos(a2) * np.sin(o2), np.sin(a2)])
    w = np.arccos(np.clip(p1 @ p2, -1, 1))
    if w < 1e-6:
        return [o[0], d[0]], [o[1], d[1]]
    t = np.linspace(0, 1, n)[:, None]
    p = (np.sin((1 - t) * w) * p1 + np.sin(t * w) * p2) / np.sin(w)
    return list(np.degrees(np.arcsin(p[:, 2]))), list(np.degrees(np.arctan2(p[:, 1], p[:, 0])))


def _min_hhmm(hhmm):
    try:
        h, m = str(hhmm).split(":")[:2]
        return int(h) * 60 + int(m)
    except (ValueError, AttributeError):
        return None


def fig_recorrido(lat, lon, salida, minutos, nom_o, nom_d, icono, color, real=True):
    """Mapa con el trayecto y un punto que lo recorre según la hora (botón ▶)."""
    lat, lon = np.asarray(lat, float), np.asarray(lon, float)
    cum = _km_ruta(lat, lon)
    n = 90
    fr = np.linspace(0, 1, n)
    la = np.interp(fr * cum[-1], cum, lat)
    lo = np.interp(fr * cum[-1], cum, lon)
    ini = _min_hhmm(salida)
    etiquetas = [(f"{((ini + int(f * minutos)) // 60) % 24:02d}:{(ini + int(f * minutos)) % 60:02d}"
                  if ini is not None and minutos else f"{int(f * 100)} %") for f in fr]
    fig = go.Figure(
        data=[go.Scattermap(lat=lat, lon=lon, mode="lines", line=dict(width=4, color=color),
                            hoverinfo="skip", name="Trayecto"),
              go.Scattermap(lat=[lat[0], lat[-1]], lon=[lon[0], lon[-1]], mode="markers+text",
                            marker=dict(size=13, color=["#202124", "#E5484D"]),
                            text=[nom_o, nom_d], textposition="top right",
                            hoverinfo="text", name="Extremos"),
              go.Scattermap(lat=[la[0]], lon=[lo[0]], mode="markers+text", text=[icono],
                            textfont=dict(size=22), marker=dict(size=18, color=color),
                            hoverinfo="skip", name="Posición")],
        frames=[go.Frame(data=[go.Scattermap(lat=[la[i]], lon=[lo[i]], text=[icono])], traces=[2],
                         name=etiquetas[i]) for i in range(n)])
    span = max(lon.max() - lon.min(), (lat.max() - lat.min()) * 1.5, 0.05)
    zoom = float(np.clip(np.log2(360 / span) - 0.9, 2.2, 9))
    fig.update_layout(
        map=dict(style="open-street-map", center=dict(lat=float(lat.mean()), lon=float(lon.mean())), zoom=zoom),
        height=600, margin=dict(l=0, r=0, t=0, b=0), showlegend=False,
        updatemenus=[dict(type="buttons", direction="left", x=0.02, y=0.04, xanchor="left", yanchor="bottom",
                          buttons=[dict(label="▶ Reproducir", method="animate",
                                        args=[None, dict(frame=dict(duration=70, redraw=True),
                                                         fromcurrent=True, transition=dict(duration=0))]),
                                   dict(label="⏸ Pausa", method="animate",
                                        args=[[None], dict(frame=dict(duration=0, redraw=False),
                                                           mode="immediate", transition=dict(duration=0))])])],
        sliders=[dict(active=0, x=0.18, y=0.03, len=0.78, xanchor="left", yanchor="bottom",
                      currentvalue=dict(prefix="Hora: ", font=dict(size=14)),
                      pad=dict(t=0, b=0),
                      steps=[dict(method="animate", label=etiquetas[i],
                                  args=[[etiquetas[i]], dict(mode="immediate", frame=dict(duration=0, redraw=True),
                                                             transition=dict(duration=0))])
                             for i in range(0, n, 3)])])
    return fig


@st.cache_data(show_spinner=False)
def rec_trenes(mt_, ciudad=None, sent=None):
    """Para Recorrido: lista de destinos o, con ciudad y sentido, solo esas filas."""
    t = cargar_trenes(mt_)
    t = t[t["codigo"].isin(TREN_COORDS)]
    if ciudad is None:
        return sorted(t["ciudad"].unique())
    return t[(t["ciudad"] == ciudad) & (t["sentido"] == sent)].reset_index(drop=True)


@st.cache_data(show_spinner=False)
def rec_vuelos(mt_o, mt_m, ciudad=None, sent=None):
    o = cargar_opciones(mt_o, mt_m)
    if ciudad is None:
        return sorted(o["ciudad"].unique())
    cols = ["fecha", "sentido", "codigo", "ciudad", "hora_salida", "hora_llegada", "aerolinea",
            "precio_eur", "escalas", "duracion_min"]
    return o.loc[(o["ciudad"] == ciudad) & (o["sentido"] == sent), cols].reset_index(drop=True)


def pag_recorrido():
    titulo_pagina("🧭", "Recorrido de un trayecto",
                  "Elige un tren o un vuelo y mira su ruta, sus datos y el viaje en movimiento")
    medios = []
    if hay_trenes:
        medios.append("🚆 Tren")
    if hay_datos:
        medios.append("✈️ Vuelo")
    if not medios:
        return st.info("Necesito precios descargados de trenes o de vuelos para dibujar un trayecto.")
    medio = st.radio("Medio", medios, horizontal=True, key="rec_medio")
    if medio.startswith("🚆"):
        ciudades = rec_trenes(mt_tren)
        if not ciudades:
            return sin_trenes()
        c1, c2, c3 = st.columns([2, 2, 2])
        ciudad = c1.selectbox("Destino", ciudades, key="rec_t_ciu")
        sent = c2.radio("Sentido", list(SENTIDOS_TREN), format_func=SENTIDOS_TREN.get, horizontal=True,
                        key="rec_t_sent")
        s = rec_trenes(mt_tren, ciudad, sent)
        if s.empty:
            return st.info("No hay trenes descargados para ese destino y sentido.")
        barato = s.loc[s["precio_eur"].idxmin(), "fecha"] if s["precio_eur"].notna().any() else s["fecha"].min()
        fechas = sorted(s["fecha"].dt.date.unique())
        dia = c3.selectbox("Día", fechas, index=fechas.index(barato.date()), key="rec_t_dia",
                           format_func=lambda x: f"{CORTO[x.weekday()]} {x:%d/%m/%Y}")
        s = s[s["fecha"].dt.date == dia].sort_values("hora_salida")
        op = {f"{r.hora_salida} → {r.hora_llegada} · {r.compania} {r.tipo_tren or ''} · "
              + (f"{r.precio_eur:.0f} €" if pd.notna(r.precio_eur) else "sin plazas"): r.Index
              for r in s.itertuples()}
        eleg = st.selectbox("Tren", list(op), key="rec_t_tren")
        r = s.loc[op[eleg]]
        codigo = r["codigo"]
        with st.spinner("Buscando el trazado por vía…"):
            lat, lon, km, real = ruta_tren(codigo)
        if not lat:
            return st.warning("No tengo coordenadas de esa estación.")
        if sent == "vuelta":
            lat, lon = lat[::-1], lon[::-1]
        nom_o, nom_d = ("Madrid", ciudad) if sent == "ida" else (ciudad, "Madrid")
        mins = r["duracion_min"] if pd.notna(r["duracion_min"]) else None
        k = st.columns(5)
        k[0].metric("Precio", f"{r['precio_eur']:.0f} €" if pd.notna(r["precio_eur"]) else "—",
                    r["tarifa_min"] if isinstance(r["tarifa_min"], str) else None, delta_color="off", delta_arrow="off")
        k[1].metric("Horario", f"{r['hora_salida']} → {r['hora_llegada']}")
        k[2].metric("Duración", dur(int(mins)) if mins else "—")
        k[3].metric("Distancia por vía" if real else "Distancia (recta)", f"{km:.0f} km")
        k[4].metric("Velocidad media", f"{km / (mins / 60):.0f} km/h" if mins else "—")
        st.plotly_chart(fig_recorrido(lat, lon, r["hora_salida"], mins, nom_o, nom_d, "🚆", COLORES[2], real),
                        width="stretch")
        st.caption(("Trazado real por vía (OpenRailRouting + OpenStreetMap, guardado en tu carpeta)." if real else
                    "No he podido obtener el trazado por vía (sin conexión al servicio): se muestra una línea recta.")
                   + " El punto se mueve a velocidad uniforme entre la hora de salida y la de llegada; "
                   "no se conocen las paradas intermedias.")
        if isinstance(r["tarifas"], str) and r["tarifas"]:
            st.write("**Tarifas:** " + r["tarifas"].replace(" | ", " · "))
        if isinstance(r["enlace"], str) and r["enlace"]:
            st.link_button(f"🚆 Ver en {r['compania']}", r["enlace"])
    else:
        ciudades = rec_vuelos(mt_opc, mt)
        if not ciudades:
            return sin_datos()
        c1, c2, c3 = st.columns([2, 2, 2])
        ciudad = c1.selectbox("Destino", ciudades, key="rec_v_ciu")
        sent = c2.radio("Sentido", ["IDA", "VUELTA"], horizontal=True, key="rec_v_sent",
                        format_func=lambda x: "Madrid → destino" if x == "IDA" else "Destino → Madrid")
        s = rec_vuelos(mt_opc, mt, ciudad, sent)
        if s.empty:
            return st.info("No hay vuelos descargados para ese destino y sentido.")
        barato = s.loc[s["precio_eur"].idxmin(), "fecha"]
        fechas = sorted(s["fecha"].unique())
        dia = c3.selectbox("Día", fechas, index=fechas.index(barato), key="rec_v_dia",
                           format_func=lambda x: f"{CORTO[x.weekday()]} {x:%d/%m/%Y}")
        s = s[s["fecha"] == dia].sort_values("precio_eur")
        op = {f"{r.hora_salida} → {r.hora_llegada} · {r.aerolinea} · {r.precio_eur:.0f} € · "
              + ("directo" if r.escalas == 0 else f"{int(r.escalas)} escala(s)"): r.Index for r in s.itertuples()}
        eleg = st.selectbox("Vuelo", list(op), key="rec_v_vuelo")
        r = s.loc[op[eleg]]
        cod = r["codigo"]
        aero = coords_aeropuertos([cod])
        if cod not in aero or "MAD" not in aero:
            return st.warning("No tengo coordenadas de aeropuerto para este destino.")
        o_xy, d_xy = (aero["MAD"], aero[cod]) if sent == "IDA" else (aero[cod], aero["MAD"])
        lat, lon = arco_vuelo(o_xy, d_xy)
        km = float(_km_ruta(lat, lon)[-1])
        mins = r["duracion_min"] if pd.notna(r["duracion_min"]) else None
        nom_o, nom_d = ("Madrid", ciudad) if sent == "IDA" else (ciudad, "Madrid")
        k = st.columns(5)
        k[0].metric("Precio", f"{r['precio_eur']:.0f} €")
        k[1].metric("Horario", f"{r['hora_salida']} → {r['hora_llegada']}")
        k[2].metric("Duración", dur(int(mins)) if mins else "—")
        k[3].metric("Distancia (círculo máximo)", f"{km:.0f} km")
        k[4].metric("Escalas", "Directo" if r["escalas"] == 0 else f"{int(r['escalas'])}")
        st.plotly_chart(fig_recorrido(lat, lon, r["hora_salida"], mins, nom_o, nom_d, "✈️", COLORES[0]),
                        width="stretch")
        st.caption("El arco es la ruta directa entre aeropuertos; si el vuelo tiene escalas, el recorrido real "
                   "pasa por otro aeropuerto. La duración incluye las esperas.")


def siguiente_ejecucion(prog, desde=None):
    """Siguiente momento en que toca descargar, según la programación guardada."""
    desde = desde or datetime.now()
    try:
        h, m = map(int, str(prog.get("hora", "04:00")).split(":")[:2])
    except ValueError:
        h, m = 4, 0
    if prog.get("tipo") == "semana":
        objetivo = [DIAS.index(d) for d in prog.get("dias_semana", []) if d in DIAS] or [0]
        for i in range(1, 15):
            d = (desde + timedelta(days=i)).replace(hour=h, minute=m, second=0, microsecond=0)
            if d.weekday() in objetivo:
                return d
    return (desde + timedelta(days=int(prog.get("cada_dias", 7)))).replace(
        hour=h, minute=m, second=0, microsecond=0)

def pag_gestion_datos_hoteles():
    titulo_pagina("🗄️", "Gestión de datos", "Cuánto se ha descargado cada día y cuánto pesa")
    st.subheader("Tamaño de los archivos")
    archivos = [(CSV_HOT, "Hoteles"), (CSV_HOT_HIST, "Histórico de precios"),
                (CSV_HOT_SONDEO, "Sondeos por mes")]
    filas_tam = [{"Archivo": et, "Tamaño": tamano_legible(tamano_bytes(r))}
                for r, et in archivos if os.path.exists(r)]
    st.dataframe(pd.DataFrame(filas_tam), hide_index=True, width="stretch")
    total = sum(tamano_bytes(r) for r, _ in archivos)
    st.metric("Total en disco", tamano_legible(total))

    por_dia = consultas_por_dia(CSV_HOT_HIST, mtime(CSV_HOT_HIST))
    if por_dia.empty:
        st.info("Todavía no hay histórico de descargas de hoteles.")
        return

    hoy = date.today()
    fila_hoy = por_dia[por_dia["dia"] == hoy]
    c1, c2 = st.columns(2)
    c1.metric("Consultas hoy", f"{int(fila_hoy['filas'].iloc[0]):,}".replace(",", ".") if not fila_hoy.empty else "0")
    c2.metric("Ciudades distintas hoy", int(fila_hoy["destinos"].iloc[0]) if not fila_hoy.empty else 0)

    st.subheader("Descargas por día")
    fig = px.bar(por_dia.sort_values("dia"), x="dia", y="filas", labels={"dia": "", "filas": "Consultas"})
    fig.update_traces(marker_color=COLORES[0])
    estilo(fig, alto=280, leyenda="no")
    fig.update_layout(bargap=.15)
    st.plotly_chart(fig, width="stretch")
    st.dataframe(por_dia.sort_values("dia", ascending=False), hide_index=True, width="stretch",
                 column_config={"dia": st.column_config.DateColumn("Día", format="DD/MM/YY"),
                                "filas": "Consultas", "destinos": "Ciudades distintas"})

    st.subheader("Reducir el histórico")
    st.caption("`historico_hoteles.csv` guarda una fila por cada consulta y alojamiento. Puedes "
               "recortar lo más antiguo a una sola fila por alojamiento y día (la última consulta "
               "de ese día); lo reciente se deja intacto.")
    dias_mantener, dias_retener = politica_historico()
    if st.button(f"🗜️ Comprimir histórico de hoteles anterior a {dias_mantener} días"):
        with st.spinner("Comprimiendo histórico de hoteles…"):
            n0, n1 = comprimir_historico(CSV_HOT_HIST, dias_mantener,
                                         ["codigo", "ciudad", "fecha_entrada", "nombre"], dias_retener)
        consultas_por_dia.clear()
        st.toast(f"Histórico comprimido: {n0:,} → {n1:,} filas".replace(",", "."), icon="🗜️")
        st.rerun()

def programacion(sel, prio, peso, vel, dias, modo, sondeo_n):
    """Descargas periódicas: las lanza el icono de la bandeja mientras la app esté abierta."""
    prog = leer_config().get("programada", {}) or {}
    with st.container(border=True):
        st.markdown("**⏱️ Descargas periódicas**")
        activa = st.toggle("Repetir la descarga automáticamente", value=bool(prog.get("activa")),
                           key="pg_activa")
        if not activa:
            if prog.get("activa"):
                guardar_config(programada={**prog, "activa": False})
                st.toast("Descargas periódicas desactivadas", icon="⏹️")
            st.caption("Actívalo para repetir esta misma descarga cada cierto tiempo, sin tener que "
                       "entrar a lanzarla.")
            return
        c1, c2, c3 = st.columns(3)
        tipo = c1.radio("Cada cuánto", ["Cada X días", "Días de la semana"],
                        index=0 if prog.get("tipo", "cada") == "cada" else 1, key="pg_tipo")
        if tipo == "Cada X días":
            cada = c1.number_input("Días entre descargas", 1, 60, int(prog.get("cada_dias", 7)),
                                   key="pg_cada")
            dias_sem = []
        else:
            cada = int(prog.get("cada_dias", 7))
            st.session_state.setdefault("pg_dsem", prog.get("dias_semana") or ["lunes"])
            dias_sem = c1.multiselect("Qué días", DIAS, key="pg_dsem")
            if not dias_sem:
                c1.warning("Elige al menos un día; de momento uso el lunes.")
                dias_sem = ["lunes"]
        HORAS = [f"{h:02d}:{m:02d}" for h in range(24) for m in (0, 30)]
        st.session_state.setdefault("pg_hora", prog.get("hora") if prog.get("hora") in HORAS else "04:00")
        hora_txt = c2.selectbox("Hora", HORAS, key="pg_hora",
                                help="Mejor de madrugada: tarda menos y molesta menos la conexión")
        hora = dt_time(*map(int, hora_txt.split(":")))
        empezar = c3.number_input("Empezar dentro de (días)", 0, 60, int(prog.get("empezar", 7)),
                                  key="pg_empezar",
                                  help="0 = la primera a la hora indicada de hoy o mañana")
        nueva = {
            "activa": True, "tipo": "cada" if tipo == "Cada X días" else "semana",
            "cada_dias": int(cada), "dias_semana": dias_sem, "hora": hora_txt,
            "empezar": int(empezar),
            "args": construir_args(sel, prio, peso, vel, dias, HORAS_MODO[modo], sondeo_n),
            "etiqueta": f"{len(sel)} destinos · {dias} días · {modo}",
        }
        base = datetime.now().replace(hour=hora.hour, minute=hora.minute, second=0, microsecond=0)
        proxima = base + timedelta(days=int(empezar))
        if proxima <= datetime.now():
            proxima += timedelta(days=1)
        cambiado = {k: v for k, v in nueva.items() if k != "args"} != \
                   {k: prog.get(k) for k in nueva if k != "args"} or prog.get("args") != nueva["args"]
        if cambiado or not prog.get("proxima"):
            nueva["proxima"] = proxima.strftime("%Y-%m-%d %H:%M")
            guardar_config(programada=nueva)
            prog = nueva
        _p = pd.to_datetime(prog["proxima"])
        st.caption(f"**Próxima:** {DIAS[_p.dayofweek]} {_p:%d/%m} a las {_p:%H:%M} · "
                   f"descargará: {nueva['etiqueta']}"
                   + (f" · **última:** {prog['ultima']}" if prog.get("ultima") else ""))
        st.caption("La lanza el icono de la bandeja, así que basta con tener la app abierta (puedes "
                   "cerrar la ventana). Si el ordenador está apagado a esa hora, se lanza en cuanto "
                   "lo enciendas y abras la app.")


def descargas_hotel():
    """Descarga de alojamientos: 4 modos de un clic (todo / solo lo nuevo, con o sin filtros)."""
    if not os.path.exists(SCRIPT_HOT):
        return st.info(f"Falta {SCRIPT_HOT} en la carpeta de la app.")
    cfg = leer_config()
    todos = destinos_script()
    nombre = lambda k: f"{todos.get(k, k)} ({k})"
    en_curso = descargando("hoteles")
    with st.container(border=True):
        st.markdown("**Ciudades y días**")
        grupos = grupos_script()
        st.session_state.setdefault("hd_destinos", [k for k in cfg.get("hoteles_destinos",
                                                                      cfg.get("destinos", list(todos)))
                                                    if k in todos])
        sel = st.multiselect("Ciudades", list(todos), format_func=nombre, key="hd_destinos")
        if grupos:
            g1, g2, g3 = st.columns([3, 1, 1])
            elegidos = g1.multiselect("Grupos", list(grupos), key="hd_grupos",
                                      placeholder="Añadir o quitar zonas enteras",
                                      format_func=lambda g: f"{g} ({len(grupos[g])})")
            codigos_grupo = [c for g in elegidos for c in grupos[g]]

            def _añadir_hot():
                st.session_state["hd_destinos"] = sorted(
                    set(st.session_state["hd_destinos"]) | set(codigos_grupo), key=list(todos).index)

            def _quitar_hot():
                st.session_state["hd_destinos"] = [c for c in st.session_state["hd_destinos"]
                                                   if c not in codigos_grupo]
            g2.button("➕ Añadir", width="stretch", on_click=_añadir_hot, disabled=not elegidos,
                     key="hd_g_add")
            g3.button("➖ Quitar", width="stretch", on_click=_quitar_hot, disabled=not elegidos,
                     key="hd_g_del")
            st.caption(f"{len(sel)} de {len(todos)} ciudades seleccionadas.")
        dias = st.slider("Días hacia delante", 7, 365, int(cfg.get("hoteles_dias", 60)), step=7,
                         key="hd_dias")
        vel_args = selector_velocidad_th("hoteles", "hd_vel")
        n_todo = len(sel) * dias
        st.caption(f"{n_todo:,}".replace(",", ".") + " consultas en total · una por ciudad y día de "
                   f"entrada · ~{dur(int(n_todo * (seg_previo('hoteles') or 0.7) / 60)) if n_todo else '0 min'}"
                   + (" según tus últimas descargas" if seg_previo("hoteles") else " a ritmo prudente"))

    bloqueado = en_curso or not sel
    base_args = ["--noches", "1", "--salida", CSV_HOT, *vel_args]
    args_pares_h = lambda pares: ["--salida", CSV_HOT, *args_pares(pares),
                                  *(vel_args or ["--hilos", "4", "--velocidad", "1", "--velocidad-max", "4"])]
    with st.container(border=True):
        st.markdown("**Descargar**")
        if en_curso:
            st.caption("⏳ Hay una descarga de hoteles en curso: los botones se activan cuando termine "
                       "(o si la detienes). Mientras tanto puedes usar toda la app.")
        st.caption("«Con filtros» usa los filtros del Buscador (barra lateral) → "
                   + resumen_filtros_descarga(sel, hoteles=True))
        b1, b2 = st.columns(2)
        b3, b4 = st.columns(2)
        if b1.button("📦 Descargar todo", type="primary", width="stretch", key="dl_h_todo",
                     disabled=bloqueado,
                     help="Vuelve a bajar TODOS los alojamientos de las ciudades y días elegidos, "
                          "estén o no ya descargados."):
            guardar_config(hoteles_destinos=sel, hoteles_dias=dias)
            confirmar_descarga(["--destinos", *sel, "--dias", str(dias), *base_args, "--actualizar", "0"],
                               n_todo, sel, seg=0.7, script=SCRIPT_HOT, tipo="hoteles")
        b1.caption(f"{n_todo:,} consultas".replace(",", "."))
        if b2.button("🎯 Descargar todo con filtros", width="stretch", key="dl_h_todo_f",
                     disabled=bloqueado or not hay_hoteles,
                     help="Vuelve a bajar los alojamientos que ves ahora mismo en el Buscador (con todos "
                          "sus filtros: nota, estrellas, servicios, precio, ubicación…)."):
            with st.spinner("Filtrando alojamientos…"):
                h_f = hoteles_filtrados(mt_hot, F["fh"])
                if F["ciudades"]:
                    h_f = h_f[h_f["ciudad"].isin(F["ciudades"])]
                if not F["fecha_libre"]:
                    h_f = h_f[(h_f["fecha_entrada"] >= pd.Timestamp(F["rango"][0]))
                              & (h_f["fecha_entrada"] <= pd.Timestamp(F["rango"][1]))]
            if h_f.empty:
                st.toast("No hay alojamientos con los filtros actuales", icon="⚠️")
            else:
                pares = pares_hoteles_de((r.codigo, r.fecha_entrada.date().isoformat())
                                         for r in h_f.itertuples())
                confirmar_descarga([*args_pares_h(pares), "--actualizar", "0"], len(pares),
                                   sorted(h_f["codigo"].unique()), seg=0.7, script=SCRIPT_HOT,
                                   tipo="hoteles")
        b2.caption("Lo que ves en el Buscador, refrescado")
        if b3.button("🆕 Descargar solo lo nuevo", width="stretch", key="dl_h_nuevo", disabled=bloqueado,
                     help="Solo las ciudades y fechas que todavía no están descargadas. No toca lo "
                          "que ya tienes."):
            with st.spinner("Calculando lo que falta…"):
                nuevos = {(c, f) for c in sel for f in universo_fechas_hoteles(dias)} - existentes_hoteles()
            if not nuevos:
                st.toast("Ya está todo descargado con esas opciones", icon="✅")
            else:
                guardar_config(hoteles_destinos=sel, hoteles_dias=dias)
                confirmar_descarga(["--destinos", *sel, "--dias", str(dias), *base_args], len(nuevos),
                                   sorted({c for c, _ in nuevos}), seg=0.7, script=SCRIPT_HOT,
                                   tipo="hoteles")
        b3.caption("Lo que falta, sin repetir nada")
        if b4.button("🆕 Descargar solo lo nuevo con filtros", width="stretch", key="dl_h_nuevo_f",
                     disabled=bloqueado,
                     help="Lo que falta dentro de los filtros del Buscador que se pueden aplicar a "
                          "alojamientos aún sin descargar: ciudad y fecha de entrada."):
            with st.spinner("Calculando lo que falta con esos filtros…"):
                nuevos = universo_hoteles_filtrado(sel, dias) - existentes_hoteles()
            if not nuevos:
                st.toast("No falta nada dentro de esos filtros", icon="✅")
            else:
                pares = pares_hoteles_de(sorted(nuevos))
                confirmar_descarga(args_pares_h(pares), len(pares), sorted({c for c, _ in nuevos}),
                                   seg=0.7, script=SCRIPT_HOT, tipo="hoteles")
        b4.caption("Lo que falta dentro de tus filtros")
    bloque_region("dl_h", grupos, dias, 1, en_curso,
                  lambda cods, n: confirmar_descarga(["--destinos", *cods, "--dias", str(dias), *base_args,
                                                      "--actualizar", "0"], n, cods, seg=0.7,
                                                     script=SCRIPT_HOT, tipo="hoteles"))

    with st.expander("⚙️ Otros modos: refrescar lo antiguo, sondeo por meses"):
        modo_h = st.radio("Qué descargar", ["Refrescar lo de hace más de 24 h",
                                            "Solo los meses que hayan cambiado (sondeo)"], key="hd_modo")
        sondeo_hot_n = 0
        if modo_h.startswith("Solo los meses"):
            sondeo_hot_n = st.number_input("Alojamientos al azar que comprueba por mes", 3, 30, 10,
                                           key="hd_sondeo")
            st.caption(f"Comprueba {sondeo_hot_n} alojamientos ya descargados de cada mes. Si en un "
                       "mes cambian más de 5 € **la mayoría**, ese mes se vuelve a descargar entero; "
                       "el resto se deja como está.")
        if st.button("Descargar con este modo", key="dl_h_otro", disabled=bloqueado):
            guardar_config(hoteles_destinos=sel, hoteles_dias=dias)
            args = ["--destinos", *sel, "--dias", str(dias), *base_args, "--actualizar", "24"]
            if sondeo_hot_n:
                args += ["--sondeo", str(int(sondeo_hot_n))]
            confirmar_descarga(args, n_todo, sel, seg=0.7, script=SCRIPT_HOT, tipo="hoteles")
    with st.expander("🎲 Muestreo por probabilidad de subida"):
        st.markdown("**Muestreo por probabilidad de subida**")
        st.caption("De los alojamientos que cumplen tus filtros actuales (⭐ Buscador), sortea "
                   "cuáles redescargar: a cada uno se le compara un número al azar (uniforme "
                   "entre 0 y 1) con su probabilidad estimada de haber subido desde la última "
                   "descarga. Cuanto más probable que haya cambiado, más papeletas tiene, pero "
                   "no es determinista — es un muestreo, no un umbral fijo.")
        cand_h, tsub_hm = hoteles_candidatos_muestreo()
        if tsub_hm.empty:
            st.caption("Todavía no hay histórico suficiente para esto.")
        elif cand_h.empty:
            st.caption("Ningún alojamiento cumple ahora mismo tus filtros.")
        else:
            st.caption(f"{len(cand_h)} alojamiento(s) candidatos · probabilidad media de "
                       f"subida {cand_h['prob_subida'].mean():.0%}.")
            if st.button("🎲 Sortear y redescargar", disabled=en_curso, key="dl_muestreo_hoteles"):
                azar = np.random.uniform(0, 1, size=len(cand_h))
                sorteados = cand_h[azar < cand_h["prob_subida"].to_numpy()]
                if sorteados.empty:
                    st.toast("El sorteo no ha tocado a ninguno esta vez. Prueba de nuevo.", icon="🎲")
                else:
                    pares = pares_hoteles_de((r.codigo, r.fecha_entrada.date().isoformat())
                                             for r in sorteados.itertuples())
                    confirmar_descarga([*args_pares_h(pares), "--actualizar", "0"], len(pares),
                                       sorted(sorteados["codigo"].unique()), seg=0.7,
                                       script=SCRIPT_HOT, tipo="hoteles")
    desplegable("🔎 Último sondeo de hoteles por meses", tabla_sondeos_hoteles, "dz_sond_hot")
    if hay_hoteles:
        desplegable("📋 Datos descargados", tabla_datos_hoteles, "dz_datos_hot")


def tabla_sondeos_hoteles():
    try:
        ts = pd.read_csv(CSV_HOT_SONDEO, sep=";", encoding="utf-8-sig", on_bad_lines="skip")
    except Exception:
        ts = pd.DataFrame()
    if not ts.empty:
        ult = ts[ts["momento"] == ts["momento"].max()]
        st.dataframe(ult[["mes", "muestra", "cambiados", "pct_cambiados", "dif_media", "decision"]],
                     hide_index=True, width="stretch", column_config={
                         "mes": "Mes de entrada", "muestra": "Alojamientos comprobados",
                         "cambiados": "Cambiaron",
                         "pct_cambiados": st.column_config.ProgressColumn("% que cambió", format="percent",
                                                                          min_value=0, max_value=1),
                         "dif_media": st.column_config.NumberColumn("Cambio medio", format="%+.1f €"),
                         "decision": "Decisión"})
    else:
        st.caption("Todavía no hay sondeos de hoteles.")


def tabla_datos_hoteles():
    r = resumen_hoteles_descargados(mt_hot)
    st.dataframe(r, hide_index=True, width="stretch", column_config={
        "ciudad": "Ciudad", "alojamientos": "Filas", "fechas": "Fechas",
        "desde": st.column_config.DateColumn("Desde", format="DD/MM/YY"),
        "hasta": st.column_config.DateColumn("Hasta", format="DD/MM/YY"),
        "precio": st.column_config.NumberColumn("€/noche mediano", format="%d €")})


@st.cache_data(show_spinner=False)
def resumen_hoteles_descargados(mt_):
    """Filas, fechas y precio mediano por ciudad leyendo solo 5 columnas del Parquet (la tabla
    entera pesa cientos de MB y no hace falta para este resumen)."""
    cols = ["ciudad", "nombre", "fecha_entrada", "precio_noche"]
    h = leer_columnas(CSV_HOT, mt_, cols)
    if h is None:
        h = cargar_hoteles(mt_)[cols]
    fe = h["fecha_entrada"].astype(str)
    h = h.assign(fecha_entrada=pd.to_datetime(fe, errors="coerce", format="%Y-%m-%d").fillna(
        pd.to_datetime(fe, errors="coerce", dayfirst=True)),
        precio_noche=pd.to_numeric(h["precio_noche"], errors="coerce"))
    h = h.dropna(subset=["fecha_entrada", "precio_noche"])
    h = h[h["fecha_entrada"] > pd.Timestamp.today().normalize()]
    return (h.groupby("ciudad").agg(alojamientos=("nombre", "size"), fechas=("fecha_entrada", "nunique"),
                                    desde=("fecha_entrada", "min"), hasta=("fecha_entrada", "max"),
                                    precio=("precio_noche", "median")).reset_index())


def tabla_sondeos():
    """Resultado de los sondeos por mes (qué meses se recalcularon y cuáles no)."""
    try:
        t = pd.read_csv(SONDEOS, sep=";", encoding="utf-8-sig", on_bad_lines="skip")
    except Exception:
        return
    if t.empty:
        return
    ult = t[t["momento"] == t["momento"].max()].copy()
    st.caption(f"Sondeo del {ult['momento'].iloc[0]}: se comprobaron "
               f"{int(ult['muestra'].sum())} vuelos ya descargados. Un mes se recalcula cuando más de "
               "la mitad de su muestra cambia 5 € o más.")
    st.dataframe(ult[["mes", "muestra", "cambiados", "pct_cambiados", "dif_media", "dif_media_abs",
                      "decision"]],
                 hide_index=True, width="stretch", column_config={
                     "mes": "Mes de salida", "muestra": "Vuelos comprobados", "cambiados": "Cambiaron",
                     "pct_cambiados": st.column_config.ProgressColumn("% que cambió", format="percent",
                                                                      min_value=0, max_value=1),
                     "dif_media": st.column_config.NumberColumn("Cambio medio", format="%+.1f €"),
                     "dif_media_abs": st.column_config.NumberColumn("Cambio medio (sin signo)", format="%.1f €"),
                     "decision": "Decisión"})
    if len(t["momento"].unique()) > 1:
        if st.toggle("Ver sondeos anteriores", key="sond_ant"):
            st.dataframe(t.sort_values("momento", ascending=False), hide_index=True, width="stretch")


def tabla_errores():
    """Tabla de frecuencias de los errores de descarga (historial en errores_descarga.csv)."""
    try:
        e = pd.read_csv(ERRORES, sep=";", encoding="utf-8-sig", on_bad_lines="skip")
        e["momento"] = pd.to_datetime(e["momento"], errors="coerce")
    except Exception:
        e = pd.DataFrame()
    if e.empty:
        st.caption("Sin errores registrados todavía. ✅")
        return
    periodo = st.segmented_control("Periodo", ["Últimas 24 h", "Últimos 7 días", "Todo"],
                                   default="Últimos 7 días", key="err_periodo")
    horas = {"Últimas 24 h": 24, "Últimos 7 días": 24 * 7}.get(periodo or "Todo")
    if horas:
        e = e[e["momento"] >= datetime.now() - timedelta(hours=horas)]
    if e.empty:
        st.caption("Sin errores en este periodo. ✅")
        return
    nombres = {**destinos_script(), ORIGEN: "Madrid"}
    e["ruta"] = e["origen"].map(lambda c: nombres.get(c, c)) + " → " + e["destino"].map(lambda c: nombres.get(c, c))
    f = (e.groupby("tipo").agg(veces=("tipo", "size"), ultima=("momento", "max"),
                               ejemplo=("mensaje", "last"))
         .reset_index().sort_values("veces", ascending=False))
    f["pct"] = f["veces"] / f["veces"].sum()
    c1, c2 = st.columns([3, 2])
    with c1:
        st.dataframe(f[["tipo", "veces", "pct", "ultima", "ejemplo"]], hide_index=True, width="stretch",
                     column_config={
                         "tipo": "Tipo de error", "veces": "Veces",
                         "pct": st.column_config.ProgressColumn("% del total", format="percent",
                                                                min_value=0, max_value=1),
                         "ultima": st.column_config.DatetimeColumn("Última vez", format="DD/MM HH:mm"),
                         "ejemplo": "Último mensaje"})
    with c2:
        h = e.set_index("momento").resample("h").size().rename("errores").reset_index()
        fig = px.bar(h, x="momento", y="errores", labels={"momento": "", "errores": "Errores por hora"})
        fig.update_traces(marker_color=ROJO)
        estilo(fig, alto=230, leyenda="no")
        fig.update_layout(margin=dict(t=6, b=0, l=0, r=0), bargap=0.2)
        fig.update_xaxes(tickformat="%d/%m %Hh")
        st.plotly_chart(fig, width="stretch")
    if st.toggle("Ver por ruta", key="err_ruta"):
        r = (e.groupby(["ruta", "tipo"]).size().unstack(fill_value=0))
        r["Total"] = r.sum(axis=1)
        st.dataframe(r.sort_values("Total", ascending=False), width="stretch")
    st.caption("«Pausa por captcha» no es un fallo: la descarga espera y sigue sola. Los demás son consultas "
               "que fallaron tras 3 intentos; se reintentan al volver a descargar «Solo lo que falta».")
    if st.button("🗑️ Borrar historial de errores"):
        confirmar_borrar_errores()


@st.dialog("¿Borrar el historial de errores?")
def confirmar_borrar_errores():
    st.write("Solo se borra el registro de errores; los precios descargados no se tocan.")
    a, b = st.columns(2)
    if a.button("Sí, borrar", type="primary", width="stretch"):
        try:
            os.remove(ERRORES)
            st.session_state["aviso"] = ("🗑️", "Historial de errores borrado")
        except OSError as ex:
            st.session_state["aviso"] = ("⚠️", f"No se ha podido borrar: {ex}")
        st.rerun()
    if b.button("Cancelar", width="stretch"):
        st.rerun()


def pag_anticipacion():
    titulo_pagina("📉", "Antelación y volatilidad",
                  "Con qué antelación sube el precio y cada cuánto conviene refrescar cada tramo")
    if not hay_datos:
        return sin_datos()
    try:
        import modelo_precios as mp
    except ImportError:
        return st.error("Falta el fichero modelo_precios.py en la carpeta de la app.")

    mt_hist = mtime(HISTORICO)
    clave = "modelo_ctrl_vuelos"
    ctrl = selector_modelo(clave)
    st.caption("**Modelo con más variables**: además del efecto fijo por vuelo, descuenta lo que se "
               "mueve el mercado cada día de consulta y la franja horaria (y amplía el modelo del punto 3). "
               "Tarda más en calcularse." if ctrl else
               "**Modelo actual**: compara cada vuelo consigo mismo según el tramo de antelación.")

    st.subheader("1. ¿Cuánto encarece acercarse a la fecha?")
    tabla, info = _modelo_anticipacion_vuelos(mt_hist, ctrl)
    if tabla.empty:
        st.info(info.get("error", "No hay datos suficientes."))
    else:
        k = st.columns(4)
        k[0].metric("Umbral estimado", f"{info['umbral']} días" if info["umbral"] else "sin efecto claro")
        k[1].metric("Precios usados", f"{info['n']:,}".replace(",", "."))
        k[2].metric("Vuelos comparados", f"{info['grupos']:,}".replace(",", "."))
        k[3].metric("R² del modelo", f"{info['r2']:.2f}")
        t = tabla.copy()
        t["ic"] = 1.96 * t["se"] * (1 + t["efecto"])          # margen aproximado en %
        comp = None
        if ctrl and st.checkbox("Superponer el modelo actual", key=f"{clave}_comp"):
            comp = comparar_antelacion(tabla, _modelo_anticipacion_vuelos(mt_hist, False)[0])
        datos = t if comp is None else comp
        fig = px.bar(datos, x="tramo", y="efecto", error_y="ic", barmode="group",
                     color=(t["p"].lt(mp.ALFA) & t["efecto"].abs().ge(mp.EFECTO_MIN)) if comp is None
                     else datos["modelo"],
                     color_discrete_map={True: ROJO, False: GRIS, "Actual": GRIS, "Con más variables": ROJO},
                     labels={"tramo": "Días hasta la salida", "efecto": "Diferencia de precio", "color": ""})
        fig.update_traces(hovertemplate="%{x}<br>%{y:+.1%}<extra></extra>")
        estilo(fig, alto=360, leyenda="no" if comp is None else "arriba")
        fig.update_layout(yaxis_tickformat=".0%", bargap=.3)
        if info["umbral"] and comp is None:
            fig.add_vline(x=info["umbral"] and next((i for i, r in enumerate(t.itertuples())
                                                     if r.hasta == info["umbral"]), 0) + 0.5,
                          line_dash="dash", line_color="#333")
        st.plotly_chart(fig, width="stretch")
        st.dataframe(t[["tramo", "n", "efecto", "se", "p"]], hide_index=True, width="stretch", column_config={
            "tramo": "Días hasta la salida", "n": "Precios",
            "efecto": st.column_config.NumberColumn(f"Dif. frente a «{info['base']}»", format="percent"),
            "se": st.column_config.NumberColumn("Error estándar", format="%.4f",
                                                help="Agrupado por vuelo: varias consultas del mismo vuelo no cuentan como independientes"),
            "p": st.column_config.NumberColumn("p-valor", format="%.3f",
                                               help="Menor de 0,05 = diferencia estadísticamente significativa")})
        st.caption(f"Compara cada vuelo consigo mismo en distintos momentos (efectos fijos por vuelo, "
                   f"{info['grupos']} vuelos vistos en al menos dos tramos), así se descuenta el destino, "
                   "el mes, el día de la semana y el sentido. En rojo, los tramos con efecto significativo "
                   "(p < 0,05, con errores agrupados por vuelo) y de al menos el 5 %. El umbral es el punto "
                   "a partir del cual la antelación deja de importar.")
        with st.expander("📐 Formalización del modelo"):
            st.latex(LATEX_ANTELACION_CTRL if ctrl else
                     r"\log(\text{precio}_{it}) = \alpha_i + \sum_{k} \beta_k \cdot \mathbb{1}[\text{tramo}_{it}=k] + \varepsilon_{it}")
            if ctrl:
                st.markdown("\n".join(LINEAS_ANTELACION_CTRL))
            st.markdown("\n".join([
                "- **i** = vuelo/ruta concreta (código + sentido + fecha de salida) · **t** = cada consulta histórica de ese vuelo.",
                "- **αᵢ**: efecto fijo por vuelo — descuenta todo lo que no cambia para ese vuelo (destino, mes, día de la semana...).",
                f"- **βₖ** (exponenciado, exp(β)-1): cambio porcentual de precio en el tramo *k* frente al tramo de referencia «{info['base']}».",
                "- Estimado por mínimos cuadrados sobre las variables centradas por vuelo (*within estimator*), equivalente a incluir una variable ficticia por vuelo.",
                f"- Errores estándar agrupados (*cluster-robust*) por vuelo: **{info['grupos']}** grupos, **{info['n']}** observaciones, R² = **{info['r2']:.3f}**.",
            ]))

    st.subheader("2. ¿Cuánto se mueve el precio de verdad?")
    if ctrl:
        st.caption(NOTA_VOLATILIDAD_CTRL)
    vol, vinfo = _volatilidad_vuelos(mt_hist)
    umbral_vol = 0
    if vol.empty:
        st.info(vinfo.get("error", "") + " Hacen falta al menos dos descargas de los mismos días, "
                "separadas en el tiempo (por ejemplo, un día).")
    else:
        umbral_vol = vinfo["umbral"]
        c1, c2 = st.columns(2)
        c1.metric("Umbral por volatilidad", f"{umbral_vol} días" if umbral_vol else "estable")
        c2.metric("Comparaciones", f"{vinfo['pares']:,}".replace(",", "."),
                  f"desde {pd.to_datetime(vinfo['desde_cuando']):%d/%m}", delta_arrow="off", delta_color="off")
        vm = vol.melt(id_vars=["tramo", "desde"], value_vars=["tendencia_dia", "volatilidad_dia"],
                      var_name="serie", value_name="valor")
        vm["serie"] = vm["serie"].map({"tendencia_dia": "Tendencia (con signo)", "volatilidad_dia": "Volatilidad (magnitud)"})
        fig = px.bar(vm.sort_values("desde"), x="tramo", y="valor", color="serie", barmode="group",
                     labels={"tramo": "Días hasta la salida", "valor": "Cambio al día", "serie": ""},
                     color_discrete_sequence=[COLORES[0], ROJO])
        fig.update_traces(hovertemplate="%{x}<br>%{y:.2%} al día<extra></extra>")
        estilo(fig, alto=320)
        fig.update_layout(yaxis_tickformat=".1%", bargap=.3)
        st.plotly_chart(fig, width="stretch")
        st.dataframe(vol[["tramo", "pares", "tendencia_dia", "volatilidad_dia", "pct_movidos", "dias_refresco"]],
                     hide_index=True, width="stretch", column_config={
                         "tramo": "Días hasta la salida", "pares": "Comparaciones",
                         "tendencia_dia": st.column_config.NumberColumn(
                             "Tendencia al día", format="percent",
                             help="Cambio medio CON signo, por día: ¿sube o baja de media en ese tramo?"),
                         "volatilidad_dia": st.column_config.NumberColumn(
                             "Volatilidad al día", format="percent",
                             help="Magnitud del movimiento típico, escalada con la raíz del tiempo (paseo aleatorio)"),
                         "pct_movidos": st.column_config.NumberColumn("% que cambió ≥5 %", format="percent"),
                         "dias_refresco": st.column_config.NumberColumn(
                             "Refrescar cada (días)", format="%d",
                             help="Días que tarda el precio, de media, en moverse un 5 %")})
        st.caption("Compara cada precio con el de la descarga anterior del mismo vuelo. La tendencia lleva "
                   "signo (sube o baja de media); la volatilidad es la magnitud del movimiento, sin signo. "
                   "Los tramos con menos de 30 comparaciones son poco fiables.")
        with st.expander("📐 Formalización del modelo"):
            st.latex(r"\text{tendencia}_{it} = \frac{\Delta p_{it}/p_{i,t-1}}{\Delta t_{it}} "
                     r"\qquad \text{volatilidad}_{it} = \frac{|\Delta p_{it}/p_{i,t-1}|}{\sqrt{\Delta t_{it}}}")
            st.markdown("\n".join([
                "- **Δt**: tiempo (en días) transcurrido entre dos consultas consecutivas del mismo vuelo.",
                "- La volatilidad se escala con la **raíz** de Δt, no linealmente, como en un paseo aleatorio: así no se sobrestima cuánto se moverá el precio dentro de varios días a partir de cambios vistos en pocas horas.",
                "- `dias_refresco` = los días que hacen falta, dentro de ese tramo, para que la volatilidad acumulada (volatilidad_dia × √días) alcance el 5 % — ese es el ritmo de refresco recomendado.",
            ]))

    st.subheader("3. ¿Sube o baja según se acerca la fecha?")
    tsub, curva, isub = _probabilidad_vuelos(mt_hist, ctrl)
    if tsub.empty:
        st.info(isub.get("error", "Todavía no hay histórico suficiente."))
    else:
        st.metric("Comparaciones", f"{isub['pares']:,}".replace(",", "."))
        fig = px.bar(tsub, x="tramo", y="pct_subio",
                     labels={"tramo": "Días hasta la salida", "pct_subio": "% de veces que subió"})
        fig.update_traces(marker_color=ROJO, hovertemplate="%{x}<br>%{y:.0%}<extra></extra>")
        estilo(fig, alto=300, leyenda="no")
        fig.update_layout(yaxis_tickformat=".0%", yaxis_range=[0, 1], bargap=.3)
        fig.add_hline(y=0.5, line_dash="dash", line_color="#888")
        st.plotly_chart(fig, width="stretch")
        if isub["modelo_ok"] and not curva.empty:
            st.caption(f"Curva estimada por un modelo (regresión logística, {isub['pares']} comparaciones, "
                       f"{isub['grupos']} vuelos, cambios menores del {isub['umbral_ruido']:.0%} descartados "
                       "como ruido): probabilidad de subida según los días que faltan.")
            fig2 = px.line(curva, x="dias", y="probabilidad",
                           labels={"dias": "Días hasta la salida", "probabilidad": "Probabilidad de subida"})
            fig2.update_traces(line_color=ROJO)
            estilo(fig2, alto=260, leyenda="no")
            fig2.update_layout(yaxis_tickformat=".0%", yaxis_range=[0, 1])
            st.plotly_chart(fig2, width="stretch")
            with st.expander("📐 Formalización del modelo"):
                st.latex(r"\text{logit}\big(P(\text{subió}_{it})\big) = \beta_0 + \beta_1 \cdot \text{días}_{it} "
                         + (LATEX_SUBIDA_CTRL if ctrl else "")
                         + r"+ \sum_j \gamma_j \cdot \mathbb{1}[\text{destino}_{it}=j]")
                lineas = [
                    f"- Solo cuenta cambios de al menos el {isub['umbral_ruido']:.0%} frente a la consulta "
                    "anterior; los menores se descartan como ruido de redondeo, no una subida/bajada real.",
                    "- Se controla por destino (**γⱼ**) para no confundir «esta ruta siempre sube» con "
                    "«sube porque falta poco».",
                ]
                lineas += LINEAS_SUBIDA_CTRL if ctrl else []
                or_dia = np.exp(isub["b1"]) if isub.get("b1") is not None and not pd.isna(isub.get("b1")) else None
                if or_dia is not None:
                    lineas.append(f"- **β₁ = {isub['b1']:.4f}** → cada día menos multiplica la "
                                 f"probabilidad de subir por exp(β₁) ≈ **{or_dia:.3f}** (odds ratio diario).")
                lineas.append(f"- Ajustado por Newton-Raphson (IRLS); errores agrupados por vuelo "
                              f"(**{isub['grupos']}** grupos, **{isub['pares']}** comparaciones).")
                st.markdown("\n".join(lineas))
        st.caption("La línea del 50% marca 'sube o baja según toque'. Por encima, sube más veces "
                   "de las que baja al acercarse esa antelación; por debajo, al revés.")

    st.subheader("4. ¿Cuánto sube si contrato más tarde?")
    st.caption("Con los vuelos que cumplen tus filtros actuales (⭐ Buscador) y el modelo del punto "
               "1: cuánto pagarías de más, de media, si contratas en la fecha que elijas en vez de "
               "hoy (tomando la fecha de ida como referencia de antelación).")
    if tabla.empty:
        st.info("Hace falta el modelo del punto 1 para esto.")
    else:
        c_f = combinaciones()
        if c_f.empty:
            st.info("No hay vuelos con los filtros actuales (revisa ⭐ Buscador).")
        else:
            hoy = date.today()
            fecha_futura = st.date_input(
                "Fecha en la que contratarías", value=hoy + timedelta(days=30),
                min_value=hoy + timedelta(days=1), key="fecha_estimador_vuelos")
            efecto_tramo = tabla.set_index("tramo")["efecto"].to_dict()
            tr_ant = mp.TRAMOS_CTRL if ctrl else mp.TRAMOS
            est = c_f.assign(fecha_ref=c_f["ida"].dt.date)
            est["dias_hoy"] = est["fecha_ref"].map(lambda f: max((f - hoy).days, 0))
            est["dias_futuro"] = est["fecha_ref"].map(lambda f: (f - fecha_futura).days)
            est = est[est["dias_futuro"] >= 0]
            if est.empty:
                st.info(f"La fecha elegida ({fecha_futura:%d/%m/%y}) es posterior a todos los vuelos "
                        "filtrados.")
            else:
                est["efecto_hoy"] = est["dias_hoy"].map(lambda d: mp.tramo_de(d, tr_ant)).map(efecto_tramo)
                est["efecto_futuro"] = est["dias_futuro"].map(lambda d: mp.tramo_de(d, tr_ant)).map(efecto_tramo)
                est = est.dropna(subset=["efecto_hoy", "efecto_futuro"]).copy()
                if est.empty:
                    st.info("No hay suficientes tramos con datos para estimar esto.")
                else:
                    est["incremento_eur"] = est["total"] * (
                        (1 + est["efecto_futuro"]) / (1 + est["efecto_hoy"]) - 1)
                    media = est["incremento_eur"].mean()
                    k1, k2 = st.columns(2)
                    k1.metric("Vuelos comparados", f"{len(est):,}".replace(",", "."))
                    signo, verbo = ("más caro", "subiría") if media >= 0 else ("más barato", "bajaría")
                    k2.metric(f"Si contratas el {fecha_futura:%d/%m/%y}",
                              f"{abs(media):,.0f} € {signo}".replace(",", "."))
                    st.caption(f"El precio medio {verbo} unos {abs(media):.0f} € frente a contratarlo "
                               f"hoy, según cómo cambia el efecto de antelación entre el tramo de hoy "
                               f"y el tramo en el que estaría cada vuelo el {fecha_futura:%d/%m/%y}, "
                               "aplicado sobre su precio actual.")

    st.subheader("5. ¿Cuándo suele estar más barato cada destino?")
    st.caption("A cuántos días de la salida suele estar el precio mínimo de un vuelo, y en qué tramo de "
               "antelación sale más barato frente a la media de ese mismo vuelo.")
    mm, imm = _mejor_momento_vuelos(mt_hist)
    if mm.empty:
        st.info(imm.get("error", "Todavía no hay datos suficientes."))
    else:
        if imm["dias_historico"] < 60:
            st.warning(f"Solo hay {imm['dias_historico']} días de histórico: cada vuelo se ha visto, como mucho, "
                       f"{imm['rango_mediano']:.0f} días seguidos. \"A cuántos días suele darse el mínimo\" está "
                       "limitado a esa ventana; tómalo como orientativo.")
        pocos = st.checkbox("Mostrar destinos con pocos datos", key="mm_pocos_vuelos")
        m = (mm if pocos else mm[mm["fiable"]]).copy()
        m["ciudad"] = m["codigo"].map(destinos_script()).fillna(m["codigo"])
        m["ventaja_tramo"] *= 100
        st.dataframe(m[["ciudad", "sentido", "vuelos", "minimo_habitual", "dias_min", "tramo_barato",
                        "ventaja_tramo"]], hide_index=True, width="stretch", column_config={
                            "ciudad": "Destino", "sentido": "Sentido", "vuelos": "Vuelos",
                            "minimo_habitual": st.column_config.NumberColumn("Mínimo habitual", format="%.0f €"),
                            "dias_min": st.column_config.NumberColumn("Suele darse a (días)", format="%.0f"),
                            "tramo_barato": "Tramo más barato",
                            "ventaja_tramo": st.column_config.NumberColumn("Ventaja del tramo", format="%+.0f %%")})
        ida = m[m["sentido"] == "IDA"].sort_values("dias_min")
        if not ida.empty:
            fig = px.bar(ida, x="ciudad", y="dias_min", color_discrete_sequence=COLORES,
                         labels={"ciudad": "", "dias_min": "Días antes de la salida (mediana del mínimo, solo ida)"})
            estilo(fig, alto=380)
            st.plotly_chart(fig, width="stretch")

    st.subheader("6. Qué hago con esto")
    umbral = umbral_vol or (info.get("umbral", 0) if not tabla.empty else 0)
    if not umbral:
        st.info("Todavía no hay un umbral claro. Descarga más días y vuelve a mirarlo.")
        return
    fuente = "la volatilidad real" if umbral_vol else "la curva de antelación"
    st.success(f"**Umbral recomendado: {umbral} días** (según {fuente}). Los vuelos que salen dentro de ese "
               "plazo son los que cambian de precio; los demás se pueden dejar semanas sin refrescar.")
    if not ctrl:
        guardar_config(umbral=int(umbral))
    cfg = leer_config()
    destinos = cfg.get("destinos") or list(destinos_script())
    c1, c2 = st.columns([1, 2])
    if c1.button(f"🔄 Refrescar los próximos {umbral} días", type="primary", disabled=descargando()):
        with st.spinner("Calculando consultas…"):
            n = pendientes(CSV, destinos, int(umbral), 12)
        if n == 0:
            st.toast("Ya están recién descargados", icon="✅")
        else:
            hilos, cps, cps_max = VELOCIDADES.get(cfg.get("velocidad", ""), VELOCIDADES["🚶 Normal"])
            args = ["--dias", str(int(umbral)), "--salida", CSV, "--opciones", CSV_OPC,
                    "--actualizar", "12", "--destinos", *destinos,
                    "--hilos", str(hilos), "--velocidad", str(cps), "--velocidad-max", str(cps_max)]
            confirmar_descarga(args, n, destinos, seg=1 / cps)
    c2.caption("Vuelve a descargar solo esos días (los que se bajaron hace menos de 12 h se saltan). "
               "Además, a partir de ahora toda descarga consulta primero esos días.")


def codigos_de_ciudades(nombres):
    """Códigos de destino a partir de los nombres de ciudad del filtro del Buscador."""
    nombres = set(nombres)
    return [c for c, n in destinos_script().items() if n in nombres]


def existentes_vuelos():
    """(codigo, sentido, fecha) que ya están en el CSV de vuelos (con o sin precio)."""
    if df.empty or "sentido" not in df.columns:
        return set()
    return set(zip(df["codigo"], df["sentido"], df["fecha"].astype(str)))


def universo_vuelos_filtrado(sel, dias):
    """Trayectos (codigo, sentido, fecha_iso) que encajan con los filtros del Buscador que se
    pueden aplicar a vuelos todavía sin descargar: destino, fecha de salida y de vuelta, día de
    la semana de salida y noches. (Aerolínea, horario, escalas o presupuesto solo se pueden
    aplicar a vuelos que ya tienes.)"""
    cods = codigos_de_ciudades(F["ciudades"]) if F["ciudades"] else list(sel)
    noches = tuple(F["noches"]) or (1,)
    manana = date.today() + timedelta(days=1)
    fin_dias = manana + timedelta(days=int(dias) - 1)
    if F["fecha_libre"]:
        i0, i1 = manana, fin_dias
    else:
        i0, i1 = max(F["rango"][0], manana), min(F["rango"][1], manana + timedelta(days=364))
    if F["vuelta_libre"]:
        v0, v1 = manana, fin_dias + timedelta(days=max(noches))
    else:
        v0, v1 = max(F["rango_vuelta"][0], manana), F["rango_vuelta"][1]
    pares = set()
    d = i0
    while d <= i1:
        if not F["dias_sem"] or DIAS[d.weekday()] in F["dias_sem"]:
            for n in noches:
                v = d + timedelta(days=n)
                if v0 <= v <= v1:
                    for c in cods:
                        pares.add((c, "IDA", d.isoformat()))
                        pares.add((c, "VUELTA", v.isoformat()))
        d += timedelta(days=1)
    return pares


def existentes_hoteles():
    """(codigo, fecha_entrada) que ya están en el CSV de alojamientos."""
    if not hay_hoteles:
        return set()
    h = cargar_hoteles(mt_hot)
    return set(zip(h["codigo"], h["fecha_entrada"].dt.strftime("%Y-%m-%d")))


def universo_fechas_hoteles(dias):
    """Fechas de entrada (iso) desde mañana durante `dias` días."""
    manana = date.today() + timedelta(days=1)
    return [(manana + timedelta(days=k)).isoformat() for k in range(int(dias))]


def universo_hoteles_filtrado(sel, dias):
    """(codigo, fecha_entrada_iso) que encajan con los filtros de ciudad y fecha del Buscador."""
    cods = codigos_de_ciudades(F["ciudades"]) if F["ciudades"] else list(sel)
    manana = date.today() + timedelta(days=1)
    if F["fecha_libre"]:
        i0, i1 = manana, manana + timedelta(days=int(dias) - 1)
    else:
        i0, i1 = max(F["rango"][0], manana), min(F["rango"][1], manana + timedelta(days=364))
    fechas = [(i0 + timedelta(days=k)).isoformat() for k in range(max((i1 - i0).days + 1, 0))]
    return {(c, f) for c in cods for f in fechas}


def resumen_filtros_descarga(sel, hoteles=False):
    """Una línea con los filtros del Buscador que aplican los modos «con filtros»."""
    p = ["destinos: " + (", ".join(F["ciudades"][:3]) + ("…" if len(F["ciudades"]) > 3 else "")
                         if F["ciudades"] else f"los {len(sel)} elegidos arriba")]
    if not F["fecha_libre"]:
        p.append(f"salida {F['rango'][0]:%d/%m/%y}–{F['rango'][1]:%d/%m/%y}" if not hoteles
                 else f"entrada {F['rango'][0]:%d/%m/%y}–{F['rango'][1]:%d/%m/%y}")
    if not hoteles:
        if not F["vuelta_libre"]:
            p.append(f"vuelta {F['rango_vuelta'][0]:%d/%m/%y}–{F['rango_vuelta'][1]:%d/%m/%y}")
        if F["dias_sem"]:
            p.append("sale: " + ", ".join(F["dias_sem"]))
        if F["noches"]:
            p.append(f"{min(F['noches'])}–{max(F['noches'])} noches")
    return " · ".join(p)


def bloque_region(clave, grupos, dias, por_dia, en_curso, lanzar, nota=""):
    """Descarga única por región: eliges una o varias zonas y un botón baja TODO de ellas
    (con los días de arriba), sin tocar la selección de destinos ni los filtros."""
    if not grupos:
        return
    with st.container(border=True):
        st.markdown("**⚡ Descarga única por región**")
        reg = st.multiselect("Regiones", list(grupos), key=f"{clave}_reg", placeholder="Elige una o varias",
                             format_func=lambda g: f"{g} ({len(grupos[g])})")
        cods = [c for g in reg for c in grupos[g]]
        n = len(cods) * dias * por_dia
        st.caption((f"{len(cods)} destinos · {n:,} consultas".replace(",", ".") if cods else
                    "Descarga todos los destinos de esas regiones de una vez, con los días de arriba.")
                   + (f" {nota}" if nota else ""))
        if st.button("⚡ Descargar todo de estas regiones", type="primary", width="stretch",
                     key=f"{clave}_reg_go", disabled=en_curso or not cods,
                     help="Vuelve a bajar todo de las regiones elegidas, esté o no descargado."):
            lanzar(cods, n)


def descargas_vuelos():
    """Descarga de vuelos: 4 modos de un clic (todo / solo lo nuevo, con o sin filtros)."""
    if not os.path.exists(SCRIPT):
        return st.error(f"No encuentro {SCRIPT} en la carpeta de la app.")
    en_curso = descargando("vuelos")
    todos = destinos_script()
    cfg = leer_config()
    nombre = lambda k: f"{todos.get(k, k)} ({k})"
    grupos = grupos_script()
    with st.container(border=True):
        st.markdown("**Destinos y ritmo**")
        st.session_state.setdefault(
            "dl_destinos", [k for k in cfg.get("destinos", list(todos)) if k in todos])
        sel = st.multiselect("Destinos", list(todos), format_func=nombre, key="dl_destinos")
        if grupos:
            g1, g2, g3 = st.columns([3, 1, 1])
            elegidos = g1.multiselect("Grupos", list(grupos), key="dl_grupos",
                                      placeholder="Añadir o quitar zonas enteras",
                                      format_func=lambda g: f"{g} ({len(grupos[g])})")
            codigos_grupo = [c for g in elegidos for c in grupos[g]]

            def _añadir():
                st.session_state["dl_destinos"] = sorted(
                    set(st.session_state["dl_destinos"]) | set(codigos_grupo), key=list(todos).index)

            def _quitar():
                st.session_state["dl_destinos"] = [c for c in st.session_state["dl_destinos"]
                                                   if c not in codigos_grupo]
            g2.button("➕ Añadir", width="stretch", on_click=_añadir, disabled=not elegidos)
            g3.button("➖ Quitar", width="stretch", on_click=_quitar, disabled=not elegidos)
            st.caption(f"{len(sel)} de {len(todos)} destinos seleccionados · "
                       f"{len(sel) * 2:,}".replace(",", ".") + " consultas por día de calendario.")
        prio, peso = [], 70      # las descargas prioritarias se han quitado en la 1.4
        v1, v2 = st.columns([1, 2])
        st.session_state.setdefault("dl_vel", cfg.get("velocidad") if cfg.get("velocidad")
                                    in VELOCIDADES else list(VELOCIDADES)[1])
        vel = v1.selectbox("Velocidad", list(VELOCIDADES), key="dl_vel")
        hilos, cps, cps_max = VELOCIDADES[vel]
        v2.caption(f"Empieza a {cps * 60:.0f} consultas/min y sube sola hasta "
                   f"**{cps_max * 60:.0f}/min** si Google no bloquea; si bloquea, baja a la mitad y "
                   f"sigue. Consumo máximo: {cps_max * 0.29:.1f} MB/s. «🚀 Máxima» es la que más "
                   "riesgo tiene de captchas.")
        st.session_state.setdefault("dl_dias", int(cfg.get("dias", 90)))
        dias = st.slider("Días hacia delante", 7, 365, step=7, key="dl_dias")

    bloqueado = en_curso or not sel
    args_pares_v = lambda pares: ["--salida", CSV, "--opciones", CSV_OPC, *args_pares(pares),
                                  "--hilos", str(hilos), "--velocidad", str(cps),
                                  "--velocidad-max", str(cps_max)]
    with st.container(border=True):
        st.markdown("**Descargar**")
        if en_curso:
            st.caption("⏳ Hay una descarga de vuelos en curso: los botones se activan cuando termine "
                       "(o si la detienes). Mientras tanto puedes usar toda la app.")
        st.caption("«Con filtros» usa los filtros del Buscador (barra lateral) → "
                   + resumen_filtros_descarga(sel))
        b1, b2 = st.columns(2)
        b3, b4 = st.columns(2)
        if b1.button("📦 Descargar todo", type="primary", width="stretch", key="dl_v_todo",
                     disabled=bloqueado,
                     help="Vuelve a bajar TODOS los precios de los destinos y días elegidos arriba, "
                          "estén o no ya descargados."):
            confirmar_descarga(construir_args(sel, prio, peso, vel, dias, 0), len(sel) * dias * 2, sel,
                               seg=1 / cps)
        b1.caption(f"{len(sel) * dias * 2:,} consultas".replace(",", "."))
        if b2.button("🎯 Descargar todo con filtros", width="stretch", key="dl_v_todo_f",
                     disabled=bloqueado or not hay_datos,
                     help="Vuelve a bajar los trayectos que ves ahora mismo en el Buscador (con todos sus "
                          "filtros: destino, fechas, aerolínea, horario, escalas, presupuesto…)."):
            with st.spinner("Buscando los vuelos que cumplen tus filtros…"):
                c_f = combinaciones()
            if c_f.empty:
                st.toast("No hay combinaciones con los filtros actuales", icon="⚠️")
            else:
                pares = pares_vuelos_de((r.codigo, r.ida.date().isoformat(), r.vuelta.date().isoformat())
                                        for r in c_f.itertuples())
                confirmar_descarga([*args_pares_v(pares), "--actualizar", "0"], len(pares),
                                   sorted(c_f["codigo"].unique()), seg=1 / cps)
        b2.caption("Lo que ves en el Buscador, refrescado")
        if b3.button("🆕 Descargar solo lo nuevo", width="stretch", key="dl_v_nuevo", disabled=bloqueado,
                     help="Solo los precios que todavía no están descargados de los destinos y días "
                          "elegidos. No toca lo que ya tienes."):
            with st.spinner("Calculando consultas pendientes…"):
                n = pendientes(CSV, sel, dias, None)
            if n == 0:
                st.toast("Ya está todo descargado con esas opciones", icon="✅")
            else:
                confirmar_descarga(construir_args(sel, prio, peso, vel, dias, None), n, sel, seg=1 / cps)
        b3.caption("Lo que falta, sin repetir nada")
        if b4.button("🆕 Descargar solo lo nuevo con filtros", width="stretch", key="dl_v_nuevo_f",
                     disabled=bloqueado,
                     help="Lo que falta dentro de los filtros del Buscador que se pueden aplicar a "
                          "vuelos aún sin descargar: destino, fechas, día de salida y noches."):
            with st.spinner("Calculando lo que falta con esos filtros…"):
                nuevos = universo_vuelos_filtrado(sel, dias) - existentes_vuelos()
            if not nuevos:
                st.toast("No falta nada dentro de esos filtros", icon="✅")
            else:
                pares = pares_de(sorted(nuevos))
                confirmar_descarga(args_pares_v(pares), len(pares), sorted({p[0] for p in nuevos}),
                                   seg=1 / cps)
        b4.caption("Lo que falta dentro de tus filtros")
    bloque_region("dl_v", grupos, dias, 2, en_curso,
                  lambda cods, n: confirmar_descarga(construir_args(cods, [], peso, vel, dias, 0), n, cods,
                                                     seg=1 / cps))

    with st.expander("⚙️ Otros modos: refrescar lo antiguo, solo el próximo mes, sondeo por meses"):
        st.session_state.setdefault("dl_modo", cfg.get("modo") if cfg.get("modo") in MODOS else MODOS[0])
        modo = st.radio("Qué descargar", MODOS, key="dl_modo")
        sondeo_n = 0
        if modo == MODOS[3]:
            st.session_state.setdefault("dl_sondeo", int(cfg.get("sondeo", 10)))
            sondeo_n = st.number_input("Vuelos al azar que comprueba por mes", 3, 30, key="dl_sondeo")
            st.caption(f"Comprueba {sondeo_n} vuelos ya descargados de cada mes. Si en un mes "
                       "cambian más de 5 € **la mayoría**, ese mes se vuelve a descargar entero; "
                       "el resto se deja como está.")
        if st.button("Descargar con este modo", key="dl_v_otro", disabled=bloqueado):
            horas = HORAS_MODO[modo]
            dias_m = min(dias, 31) if modo == MODOS[2] else dias
            with st.spinner("Calculando consultas pendientes…"):
                n = pendientes(CSV, sel, dias_m, horas)
            if n == 0:
                st.toast("Ya está todo descargado con esas opciones", icon="✅")
            else:
                confirmar_descarga(construir_args(sel, prio, peso, vel, dias_m, horas, sondeo_n), n, sel,
                                   seg=1 / cps)
    guardar_config(destinos=sel, velocidad=vel, dias=dias,
                   modo=modo, sondeo=int(sondeo_n) if sondeo_n else cfg.get("sondeo", 10))

    with st.expander("🎲 Muestreo por probabilidad de subida"):
        st.markdown("**Muestreo por probabilidad de subida**")
        st.caption("De los vuelos que cumplen tus filtros actuales (⭐ Buscador), sortea cuáles "
                   "redescargar: a cada uno se le compara un número al azar (uniforme entre 0 y "
                   "1) con su probabilidad estimada de haber subido desde la última descarga. "
                   "Cuanto más probable que haya cambiado, más papeletas tiene, pero no es "
                   "determinista — es un muestreo, no un umbral fijo.")
        cand, tsub_m = vuelos_candidatos_muestreo()
        if tsub_m.empty:
            st.caption("Todavía no hay histórico suficiente para esto.")
        elif cand.empty:
            st.caption("Ningún vuelo cumple ahora mismo tus filtros.")
        else:
            st.caption(f"{len(cand)} vuelo(s) candidatos · probabilidad media de subida "
                       f"{cand['prob_subida'].mean():.0%}.")
            if st.button("🎲 Sortear y redescargar", disabled=en_curso, key="dl_muestreo_vuelos"):
                azar = np.random.uniform(0, 1, size=len(cand))
                sorteados = cand[azar < cand["prob_subida"].to_numpy()]
                if sorteados.empty:
                    st.toast("El sorteo no ha tocado a ninguno esta vez. Prueba de nuevo.", icon="🎲")
                else:
                    pares = pares_de((r.codigo, r.sentido, r.fecha.isoformat())
                                     for r in sorteados.itertuples())
                    confirmar_descarga([*args_pares_v(pares), "--actualizar", "0"], len(pares),
                                       sorted(sorteados["codigo"].unique()), seg=0.7)
    with st.expander("⏱️ Descargas periódicas"):
        programacion(sel, prio, peso, vel, dias, modo, sondeo_n)


def tabla_datos_vuelos():
    r = (df.assign(ok=df["precio_eur"].notna())
         .groupby("ciudad").agg(dias_con_precio=("ok", "sum"), desde=("fecha", "min"),
                                hasta=("fecha", "max"), ultima_descarga=("ultima_descarga", "max"))
         .reset_index())
    st.dataframe(r, hide_index=True, width="stretch", column_config={
        "ciudad": "Destino", "dias_con_precio": "Trayectos con precio",
        "desde": st.column_config.DateColumn("Desde", format="DD/MM/YY"),
        "hasta": st.column_config.DateColumn("Hasta", format="DD/MM/YY"),
        "ultima_descarga": "Última descarga"})


def tabla_datos_trenes():
    tt = cargar_trenes(mt_tren)
    r = (tt.groupby("ciudad").agg(trenes=("tren", "size"), desde=("fecha", "min"), hasta=("fecha", "max"),
                                  companias=("compania", lambda x: ", ".join(sorted(set(x)))),
                                  ultima_descarga=("consulta", "max")).reset_index())
    st.dataframe(r, hide_index=True, width="stretch", column_config={
        "ciudad": "Destino", "trenes": "Trenes descargados",
        "desde": st.column_config.DateColumn("Desde", format="DD/MM/YY"),
        "hasta": st.column_config.DateColumn("Hasta", format="DD/MM/YY"),
        "companias": "Compañías",
        "ultima_descarga": st.column_config.DatetimeColumn("Última descarga", format="DD/MM HH:mm")})


def descargas_todos():
    """Descarga única de vuelos + trenes + hoteles de las mismas regiones, con un solo botón."""
    cfg = leer_config()
    g_vue, g_tren = grupos_script(), grupos_tren()
    dest_vue, dest_tren = destinos_script(), destinos_tren()
    regiones = [*g_vue, *[g for g in g_tren if g not in g_vue]]
    if not regiones:
        return st.info("No hay regiones disponibles.")
    with st.container(border=True):
        st.markdown("**🌍 Regiones**")
        reg = st.multiselect("Regiones", regiones, key="dt_reg", placeholder="Elige una o varias",
                             format_func=lambda g: f"{g} ({len(g_vue.get(g, g_tren.get(g, [])))})",
                             help="Los destinos de vuelos y hoteles y los de tren se emparejan por nombre de ciudad: "
                                  "al elegir «Cataluña» se bajan también los vuelos y hoteles de Barcelona, "
                                  "Girona…, y al elegir «Francia» los trenes de Marsella, Montpellier…")
        tipos = st.multiselect("Qué descargar", ["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles"],
                               default=["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles"], key="dt_tipos")
        manana = date.today() + timedelta(days=1)
        dias_cfg = int(cfg.get("dias", 90))
        _r = st.session_state.get("dt_rango")        # un rango guardado de otro día puede quedar fuera de los límites
        if isinstance(_r, (tuple, list)) and _r and (min(_r) < manana or max(_r) > manana + timedelta(days=364)):
            st.session_state.pop("dt_rango")
        rango = st.date_input("Fechas a descargar (desde – hasta)", value=(manana, manana + timedelta(days=dias_cfg - 1)),
                              min_value=manana, max_value=manana + timedelta(days=364), key="dt_rango",
                              format="DD/MM/YYYY",
                              help="Mismo rango para vuelos, trenes y hoteles. Los trenes solo se venden con "
                                   "unos meses de antelación, así que para ellos se recorta a 180 días desde el primer día.")
        if not (isinstance(rango, (tuple, list)) and len(rango) == 2):
            st.caption("Elige también el último día del rango.")
            return
        f_desde, f_hasta = rango
        d_v = d_h = (f_hasta - f_desde).days + 1
        f_hasta_t = min(f_hasta, f_desde + timedelta(days=179))
        d_t = (f_hasta_t - f_desde).days + 1
        if d_t < d_v:
            st.caption(f"🚆 Trenes: se descargan {d_t} días ({f_desde:%d/%m} – {f_hasta_t:%d/%m}); más allá no hay billetes a la venta.")

    # destinos de cada tipo: los del grupo propio + los que coinciden por nombre de ciudad
    por_nombre_v = {}
    for k, nom in dest_vue.items():
        por_nombre_v.setdefault(_norm_ciudad(nom), []).append(k)
    por_nombre_t = {}
    for k, nom in dest_tren.items():
        por_nombre_t.setdefault(_norm_ciudad(nom), []).append(k)
    cv, ct = [], []
    for g in reg:
        if g in g_vue:
            cv += list(g_vue[g])
            ct += [c for k in g_vue[g] for c in por_nombre_t.get(_norm_ciudad(dest_vue.get(k, "")), [])]
        if g in g_tren:
            ct += list(g_tren[g])
            cv += [c for k in g_tren[g] for c in por_nombre_v.get(_norm_ciudad(dest_tren.get(k, "")), [])]
    cv, ct = list(dict.fromkeys(cv)), list(dict.fromkeys(ct))
    quiere_v, quiere_t, quiere_h = "✈️ Vuelos" in tipos, "🚆 Trenes" in tipos, "🏨 Hoteles" in tipos
    n_v, n_t, n_h = len(cv) * d_v * 2, len(ct) * d_t * 2, len(cv) * d_h
    plan = [("✈️ Vuelos", len(cv), n_v, "vuelos", quiere_v and cv),
            ("🚆 Trenes", len(ct), n_t, "trenes", quiere_t and ct),
            ("🏨 Hoteles", len(cv), n_h, "hoteles", quiere_h and cv)]
    with st.container(border=True):
        st.markdown("**Lo que se va a descargar**")
        if not reg:
            st.caption("Elige al menos una región.")
        for et, nd, n, tipo, activo in plan:
            if not reg:
                break
            estado = ("⏳ ya hay una descarga en curso: se salta" if activo and descargando(tipo)
                      else "" if activo else "— no seleccionado" if nd else "— sin destinos en esa región")
            st.write(f"{et}: **{nd}** destinos · **{n:,}** consultas {estado}".replace(",", "."))
        libres = [p_ for p_ in plan if p_[4] and not descargando(p_[3])]
        if st.button("⚡ Descargar todo de estas regiones", type="primary", width="stretch", key="dt_go",
                     disabled=not reg or not libres,
                     help="Lanza a la vez las descargas de vuelos, trenes y hoteles de las regiones elegidas."):
            vel = cfg.get("velocidad") if cfg.get("velocidad") in VELOCIDADES else list(VELOCIDADES)[1]
            hilos, cps, cps_max = VELOCIDADES[vel]
            tot = 0
            for et, nd, n, tipo, activo in libres:
                if tipo == "vuelos":
                    lanzar([*construir_args(cv, [], 70, vel, d_v, 0), "--desde", f_desde.isoformat(),
                            "--hasta", f_hasta.isoformat()], tipo="vuelos", n=n)
                elif tipo == "trenes":
                    lanzar(["--destinos", *ct, "--desde", f_desde.isoformat(), "--hasta", f_hasta_t.isoformat(),
                            "--sentidos", "ida", "vuelta", "--salida", CSV_TREN, "--actualizar", "0"],
                           script=SCRIPT_TREN, tipo="trenes", n=n)
                else:
                    lanzar(["--destinos", *cv, "--desde", f_desde.isoformat(), "--hasta", f_hasta.isoformat(),
                            "--noches", "1", "--salida", CSV_HOT, "--actualizar", "0"],
                           script=SCRIPT_HOT, tipo="hoteles", n=n)
                tot += n
            st.session_state["aviso"] = ("🚀", f"Descarga iniciada: {len(libres)} tipos · {tot:,} consultas".replace(",", "."))
            st.rerun()
    st.caption("Cada tipo se descarga en su propio proceso, así que van a la vez y puedes seguir usando la app. "
               "El progreso de cada uno se ve arriba y en el recuadro de abajo a la derecha.")


def pag_descargas():
    titulo_pagina("⬇️", "Descargas", "Qué precios bajar y cómo · puedes seguir usando la app mientras descarga")
    auto_refresco(lambda: progreso_detallado("vuelos"), min(intervalo_refresco(), 30))
    auto_refresco(lambda: progreso_detallado("hoteles"), min(intervalo_refresco(), 30))
    auto_refresco(lambda: progreso_detallado("trenes"), min(intervalo_refresco(), 30))
    s1, s2, s3 = st.columns(3)
    if descargando("vuelos") and s1.button("⏹️ Detener descarga de vuelos", key="stop_vuelos"):
        confirmar_parada("vuelos")
    if descargando("hoteles") and s2.button("⏹️ Detener descarga de hoteles", key="stop_hoteles"):
        confirmar_parada("hoteles")
    if descargando("trenes") and s3.button("⏹️ Detener descarga de trenes", key="stop_trenes"):
        confirmar_parada("trenes")
    if descargando():
        st.caption("Puedes cambiar de página mientras descarga: el progreso se ve en el recuadro de "
                   "abajo a la derecha.")
    tab_v, tab_t, tab_h, tab_a = st.tabs(["✈️ Vuelos", "🚆 Trenes", "🏨 Hoteles", "🌍 Todos"])
    with tab_a:
        descargas_todos()
    with tab_v:
        descargas_vuelos()
        desplegable("🥧 Cobertura de tus filtros", cobertura, "dz_cobertura")
        desplegable("🔎 Último sondeo por meses", tabla_sondeos, "dz_sond_vue")
        if hay_datos:
            desplegable("📋 Datos descargados", tabla_datos_vuelos, "dz_datos_vue")
    with tab_t:
        with st.spinner("Cargando trenes…"):
            descargas_trenes()
        if hay_trenes:
            desplegable("📋 Datos descargados", tabla_datos_trenes, "dz_datos_tren")
    with tab_h:
        with st.spinner("Cargando hoteles…"):
            descargas_hotel()
    desplegable("⚠️ Frecuencia de errores", tabla_errores, "dz_errores")


if (_mt := mt_estable(HISTORICO, "mt_hist_fav")) != st.session_state.get("toast_fav_mt"):
    st.session_state["toast_fav_mt"] = _mt
    if _t := texto_aviso_favoritos(*favoritos_bajados()):
        st.toast(_t, icon="📉")

pg.run()
:::END
:::BEGIN py/vuelos_madrid.py|text
"""
Descarga el precio más barato de vuelo de SOLO IDA para cada día del próximo año:
  - IDA:    Madrid (MAD) -> destino
  - VUELTA: destino -> Madrid (MAD)
y lo guarda en un CSV listo para abrir en Excel (separador ';' y coma decimal).

Fuente: Google Flights mediante la librería `fast-flights` (no oficial).

Instalación:
    pip install fast-flights primp

Uso:
    python vuelos_madrid.py                      # todos los destinos, 365 días
    python vuelos_madrid.py --dias 60            # solo los próximos 60 días
    python vuelos_madrid.py --destinos LIS FCO   # solo algunos destinos
    python vuelos_madrid.py --combinar           # además genera combinaciones ida+vuelta
    python vuelos_madrid.py --actualizar         # vuelve a descargar todos los precios
    python vuelos_madrid.py --actualizar 72      # solo los descargados hace más de 72 h

El script es REANUDABLE: si lo cortas (Ctrl+C) o falla, al relanzarlo se salta
lo que ya está en el CSV. Con --actualizar refresca precios: se conserva el
precio anterior y la columna 'ultima_descarga' indica cuándo se bajó cada uno.
'enlace_reserva' abre esa búsqueda en Google Flights, desde donde se reserva.
"""

import argparse
import csv
import os
import random
import sys
import time
from collections import deque
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import date, datetime, timedelta
from threading import Lock, local

from fast_flights import FlightQuery, Passengers, create_query
from fast_flights.parser import parse
from primp import Client

URL_GOOGLE = "https://www.google.com/travel/flights"
# Cookies de "consentimiento aceptado": sin ellas, desde Europa Google devuelve la
# página "Antes de ir a Google" en vez de los vuelos.
COOKIES = {
    "SOCS": "CAESEwgDEgk0ODE3Nzk3MjQaAmVzIAEaBgiA_LyaBg",
    "CONSENT": "YES+cb.20240101-00-p0.es+FX+000",
}
_hilo = local()
_print_lock = Lock()


def log(msg, err=False):
    with _print_lock:
        print(msg, file=sys.stderr if err else sys.stdout, flush=True)


class PaginaCookies(Exception):
    pass


def tipo_error(e):
    m = str(e).lower()
    if isinstance(e, Bloqueo) or "captcha" in m or "inusual" in m:
        return "Captcha / tráfico inusual"
    if isinstance(e, PaginaCookies) or "cookies" in m:
        return "Página de cookies"
    if "sin datos" in m:
        return "Página sin datos de vuelos"
    if any(k in m for k in ("timeout", "timed out", "connect", "dns", "network", "connection", "reset")):
        return "Error de red"
    return "Otro"


def registrar_error(tipo, origen, destino, fecha, mensaje):
    """Añade el error al historial (errores_descarga.csv)."""
    try:
        nuevo = not os.path.exists(CSV_ERRORES)
        with _print_lock, open(CSV_ERRORES, "a", encoding="utf-8-sig" if nuevo else "utf-8", newline="") as f:
            w = csv.writer(f, delimiter=";")
            if nuevo:
                w.writerow(["momento", "tipo", "origen", "destino", "fecha_vuelo", "mensaje"])
            w.writerow([datetime.now().strftime("%Y-%m-%d %H:%M:%S"), tipo, origen, destino,
                        str(fecha), str(mensaje)[:200]])
    except OSError:
        pass


class Bloqueo(Exception):
    pass


_bloqueo = {"hasta": 0.0}


class Ritmo:
    """Reparte las consultas en el tiempo a X por segundo y ajusta esa velocidad sola:
    la baja a la mitad cuando Google bloquea y la sube poco a poco si todo va bien."""

    def __init__(self, cps=2.0, cps_max=6.0):   # valores reales: ver VELOCIDAD más abajo
        # Arranca siempre prudente (<=1 consulta/s) sea el que sea el "cps" pedido: la
        # velocidad real la decide lo que vaya pasando (sube si no hay bloqueos, baja si
        # los hay), no un valor alto elegido de antemano que dispare el captcha nada más
        # empezar. cps_max sigue marcando el techo al que puede llegar si va todo bien.
        self.cps = max(0.05, min(cps, cps_max, 1.0))
        self.cps_max = max(0.05, cps_max)
        self.siguiente = time.time()
        self.exitos = 0
        self.lock = Lock()

    def esperar(self):
        with self.lock:
            t = max(self.siguiente, time.time())
            self.siguiente = t + 1 / self.cps
        espera = t - time.time()
        if espera > 0:
            time.sleep(espera)

    def ok(self):
        with self.lock:
            self.exitos += 1
            if self.exitos >= 150 and self.cps < self.cps_max:
                self.cps = min(self.cps_max, self.cps * 1.25)
                self.exitos = 0
                nueva = self.cps
            else:
                return
        log(f"  ^ sin bloqueos: subo a {nueva:.1f} consultas/s")

    def frenar(self):
        with self.lock:
            self.cps = max(0.1, self.cps / 2)
            self.exitos = 0
            nueva = self.cps
        log(f"  v bloqueo: bajo a {nueva:.1f} consultas/s", err=True)


ritmo = Ritmo()


def _cliente():
    if not hasattr(_hilo, "c"):
        _hilo.c = Client(impersonate="chrome_145", impersonate_os="windows", referer=True,
                         cookie_store=True, cookies=COOKIES, timeout=30,
                         headers={"Accept-Language": "es-ES,es;q=0.9"})
    return _hilo.c


def descargar(q):
    html = _cliente().get(URL_GOOGLE, params=q.params(), cookies=COOKIES).text
    if "ds:1" not in html:
        if "consent" in html.lower() or "antes de ir a google" in html.lower():
            _hilo.__dict__.pop("c", None)
            raise PaginaCookies("Google ha devuelto la página de cookies en lugar de los vuelos")
        bajo = html.lower()
        if any(k in bajo for k in ("unusual traffic", "tráfico inusual", "trafico inusual", "/sorry/", "captcha")):
            raise Bloqueo("Google pide captcha por tráfico inusual")
        raise RuntimeError("Google ha devuelto una página sin datos de vuelos")
    try:
        return parse(html)
    except (TypeError, IndexError):   # página válida pero sin resultados (ruta sin vuelos ese día)
        return []

# ============================== CONFIGURACIÓN ==============================

ORIGEN = "MAD"

# Edita libremente: código IATA -> nombre que verás en el Excel
# Aeropuertos agrupados por zona. La lista sale de barrer los ~7.900 códigos IATA del mundo contra
# Google Flights: 170 tienen vuelo DIRECTO desde Madrid (grupo «Vuelo directo desde Madrid») y el
# resto se alcanza con una escala. Los códigos de ciudad agrupan todos los aeropuertos de esa ciudad
# (LON = Heathrow + Gatwick + Stansted + City; PAR = CDG + Orly; MIL = Malpensa + Linate + Bérgamo;
# ROM = Fiumicino + Ciampino; STO = Arlanda), por eso esos aeropuertos no aparecen por separado.
GRUPOS = {
    "Principales (varios aeropuertos)": {
        "PAR": "París",
        "ROM": "Roma",
        "MIL": "Milán",
        "LON": "Londres",
        "STO": "Estocolmo",
    },
    "Capitales UE": {
        "LIS": "Lisboa",
        "PAR": "París",
        "ROM": "Roma",
        "BER": "Berlín",
        "AMS": "Ámsterdam",
        "BRU": "Bruselas",
        "LUX": "Luxemburgo",
        "DUB": "Dublín",
        "CPH": "Copenhague",
        "STO": "Estocolmo",
        "HEL": "Helsinki",
        "TLL": "Tallin",
        "RIX": "Riga",
        "VNO": "Vilna",
        "WAW": "Varsovia",
        "PRG": "Praga",
        "VIE": "Viena",
        "BTS": "Bratislava",
        "BUD": "Budapest",
        "LJU": "Liubliana",
        "ZAG": "Zagreb",
        "OTP": "Bucarest",
        "SOF": "Sofía",
        "ATH": "Atenas",
        "LCA": "Nicosia (Lárnaca)",
        "MLA": "La Valeta (Malta)",
    },
    "Secundarios low cost": {
        "CRL": "Bruselas-Charleroi",
        "BVA": "París-Beauvais",
        "WMI": "Varsovia-Modlin",
        "EIN": "Eindhoven (Ámsterdam)",
        "RTM": "Róterdam",
        "MST": "Maastricht",
        "BSL": "Basilea-Mulhouse",
        "LIL": "Lille",
        "TRF": "Oslo-Torp",
        "BLL": "Billund",
        "PIK": "Glasgow-Prestwick",
    },
    "Vuelo directo desde Madrid": {
        "ACE": "Lanzarote",
        "ADB": "Esmirna",
        "AGA": "Agadir",
        "AGP": "Málaga",
        "ALC": "Alicante",
        "AMM": "Ammán",
        "AMS": "Ámsterdam",
        "AOI": "Ancona",
        "ASU": "Asunción",
        "ATH": "Atenas",
        "ATL": "Atlanta",
        "AUH": "Abu Dabi",
        "BCN": "Barcelona",
        "BEG": "Belgrado",
        "BER": "Berlín",
        "BEY": "Beirut",
        "BHX": "Birmingham",
        "BIO": "Bilbao",
        "BJZ": "Badajoz",
        "BLQ": "Bolonia",
        "BOD": "Burdeos",
        "BOG": "Bogotá",
        "BOS": "Boston",
        "BRI": "Bari",
        "BRS": "Bristol",
        "BRU": "Bruselas",
        "BSL": "Basilea-Mulhouse",
        "BUD": "Budapest",
        "CAI": "El Cairo",
        "CDT": "Castellón",
        "CLJ": "Cluj",
        "CLO": "Cali",
        "CLT": "Charlotte",
        "CMN": "Casablanca",
        "COR": "Córdoba (Argentina)",
        "CPH": "Copenhague",
        "CRA": "Craiova",
        "CRL": "Bruselas-Charleroi",
        "CTA": "Catania",
        "CTG": "Cartagena de Indias",
        "CUN": "Cancún",
        "DFW": "Dallas",
        "DOH": "Doha",
        "DSS": "Dakar-Blaise Diagne",
        "DUB": "Dublín",
        "DUS": "Düsseldorf",
        "DXB": "Dubái",
        "EAS": "San Sebastián",
        "EDI": "Edimburgo",
        "ESB": "Ankara",
        "EWR": "Nueva York (Newark)",
        "EZE": "Buenos Aires",
        "FAO": "Faro",
        "FEZ": "Fez",
        "FLR": "Florencia",
        "FOR": "Fortaleza",
        "FRA": "Fráncfort",
        "FUE": "Fuerteventura",
        "GDL": "Guadalajara",
        "GDN": "Gdansk",
        "GIG": "Río de Janeiro",
        "GRU": "São Paulo",
        "GRX": "Granada",
        "GUA": "Ciudad de Guatemala",
        "GVA": "Ginebra",
        "GYE": "Guayaquil",
        "HAM": "Hamburgo",
        "HEL": "Helsinki",
        "HKG": "Hong Kong",
        "IAD": "Washington",
        "IAS": "Iasi",
        "IBZ": "Ibiza",
        "IST": "Estambul",
        "JFK": "Nueva York",
        "JNB": "Johannesburgo",
        "KRK": "Cracovia",
        "KWI": "Kuwait",
        "LAX": "Los Ángeles",
        "LCA": "Nicosia (Lárnaca)",
        "LCG": "A Coruña",
        "LEI": "Almería",
        "LEU": "La Seu d'Urgell",
        "LIM": "Lima",
        "LIS": "Lisboa",
        "LON": "Londres",
        "LPA": "Gran Canaria",
        "LUX": "Luxemburgo",
        "LYS": "Lyon",
        "MAH": "Menorca",
        "MAN": "Mánchester",
        "MDE": "Medellín",
        "MEX": "Ciudad de México",
        "MIA": "Miami",
        "MIL": "Milán",
        "MLA": "La Valeta (Malta)",
        "MLN": "Melilla",
        "MPL": "Montpellier",
        "MRS": "Marsella",
        "MTY": "Monterrey",
        "MUC": "Múnich",
        "MVD": "Montevideo",
        "NCE": "Niza",
        "NDR": "Nador",
        "NRT": "Tokio",
        "NTE": "Nantes",
        "OPO": "Oporto",
        "ORD": "Chicago",
        "OSL": "Oslo",
        "OTP": "Bucarest",
        "OVD": "Asturias",
        "PAR": "París",
        "PHL": "Filadelfia",
        "PMI": "Palma de Mallorca",
        "PMO": "Palermo",
        "PNA": "Pamplona",
        "PRG": "Praga",
        "PSA": "Pisa",
        "PTY": "Panamá",
        "PUJ": "Punta Cana",
        "RAK": "Marrakech",
        "RBA": "Rabat",
        "REC": "Recife",
        "RJL": "Logroño",
        "ROM": "Roma",
        "SAP": "San Pedro Sula",
        "SAW": "Estambul-Sabiha",
        "SBZ": "Sibiu",
        "SCL": "Santiago de Chile",
        "SCQ": "Santiago",
        "SDQ": "Santo Domingo",
        "SDR": "Santander",
        "SFO": "San Francisco",
        "SJO": "San José (Costa Rica)",
        "SJU": "San Juan (Puerto Rico)",
        "SKP": "Skopie",
        "SNN": "Shannon",
        "SOF": "Sofía",
        "SPC": "La Palma",
        "STO": "Estocolmo",
        "SVQ": "Sevilla",
        "SXB": "Estrasburgo",
        "TFN": "Tenerife Norte",
        "TFS": "Tenerife Sur",
        "TIA": "Tirana",
        "TLS": "Toulouse",
        "TLV": "Tel Aviv",
        "TNG": "Tánger",
        "TRN": "Turín",
        "TSR": "Timisoara",
        "TUN": "Túnez",
        "VCE": "Venecia",
        "VGO": "Vigo",
        "VIE": "Viena",
        "VLC": "Valencia",
        "VVI": "Santa Cruz (Bolivia)",
        "WAW": "Varsovia",
        "WMI": "Varsovia-Modlin",
        "WRO": "Breslavia",
        "XRY": "Jerez",
        "YUL": "Montreal",
        "YYZ": "Toronto",
        "ZRH": "Zúrich",
    },
    "España": {
        "LCG": "A Coruña",
        "ALC": "Alicante",
        "LEI": "Almería",
        "OVD": "Asturias",
        "BJZ": "Badajoz",
        "BCN": "Barcelona",
        "BIO": "Bilbao",
        "CDT": "Castellón",
        "FUE": "Fuerteventura",
        "LPA": "Gran Canaria",
        "GRX": "Granada",
        "EAS": "San Sebastián",
        "IBZ": "Ibiza",
        "XRY": "Jerez",
        "SPC": "La Palma",
        "ACE": "Lanzarote",
        "RJL": "Logroño",
        "MLN": "Melilla",
        "MAH": "Menorca",
        "LEU": "La Seu d'Urgell",
        "AGP": "Málaga",
        "PMI": "Palma de Mallorca",
        "PNA": "Pamplona",
        "SDR": "Santander",
        "SCQ": "Santiago",
        "SVQ": "Sevilla",
        "TFN": "Tenerife Norte",
        "TFS": "Tenerife Sur",
        "VLC": "Valencia",
        "VGO": "Vigo",
    },
    "Portugal": {
        "PDL": "Azores (Ponta Delgada)",
        "FAO": "Faro",
        "LIS": "Lisboa",
        "FNC": "Madeira",
        "OPO": "Oporto",
    },
    "Francia": {
        "BSL": "Basilea-Mulhouse",
        "BIQ": "Biarritz",
        "BOD": "Burdeos",
        "SXB": "Estrasburgo",
        "LIL": "Lille",
        "LYS": "Lyon",
        "MRS": "Marsella",
        "MPL": "Montpellier",
        "NTE": "Nantes",
        "NCE": "Niza",
        "PAR": "París",
        "TLS": "Toulouse",
    },
    "Italia": {
        "AOI": "Ancona",
        "BRI": "Bari",
        "BLQ": "Bolonia",
        "CAG": "Cagliari",
        "CTA": "Catania",
        "FLR": "Florencia",
        "MIL": "Milán",
        "NAP": "Nápoles",
        "OLB": "Olbia (Cerdeña)",
        "PMO": "Palermo",
        "PSA": "Pisa",
        "ROM": "Roma",
        "TRN": "Turín",
        "VCE": "Venecia",
        "VRN": "Verona",
    },
    "Alemania": {
        "BER": "Berlín",
        "BRE": "Bremen",
        "CGN": "Colonia",
        "DUS": "Düsseldorf",
        "FRA": "Fráncfort",
        "HAM": "Hamburgo",
        "LEJ": "Leipzig",
        "MUC": "Múnich",
        "NUE": "Núremberg",
        "STR": "Stuttgart",
    },
    "Reino Unido e Irlanda": {
        "BHX": "Birmingham",
        "BRS": "Bristol",
        "ORK": "Cork",
        "DUB": "Dublín",
        "EDI": "Edimburgo",
        "GLA": "Glasgow",
        "PIK": "Glasgow-Prestwick",
        "LPL": "Liverpool",
        "LON": "Londres",
        "MAN": "Mánchester",
        "NCL": "Newcastle",
        "SNN": "Shannon",
    },
    "Benelux": {
        "BRU": "Bruselas",
        "CRL": "Bruselas-Charleroi",
        "EIN": "Eindhoven (Ámsterdam)",
        "LUX": "Luxemburgo",
        "MST": "Maastricht",
        "RTM": "Róterdam",
        "AMS": "Ámsterdam",
    },
    "Suiza y Austria": {
        "GVA": "Ginebra",
        "GRZ": "Graz",
        "INN": "Innsbruck",
        "SZG": "Salzburgo",
        "VIE": "Viena",
        "ZRH": "Zúrich",
    },
    "Nórdicos y Bálticos": {
        "BGO": "Bergen",
        "BLL": "Billund",
        "CPH": "Copenhague",
        "STO": "Estocolmo",
        "GOT": "Gotemburgo",
        "HEL": "Helsinki",
        "OSL": "Oslo",
        "TRF": "Oslo-Torp",
        "KEF": "Reikiavik",
        "RIX": "Riga",
        "SVG": "Stavanger",
        "TLL": "Tallin",
        "TOS": "Tromsø",
        "TRD": "Trondheim",
        "VNO": "Vilna",
    },
    "Europa del Este": {
        "BTS": "Bratislava",
        "WRO": "Breslavia",
        "OTP": "Bucarest",
        "BUD": "Budapest",
        "CLJ": "Cluj",
        "KRK": "Cracovia",
        "CRA": "Craiova",
        "GDN": "Gdansk",
        "IAS": "Iasi",
        "KTW": "Katowice",
        "POZ": "Poznan",
        "PRG": "Praga",
        "RZE": "Rzeszów",
        "SBZ": "Sibiu",
        "SOF": "Sofía",
        "QZD": "Szeged",
        "TSR": "Timisoara",
        "WAW": "Varsovia",
        "WMI": "Varsovia-Modlin",
    },
    "Balcanes, Grecia y Chipre": {
        "ATH": "Atenas",
        "BEG": "Belgrado",
        "CFU": "Corfú",
        "HER": "Creta (Heraclión)",
        "CHQ": "Creta (La Canea)",
        "DBV": "Dubrovnik",
        "MLA": "La Valeta (Malta)",
        "LJU": "Liubliana",
        "LCA": "Nicosia (Lárnaca)",
        "TGD": "Podgorica",
        "RHO": "Rodas",
        "SKG": "Salónica",
        "JTR": "Santorini",
        "SJJ": "Sarajevo",
        "SKP": "Skopie",
        "SPU": "Split",
        "TIA": "Tirana",
        "ZAG": "Zagreb",
    },
    "Turquía y Oriente Medio": {
        "AUH": "Abu Dabi",
        "AMM": "Ammán",
        "ESB": "Ankara",
        "AYT": "Antalya",
        "BEY": "Beirut",
        "DOH": "Doha",
        "DXB": "Dubái",
        "ADB": "Esmirna",
        "IST": "Estambul",
        "SAW": "Estambul-Sabiha",
        "KWI": "Kuwait",
        "TLV": "Tel Aviv",
    },
    "Norte de África": {
        "AGA": "Agadir",
        "ALG": "Argel",
        "CMN": "Casablanca",
        "CAI": "El Cairo",
        "FEZ": "Fez",
        "HRG": "Hurgada",
        "RAK": "Marrakech",
        "NDR": "Nador",
        "RBA": "Rabat",
        "SSH": "Sharm el Sheij",
        "TNG": "Tánger",
        "TUN": "Túnez",
    },
    "África subsahariana": {
        "DSS": "Dakar-Blaise Diagne",
        "JNB": "Johannesburgo",
    },
    "Norteamérica": {
        "ATL": "Atlanta",
        "BOS": "Boston",
        "CLT": "Charlotte",
        "ORD": "Chicago",
        "DFW": "Dallas",
        "YUL": "Montreal",
        "LAX": "Los Ángeles",
        "MIA": "Miami",
        "YYZ": "Toronto",
        "JFK": "Nueva York",
        "EWR": "Nueva York (Newark)",
        "PHL": "Filadelfia",
        "SFO": "San Francisco",
        "SJU": "San Juan (Puerto Rico)",
        "IAD": "Washington",
    },
    "Latinoamérica y Caribe": {
        "ASU": "Asunción",
        "BOG": "Bogotá",
        "CLO": "Cali",
        "CUN": "Cancún",
        "CTG": "Cartagena de Indias",
        "COR": "Córdoba (Argentina)",
        "EZE": "Buenos Aires",
        "FOR": "Fortaleza",
        "GDL": "Guadalajara",
        "GUA": "Ciudad de Guatemala",
        "GYE": "Guayaquil",
        "SAP": "San Pedro Sula",
        "LIM": "Lima",
        "MEX": "Ciudad de México",
        "MTY": "Monterrey",
        "MVD": "Montevideo",
        "PUJ": "Punta Cana",
        "REC": "Recife",
        "GIG": "Río de Janeiro",
        "MDE": "Medellín",
        "SJO": "San José (Costa Rica)",
        "VVI": "Santa Cruz (Bolivia)",
        "SCL": "Santiago de Chile",
        "SDQ": "Santo Domingo",
        "GRU": "São Paulo",
        "PTY": "Panamá",
    },
    "Asia y Pacífico": {
        "HKG": "Hong Kong",
        "NRT": "Tokio",
    },
}

# Grupo agregado con todos los aeropuertos de Europa (unión de los grupos por país/región
# de arriba); no se incluye "Turquía y Oriente Medio" porque mezcla aeropuertos turcos con
# otros que no son de Europa.
_GRUPOS_EUROPA = [
    "España", "Portugal", "Francia", "Italia", "Alemania", "Reino Unido e Irlanda", "Benelux",
    "Suiza y Austria", "Nórdicos y Bálticos", "Europa del Este", "Balcanes, Grecia y Chipre",
    "Secundarios low cost",
]
GRUPOS["Europa (todos)"] = {c: n for g in _GRUPOS_EUROPA for c, n in GRUPOS[g].items()}

DESTINOS = {c: n for g in GRUPOS.values() for c, n in g.items()}

PRIORITARIOS = []      # códigos a priorizar si no se indican con --prioritarios
PESO_PRIORIDAD = 0.7   # fracción de consultas dedicada a los prioritarios

DIAS = 365             # nº de días a consultar desde mañana
MAX_ESCALAS = None     # None = cualquiera, 0 = solo directos, 1 = máx. 1 escala
ADULTOS = 1
HILOS = 6              # consultas en paralelo
VELOCIDAD = 2.0        # consultas por segundo al empezar (se ajusta sola)
VELOCIDAD_MAX = 6.0    # techo: no se pasa de aquí aunque todo vaya bien
PAUSA = (0.0, 0.0)     # pausa extra por hilo (normalmente no hace falta: manda VELOCIDAD)
ESPERA_BLOQUEO = 120   # segundos de pausa si Google detecta "tráfico inusual"
REINTENTOS = 3

NOCHES_COMBINAR = range(2, 11)   # estancias a calcular con --combinar (2 a 10 noches)

# Estructura de carpetas: este script vive en .../Vuelos/py/, los datos en .../Vuelos/csv/
CARPETA = os.path.dirname(os.path.abspath(__file__))     # .../Vuelos/py
BASE = os.path.dirname(CARPETA)                            # .../Vuelos
CSV_DIR = os.path.join(BASE, "csv")
os.makedirs(CSV_DIR, exist_ok=True)

CSV_SALIDA = os.path.join(CSV_DIR, "vuelos_madrid.csv")
CSV_OPCIONES = os.path.join(CSV_DIR, "vuelos_opciones.csv")
CSV_ERRORES = os.path.join(CSV_DIR, "errores_descarga.csv")
CSV_HISTORICO = os.path.join(CSV_DIR, "historico_precios.csv")   # un precio por consulta: permite medir la volatilidad
CSV_SONDEO = os.path.join(CSV_DIR, "sondeo_meses.csv")           # resultado de los sondeos por mes

SONDEO_N = 10          # vuelos al azar que se comprueban por mes
SONDEO_DIF = 5.0       # € de diferencia a partir de los cuales se considera que el precio cambió
SONDEO_MAYORIA = 0.5   # fracción de la muestra que debe haber cambiado para recalcular el mes   # historial de errores (para la tabla de frecuencias de la app)   # TODOS los vuelos de cada día (para filtrar por hora, aerolínea…)
CSV_COMBINACIONES = os.path.join(CSV_DIR, "vuelos_combinaciones.csv")

# ===========================================================================

DIAS_SEMANA = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]
MESES = ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
         "agosto", "septiembre", "octubre", "noviembre", "diciembre"]

COLUMNAS = [
    "fecha", "dia_semana", "mes", "sentido", "codigo", "ciudad", "origen", "destino",
    "precio_eur", "precio_anterior", "aerolinea", "escalas", "duracion_min", "duracion",
    "hora_salida", "hora_llegada", "llega_dia_siguiente", "n_opciones",
    "ultima_descarga", "enlace_reserva",
]


def _dt(sd):
    """SimpleDatetime de fast-flights -> datetime."""
    y, m, d = sd.date
    hh, mm = sd.time
    return datetime(y, m, d, hh, mm)


def _hhmm(minutos):
    return f"{minutos // 60}h {minutos % 60:02d}m"


def crear_query(tramos):
    """tramos = [(fecha, origen, destino), ...]  -> 1 tramo solo ida, 2 tramos ida y vuelta."""
    return create_query(
        flights=[FlightQuery(date=f.isoformat() if isinstance(f, date) else f,
                             from_airport=o, to_airport=d) for f, o, d in tramos],
        trip="one-way" if len(tramos) == 1 else "round-trip",
        seat="economy",
        passengers=Passengers(adults=ADULTOS),
        language="es",
        currency="EUR",
        max_stops=MAX_ESCALAS,
    )


def enlace(tramos):
    """URL de Google Flights con esa búsqueda (desde ahí se elige vuelo y se reserva)."""
    return crear_query(tramos).url()


def consultar(fecha: date, origen: str, destino: str):
    """Devuelve la lista de vuelos (objetos Flights) de ese día, o [] si no hay."""
    q = crear_query([(fecha, origen, destino)])
    ultimo_error = None
    for intento in range(1, REINTENTOS + 1):
        espera = _bloqueo["hasta"] - time.time()
        if espera > 0:
            time.sleep(espera)
        ritmo.esperar()
        try:
            vuelos = [f for f in descargar(q) if f.price and f.price > 0]
            ritmo.ok()
            return vuelos
        except Exception as e:  # FlightsNotFound, errores de red, HTML inesperado...
            if type(e).__name__ == "FlightsNotFound":
                return []
            ultimo_error = e
            if isinstance(e, Bloqueo):
                ritmo.frenar()
                with _print_lock:
                    nuevo = _bloqueo["hasta"] < time.time()
                    if nuevo:
                        _bloqueo["hasta"] = time.time() + ESPERA_BLOQUEO
                if nuevo:
                    log(f"  ~ Google ha detectado demasiadas consultas: pausa de {ESPERA_BLOQUEO} s", err=True)
                    registrar_error("Pausa por captcha", origen, destino, fecha,
                                    f"Pausa automática de {ESPERA_BLOQUEO} s")
                continue
            time.sleep(3 * intento + random.random() * 3)
    registrar_error(tipo_error(ultimo_error), origen, destino, fecha, ultimo_error)
    raise RuntimeError(f"{origen}->{destino} {fecha}: {ultimo_error}")


COLUMNAS_OPC = [
    "fecha", "sentido", "codigo", "ciudad", "origen", "destino", "aeropuerto_salida",
    "aeropuerto_llegada", "precio_eur", "aerolinea", "escalas", "duracion_min", "hora_salida",
    "hora_llegada", "llega_dia_siguiente", "escala_max_min", "co2_kg", "consulta",
]


def detalle(vuelo):
    """Datos comunes de un vuelo (Flights de fast-flights)."""
    tramos = vuelo.flights
    salida, llegada = _dt(tramos[0].departure), _dt(tramos[-1].arrival)
    esperas = [int((_dt(b.departure) - _dt(a.arrival)).total_seconds() // 60)
               for a, b in zip(tramos, tramos[1:])]
    duracion = sum(t.duration for t in tramos) + sum(esperas)
    try:
        co2 = round(vuelo.carbon.emission / 1000)
    except Exception:
        co2 = ""
    return {
        "aeropuerto_salida": tramos[0].from_airport.code,
        "aeropuerto_llegada": tramos[-1].to_airport.code,
        "precio_eur": vuelo.price,
        "aerolinea": " / ".join(dict.fromkeys(vuelo.airlines)),
        "escalas": len(tramos) - 1,
        "duracion_min": duracion,
        "hora_salida": salida.strftime("%H:%M"),
        "hora_llegada": llegada.strftime("%H:%M"),
        "llega_dia_siguiente": "sí" if llegada.date() > salida.date() else "no",
        "escala_max_min": max(esperas) if esperas else 0,
        "co2_kg": co2,
    }


def filas_opciones(fecha, sentido, origen, destino, codigo, ciudad, vuelos, consulta):
    base = {"fecha": fecha.isoformat(), "sentido": sentido, "codigo": codigo, "ciudad": ciudad,
            "origen": origen, "destino": destino, "consulta": consulta}
    return [base | detalle(v) for v in vuelos]


def compactar_opciones(ruta):
    """Deja solo los vuelos de la consulta más reciente de cada día/sentido/destino
    y quita los días pasados. Se hace en streaming para no cargar todo en memoria."""
    if not os.path.exists(ruta):
        return
    clave_o = lambda r: (r.get("fecha") or "", r.get("sentido") or "", r.get("codigo") or "")
    ultima = {}
    with open(ruta, encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f, delimiter=";"):
            if not fila_valida(r):
                continue
            k = clave_o(r)
            if (r.get("consulta") or "") > ultima.get(k, ""):
                ultima[k] = r["consulta"]
    hoy = date.today().isoformat()
    tmp = ruta + ".tmp"
    with open(ruta, encoding="utf-8-sig", newline="") as f, \
            open(tmp, "w", encoding="utf-8-sig", newline="") as g:
        w = csv.DictWriter(g, fieldnames=COLUMNAS_OPC, delimiter=";", extrasaction="ignore")
        w.writeheader()
        for r in csv.DictReader(f, delimiter=";"):
            if fila_valida(r) and r["fecha"] > hoy and r.get("consulta") == ultima.get(clave_o(r)):
                w.writerow(r)
    try:
        os.replace(tmp, ruta)
    except OSError:          # p. ej. OneDrive tiene el fichero bloqueado: se reintentará la próxima vez
        os.remove(tmp)


def sondear_meses(muestreables, n_por_mes, consulta_fn, ruta_sondeo, dif=SONDEO_DIF,
                  mayoria=SONDEO_MAYORIA, fecha_col="fecha", precio_col="precio_eur"):
    """Comprueba n_por_mes vuelos al azar de cada mes ya descargado y decide qué meses
    hay que recalcular: aquellos en los que la mayoría de la muestra ha cambiado más de `dif` €.
    Devuelve (meses_a_recalcular, tabla)."""
    por_mes = {}
    for r in muestreables:
        por_mes.setdefault(r[fecha_col][:7], []).append(r)
    momento = datetime.now().strftime("%Y-%m-%d %H:%M")
    tabla, recalcular = [], []
    for mes in sorted(por_mes):
        muestra = random.sample(por_mes[mes], min(n_por_mes, len(por_mes[mes])))
        difs = []
        for r in muestra:
            try:
                nuevo = consulta_fn(r)
            except Exception as e:
                log(f"  ! sondeo {mes}: {e}", err=True)
                continue
            if nuevo is not None:
                difs.append(nuevo - float(r[precio_col]))
        if not difs:
            continue
        cambiados = sum(1 for d in difs if abs(d) >= dif)
        frac = cambiados / len(difs)
        decision = "recalcular" if frac > mayoria else "mantener"
        fila = {"momento": momento, "mes": mes, "muestra": len(difs), "cambiados": cambiados,
                "pct_cambiados": round(frac, 3),
                "dif_media": round(sum(difs) / len(difs), 2),
                "dif_media_abs": round(sum(abs(d) for d in difs) / len(difs), 2),
                "decision": decision}
        tabla.append(fila)
        log(f"  ? sondeo {mes}: {cambiados}/{len(difs)} cambiaron mas de {dif:.0f} EUR "
            f"(media {fila['dif_media']:+.1f} EUR) -> {decision}")
        if decision == "recalcular":
            recalcular.append(mes)
    if tabla:
        nuevo_f = not os.path.exists(ruta_sondeo)
        with open(ruta_sondeo, "a", encoding="utf-8-sig" if nuevo_f else "utf-8", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(tabla[0]), delimiter=";")
            if nuevo_f:
                w.writeheader()
            w.writerows(tabla)
    return recalcular, tabla


def ordenar_por_prioridad(tareas, prioritarios, peso, umbral=0):
    """Intercala tareas: ~peso de prioritarios y el resto de los demás, sin agotar
    primero unos ni otros. Dentro de cada grupo van primero los vuelos que salen dentro
    del umbral de días (los que más cambian de precio), y luego el resto, por fecha."""
    if umbral:
        limite = date.today() + timedelta(days=umbral)
        tareas = sorted(tareas, key=lambda t: (t[0] > limite, t[0], t[4]))
    if not prioritarios:
        return tareas
    prio = [t for t in tareas if t[4] in prioritarios]
    resto = [t for t in tareas if t[4] not in prioritarios]
    out, n_prio = [], 0
    ip = ir = 0
    while ip < len(prio) or ir < len(resto):
        if ip < len(prio) and (ir >= len(resto) or n_prio < peso * (len(out) + 1)):
            out.append(prio[ip]); ip += 1; n_prio += 1
        else:
            out.append(resto[ir]); ir += 1
    return out


def a_fila(fecha, sentido, origen, destino, codigo, ciudad, vuelo, n_opciones):
    fila = {
        "fecha": fecha.isoformat(),
        "dia_semana": DIAS_SEMANA[fecha.weekday()],
        "mes": MESES[fecha.month - 1],
        "sentido": sentido,
        "codigo": codigo,
        "ciudad": ciudad,
        "origen": origen,
        "destino": destino,
        "n_opciones": n_opciones,
        "ultima_descarga": datetime.now().strftime("%Y-%m-%d %H:%M"),
        "enlace_reserva": enlace([(fecha, origen, destino)]),
    }
    if vuelo is None:
        return fila  # día sin vuelos: se guarda con precio vacío para no repetir la consulta

    d = detalle(vuelo)
    fila.update({k: d[k] for k in ("precio_eur", "aerolinea", "escalas", "duracion_min",
                                   "hora_salida", "hora_llegada", "llega_dia_siguiente")})
    fila["duracion"] = _hhmm(d["duracion_min"])
    return fila


def clave(r):
    return (r.get("fecha") or "", r.get("sentido") or "", r.get("codigo") or "")


def fila_valida(r):
    """Descarta filas corruptas (p. ej. una línea cortada al detener una descarga)."""
    return all(r.get(c) for c in ("fecha", "sentido", "codigo")) and len(r.get("fecha", "")) == 10


def leer_filas(ruta):
    if not os.path.exists(ruta):
        return []
    with open(ruta, encoding="utf-8-sig", newline="") as f:
        filas = [r for r in csv.DictReader(f, delimiter=";") if fila_valida(r)]
    return filas


def compactar(ruta):
    """Deja una sola fila por (fecha, sentido, destino): la de la descarga más reciente.
    Si había un precio anterior distinto, lo guarda en 'precio_anterior'.
    Elimina además los días que ya han pasado."""
    ultimas = {}
    for r in leer_filas(ruta):  # el fichero está en orden de escritura: lo último es lo más nuevo
        previa = ultimas.get(clave(r))
        if previa and previa["precio_eur"] and previa["precio_eur"] != r["precio_eur"]:
            r["precio_anterior"] = previa["precio_eur"]
        elif previa and not r.get("precio_anterior"):
            r["precio_anterior"] = previa.get("precio_anterior", "")
        ultimas[clave(r)] = r
    hoy = date.today().isoformat()
    filas = sorted((r for r in ultimas.values() if r.get("fecha", "") > hoy), key=clave)
    with open(ruta, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=COLUMNAS, delimiter=";", extrasaction="ignore")
        w.writeheader()
        w.writerows(filas)
    return len(filas)


def escribir_combinaciones(ruta_entrada, ruta_salida):
    """Cruza cada IDA con cada VUELTA N noches después (sin nuevas consultas)."""
    precios = {}
    with open(ruta_entrada, encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f, delimiter=";"):
            if r["precio_eur"]:
                precios[(r["codigo"], r["sentido"], r["fecha"])] = r

    filas = []
    for (dest, sentido, f_ida), ida in precios.items():
        if sentido != "IDA":
            continue
        d_ida = date.fromisoformat(f_ida)
        for n in NOCHES_COMBINAR:
            d_vta = d_ida + timedelta(days=n)
            vta = precios.get((dest, "VUELTA", d_vta.isoformat()))
            if not vta:
                continue
            total = int(ida["precio_eur"]) + int(vta["precio_eur"])
            filas.append({
                "destino": dest, "ciudad": ida["ciudad"],
                "fecha_ida": f_ida, "dia_ida": ida["dia_semana"], "mes_ida": ida["mes"],
                "fecha_vuelta": d_vta.isoformat(), "dia_vuelta": DIAS_SEMANA[d_vta.weekday()],
                "noches": n,
                "precio_ida": int(ida["precio_eur"]), "precio_vuelta": int(vta["precio_eur"]),
                "precio_total": total,
                "precio_noche": f"{total / n:.2f}".replace(".", ","),
                "aerolinea_ida": ida["aerolinea"], "hora_salida_ida": ida["hora_salida"],
                "aerolinea_vuelta": vta["aerolinea"], "hora_salida_vuelta": vta["hora_salida"],
                "ultima_descarga": min(ida["ultima_descarga"], vta["ultima_descarga"]),
                "enlace_reserva": enlace([(f_ida, ORIGEN, dest), (d_vta.isoformat(), dest, ORIGEN)]),
            })
    filas.sort(key=lambda r: (r["destino"], r["fecha_ida"], r["noches"]))
    with open(ruta_salida, "w", encoding="utf-8-sig", newline="") as f:
        cols = list(filas[0].keys()) if filas else ["destino"]
        w = csv.DictWriter(f, fieldnames=cols, delimiter=";")
        w.writeheader()
        w.writerows(filas)
    print(f"Combinaciones: {len(filas)} filas -> {ruta_salida}")


def main():
    p = argparse.ArgumentParser(description="Precios diarios de vuelos desde/hacia Madrid")
    p.add_argument("--dias", type=int, default=DIAS)
    p.add_argument("--destinos", nargs="*", help="códigos IATA (por defecto, todos los de DESTINOS)")
    p.add_argument("--hilos", type=int, default=HILOS)
    p.add_argument("--velocidad", type=float, default=VELOCIDAD,
                   help="consultas por segundo al empezar (se ajusta sola)")
    p.add_argument("--velocidad-max", type=float, default=VELOCIDAD_MAX,
                   help="máximo de consultas por segundo")
    p.add_argument("--salida", default=CSV_SALIDA)
    p.add_argument("--nuevo", action="store_true", help="borra el CSV previo y empieza de cero")
    p.add_argument("--actualizar", nargs="?", const=0, type=float, metavar="HORAS",
                   help="vuelve a descargar los precios (todos, o solo los más antiguos que HORAS)")
    p.add_argument("--combinar", action="store_true", help="genera también el CSV de ida+vuelta")
    p.add_argument("--opciones", default=CSV_OPCIONES, help="CSV con todos los vuelos de cada día")
    p.add_argument("--prioritarios", nargs="*", default=PRIORITARIOS,
                   help="destinos a priorizar (reciben --peso de las consultas)")
    p.add_argument("--peso", type=float, default=PESO_PRIORIDAD,
                   help="fracción de consultas para los prioritarios (0-1)")
    p.add_argument("--umbral", type=int, default=0,
                   help="días: los vuelos que salgan antes de ese plazo se consultan primero")
    p.add_argument("--historico", default=CSV_HISTORICO, help="CSV con el histórico de precios")
    p.add_argument("--sondeo", nargs="?", const=SONDEO_N, type=int, metavar="N",
                   help="antes de descargar, comprueba N vuelos al azar por mes y solo recalcula "
                        "los meses en los que la mayoría haya cambiado")
    p.add_argument("--sondeo-dif", type=float, default=SONDEO_DIF,
                   help="euros de diferencia para considerar que un precio ha cambiado")
    p.add_argument("--meses", nargs="*", help="limita la descarga a estos meses (AAAA-MM)")
    p.add_argument("--pares", nargs="*",
                   help="consultas exactas 'CODIGO:SENTIDO:AAAA-MM-DD' (IDA o VUELTA); si se da, "
                        "ignora --dias, --destinos y --meses y solo consulta justo esas filas "
                        "(favoritos o filtros concretos)")
    p.add_argument("--pares-fichero", metavar="RUTA",
                   help="fichero de texto con una consulta 'CODIGO:SENTIDO:AAAA-MM-DD' por línea, "
                        "para no toparse con el límite de longitud de la línea de comandos de "
                        "Windows cuando --pares tendría muchísimas filas; se juntan con --pares "
                        "si se dan los dos")
    p.add_argument("--desde", metavar="AAAA-MM-DD",
                   help="primer día a consultar (por defecto, mañana); junto con --hasta sustituye a --dias")
    p.add_argument("--hasta", metavar="AAAA-MM-DD", help="último día a consultar (incluido)")
    a = p.parse_args()
    if a.desde or a.hasta:      # rango de fechas: se traduce a nº de días desde el primero
        _ini = date.fromisoformat(a.desde) if a.desde else date.today() + timedelta(days=1)
        if a.hasta:
            a.dias = max((date.fromisoformat(a.hasta) - _ini).days + 1, 0)
    if a.pares_fichero:
        with open(a.pares_fichero, encoding="utf-8") as f:
            a.pares = (a.pares or []) + [l.strip() for l in f if l.strip()]
    global CSV_ERRORES
    CSV_ERRORES = os.path.join(os.path.dirname(os.path.abspath(a.salida)), os.path.basename(CSV_ERRORES))
    a.historico = os.path.join(os.path.dirname(os.path.abspath(a.salida)), os.path.basename(a.historico))
    ruta_sondeo = os.path.join(os.path.dirname(os.path.abspath(a.salida)), CSV_SONDEO)

    global ritmo
    ritmo = Ritmo(a.velocidad, a.velocidad_max)
    destinos = {k: DESTINOS.get(k, k) for k in (a.destinos or DESTINOS)}
    if a.pares:
        destinos = {k: DESTINOS.get(k, k) for k in {par.split(":", 2)[0] for par in a.pares}}
    if a.nuevo and os.path.exists(a.salida):
        os.remove(a.salida)

    for _limpiar, _ruta in ((compactar, a.salida), (compactar_opciones, a.opciones)):
        try:
            if os.path.exists(_ruta):
                _limpiar(_ruta)
        except Exception as _e:      # nunca debe impedir que se descargue
            log(f"  ! no he podido limpiar {os.path.basename(_ruta)}: {_e}", err=True)
    hechos = set()
    previas = leer_filas(a.salida)
    for r in previas:
        if a.actualizar is not None:
            edad_h = (datetime.now() - datetime.strptime(r["ultima_descarga"], "%Y-%m-%d %H:%M")).total_seconds() / 3600
            if edad_h <= a.actualizar:
                hechos.add(clave(r))
        else:
            hechos.add(clave(r))
    inicio = date.fromisoformat(a.desde) if a.desde else date.today() + timedelta(days=1)
    tareas = []
    if a.pares:
        for par in a.pares:
            cod, sentido, fecha_str = par.split(":", 2)
            f = date.fromisoformat(fecha_str)
            ciudad = destinos.get(cod, cod)
            o, d = (ORIGEN, cod) if sentido == "IDA" else (cod, ORIGEN)
            if (f.isoformat(), sentido, cod) not in hechos:
                tareas.append((f, sentido, o, d, cod, ciudad))
    else:
        for i in range(a.dias):
            f = inicio + timedelta(days=i)
            for cod, ciudad in destinos.items():
                for sentido, o, d in (("IDA", ORIGEN, cod), ("VUELTA", cod, ORIGEN)):
                    if (f.isoformat(), sentido, cod) not in hechos:
                        tareas.append((f, sentido, o, d, cod, ciudad))
        if a.meses:
            tareas = [t for t in tareas if t[0].strftime("%Y-%m") in set(a.meses)]
    tareas = ordenar_por_prioridad(tareas, set(a.prioritarios or []), a.peso, a.umbral)
    total = len(tareas)
    if a.pares:
        print(f"{len(a.pares)} consultas concretas (favoritos/filtro) | pendientes: {total}")
    else:
        print(f"{len(destinos)} destinos x {a.dias} días x 2 sentidos | ya hechas: {len(hechos)} | pendientes: {total}")
    if a.prioritarios:
        print(f"Prioritarios ({a.peso:.0%} de las consultas): {', '.join(a.prioritarios)}")
    if a.umbral:
        print(f"Primero los vuelos que salen en los próximos {a.umbral} días")
    if not total:
        if a.combinar:
            escribir_combinaciones(a.salida, CSV_COMBINACIONES)
        return

    nuevo_fichero = not os.path.exists(a.salida)
    fh = open(a.salida, "a", encoding="utf-8-sig" if nuevo_fichero else "utf-8", newline="")
    w = csv.DictWriter(fh, fieldnames=COLUMNAS, delimiter=";", extrasaction="ignore")
    if nuevo_fichero:
        w.writeheader()
        fh.flush()
    nuevo_hist = not os.path.exists(a.historico)
    fhist = open(a.historico, "a", encoding="utf-8-sig" if nuevo_hist else "utf-8", newline="")
    whist = csv.DictWriter(fhist, fieldnames=["consulta", "fecha_vuelo", "sentido", "codigo",
                                              "dias_antelacion", "precio_eur"], delimiter=";")
    if nuevo_hist:
        whist.writeheader()
        fhist.flush()
    nuevo_opc = not os.path.exists(a.opciones)
    fo = open(a.opciones, "a", encoding="utf-8-sig" if nuevo_opc else "utf-8", newline="")
    wo = csv.DictWriter(fo, fieldnames=COLUMNAS_OPC, delimiter=";", extrasaction="ignore")
    if nuevo_opc:
        wo.writeheader()
        fo.flush()
    lock = Lock()
    errores = 0
    t0 = time.time()
    marcas = deque(maxlen=2000)   # instante en que terminó cada consulta

    def minutos_restantes(pend):
        """Ritmo de los últimos 5 min (incluye pausas por captcha); si hay pocas
        consultas en ese rato, ritmo de las últimas 100."""
        ahora = time.time()
        ventana = [t for t in marcas if ahora - t <= 300]
        if len(ventana) >= 20:
            ritmo = (ahora - ventana[0]) / len(ventana)
        else:
            ult = list(marcas)[-100:]
            ritmo = (ahora - (ult[0] if len(ult) > 1 else t0)) / max(len(ult), 1)
        return pend * ritmo / 60

    lock_escritura = lock

    def escribir(fila, opciones):
        with lock_escritura:
            if fila.get("precio_eur"):
                whist.writerow({"consulta": fila["ultima_descarga"], "fecha_vuelo": fila["fecha"],
                                "sentido": fila["sentido"], "codigo": fila["codigo"],
                                "dias_antelacion": (date.fromisoformat(fila["fecha"]) - date.today()).days,
                                "precio_eur": fila["precio_eur"]})
                fhist.flush()
            wo.writerows(opciones)
            fo.flush()
            w.writerow(fila)
            fh.flush()

    if a.sondeo:
        def consulta_sondeo(r):
            f = date.fromisoformat(r["fecha"])
            o, d = (ORIGEN, r["codigo"]) if r["sentido"] == "IDA" else (r["codigo"], ORIGEN)
            log(f"  > {o}->{d} {r['fecha']} (sondeo)")
            vuelos = consultar(f, o, d)
            v = min(vuelos, key=lambda x: x.price) if vuelos else None
            consulta = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            escribir(a_fila(f, r["sentido"], o, d, r["codigo"], r.get("ciudad", r["codigo"]), v, len(vuelos)),
                     filas_opciones(f, r["sentido"], o, d, r["codigo"], r.get("ciudad", r["codigo"]),
                                    vuelos, consulta))
            return float(v.price) if v else None

        muestreables = [r for r in previas
                        if r.get("precio_eur") and r["fecha"] > date.today().isoformat()
                        and r["codigo"] in destinos]
        print(f"Sondeo: {a.sondeo} vuelos al azar por mes ({len(muestreables)} candidatos)")
        meses_ok, _ = sondear_meses(muestreables, a.sondeo, consulta_sondeo, ruta_sondeo, a.sondeo_dif)
        if not meses_ok:
            print("Ningún mes ha cambiado lo suficiente: no hace falta recalcular nada.")
            fh.close(); fo.close(); fhist.close()
            return
        print(f"Meses a recalcular: {', '.join(meses_ok)}")
        tareas = [t for t in tareas if t[0].strftime("%Y-%m") in set(meses_ok)]
        total = len(tareas)
        if not total:
            fh.close(); fo.close(); fhist.close()
            return

    seguidos = [0]
    parar = [False]

    def trabajo(t):
        f, sentido, o, d, cod, ciudad = t
        if parar[0]:
            return None
        log(f"  > {o}->{d} {f.isoformat()}")
        try:
            vuelos = consultar(f, o, d)
        finally:
            if PAUSA[1]:
                time.sleep(random.uniform(*PAUSA))
        vuelo = min(vuelos, key=lambda v: v.price) if vuelos else None
        if vuelo:
            log(f"  = {o}->{d} {f.isoformat()} {vuelo.price} EUR {' / '.join(dict.fromkeys(vuelo.airlines))}"
                f" ({len(vuelos)} vuelos)")
        else:
            log(f"  = {o}->{d} {f.isoformat()} sin vuelos")
        consulta = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        return (a_fila(f, sentido, o, d, cod, ciudad, vuelo, len(vuelos)),
                filas_opciones(f, sentido, o, d, cod, ciudad, vuelos, consulta))

    try:
        with ThreadPoolExecutor(max_workers=a.hilos) as ex:
            futuros = [ex.submit(trabajo, t) for t in tareas]
            for k, fut in enumerate(as_completed(futuros), 1):
                marcas.append(time.time())
                try:
                    res = fut.result()
                    if res is None:
                        continue
                    fila, opciones = res
                    seguidos[0] = 0
                    escribir(fila, opciones)
                except Exception as e:
                    errores += 1
                    seguidos[0] += 1
                    log(f"  ! {e}", err=True)
                    if seguidos[0] >= 15 and not parar[0]:
                        parar[0] = True
                        log("  !! 15 errores seguidos: detengo la descarga. Prueba de nuevo más tarde.", err=True)
                        ex.shutdown(wait=False, cancel_futures=True)
                        break
                if True:  # progreso y tiempo restante tras cada consulta
                    resta = minutos_restantes(total - k)
                    log(f"  {k}/{total}  ({errores} errores)  ~{resta:.0f} min restantes"
                        f"  [{ritmo.cps:.1f} consultas/s, {a.hilos} hilos]  t={time.time() - t0:.0f}s")
    except KeyboardInterrupt:
        print("\nInterrumpido. Lo descargado está guardado; relanza para continuar.")
        ex.shutdown(wait=False, cancel_futures=True)
    finally:
        fh.close()
        fo.close()
        fhist.close()

    try:
        n = compactar(a.salida)
        compactar_opciones(a.opciones)
    except Exception as e:
        n, _ = -1, log(f"  ! no he podido limpiar los CSV: {e}", err=True)
    print(f"Hecho -> {a.salida}  ({n} filas, {errores} errores; relanza el script para reintentarlos)")
    if a.combinar:
        escribir_combinaciones(a.salida, CSV_COMBINACIONES)


if __name__ == "__main__":
    main()
:::END
:::BEGIN py/hoteles_madrid.py|text
"""
Descarga precios de alojamiento (Google Hotels) para los mismos destinos que los vuelos.

Guarda UNA FILA POR ALOJAMIENTO Y BÚSQUEDA, con todo lo que se puede categorizar
(precio, valoración, reseñas, estrellas, tipo, servicios), para poder filtrar luego en la app
sin volver a descargar.

Uso:
    python hoteles_madrid.py --destinos LIS ROM --dias 90 --noches 3
    python hoteles_madrid.py --actualizar 24        # refresca lo de hace más de 24 h
    python hoteles_madrid.py --pases-hotel 3        # EXPERIMENTAL: intenta traer más alojamientos
                                                     # por consulta (más lento, más peticiones)
"""

import argparse
import csv
import json
import urllib.parse
import urllib.request
import os
import re
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import date, datetime, timedelta

from selectolax.lexbor import LexborHTMLParser

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vuelos_madrid as vm          # se reutilizan cliente, ritmo, cookies y registro de errores

URL = "https://www.google.com/travel/search"

# Estructura de carpetas: este script vive en .../Vuelos/py/, los datos en .../Vuelos/csv/
CARPETA = os.path.dirname(os.path.abspath(__file__))     # .../Vuelos/py
BASE = os.path.dirname(CARPETA)                            # .../Vuelos
CSV_DIR = os.path.join(BASE, "csv")
os.makedirs(CSV_DIR, exist_ok=True)

CSV_HOTELES = os.path.join(CSV_DIR, "hoteles.csv")
CSV_HISTORICO = os.path.join(CSV_DIR, "historico_hoteles.csv")   # un precio por consulta: permite medir volatilidad/subidas
CSV_SONDEO_HOT = os.path.join(CSV_DIR, "sondeo_meses_hoteles.csv")   # resultado del sondeo, fichero propio (no mezclar con vuelos)
COLUMNAS_HIST = ["consulta", "fecha_entrada", "codigo", "ciudad", "nombre", "precio_noche"]
CENTROS = os.path.join(BASE, "centros_ciudades.json")     # coordenadas del centro de cada ciudad (se piden una vez)
RUTAS = os.path.join(BASE, "rutas_coche.json")            # minutos en coche ya calculados (para no repetir consultas)
RUTAS_TRANSPORTE = os.path.join(BASE, "rutas_transporte.json")   # minutos en transporte público (Transitous, gratis)
TOPE_TRANSPORTE = 400   # consultas por ejecución, por cortesía con el servicio gratuito
NOCHES = 1               # 1 noche por día: luego se suman las noches que haga falta
DIAS = 90
HILOS = 8

# EXPERIMENTAL: valores de "sort" que acepta Google Hotels (3=precio, 8=valoración).
# Repetir la consulta con cada uno y juntar lo nuevo es un intento de sacar más de los
# ~20-30 alojamientos que trae una sola página. No está verificado que Google reordene
# de verdad los resultados con este parámetro: hay que comparar --pases-hotel 1 vs 3.
SORTS_HOTEL = [None, 3, 8]
TOPE_ALOJAMIENTOS = 500   # tope orientativo por ciudad/fecha, para no seguir sin parar

SERVICIOS = {          # texto de la tarjeta -> columna (orden importante: lo más específico antes)
    "desayuno gratis": "desayuno", "desayuno ($)": "desayuno_pago", "desayuno": "desayuno",
    "wi‑fi gratis": "wifi", "wi-fi gratis": "wifi", "wi‑fi ($)": "wifi_pago", "wi-fi ($)": "wifi_pago",
    "wi‑fi": "wifi", "wi-fi": "wifi",
    "aparcamiento gratuito": "parking_gratis", "aparcamiento ($)": "parking_pago",
    "aparcamiento": "parking", "aire acondicionado": "aire", "piscina": "piscina",
    "restaurante": "restaurante", "bar": "bar", "gimnasio": "gimnasio", "jacuzzi": "jacuzzi",
    "spa": "spa", "cocina": "cocina", "lavadora": "lavadora", "lavander": "lavanderia",
    "se admiten mascotas": "mascotas", "adecuado para niños": "ninos",
    "alojamiento para no fumadores": "no_fumadores", "traslado del/al aeropuerto": "traslado_aeropuerto",
    "servicio de habitaciones": "servicio_habitaciones", "accesible": "accesible",
}
COLS_SERVICIO = sorted(set(SERVICIOS.values()))

COLUMNAS = ([
    "fecha_entrada", "fecha_salida", "noches", "codigo", "ciudad", "nombre", "precio_noche",
    "precio_total", "moneda", "valoracion", "resenas", "estrellas", "tipo",
    "lat", "lon", "direccion", "km_centro", "min_andando", "min_coche", "min_transporte",
    "km_aeropuerto", "min_coche_aeropuerto", "min_andando_aeropuerto",
] + COLS_SERVICIO + ["servicios", "buena_ubicacion", "oferta", "enlace", "consulta"])
TIPOS = ["hotel", "apartamento", "aparthotel", "hostal", "hostel", "casa de huéspedes",
         "pensión", "resort", "bed and breakfast", "alojamiento"]


def haversine(lat1, lon1, lat2, lon2):
    """Distancia en km entre dos coordenadas."""
    from math import radians, sin, cos, asin, sqrt
    if None in (lat1, lon1, lat2, lon2):
        return ""
    dlat, dlon = radians(lat2 - lat1), radians(lon2 - lon1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2) ** 2
    return round(2 * 6371 * asin(sqrt(a)), 2)


_centros = None


def centro_ciudad(ciudad, ruta=CENTROS):
    """Coordenadas del centro (se preguntan una vez a OpenStreetMap y se guardan)."""
    global _centros
    if _centros is None:
        try:
            with open(ruta, encoding="utf-8") as f:
                _centros = json.load(f)
        except Exception:
            _centros = {}
    if ciudad in _centros:
        c = _centros[ciudad]
        return (c[0], c[1]) if c else (None, None)
    coords = None
    try:
        nombre = ciudad.split("(")[0].split("-")[0].strip()
        req = urllib.request.Request(
            "https://nominatim.openstreetmap.org/search?"
            + urllib.parse.urlencode({"city": nombre, "format": "json", "limit": 1}),
            headers={"User-Agent": "app-vuelos-personal/1.0"})
        d = json.load(urllib.request.urlopen(req, timeout=20))
        if d:
            coords = [float(d[0]["lat"]), float(d[0]["lon"])]
        time.sleep(1.1)          # OpenStreetMap pide como mucho 1 consulta por segundo
    except Exception as e:
        vm.log(f"  ! no he podido obtener el centro de {ciudad}: {e}", err=True)
    if not coords:
        return (None, None)          # no se guarda el fallo: se reintenta la próxima vez
    _centros[ciudad] = coords
    try:
        with open(ruta, "w", encoding="utf-8") as f:
            json.dump(_centros, f, ensure_ascii=False, indent=1)
    except OSError:
        pass
    return (coords[0], coords[1])


def centro_aproximado(ciudad, geo):
    """Si OpenStreetMap no contesta: el centro es la mediana de los alojamientos de la página
    (los resultados de Google se concentran en el centro, así que se parece bastante)."""
    pts = [(la, lo) for la, lo, _ in geo.values() if la and lo]
    if len(pts) < 5:
        return (None, None)
    lats, lons = sorted(p[0] for p in pts), sorted(p[1] for p in pts)
    m = len(pts) // 2
    _aprox[ciudad] = (lats[m], lons[m])
    return _aprox[ciudad]


_aprox = {}


# ------------------------------------------------------------------ tiempos de trayecto
OSRM = "https://router.project-osrm.org/route/v1/driving/{},{};{},{}?overview=false"
REJILLA = 0.005          # ~500 m: los alojamientos de la misma manzana comparten ruta
TOPE_RUTAS = 400         # consultas de ruta por ejecución (el servidor público es gratuito)
_rutas, _pedidas = None, 0
_rutas_transporte, _pedidas_transporte = None, 0


def _celda(lat, lon):
    return f"{round(lat / REJILLA) * REJILLA:.3f},{round(lon / REJILLA) * REJILLA:.3f}"


def minutos_coche(lat, lon, lat_d, lon_d, km):
    """Minutos en coche hasta un punto. Se pregunta una vez por cada celda de ~500 m y se
    guarda; si el servicio no contesta se estima con la distancia."""
    global _rutas, _pedidas
    if not lat or not lat_d or km == "":
        return ""
    estimado = round(km * 1.35 / 24 * 60 + 3)      # calles: rodeo x1,35 y ~24 km/h de media
    if _rutas is None:
        try:
            with open(RUTAS, encoding="utf-8") as f:
                _rutas = json.load(f)
        except Exception:
            _rutas = {}
    clave = f"{_celda(lat, lon)}>{_celda(lat_d, lon_d)}"
    if clave in _rutas:
        return _rutas[clave] or estimado
    if _pedidas >= TOPE_RUTAS:
        return estimado
    _pedidas += 1
    minutos = None
    try:
        req = urllib.request.Request(OSRM.format(lon, lat, lon_d, lat_d),
                                     headers={"User-Agent": "app-vuelos-personal/1.0"})
        d = json.load(urllib.request.urlopen(req, timeout=15))
        if d.get("routes"):
            minutos = round(d["routes"][0]["duration"] / 60)
    except Exception:
        minutos = None
    _rutas[clave] = minutos
    try:
        with open(RUTAS, "w", encoding="utf-8") as f:
            json.dump(_rutas, f)
    except OSError:
        pass
    return minutos if minutos else estimado


def _hora_representativa():
    """Próximo martes a las 10:00: pedir un trayecto de una mañana entre semana da un
    "tiempo medio" más realista que la hora exacta en la que se lance la descarga."""
    ahora = datetime.now()
    dias = (1 - ahora.weekday()) % 7 or 7   # martes = weekday() 1
    objetivo = (ahora + timedelta(days=dias)).replace(hour=10, minute=0, second=0, microsecond=0)
    return objetivo.strftime("%Y-%m-%dT%H:%M:00Z")


TRANSITOUS = "https://api.transitous.org/api/v6/plan"


def minutos_transporte(lat, lon, lat_d, lon_d, min_coche, km):
    """Tiempo medio hasta el centro en transporte público, vía Transitous (transitous.org):
    gratis, sin clave ni cuenta, con cobertura buena en Europa y más floja en otras zonas.
    Se calcula una sola vez por celda de ~500 m (igual que el tiempo en coche) y se guarda en
    rutas_transporte.json: las descargas siguientes heredan el valor sin volver a consultar.
    Si esa ciudad no tiene cobertura o falla la consulta, se usa la estimación de siempre
    sobre el tiempo en coche."""
    global _rutas_transporte, _pedidas_transporte
    if min_coche == "" or km == "":
        return ""
    estimado = round(min_coche * 1.45 + 7)
    if not lat or not lat_d:
        return estimado
    if _rutas_transporte is None:
        try:
            with open(RUTAS_TRANSPORTE, encoding="utf-8") as f:
                _rutas_transporte = json.load(f)
        except Exception:
            _rutas_transporte = {}
    celda = f"{_celda(lat, lon)}>{_celda(lat_d, lon_d)}"
    if celda in _rutas_transporte:
        return _rutas_transporte[celda] or estimado
    if _pedidas_transporte >= TOPE_TRANSPORTE:
        return estimado
    _pedidas_transporte += 1
    minutos = None
    try:
        params = urllib.parse.urlencode({
            "fromPlace": f"{lat},{lon}", "toPlace": f"{lat_d},{lon_d}",
            "time": _hora_representativa(),
        })
        req = urllib.request.Request(
            f"{TRANSITOUS}?{params}",
            headers={"User-Agent": "app-vuelos-personal/1.0 (uso personal, no comercial)"})
        d = json.load(urllib.request.urlopen(req, timeout=20))
        itin = d.get("itineraries") or d.get("direct") or []
        if itin:
            minutos = round(itin[0]["duration"] / 60)
    except Exception:
        minutos = None
    _rutas_transporte[celda] = minutos
    try:
        with open(RUTAS_TRANSPORTE, "w", encoding="utf-8") as f:
            json.dump(_rutas_transporte, f)
    except OSError:
        pass
    return minutos if minutos else estimado




AEROPUERTO_CIUDAD = {"PAR": "CDG", "ROM": "FCO", "MIL": "MXP", "LON": "LHR", "STO": "ARN"}


def coords_aeropuerto(codigo):
    try:
        import airportsdata
        a = airportsdata.load("IATA").get(AEROPUERTO_CIUDAD.get(codigo, codigo))
        return (a["lat"], a["lon"]) if a else (None, None)
    except Exception:
        return (None, None)


def coordenadas_por_nombre(html):
    """Del JSON que trae la página: nombre -> (lat, lon, dirección)."""
    out = {}
    for m in re.finditer(r'"((?:[^"\\]|\\.){3,90})",\s*\[\[(-?\d+\.\d+),\s*(-?\d+\.\d+)\]'
                         r'(?:,\s*\[\[\["((?:[^"\\]|\\.){3,120})"\]\]\])?', html):
        def limpiar(t):      # deshace los \uXXXX sin romper los acentos
            try:
                return json.loads(f'"{t}"')
            except Exception:
                return t
        nombre = limpiar(m.group(1))
        if nombre not in out:
            out[nombre] = (float(m.group(2)), float(m.group(3)), limpiar(m.group(4) or ""))
    return out


def _num(txt):
    """'1,0 mil' -> 1000 ; '1.242' -> 1242 ; '4,3' -> 4.3"""
    if not txt:
        return None
    t = txt.strip().lower().replace("(", "").replace(")", "")
    mil = "mil" in t
    t = t.replace("mil", "").strip().replace(".", "").replace(",", ".")
    try:
        v = float(t)
    except ValueError:
        return None
    return v * 1000 if mil else v


def parsear(html, codigo, ciudad, entrada, noches):
    """Saca una fila por alojamiento, con precio, calidad, servicios y distancias."""
    p = LexborHTMLParser(html)
    consulta = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    salida = (entrada + timedelta(days=noches)).isoformat()
    geo = coordenadas_por_nombre(html)
    lat_c, lon_c = centro_ciudad(ciudad)
    if not lat_c:
        lat_c, lon_c = _aprox.get(ciudad) or centro_aproximado(ciudad, geo)
    lat_a, lon_a = coords_aeropuerto(codigo)
    filas = []
    for tarjeta in p.css("div.Zvwhrc"):
        nombre_n = tarjeta.css_first("div.QT7m7")
        if not nombre_n:
            continue
        nombre = nombre_n.text(strip=True)
        txt = tarjeta.text(separator=" ▸ ", strip=True)
        precio = re.search(r"([\d.,]+)\s*(€|US\$|\$|£)\s*▸?\s*por noche", txt)
        total = re.search(r"([\d.,]+)\s*(?:€|US\$|\$|£)\s*(?:▸\s*)?en total", txt)
        nn = re.search(r"(\d+)\s+noches?", txt)
        val = re.search(r"▸ (\d[,.]\d) ▸ \((\d[\d.,]*(?:\s*mil)?)\)", txt)
        etiquetas = [x.text(strip=True) for n in tarjeta.css("div.HlxIlc")
                     for x in n.iter(include_text=False) if x.text(strip=True)]
        servicios = " · ".join(dict.fromkeys(etiquetas))
        bajo = servicios.lower()
        estrellas = re.search(r"de (\d) estrellas?", bajo)
        tipo = next((t for t in TIPOS if t in bajo or t in nombre.lower()), "")
        lat, lon, direccion = geo.get(nombre, (None, None, ""))
        km_centro = haversine(lat, lon, lat_c, lon_c) if lat and lat_c else ""
        km_aero = haversine(lat, lon, lat_a, lon_a) if lat and lat_a else ""
        min_coche = minutos_coche(lat, lon, lat_c, lon_c, km_centro)
        enlace = next((a.attributes.get("href", "") for a in tarjeta.css("a")
                       if "/travel/hotels/entity/" in a.attributes.get("href", "")), "")
        fila = {
            "fecha_entrada": entrada.isoformat(), "fecha_salida": salida,
            "noches": int(nn.group(1)) if nn else noches,
            "codigo": codigo, "ciudad": ciudad, "nombre": nombre,
            "precio_noche": (_num(precio.group(1)) if precio
                             else (round(_num(total.group(1)) / (int(nn.group(1)) if nn else noches), 2)
                                   if total else "")),
            "precio_total": _num(total.group(1)) if total else "",
            "moneda": (precio.group(2) if precio else "").replace("US$", "USD").replace("€", "EUR"),
            "valoracion": _num(val.group(1)) if val else "",
            "resenas": int(_num(val.group(2)) or 0) if val else "",
            "estrellas": int(estrellas.group(1)) if estrellas else "",
            "tipo": tipo, "lat": lat or "", "lon": lon or "", "direccion": direccion,
            "km_centro": km_centro,
            # a pie: la calle da rodeos (x1,3) y se anda a unos 4,8 km/h
            "min_andando": round(km_centro * 1.3 / 4.8 * 60) if km_centro != "" else "",
            "min_coche": min_coche,
            "min_transporte": minutos_transporte(lat, lon, lat_c, lon_c, min_coche, km_centro),
            "km_aeropuerto": km_aero,
            "min_coche_aeropuerto": minutos_coche(lat, lon, lat_a, lon_a, km_aero),
            "min_andando_aeropuerto": round(km_aero * 1.3 / 4.8 * 60) if km_aero != "" else "",
            "servicios": servicios,
            "buena_ubicacion": "sí" if "excelente ubicación" in txt.lower() else "no",
            "oferta": "sí" if "oferta" in txt.lower() else "no",
            "enlace": "https://www.google.com" + enlace.split("?")[0] if enlace else "",
            "consulta": consulta,
        }
        for col in COLS_SERVICIO:
            fila[col] = "no"
        for clave, col in SERVICIOS.items():
            if clave in bajo:
                fila[col] = "sí"
        if fila.get("parking_gratis") == "sí" or fila.get("parking_pago") == "sí":
            fila["parking"] = "sí"
        filas.append(fila)
    return filas


def consultar(codigo, ciudad, entrada, noches, reintentos=3, sort_by=None):
    """Una búsqueda: ciudad + fechas escritas en la propia consulta (Google las entiende).
    sort_by (experimental): valor de SORTS_HOTEL para pedir la página con otro orden."""
    salida = entrada + timedelta(days=noches)
    q = f"hotels in {ciudad} {entrada.isoformat()} to {salida.isoformat()}"
    params = {"q": q, "hl": "es", "gl": "es", "curr": "EUR"}
    if sort_by:
        params["sort"] = str(sort_by)
    ultimo = None
    for intento in range(1, reintentos + 1):
        espera = vm._bloqueo["hasta"] - time.time()
        if espera > 0:
            time.sleep(espera)
        vm.ritmo.esperar()
        try:
            h = vm._cliente().get(URL, params=params, cookies=vm.COOKIES).text
            filas = parsear(h, codigo, ciudad, entrada, noches)
            if filas:
                vm.ritmo.ok()
                return filas
            # sin resultados: solo entonces miramos si es un bloqueo de verdad
            bajo = h[:20000].lower()
            if any(k in bajo for k in ("tráfico inusual", "unusual traffic", "/sorry/index")):
                raise vm.Bloqueo("Google pide captcha por tráfico inusual")
            if "antes de ir a google" in bajo or "consent.google" in bajo:
                raise vm.PaginaCookies("Google ha devuelto la página de cookies")
            return []
        except Exception as e:
            ultimo = e
            if isinstance(e, vm.Bloqueo):
                vm.ritmo.frenar()
                with vm._print_lock:
                    nuevo = vm._bloqueo["hasta"] < time.time()
                    if nuevo:
                        vm._bloqueo["hasta"] = time.time() + vm.ESPERA_BLOQUEO
                if nuevo:
                    vm.log(f"  ~ Google ha detectado demasiadas consultas: pausa de {vm.ESPERA_BLOQUEO} s",
                           err=True)
                continue
            time.sleep(2 * intento)
    vm.registrar_error(vm.tipo_error(ultimo), "MAD", codigo, entrada, ultimo)
    raise RuntimeError(f"hoteles {codigo} {entrada}: {ultimo}")


def consultar_multi(codigo, ciudad, entrada, noches, pases=1, reintentos=3):
    """EXPERIMENTAL: repite la consulta con distintos criterios de orden de Google (ver
    SORTS_HOTEL) y junta los alojamientos que no hayan salido ya (por nombre), para intentar
    sacar más de los ~20-30 que trae una sola página. pases=1 = comportamiento de siempre
    (una sola consulta, sin 'sort'). No está verificado que el parámetro cambie de verdad
    el listado de Google: compara el número de filas con pases=1 y pases=3 para saberlo."""
    vistos = set()
    todas = []
    for sort_by in SORTS_HOTEL[:max(1, pases)]:
        filas = consultar(codigo, ciudad, entrada, noches, reintentos=reintentos, sort_by=sort_by)
        for fila in filas:
            nombre = fila.get("nombre")
            if nombre and nombre not in vistos:
                vistos.add(nombre)
                todas.append(fila)
        if len(todas) >= TOPE_ALOJAMIENTOS:
            break
    return todas


def clave(r):
    return (r.get("fecha_entrada") or "", r.get("noches") or "", r.get("codigo") or "")


def compactar(ruta):
    """Deja solo la consulta más reciente de cada ciudad/fecha y quita lo ya pasado."""
    if not os.path.exists(ruta):
        return 0
    ultima = {}
    with open(ruta, encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f, delimiter=";"):
            if r.get("fecha_entrada") and (r.get("consulta") or "") > ultima.get(clave(r), ""):
                ultima[clave(r)] = r["consulta"]
    hoy = date.today().isoformat()
    tmp = ruta + ".tmp"
    n = 0
    with open(ruta, encoding="utf-8-sig", newline="") as f, \
            open(tmp, "w", encoding="utf-8-sig", newline="") as g:
        w = csv.DictWriter(g, fieldnames=COLUMNAS, delimiter=";", extrasaction="ignore")
        w.writeheader()
        for r in csv.DictReader(f, delimiter=";"):
            if r.get("fecha_entrada", "") > hoy and r.get("consulta") == ultima.get(clave(r)):
                w.writerow(r)
                n += 1
    try:
        os.replace(tmp, ruta)
    except OSError:
        os.remove(tmp)
    return n


def main():
    p = argparse.ArgumentParser(description="Precios de alojamiento por destino y fecha")
    p.add_argument("--destinos", nargs="*", help="códigos IATA (los mismos que los vuelos)")
    p.add_argument("--dias", type=int, default=DIAS)
    p.add_argument("--noches", type=int, default=NOCHES,
                   help="1 = una noche por día (recomendado: luego se suman las que haga falta)")
    p.add_argument("--salida", default=CSV_HOTELES)
    p.add_argument("--historico", default=CSV_HISTORICO,
                   help="CSV con un precio por consulta, para medir volatilidad y subidas")
    p.add_argument("--hilos", type=int, default=HILOS)
    p.add_argument("--velocidad", type=float, default=1.5)
    p.add_argument("--velocidad-max", type=float, default=8.0)
    p.add_argument("--actualizar", nargs="?", const=0, type=float, metavar="HORAS")
    p.add_argument("--prioritarios", nargs="*", default=[])
    p.add_argument("--peso", type=float, default=0.7)
    p.add_argument("--umbral", type=int, default=0)
    p.add_argument("--sondeo", nargs="?", const=vm.SONDEO_N, type=int, metavar="N",
                   help="comprueba N alojamientos al azar por mes ya descargado y solo "
                        "recalcula los meses donde el precio típico haya cambiado de verdad")
    p.add_argument("--sondeo-dif", type=float, default=vm.SONDEO_DIF,
                   help="€ de diferencia a partir de los cuales se considera que el precio cambió")
    p.add_argument("--pases-hotel", type=int, default=1, dest="pases_hotel",
                   help="EXPERIMENTAL: repite cada consulta con otro orden (precio, valoración) "
                        "y junta los alojamientos nuevos, para intentar traer más de los ~20-30 "
                        "que da una sola página. 1 = como siempre. Multiplica las peticiones a "
                        "Google por este número: más lento y más riesgo de captcha.")
    p.add_argument("--pares", nargs="*",
                   help="consultas exactas 'CODIGO:AAAA-MM-DD'; si se da, ignora --dias y "
                        "--destinos y solo consulta justo esas ciudades/fechas "
                        "(favoritos o filtro concreto)")
    p.add_argument("--pares-fichero", metavar="RUTA",
                   help="fichero de texto con una consulta 'CODIGO:AAAA-MM-DD' por línea, para no "
                        "toparse con el límite de longitud de la línea de comandos de Windows "
                        "cuando --pares tendría muchísimas filas; se juntan con --pares si se "
                        "dan los dos")
    p.add_argument("--desde", metavar="AAAA-MM-DD",
                   help="primer día a consultar (por defecto, mañana); junto con --hasta sustituye a --dias")
    p.add_argument("--hasta", metavar="AAAA-MM-DD", help="último día a consultar (incluido)")
    a = p.parse_args()
    if a.desde or a.hasta:      # rango de fechas: se traduce a nº de días desde el primero
        _ini = date.fromisoformat(a.desde) if a.desde else date.today() + timedelta(days=1)
        if a.hasta:
            a.dias = max((date.fromisoformat(a.hasta) - _ini).days + 1, 0)
    if a.pares_fichero:
        with open(a.pares_fichero, encoding="utf-8") as f:
            a.pares = (a.pares or []) + [l.strip() for l in f if l.strip()]

    vm.ritmo = vm.Ritmo(a.velocidad, a.velocidad_max)
    vm.CSV_ERRORES = os.path.join(os.path.dirname(os.path.abspath(a.salida)), "errores_descarga.csv")
    a.historico = os.path.join(os.path.dirname(os.path.abspath(a.salida)), os.path.basename(a.historico))
    destinos = {k: vm.DESTINOS.get(k, k) for k in (a.destinos or vm.DESTINOS)}
    if a.pares:
        destinos = {k: vm.DESTINOS.get(k, k) for k in {par.split(":", 1)[0] for par in a.pares}}
    try:
        compactar(a.salida)
    except Exception as e:
        vm.log(f"  ! no he podido limpiar {a.salida}: {e}", err=True)

    hechas = {}
    previas = []
    if os.path.exists(a.salida):
        with open(a.salida, encoding="utf-8-sig", newline="") as f:
            for r in csv.DictReader(f, delimiter=";"):
                if r.get("fecha_entrada"):
                    hechas[clave(r)] = r.get("consulta", "")
                    previas.append(r)

    inicio = date.fromisoformat(a.desde) if a.desde else date.today() + timedelta(days=1)
    tareas = []
    if a.pares:
        for par in a.pares:
            cod, fecha_str = par.split(":", 1)
            f = date.fromisoformat(fecha_str)
            ciudad = destinos.get(cod, cod)
            k = (f.isoformat(), str(a.noches), cod)
            if k in hechas and a.actualizar is None:
                continue
            tareas.append((cod, ciudad, f))
    else:
        for i in range(a.dias):
            f = inicio + timedelta(days=i)
            for cod, ciudad in destinos.items():
                k = (f.isoformat(), str(a.noches), cod)
                if k in hechas:
                    if a.actualizar is None:
                        continue
                    try:
                        edad = (datetime.now() - datetime.strptime(hechas[k][:16], "%Y-%m-%d %H:%M")).total_seconds() / 3600
                    except ValueError:
                        edad = 1e9
                    if edad <= a.actualizar:
                        continue
                tareas.append((cod, ciudad, f))
    tareas = vm.ordenar_por_prioridad([(f, "HOTEL", "MAD", cod, cod, ciudad) for cod, ciudad, f in tareas],
                                      set(a.prioritarios or []), a.peso, a.umbral)
    tareas = [(t[3], t[5], t[0]) for t in tareas]

    if a.sondeo:
        ruta_sondeo = os.path.join(os.path.dirname(os.path.abspath(a.salida)), CSV_SONDEO_HOT)

        def consulta_sondeo(r):
            f = date.fromisoformat(r["fecha_entrada"])
            nn = int(r.get("noches") or 1)
            vm.log(f"  > {r['ciudad']} {r['fecha_entrada']} (sondeo)")
            filas = consultar_multi(r["codigo"], r["ciudad"], f, nn, pases=a.pases_hotel)
            precios = [x["precio_noche"] for x in filas if x["precio_noche"]]
            return min(precios) if precios else None

        muestreables = [r for r in previas
                        if r.get("precio_noche") and r["fecha_entrada"] > date.today().isoformat()
                        and r["codigo"] in destinos]
        print(f"Sondeo: {a.sondeo} alojamientos al azar por mes ({len(muestreables)} candidatos)")
        meses_ok, _ = vm.sondear_meses(muestreables, a.sondeo, consulta_sondeo, ruta_sondeo, a.sondeo_dif,
                                       fecha_col="fecha_entrada", precio_col="precio_noche")
        if not meses_ok:
            print("Ningún mes ha cambiado lo suficiente: no hace falta recalcular nada.")
            return
        print(f"Meses a recalcular: {', '.join(meses_ok)}")
        tareas = [t for t in tareas if t[2].strftime("%Y-%m") in set(meses_ok)]

    total = len(tareas)
    if a.pares:
        print(f"{len(a.pares)} consultas concretas (favoritos/filtro) | pendientes: {total}"
              + (f" · {a.pases_hotel} pases/consulta (experimental)" if a.pases_hotel > 1 else ""))
    else:
        print(f"{len(destinos)} destinos x {a.dias} días ({a.noches} noches) | pendientes: {total}"
          + (f" · {a.pases_hotel} pases/consulta (experimental)" if a.pases_hotel > 1 else ""))
    if not total:
        return

    nuevo = not os.path.exists(a.salida)
    fh = open(a.salida, "a", encoding="utf-8-sig" if nuevo else "utf-8", newline="")
    w = csv.DictWriter(fh, fieldnames=COLUMNAS, delimiter=";", extrasaction="ignore")
    if nuevo:
        w.writeheader()
        fh.flush()

    nuevo_hist = not os.path.exists(a.historico)
    fhist = open(a.historico, "a", encoding="utf-8-sig" if nuevo_hist else "utf-8", newline="")
    whist = csv.DictWriter(fhist, fieldnames=COLUMNAS_HIST, delimiter=";", extrasaction="ignore")
    if nuevo_hist:
        whist.writeheader()
        fhist.flush()

    errores = seguidos = 0
    t0 = time.time()

    def trabajo(t):
        cod, ciudad, f = t
        vm.log(f"  > {ciudad} {f.isoformat()} ({a.noches}n)")
        filas = consultar_multi(cod, ciudad, f, a.noches, pases=a.pases_hotel)
        if filas:
            precios = [x["precio_noche"] for x in filas if x["precio_noche"]]
            vm.log(f"  = {ciudad} {f.isoformat()} {len(filas)} alojamientos"
                   + (f", desde {min(precios):.0f} EUR/noche" if precios else ""))
        else:
            vm.log(f"  = {ciudad} {f.isoformat()} sin resultados")
        return filas

    try:
        with ThreadPoolExecutor(max_workers=a.hilos) as ex:
            futuros = [ex.submit(trabajo, t) for t in tareas]
            for k, fut in enumerate(as_completed(futuros), 1):
                try:
                    filas = fut.result()
                    seguidos = 0
                    with vm._print_lock:
                        w.writerows(filas)
                        fh.flush()
                        whist.writerows(filas)
                        fhist.flush()
                except Exception as e:
                    errores += 1
                    seguidos += 1
                    vm.log(f"  ! {e}", err=True)
                    if seguidos >= 15:
                        vm.log("  !! 15 errores seguidos: detengo la descarga.", err=True)
                        ex.shutdown(wait=False, cancel_futures=True)
                        break
                ritmo_s = (time.time() - t0) / k
                vm.log(f"  {k}/{total}  ({errores} errores)  ~{(total - k) * ritmo_s / 60:.0f} min restantes"
                       f"  [{vm.ritmo.cps:.1f} consultas/s, {a.hilos} hilos]  t={time.time() - t0:.0f}s")
    except KeyboardInterrupt:
        print("\nInterrumpido. Lo descargado está guardado.")
    finally:
        fh.close()
        fhist.close()
    n = compactar(a.salida)
    print(f"Hecho -> {a.salida}  ({n} filas, {errores} errores)")


if __name__ == "__main__":
    main()
:::END
:::BEGIN py/trenes_madrid.py|text
"""
Descarga precios de tren (Renfe + Ouigo) desde Madrid a destinos nacionales, y la vuelta.

Guarda UNA FILA POR TREN Y CONSULTA (hora, duración, tipo de tren, precio de cada tarifa,
plazas libres si la compañía las da), para poder filtrar luego en la app sin volver a bajar.

Uso:
    python trenes_madrid.py --destinos 71801 51003 --dias 60
    python trenes_madrid.py --actualizar 24          # refresca lo de hace más de 24 h
    python trenes_madrid.py --pares 71801:2026-11-10:ida 71801:2026-11-14:vuelta

Fuentes (gratuitas, sin clave): venta.renfe.com (la misma web de compra, vía DWR) y la API
pública de la web de Ouigo. iryo no se consulta: exige un navegador real (Cloudflare).
"""

import argparse
import csv
import http.cookiejar
import json
import os
import random
import re
import string
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import date, datetime, timedelta
from threading import Lock

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vuelos_madrid as vm          # se reutilizan ritmo, registro de errores y orden por prioridad

try:
    import json5
except ImportError:                  # sin json5 se usa un conversor sencillo (ver _js_a_dict)
    json5 = None

CARPETA = os.path.dirname(os.path.abspath(__file__))     # .../Vuelos/py
BASE = os.path.dirname(CARPETA)                            # .../Vuelos
CSV_DIR = os.path.join(BASE, "csv")
os.makedirs(CSV_DIR, exist_ok=True)
CSV_TRENES = os.path.join(CSV_DIR, "trenes.csv")
CSV_HISTORICO = os.path.join(CSV_DIR, "historico_trenes.csv")
ESTADO = os.path.join(BASE, "trenes_estado.json")          # qué destinos tienen Ouigo (se aprende solo)

DIAS = 60
HILOS = 4
REINTENTOS = 3
UA = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) "
      "Chrome/131.0.0.0 Safari/537.36")

# --------------------------------------------------------------------------- estaciones
# código Renfe (5 cifras) -> (ciudad, estación, grupo). El código UIC de Ouigo es "71" + código Renfe.
MADRID = ("MADRI", "MADRID (TODAS)", "MT1")    # código Renfe, nombre Renfe, código Ouigo

GRUPOS_TREN = {
    "Cataluña": {
        "71801": ("Barcelona", "BARCELONA-SANTS"), "79300": ("Girona", "GIRONA"),
        "78400": ("Lleida", "LLEIDA-PIRINEUS"), "04104": ("Tarragona (Camp)", "CAMP TARRAGONA"),
        "04307": ("Figueres", "FIGUERES VILAFANT"), "71400": ("Reus", "REUS"),
    },
    "Aragón y Navarra": {
        "04040": ("Zaragoza", "ZARAGOZA-DELICIAS"), "70600": ("Calatayud", "CALATAYUD"),
        "74200": ("Huesca", "HUESCA"), "67200": ("Teruel", "TERUEL"),
        "80100": ("Pamplona", "PAMPLONA/IRUÑA"), "81202": ("Tudela", "TUDELA DE NAVARRA"),
    },
    "Levante y Murcia": {
        "03216": ("Valencia", "VALENCIA JOAQUÍN SOROLLA"), "60911": ("Alicante", "ALICANTE/ALACANT"),
        "65300": ("Castellón", "CASTELLÓ"), "61200": ("Murcia", "MURCIA"),
        "61307": ("Cartagena", "CARTAGENA"), "62103": ("Elche", "ELCHE PARQUE/ELX PARC"),
        "60600": ("Albacete", "ALBACETE-LOS LLANOS"), "64100": ("Xàtiva", "XÀTIVA"),
        "03213": ("Requena-Utiel", "REQUENA UTIEL"), "60902": ("Villena", "VILLENA"),
    },
    "Andalucía": {
        "51003": ("Sevilla", "SEVILLA-SANTA JUSTA"), "54413": ("Málaga", "MÁLAGA MARÍA ZAMBRANO"),
        "50500": ("Córdoba", "CÓRDOBA"), "05000": ("Granada", "GRANADA"),
        "56312": ("Almería", "ALMERÍA"), "51405": ("Cádiz", "CÁDIZ"),
        "51300": ("Jerez", "JEREZ DE LA FRONTERA"), "43019": ("Huelva", "HUELVA"),
        "03100": ("Jaén", "JAÉN"), "50300": ("Linares-Baeza", "LINARES-BAEZA"),
        "02003": ("Antequera", "ANTEQUERA-SANTA ANA"), "55007": ("Ronda", "RONDA"),
        "55020": ("Algeciras", "ALGECIRAS"), "02002": ("Puente Genil", "PUENTE GENIL-HERRERA"),
    },
    "Norte": {
        "13200": ("Bilbao", "BILBAO-ABANDO INDALECIO PRIETO"), "11511": ("San Sebastián", "SAN SEBASTIÁN/DONOSTIA"),
        "11208": ("Vitoria", "VITORIA/GASTEIZ"), "14223": ("Santander", "SANTANDER"),
        "15211": ("Oviedo", "OVIEDO/UVIÉU"), "15410": ("Gijón", "GIJÓN/XIXÓN"),
        "81100": ("Logroño", "LOGROÑO"), "11014": ("Burgos", "BURGOS ROSA MANZANO"),
        "11200": ("Miranda de Ebro", "MIRANDA DE EBRO"), "11600": ("Irun", "IRUN"),
    },
    "Galicia": {
        "31400": ("Santiago", "SANTIAGO DE COMPOSTELA"), "31412": ("A Coruña", "A CORUÑA"),
        "22308": ("Vigo", "VIGO GUIXAR"), "22100": ("Ourense", "OURENSE"),
        "23004": ("Pontevedra", "PONTEVEDRA"), "20309": ("Lugo", "LUGO"),
        "21010": ("Ferrol", "FERROL"), "20200": ("Ponferrada", "PONFERRADA"),
    },
    "Castilla y León": {
        "10600": ("Valladolid", "VALLADOLID"), "15100": ("León", "LEÓN"),
        "30100": ("Salamanca", "SALAMANCA"), "14100": ("Palencia", "PALENCIA"),
        "30200": ("Zamora", "ZAMORA"), "08004": ("Segovia", "SEGOVIA GUIOMAR"),
        "10400": ("Ávila", "ÁVILA"), "82100": ("Soria", "SORIA"),
        "10500": ("Medina del Campo", "MEDINA DEL CAMPO"),
    },
    "Centro": {
        "92102": ("Toledo", "TOLEDO"), "04007": ("Guadalajara-Yebes", "GUADALAJARA - YEBES"),
        "03208": ("Cuenca", "CUENCA FERNANDO ZÓBEL"), "37200": ("Ciudad Real", "CIUDAD REAL"),
        "37300": ("Puertollano", "PUERTOLLANO"), "35200": ("Talavera", "TALAVERA DE LA REINA"),
    },
    "Extremadura": {
        "37606": ("Badajoz", "BADAJOZ"), "35400": ("Cáceres", "CÁCERES"),
        "37500": ("Mérida", "MÉRIDA"), "30002": ("Plasencia", "PLASENCIA"),
        "40100": ("Zafra", "ZAFRA"),
    },
    # AVE internacional Renfe-SNCF Madrid–Barcelona–Marsella: único tren directo desde Madrid a Europa.
    # Solo lo vende Renfe (Ouigo no llega) y los códigos no siguen la regla "71 + código Renfe".
    "Europa (directo desde Madrid)": {
        "87374": ("Perpiñán", "PERPIGNAN"), "87088": ("Narbona", "NARBONNE"),
        "MONTP": ("Montpellier", "MONTPELLIER"), "NIMES": ("Nimes", "NIMES"),
        "87814": ("Aviñón TGV", "AVIGNON TGV"), "87912": ("Aix-en-Provence TGV", "AIX EN PROVENCE TGV"),
        "87089": ("Marsella", "MARSEILLE ST CHARLES"),
    },
}
# Destinos que Renfe solo vende desde Barcelona (AVE internacional Barcelona–Lyon/Valence): se
# construyen combinando Madrid↔Barcelona con Barcelona↔destino, con un transbordo mínimo.
HUB = ("71801", "Barcelona", "BARCELONA-SANTS")
GRUPOS_TREN["Europa (vía Barcelona)"] = {
    "LYON-": ("Lyon", "LYON"), "VALFR": ("Valence", "VALENCE"),
}
NIVEL2 = set(GRUPOS_TREN["Europa (vía Barcelona)"])
MIN_TRANSBORDO = 45        # minutos entre la llegada y la salida del siguiente tren
# Francia/Italia con precio real: Madrid ↔ Lyon (Renfe, vía Barcelona) + Lyon ↔ destino (Frecciarossa,
# API pública de lefrecce.it/Trenitalia, la única con precios sin bloqueo antibots).
LYON_COD = "LYON-"
TI = "https://www.lefrecce.it/Channels.Website.BFF.WEB/website/"
TI_LYON = 870072319        # Lyon Part-Dieu
GRUPOS_TREN["Europa (vía Lyon, Trenitalia)"] = {
    "PARIS": ("París", "PARIS"), "MILAN": ("Milán", "MILANO"), "TURIN": ("Turín", "TORINO"),
}
NIVEL3 = {"PARIS": 870075890, "MILAN": 830001650, "TURIN": 830000996}     # id de ciudad en Trenitalia
EUROPA = set(GRUPOS_TREN["Europa (directo desde Madrid)"]) | NIVEL2 | set(NIVEL3)
DESTINOS = {c: v[0] for g in GRUPOS_TREN.values() for c, v in g.items()}
ESTACION = {c: v[1] for g in GRUPOS_TREN.values() for c, v in g.items()}

COLUMNAS = ["consulta", "fecha", "sentido", "codigo", "ciudad", "origen", "destino", "compania", "tren",
            "tipo_tren", "hora_salida", "hora_llegada", "duracion_min", "directo", "disponible",
            "precio_eur", "tarifa_min", "precio_max", "tarifas", "plazas", "distancia_km", "enlace"]
COLUMNAS_HIST = ["consulta", "fecha", "sentido", "codigo", "ciudad", "compania", "tren", "hora_salida",
                 "precio_eur"]
ENLACES = {"Renfe": "https://www.renfe.com/es/es", "Ouigo": "https://ouigo.com/es/",
           "Trenitalia": "https://www.trenitalia.com/es.html"}


# --------------------------------------------------------------------------- utilidades
_lock_estado = Lock()


def leer_estado():
    try:
        with open(ESTADO, encoding="utf-8") as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


def guardar_estado(e):
    try:
        tmp = ESTADO + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(e, f, ensure_ascii=False)
        os.replace(tmp, ESTADO)
    except OSError:
        pass


def _num(txt):
    """'37,35' -> 37.35 (o None)."""
    if txt is None or txt == "":
        return None
    try:
        return float(str(txt).replace(".", "").replace(",", ".")) if "," in str(txt) else float(txt)
    except ValueError:
        return None


def _hm(ts):
    """'2026-10-10T06:22:00+02:00' -> '06:22'."""
    m = re.search(r"T(\d\d:\d\d)", ts or "")
    return m.group(1) if m else ""


def _min_entre(s, ll):
    try:
        a = datetime.strptime(s, "%H:%M")
        b = datetime.strptime(ll, "%H:%M")
        d = (b - a).total_seconds() / 60
        return int(d if d >= 0 else d + 1440)
    except ValueError:
        return None


# --------------------------------------------------------------------------- Renfe (DWR)
RENFE = "https://venta.renfe.com/vol/"
DWR = RENFE + "dwr/call/plaincall/"


def _tokenify(n):
    cm = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ*$"
    out = []
    while n > 0:
        out.append(cm[n & 63])
        n //= 64
    return "".join(out)


def _js_a_dict(txt):
    """Convierte el objeto JavaScript de Renfe en dict. Usa json5 si está; si no, un arreglo sencillo."""
    if json5 is not None:
        return json5.loads(txt)
    t = re.sub(r"([{,]\s*)([A-Za-z_$][\w$]*)\s*:", r'\1"\2":', txt)
    t = re.sub(r"'((?:[^'\\]|\\.)*)'", lambda m: json.dumps(m.group(1)), t)
    return json.loads(t)


def renfe_trenes(origen, destino, f):
    """origen/destino = (código Renfe, nombre). Devuelve la lista cruda de trenes de ese día."""
    cj = http.cookiejar.CookieJar()
    op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    op.addheaders = [("User-Agent", UA), ("Accept", "*/*")]
    sid = "_" + "".join(random.choice(string.ascii_letters + string.digits) for _ in range(4))
    busq = {"origen": {"code": origen[0], "name": origen[1]}, "destino": {"code": destino[0], "name": destino[1]},
            "pasajerosAdultos": 1, "pasajerosNinos": 0, "pasajerosSpChild": 0}
    cj.set_cookie(http.cookiejar.Cookie(0, "Search", str(busq), None, False, ".renfe.com", True, True, "/",
                                        True, False, None, True, None, None, {}))
    fs = f.strftime("%d/%m/%Y")

    def post(url, data):
        if isinstance(data, dict):
            data = urllib.parse.urlencode(data)
        r = op.open(urllib.request.Request(url, data=data.encode(), method="POST"), timeout=30)
        return r.read().decode("utf-8", "replace")

    post(RENFE + "buscarTren.do?Idioma=es&Pais=ES", {
        "tipoBusqueda": "autocomplete", "currenLocation": "menuBusqueda", "vengoderenfecom": "SI",
        "desOrigen": origen[1], "desDestino": destino[1], "cdgoOrigen": origen[0], "cdgoDestino": destino[0],
        "idiomaBusqueda": "ES", "FechaIdaSel": fs, "FechaVueltaSel": "", "_fechaIdaVisual": fs,
        "_fechaVueltaVisual": "", "adultos_": "1", "ninos_": "0", "ninosMenores": "0", "codPromocional": "",
        "plazaH": "false", "sinEnlace": "false", "asistencia": "false", "franjaHoraI": "", "franjaHoraV": "",
        "Idioma": "es", "Pais": "ES"})
    lote = [0]
    pagina = f"page=%2Fvol%2FbuscarTrenEnlaces.do%3Fc%3D{sid}\n"

    def gen_id():
        p = ("callCount=1\nc0-scriptName=__System\nc0-methodName=generateId\nc0-id=0\n"
             f"batchId={lote[0]}\ninstanceId=0\n{pagina}scriptSessionId=\nwindowName=\n")
        lote[0] += 1
        return post(DWR + "__System.generateId.dwr", p)

    gen_id()
    m = re.search(r'r\.handleCallback\("[^"]+","[^"]+","([^"]+)"\)', gen_id())
    if not m:
        raise RuntimeError("Renfe no ha dado token DWR")
    tok = m.group(1)
    cj.set_cookie(http.cookiejar.Cookie(0, "DWRSESSIONID", tok, None, False, "venta.renfe.com", True, False,
                                        "/vol", True, False, None, True, None, None, {}))
    ss = f"{tok}/{_tokenify(int(time.time() * 1000))}-{_tokenify(int(random.random() * 1e16))}"
    p = ("callCount=1\nwindowName=\nc0-scriptName=buyEnlacesManager\nc0-methodName=actualizaObjetosSesion\n"
         f"c0-id=0\nc0-e1=string:{sid}\nc0-e2=string:\nc0-param0=array:[reference:c0-e1,reference:c0-e2]\n"
         f"batchId={lote[0]}\ninstanceId=0\n{pagina}scriptSessionId={ss}\n")
    lote[0] += 1
    post(DWR + "buyEnlacesManager.actualizaObjetosSesion.dwr", p)
    q = urllib.parse.quote_plus(fs)
    p = ("callCount=1\nwindowName=\nc0-scriptName=trainEnlacesManager\nc0-methodName=getTrainsList\nc0-id=0\n"
         "c0-e1=string:false\nc0-e2=string:false\nc0-e3=string:false\nc0-e4=string:\nc0-e5=string:\n"
         "c0-e6=string:\nc0-e7=string:\n"
         f"c0-e8=string:{q}\nc0-e9=string:\nc0-e10=string:1\nc0-e11=string:0\nc0-e12=string:0\n"
         "c0-e13=string:I\nc0-e14=string:\n"
         "c0-param0=Object_Object:{atendo:reference:c0-e1, sinEnlace:reference:c0-e2, plazaH:reference:c0-e3, "
         "tipoFranjaI:reference:c0-e4, tipoFranjaV:reference:c0-e5, horaFranjaIda:reference:c0-e6, "
         "horaFranjaVuelta:reference:c0-e7, fechaSalida:reference:c0-e8, fechaVuelta:reference:c0-e9, "
         "adultos:reference:c0-e10, ninos:reference:c0-e11, ninosMenores:reference:c0-e12, "
         "trayecto:reference:c0-e13, idaVuelta:reference:c0-e14}\n"
         f"batchId={lote[0]}\ninstanceId=0\n{pagina}scriptSessionId={ss}\n")
    t = post(DWR + "trainEnlacesManager.getTrainsList.dwr", p)
    m = re.search(r"r\.handleCallback\([^,]+,\s*[^,]+,\s*(\{.*\})\);", t, re.DOTALL)
    if not m:
        bajo = t[:600].lower()
        if "captcha" in bajo or "robot" in bajo or "bloque" in bajo:
            raise vm.Bloqueo("Renfe pide captcha")
        return []
    d = _js_a_dict(m.group(1))
    lista = d.get("listadoTrenes") or []
    return (lista[0].get("listviajeViewEnlaceBean") or []) if lista else []


def filas_renfe(trenes, f, sentido, cod, ciudad, consulta):
    ori, des = ("Madrid", ciudad) if sentido == "ida" else (ciudad, "Madrid")
    filas = []
    for t in trenes:
        tarifas = []
        for a in t.get("tarifasDisponibles") or []:
            pr = _num(a.get("precioTarifa"))
            if pr is not None:
                tarifas.append((a.get("titulo") or a.get("codigoTarifa") or "?", pr))
        minimo = _num(t.get("tarifaMinima"))
        if minimo is None and tarifas:
            minimo = min(p for _, p in tarifas)
        disp = (not t.get("completo")) and minimo is not None and not t.get("soloPlazaH")
        tarifa_min = ""
        if tarifas and minimo is not None:
            tarifa_min = min(tarifas, key=lambda x: x[1])[0]
        tipo = t.get("tipoTrenUno") or ""
        if t.get("tipoTrenDos"):
            tipo += f" + {t['tipoTrenDos']}"
        num = ""
        try:
            num = t["tarifasDisponibles"][0]["tarifaTramoCombViewBean"][0].get("cdgoTren") or ""
        except (KeyError, IndexError, TypeError):
            pass
        dist = t.get("distancia")
        filas.append({
            "consulta": consulta, "fecha": f.isoformat(), "sentido": sentido, "codigo": cod, "ciudad": ciudad,
            "origen": ori, "destino": des, "compania": "Renfe", "tren": num, "tipo_tren": tipo,
            "hora_salida": t.get("horaSalida") or "", "hora_llegada": t.get("horaLlegada") or "",
            "duracion_min": t.get("duracionViajeTotalEnMinutos") or "",
            "directo": 1 if t.get("directo", True) else 0, "disponible": 1 if disp else 0,
            "precio_eur": round(minimo, 2) if (minimo is not None and disp) else "",
            "tarifa_min": tarifa_min if disp else "",
            "precio_max": round(max(p for _, p in tarifas), 2) if (tarifas and disp) else "",
            "tarifas": " | ".join(f"{n} {p:g}" for n, p in tarifas) if disp else "",
            "plazas": "", "distancia_km": round(dist / 1000) if isinstance(dist, (int, float)) and dist > 1000
            else (dist or ""), "enlace": ENLACES["Renfe"]})
    return filas


# --------------------------------------------------------------------------- Ouigo (API pública de su web)
OUIGO = "https://mdw02.api-es.ouigo.com/api/"
_tok = {"v": None, "hasta": 0.0}
_lock_tok = Lock()


def _ouigo_post(ruta, cuerpo, token=None):
    h = {"content-type": "application/json", "user-agent": UA}
    if token:
        h["authorization"] = "Bearer " + token
    r = urllib.request.Request(OUIGO + ruta, data=json.dumps(cuerpo).encode(), headers=h, method="POST")
    with urllib.request.urlopen(r, timeout=30) as f:
        return json.loads(f.read().decode("utf-8", "replace") or "{}")


def ouigo_token(forzar=False):
    with _lock_tok:
        if forzar or not _tok["v"] or time.time() > _tok["hasta"]:
            d = _ouigo_post("Token/login", {"username": "ouigo.web", "password": "SquirelWeb!2020"})
            _tok["v"] = d["token"]
            _tok["hasta"] = time.time() + 20 * 60
        return _tok["v"]


def ouigo_trenes(origen, destino, f):
    """origen/destino = código UIC de Ouigo. Devuelve la lista cruda de trenes (vacía si no hay servicio)."""
    cuerpo = {"origin": origen, "destination": destino, "outbound_date": f.isoformat(),
              "passengers": [{"discount_cards": [], "disability_type": "NH", "type": "A"}]}
    for intento in (1, 2):
        try:
            d = _ouigo_post("Sale/journeysearch", cuerpo, ouigo_token(forzar=intento == 2))
            return d.get("outbound") or []
        except urllib.error.HTTPError as e:
            if e.code == 401 and intento == 1:
                continue
            if e.code in (429, 403):
                raise vm.Bloqueo(f"Ouigo HTTP {e.code}")
            if 400 <= e.code < 500:
                return []          # ruta o fecha sin servicio
            raise
    return []


def filas_ouigo(trenes, f, sentido, cod, ciudad, consulta):
    ori, des = ("Madrid", ciudad) if sentido == "ida" else (ciudad, "Madrid")
    filas = []
    for t in trenes:
        seg = (t.get("segments") or [{}])[0]
        hs = _hm((t.get("departure_station") or {}).get("departure_timestamp"))
        hl = _hm((t.get("arrival_station") or {}).get("arrival_timestamp"))
        tarifas = []
        for p in t.get("packages") or []:
            pr = p.get("price_to_be_paid", p.get("price"))
            if isinstance(pr, (int, float)):
                tarifas.append((p.get("name") or p.get("product_family_id") or "?", float(pr)))
        minimo = t.get("price") if isinstance(t.get("price"), (int, float)) else None
        if minimo is None and tarifas:
            minimo = min(p for _, p in tarifas)
        disp = (not t.get("full")) and minimo is not None
        extra = []
        if isinstance(t.get("ouip_price"), (int, float)):
            extra.append(f"Ouigo+ +{t['ouip_price']:g}")
        if isinstance(t.get("flex_price"), (int, float)):
            extra.append(f"Flex +{t['flex_price']:g}")
        txt = " | ".join(f"{n} {p:g}" for n, p in tarifas) if disp else ""
        if txt and extra:
            txt += " | " + " | ".join(extra)
        filas.append({
            "consulta": consulta, "fecha": f.isoformat(), "sentido": sentido, "codigo": cod, "ciudad": ciudad,
            "origen": ori, "destino": des, "compania": "Ouigo", "tren": seg.get("service_name") or "",
            "tipo_tren": "OUIGO", "hora_salida": hs, "hora_llegada": hl,
            "duracion_min": _min_entre(hs, hl) or "", "directo": 1 if len(t.get("segments") or []) <= 1 else 0,
            "disponible": 1 if disp else 0, "precio_eur": round(float(minimo), 2) if disp else "",
            "tarifa_min": (min(tarifas, key=lambda x: x[1])[0] if (tarifas and disp) else ""),
            "precio_max": round(max(p for _, p in tarifas), 2) if (tarifas and disp) else "",
            "tarifas": txt, "plazas": t.get("remaining_seats") if t.get("remaining_seats") is not None else "",
            "distancia_km": "", "enlace": ENLACES["Ouigo"]})
    return filas


# --------------------------------------------------------------------------- consulta conjunta
def _con_reintentos(fn, etiqueta, cod, f):
    ultimo = None
    for intento in range(1, REINTENTOS + 1):
        espera = vm._bloqueo["hasta"] - time.time()
        if espera > 0:
            time.sleep(espera)
        vm.ritmo.esperar()
        try:
            r = fn()
            vm.ritmo.ok()
            return r
        except Exception as e:
            ultimo = e
            if isinstance(e, vm.Bloqueo):
                vm.ritmo.frenar()
                with vm._print_lock:
                    nuevo = vm._bloqueo["hasta"] < time.time()
                    if nuevo:
                        vm._bloqueo["hasta"] = time.time() + vm.ESPERA_BLOQUEO
                if nuevo:
                    vm.log(f"  ~ {etiqueta} ha detectado demasiadas consultas: pausa de "
                           f"{vm.ESPERA_BLOQUEO} s", err=True)
                continue
            time.sleep(2 * intento)
    vm.registrar_error(vm.tipo_error(ultimo), "MAD", cod, f, f"[tren {etiqueta}] {ultimo}")
    raise RuntimeError(f"{etiqueta} {cod} {f}: {ultimo}")


def _dt(f, hhmm):
    h, m = str(hhmm).split(":")[:2]
    return datetime(f.year, f.month, f.day, int(h), int(m))


def _tramos_renfe(crudo, f):
    """Trenes de un tramo suelto (lista cruda de Renfe) -> [{sal, lle, precio, tipo, tren}] con plazas."""
    out = []
    for t in crudo or []:
        minimo = _num(t.get("tarifaMinima"))
        if t.get("completo") or minimo is None or t.get("soloPlazaH") or not t.get("horaSalida"):
            continue
        sal = _dt(f, t["horaSalida"])
        dur = int(t.get("duracionViajeTotalEnMinutos") or 0)
        out.append({"sal": sal, "lle": sal + timedelta(minutes=dur), "precio": minimo,
                    "tipo": t.get("tipoTrenUno") or "AVE INT", "cia": "Renfe", "tren": ""})
    return out


def _tramos_filas(filas, f):
    """Mismo formato, a partir de las filas ya construidas de Madrid↔Barcelona (Renfe y Ouigo)."""
    out = []
    for r in filas:
        try:
            pr = float(r["precio_eur"])
            sal = _dt(f, r["hora_salida"])
            dur = int(float(r["duracion_min"]))
        except (ValueError, TypeError, KeyError):
            continue
        out.append({"sal": sal, "lle": sal + timedelta(minutes=dur), "precio": pr,
                    "tipo": r.get("tipo_tren") or "", "cia": r.get("compania") or "Renfe",
                    "tren": r.get("tren") or ""})
    return out


def consultar_nivel2(cod, ciudad, f, sentido, consulta):
    """Madrid → Barcelona + Barcelona → destino (o al revés en la vuelta). Para cada tren del segundo
    tramo se elige el primer tramo más barato que llegue con MIN_TRANSBORDO de margen; si el mismo día
    no hay combinación posible, se prueba con el día siguiente (noche en Barcelona)."""
    est_dest = (cod, ESTACION.get(cod, ciudad))
    hub = (HUB[0], HUB[2])
    mad = (MADRID[0], MADRID[1])

    def b(dia):     # tramo Barcelona <-> destino europeo
        o, d = (hub, est_dest) if sentido == "ida" else (est_dest, hub)
        return _tramos_renfe(_con_reintentos(lambda: renfe_trenes(o, d, dia), "Renfe", cod, dia), dia)

    def a(dia):     # tramo Madrid <-> Barcelona (Renfe y Ouigo)
        return _tramos_filas(consultar(HUB[0], HUB[1], dia, sentido), dia)

    if sentido == "ida":
        primero, segundo = a(f), None
        def segundo(dia): return b(dia)
    else:
        primero = b(f)
        def segundo(dia): return a(dia)
    combos, noche = [], False
    for k, dia in enumerate((f, f + timedelta(days=1))):
        if k == 1 and combos:
            break
        for x2 in segundo(dia):
            validos = [x1 for x1 in primero if (x2["sal"] - x1["lle"]).total_seconds() >= MIN_TRANSBORDO * 60]
            if validos:
                x1 = min(validos, key=lambda x: (x["precio"], -x["lle"].timestamp()))
                combos.append((x1, x2))
                noche = k == 1
    ori, des = ("Madrid", ciudad) if sentido == "ida" else (ciudad, "Madrid")
    filas = []
    for x1, x2 in sorted(combos, key=lambda c: (c[1]["lle"] - c[0]["sal"], c[0]["precio"] + c[1]["precio"])):
        total = round(x1["precio"] + x2["precio"], 2)
        pa, pb = (x1, x2) if sentido == "ida" else (x2, x1)     # pa = Madrid↔Barcelona, pb = Barcelona↔destino
        dur = int((x2["lle"] - x1["sal"]).total_seconds() // 60)
        tramo_a = "Madrid→Barcelona" if sentido == "ida" else "Barcelona→Madrid"
        tramo_b = f"Barcelona→{ciudad}" if sentido == "ida" else f"{ciudad}→Barcelona"
        filas.append({
            "consulta": consulta, "fecha": f.isoformat(), "sentido": sentido, "codigo": cod, "ciudad": ciudad,
            "origen": ori, "destino": des, "compania": "Combinado",
            "tren": f"{pa['cia']} {pa['tipo']} + Renfe {pb['tipo']}".strip(),
            "tipo_tren": f"{x1['tipo'] or x1['cia']} + AVE INT" + (" · noche en Barcelona" if noche else ""),
            "hora_salida": x1["sal"].strftime("%H:%M"), "hora_llegada": x2["lle"].strftime("%H:%M"),
            "duracion_min": dur, "directo": 0, "disponible": 1, "precio_eur": total,
            "tarifa_min": "Combinado", "precio_max": total, "tarifas": f"Combinado {total:g}",
            "plazas": "", "distancia_km": "",
            "enlace": ENLACES["Renfe"]})
        filas[-1]["tren"] = f"{tramo_a} {pa['precio']:g} € + {tramo_b} {pb['precio']:g} €"
    return filas


def trenitalia_tramos(origen_id, destino_id, f):
    """Trenes con precio de Trenitalia (Frecciarossa) entre dos ids de lefrecce.it para el día f."""
    import gzip
    cuerpo = {"departureLocationId": origen_id, "arrivalLocationId": destino_id,
              "departureTime": f.strftime("%Y-%m-%dT00:00:00.000"), "adults": 1, "children": 0,
              "criteria": {"frecceOnly": False, "regionalOnly": False, "noChanges": False,
                           "order": "DEPARTURE_DATE", "limit": 40, "offset": 0},
              "advancedSearchRequest": {"bestFare": False}}
    req = urllib.request.Request(TI + "ticket/solutions", data=json.dumps(cuerpo).encode(), headers={
        "Content-Type": "application/json", "Accept": "application/json", "Accept-Encoding": "gzip",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124 Safari/537.36"})
    try:
        with urllib.request.urlopen(req, timeout=40) as r:
            raw = r.read()
    except urllib.error.HTTPError as e:
        if e.code in (403, 429):
            raise vm.Bloqueo(f"Trenitalia HTTP {e.code}")
        raise
    if raw[:2] == b"\x1f\x8b":
        raw = gzip.decompress(raw)
    out = []
    for x in json.loads(raw.decode("utf-8")).get("solutions") or []:
        t = x.get("solution") or {}
        pr = (t.get("price") or {}).get("amount")
        if pr is None or t.get("status") != "SALEABLE":
            continue            # tramos que vende otro operador (TGV Lyria, etc.): sin precio aquí
        try:
            sal = datetime.fromisoformat(t["departureTime"][:16])
            lle = datetime.fromisoformat(t["arrivalTime"][:16])
        except (KeyError, ValueError):
            continue
        if sal.date() != f:
            continue
        cats = [tr.get("trainCategory") or "" for tr in t.get("trains", []) if "Urban" not in (tr.get("trainCategory") or "")]
        out.append({"sal": sal, "lle": lle, "precio": float(pr), "cia": "Trenitalia",
                    "tipo": " + ".join(c for c in cats if c) or "Frecciarossa", "tren": ""})
    return out


def consultar_nivel3(cod, ciudad, f, sentido, consulta):
    """Madrid ↔ Lyon (combinado Renfe, vía Barcelona) + Lyon ↔ París/Milán/Turín (Trenitalia)."""
    def lyon_madrid(dia):
        return _tramos_filas(consultar_nivel2(LYON_COD, "Lyon", dia, sentido, consulta), dia)

    def lyon_dest(dia):
        o, d = (TI_LYON, NIVEL3[cod]) if sentido == "ida" else (NIVEL3[cod], TI_LYON)
        return trenitalia_tramos(o, d, dia)

    if sentido == "ida":
        primero = lyon_madrid(f)
        segundo = lyon_dest
    else:
        primero = lyon_dest(f)
        segundo = lyon_madrid
    combos, noche = [], False
    for k, dia in enumerate((f, f + timedelta(days=1))):
        if k == 1 and combos:
            break
        for x2 in segundo(dia):
            validos = [x1 for x1 in primero if (x2["sal"] - x1["lle"]).total_seconds() >= MIN_TRANSBORDO * 60]
            if validos:
                x1 = min(validos, key=lambda x: (x["precio"], -x["lle"].timestamp()))
                combos.append((x1, x2))
                noche = k == 1
    ori, des = ("Madrid", ciudad) if sentido == "ida" else (ciudad, "Madrid")
    filas = []
    for x1, x2 in sorted(combos, key=lambda c: (c[1]["lle"] - c[0]["sal"], c[0]["precio"] + c[1]["precio"])):
        total = round(x1["precio"] + x2["precio"], 2)
        dur = int((x2["lle"] - x1["sal"]).total_seconds() // 60)
        t1 = "Madrid→Lyon" if sentido == "ida" else f"{ciudad}→Lyon"
        t2 = f"Lyon→{ciudad}" if sentido == "ida" else "Lyon→Madrid"
        filas.append({
            "consulta": consulta, "fecha": f.isoformat(), "sentido": sentido, "codigo": cod, "ciudad": ciudad,
            "origen": ori, "destino": des, "compania": "Combinado",
            "tren": f"{t1} {x1['precio']:g} € + {t2} {x2['precio']:g} €",
            "tipo_tren": f"{'Renfe vía Barcelona' if sentido == 'ida' else x1['tipo']} + "
                         f"{x2['tipo'] if sentido == 'ida' else 'Renfe vía Barcelona'} · Lyon"
                         + (" · noche en el camino" if noche else ""),
            "hora_salida": x1["sal"].strftime("%H:%M"), "hora_llegada": x2["lle"].strftime("%H:%M"),
            "duracion_min": dur, "directo": 0, "disponible": 1, "precio_eur": total,
            "tarifa_min": "Combinado", "precio_max": total, "tarifas": f"Combinado {total:g}",
            "plazas": "", "distancia_km": "", "enlace": ENLACES["Trenitalia"]})
    return filas


def consultar(cod, ciudad, f, sentido):
    """Renfe + Ouigo para un destino, un día y un sentido. Devuelve las filas (una por tren)."""
    consulta = datetime.now().strftime("%Y-%m-%d %H:%M")
    if cod in NIVEL2 or cod in NIVEL3:
        filas = (consultar_nivel2 if cod in NIVEL2 else consultar_nivel3)(cod, ciudad, f, sentido, consulta)
        if not filas:
            filas = [dict.fromkeys(COLUMNAS, "") | {
                "consulta": consulta, "fecha": f.isoformat(), "sentido": sentido, "codigo": cod, "ciudad": ciudad,
                "origen": "Madrid" if sentido == "ida" else ciudad,
                "destino": ciudad if sentido == "ida" else "Madrid", "compania": "Combinado", "disponible": 0}]
        return filas
    est_renfe = (cod, ESTACION.get(cod, ciudad))
    mad = (MADRID[0], MADRID[1])
    o, d = (mad, est_renfe) if sentido == "ida" else (est_renfe, mad)
    crudo = _con_reintentos(lambda: renfe_trenes(o, d, f), "Renfe", cod, f)
    filas = filas_renfe(crudo, f, sentido, cod, ciudad, consulta)
    if not filas:      # marca "sin trenes ese día" para no volver a pedirlo una y otra vez
        filas = [dict.fromkeys(COLUMNAS, "") | {
            "consulta": consulta, "fecha": f.isoformat(), "sentido": sentido, "codigo": cod, "ciudad": ciudad,
            "origen": "Madrid" if sentido == "ida" else ciudad, "destino": ciudad if sentido == "ida" else "Madrid",
            "compania": "Renfe", "disponible": 0}]

    with _lock_estado:
        est = leer_estado()
    sin = set(est.get("ouigo_sin", []))
    bien = set(est.get("ouigo_ok", []))
    if cod not in sin and cod not in EUROPA:
        uic = "71" + cod
        oo, od = ("MT1", uic) if sentido == "ida" else (uic, "MT1")
        try:
            oc = _con_reintentos(lambda: ouigo_trenes(oo, od, f), "Ouigo", cod, f)
        except Exception as e:     # Ouigo caído no debe tirar la consulta de Renfe
            vm.log(f"  ! Ouigo {ciudad} {f}: {e}", err=True)
            oc = None
        if oc is not None:
            with _lock_estado:
                est = leer_estado()
                fallos = est.setdefault("ouigo_vacios", {})
                if oc:
                    est.setdefault("ouigo_ok", [])
                    if cod not in est["ouigo_ok"]:
                        est["ouigo_ok"].append(cod)
                    fallos[cod] = 0
                elif cod not in set(est.get("ouigo_ok", [])):
                    fallos[cod] = fallos.get(cod, 0) + 1
                    if fallos[cod] >= 4:       # 4 días seguidos sin nada y nunca con servicio: no hay Ouigo
                        est.setdefault("ouigo_sin", [])
                        if cod not in est["ouigo_sin"]:
                            est["ouigo_sin"].append(cod)
                            vm.log(f"  ~ {ciudad}: sin Ouigo, no se vuelve a consultar", err=False)
                guardar_estado(est)
            filas += filas_ouigo(oc, f, sentido, cod, ciudad, consulta)
    return filas


# --------------------------------------------------------------------------- CSV
def clave(r):
    return (r.get("fecha") or "", r.get("sentido") or "", r.get("codigo") or "")


def compactar(ruta):
    """Deja solo la consulta más reciente de cada destino/día/sentido/compañía y quita lo ya pasado."""
    if not os.path.exists(ruta):
        return 0
    ultima = {}
    with open(ruta, encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f, delimiter=";"):
            k = clave(r) + (r.get("compania") or "",)
            if r.get("fecha") and (r.get("consulta") or "") > ultima.get(k, ""):
                ultima[k] = r["consulta"]
    hoy = date.today().isoformat()
    tmp = ruta + ".tmp"
    n = 0
    with open(ruta, encoding="utf-8-sig", newline="") as f, \
            open(tmp, "w", encoding="utf-8-sig", newline="") as g:
        w = csv.DictWriter(g, fieldnames=COLUMNAS, delimiter=";", extrasaction="ignore")
        w.writeheader()
        for r in csv.DictReader(f, delimiter=";"):
            k = clave(r) + (r.get("compania") or "",)
            if r.get("fecha", "") >= hoy and r.get("consulta") == ultima.get(k):
                w.writerow(r)
                n += 1
    try:
        os.replace(tmp, ruta)
    except OSError:
        os.remove(tmp)
    return n


def main():
    p = argparse.ArgumentParser(description="Precios de tren (Renfe + Ouigo) desde Madrid")
    p.add_argument("--destinos", nargs="*", help="códigos de estación Renfe (por defecto, todos los de DESTINOS)")
    p.add_argument("--dias", type=int, default=DIAS)
    p.add_argument("--sentidos", nargs="*", default=["ida", "vuelta"], choices=["ida", "vuelta"])
    p.add_argument("--salida", default=CSV_TRENES)
    p.add_argument("--historico", default=CSV_HISTORICO)
    p.add_argument("--hilos", type=int, default=HILOS)
    p.add_argument("--velocidad", type=float, default=1.0)
    p.add_argument("--velocidad-max", type=float, default=3.0)
    p.add_argument("--actualizar", nargs="?", const=0, type=float, metavar="HORAS")
    p.add_argument("--prioritarios", nargs="*", default=[])
    p.add_argument("--peso", type=float, default=0.7)
    p.add_argument("--umbral", type=int, default=0)
    p.add_argument("--meses", nargs="*", help="limita la descarga a estos meses (AAAA-MM)")
    p.add_argument("--pares", nargs="*",
                   help="consultas exactas 'CODIGO:AAAA-MM-DD[:ida|vuelta]'; sin sentido = los dos")
    p.add_argument("--pares-fichero", metavar="RUTA",
                   help="fichero con una consulta 'CODIGO:AAAA-MM-DD[:sentido]' por línea")
    p.add_argument("--desde", metavar="AAAA-MM-DD",
                   help="primer día a consultar (por defecto, mañana); junto con --hasta sustituye a --dias")
    p.add_argument("--hasta", metavar="AAAA-MM-DD", help="último día a consultar (incluido)")
    a = p.parse_args()
    if a.desde or a.hasta:      # rango de fechas: se traduce a nº de días desde el primero
        _ini = date.fromisoformat(a.desde) if a.desde else date.today() + timedelta(days=1)
        if a.hasta:
            a.dias = max((date.fromisoformat(a.hasta) - _ini).days + 1, 0)
    if a.pares_fichero:
        with open(a.pares_fichero, encoding="utf-8") as f:
            a.pares = (a.pares or []) + [l.strip() for l in f if l.strip()]

    vm.ritmo = vm.Ritmo(a.velocidad, a.velocidad_max)
    vm.CSV_ERRORES = os.path.join(os.path.dirname(os.path.abspath(a.salida)), "errores_descarga.csv")
    a.historico = os.path.join(os.path.dirname(os.path.abspath(a.salida)), os.path.basename(a.historico))
    destinos = {k: DESTINOS.get(k, k) for k in (a.destinos or DESTINOS)}
    if json5 is None:
        vm.log("  ~ aviso: falta json5 (pip install json5); uso un conversor sencillo")
    try:
        compactar(a.salida)
    except Exception as e:
        vm.log(f"  ! no he podido limpiar {a.salida}: {e}", err=True)

    hechas = {}
    if os.path.exists(a.salida):
        with open(a.salida, encoding="utf-8-sig", newline="") as f:
            for r in csv.DictReader(f, delimiter=";"):
                if r.get("fecha") and r.get("compania") == "Renfe":
                    hechas[clave(r)] = r.get("consulta", "")

    def pendiente(k):
        if k not in hechas:
            return True
        if a.actualizar is None:
            return False
        try:
            edad = (datetime.now() - datetime.strptime(hechas[k][:16], "%Y-%m-%d %H:%M")).total_seconds() / 3600
        except ValueError:
            edad = 1e9
        return edad > a.actualizar

    mesok = set(a.meses or [])
    tareas = []
    if a.pares:
        for par in a.pares:
            trozos = par.split(":")
            cod, fecha_str = trozos[0], trozos[1]
            sents = [trozos[2]] if len(trozos) > 2 and trozos[2] in ("ida", "vuelta") else ["ida", "vuelta"]
            f = date.fromisoformat(fecha_str)
            for s in sents:
                if a.actualizar is None and clave({"fecha": f.isoformat(), "sentido": s, "codigo": cod}) in hechas:
                    continue
                tareas.append((cod, DESTINOS.get(cod, cod), f, s))
    else:
        inicio = date.fromisoformat(a.desde) if a.desde else date.today() + timedelta(days=1)
        for i in range(a.dias):
            f = inicio + timedelta(days=i)
            if mesok and f.strftime("%Y-%m") not in mesok:
                continue
            for cod, ciudad in destinos.items():
                for s in a.sentidos:
                    if pendiente(clave({"fecha": f.isoformat(), "sentido": s, "codigo": cod})):
                        tareas.append((cod, ciudad, f, s))
    orden = vm.ordenar_por_prioridad([(f, s, "MAD", cod, cod, ciudad) for cod, ciudad, f, s in tareas],
                                     set(a.prioritarios or []), a.peso, a.umbral)
    tareas = [(t[3], t[5], t[0], t[1]) for t in orden]

    total = len(tareas)
    if a.pares:
        print(f"{len(a.pares)} consultas concretas (favoritos/filtro) | pendientes: {total}")
    else:
        print(f"{len(destinos)} destinos x {a.dias} días ({' + '.join(a.sentidos)}) | pendientes: {total}")
    if not total:
        return

    nuevo = not os.path.exists(a.salida)
    fh = open(a.salida, "a", encoding="utf-8-sig" if nuevo else "utf-8", newline="")
    w = csv.DictWriter(fh, fieldnames=COLUMNAS, delimiter=";", extrasaction="ignore")
    if nuevo:
        w.writeheader()
        fh.flush()
    nuevo_h = not os.path.exists(a.historico)
    fhist = open(a.historico, "a", encoding="utf-8-sig" if nuevo_h else "utf-8", newline="")
    whist = csv.DictWriter(fhist, fieldnames=COLUMNAS_HIST, delimiter=";", extrasaction="ignore")
    if nuevo_h:
        whist.writeheader()
        fhist.flush()

    errores = seguidos = 0
    t0 = time.time()

    def trabajo(t):
        cod, ciudad, f, s = t
        vm.log(f"  > {ciudad} {f.isoformat()} ({s})")
        filas = consultar(cod, ciudad, f, s)
        reales = [x for x in filas if x.get("hora_salida")]
        precios = [x["precio_eur"] for x in reales if x.get("precio_eur") != ""]
        if reales:
            vm.log(f"  = {ciudad} {f.isoformat()} {len(reales)} trenes"
                   + (f", desde {min(precios):.0f} EUR" if precios else ", sin plazas"))
        else:
            vm.log(f"  = {ciudad} {f.isoformat()} sin trenes")
        return filas

    try:
        with ThreadPoolExecutor(max_workers=a.hilos) as ex:
            futuros = [ex.submit(trabajo, t) for t in tareas]
            for k, fut in enumerate(as_completed(futuros), 1):
                try:
                    filas = fut.result()
                    seguidos = 0
                    with vm._print_lock:
                        w.writerows(filas)
                        fh.flush()
                        whist.writerows([x for x in filas if x.get("hora_salida") and x.get("precio_eur") != ""])
                        fhist.flush()
                except Exception as e:
                    errores += 1
                    seguidos += 1
                    vm.log(f"  ! {e}", err=True)
                    if seguidos >= 15:
                        vm.log("  !! 15 errores seguidos: detengo la descarga.", err=True)
                        ex.shutdown(wait=False, cancel_futures=True)
                        break
                ritmo_s = (time.time() - t0) / k
                vm.log(f"  {k}/{total}  ({errores} errores)  ~{(total - k) * ritmo_s / 60:.0f} min restantes"
                       f"  [{vm.ritmo.cps:.1f} consultas/s, {a.hilos} hilos]  t={time.time() - t0:.0f}s")
    except KeyboardInterrupt:
        print("\nInterrumpido. Lo descargado está guardado.")
    finally:
        fh.close()
        fhist.close()
    n = compactar(a.salida)
    print(f"Hecho -> {a.salida}  ({n} filas, {errores} errores)")


if __name__ == "__main__":
    main()
:::END
:::BEGIN py/modelo_precios.py|text
"""
Modelos para decidir qué días conviene volver a descargar.

1) modelo_anticipacion(): con el histórico de descargas (varias filas del MISMO vuelo o
   alojamiento a lo largo del tiempo), estima con efectos fijos por vuelo/alojamiento cuánto
   cambia el precio según el tramo de antelación. Al comparar cada vuelo solo contra sí mismo
   se descuenta automáticamente el destino, el mes, el día de la semana y cualquier otra cosa
   que no cambie para ese vuelo concreto — así el efecto de "antelación" no se confunde con
   que una fecha sea cara por otro motivo.

2) volatilidad(): con el mismo histórico, separa la TENDENCIA (si el precio sube o baja de
   media, con signo) de la VOLATILIDAD (cuánto se mueve, sin signo) según los días que falten,
   y de ahí sale cada cuánto conviene refrescar cada tramo. La volatilidad se escala con la
   raíz del tiempo transcurrido entre descargas (como en un paseo aleatorio), no linealmente:
   así no se sobreestima cuánto se habrá movido el precio dentro de varios días.

3) probabilidad_subida(): con el histórico, la probabilidad de que el precio del mismo vuelo
   (o del mismo alojamiento) haya SUBIDO frente a la consulta anterior, según los días que
   falten. Es genérica: sirve para vuelos y para hoteles, solo cambian las columnas que se le
   pasan. Descarta cambios menores que UMBRAL_RUIDO (ruido de redondeo, no una subida/bajada
   real) y controla por destino/alojamiento para no confundir "sube porque es esta ruta" con
   "sube porque falta poco".

En los tres casos, "días de antelación" es SIEMPRE la diferencia entre la fecha del vuelo/
entrada y la fecha en la que se hizo esa consulta en particular (columna col_consulta) — NO
los días que faltan hoy. Cada fila del histórico lleva su propia antelación, tal y como era en
el momento en que se descargó; por eso no hace falta (ni se usa) un parámetro "hoy".

Los tres modelos agrupan (clusterizan) los errores estándar por vuelo/alojamiento: varias
filas seguidas del mismo vuelo NO son observaciones independientes entre sí (si un vuelo está
en racha alcista, cada consulta suya "vota" en la misma dirección), y tratarlas como
independientes haría parecer los resultados más seguros de lo que son.

Sin dependencias más allá de numpy y pandas (las regresiones están implementadas aquí).
"""

import math

import numpy as np
import pandas as pd

# Tramos de días hasta la salida (límite inferior incluido, superior excluido)
TRAMOS = [(0, 3), (3, 7), (7, 14), (14, 21), (21, 30), (30, 45), (45, 60),
          (60, 90), (90, 120), (120, 180), (180, 10_000)]
EFECTO_MIN = 0.05   # 5 %: por debajo de esto el efecto se considera irrelevante
ALFA = 0.05         # nivel de significancia
UMBRAL_RUIDO = 0.01  # 1 %: por debajo, un cambio de precio se trata como ruido de redondeo,
                     # no como una subida o bajada real


# Con efectos de fecha de consulta, la antelación solo se identifica si el tramo más lejano es
# plano (sin él, "días hasta la salida" = fecha de salida − fecha de consulta es colineal con
# vuelo + día de consulta): se funden 120-179 y 180+ como referencia.
TRAMOS_CTRL = TRAMOS[:-2] + [(120, 10_000)]
FRANJAS_HORA = ([-1, 8, 11, 14, 24], ["<9h", "9-11h", "12-14h", "15h+"])


def etiqueta_tramo(a, b):
    return f"{a}-{b - 1} días" if b < 10_000 else f"{a}+ días"


def tramo_de(dias, tramos=TRAMOS):
    for a, b in tramos:
        if a <= dias < b:
            return etiqueta_tramo(a, b)
    return etiqueta_tramo(*tramos[-1])


def _franja(ts):
    """Franja horaria de una serie de fechas con hora."""
    return pd.cut(ts.dt.hour, FRANJAS_HORA[0], labels=FRANJAS_HORA[1]).astype(str)


def _avanza(progreso, frac, texto):
    if progreso:
        progreso(frac, texto)


def _p_valor(t):
    """p-valor bilateral con la normal (n grande); evita depender de scipy."""
    return math.erfc(abs(t) / math.sqrt(2))


def _clave_grupo(df, claves):
    """Identificador de texto único por vuelo/alojamiento, para agrupar/clusterizar."""
    if df.empty:
        return pd.Series(dtype=object, index=df.index)
    return pd.Series(df.groupby(list(claves), sort=False).ngroup().to_numpy(), index=df.index)


def _meat_cluster(scores, cluster):
    """Suma por grupo de las contribuciones por fila (n×k) y su producto externo: la "carne"
    del estimador agrupado. Ordena y suma con reduceat en vez de un bucle por grupo."""
    _, inv = np.unique(np.asarray(cluster), return_inverse=True)
    orden = np.argsort(inv, kind="stable")
    inv = inv[orden]
    inicios = np.flatnonzero(np.r_[True, inv[1:] != inv[:-1]])
    s = np.add.reduceat(scores[orden], inicios, axis=0)
    return s.T @ s, len(inicios)


def ols(y, X, nombres, cluster=None):
    """Mínimos cuadrados. Sin cluster: errores robustos a heterocedasticidad (HC1). Con
    cluster (un valor de agrupación por fila): errores robustos agrupados, para cuando hay
    varias filas del mismo vuelo/alojamiento y no son observaciones independientes entre sí."""
    beta, *_ = np.linalg.lstsq(X, y, rcond=None)
    resid = y - X @ beta
    n, k = X.shape
    XtX_inv = np.linalg.pinv(X.T @ X)
    if cluster is not None:
        meat, G = _meat_cluster(X * resid[:, None], cluster)
        cov = XtX_inv @ meat @ XtX_inv * (G / max(G - 1, 1))
    else:
        meat = (X * (resid ** 2)[:, None]).T @ X
        cov = XtX_inv @ meat @ XtX_inv * (n / max(n - k, 1))       # HC1
    se = np.sqrt(np.clip(np.diag(cov), 0, None))
    with np.errstate(divide="ignore", invalid="ignore"):
        t = np.where(se > 0, beta / se, 0.0)
    sct = ((y - y.mean()) ** 2).sum()
    r2 = 1 - (resid ** 2).sum() / sct if sct > 0 else np.nan
    return pd.DataFrame({"variable": nombres, "coef": beta, "se": se, "t": t,
                         "p": [_p_valor(x) for x in t]}), r2, n


def _logit_fit(y, X, nombres, cluster=None, iters=50, tol=1e-8, progreso=None):
    """Regresión logística por Newton-Raphson (IRLS). y en {0,1}. Sin scipy/sklearn.
    Los errores son siempre "sandwich" (robustos); con cluster, además agrupados."""
    n, k = X.shape
    beta = np.zeros(k)
    for it in range(iters):
        _avanza(progreso, 0.4 + 0.5 * min(it + 1, 8) / 8, f"Ajustando el modelo (iteración {it + 1})…")
        z = np.clip(X @ beta, -30, 30)
        p = 1 / (1 + np.exp(-z))
        w = np.clip(p * (1 - p), 1e-6, None)
        XtWX = (X * w[:, None]).T @ X
        grad = X.T @ (y - p)
        try:
            delta = np.linalg.solve(XtWX, grad)
        except np.linalg.LinAlgError:
            delta = np.linalg.lstsq(XtWX, grad, rcond=None)[0]
        beta = beta + delta
        if np.max(np.abs(delta)) < tol:
            break
    z = np.clip(X @ beta, -30, 30)
    p = 1 / (1 + np.exp(-z))
    w = np.clip(p * (1 - p), 1e-6, None)
    XtWX = (X * w[:, None]).T @ X
    bread = np.linalg.pinv(XtWX)
    score = X * (y - p)[:, None]     # contribución de cada fila al gradiente
    if cluster is not None:
        meat, G = _meat_cluster(score, cluster)
        cov = bread @ meat @ bread * (G / max(G - 1, 1))
    else:
        meat = score.T @ score
        cov = bread @ meat @ bread
    se = np.sqrt(np.clip(np.diag(cov), 0, None))
    with np.errstate(divide="ignore", invalid="ignore"):
        z_stat = np.where(se > 0, beta / se, 0.0)
    return pd.DataFrame({"variable": nombres, "coef": beta, "se": se,
                         "p": [_p_valor(x) for x in z_stat]})


def _dummies(serie, prefijo, base=None):
    """Variables ficticias dejando fuera una categoría de referencia."""
    cats = sorted(serie.dropna().unique())
    base = base if base in cats else (cats[0] if cats else None)
    cols = {f"{prefijo}={c}": (serie == c).astype(float) for c in cats if c != base}
    return pd.DataFrame(cols, index=serie.index), base


def modelo_anticipacion(hist, claves=("codigo", "sentido", "fecha_vuelo"),
                        col_fecha_objetivo="fecha_vuelo", col_precio="precio_eur",
                        col_consulta="consulta", controles=False, progreso=None):
    """hist: histórico de descargas (varias filas del MISMO vuelo o alojamiento a lo largo del
    tiempo). Devuelve (tabla, info). Con efectos fijos por vuelo/alojamiento: cada uno se
    compara solo contra sí mismo en distintos momentos, así se descuenta destino, mes, día de
    la semana... todo lo que no cambia para ese vuelo. claves identifica "el mismo"
    vuelo/alojamiento a lo largo del tiempo (debe incluir "codigo"). La antelación de cada
    fila es la fecha objetivo menos la fecha en que se hizo ESA consulta, no "hoy".

    controles=True añade, además del efecto fijo por vuelo: un efecto fijo por día de consulta
    (descuenta lo que se mueve el mercado entero ese día) y la franja horaria de la consulta.
    Para que la antelación siga siendo identificable el tramo de referencia pasa a ser 120+
    (TRAMOS_CTRL). progreso(fracción, texto) es opcional (barra de progreso de la interfaz)."""
    tramos = TRAMOS_CTRL if controles else TRAMOS
    _avanza(progreso, 0.02, "Preparando los datos…")
    h = hist.dropna(subset=[col_precio]).copy()
    h = h[h[col_precio] > 0]
    h[col_fecha_objetivo] = pd.to_datetime(h[col_fecha_objetivo], errors="coerce")
    h[col_consulta] = pd.to_datetime(h[col_consulta], errors="coerce")
    h = h.dropna(subset=[col_fecha_objetivo, col_consulta] + list(claves))
    h["dias"] = (h[col_fecha_objetivo] - h[col_consulta]).dt.days
    h = h[h["dias"] >= 0]
    h["tramo"] = h["dias"].map(lambda d: tramo_de(d, tramos))
    _avanza(progreso, 0.15, "Identificando vuelos/alojamientos…")
    h["grupo"] = _clave_grupo(h, claves)
    n_tramos = h.groupby("grupo")["tramo"].transform("nunique") if not h.empty else pd.Series(dtype=int)
    h = h[n_tramos >= 2]          # solo los vistos en más de un tramo: son los que informan
    grupos_totales = int(h["grupo"].nunique())
    if h.empty or grupos_totales < 10:
        return pd.DataFrame(), {"n": len(h), "grupos": grupos_totales,
                                "error": "Hacen falta más vuelos/alojamientos vistos en al menos dos "
                                         "tramos de antelación distintos (se van acumulando con cada "
                                         "descarga; con una sola foto de hoy no basta)."}
    presentes = [etiqueta_tramo(a, b) for a, b in tramos if (h["tramo"] == etiqueta_tramo(a, b)).sum() >= 10]
    if len(presentes) < 2:
        return pd.DataFrame(), {"n": len(h), "grupos": grupos_totales,
                                "error": "Hacen falta precios de al menos dos tramos de antelación."}
    h = h[h["tramo"].isin(presentes)]
    base = presentes[-1]        # el tramo más lejano es la referencia
    dum, _ = _dummies(h["tramo"], "tramo", base)
    if controles:
        dum = pd.concat([dum, _dummies(h[col_consulta].dt.strftime("%Y-%m-%d"), "dia")[0],
                         _dummies(_franja(h[col_consulta]), "hora")[0]], axis=1)
    nombres = list(dum.columns)
    _avanza(progreso, 0.3, "Centrando por vuelo/alojamiento…")
    aux = dum.copy()
    aux["grupo"] = h["grupo"].to_numpy()
    aux["y"] = np.log(h[col_precio].to_numpy(float))
    medias = aux.groupby("grupo")[nombres + ["y"]].transform("mean")
    Xw = (aux[nombres] - medias[nombres]).to_numpy(float)     # efectos fijos "por dentro"
    yw = (aux["y"] - medias["y"]).to_numpy(float)
    del aux, medias
    _avanza(progreso, 0.6, "Estimando y calculando errores agrupados…")
    res, r2, n = ols(yw, Xw, nombres, cluster=h["grupo"].to_numpy())
    _avanza(progreso, 0.98, "Terminando…")

    filas = []
    for a, b in tramos:
        et = etiqueta_tramo(a, b)
        if et not in presentes:
            continue
        if et == base:
            filas.append({"tramo": et, "desde": a, "hasta": b, "n": int((h["tramo"] == et).sum()),
                          "efecto": 0.0, "se": 0.0, "p": np.nan, "referencia": True})
            continue
        r = res[res["variable"] == f"tramo={et}"].iloc[0]
        filas.append({"tramo": et, "desde": a, "hasta": b, "n": int((h["tramo"] == et).sum()),
                      "efecto": math.exp(r["coef"]) - 1, "se": r["se"], "p": r["p"], "referencia": False})
    tabla = pd.DataFrame(filas)

    # Umbral: desde el tramo más lejano hacia el más cercano, el primero que sea
    # significativo (p < 0,05, con errores agrupados por vuelo/alojamiento) Y con efecto de
    # al menos el 5 % marca el límite.
    umbral = 0
    for fila in tabla.sort_values("desde", ascending=False).itertuples():
        if not fila.referencia and fila.p < ALFA and abs(fila.efecto) >= EFECTO_MIN:
            umbral = int(fila.hasta if fila.hasta < 10_000 else fila.desde)
            break
    info = {"n": n, "r2": r2, "base": base, "umbral": umbral, "grupos": grupos_totales,
            "destinos": int(h["codigo"].nunique()) if "codigo" in h else 0, "controles": controles}
    return tabla, info


def volatilidad(hist, claves=("codigo", "sentido", "fecha_vuelo"),
               col_fecha_objetivo="fecha_vuelo", col_precio="precio_eur", col_consulta="consulta"):
    """hist: histórico de descargas (varias filas del MISMO vuelo o alojamiento a lo largo del
    tiempo). Compara cada precio con la observación anterior de lo mismo y separa:
    - tendencia_dia: cambio medio CON SIGNO por día (¿tiende a subir o a bajar en ese tramo?).
    - volatilidad_dia: magnitud del cambio típico, escalada con la RAÍZ del tiempo transcurrido
      entre descargas (como en un paseo aleatorio) en vez de linealmente, para no sobrestimar
      cada cuánto conviene refrescar. La antelación de cada comparación es la fecha objetivo
      menos la fecha de la consulta más reciente de las dos, no "hoy"."""
    h = hist.dropna(subset=[col_precio]).copy()
    h = h[h[col_precio] > 0]
    if h.empty:
        return pd.DataFrame(), {"pares": 0, "error": "Todavía no hay histórico."}
    h[col_consulta] = pd.to_datetime(h[col_consulta], errors="coerce")
    h[col_fecha_objetivo] = pd.to_datetime(h[col_fecha_objetivo], errors="coerce")
    h = h.dropna(subset=[col_consulta, col_fecha_objetivo] + list(claves)).sort_values(col_consulta)
    g = h.groupby(list(claves))
    h["precio_ant"] = g[col_precio].shift()
    h["consulta_ant"] = g[col_consulta].shift()
    p = h.dropna(subset=["precio_ant"]).copy()
    p = p[p["precio_ant"] > 0]
    p["horas"] = (p[col_consulta] - p["consulta_ant"]).dt.total_seconds() / 3600
    p = p[p["horas"] >= 1]
    if p.empty:
        return pd.DataFrame(), {"pares": 0,
                                "error": "Hace falta más de una descarga del mismo día, separadas al menos una hora."}
    p["dias_transc"] = (p["horas"] / 24).clip(lower=0.25)
    p["cambio_rel"] = (p[col_precio] - p["precio_ant"]) / p["precio_ant"]      # con signo
    p["cambio_abs"] = p["cambio_rel"].abs()
    p["tendencia_dia"] = p["cambio_rel"] / p["dias_transc"]
    p["volatilidad_dia"] = p["cambio_abs"] / np.sqrt(p["dias_transc"])
    p["dias"] = (p[col_fecha_objetivo] - p[col_consulta]).dt.days.clip(lower=0)
    p["tramo"] = p["dias"].map(tramo_de)
    t = (p.groupby("tramo").agg(pares=("cambio_abs", "size"),
                                tendencia_dia=("tendencia_dia", "mean"),
                                volatilidad_dia=("volatilidad_dia", "mean"),
                                pct_movidos=("cambio_abs", lambda s: (s >= EFECTO_MIN).mean()))
         .reset_index())
    orden = {etiqueta_tramo(a, b): a for a, b in TRAMOS}
    t["desde"] = t["tramo"].map(orden)
    t["hasta"] = t["desde"].map({a: b for a, b in TRAMOS})
    t = t.sort_values("desde")
    # Días hasta acumular, de media, un movimiento del 5 % (escalado con la raíz del tiempo)
    t["dias_refresco"] = np.where(t["volatilidad_dia"] > 0,
                                  np.ceil((EFECTO_MIN / t["volatilidad_dia"]) ** 2), np.inf)
    t["dias_refresco"] = t["dias_refresco"].clip(upper=90)
    fiables = t[t["pares"] >= 30]
    umbral = 0
    for fila in fiables.sort_values("desde", ascending=False).itertuples():
        if fila.volatilidad_dia * math.sqrt(7) >= EFECTO_MIN:      # se mueve un 5 % o más en una semana
            umbral = int(fila.hasta if fila.hasta < 10_000 else fila.desde)
            break
    return t, {"pares": int(p.shape[0]), "umbral": umbral,
               "desde_cuando": p["consulta_ant"].min(), "fiable": len(fiables) > 0}


def probabilidad_subida(hist, claves, col_fecha_objetivo, col_precio, col_consulta="consulta",
                        col_control="codigo", umbral_ruido=UMBRAL_RUIDO, controles=False, progreso=None):
    """Con un histórico de descargas (varias filas del MISMO vuelo o alojamiento a lo largo
    del tiempo), estima la probabilidad de que el precio haya SUBIDO frente a la consulta
    anterior, según los días que faltaban EN EL MOMENTO de esa consulta (no "hoy"). Es
    genérica: sirve tanto para vuelos como para hoteles.

    hist: DataFrame con al menos las columnas de `claves`, col_fecha_objetivo, col_precio,
          col_consulta y (si se quiere controlar por destino) col_control.
    claves: columnas que identifican "el mismo" vuelo/alojamiento a lo largo del tiempo.
    col_control: columna a añadir como control categórico en el modelo (por defecto "codigo",
                 el destino/ciudad), para no confundir "esta ruta siempre sube" con "sube
                 porque falta poco". None para desactivarlo.
    umbral_ruido: cambios de precio por debajo de este % se descartan como ruido de redondeo,
                  no como una subida o bajada real.

    Devuelve (tabla_por_tramo, curva_del_modelo, info). tabla_por_tramo incluye, por tramo,
    pct_subio (probabilidad de subida ENTRE DOS CONSULTAS SEPARADAS dias_gap_medio DÍAS de
    media), subida_media (cambio relativo medio, SOLO entre los casos que subieron: sirve para
    estimar cuánto sube cuando sube) y dias_gap_medio (separación media, en días, entre las dos
    consultas comparadas en ese tramo). pct_subio no es "la probabilidad de que suba" en
    abstracto: es la probabilidad observada para ese hueco de tiempo medio. Para una espera de
    N días concretos, hay que convertir pct_subio a una tasa diaria y escalarla por N (así, más
    días desde la última vez que se miró = más probabilidad de que haya subido; y como cada
    tramo es un tramo de antelación distinto, un vuelo/alojamiento lejano usa el tramo con su
    propio pct_subio/dias_gap_medio, normalmente con menos movimiento que uno cercano). Los
    errores del modelo van agrupados por vuelo/alojamiento (varias consultas seguidas de lo
    mismo no son independientes).

    controles=True añade al logit: el hueco entre consultas (log de dias_gap), el precio previo
    relativo a la media (log) de ese mismo vuelo/alojamiento (reversión a la media), día de la
    semana y franja horaria de la consulta, día de la semana y mes de la fecha objetivo y, si
    existe la columna, el sentido. Entonces pct_subio de la tabla es la probabilidad AJUSTADA del
    modelo (con `dias` fijado en la media de cada tramo y el resto de variables como se
    observaron; pct_subio_bruto conserva la descriptiva) y dias_gap_medio pasa a ser el hueco
    medio global, que es con el que está calculada esa probabilidad ajustada.
    """
    _avanza(progreso, 0.02, "Preparando los datos…")
    h = hist.dropna(subset=[col_precio]).copy()
    h = h[h[col_precio] > 0]
    if h.empty:
        return pd.DataFrame(), pd.DataFrame(), {"pares": 0, "error": "Todavía no hay histórico."}
    h[col_consulta] = pd.to_datetime(h[col_consulta], errors="coerce")
    h[col_fecha_objetivo] = pd.to_datetime(h[col_fecha_objetivo], errors="coerce")
    h = h.dropna(subset=[col_consulta, col_fecha_objetivo] + list(claves)).sort_values(col_consulta)
    if controles:
        lp = np.log(h[col_precio])
        h["rel"] = lp - lp.groupby([h[c] for c in claves]).transform("mean")
    g = h.groupby(list(claves))
    h["precio_ant"] = g[col_precio].shift()
    h["consulta_ant"] = g[col_consulta].shift()
    if controles:
        h["rel_ant"] = g["rel"].shift()
    _avanza(progreso, 0.2, "Comparando con la consulta anterior…")
    p = h.dropna(subset=["precio_ant"]).copy()
    p = p[p["precio_ant"] > 0]
    p["horas_gap"] = (p[col_consulta] - p["consulta_ant"]).dt.total_seconds() / 3600
    p = p[p["horas_gap"] >= 1]
    if p.empty:
        return pd.DataFrame(), pd.DataFrame(), {
            "pares": 0, "error": "Hace falta más de una descarga de lo mismo, separadas al menos una hora."}
    p["cambio_rel"] = (p[col_precio] - p["precio_ant"]) / p["precio_ant"]
    p = p[p["cambio_rel"].abs() >= umbral_ruido]      # descarta ruido de redondeo
    if p.empty:
        return pd.DataFrame(), pd.DataFrame(), {
            "pares": 0, "error": f"Todos los cambios observados son menores del {umbral_ruido:.0%}: "
                                  "no se puede distinguir una subida real del ruido de redondeo."}
    p["subio"] = (p["cambio_rel"] > 0).astype(float)
    p["dias"] = (p[col_fecha_objetivo] - p[col_consulta]).dt.days.clip(lower=0)
    p["tramo"] = p["dias"].map(tramo_de)
    p["dias_gap"] = (p["horas_gap"] / 24).clip(lower=1 / 24)

    t = p.groupby("tramo").agg(
        pares=("subio", "size"), pct_subio=("subio", "mean"),
        subida_media=("cambio_rel", lambda s: s[s > 0].mean() if (s > 0).any() else np.nan),
        dias_gap_medio=("dias_gap", "mean"),
    ).reset_index()
    orden = {etiqueta_tramo(a, b): a for a, b in TRAMOS}
    t["desde"] = t["tramo"].map(orden)
    t["hasta"] = t["desde"].map({a: b for a, b in TRAMOS})
    t = t.sort_values("desde")

    cluster = _clave_grupo(p, claves)
    _avanza(progreso, 0.35, "Preparando el modelo…")
    curva = pd.DataFrame()
    modelo_ok = False
    b0 = b1 = np.nan
    p_dias = np.nan
    if len(p) >= 60 and p["dias"].nunique() >= 3:
        partes = [pd.DataFrame({"const": 1.0, "dias": p["dias"].astype(float)}, index=p.index)]
        if col_control and col_control in p.columns and p[col_control].nunique() > 1:
            dd, _ = _dummies(p[col_control], "grp")
            partes.append(dd)
        if controles:
            c, f = p[col_consulta], p[col_fecha_objetivo]
            partes.append(pd.DataFrame({"log_gap": np.log(p["dias_gap"]), "rel_ant": p["rel_ant"]}, index=p.index))
            for nombre, v in [("dsem_consulta", c.dt.dayofweek), ("hora", _franja(c)),
                              ("dsem_fecha", f.dt.dayofweek), ("mes_fecha", f.dt.month)] + (
                    [("sentido", p["sentido"])] if "sentido" in p.columns else []):
                partes.append(_dummies(v.astype(str), nombre)[0])
        X = pd.concat(partes, axis=1)
        try:
            res = _logit_fit(p["subio"].to_numpy(float), X.to_numpy(float), list(X.columns),
                             cluster=cluster.to_numpy(), progreso=progreso)
            b0 = res.loc[res["variable"] == "const", "coef"].iloc[0]
            b1 = res.loc[res["variable"] == "dias", "coef"].iloc[0]
            p_dias = res.loc[res["variable"] == "dias", "p"].iloc[0]
            dias_curva = np.arange(0, int(p["dias"].quantile(0.98)) + 1)
            base_z = b0
            if controles:      # el resto de variables, en su media (no en el "vuelo de referencia")
                coef = res.set_index("variable")["coef"]
                resto = [v for v in X.columns if v not in ("const", "dias")]
                base_z = b0 + float((X[resto].mean() * coef[resto]).sum())
                z0 = X[resto].to_numpy(float) @ coef[resto].to_numpy() + b0
                dmed = p.groupby("tramo")["dias"].mean()
                t["pct_subio_bruto"] = t["pct_subio"]
                t["pct_subio"] = [float((1 / (1 + np.exp(-np.clip(z0 + b1 * dmed[tr], -30, 30)))).mean())
                                  for tr in t["tramo"]]
                t["dias_gap_medio"] = p["dias_gap"].mean()
            z = np.clip(base_z + b1 * dias_curva, -30, 30)
            curva = pd.DataFrame({"dias": dias_curva, "probabilidad": 1 / (1 + np.exp(-z))})
            modelo_ok = True
        except Exception:
            b0 = b1 = p_dias = np.nan
            modelo_ok = False

    return t, curva, {"pares": int(len(p)), "modelo_ok": modelo_ok, "p_dias": p_dias,
                      "b0": b0, "b1": b1, "grupos": int(cluster.nunique()),
                      "umbral_ruido": umbral_ruido, "desde_cuando": p["consulta_ant"].min(),
                      "controles": controles}


def tasa_diaria(pct_subio, dias_gap_medio):
    """Convierte pct_subio (probabilidad de subida observada entre dos consultas separadas, de
    media, dias_gap_medio días) en una tasa diaria: la probabilidad de que suba en UN día
    concreto. Es lo que hay que escalar por los días reales de espera para un vuelo/alojamiento
    dado (a más días sin refrescar ese precio, más probabilidad acumulada de que haya subido)."""
    dias_gap_medio = max(float(dias_gap_medio), 1 / 24)
    pct_subio = min(max(float(pct_subio), 0.0), 0.999999)
    return 1 - (1 - pct_subio) ** (1 / dias_gap_medio)


def prob_en_espera(tasa_diaria_, dias_espera, tope=0.97):
    """Probabilidad de que el precio haya subido al menos una vez en dias_espera días, dada una
    tasa diaria de subida (ver tasa_diaria). tope evita dar probabilidades irreales cuando hace
    mucho que no se refresca un precio."""
    dias_espera = max(float(dias_espera), 0.0)
    return min(1 - (1 - tasa_diaria_) ** dias_espera, tope)


def precio_favorito(hist, codigo, ida, vuelta, guardado):
    """Precio base por persona (IDA+VUELTA) de un vuelo favorito a lo largo del histórico:
    {ahora, minimo, al_guardar, cambio_pct}. Cada consulta usa el último precio visto de cada
    sentido (ffill); al_guardar es el último valor con consulta <= guardado."""
    nan = float("nan")
    vacio = dict(ahora=nan, minimo=nan, al_guardar=nan, cambio_pct=nan)
    if hist is None or hist.empty:
        return vacio
    h = hist[hist["codigo"] == codigo]
    f = pd.to_datetime(h["fecha_vuelo"], errors="coerce")
    h = h[((h["sentido"] == "IDA") & (f == pd.Timestamp(ida)))
          | ((h["sentido"] == "VUELTA") & (f == pd.Timestamp(vuelta)))]
    c = pd.to_datetime(h["consulta"], errors="coerce")
    p = h.assign(consulta=c).dropna(subset=["consulta"]).groupby(["consulta", "sentido"])["precio_eur"].last().unstack()
    if not {"IDA", "VUELTA"} <= set(p.columns):
        return vacio
    return _resumen(p.sort_index().ffill()[["IDA", "VUELTA"]].sum(axis=1, min_count=2).dropna(), guardado)


def _resumen(tot, guardado):
    """{ahora, minimo, al_guardar, cambio_pct} de una serie de totales indexada por consulta."""
    nan = float("nan")
    if tot.empty:
        return dict(ahora=nan, minimo=nan, al_guardar=nan, cambio_pct=nan)
    previos = tot[tot.index <= pd.Timestamp(guardado)]
    ahora, antes = float(tot.iloc[-1]), (float(previos.iloc[-1]) if len(previos) else nan)
    return dict(ahora=ahora, minimo=float(tot.min()), al_guardar=antes, cambio_pct=ahora / antes - 1)


def precio_estancia(hist_hot, codigo, nombre, ida, vuelta, guardado):
    """Como precio_favorito pero para un alojamiento: suma de las noches entre ida y vuelta-1
    (último precio visto de cada noche en cada consulta). NaN si falta alguna noche."""
    noches = pd.date_range(ida, pd.Timestamp(vuelta) - pd.Timedelta(days=1))
    if hist_hot is None or hist_hot.empty or len(noches) == 0:
        return _resumen(pd.Series(dtype=float), guardado)
    h = hist_hot[(hist_hot["codigo"] == codigo) & (hist_hot["nombre"] == nombre)].dropna(subset=["precio_noche"])
    h = h.assign(consulta=pd.to_datetime(h["consulta"], errors="coerce"),
                 fecha_entrada=pd.to_datetime(h["fecha_entrada"], errors="coerce")).dropna(subset=["consulta", "fecha_entrada"])
    p = h.groupby(["consulta", "fecha_entrada"])["precio_noche"].last().unstack()
    tot = p.sort_index().reindex(columns=noches).ffill().sum(axis=1, min_count=len(noches)).dropna()
    return _resumen(tot, guardado)


def mejor_momento(hist, min_vuelos=30, min_consultas=3, min_rango=7):
    """Por destino y sentido: a cuántos días de la salida suele estar el mínimo de un vuelo y qué
    tramo de antelación sale más barato (frente a la media del propio vuelo). Solo cuentan los
    vuelos vistos >= min_consultas veces en una ventana de >= min_rango días. Devuelve (tabla, info)."""
    claves = ("codigo", "sentido", "fecha_vuelo")
    vacia = pd.DataFrame()
    h = hist.dropna(subset=["precio_eur"]).copy() if not hist.empty else hist
    if h.empty:
        return vacia, {"error": "Todavía no hay histórico."}
    h = h[h["precio_eur"] > 0]
    h["fecha_vuelo"] = pd.to_datetime(h["fecha_vuelo"], errors="coerce")
    h["consulta"] = pd.to_datetime(h["consulta"], errors="coerce")
    h = h.dropna(subset=["fecha_vuelo", "consulta", "codigo", "sentido"])
    h["dias"] = (h["fecha_vuelo"] - h["consulta"]).dt.days
    h = h[h["dias"] >= 0]
    h["grupo"] = _clave_grupo(h, claves)
    g = h.groupby("grupo")["dias"]
    h = h[(g.transform("size") >= min_consultas) & (g.transform("max") - g.transform("min") >= min_rango)]
    if h.empty:
        return vacia, {"error": "Faltan vuelos vistos varias veces a lo largo de varios días."}
    h["lp"] = np.log(h["precio_eur"])
    h["media"] = h.groupby("grupo")["lp"].transform("mean")
    h["rel"] = h["lp"] - h["media"]
    h["tramo"] = h["dias"].map(tramo_de)
    imin = h.groupby("grupo")["precio_eur"].idxmin()
    v = h.groupby("grupo").agg(codigo=("codigo", "first"), sentido=("sentido", "first"),
                               tipico=("media", lambda x: math.exp(x.iloc[0])), minimo=("precio_eur", "min"))
    v["dia_min"] = h.loc[imin.values, "dias"].to_numpy()
    v["bajo_media"] = 1 - v["minimo"] / v["tipico"]
    t = v.groupby(["codigo", "sentido"]).agg(
        vuelos=("tipico", "size"), precio_tipico=("tipico", "median"), minimo_habitual=("minimo", "median"),
        bajo_media=("bajo_media", "median"), dias_min=("dia_min", "median"),
        dias_min_p25=("dia_min", lambda x: x.quantile(.25)), dias_min_p75=("dia_min", lambda x: x.quantile(.75)))
    tr = h.groupby(["codigo", "sentido", "tramo"]).agg(rel=("rel", "mean"), n=("grupo", "nunique"))
    tr = tr[tr["n"] >= min_vuelos // 3].reset_index()
    mejor = tr.loc[tr.groupby(["codigo", "sentido"])["rel"].idxmin()].set_index(["codigo", "sentido"])
    t["tramo_barato"] = mejor["tramo"]
    t["ventaja_tramo"] = np.exp(mejor["rel"]) - 1
    t["fiable"] = t["vuelos"] >= min_vuelos
    info = {"dias_historico": int((h["consulta"].max() - h["consulta"].min()).days),
            "vuelos": int(len(v)), "rango_mediano": float((h.groupby("grupo")["dias"].agg(lambda x: x.max() - x.min())).median())}
    return t.reset_index(), info
:::END
:::BEGIN py/vuelos_app.pyw|text
"""
Viajes — presupuestos de viaje desde Madrid: lanzador de escritorio con icono en la bandeja del sistema.

- Abre la app en una ventana propia (sin navegador ni consola).
- Cerrar la ventana solo la OCULTA: la app y las descargas siguen en segundo plano.
- Para salir del todo: icono del avión junto al reloj → clic derecho → Salir.
- Si ya está abierta, volver a lanzarla solo muestra la ventana.

Requiere: pip install streamlit pystray pillow pywebview
"""
import os
import socket
import subprocess
import sys
import threading
import time
import urllib.request

import json
from datetime import datetime, timedelta

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mantenimiento

CARPETA = os.path.dirname(os.path.abspath(__file__))   # .../Vuelos/py
BASE = os.path.dirname(CARPETA)                          # .../Vuelos
ASSETS_DIR = os.path.join(BASE, "assets")
os.chdir(BASE)
PUERTO = 8501             # servidor de la app
PUERTO_CONTROL = 8511     # para detectar que ya hay una instancia abierta
URL = f"http://localhost:{PUERTO}"
TITULO = "Viajes"
ICONO = os.path.join(ASSETS_DIR, "vuelos.ico")
# Mismo fichero que usa la descarga manual (PIDS["vuelos"] en app_vuelos.py): asi
# ambas vias se ven la una a la otra y no arrancan una descarga de vuelos por
# duplicado.
PID_DESCARGA = os.path.join(BASE, "descarga_vuelos.pid")
CONFIG = os.path.join(BASE, "config_vuelos.json")
SCRIPT_DESCARGA = os.path.join(CARPETA, "vuelos_madrid.py")
DIAS_SEMANA = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]
LOG_DESCARGA = os.path.join(BASE, "descarga_vuelos.log")
SIN_VENTANA = subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0

CARGANDO = """<html><body style="margin:0;height:100vh;display:flex;flex-direction:column;
align-items:center;justify-content:center;font-family:Segoe UI,sans-serif;background:#111;color:#eee">
<svg width="84" height="84" viewBox="0 0 100 100"><rect x="36" y="6" width="28" height="7" rx="3.5" fill="#fff"/><rect x="40" y="10" width="5" height="26" rx="2.5" fill="#fff"/><rect x="55" y="10" width="5" height="26" rx="2.5" fill="#fff"/><rect x="19" y="32" width="62" height="52" rx="10" fill="#fff"/><rect x="38" y="38" width="3.5" height="40" rx="1.7" fill="#111"/><rect x="58.5" y="38" width="3.5" height="40" rx="1.7" fill="#111"/><rect x="29" y="83" width="9" height="7" rx="3" fill="#fff"/><rect x="62" y="83" width="9" height="7" rx="3" fill="#fff"/></svg><h2 style="margin:8px 0">Viajes</h2>
<p id="m" style="color:#aaa">Arrancando la app…</p>
<div style="width:48px;height:48px;border:5px solid #444;border-top-color:#fff;border-radius:50%;
animation:g 1s linear infinite"></div>
<style>@keyframes g{to{transform:rotate(360deg)}}</style></body></html>"""

servidor = None
ventana = None
icono_bandeja = None
saliendo = False
mostrar_evento = threading.Event()


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


def pid_descarga():
    try:
        pid = int(open(PID_DESCARGA).read().strip())
        return pid if mantenimiento.pid_vivo(pid) else None
    except Exception:
        return None


def matar(pid):
    if os.name == "nt":
        try:        # primero con educación: así no corta una escritura del CSV a medias
            import signal as _s
            os.kill(pid, _s.CTRL_BREAK_EVENT)
            for _ in range(24):
                if not pid_vivo(pid):
                    return
                time.sleep(0.5)
        except Exception:
            pass
        subprocess.run(["taskkill", "/PID", str(pid), "/T", "/F"], capture_output=True,
                       creationflags=SIN_VENTANA)
    else:
        try:
            os.kill(pid, 15)
        except OSError:
            pass


def progreso_descarga():
    """Texto corto con el progreso, leyendo la última línea de progreso del log."""
    if not pid_descarga():
        return None
    try:
        with open(LOG_DESCARGA, encoding="utf-8", errors="replace") as f:
            lineas = f.readlines()[-60:]
    except OSError:
        return "Descargando…"
    for l in reversed(lineas):
        l = l.strip()
        if "/" in l and "errores" in l:
            partes = l.split()
            hechos, total = partes[0].split("/")
            resta = l.split("~")[-1].replace(" restantes", "") if "~" in l else ""
            try:
                pct = int(hechos) / max(int(total), 1)
                return f"Descargando {hechos}/{total} ({pct:.0%}) · {resta}"
            except ValueError:
                break
    return "Descargando…"


# ------------------------------------------------------------ descargas periódicas
def leer_config():
    try:
        with open(CONFIG, encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def guardar_config(cfg):
    try:
        tmp = CONFIG + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(cfg, f, ensure_ascii=False, indent=1)
        os.replace(tmp, CONFIG)
    except OSError:
        pass


def siguiente_ejecucion(prog, desde=None):
    desde = desde or datetime.now()
    try:
        h, m = map(int, str(prog.get("hora", "04:00")).split(":")[:2])
    except ValueError:
        h, m = 4, 0
    if prog.get("tipo") == "semana":
        objetivo = [DIAS_SEMANA.index(d) for d in prog.get("dias_semana", []) if d in DIAS_SEMANA] or [0]
        for i in range(1, 15):
            d = (desde + timedelta(days=i)).replace(hour=h, minute=m, second=0, microsecond=0)
            if d.weekday() in objetivo:
                return d
    return (desde + timedelta(days=int(prog.get("cada_dias", 7)))).replace(
        hour=h, minute=m, second=0, microsecond=0)


def lanzar_descarga(args):
    """Arranca vuelos_madrid.py igual que lo hace la app."""
    python = sys.executable.replace("pythonw.exe", "python.exe")
    env = dict(os.environ, PYTHONIOENCODING="utf-8", PYTHONUNBUFFERED="1")
    log = open(LOG_DESCARGA, "w", encoding="utf-8")
    flags = SIN_VENTANA | (subprocess.CREATE_NEW_PROCESS_GROUP if os.name == "nt" else 0)
    p = subprocess.Popen([python, "-u", SCRIPT_DESCARGA, *args], stdout=log,
                         stderr=subprocess.STDOUT, cwd=CARPETA, env=env, creationflags=flags)
    with open(PID_DESCARGA, "w") as f:
        f.write(str(p.pid))
    return p


def vigilar_programacion():
    """Cada minuto mira si toca una descarga programada y la lanza."""
    while not saliendo:
        try:
            cfg = leer_config()
            prog = cfg.get("programada") or {}
            if prog.get("activa") and prog.get("args") and prog.get("proxima") and not pid_descarga():
                toca = datetime.strptime(prog["proxima"], "%Y-%m-%d %H:%M")
                if datetime.now() >= toca:
                    mantenimiento.fusionar_conflictos(BASE)
                    lanzar_descarga(prog["args"])
                    prog["ultima"] = datetime.now().strftime("%Y-%m-%d %H:%M")
                    prog["proxima"] = siguiente_ejecucion(prog).strftime("%Y-%m-%d %H:%M")
                    guardar_config({**cfg, "programada": prog})
                    if icono_bandeja:
                        try:
                            icono_bandeja.notify(f"Descarga programada en marcha.\nSiguiente: "
                                                 f"{prog['proxima']}", TITULO)
                        except Exception:
                            pass
        except Exception:
            pass
        time.sleep(60)


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
        [python, "-m", "streamlit", "run", "app_vuelos.py", "--server.port", str(PUERTO),
         "--server.headless", "true", "--browser.gatherUsageStats", "false",
],
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
    """Cerrar = ocultar. La app sigue en la bandeja y la descarga continúa."""
    if saliendo:
        return True
    threading.Thread(target=ventana.hide, daemon=True).start()
    return False


# ------------------------------------------------------------ bandeja del sistema
def salir(*_):
    global saliendo
    saliendo = True
    pid = pid_descarga()
    if pid:
        matar(pid)          # lo descargado ya está guardado; se continúa la próxima vez
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
    img = Image.open(ICONO) if os.path.exists(ICONO) else Image.new("RGB", (64, 64), "black")
    menu = pystray.Menu(
        pystray.MenuItem("Abrir Viajes", mostrar, default=True),
        pystray.MenuItem(lambda _: progreso_descarga() or "Sin descargas en curso", None, enabled=False),
        pystray.MenuItem(lambda _: (lambda p: f"Programada: {p['proxima']}" if p.get("activa") and
                                    p.get("proxima") else "Sin descargas programadas")(
                                        leer_config().get("programada") or {}), None, enabled=False),
        pystray.Menu.SEPARATOR,
        pystray.MenuItem(lambda _: "Salir (pausa la descarga)" if pid_descarga() else "Salir", salir),
    )
    icono_bandeja = pystray.Icon("viajes", img, TITULO, menu)

    # Descargas programadas desactivadas: Mario prefiere lanzarlas el mismo a mano.
    # (la función vigilar_programacion() se deja tal cual por si se quiere retomar)
    # threading.Thread(target=vigilar_programacion, daemon=True).start()

    def vigilar():
        """Actualiza el texto al pasar el ratón y avisa cuando termina una descarga."""
        estaba = False
        while not saliendo:
            prog = progreso_descarga()
            icono_bandeja.title = f"{TITULO}\n{prog}" if prog else TITULO
            if estaba and not prog:
                try:
                    icono_bandeja.notify("La descarga de precios ha terminado.", TITULO)
                except Exception:
                    pass
            estaba = bool(prog)
            try:
                icono_bandeja.update_menu()
            except Exception:
                pass
            time.sleep(5)
    threading.Thread(target=vigilar, daemon=True).start()
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
        "$l = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Viajes.lnk';"
        "$s = (New-Object -ComObject WScript.Shell).CreateShortcut($l);"
        f"$s.TargetPath = '{pyw}';"
        f"$s.Arguments = '\"{script}\"';"
        f"$s.WorkingDirectory = '{CARPETA}';"
        f"$s.IconLocation = '{icono}';"
        "$s.Description = 'Viajes';"
        "$s.Save()"
    )
    r = subprocess.run(["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps],
                       capture_output=True, text=True)
    print("      Acceso directo 'Viajes' creado en el escritorio" if r.returncode == 0
          else f"      No se pudo crear el acceso directo: {r.stderr.strip()[:200]}")
    subprocess.Popen([pyw, script], cwd=CARPETA, close_fds=True,
                     creationflags=0x00000008 | 0x00000200)  # DETACHED_PROCESS | NEW_PROCESS_GROUP


# ------------------------------------------------------------ principal
def main():
    global ventana
    if ya_abierta():
        return
    try:
        mantenimiento.fusionar_conflictos(BASE)
    except Exception:
        pass
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
    webview.settings["OPEN_EXTERNAL_LINKS_IN_BROWSER"] = True   # "Reservar" abre tu navegador
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
:::BEGIN py/mantenimiento.py|text
"""
Mantenimiento de la carpeta de datos: evita que se acumulen duplicados.

Cuando OneDrive sincroniza el mismo fichero editado casi a la vez desde el
portátil y el ordenador de sobremesa, en vez de perder datos crea una "copia
en conflicto" con el nombre del PC añadido (p. ej. "vuelos_madrid-Portatil_Mario.csv"
junto a "vuelos_madrid.csv"). Sin limpieza, esas copias se van acumulando.

fusionar_conflictos() se llama una vez al arrancar la app (y antes de cada
descarga programada): busca esas copias, junta en el CSV principal las filas
que no estuvieran ya (nunca se pierde nada) y borra la copia. Los ficheros
de configuración (.json) no se fusionan solos —mezclar ajustes a ciegas puede
dejar un estado sin sentido—, solo se avisa por si hay que revisarlos a mano.
"""
import csv
import glob
import os
import re
from datetime import datetime


def _fusionar_csv(canon, copia, log):
    """Añade a 'canon' las filas de 'copia' que no tenga ya, y borra 'copia'."""
    try:
        with open(canon, "rb") as f:
            existentes = set(f.readlines()[1:])   # todo menos la cabecera
        with open(copia, "rb") as f:
            lineas = f.readlines()[1:]
        nuevas = [l for l in lineas if l not in existentes]
        if nuevas:
            with open(canon, "ab") as f:
                f.writelines(nuevas)
        os.remove(copia)
        log(f"[mantenimiento] {os.path.basename(copia)}: {len(nuevas)} fila(s) nueva(s) "
            f"añadidas a {os.path.basename(canon)}; copia borrada.")
    except Exception as e:
        log(f"[mantenimiento] no se pudo fusionar {os.path.basename(copia)}: {e}")


def fusionar_conflictos(base_dir, log=print):
    """Revisa csv/ y la carpeta base en busca de copias en conflicto de OneDrive
    y las resuelve. base_dir = carpeta 'Vuelos' (la que contiene csv/, assets/, py/)."""
    csv_dir = os.path.join(base_dir, "csv")
    patron = re.compile(r"^(.+)-[A-Za-z0-9_]+(-\d+)?$")

    # 1) CSV de datos: fusionar filas y borrar la copia
    if os.path.isdir(csv_dir):
        for nombre in sorted(os.listdir(csv_dir)):
            ruta = os.path.join(csv_dir, nombre)
            stem, ext = os.path.splitext(nombre)
            if ext.lower() != ".csv":
                continue
            m = patron.match(stem)
            if not m:
                continue
            canon = os.path.join(csv_dir, m.group(1) + ext)
            if os.path.exists(canon) and canon != ruta:
                _fusionar_csv(canon, ruta, log)

    # 2) config_vuelos.json: solo avisar, nunca fusionar ajustes a ciegas
    for ruta in glob.glob(os.path.join(base_dir, "config_vuelos-*.json")):
        log(f"[mantenimiento] aviso: copia en conflicto de config_vuelos.json "
            f"({os.path.basename(ruta)}); revísala a mano si tiene ajustes que quieras "
            f"conservar y bórrala luego.")

    # 3) logs y .pid de otras máquinas: no aportan nada, se borran directamente
    for patron_glob in ("app-*.log", "descarga-*.log", "descarga-*.pid",
                        "descarga_vuelos-*.log", "descarga_vuelos-*.pid",
                        "descarga_hoteles-*.log", "descarga_hoteles-*.pid"):
        for ruta in glob.glob(os.path.join(base_dir, patron_glob)):
            try:
                os.remove(ruta)
            except OSError:
                pass


def _num_o_none(v):
    """float(v), o None si está vacío/no es numérico (nunca lanza excepción)."""
    try:
        x = float(v)
        return x if x == x else None      # descarta NaN
    except (TypeError, ValueError):
        return None


def parchear_precios_hoteles_previos(base_dir, log=print):
    """Parche de un solo uso para los datos de hoteles descargados antes de corregir el
    scraper: en algún momento Google dejó de mostrar el precio "por noche" en el texto de
    cada alojamiento (solo enseña el total de la estancia), y precio_noche se quedó vacío en
    todas las descargas desde entonces. El scraper ya está corregido (calcula
    precio_noche = precio_total / noches cuando falta), pero los datos ya descargados se
    quedaron con el precio vacío. Este parche los recupera hasta donde es posible:

    1) hoteles.csv: tiene precio_total y noches de cada fila, así que se recupera
       precio_noche del todo (se recalcula y se guarda).
    2) historico_hoteles.csv: ahí nunca se guardó precio_total ni noches (solo precio_noche),
       así que solo se puede recuperar el precio de la consulta más reciente de cada
       alojamiento/fecha —la que coincide con la fila que sigue viva en hoteles.csv—; las
       consultas más antiguas de esa misma fecha se sobrescribieron sin guardar el precio y
       ya no hay forma de recuperarlas. Con esto, cada alojamiento/fecha parte ya con un
       precio válido y solo hace falta UNA descarga más (no dos) para tener el primer tramo
       de antelación comparable.

    Se ejecuta una sola vez (deja una marca en base_dir); no vuelve a tocar nada en
    ejecuciones posteriores."""
    marca = os.path.join(base_dir, ".parche_precio_hoteles_v1")
    if os.path.exists(marca):
        return
    csv_dir = os.path.join(base_dir, "csv")
    ruta_hoteles = os.path.join(csv_dir, "hoteles.csv")
    ruta_hist = os.path.join(csv_dir, "historico_hoteles.csv")

    recuperados = {}   # (consulta, fecha_entrada, codigo, ciudad, nombre) -> precio_noche
    n_hoteles = 0

    if os.path.exists(ruta_hoteles):
        tmp = ruta_hoteles + ".tmp"
        try:
            with open(ruta_hoteles, encoding="utf-8-sig", newline="") as f:
                r = csv.DictReader(f, delimiter=";")
                columnas = r.fieldnames
                with open(tmp, "w", encoding="utf-8-sig", newline="") as g:
                    w = csv.DictWriter(g, fieldnames=columnas, delimiter=";", extrasaction="ignore")
                    w.writeheader()
                    for fila in r:
                        pn = _num_o_none(fila.get("precio_noche"))
                        if pn is None:
                            pt = _num_o_none(fila.get("precio_total"))
                            nn = _num_o_none(fila.get("noches")) or 1
                            if pt is not None and nn:
                                pn = round(pt / nn, 2)
                                fila["precio_noche"] = pn
                                n_hoteles += 1
                        if pn is not None:
                            clave = (fila.get("consulta", ""), fila.get("fecha_entrada", ""),
                                     fila.get("codigo", ""), fila.get("ciudad", ""), fila.get("nombre", ""))
                            recuperados[clave] = pn
                        w.writerow(fila)
            os.replace(tmp, ruta_hoteles)
            log(f"[parche hoteles] hoteles.csv: {n_hoteles:,} precio(s) recuperado(s) a partir del total.")
        except Exception as e:
            log(f"[parche hoteles] no se pudo parchear hoteles.csv: {e}")
            try:
                os.remove(tmp)
            except OSError:
                pass

    n_hist = 0
    if os.path.exists(ruta_hist) and recuperados:
        tmp = ruta_hist + ".tmp"
        try:
            with open(ruta_hist, encoding="utf-8-sig", newline="") as f:
                r = csv.DictReader(f, delimiter=";")
                columnas = r.fieldnames
                with open(tmp, "w", encoding="utf-8-sig", newline="") as g:
                    w = csv.DictWriter(g, fieldnames=columnas, delimiter=";", extrasaction="ignore")
                    w.writeheader()
                    for fila in r:
                        if not fila.get("precio_noche"):
                            clave = (fila.get("consulta", ""), fila.get("fecha_entrada", ""),
                                     fila.get("codigo", ""), fila.get("ciudad", ""), fila.get("nombre", ""))
                            pn = recuperados.get(clave)
                            if pn is not None:
                                fila["precio_noche"] = pn
                                n_hist += 1
                        w.writerow(fila)
            os.replace(tmp, ruta_hist)
            log(f"[parche hoteles] historico_hoteles.csv: {n_hist:,} precio(s) recuperado(s) "
                "(solo la última consulta de cada alojamiento/fecha; las anteriores no se "
                "pueden recuperar).")
        except Exception as e:
            log(f"[parche hoteles] no se pudo parchear historico_hoteles.csv: {e}")
            try:
                os.remove(tmp)
            except OSError:
                pass

    try:
        with open(marca, "w") as f:
            f.write(datetime.now().isoformat())
    except OSError:
        pass


def pid_vivo(pid):
    """True si ese PID sigue existiendo (proceso vivo). En Windows usa la API nativa;
    en otros sistemas, os.kill(pid, 0)."""
    if os.name == "nt":
        import ctypes
        h = ctypes.windll.kernel32.OpenProcess(0x1000, False, pid)  # QUERY_LIMITED_INFORMATION
        if not h:
            return False
        code = ctypes.c_ulong()
        ctypes.windll.kernel32.GetExitCodeProcess(h, ctypes.byref(code))
        ctypes.windll.kernel32.CloseHandle(h)
        return code.value == 259  # STILL_ACTIVE
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


def pid_en_marcha(ruta_pid):
    """Lee un fichero .pid y devuelve el PID si ese proceso sigue vivo, o None si no
    existe el fichero, esta vacio o el proceso ya ha terminado. Se usa para que la
    descarga manual (app_vuelos.py) y la programada (vuelos_app.pyw) se vean la una
    a la otra aunque sean procesos distintos, y no se lancen las dos a la vez."""
    try:
        pid = int(open(ruta_pid).read().strip())
    except Exception:
        return None
    return pid if pid_vivo(pid) else None
:::END
:::BEGIN py/requirements.txt|text
fast-flights==3.1.0
primp==2.0.1
selectolax
streamlit
plotly
pandas
pyarrow
pystray
pillow
pywebview
airportsdata
psutil
json5
openpyxl
:::END
:::BEGIN py/VERSION.txt|text
1.7.0
:::END
:::BEGIN assets/vuelos.ico|b64
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
:::END
:::BEGIN assets/vuelos.png|b64
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
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
