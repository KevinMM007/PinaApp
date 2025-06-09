# Instrucciones para Completar las Correcciones de Iconos

## Cambios Realizados ✅

1. **Pantalla de inicio de sesión**: Se cambió el placeholder temporal por el logo.png
2. **Publicaciones sin foto**: Se quitó el texto "piña" y se aumentó el tamaño del icono
3. **AppBar principal**: Se simplificó para mostrar solo el icono de piña sin fondo extra
4. **Perfil**: Ya tiene el icono y "Mi Perfil" en el header
5. **ListTiles del perfil**: Se mejoró el diseño con sombras y mejor separación

## Pasos Pendientes para Completar 🔧

Para completar los cambios de iconos de la aplicación (puntos 1 y 2), debes ejecutar los siguientes comandos:

### 1. Abrir una terminal en la carpeta del proyecto:
```bash
cd C:\Users\moral\Documents\PinaApp
```

### 2. Instalar las dependencias:
```bash
flutter pub get
```

### 3. Generar los iconos de la aplicación:
```bash
flutter pub run flutter_launcher_icons
```

### 4. Generar el splash screen:
```bash
flutter pub run flutter_native_splash:create
```

### 5. Limpiar y reconstruir el proyecto:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 6. Ejecutar la aplicación:
```bash
flutter run
```

## Verificación

Después de ejecutar estos comandos, deberías ver:

1. **Icono de la app**: El logo.png como icono de la aplicación en el teléfono
2. **Splash screen**: Una pantalla de carga verde con el logo.png
3. **Pantalla de login**: El logo.png en lugar del icono temporal
4. **Publicaciones sin foto**: Solo el icono de piña más grande sin texto
5. **AppBar**: El icono de piña en blanco sin fondo extra
6. **Perfil**: Opciones mejor diseñadas con sombras y separación

## Notas Importantes

- Si el icono no se actualiza inmediatamente, desinstala la app del dispositivo y vuelve a instalarla
- En algunos dispositivos Android, puede ser necesario reiniciar el launcher o el dispositivo
- Para iOS, asegúrate de ejecutar `flutter clean` antes de construir

## Posibles Problemas

Si encuentras algún error:

1. **Error de permisos**: Ejecuta la terminal como administrador
2. **Error de caché**: Ejecuta `flutter clean` y vuelve a intentar
3. **Error de iconos**: Verifica que logo.png esté en `assets/images/`

¡Listo! Todos los cambios solicitados han sido implementados. 🎉
