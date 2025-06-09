# Corrección de Splash Screen - Solo Native Launch Screen

## Problema Identificado
La app estaba mostrando dos pantallas de inicio:
1. Native Launch Screen (con fondo verde e icono de piña)
2. Splash Screen adicional en Flutter (con fondo verde y CircularProgressIndicator)

## Solución Aplicada

### 1. Eliminación del Splash Screen Adicional
- Se eliminó la clase `_SplashScreen` del archivo `main.dart`
- Se reemplazó por un simple `CircularProgressIndicator` sin fondo
- Esto reduce el tiempo de carga y evita mostrar dos pantallas de inicio

### 2. Configuración del Native Splash
El archivo `pubspec.yaml` ya está configurado correctamente para usar `splash.png`:
```yaml
flutter_native_splash:
  background_image: assets/images/splash.png
  fullscreen: true
  android_12:
    image: assets/images/logo.png
    color: "#4CAF50"
  web: false
```

## Pasos para Aplicar los Cambios

### Paso 1: Regenerar el Native Splash
Ejecuta el archivo batch creado:
```
fix_native_splash.bat
```

O ejecuta manualmente estos comandos:
```bash
# Eliminar configuración anterior
flutter pub run flutter_native_splash:remove

# Regenerar con la nueva configuración
flutter pub run flutter_native_splash:create
```

### Paso 2: Limpiar y Reconstruir
```bash
# Limpiar el proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Reconstruir la app
flutter build apk --release
```

### Paso 3: Probar la App
1. Desinstala la versión anterior de la app del dispositivo
2. Instala la nueva versión
3. Al abrir la app deberías ver solo el splash.png como pantalla de inicio

## Resultado Esperado
- Al iniciar la app: Solo se muestra la imagen `splash.png` completa
- No hay pantalla adicional con fondo verde y spinner
- La transición es directa del splash a la pantalla de login o home

## Nota Importante
Si el native splash sigue mostrando el fondo verde con icono en lugar de splash.png, es posible que necesites:
1. Verificar que el archivo `splash.png` esté en el formato correcto (PNG)
2. Asegurarte de que la imagen tenga las dimensiones adecuadas (se recomienda 1920x1080 o similar)
3. En Android 12+, el sistema puede aplicar su propio estilo al splash, por eso hay una configuración específica para `android_12` en el pubspec.yaml

## Archivos Modificados
- `lib/main.dart`: Eliminado _SplashScreen, simplificado AuthWrapper
- `fix_native_splash.bat`: Script para regenerar el native splash

## Tiempo de Ejecución
El proceso completo debería tomar aproximadamente 5-10 minutos dependiendo de la velocidad de tu computadora.
