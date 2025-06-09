@echo off
echo ==========================================
echo Solucion Alternativa - Splash Screen
echo ==========================================
echo.

cd /d C:\Users\moral\Documents\PinaApp

echo Paso 1: Respaldando archivo original...
copy android\app\src\main\res\drawable\launch_background.xml android\app\src\main\res\drawable\launch_background_backup.xml

echo.
echo Paso 2: Aplicando nueva configuracion del splash...
copy /Y android\app\src\main\res\drawable\launch_background_fixed.xml android\app\src\main\res\drawable\launch_background.xml

echo.
echo Paso 3: Limpiando proyecto...
call flutter clean

echo.
echo Paso 4: Obteniendo dependencias...
call flutter pub get

echo.
echo Paso 5: Construyendo la aplicacion...
call flutter build apk --release

echo.
echo ==========================================
echo COMPLETADO!
echo ==========================================
echo.
echo Esta solucion modifica directamente el XML
echo para usar solo splash.png en toda la pantalla.
echo.
echo El APK se encuentra en:
echo build\app\outputs\flutter-apk\app-release.apk
echo ==========================================
pause
