import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  const LocationPickerScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  }) : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;
  List<Marker> _markers = [];

  // Ubicación por defecto (México)
  static const LatLng _defaultLocation = LatLng(19.4326, -99.1332);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _selectedAddress = widget.initialAddress ?? '';
      _updateMarker(_selectedLocation!);
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar permisos
      final status = await Permission.location.request();
      
      if (status.isGranted) {
        // Obtener ubicación actual
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        LatLng currentLocation = LatLng(position.latitude, position.longitude);
        
        // Mover el mapa a la ubicación actual
        _mapController.move(currentLocation, 15);
        
        // Actualizar marcador y dirección
        await _onLocationSelected(currentLocation);
      } else {
        // Si no hay permisos, usar ubicación por defecto
        _selectedLocation = _defaultLocation;
        _updateMarker(_defaultLocation);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de ubicación denegado. Selecciona tu ubicación manualmente.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      // Usar ubicación por defecto en caso de error
      _selectedLocation = _defaultLocation;
      _updateMarker(_defaultLocation);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onLocationSelected(LatLng location) async {
    setState(() {
      _isLoading = true;
      _selectedLocation = location;
    });

    _updateMarker(location);

    try {
      // Obtener dirección usando Nominatim (servicio gratuito de OpenStreetMap)
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1',
        ),
        headers: {
          'User-Agent': 'PinaApp/1.0', // Requerido por Nominatim
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        
        // Construir dirección
        List<String> addressParts = [];
        
        if (address['road'] != null) {
          addressParts.add(address['road']);
        }
        if (address['suburb'] != null) {
          addressParts.add(address['suburb']);
        } else if (address['neighbourhood'] != null) {
          addressParts.add(address['neighbourhood']);
        }
        if (address['city'] != null) {
          addressParts.add(address['city']);
        } else if (address['town'] != null) {
          addressParts.add(address['town']);
        } else if (address['municipality'] != null) {
          addressParts.add(address['municipality']);
        }
        if (address['state'] != null) {
          addressParts.add(address['state']);
        }
        if (address['country'] != null) {
          addressParts.add(address['country']);
        }
        
        setState(() {
          _selectedAddress = addressParts.join(', ');
        });
      } else {
        throw Exception('Error obteniendo dirección');
      }
    } catch (e) {
      print('Error obteniendo dirección: $e');
      setState(() {
        _selectedAddress = 'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMarker(LatLng location) {
    setState(() {
      _markers = [
        Marker(
          point: location,
          width: 80,
          height: 80,
          child: Icon(
            Icons.location_pin,
            color: Theme.of(context).primaryColor,
            size: 40,
          ),
        ),
      ];
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'latitud': _selectedLocation!.latitude,
        'longitud': _selectedLocation!.longitude,
        'direccion': _selectedAddress,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una ubicación'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ?? _defaultLocation,
              initialZoom: 12,
              onTap: (tapPosition, latLng) => _onLocationSelected(latLng),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.pina_app',
                // Opcional: puedes agregar atribución
                additionalOptions: const {
                  'attribution': '© OpenStreetMap contributors',
                },
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          
          // Panel inferior con información
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubicación seleccionada:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (_selectedAddress.isNotEmpty)
                    Text(
                      _selectedAddress,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    const Text(
                      'Toca el mapa para seleccionar una ubicación',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedLocation != null ? _confirmLocation : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Confirmar Ubicación'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          
          // Atribución de OpenStreetMap (requerida por sus términos)
          const Positioned(
            right: 10,
            bottom: 140,
            child: Text(
              '© OpenStreetMap',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black54,
                backgroundColor: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
