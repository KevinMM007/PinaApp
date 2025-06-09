import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/models/producto.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/product_provider.dart';
import 'package:pina_app/utils/validators.dart';
import 'package:pina_app/widgets/common/custom_button.dart';
import 'package:pina_app/widgets/common/custom_text_field.dart';
import 'package:pina_app/widgets/common/location_picker_widget.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();
  
  String _variedad = AppConstants.variedadesPina[0];
  String _calidad = 'Estándar';
  String _unidadPrecio = 'kg';
  String _ubicacionTexto = '';
  double? _latitud;
  double? _longitud;
  
  final List<String> _calidades = ['Premium', 'Estándar', 'Segunda'];
  final List<String> _unidades = ['kg', 'tonelada', 'pieza'];
  
  // Lista dinámica para fotos
  final List<String> _fotos = [];

  /// Método helper para manejar imágenes placeholder
  List<String> _getPhotosForProduct() {
    if (_fotos.isEmpty) {
      // Usar una imagen placeholder válida
      return ['https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Piña'];
    }
    return _fotos;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (_formKey.currentState!.validate() && _ubicacionTexto.isNotEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      final producto = Producto(
        idVendedor: authProvider.user!.uid,
        titulo: _tituloController.text.trim(),
        variedad: _variedad,
        descripcion: _descripcionController.text.trim(),
        precio: double.parse(_precioController.text),
        unidadPrecio: _unidadPrecio,
        cantidadDisponible: double.parse(_cantidadController.text),
        calidad: _calidad,
        fotos: _getPhotosForProduct(), // Usar el método helper
        ubicacion: _ubicacionTexto,
        latitud: _latitud,
        longitud: _longitud,
        fechaPublicacion: DateTime.now(),
      );
      
      final success = await productProvider.agregarProducto(producto);
      
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto añadido correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(productProvider.error)),
        );
      }
    } else if (_ubicacionTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una ubicación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: 'Título',
              hint: 'Ej: Piña MD2 fresca de temporada',
              controller: _tituloController,
              validator: (value) => Validators.validateRequired(value, 'el título'),
            ),
            const SizedBox(height: 16),
            
            // Variedad
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Variedad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _variedad,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      borderRadius: BorderRadius.circular(8),
                      items: AppConstants.variedadesPina.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _variedad = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Descripción',
              hint: 'Describe las características de tu producto',
              controller: _descripcionController,
              keyboardType: TextInputType.multiline,
              validator: Validators.validateDescription,
            ),
            const SizedBox(height: 16),
            
            // Precio y unidad
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Precio',
                    hint: 'Ej: 15.50',
                    controller: _precioController,
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.validatePositiveNumber(value, 'el precio'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unidad',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _unidadPrecio,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            borderRadius: BorderRadius.circular(8),
                            items: _unidades.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _unidadPrecio = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Cantidad disponible',
              hint: 'Ej: 1000',
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validatePositiveNumber(value, 'la cantidad'),
            ),
            const SizedBox(height: 16),
            
            // Calidad
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calidad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _calidad,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      borderRadius: BorderRadius.circular(8),
                      items: _calidades.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _calidad = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Ubicación con selector de mapa
            LocationPickerWidget(
              hintText: 'Selecciona la ubicación de tu finca o almacén',
              onLocationSelected: (latitude, longitude, address) {
                setState(() {
                  _latitud = latitude;
                  _longitud = longitude;
                  _ubicacionTexto = address;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Sección de imágenes mejorada
            _buildImageSection(),
            const SizedBox(height: 32),
            
            CustomButton(
              text: 'Guardar Producto',
              isLoading: productProvider.isLoading,
              onPressed: _guardarProducto,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la sección de imágenes mejorada
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imágenes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, 
                     color: Colors.grey[600], 
                     size: 32),
                const SizedBox(height: 8),
                Text(
                  'Funcionalidad de imágenes\npronto disponible',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}