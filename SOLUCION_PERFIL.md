# Solución para el problema de carga de perfil en PiñaApp

## Resumen del problema

El problema ocurre cuando:
1. Los usuarios existentes no pueden cargar su perfil después de reinstalar la app
2. Solo funciona con usuarios nuevos
3. La app se queda cargando al reiniciar
4. El diagnóstico no resuelve el problema

## Causa raíz

El problema está relacionado con la **persistencia de Firestore** y conflictos de caché cuando se elimina y reinstala la aplicación.

## Solución implementada

### 1. **Desactivar temporalmente la persistencia**

Ya está configurado en `firebase_config.dart`:
```dart
static const bool enablePersistence = false;
```

### 2. **Forzar lectura desde servidor**

El código ahora siempre lee desde el servidor cuando la persistencia está deshabilitada.

### 3. **Mejorar el manejo de errores**

Se agregó mejor logging y manejo de timeouts.

## Pasos para solucionar el problema inmediato

1. **Asegúrate de instalar las dependencias**:
```bash
flutter pub get
```

2. **Limpia el proyecto**:
```bash
flutter clean
flutter pub get
```

3. **Ejecuta la aplicación**:
```bash
flutter run
```

## Si el problema persiste

### Opción 1: Verificar las reglas de Firestore

Ve a Firebase Console → Firestore → Rules y asegúrate de que las reglas permitan a los usuarios leer su propio documento:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /usuarios/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Opción 2: Verificar el documento en Firebase Console

1. Ve a Firebase Console → Firestore
2. Busca la colección `usuarios`
3. Verifica que existe el documento del usuario con el que intentas iniciar sesión
4. Si no existe, elimina el usuario de Authentication y regístralo nuevamente

### Opción 3: Limpiar completamente y reinstalar

1. Desinstala la app del emulador
2. En Android Studio: Tools → AVD Manager → Wipe Data del emulador
3. Reinstala y ejecuta la app

## Mejoras implementadas

1. **DiagnosticService**: Servicio completo de diagnóstico y reparación automática
2. **CacheManager**: Manejo inteligente del caché
3. **Mejor logging**: Para identificar exactamente dónde falla
4. **Timeouts configurables**: Para evitar esperas infinitas
5. **Lectura forzada desde servidor**: Cuando la persistencia está deshabilitada

## Configuración recomendada para desarrollo

Mantén estas configuraciones mientras desarrollas:

**firebase_config.dart**:
```dart
static const bool enablePersistence = false; // Deshabilitado
static const int firestoreTimeout = 10; // 10 segundos
static const int maxRetries = 3;
```

## Para producción

Cuando la app esté estable, puedes re-habilitar la persistencia:
```dart
static const bool enablePersistence = true;
```

Pero asegúrate de implementar una estrategia de limpieza de caché periódica.
