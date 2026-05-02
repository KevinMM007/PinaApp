# 🍍 PiñaApp

> **Marketplace móvil multiplataforma** que conecta directamente a **productores, compradores y transportistas** de piña, eliminando intermediarios y promoviendo el comercio justo. Construida con Flutter y Firebase, con sistema de chat, ofertas, calificaciones, mapas y filtros avanzados.

<p>
  <img src="https://img.shields.io/badge/version-1.3-blue" alt="Version"/>
  <img src="https://img.shields.io/badge/Flutter-3.10%2B-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Provider-state-purple" alt="Provider"/>
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-blue" alt="Platforms"/>
</p>

> ⚠️ **Branch principal de desarrollo:** `Codigo-actualizado` (es la versión 1.3 con chats y sistema de ofertas).

---

## 📖 Acerca del proyecto

PiñaApp es una plataforma diseñada para el ecosistema productivo de la piña en México. Permite que tres actores clave del sector se conecten de forma directa:

| Rol | Acciones principales |
|---|---|
| 🌱 **Productor** | Publica productos (lotes de piña) con fotos, calidad, variedad, precio y ubicación. Recibe ofertas y se comunica con compradores. |
| 🛒 **Comprador** | Explora el marketplace, marca favoritos, hace ofertas, publica necesidades de compra y chatea con productores. |
| 🚚 **Transportista** | Ofrece servicios de logística para mover producto entre productor y comprador. |

Todo se construye sobre **Firebase** (Auth + Firestore + Storage), con un cliente Flutter que corre en **6 plataformas**: Android, iOS, Web, Windows, macOS y Linux.

---

## ✨ Características principales

### 🔐 Autenticación y perfiles
- Registro / login con email y contraseña (Firebase Auth).
- **Verificación de email** obligatoria.
- Recuperación de contraseña.
- **3 tipos de perfil** con campos específicos: Productor (nombre de finca, hectáreas), Comprador (empresa, volumen mensual), Transportista (empresa, vehículos).
- Foto de perfil con subida a Firebase Storage.
- Sistema de **verificación** de usuarios.

### 🛍️ Marketplace
- Listado de **productos** publicados por productores (variedad, calidad, precio, cantidad disponible, fotos múltiples).
- Listado de **"Necesidades de compra"** publicadas por compradores.
- Vista de detalle del producto con galería de fotos.
- **Favoritos** persistentes por usuario.
- **Filtros avanzados** (variedad, calidad, ubicación, precio).

### 💬 Comunicación entre usuarios
- **Chat 1:1** en tiempo real entre productores y compradores (Firestore streams).
- Lista de conversaciones con preview del último mensaje.
- Conversaciones vinculadas opcionalmente a un producto específico.

### 💰 Sistema de ofertas
- Los compradores pueden **enviar ofertas** sobre un producto (precio, cantidad, mensaje).
- El productor recibe **notificaciones** y puede aceptar / rechazar / contraofertar.
- Estados de oferta: `pendiente`, `aceptada`, `rechazada`, `contraoferta`.

### ⭐ Sistema de calificaciones
- Calificación entre usuarios después de transacciones.
- **Calificación promedio** visible en cada perfil.
- Contador de transacciones completadas.

### 🗺️ Geolocalización y mapas
- Selector de ubicación con **flutter_map** (OpenStreetMap).
- Geolocalización del dispositivo (`geolocator`).
- Geocoding inverso para mostrar nombre de la zona.
- Permisos manejados con `permission_handler`.

### 🎨 UI / UX
- Theme propio con **paleta inspirada en la piña** (verdes vibrantes + dorados cálidos).
- Splash screen nativo (`flutter_native_splash`) configurado para Android, iOS y Web.
- Iconos de app generados para las 6 plataformas (`flutter_launcher_icons`).
- Componentes reutilizables (botones animados, cards, image pickers, location pickers).
- Diseño responsive para tablets y desktop.

### ⚙️ Robustez y producción
- Manejo de timeouts en inicialización con pantalla de error y reintento.
- **Reglas de seguridad** definidas para Firestore y Storage (incluidas en el repo).
- Validadores propios (email, teléfono, contraseña).
- Cache manager interno.
- Utilidades de diagnóstico de Firebase.

---

## 🧱 Arquitectura

