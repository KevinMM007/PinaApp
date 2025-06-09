# Solución para Error de Splash Screen

## Error
```
ERROR: C:\Users\moral\Documents\PinaApp\android\app\src\main\res\drawable-night-v21\launch_background.xml:10: AAPT: error: resource drawable/branding (aka com.example.pina_app:drawable/branding) not found.
```

## Solución Rápida

1. **Limpia y regenera el splash screen:**
```bash
flutter clean
flutter pub run flutter_native_splash:remove
flutter pub run flutter_native_splash:create
flutter pub get
flutter run
```

## Solución Manual (si persiste el error)

1. Navega a: `C:\Users\moral\Documents\PinaApp\android\app\src\main\res\`

2. En las siguientes carpetas, edita el archivo `launch_background.xml`:
   - `drawable/`
   - `drawable-v21/`
   - `drawable-night-v21/` (si existe)

3. Busca y elimina estas líneas (si existen):
```xml
<item>
    <bitmap android:gravity="center" android:src="@drawable/branding" />
</item>
```

4. El archivo debe quedar así:
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item>
        <bitmap android:gravity="fill" android:src="@drawable/background"/>
    </item>
    <item>
        <bitmap android:gravity="center" android:src="@drawable/splash"/>
    </item>
</layer-list>
```

5. Ejecuta nuevamente:
```bash
flutter clean
flutter pub get
flutter run
```

## Alternativa: Splash Simple

Si los problemas persisten, puedes usar un splash simple sin imagen de fondo:

En `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#4CAF50"  # Verde sólido
  image: assets/images/logo.png
  android_12:
    color: "#4CAF50"
    image: assets/images/logo.png
  web: false
```

Luego ejecuta:
```bash
flutter pub run flutter_native_splash:create
flutter run
```
