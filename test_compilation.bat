@echo off
echo ================================
echo Compilando PiñaApp...
echo ================================

echo.
echo 1. Limpiando proyecto...
flutter clean

echo.
echo 2. Obteniendo dependencias...
flutter pub get

echo.
echo 3. Compilando aplicación...
flutter build apk --debug

echo.
if %ERRORLEVEL% EQU 0 (
    echo ================================
    echo ¡Compilación exitosa! ✅
    echo ================================
    echo.
    echo Ahora puedes ejecutar:
    echo flutter run
) else (
    echo ================================
    echo Error en la compilación ❌
    echo ================================
    echo.
    echo Revisa los errores arriba
)

echo.
pause
