@echo off
REM Script de solución rápida para PiñaApp

echo 🔧 Solucionando problemas de PiñaApp...
echo.

REM 1. Limpiar el proyecto
echo 1️⃣ Limpiando el proyecto...
call flutter clean

echo.
echo 2️⃣ Obteniendo dependencias...
call flutter pub get

echo.
echo 3️⃣ Verificando la configuración...
echo.
echo ✅ Asegúrate de que en firebase_config.dart:
echo    - enablePersistence = false
echo.

echo 4️⃣ Instrucciones adicionales:
echo.
echo Si el problema persiste después de ejecutar 'flutter run':
echo.
echo 📱 En el emulador:
echo    1. Ve a Configuración → Apps → PiñaApp
echo    2. Toca 'Almacenamiento'
echo    3. Toca 'Borrar datos' y 'Borrar caché'
echo.
echo 🔑 En Firebase Console:
echo    1. Verifica que el usuario existe en Authentication
echo    2. Verifica que su documento existe en Firestore → usuarios
echo    3. Si no existe el documento, elimina el usuario y regístralo de nuevo
echo.
echo ✅ Listo! Ahora ejecuta: flutter run
pause
