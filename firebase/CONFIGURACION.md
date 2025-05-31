# Configuración de Firebase para PiñaApp

## Problemas de conexión y soluciones

### 1. Error "Sin conexión a internet" en el emulador

Si estás viendo el error "Sin conexión a internet" en tu emulador de Android, sigue estos pasos:

#### Verificar conexión del emulador:
1. Abre el navegador del emulador y navega a cualquier sitio web
2. Si no hay conexión, reinicia el emulador
3. En Android Studio: AVD Manager → Actions → Cold Boot Now

#### Verificar configuración de Firebase:
1. Asegúrate de que tu archivo `google-services.json` esté en `android/app/`
2. Verifica que el archivo contenga la configuración correcta de tu proyecto

### 2. Configurar Firestore

#### Habilitar Firestore en Firebase Console:
1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. En el menú lateral, ve a Firestore Database
4. Haz clic en "Create Database"
5. Selecciona "Start in production mode"
6. Elige la ubicación más cercana a tu región

#### Configurar las reglas de seguridad:
1. En Firestore, ve a la pestaña "Rules"
2. Copia el contenido del archivo `firebase/firestore.rules`
3. Pégalo en el editor de reglas
4. Haz clic en "Publish"

### 3. Habilitar Authentication

1. En Firebase Console, ve a Authentication
2. Haz clic en "Get started"
3. En la pestaña "Sign-in method"
4. Habilita "Email/Password"

### 4. Configurar el emulador para modo offline

La app ahora soporta modo offline. Cuando no hay conexión:
- Se crea un perfil temporal con datos básicos
- Se muestra un banner naranja indicando el modo sin conexión
- Los datos se sincronizarán cuando vuelva la conexión

### 5. Probar la app

Para probar que todo funciona:

1. **Con conexión:**
   - Registra un nuevo usuario
   - Verifica que puedas iniciar sesión
   - El perfil debe cargarse correctamente

2. **Sin conexión:**
   - Activa el modo avión en el emulador
   - Intenta acceder al perfil
   - Deberías ver el banner de "Modo sin conexión"
   - Desactiva el modo avión y pulsa el botón de refrescar

### 6. Depuración

Si sigues teniendo problemas:

1. **Revisa los logs de Android Studio:**
   ```
   adb logcat | grep -i firebase
   ```

2. **Verifica la configuración de red del emulador:**
   - Settings → Network & Internet → Mobile network
   - Asegúrate de que esté habilitado

3. **Limpia y reconstruye el proyecto:**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   flutter run
   ```

### 7. Configuración adicional para producción

Antes de publicar la app:

1. **Índices de Firestore:**
   - Los índices se crearán automáticamente cuando uses queries complejas
   - Revisa la consola de Firebase para ver si hay índices pendientes

2. **Límites de cuota:**
   - Configura alertas de uso en Firebase Console
   - Considera usar Firebase App Check para mayor seguridad

3. **Respaldos:**
   - Configura respaldos automáticos de Firestore
   - Firebase Console → Firestore → Import/Export

## Problemas resueltos en esta actualización

✅ **Error de carga de perfil:** Ahora maneja mejor los errores de conectividad
✅ **Botón cerrar sesión:** Limpia el estado correctamente antes de cerrar
✅ **Registro queda cargando:** Navega correctamente después del registro
✅ **Eliminar cuenta:** El botón se habilita correctamente al escribir la contraseña
✅ **Modo offline:** La app funciona con funcionalidad limitada sin conexión

## Contacto y soporte

Si encuentras otros problemas, verifica:
- La versión de Flutter: `flutter --version`
- Los plugins están actualizados: `flutter pub outdated`
- Firebase CLI está instalado: `firebase --version`
