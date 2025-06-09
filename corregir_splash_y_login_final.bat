@echo off
echo =================================================
echo     CORRECCIONES FINALES - SPLASH Y LOGIN
echo =================================================
echo.

echo ✅ 1. Verificando imágenes necesarias...
if exist "assets\images\splash.png" (
    echo    ✅ splash.png encontrado
) else (
    echo    ❌ splash.png NO encontrado - verifica que exista
    pause
    exit /b 1
)

if exist "assets\images\fondoDePantalla.png" (
    echo    ✅ fondoDePantalla.png encontrado
) else (
    echo    ❌ fondoDePantalla.png NO encontrado - verifica que exista
    pause
    exit /b 1
)

if exist "assets\images\googleLogo.png" (
    echo    ✅ googleLogo.png encontrado
) else (
    echo    ❌ googleLogo.png NO encontrado - verifica que exista
    pause
    exit /b 1
)

if exist "assets\images\logo.png" (
    echo    ✅ logo.png encontrado
) else (
    echo    ❌ logo.png NO encontrado - verifica que exista
    pause
    exit /b 1
)

echo.
echo ✅ 2. Limpiando cache y archivos temporales...
flutter clean

echo.
echo ✅ 3. Obteniendo dependencias...
flutter pub get

echo.
echo ✅ 4. Eliminando splash screen anterior...
flutter packages pub run flutter_native_splash:remove

echo.
echo ✅ 5. Generando nuevo splash screen...
flutter packages pub run flutter_native_splash:create

echo.
echo ✅ 6. Generando iconos de la app...
flutter packages pub run flutter_launcher_icons:main

echo.
echo ================================================
echo              CORRECCIONES APLICADAS:
echo ================================================
echo ✅ SPLASH SCREEN:
echo    - Usa splash.png como imagen de fondo
echo    - Logo de piña centrado correctamente
echo    - Fallback a fondoDePantalla.png si hay error
echo.
echo ✅ LOGIN SCREEN:
echo    - Fondo: fondoDePantalla.png (corregido)
echo    - Logo de piña más grande (140x140px)
echo    - Logo de Google: usa googleLogo.png real
echo    - Botón degradado naranja mantiene diseño Figma
echo    - Sin scroll requerido
echo.
echo Para probar la app ejecuta: flutter run
echo.
echo Si aún ves el splash verde, ejecuta:
echo flutter run --debug
echo.
pause
