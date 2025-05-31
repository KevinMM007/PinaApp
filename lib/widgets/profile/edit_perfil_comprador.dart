import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/models/usuario.dart';
import 'package:pina_app/models/perfil_comprador.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/utils/validators.dart';
import 'package:pina_app/widgets/common/custom_button.dart';
import 'package:pina_app/widgets/common/custom_text_field.dart';

class EditPerfilComprador extends StatefulWidget {
  final Usuario usuario;

  const EditPerfilComprador({
    Key? key,
    required this.usuario,
  }) : super(key: key);

  @override
  _EditPerfilCompradorState createState() => _EditPerfilCompradorState();
}

class _EditPerfilCompradorState extends State<EditPerfilComprador> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _nombreEmpresaController = TextEditingController();
  final _volumenCompraController = TextEditingController();
  final _contactoComercialController = TextEditingController();
  final _horarioAtencionController = TextEditingController();
  final _diasCreditoController = TextEditingController();
  
  // Listas y selecciones
  String _tipoComprador = 'minorista';
  String _metodoPago = 'contado';
  String _frecuenciaCompra = 'mensual';
  List<String> _variedadesInteres = [];
  List<String> _calidadesPreferidas = [];
  List<String> _certificacionesRequeridas = [];
  bool _requiereTransporte = false;
  
  final List<String> _tiposComprador = [
    'minorista',
    'mayorista', 
    'exportador',
    'procesador',
  ];
  
  final List<String> _metodosPago = [
    'contado',
    'credito',
    'mixto',
  ];
  
  final List<String> _frecuenciasCompra = [
    'semanal',
    'quincenal',
    'mensual',
    'trimestral',
  ];
  
  final List<String> _calidades = [
    'Premium',
    'Primera',
    'Segunda',
    'Estándar',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final perfil = widget.usuario.perfilComprador ?? PerfilComprador();
    
    _nombreEmpresaController.text = perfil.nombreEmpresa;
    _volumenCompraController.text = perfil.volumenCompraMensual > 0 
        ? perfil.volumenCompraMensual.toString() : '';
    _contactoComercialController.text = perfil.contactoComercial;
    _horarioAtencionController.text = perfil.horarioAtencion;
    _diasCreditoController.text = perfil.diasCredito > 0 
        ? perfil.diasCredito.toString() : '';
    
    _tipoComprador = perfil.tipoComprador.isNotEmpty ? perfil.tipoComprador : 'minorista';
    _metodoPago = perfil.metodoPago.isNotEmpty ? perfil.metodoPago : 'contado';
    _frecuenciaCompra = perfil.frecuenciaCompra.isNotEmpty ? perfil.frecuenciaCompra : 'mensual';
    _variedadesInteres = List.from(perfil.variedadesInteres);
    _calidadesPreferidas = List.from(perfil.calidadesPreferidas);
    _certificacionesRequeridas = List.from(perfil.certificacionesRequeridas);
    _requiereTransporte = perfil.requiereTransporte;
  }

  @override
  void dispose() {
    _nombreEmpresaController.dispose();
    _volumenCompraController.dispose();
    _contactoComercialController.dispose();
    _horarioAtencionController.dispose();
    _diasCreditoController.dispose();
    super.dispose();
  }

  Future<void> _guardarPerfil() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final perfilActualizado = PerfilComprador(
        tipoComprador: _tipoComprador,
        nombreEmpresa: _nombreEmpresaController.text.trim(),
        volumenCompraMensual: double.tryParse(_volumenCompraController.text) ?? 0.0,
        variedadesInteres: _variedadesInteres,
        calidadesPreferidas: _calidadesPreferidas,
        metodoPago: _metodoPago,
        diasCredito: int.tryParse(_diasCreditoController.text) ?? 0,
        certificacionesRequeridas: _certificacionesRequeridas,
        frecuenciaCompra: _frecuenciaCompra,
        requiereTransporte: _requiereTransporte,
        contactoComercial: _contactoComercialController.text.trim(),
        horarioAtencion: _horarioAtencionController.text.trim(),
      );

      final success = await authProvider.actualizarPerfilEspecifico(
        perfilActualizado.toMap(),
      );

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
                _buildEmpresaInfoSection(),
                const SizedBox(height: 24),
                _buildComprasSection(),
                const SizedBox(height: 24),
                _buildPreferenciasSection(),
                const SizedBox(height: 24),
                _buildPagosSection(),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Guardar Perfil de Comprador',
                  onPressed: _guardarPerfil,
                  isLoading: authProvider.isLoading,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpresaInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la Empresa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Nombre de la empresa',
              controller: _nombreEmpresaController,
              validator: (value) => Validators.validateRequired(value, 'el nombre de la empresa'),
              prefixIcon: const Icon(Icons.business),
            ),
            
            const SizedBox(height: 16),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipo de comprador', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
                      items: _tiposComprador.map((tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(_getTipoCompradorDisplayName(tipo)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _tipoComprador = value!;
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
              prefixIcon: const Icon(Icons.person_outline),
              hint: 'Nombre del responsable de compras',
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Horario de atención',
              controller: _horarioAtencionController,
              prefixIcon: const Icon(Icons.schedule),
              hint: 'Ej: Lunes a Viernes 8:00 - 17:00',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComprasSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Compras',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Volumen de compra mensual',
              controller: _volumenCompraController,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validatePositiveNumber(value, 'el volumen de compra'),
              prefixIcon: const Icon(Icons.scale),
              suffixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('ton'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Frecuencia de compra', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
                      items: _frecuenciasCompra.map((freq) {
                        return DropdownMenuItem<String>(
                          value: freq,
                          child: Text(_getFrecuenciaDisplayName(freq)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _frecuenciaCompra = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Requiere transporte'),
              subtitle: const Text('¿Necesitas servicio de transporte?'),
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
    );
  }

  Widget _buildPreferenciasSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferencias de Producto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Variedades de interés', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AppConstants.variedadesPina.map((variedad) {
                    final isSelected = _variedadesInteres.contains(variedad);
                    return FilterChip(
                      label: Text(variedad),
                      selected: isSelected,
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
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Calidades preferidas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _calidades.map((calidad) {
                    final isSelected = _calidadesPreferidas.contains(calidad);
                    return FilterChip(
                      label: Text(calidad),
                      selected: isSelected,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPagosSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Términos de Pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Método de pago', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: _metodosPago.map((metodo) {
                      return RadioListTile<String>(
                        title: Text(_getMetodoPagoDisplayName(metodo)),
                        value: metodo,
                        groupValue: _metodoPago,
                        onChanged: (value) {
                          setState(() {
                            _metodoPago = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            
            if (_metodoPago == 'credito' || _metodoPago == 'mixto') ...[
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Días de crédito',
                controller: _diasCreditoController,
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validatePositiveNumber(value, 'los días de crédito'),
                prefixIcon: const Icon(Icons.calendar_month),
                suffixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('días'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTipoCompradorDisplayName(String tipo) {
    switch (tipo) {
      case 'minorista': return 'Minorista';
      case 'mayorista': return 'Mayorista';
      case 'exportador': return 'Exportador';
      case 'procesador': return 'Procesador';
      default: return tipo;
    }
  }

  String _getFrecuenciaDisplayName(String freq) {
    switch (freq) {
      case 'semanal': return 'Semanal';
      case 'quincenal': return 'Quincenal';
      case 'mensual': return 'Mensual';
      case 'trimestral': return 'Trimestral';
      default: return freq;
    }
  }

  String _getMetodoPagoDisplayName(String metodo) {
    switch (metodo) {
      case 'contado': return 'Contado';
      case 'credito': return 'Crédito';
      case 'mixto': return 'Mixto';
      default: return metodo;
    }
  }
}
