# 🔧 INSTRUCCIONES PARA APLICAR LOS CAMBIOS DE LOGOS

## ✅ Estado de las correcciones

1. **✅ Logo superior de la app**: Corregido (logo2.png - piña blanca)
2. **✅ Publicaciones sin foto**: Corregido (logo2.png - piña blanca)  
3. **✅ Perfil**: Corregido (logo2.png - piña blanca)
4. **🔄 Logos del escritorio y carga**: REQUIERE ACCIÓN (logo.png - principal)
5. **✅ Logo al reiniciar**: Corregido (logo.png - principal)

## 🚀 Pasos para aplicar los cambios pendientes

### Paso 1: Ejecutar el script de generación

**En Windows:**
```bash
# Doble clic en el archivo o ejecutar en terminal:
generate_app_assets.bat
```

**En Linux/Mac:**
```bash
# Dar permisos de ejecución y ejecutar:
chmod +x generate_app_assets.sh
./generate_app_assets.sh
```

### Paso 2: Verificar los cambios

Después de ejecutar el script, verifica que se hayan generado:

- **Iconos de Android**: `android/app/src/main/res/mipmap-*/launcher_icon.png`
- **Iconos de iOS**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Splash Screen**: Archivos actualizados en `android/app/src/main/res/drawable/`

### Paso 3: Compilar y probar

```bash
# Compilar la app
flutter build apk --debug

# O ejecutar en emulador/dispositivo
flutter run
```

## 🎨 Configuración aplicada

### Iconos de la app:
- **Imagen**: `assets/images/logo.png` (logo principal)
- **Plataformas**: Android, iOS, Web, Windows, macOS

### Splash Screen:
- **Imagen**: `assets/images/logo.png` (logo principal)
- **Color de fondo**: Verde (#4CAF50) - temática de piña
- **Color oscuro**: Verde oscuro (#2E7D32)
- **Soporte**: Android (incluyendo Android 12+)

## 📱 Resultado final

Después de aplicar estos cambios:

1. **Icono en escritorio**: Logo principal de la piña con fondo verde
2. **Splash screen nativo**: Logo principal sobre fondo verde
3. **Splash screen de Flutter**: Logo principal con animaciones (ya configurado)
4. **AppBar**: Logo de piña blanca (ya configurado)
5. **Perfil**: Logo de piña blanca (ya configurado)
6. **Productos sin foto**: Logo de piña blanca (ya configurado)

## ⚠️ Notas importantes

- Los cambios en iconos nativos requieren reinstalar la app
- El splash screen nativo solo se ve al abrir la app desde el escritorio
- Los colores elegidos combinan con la temática de la app (verde piña)

## 🐛 Solución de problemas

Si algo no funciona:

1. Ejecuta `flutter clean`
2. Ejecuta `flutter pub get`
3. Vuelve a ejecutar el script
4. Reinstala la app completamente

¡Los logos ahora están perfectamente configurados! 🍍✨
