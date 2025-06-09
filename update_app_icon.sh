#!/bin/bash

# Script para actualizar el ícono de la aplicación PiñaApp
# Este script copia el logo.png a los directorios de Android e iOS con las resoluciones correctas

echo "Actualizando ícono de la aplicación PiñaApp..."

# Verificar que existe el logo original
if [ ! -f "assets/images/logo.png" ]; then
    echo "❌ Error: No se encuentra el archivo assets/images/logo.png"
    exit 1
fi

echo "✅ Logo encontrado en assets/images/logo.png"

# Para Android, necesitamos copiar el logo a los directorios mipmap
# En un proyecto real, deberías redimensionar el logo a diferentes tamaños:
# mdpi: 48x48, hdpi: 72x72, xhdpi: 96x96, xxhdpi: 144x144, xxxhdpi: 192x192

echo "📱 Configurando para Android..."

# Crear directorios si no existen
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi

# Copiar el logo (en producción deberías redimensionar cada una)
cp assets/images/logo.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png
cp assets/images/logo.png android/app/src/main/res/mipmap-hdpi/ic_launcher.png
cp assets/images/logo.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
cp assets/images/logo.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
cp assets/images/logo.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

echo "✅ Íconos de Android actualizados"

# Para iOS (si existe)
if [ -d "ios" ]; then
    echo "🍎 Configurando para iOS..."
    # En iOS los íconos van en ios/Runner/Assets.xcassets/AppIcon.appiconset/
    # Aquí también necesitarías múltiples tamaños
    echo "ℹ️  Para iOS, necesitas actualizar los íconos manualmente en Xcode"
fi

echo "🎉 ¡Configuración de íconos completada!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Para ver los cambios, desinstala la app del dispositivo/emulador"
echo "2. Ejecuta: flutter clean && flutter pub get"
echo "3. Reinstala la app: flutter run"
echo ""
echo "💡 Nota: En producción deberías usar diferentes tamaños de imagen"
echo "   para cada resolución en lugar de usar la misma imagen."
