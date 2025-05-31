# SOLUCIÓN: Usuarios sin documentos en Firestore

## Problema identificado

Los usuarios existen en Firebase Authentication pero NO tienen sus documentos correspondientes en Firestore. Esto ocurre porque:

1. Las reglas de Firestore están bloqueando la creación de documentos
2. Hubo un error al crear el documento durante el registro
3. Los documentos fueron eliminados manualmente

## Solución paso a paso

### 1. Actualiza las reglas de Firestore (IMPORTANTE)

Ve a Firebase Console → Firestore Database → Rules y reemplaza con:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir a usuarios autenticados leer/escribir su propio documento
    match /usuarios/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // TEMPORAL para desarrollo - permitir todo a usuarios autenticados
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Haz clic en "Publicar" después de pegar las reglas.**

### 2. Ejecuta este código para verificar

```dart
// En tu archivo principal temporalmente
import 'package:pina_app/services/user_sync_service.dart';

// Agrega este botón en alguna pantalla temporal
ElevatedButton(
  onPressed: () async {
    final status = await UserSyncService.checkCurrentUserSync();
    print(status);
    
    if (!status.isSync && status.hasAuth) {
      final result = await UserSyncService.syncAuthWithFirestore();
      print(result);
    }
  },
  child: Text('Verificar y Sincronizar'),
)
```

### 3. O manualmente en Firebase Console

Para cada usuario que quieras probar:

1. Ve a Firestore Database
2. Haz clic en la colección `usuarios`
3. Haz clic en "Agregar documento"
4. **ID del documento**: Pega el UID del usuario (de la lista de Authentication)
5. Agrega estos campos mínimos:

```
nombre: [string] = "Nombre del Usuario"
email: [string] = "correo@ejemplo.com"
tipo: [string] = "productor"
telefono: [string] = ""
perfilCompleto: [boolean] = false
verificado: [boolean] = false
calificacionPromedio: [number] = 0
numeroTransacciones: [number] = 0
ubicacion: [string] = ""
fotoPerfil: [string] = ""
```

6. Para el campo `configuracion`, selecciona tipo "map" y agrega:
```
notificacionesEmail: [boolean] = true
notificacionesPush: [boolean] = true
mostrarTelefono: [boolean] = true
mostrarUbicacion: [boolean] = true
idioma: [string] = "es"
tema: [string] = "claro"
```

### 4. Script de limpieza (opcional)

Si quieres limpiar usuarios sin documentos:

1. Ve a Authentication
2. Para cada usuario que no funcione:
   - Haz clic en los 3 puntos → "Eliminar cuenta"
3. Pide a los usuarios que se registren de nuevo

## Verificación

Después de aplicar estos cambios:

1. Cierra la app completamente
2. Vuelve a ejecutar `flutter run`
3. Intenta iniciar sesión

## ¿Por qué pasó esto?

Probablemente las reglas de Firestore estaban muy restrictivas o hubo un error de red durante el registro que impidió crear el documento en Firestore aunque sí se creó en Authentication.

## Prevención futura

1. Siempre verifica que las reglas de Firestore permitan a los usuarios crear su propio documento
2. Implementa reintentos al crear documentos durante el registro
3. Agrega logs detallados para identificar fallos
