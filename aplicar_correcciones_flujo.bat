@echo off
echo ====================================
echo Aplicando todas las correcciones
echo ====================================

cd C:\Users\moral\Documents\PinaApp

echo.
echo [1/4] Limpiando el proyecto...
flutter clean

echo.
echo [2/4] Obteniendo dependencias...
flutter pub get

echo.
echo [3/4] Regenerando Native Splash Screen...
flutter pub run flutter_native_splash:create

echo.
echo [4/4] Compilando la aplicacion...
flutter build apk --debug

echo.
echo ====================================
echo CORRECCIONES APLICADAS!
echo ====================================
echo.
echo Verifica lo siguiente:
echo - La splash screen debe mostrar el fondo de pantalla con el logo
echo - Los productos deben abrirse sin pantalla de carga
echo - Al reabrir la app no debe mostrar login si ya estas autenticado
echo.
echo Para probar, ejecuta: flutter run
echo.
pause
