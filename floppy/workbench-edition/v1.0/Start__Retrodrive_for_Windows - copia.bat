@echo off
cd /d "%~dp0"
chcp 1252 >nul
mode con cols=65 lines=40
color 0A

setlocal enabledelayedexpansion

set CONFIG_DIR=config

:: Crear carpeta config si no existe
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"

:: ===== DETECTAR CONFIG =====
set FIRST_RUN=1

if exist "%CONFIG_DIR%\config.cfg" (
for /f "tokens=1,2 delims==" %%a in (%CONFIG_DIR%\config.cfg) do (
if /i "%%a"=="LANG" (
set lang=%%b
set FIRST_RUN=0
)
)
)

if not defined lang goto langmenu
goto loadlang

:: ===== SELECTOR DE IDIOMA =====
:langmenu
cls
type %CONFIG_DIR%\retrodrive.txt

echo.
echo.    [ 1 ] English   [ 2 ] Español   [ 3 ] Deutsch   [ 4 ] Italiano   [ 5 ] Français
echo.
echo.    Select a language by pressing a number
echo.

<nul set /p ="[ "
set /p lang=
<nul set /p ="]"
echo.

if "%lang%"=="1" set lang=en
if "%lang%"=="2" set lang=es
if "%lang%"=="3" set lang=de
if "%lang%"=="4" set lang=it
if "%lang%"=="5" set lang=fr

if not defined lang goto langmenu

echo LANG=%lang%> "%CONFIG_DIR%\config.cfg"
set FIRST_RUN=1

:: ===== CARGAR IDIOMA =====
:loadlang

set menu1=
set menu2=
set menu3=
set menu4=
set select=

if exist "%CONFIG_DIR%\lang_%lang%.cfg" (
for /f "usebackq tokens=1,* delims== eol=#" %%a in ("%CONFIG_DIR%\lang_%lang%.cfg") do (
set "%%a=%%b"
)
)

goto mainmenu

:: ===== MENÚ PRINCIPAL =====
:mainmenu

if "%FIRST_RUN%"=="1" (
type "%CONFIG_DIR%\retrodrive.txt"
) else (
type "%CONFIG_DIR%\logo.txt"
)

cls

:: mostrar logo
if exist "%CONFIG_DIR%\logo.txt" (
type "%CONFIG_DIR%\logo.txt"
echo.
)

echo        +------------------------------------------+
echo        ^| WORKBENCH EMULATOR                       ^|
echo        +------------------------------------------+
echo.
echo            1. %menu1%
echo            2. %menu2%
echo            3. %menu3%
echo            4. %menu4%
echo.
echo        -------------------------------------------
echo        %select%
echo        -------------------------------------------
<nul set /p =" *      > " & set /p key=


if "%key%"=="1" goto juegos
if "%key%"=="2" goto configuracion
if "%key%"=="3" goto ayuda
if "%key%"=="4" goto salir

goto mainmenu



:: ===== AYUDA =====
:ayuda
cls

echo.
echo    ******************
echo    :: %menu3%
echo    ******************
echo.

echo    %help1%
echo.
echo    %help2%
echo    %help3%
echo.
echo    %help4%
echo.
echo    %help5%
echo.

pause
goto mainmenu

:: ===== CONFIGURACIÓN =====
:configuracion
cls
echo.
echo    Cargando configuración...
timeout /t 1 >nul
goto configmenu

:configmenu
cls

echo.
echo    ******************
echo    :: %menu2%
echo    ******************
echo.
echo    1. ROM
echo    2. %back%
echo.

<nul set /p "=    : "

choice /c 12 /n >nul
set key=%errorlevel%

<nul set /p ="%key%"
timeout /t 1 >nul

if "%key%"=="1" goto rommenu
if "%key%"=="2" goto mainmenu

goto configmenu

:: ===== ROM =====
:rommenu
cls

echo.
echo    ******************
echo    :: ROM
echo    ******************
echo.
echo    1. %checkrom%
echo    2. %getrom%
echo    3. %back%
echo.

<nul set /p "=    : "

choice /c 123 /n >nul
set key=%errorlevel%

<nul set /p ="%key%"
timeout /t 1 >nul

if "%key%"=="1" goto checkrom
if "%key%"=="2" goto getrom
if "%key%"=="3" goto configmenu

goto rommenu

:checkrom
cls

echo.
echo    ******************
echo    :: ROM
echo    ******************
echo.

if exist "ROMS\kick.rom" (
echo    %romok%
) else (
echo    %rommissing%
)

echo.
pause
goto rommenu

:getrom
cls

echo.
echo    ******************
echo    :: ROM
echo    ******************
echo.

echo    %romhelp1%
echo.
echo    %romhelp2%
echo    %romhelp3%
echo.

pause
goto rommenu

:juegos
cls

setlocal enabledelayedexpansion

if not exist "GAMES" mkdir "GAMES"

set page=1
set perpage=10

:: ===== CARGAR JUEGOS =====
set count=0

pushd GAMES

for /d %%D in (*) do (

    set /a count+=1
    set "name!count!=%%D"

    set diskcount=0

    for /f %%F in ('dir /b /a-d "%%D\*.adf" 2^>nul') do (
        set /a diskcount+=1
    )
	echo %%D = !diskcount!
    if !diskcount! EQU 0 set diskcount=1

    set "disks!count!=!diskcount!"
)

popd

if !count! EQU 0 (
echo.
echo    No hay juegos disponibles
echo.
echo    Coloque sus juegos en:
echo    GAMES\NombreDelJuego
echo.
pause
endlocal
goto mainmenu
)

:: calcular páginas totales
set /a maxpage=(count+perpage-1)/perpage

:: ===== LOOP =====
:loop
cls
if exist "%CONFIG_DIR%\games.txt" (
    type "%CONFIG_DIR%\games.txt"
    echo.
)
set /a start=(page-1)*perpage+1
set /a end=page*perpage

echo.
echo                  ****************************
echo                        %pagina% !page! / !maxpage!
echo                  ****************************
echo.

echo.
if !end! GTR !count! set end=!count!

for /l %%i in (!start!,1,!end!) do (
    if %%i LEQ !count! (

        call echo    %%i. %%name%%i%% ^(%%disks%%i%% discos^)

    )
)
echo.
echo         -------------------
echo         %games_found% !count! %games_suffix%
echo.
echo         %games_nav%
echo.
echo         %games_select%

:: INPUT SEGURO
set key=
<nul set /p ="*       > "
set /p key=

if "%key%"=="" goto loop

:: comprobar si es número
set /a test=%key% 2>nul

if not "%test%"=="" (

    if %key% GEQ 1 if %key% LEQ %count% (

        cls
        echo.
        echo    Cargando !name%key%!...
        echo.

        timeout /t 1 >nul

        set "selected=!name%key%!"
        goto rungame
    )
)

:: siguiente
if /i "%key%"=="n" (
if !page! LSS !maxpage! set /a page+=1
goto loop
)

:: anterior
if /i "%key%"=="p" (
if !page! GTR 1 set /a page-=1
goto loop
)

:: volver
if /i "%key%"=="b" (
endlocal
goto mainmenu
)

goto loop

:rungame
cls

:: cambiar color ANTES
color 0E

echo.

<nul set /p ="     | Loading %selected% "

:: animación simple sin caracteres raros
<nul set /p ="."
timeout /t 1 >nul
<nul set /p =".."
timeout /t 1 >nul
<nul set /p ="..."
timeout /t 1 >nul
<nul set /p ="...."
timeout /t 1 >nul

color 0A

timeout /t 1 >nul
goto juegos

:salir
exit
