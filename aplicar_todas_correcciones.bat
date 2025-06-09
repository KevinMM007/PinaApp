@echo off
echo ==========================================
echo Aplicando TODAS las correcciones a PinaApp
echo ==========================================
echo.

cd /d C:\Users\moral\Documents\PinaApp

echo PASO 1: Creando carpetas necesarias para Android...
if not exist "android\app\src\main\res\drawable-v21" mkdir "android\app\src\main\res\drawable-v21"
if not exist "android\app\src\main\res\drawable-hdpi" mkdir "android\app\src\main\res\drawable-hdpi"
if not exist "android\app\src\main\res\drawable-mdpi" mkdir "android\app\src\main\res\drawable-mdpi"
if not exist "android\app\src\main\res\drawable-xhdpi" mkdir "android\app\src\main\res\drawable-xhdpi"
if not exist "android\app\src\main\res\drawable-xxhdpi" mkdir "android\app\src\main\res\drawable-xxhdpi"
if not exist "android\app\src\main\res\drawable-xxxhdpi" mkdir "android\app\src\main\res\drawable-xxxhdpi"

echo.
echo PASO 2: Copiando imagenes para Launch Screen...
REM Copiar fondoDePantalla.png como fondo_de_pantalla.png (Android no acepta camelCase)
copy /Y "assets\images\fondoDePantalla.png" "android\app\src\main\res\drawable\fondo_de_pantalla.png"
copy /Y "assets\images\fondoDePantalla.png" "android\app\src\main\res\drawable-v21\fondo_de_pantalla.png"
copy /Y "assets\images\fondoDePantalla.png" "android\app\src\main\res\drawable-hdpi\fondo_de_pantalla.png"
copy /Y "assets\images\fondoDePantalla.png" "android\app\src\main\res\drawable-mdpi\fondo_de_pantalla.png"
copy /Y "assets\images\fondoDePantalla.png" "android\app\src\main\res\drawable-xhdpi\fondo_de_pantalla.png"
copy /Y "assets\images\fondoDePantalla.png" "android\app\src\main\res\drawable-xxhdpi\fondo_de_pantalla.png"
copy /Y "assets\images\fondoDePantalla.png" "android\app\src\main\res\drawable-xxxhdpi\fondo_de_pantalla.png"

REM Copiar logo.png
copy /Y "assets\images\logo.png" "android\app\src\main\res\drawable\logo.png"
copy /Y "assets\images\logo.png" "android\app\src\main\res\drawable-v21\logo.png"
copy /Y "assets\images\logo.png" "android\app\src\main\res\drawable-hdpi\logo.png"
copy /Y "assets\images\logo.png" "android\app\src\main\res\drawable-mdpi\logo.png"
copy /Y "assets\images\logo.png" "android\app\src\main\res\drawable-xhdpi\logo.png"
copy /Y "assets\images\logo.png" "android\app\src\main\res\drawable-xxhdpi\logo.png"
copy /Y "assets\images\logo.png" "android\app\src\main\res\drawable-xxxhdpi\logo.png"

echo.
echo PASO 3: Eliminando configuracion anterior del Native Splash...
call flutter pub run flutter_native_splash:remove

echo.
echo PASO 4: Limpiando cache de Flutter...
call flutter clean

echo.
echo PASO 5: Eliminando archivos temporales de Android...
if exist android\.gradle rmdir /s /q android\.gradle
if exist android\app\build rmdir /s /q android\app\build
if exist build rmdir /s /q build

echo.
echo PASO 6: Obteniendo dependencias...
call flutter pub get

echo.
echo PASO 7: Regenerando Native Splash...
call flutter pub run flutter_native_splash:create

echo.
echo PASO 8: Construyendo la aplicacion...
call flutter build apk --release

echo.
echo ==========================================
echo COMPLETADO! Cambios aplicados:
echo ==========================================
echo.
echo 1. Launch Screen nativa ahora muestra:
echo    - Fondo: fondoDePantalla.png
echo    - Icono centrado: logo.png
echo.
echo 2. Eliminada la pantalla de carga verde
echo    al abrir detalles de productos
echo.
echo 3. Corregido el problema de autenticacion
echo    (no muestra login si ya inicio sesion)
echo.
echo El APK se encuentra en:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo IMPORTANTE: Desinstala completamente la version
echo anterior de la app antes de instalar esta nueva.
echo ==========================================
pause
