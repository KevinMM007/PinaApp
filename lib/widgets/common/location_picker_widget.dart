import 'package:flutter/material.dart';
import 'package:pina_app/screens/location/location_picker_screen.dart';

class LocationPickerWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String hintText;
  final String? initialAddress;
  final Function(double latitude, double longitude, String address) onLocationSelected;

  const LocationPickerWidget({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.hintText = 'Selecciona tu ubicación',
    this.initialAddress,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _LocationPickerWidgetState createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late TextEditingController _locationController;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.initialAddress ?? '');
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
          initialAddress: _locationController.text,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result['latitud'];
        _longitude = result['longitud'];
        _locationController.text = result['direccion'];
      });
      
      widget.onLocationSelected(
        result['latitud'],
        result['longitud'],
        result['direccion'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _locationController,
          readOnly: true,
          onTap: _openLocationPicker,
          decoration: InputDecoration(
            labelText: 'Ubicación',
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor selecciona una ubicación';
            }
            return null;
          },
        ),
        if (_latitude != null && _longitude != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Coordenadas: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}