```
┌────────────────────────────────────────────────────────────────┐
│                    APP FLUTTER (Multiplataforma)                │
│                                                                 │
│   main.dart  →  AuthWrapper  →  HomeScreen / LoginScreen        │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    PROVIDERS (Provider)                  │   │
│   │  AuthProvider · ProductProvider                          │   │
│   │  FavoritesProvider · NecesidadesProvider                 │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    SCREENS (UI)                          │   │
│   │  auth/  marketplace/  profile/  transactions/            │   │
│   │  location/  legal/  help/  splash/                       │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    SERVICES (lógica)                     │   │
│   │  AuthService     ChatService     OfferService            │   │
│   │  DatabaseService LocationService RatingService           │   │
│   │  StorageService  UserSyncService DiagnosticService       │   │
│   └─────────────────────────────────────────────────────────┘   │
└────────────────────────────────┬───────────────────────────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────┐
│                  FIREBASE (Backend serverless)                  │
│                                                                 │
│   🔐 Authentication     ☁️ Cloud Firestore     📦 Storage       │
│                                                                 │
│   Colecciones: usuarios · productos · productores ·             │
│   compradores · transportistas · conversaciones · mensajes ·    │
│   ofertas · calificaciones · favoritos · necesidades            │
│                                                                 │
│   Storage: /perfiles/  /productos/  (max 5 MB, solo imágenes)   │
│                                                                 │
│   Security Rules en firestore.rules y storage.rules             │
└────────────────────────────────┬───────────────────────────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────┐
│                    SERVICIOS EXTERNOS                           │
│   🗺️ OpenStreetMap (flutter_map)                                │
│   📍 Geocoding APIs (geocoding package)                         │
└────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Stack tecnológico

### Cliente (Flutter)
| Categoría | Tecnología |
|---|---|
| **Framework** | Flutter ≥ 3.10 |
| **Lenguaje** | Dart ≥ 3.0 |
| **State management** | Provider 6 |
| **Mapas** | flutter_map 6 + latlong2 |
| **Geolocalización** | geolocator 11 + geocoding 3 + permission_handler 11 |
| **Imágenes** | image_picker 1 |
| **Persistencia local** | shared_preferences 2 |
| **HTTP** | http 1 |
| **Internacionalización** | intl 0.19 |
| **Otros** | url_launcher 6 |

### Backend (Firebase)
| Servicio | Uso |
|---|---|
| **Firebase Authentication** | Login, registro, verificación de email |
| **Cloud Firestore** | Base de datos NoSQL (usuarios, productos, ofertas, chats…) |
| **Firebase Storage** | Fotos de perfil y de productos (límite 5 MB) |

### Build / DevOps
- `flutter_launcher_icons` — iconos para las 6 plataformas
- `flutter_native_splash` — splash screen nativo
- `flutter_lints` — análisis estático

---

## 📊 Modelo de datos

El sistema maneja **15 modelos** en `lib/models/`:

| Modelo | Descripción |
|---|---|
| `Usuario` | Datos base + rol + perfil específico (productor / comprador / transportista) |
| `PerfilProductor` | Nombre de finca, hectáreas, variedades cultivadas |
| `PerfilComprador` | Nombre de empresa, volumen de compra mensual |
| `PerfilTransportista` | Nombre de empresa, vehículos, capacidad |
| `Producto` | Lote de piña en venta (variedad, calidad, precio, fotos, ubicación) |
| `NecesidadCompra` | Demanda publicada por un comprador |
| `Oferta` | Propuesta económica de un comprador a un producto |
| `Mensaje` | Mensaje individual de chat |
| `Calificacion` | Rating entre usuarios post-transacción |
| `Transaccion` | Registro de transacción cerrada |
| `Favorito` | Producto marcado como favorito por un usuario |

---

## 🚀 Instalación

### Requisitos previos

- Flutter SDK ≥ 3.10
- Dart SDK ≥ 3.0
- Android Studio o VS Code con plugins de Flutter
- Cuenta de **Firebase** (gratis) con un proyecto creado
- Para iOS: macOS con Xcode
- Para Android: Android SDK con SDK mínimo API 21

### 1. Clonar el repositorio

```bash
git clone -b Codigo-actualizado https://github.com/KevinMM007/PinaApp.git
cd PinaApp
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

