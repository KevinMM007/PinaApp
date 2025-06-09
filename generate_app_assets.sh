#!/bin/bash

echo "==================================="
echo "Generando iconos y splash screen"
echo "==================================="

echo ""
echo "1. Obteniendo dependencias..."
flutter pub get

echo ""
echo "2. Generando iconos de la app..."
flutter pub run flutter_launcher_icons

echo ""
echo "3. Generando splash screen..."
flutter pub run flutter_native_splash:create

echo ""
echo "4. Limpiando cache..."
flutter clean

echo ""
echo "==================================="
echo "Proceso completado exitosamente!"
echo "==================================="
echo ""
echo "Ahora puedes ejecutar la app con:"
echo "flutter run"
echo ""
