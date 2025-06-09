#!/bin/bash

echo "Regenerando splash screen..."
echo

echo "1. Eliminando splash screen anterior..."
flutter packages pub run flutter_native_splash:remove

echo
echo "2. Generando nuevo splash screen con splash.png..."
flutter packages pub run flutter_native_splash:create

echo
echo "3. Limpiando cache de Flutter..."
flutter clean

echo
echo "4. Obteniendo dependencias..."
flutter pub get

echo
echo "✅ Splash screen actualizado correctamente!"
echo "✅ Ahora la app usará splash.png como imagen de fondo."
echo
echo "Para ver los cambios, ejecuta: flutter run"
