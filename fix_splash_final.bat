@echo off
echo ==========================================
echo Corrigiendo Splash Screen de PinaApp
echo ==========================================
echo.

cd /d C:\Users\moral\Documents\PinaApp

echo Paso 1: Eliminando configuracion anterior del Native Splash...
call flutter pub run flutter_native_splash:remove

echo.
echo Paso 2: Limpiando cache de Flutter...
call flutter clean

echo.
echo Paso 3: Eliminando archivos temporales de Android...
if exist android\.gradle rmdir /s /q android\.gradle
if exist android\app\build rmdir /s /q android\app\build

echo.
echo Paso 4: Obteniendo dependencias...
call flutter pub get

echo.
echo Paso 5: Regenerando Native Splash con la imagen correcta...
call flutter pub run flutter_native_splash:create

echo.
echo Paso 6: Copiando splash.png como background para Android...
copy /Y assets\images\splash.png android\app\src\main\res\drawable\background.png
copy /Y assets\images\splash.png android\app\src\main\res\drawable-v21\background.png
copy /Y assets\images\splash.png android\app\src\main\res\drawable\splash.png
copy /Y assets\images\splash.png android\app\src\main\res\drawable-v21\splash.png

echo.
echo Paso 7: Construyendo la aplicacion...
call flutter build apk --release

echo.
echo ==========================================
echo COMPLETADO!
echo ==========================================
echo.
echo La app ahora deberia mostrar solo el splash.png
echo sin pantallas adicionales de carga.
echo.
echo El APK se encuentra en:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo IMPORTANTE: Desinstala la version anterior
echo de la app antes de instalar esta nueva.
echo ==========================================
pause
