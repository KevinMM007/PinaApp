# Configuración de Google Maps para PiñaApp

## Requisitos
Para usar Google Maps en la aplicación, necesitas:

1. **Una API Key de Google Maps Platform**
2. **Habilitar las siguientes APIs en Google Cloud Console:**
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API (opcional, para búsqueda de lugares)

## Pasos para obtener la API Key

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Ve a "APIs y servicios" > "Credenciales"
4. Crea una nueva API Key
5. Restringe la API Key para mayor seguridad:
   - Para Android: Agrega el SHA-1 de tu aplicación
   - Para iOS: Agrega el Bundle ID de tu aplicación

## Configuración en la aplicación

### Android
1. Abre `android/app/src/main/AndroidManifest.xml`
2. Reemplaza `YOUR_GOOGLE_MAPS_API_KEY_HERE` con tu API Key real:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI"/>
```

### iOS
1. Abre `ios/Runner/AppDelegate.swift`
2. Agrega el import y la configuración:
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("TU_API_KEY_AQUI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

3. En `ios/Runner/Info.plist`, agrega los permisos de ubicación:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>PiñaApp necesita acceso a tu ubicación para mostrar productores y compradores cercanos</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>PiñaApp necesita acceso a tu ubicación para mostrar productores y compradores cercanos</string>
```

## Permisos adicionales

### Android
Los permisos ya están configurados en el AndroidManifest.xml:
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- CAMERA
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE

### iOS
En `ios/Runner/Info.plist`, agrega también:
```xml
<key>NSCameraUsageDescription</key>
<string>PiñaApp necesita acceso a la cámara para tomar fotos de perfil y productos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>PiñaApp necesita acceso a tu galería para seleccionar fotos de perfil y productos</string>
```

## Pruebas

Para probar la funcionalidad:
1. Ejecuta `flutter clean`
2. Ejecuta `flutter pub get`
3. Para Android: `flutter run`
4. Para iOS: `cd ios && pod install && cd .. && flutter run`

## Notas importantes

- **Seguridad**: Nunca subas tu API Key a un repositorio público
- **Restricciones**: Siempre restringe tu API Key a las aplicaciones específicas
- **Cuotas**: Google Maps tiene límites gratuitos, pero cobra por uso excesivo
- **Testing**: Usa una API Key de desarrollo diferente para pruebas

## Alternativas gratuitas

Si no quieres usar Google Maps, puedes considerar:
- OpenStreetMap con el paquete `flutter_map`
- Mapbox con el paquete `mapbox_gl`

Ambas opciones son gratuitas hasta cierto límite de uso.
