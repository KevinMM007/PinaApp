@echo off
echo Regenerando Native Splash Screen...
cd C:\Users\moral\Documents\PinaApp

echo Limpiando configuraciones anteriores...
flutter clean

echo Generando nueva configuración de splash screen...
flutter pub run flutter_native_splash:create

echo Proceso completado!
pause
