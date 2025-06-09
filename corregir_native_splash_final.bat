@echo off
echo =================================================
echo    CORRIGIENDO NATIVE LAUNCH SCREEN - PiñaApp
echo =================================================
echo.

echo ✅ 1. Verificando imagen splash.png...
if exist "assets\images\splash.png" (
    echo    ✅ splash.png encontrado
) else (
    echo    ❌ splash.png NO encontrado
    echo    Por favor verifica que assets\images\splash.png exista
    pause
    exit /b 1
)

echo.
echo ✅ 2. Eliminando splash screen nativo anterior...
flutter packages pub run flutter_native_splash:remove

echo.
echo ✅ 3. Limpiando cache de Flutter...
flutter clean

echo.
echo ✅ 4. Obteniendo dependencias...
flutter pub get

echo.
echo ✅ 5. Generando nuevo Native Launch Screen con splash.png...
flutter packages pub run flutter_native_splash:create

echo.
echo ✅ 6. Ejecutando build para Android (opcional)...
flutter build apk --debug

echo.
echo ================================================
echo              CORRECCIÓN APLICADA:
echo ================================================
echo ✅ NATIVE LAUNCH SCREEN:
echo    - Ahora usa splash.png como imagen de fondo completa
echo    - Ya no aparecerá el fondo verde con piña
echo    - Solo se ve la imagen splash.png al abrir la app
echo.
echo ✅ CUSTOM SPLASH SCREEN:
echo    - Simplificado a un loading simple
echo    - Solo aparece brevemente como fallback
echo.
echo ================================================
echo                  RESULTADO:
echo ================================================
echo Al abrir la app verás SOLO:
echo 1. Native Launch Screen con tu imagen splash.png
echo 2. Luego directamente la pantalla de login
echo.
echo Para probar ejecuta: flutter run
echo.
echo Si sigues viendo el fondo verde, prueba:
echo flutter run --release
echo.
pause
