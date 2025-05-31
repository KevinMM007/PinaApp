# Configuración de Mapas para PiñaApp

## Solución Utilizada: OpenStreetMap (GRATIS)

PiñaApp utiliza **OpenStreetMap** con el paquete `flutter_map`, que es completamente gratuito y no requiere API keys.

### Ventajas de OpenStreetMap:
- ✅ **100% Gratuito** - Sin costos ocultos ni límites de uso
- ✅ **Sin API Keys** - No necesitas registrarte ni obtener claves
- ✅ **Open Source** - Datos abiertos y colaborativos
- ✅ **Funciona Offline** - Puedes cachear mapas para uso sin internet
- ✅ **Personalizable** - Puedes cambiar estilos y agregar capas

### Servicios que utilizamos:

1. **Tiles de Mapa**: OpenStreetMap
2. **Geocoding Reverso**: Nominatim (servicio gratuito de OSM)
3. **Ubicación**: Geolocator (GPS del dispositivo)

## Permisos Necesarios

### Android
En `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS
En `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>PiñaApp necesita acceso a tu ubicación para mostrar productores y compradores cercanos</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>PiñaApp necesita acceso a tu ubicación para mostrar productores y compradores cercanos</string>
```

## Uso en la App

El mapa se utiliza en:
1. **Selección de ubicación del perfil**: Los usuarios pueden seleccionar su ubicación tocando el mapa
2. **Visualización de productos**: (Próximamente) Ver productos en el mapa
3. **Rutas de transporte**: (Próximamente) Ver rutas de transportistas

## Limitaciones de Nominatim

El servicio de geocoding reverso (Nominatim) tiene algunas políticas de uso:
- Máximo 1 solicitud por segundo
- Debe incluir User-Agent en las solicitudes
- No para uso masivo comercial (pero perfecto para nuestra app)

## Alternativas consideradas

| Servicio | Costo | Límite Gratuito | API Key |
|----------|-------|-----------------|---------|
| Google Maps | $$ | 28,000 cargas/mes | Sí |
| Mapbox | $ | 50,000 cargas/mes | Sí |
| OpenStreetMap | GRATIS | Sin límite | No |
| HERE Maps | $ | 250,000 transacciones/mes | Sí |

## Troubleshooting

Si el mapa no carga:
1. Verifica conexión a internet
2. Limpia el caché: `flutter clean`
3. Reinstala dependencias: `flutter pub get`
4. Para iOS: `cd ios && pod install`

## Créditos

Según los términos de OpenStreetMap, debemos mostrar atribución:
```
© OpenStreetMap contributors
```

Esto ya está implementado en el LocationPickerScreen.
