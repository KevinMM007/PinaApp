@echo off
echo ====================================
echo Corrigiendo Native Splash Screen
echo ====================================
echo.

cd /d C:\Users\moral\Documents\PinaApp

echo Eliminando configuración anterior del Native Splash...
flutter pub run flutter_native_splash:remove

echo.
echo Regenerando Native Splash con la configuración correcta...
flutter pub run flutter_native_splash:create

echo.
echo ====================================
echo Native Splash regenerado correctamente
echo ====================================
pause
