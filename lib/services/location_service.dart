import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Verificar y solicitar permisos de ubicación
  Future<bool> solicitarPermisos() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Los permisos están permanentemente denegados
      return false;
    }
    
    return true;
  }
  
  // Obtener ubicación actual
  Future<Position?> obtenerUbicacionActual() async {
    try {
      final bool tienePermisos = await solicitarPermisos();
      if (!tienePermisos) {
        return null;
      }
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }
  
  // Obtener dirección desde coordenadas
  Future<Map<String, dynamic>?> obtenerDireccionDesdeCoordernadas({
    required double latitud,
    required double longitud,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitud,
        longitud,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        return {
          'direccion': _construirDireccion(place),
          'ciudad': place.locality ?? '',
          'estado': place.administrativeArea ?? '',
          'pais': place.country ?? '',
          'codigoPostal': place.postalCode ?? '',
          'direccionCompleta': _construirDireccionCompleta(place),
          'placemark': place,
        };
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo dirección: $e');
      return null;
    }
  }
  
  // Obtener coordenadas desde dirección
  Future<Map<String, double>?> obtenerCoordenadasDesdeDireccion(String direccion) async {
    try {
      List<Location> locations = await locationFromAddress(direccion);
      
      if (locations.isNotEmpty) {
        return {
          'latitud': locations[0].latitude,
          'longitud': locations[0].longitude,
        };
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo coordenadas: $e');
      return null;
    }
  }
  
  // Calcular distancia entre dos puntos
  double calcularDistancia({
    required double latitud1,
    required double longitud1,
    required double latitud2,
    required double longitud2,
  }) {
    return Geolocator.distanceBetween(
      latitud1,
      longitud1,
      latitud2,
      longitud2,
    );
  }
  
  // Construir dirección legible
  String _construirDireccion(Placemark place) {
    List<String> partes = [];
    
    if (place.street != null && place.street!.isNotEmpty) {
      partes.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      partes.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      partes.add(place.locality!);
    }
    
    return partes.join(', ');
  }
  
  // Construir dirección completa
  String _construirDireccionCompleta(Placemark place) {
    List<String> partes = [];
    
    if (place.street != null && place.street!.isNotEmpty) {
      partes.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      partes.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      partes.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      partes.add(place.administrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      partes.add(place.country!);
    }
    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      partes.add(place.postalCode!);
    }
    
    return partes.join(', ');
  }
  
  // Abrir configuración de la app para permisos
  Future<void> abrirConfiguracionApp() async {
    await openAppSettings();
  }
  
  // Verificar si los permisos están permanentemente denegados
  Future<bool> permisosPermantementeDenegados() async {
    final status = await Permission.location.status;
    return status.isPermanentlyDenied;
  }
}
