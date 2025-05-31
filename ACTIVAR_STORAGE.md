# 📋 Lista de tareas pendientes para activar Storage

## Cuando estés listo para actualizar a Blaze y activar Storage:

### 1. Actualizar a plan Blaze
- Ve a Firebase Console → Billing → Upgrade to Blaze
- Agrega un método de pago
- Configura alertas de presupuesto ($1 USD recomendado)

### 2. Crear bucket de Storage
- Ve a Storage → Comenzar
- Selecciona región (ej: us-central1)
- Crea el bucket

### 3. Configurar reglas de Storage
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Reglas para fotos de perfil
    match /perfiles/{fileName} {
      // Permitir lectura a todos los usuarios autenticados
      allow read: if request.auth != null;
      
      // Permitir escritura solo a usuarios autenticados
      // Verificar que el nombre del archivo contenga el userId del usuario autenticado
      allow write: if request.auth != null 
                  && fileName.matches('perfil_' + request.auth.uid + '_.*')
                  && request.resource.size < 5 * 1024 * 1024 // Max 5MB
                  && request.resource.contentType.matches('image/.*'); // Solo imágenes
    }
    
    // Reglas para fotos de productos
    match /productos/{imageName} {
      // Permitir lectura a todos (productos públicos)
      allow read: if true;
      
      // Permitir escritura solo a usuarios autenticados
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024 // Max 5MB
                   && request.resource.contentType.matches('image/.*'); // Solo imágenes
    }
  }
}
```

### 4. Activar subida de fotos en la app

En el archivo `lib/config/constants.dart`, busca esta línea:

```dart
static const bool storageEnabled = false; // Cambiar a true cuando se configure Firebase Storage
```

Y cámbiala a:

```dart
static const bool storageEnabled = true; // Firebase Storage ya está configurado
```

### 5. Reiniciar la app
```bash
flutter clean
flutter pub get
flutter run
```

## 🎯 Funcionalidades que se activarán:

- ✅ Subida de fotos de perfil
- ✅ Cambio de avatar
- ✅ Fotos de productos (cuando implementes el marketplace)
- ✅ Almacenamiento de imágenes en la nube

## 💡 Recordatorios:

- La capa gratuita de Storage incluye:
  - 5 GB de almacenamiento
  - 1 GB/día de descarga
  - 20,000 operaciones/día
  
- Para una app en desarrollo, es muy difícil exceder estos límites
- Las fotos se optimizan a 1024x1024 px para ahorrar espacio
