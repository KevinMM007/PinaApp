# PiñaApp

Aplicación móvil para conectar productores y compradores de piña.

## ⚠️ Estado Actual

**IMPORTANTE**: La aplicación está funcionando con una solución temporal. La persistencia de Firestore está deshabilitada debido a problemas de caché que ocurren al reinstalar la aplicación. Esto significa:

- ✅ La app funciona correctamente con conexión a internet
- ❌ No funciona en modo offline
- 📱 Puede usar más datos móviles de lo normal

Para más detalles, ver [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

## 🍍 Descripción

PiñaApp es una plataforma que facilita la conexión directa entre productores de piña y compradores, eliminando intermediarios y promoviendo el comercio justo.

## ✨ Características principales

- **Marketplace**: Los productores pueden publicar sus productos con fotos, precios y detalles de calidad
- **Perfiles diferenciados**: Productores, compradores y transportistas
- **Autenticación segura**: Sistema de registro e inicio de sesión con Firebase
- **Filtrado avanzado**: Búsqueda por variedad de piña, ubicación y calidad
- **Gestión de productos**: Crear, editar y eliminar publicaciones

## 🚀 Tecnologías utilizadas

- **Flutter**: Framework principal para el desarrollo multiplataforma
- **Firebase**: Backend como servicio (Authentication, Firestore)
- **Provider**: Gestión de estado reactiva
- **Material Design**: Interfaz de usuario moderna y consistente

## 📱 Instalación

### Prerrequisitos

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio o VS Code
- Firebase CLI

### Pasos de instalación

1. **Clonar el repositorio**
   ```bash
   git clone [URL_DEL_REPOSITORIO]
   cd PinaApp
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase**
   - Crear un proyecto en [Firebase Console](https://console.firebase.google.com/)
   - Agregar las aplicaciones Android e iOS
   - Descargar y colocar los archivos de configuración:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Agregar assets**
   - Los logos ya están configurados:
     - `assets/images/logo.png` (logo principal para iconos y splash)
     - `assets/images/logo2.png` (logo blanco para UI interna)

5. **Generar iconos y splash screen**
   ```bash
   # En Windows:
   generate_app_assets.bat
   
   # En Linux/Mac:
   chmod +x generate_app_assets.sh
   ./generate_app_assets.sh
   ```

6. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

   **Nota**: Si encuentras errores de compilación, ejecuta:
   ```bash
   # Compilación limpia
   test_compilation.bat
   ```

## 🏗️ Estructura del proyecto

```
lib/
├── config/          # Configuración y constantes
├── models/          # Modelos de datos
├── providers/       # Estado global con Provider
├── screens/         # Pantallas de la aplicación
├── services/        # Servicios (Firebase, API)
├── utils/           # Utilidades y validadores
└── widgets/         # Componentes reutilizables
```

## 🔧 Configuración adicional

### Configuración de Firebase

La configuración de Firebase se encuentra en `lib/config/firebase_config.dart`. Actualmente:

```dart
static const bool enablePersistence = false; // Temporalmente deshabilitado
```

⚠️ **NO CAMBIAR** a `true` hasta que se solucione el problema de caché.

### Variables de entorno

Crear archivo `.env` en la raíz del proyecto:
```
FIREBASE_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=your_project_id_here
```

### Firebase Rules

Configurar reglas de seguridad en Firestore:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /usuarios/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /productos/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.idVendedor == request.auth.uid);
    }
  }
}
```

## 🧪 Testing

```bash
# Ejecutar pruebas unitarias
flutter test

# Ejecutar pruebas de integración
flutter drive --target=test_driver/app.dart
```

## 📦 Build para producción

### Android
```bash
flutter build apk --release
# o para App Bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🐛 Problemas conocidos y soluciones

### Problema crítico actual

**Síntomas**:
1. Error "Servicio no disponible" al iniciar sesión con usuarios existentes
2. Solo funciona correctamente con usuarios nuevos
3. La app se queda en pantalla de carga al reiniciar
4. Necesitas borrar datos de la app para que funcione

**Solución temporal**: Persistencia de Firestore deshabilitada

**Trabajo en progreso**: Investigando la causa raíz del problema de caché

### Configuración de logos

🍍 **Sistema de logos implementado**:
- **Logo principal** (`logo.png`): Usado para iconos de escritorio y splash screen
- **Logo secundario** (`logo2.png`): Usado en UI interna (AppBar, placeholder, perfil)

Para aplicar los cambios de logos, ejecuta:
```bash
# Windows
generate_app_assets.bat

# Linux/Mac  
./generate_app_assets.sh
```

Ver [APLICAR_CAMBIOS_LOGOS.md](./APLICAR_CAMBIOS_LOGOS.md) para instrucciones detalladas.

### Otros problemas

1. **Firebase no inicializado**: Verificar que los archivos de configuración estén en las ubicaciones correctas
2. **Permisos de Android**: Agregar permisos necesarios en `android/app/src/main/AndroidManifest.xml`

## 🤝 Contribuir

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -am 'Agregar nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Crear un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👥 Equipo

- **Desarrollo**: [Tu nombre]
- **Diseño**: [Nombre del diseñador]
- **Producto**: [Nombre del product manager]

## 📞 Contacto

Para preguntas o sugerencias:
- Email: [tu-email@ejemplo.com]
- GitHub: [tu-usuario-github]

---

**PiñaApp** - Conectando el campo con el mercado 🍍

*Versión actual: 1.0.5 (con solución temporal para problemas de caché)*
