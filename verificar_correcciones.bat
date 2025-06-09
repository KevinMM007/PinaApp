@echo off
echo ====================================
echo Verificando correcciones aplicadas
echo ====================================

cd C:\Users\moral\Documents\PinaApp

echo.
echo [1/3] Verificando archivos modificados...
echo.

echo Verificando ProductProvider...
findstr /C:"showLoading: false" lib\providers\product_provider.dart >nul
if %errorlevel%==0 (
    echo [OK] ProductProvider corregido - no muestra loading
) else (
    echo [ERROR] ProductProvider necesita correccion
)

echo.
echo Verificando ProductDetailScreen...
findstr /C:"SizedBox.shrink()" lib\screens\marketplace\product_detail_screen.dart >nul
if %errorlevel%==0 (
    echo [OK] ProductDetailScreen corregido - no muestra error al cargar
) else (
    echo [ERROR] ProductDetailScreen necesita correccion
)

echo.
echo Verificando AuthProvider...
findstr /C:"showLoading: false" lib\providers\auth_provider.dart >nul
if %errorlevel%==0 (
    echo [OK] AuthProvider corregido - carga inicial sin loading
) else (
    echo [ERROR] AuthProvider necesita correccion
)

echo.
echo [2/3] Verificando configuracion de Native Splash...
echo.

findstr /C:"background_image: assets/images/fondoDePantalla.png" pubspec.yaml >nul
if %errorlevel%==0 (
    echo [OK] Native Splash configurado correctamente
) else (
    echo [ERROR] Native Splash necesita configuracion
)

echo.
echo [3/3] Estado del proyecto...
echo.

if exist android\app\src\main\res\drawable\splash.png (
    echo [OK] Archivos de splash generados
) else (
    echo [ADVERTENCIA] Necesitas ejecutar: flutter pub run flutter_native_splash:create
)

echo.
echo ====================================
echo Verificacion completada
echo ====================================
echo.
pause
