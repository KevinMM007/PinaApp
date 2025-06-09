@echo off
echo ========================================
echo   Aplicando correcciones a PiñaApp
echo ========================================
echo.

cd /d "C:\Users\moral\Documents\PinaApp"

echo [1/5] Limpiando cache completa...
call flutter clean
rd /s /q build 2>nul
rd /s /q .dart_tool 2>nul
rd /s /q android\app\build 2>nul
rd /s /q ios\Pods 2>nul

echo.
echo [2/5] Restaurando dependencias...
call flutter pub get

echo.
echo [3/5] Generando splash screen nativo...
call flutter pub run flutter_native_splash:create

echo.
echo [4/5] Generando iconos de la app...
call flutter pub run flutter_launcher_icons

echo.
echo [5/5] Preconstruyendo la app...
call flutter precache

echo.
echo ========================================
echo   ¡Correcciones aplicadas!
echo ========================================
echo.
echo Notas importantes:
echo - El splash screen ahora usa fondoDePantalla.png con el logo encima
echo - La app ya no mostrará la pantalla de login al volver a abrirla si ya iniciaste sesión
echo - Se eliminó cualquier pantalla de carga innecesaria
echo.
echo Para probar los cambios:
echo 1. Ejecuta: flutter run
echo 2. Cierra completamente la app (incluyendo multitarea)
echo 3. Vuelve a abrirla para verificar que funcione correctamente
echo.
pause
