import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/models/usuario.dart';
import 'package:pina_app/models/perfil_productor.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/utils/validators.dart';
import 'package:pina_app/widgets/common/custom_button.dart';
import 'package:pina_app/widgets/common/custom_text_field.dart';

class EditPerfilProductor extends StatefulWidget {
  final Usuario usuario;

  const EditPerfilProductor({
    Key? key,
    required this.usuario,
  }) : super(key: key);

  @override
  _EditPerfilProductorState createState() => _EditPerfilProductorState();
}

class _EditPerfilProductorState extends State<EditPerfilProductor> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _nombreFincaController = TextEditingController();
  final _hectareasController = TextEditingController();
  final _capacidadProductivaController = TextEditingController();
  final _anosExperienciaController = TextEditingController();
  final _equipoDisponibleController = TextEditingController();
  final _temporadaCosechaController = TextEditingController();
  
  // Listas seleccionables
  List<String> _variedadesCultivadas = [];
  List<String> _certificaciones = [];
  String _tipoSuelo = '';
  String _metodoCultivo = 'tradicional';
  
  final List<String> _tiposSuelo = [
    'Arcilloso',
    'Arenoso',
    'Franco',
    'Limoso',
    'Mixto',
  ];
  
  final List<String> _metodosCultivo = [
    'tradicional',
    'orgánico',
    'mixto',
  ];
  
  final List<String> _certificacionesDisponibles = [
    'Orgánico',
    'Fair Trade',
    'Global GAP',
    'SENASICA',
    'SAGARPA',
    'ISO 22000',
    'HACCP',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final perfil = widget.usuario.perfilProductor ?? PerfilProductor();
    
    _nombreFincaController.text = perfil.nombreFinca;
    _hectareasController.text = perfil.hectareas > 0 ? perfil.hectareas.toString() : '';
    _capacidadProductivaController.text = perfil.capacidadProductivaMensual > 0 
        ? perfil.capacidadProductivaMensual.toString() : '';
    _anosExperienciaController.text = perfil.anosExperiencia > 0 
        ? perfil.anosExperiencia.toString() : '';
    _equipoDisponibleController.text = perfil.equipoDisponible;
    _temporadaCosechaController.text = perfil.temporadaCosecha;
    
    _variedadesCultivadas = List.from(perfil.variedadesCultivadas);
    _certificaciones = List.from(perfil.certificaciones);
    _tipoSuelo = perfil.tipoSuelo;
    _metodoCultivo = perfil.metodoCultivo.isNotEmpty ? perfil.metodoCultivo : 'tradicional';
  }

  @override
  void dispose() {
    _nombreFincaController.dispose();
    _hectareasController.dispose();
    _capacidadProductivaController.dispose();
    _anosExperienciaController.dispose();
    _equipoDisponibleController.dispose();
    _temporadaCosechaController.dispose();
    super.dispose();
  }

  Future<void> _guardarPerfil() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final perfilActualizado = PerfilProductor(
        nombreFinca: _nombreFincaController.text.trim(),
        hectareas: double.tryParse(_hectareasController.text) ?? 0.0,
        variedadesCultivadas: _variedadesCultivadas,
        capacidadProductivaMensual: double.tryParse(_capacidadProductivaController.text) ?? 0.0,
        certificaciones: _certificaciones,
        tipoSuelo: _tipoSuelo,
        metodoCultivo: _metodoCultivo,
        anosExperiencia: int.tryParse(_anosExperienciaController.text) ?? 0,
        equipoDisponible: _equipoDisponibleController.text.trim(),
        temporadaCosecha: _temporadaCosechaController.text.trim(),
        ubicacionFinca: widget.usuario.perfilProductor?.ubicacionFinca ?? {},
      );

      final success = await authProvider.actualizarPerfilEspecifico(
        perfilActualizado.toMap(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil de productor actualizado correctamente'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información básica de la finca
                _buildFincaInfoSection(),
                
                const SizedBox(height: 24),
                
                // Producción
                _buildProduccionSection(),
                
                const SizedBox(height: 24),
                
                // Certificaciones y métodos
                _buildCertificacionesSection(),
                
                const SizedBox(height: 24),
                
                // Experiencia y equipamiento
                _buildExperienciaSection(),
                
                const SizedBox(height: 32),
                
                // Botón de guardar
                CustomButton(
                  text: 'Guardar Perfil de Productor',
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

  Widget _buildFincaInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la Finca',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Nombre de la finca',
              controller: _nombreFincaController,
              validator: (value) => Validators.validateRequired(value, 'el nombre de la finca'),
              prefixIcon: const Icon(Icons.agriculture),
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Hectáreas cultivadas',
              controller: _hectareasController,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validatePositiveNumber(value, 'las hectáreas'),
              prefixIcon: const Icon(Icons.square_foot),
              suffixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('ha'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tipo de suelo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipo de suelo',
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
                      value: _tipoSuelo.isEmpty ? null : _tipoSuelo,
                      hint: const Text('Selecciona el tipo de suelo'),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      items: _tiposSuelo.map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _tipoSuelo = newValue ?? '';
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
    );
  }

  Widget _buildProduccionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Producción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Variedades cultivadas
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Variedades cultivadas',
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
                    final isSelected = _variedadesCultivadas.contains(variedad);
                    return FilterChip(
                      label: Text(variedad),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _variedadesCultivadas.add(variedad);
                          } else {
                            _variedadesCultivadas.remove(variedad);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Capacidad productiva mensual',
              controller: _capacidadProductivaController,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validatePositiveNumber(value, 'la capacidad productiva'),
              prefixIcon: const Icon(Icons.scale),
              suffixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('ton'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Temporada de cosecha',
              controller: _temporadaCosechaController,
              validator: (value) => Validators.validateRequired(value, 'la temporada de cosecha'),
              prefixIcon: const Icon(Icons.event),
              hint: 'Ej: Enero - Abril, Mayo - Agosto',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificacionesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Certificaciones y Métodos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Método de cultivo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Método de cultivo',
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
                  child: Column(
                    children: _metodosCultivo.map((metodo) {
                      return RadioListTile<String>(
                        title: Text(_getMetodoDisplayName(metodo)),
                        value: metodo,
                        groupValue: _metodoCultivo,
                        onChanged: (value) {
                          setState(() {
                            _metodoCultivo = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Certificaciones
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Certificaciones',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _certificacionesDisponibles.map((cert) {
                    final isSelected = _certificaciones.contains(cert);
                    return FilterChip(
                      label: Text(cert),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _certificaciones.add(cert);
                          } else {
                            _certificaciones.remove(cert);
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

  Widget _buildExperienciaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Experiencia y Equipamiento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Años de experiencia',
              controller: _anosExperienciaController,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validatePositiveNumber(value, 'los años de experiencia'),
              prefixIcon: const Icon(Icons.timeline),
              suffixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('años'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Equipo disponible',
              controller: _equipoDisponibleController,
              keyboardType: TextInputType.multiline,
              prefixIcon: const Icon(Icons.build),
              hint: 'Describe el equipo y maquinaria disponible',
            ),
          ],
        ),
      ),
    );
  }

  String _getMetodoDisplayName(String metodo) {
    switch (metodo) {
      case 'tradicional':
        return 'Tradicional';
      case 'orgánico':
        return 'Orgánico';
      case 'mixto':
        return 'Mixto';
      default:
        return metodo;
    }
  }
}
