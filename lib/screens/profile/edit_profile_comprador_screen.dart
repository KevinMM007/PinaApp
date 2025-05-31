import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/models/perfil_comprador.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/utils/validators.dart';
import 'package:pina_app/widgets/common/custom_button.dart';
import 'package:pina_app/widgets/common/custom_text_field.dart';

class EditProfileCompradorScreen extends StatefulWidget {
  const EditProfileCompradorScreen({Key? key}) : super(key: key);

  @override
  _EditProfileCompradorScreenState createState() => _EditProfileCompradorScreenState();
}

class _EditProfileCompradorScreenState extends State<EditProfileCompradorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingLocalSave = false; // Estado local de guardado
  
  // Controladores
  late TextEditingController _nombreEmpresaController;
  late TextEditingController _volumenCompraController;
  late TextEditingController _diasCreditoController;
  late TextEditingController _contactoComercialController;
  late TextEditingController _horarioAtencionController;
  late TextEditingController _precioMinController;
  late TextEditingController _precioMaxController;
  
  // Variables de estado
  String _tipoComprador = 'minorista';
  List<String> _variedadesInteres = [];
  List<String> _calidadesPreferidas = [];
  List<String> _ubicacionesEntrega = [];
  String _metodoPago = 'contado';
  List<String> _certificacionesRequeridas = [];
  String _frecuenciaCompra = 'mensual';
  bool _requiereTransporte = false;

  // Opciones disponibles
  final List<String> _tiposComprador = [
    'minorista',
    'mayorista',
    'exportador',
    'procesador'
  ];

  final List<String> _calidadesDisponibles = [
    'Premium',
    'Estándar',
    'Segunda',
    'Procesamiento'
  ];

  final List<String> _metodosPago = [
    'contado',
    'credito',
    'mixto'
  ];

  final List<String> _frecuenciasCompra = [
    'semanal',
    'quincenal',
    'mensual',
    'trimestral'
  ];

  final List<String> _certificacionesDisponibles = [
    'Orgánico',
    'GlobalGAP',
    'Fair Trade',
    'Rainforest Alliance',
    'HACCP',
    'ISO 22000'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final perfil = authProvider.userProfile?.perfilComprador ?? PerfilComprador();
    
    _nombreEmpresaController = TextEditingController(text: perfil.nombreEmpresa);
    _volumenCompraController = TextEditingController(
      text: perfil.volumenCompraMensual.toString()
    );
    _diasCreditoController = TextEditingController(text: perfil.diasCredito.toString());
    _contactoComercialController = TextEditingController(text: perfil.contactoComercial);
    _horarioAtencionController = TextEditingController(text: perfil.horarioAtencion);
    _precioMinController = TextEditingController(
      text: perfil.rangoPrecios['min']?.toString() ?? ''
    );
    _precioMaxController = TextEditingController(
      text: perfil.rangoPrecios['max']?.toString() ?? ''
    );
    
    _tipoComprador = perfil.tipoComprador;
    _variedadesInteres = List.from(perfil.variedadesInteres);
    _calidadesPreferidas = List.from(perfil.calidadesPreferidas);
    _ubicacionesEntrega = List.from(perfil.ubicacionesEntrega);
    _metodoPago = perfil.metodoPago;
    _certificacionesRequeridas = List.from(perfil.certificacionesRequeridas);
    _frecuenciaCompra = perfil.frecuenciaCompra;
    _requiereTransporte = perfil.requiereTransporte;
  }

  @override
  void dispose() {
    _nombreEmpresaController.dispose();
    _volumenCompraController.dispose();
    _diasCreditoController.dispose();
    _contactoComercialController.dispose();
    _horarioAtencionController.dispose();
    _precioMinController.dispose();
    _precioMaxController.dispose();
    super.dispose();
  }

  Future<void> _guardarPerfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingLocalSave = true;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final perfilDatos = {
        'tipoComprador': _tipoComprador,
        'nombreEmpresa': _nombreEmpresaController.text.trim(),
        'volumenCompraMensual': double.tryParse(_volumenCompraController.text) ?? 0.0,
        'variedadesInteres': _variedadesInteres,
        'calidadesPreferidas': _calidadesPreferidas,
        'rangoPrecios': {
          'min': double.tryParse(_precioMinController.text) ?? 0.0,
          'max': double.tryParse(_precioMaxController.text) ?? 0.0,
        },
        'ubicacionesEntrega': _ubicacionesEntrega,
        'metodoPago': _metodoPago,
        'diasCredito': int.tryParse(_diasCreditoController.text) ?? 0,
        'certificacionesRequeridas': _certificacionesRequeridas,
        'frecuenciaCompra': _frecuenciaCompra,
        'requiereTransporte': _requiereTransporte,
        'contactoComercial': _contactoComercialController.text.trim(),
        'horarioAtencion': _horarioAtencionController.text.trim(),
      };

      final success = await authProvider.actualizarPerfilEspecifico(perfilDatos);

      setState(() {
        _isLoadingLocalSave = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil de comprador actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Información de la Empresa
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información de la Empresa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Nombre de la empresa',
                          controller: _nombreEmpresaController,
                          prefixIcon: const Icon(Icons.business),
                          validator: (value) => Validators.validateRequired(value, 'el nombre de la empresa'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Tipo de comprador
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tipo de comprador',
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
                                  value: _tipoComprador,
                                  isExpanded: true,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  items: _tiposComprador.map((String tipo) {
                                    return DropdownMenuItem<String>(
                                      value: tipo,
                                      child: Text(tipo.substring(0, 1).toUpperCase() + tipo.substring(1)),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _tipoComprador = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Contacto comercial',
                          controller: _contactoComercialController,
                          prefixIcon: const Icon(Icons.person_pin),
                          hint: 'Nombre del responsable de compras',
                        ),
                        
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Horario de atención',
                          controller: _horarioAtencionController,
                          prefixIcon: const Icon(Icons.schedule),
                          hint: 'Ej: Lunes a Viernes 8:00-17:00',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Preferencias de Compra
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preferencias de Compra',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Volumen de compra mensual (toneladas)',
                          controller: _volumenCompraController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.scale),
                          validator: (value) => Validators.validatePositiveNumber(value, 'el volumen de compra'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Variedades de interés
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Variedades de interés',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: AppConstants.variedadesPina.map((variedad) {
                                return FilterChip(
                                  label: Text(variedad),
                                  selected: _variedadesInteres.contains(variedad),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _variedadesInteres.add(variedad);
                                      } else {
                                        _variedadesInteres.remove(variedad);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Calidades preferidas
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Calidades preferidas',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _calidadesDisponibles.map((calidad) {
                                return FilterChip(
                                  label: Text(calidad),
                                  selected: _calidadesPreferidas.contains(calidad),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _calidadesPreferidas.add(calidad);
                                      } else {
                                        _calidadesPreferidas.remove(calidad);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Rango de precios
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Precio mínimo (\$/kg)',
                                controller: _precioMinController,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                label: 'Precio máximo (\$/kg)',
                                controller: _precioMaxController,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Frecuencia de compra
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Frecuencia de compra',
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
                                  value: _frecuenciaCompra,
                                  isExpanded: true,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  items: _frecuenciasCompra.map((String frecuencia) {
                                    return DropdownMenuItem<String>(
                                      value: frecuencia,
                                      child: Text(frecuencia.substring(0, 1).toUpperCase() + frecuencia.substring(1)),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _frecuenciaCompra = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Condiciones Comerciales
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Condiciones Comerciales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Método de pago
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Método de pago',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: _metodosPago.map((metodo) {
                                return Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(
                                      metodo.substring(0, 1).toUpperCase() + 
                                      metodo.substring(1),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    value: metodo,
                                    groupValue: _metodoPago,
                                    onChanged: (value) {
                                      setState(() {
                                        _metodoPago = value!;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        
                        if (_metodoPago == 'credito' || _metodoPago == 'mixto') ...[
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Días de crédito',
                            controller: _diasCreditoController,
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.calendar_today),
                            validator: (value) => Validators.validatePositiveNumber(value, 'los días de crédito'),
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Certificaciones requeridas
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Certificaciones requeridas',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _certificacionesDisponibles.map((certificacion) {
                                return FilterChip(
                                  label: Text(certificacion),
                                  selected: _certificacionesRequeridas.contains(certificacion),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _certificacionesRequeridas.add(certificacion);
                                      } else {
                                        _certificacionesRequeridas.remove(certificacion);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        SwitchListTile(
                          title: const Text('Requiere servicio de transporte'),
                          subtitle: const Text('¿Necesitas que el productor incluya transporte?'),
                          value: _requiereTransporte,
                          onChanged: (value) {
                            setState(() {
                              _requiereTransporte = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                CustomButton(
                  text: 'Guardar Perfil de Comprador',
                  onPressed: _guardarPerfil,
                  isLoading: _isLoadingLocalSave, // Usar estado local
                  width: double.infinity,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