Crea un proyecto en [Firebase Console](https://console.firebase.google.com/) y habilita:

- **Authentication** → Email/Password
- **Cloud Firestore** → Modo producción
- **Storage** → Modo producción

Descarga los archivos de configuración:

```
android/app/google-services.json          ← App Android de Firebase
ios/Runner/GoogleService-Info.plist       ← App iOS de Firebase
```

### 4. Aplicar las reglas de seguridad

El repositorio incluye las reglas listas en la raíz:

```bash
# Firestore Rules
firebase deploy --only firestore:rules

# Storage Rules
firebase deploy --only storage:rules
```

> 📁 Las reglas están en `firestore.rules` y `storage.rules`.

### 5. Generar iconos y splash screen

El proyecto incluye scripts para regenerar los assets visuales:

```bash
# Windows
generate_app_assets.bat

# Linux / macOS
chmod +x generate_app_assets.sh
./generate_app_assets.sh
```

O manualmente:

```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

### 6. Ejecutar

```bash
# En el dispositivo / emulador conectado
flutter run

# Plataforma específica
flutter run -d chrome      # Web
flutter run -d windows     # Windows
flutter run -d macos       # macOS
```

---

## 📦 Build para producción

### Android

```bash
# APK
flutter build apk --release

# App Bundle (para Google Play)
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
# Luego abrir ios/Runner.xcworkspace en Xcode para archivar
```

### Web

```bash
flutter build web --release
# Output en build/web/
```

### Windows / macOS / Linux

```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

---

## 📂 Estructura del proyecto

```
PinaApp/
├── lib/
│   ├── main.dart                    # Entry point + AuthWrapper
│   │
│   ├── config/
│   │   ├── constants.dart
│   │   ├── firebase_config.dart     # Configuración centralizada de Firebase
│   │   └── theme.dart               # Theme con paleta "piña" (verdes + dorados)
│   │
│   ├── models/                      # 15 modelos de dominio
│   │   ├── usuario.dart
│   │   ├── perfil_productor.dart
│   │   ├── perfil_comprador.dart
│   │   ├── perfil_transportista.dart
│   │   ├── producto.dart
│   │   ├── necesidad_compra.dart
│   │   ├── oferta.dart
│   │   ├── mensaje.dart
│   │   ├── calificacion.dart
│   │   ├── transaccion.dart
│   │   └── favorito.dart
│   │
│   ├── providers/                   # Estado global con Provider
│   │   ├── auth_provider.dart
│   │   ├── product_provider.dart
│   │   ├── favorites_provider.dart
│   │   └── necesidades_provider.dart
│   │
│   ├── services/                    # Lógica de negocio + Firebase
│   │   ├── auth_service.dart
│   │   ├── database_service.dart
│   │   ├── storage_service.dart
│   │   ├── chat_service.dart
│   │   ├── offer_service.dart
│   │   ├── rating_service.dart
│   │   ├── location_service.dart
│   │   ├── user_sync_service.dart
│   │   └── diagnostic_service.dart
│   │
│   ├── screens/                     # ~30 pantallas
│   │   ├── auth/                    # login, register, forgot password, email verification
│   │   ├── marketplace/             # marketplace, product detail, add product, necesidades, favorites
│   │   ├── profile/                 # profile, edit por rol, settings
│   │   ├── transactions/            # chat, conversations, offer, rating
│   │   ├── location/                # location picker
│   │   ├── legal/                   # privacy, terms
│   │   ├── help/                    # help screen
│   │   ├── info/                    # terms and conditions
│   │   ├── splash/                  # splash screen
│   │   └── home_screen.dart
│   │
│   ├── widgets/                     # Componentes reutilizables
│   │   ├── common/                  # botones, text fields, image picker, location picker, spinners
│   │   ├── product/                 # product card, favorite button
│   │   ├── marketplace/             # advanced filters dialog, necesidad card
│   │   ├── profile/                 # cards y editores por rol
│   │   ├── user/                    # rating summary
│   │   └── debug/                   # widgets de diagnóstico
│   │
│   └── utils/                       # cache, validators, page transitions, debug Firebase
│
├── assets/
│   ├── images/                      # logos, fondo, ilustraciones
│   └── icons/
│
├── firestore.rules                  # Security rules de Firestore
├── storage.rules                    # Security rules de Storage
├── pubspec.yaml
├── android/  ios/  web/  windows/  macos/  linux/    # Configs por plataforma
└── README.md
```

---

## 🔐 Seguridad

El repositorio incluye reglas de seguridad para Firestore y Storage:

- **Firestore (`firestore.rules`):** los usuarios solo pueden leer/escribir su propio perfil; los productos solo los puede crear quien tenga rol "productor"; las actualizaciones de un producto solo las puede hacer su dueño.
- **Storage (`storage.rules`):** las fotos de perfil deben incluir el `uid` del usuario en el nombre; todas las imágenes tienen un límite de **5 MB** y deben ser de tipo `image/*`.

---

## 🧪 Testing

```bash
# Tests unitarios
flutter test

# Test de un archivo específico
flutter test test/widget_test.dart
```

---

## 🛣️ Roadmap

- [x] Autenticación completa con verificación de email
- [x] 3 tipos de perfil (productor / comprador / transportista)
- [x] Marketplace de productos y necesidades de compra
- [x] Sistema de favoritos persistente
- [x] Filtros avanzados de búsqueda
- [x] Selector de ubicación con mapa (OpenStreetMap)
- [x] Chat 1:1 entre usuarios
- [x] Sistema de ofertas con notificaciones
- [x] Sistema de calificaciones entre usuarios
- [x] Multiplataforma (Android, iOS, Web, Windows, macOS, Linux)
- [x] Reglas de seguridad de Firestore y Storage
- [ ] Notificaciones push con Firebase Cloud Messaging
- [ ] Pasarela de pago integrada
- [ ] Tracking de envíos para transportistas
- [ ] Modo offline completo
- [ ] Tests de integración (flutter_driver)
- [ ] CI/CD con GitHub Actions (build APK + tests)

---

## 📊 Estadísticas del proyecto

- 📦 **83 archivos Dart**
- 📝 **~26 500 líneas de código**
- 🖥️ **6 plataformas soportadas**
- 🧩 **15 modelos · 4 providers · 9 services · ~30 screens · ~25 widgets**

---

## 👤 Autor

**Kevin Morales** — Ingeniero en Sistemas Computacionales (Esp. Ingeniería de Software)

- 💼 [LinkedIn](https://www.linkedin.com/in/kevin-morales-625604173/)
- 📧 moralesmonterok@gmail.com
- 🐙 [@KevinMM007](https://github.com/KevinMM007)
- 📍 Veracruz, México

---

## 📄 Licencia

Este proyecto está bajo la **Licencia MIT**.

> 🍍 **PiñaApp** — Conectando el campo con el mercado.
