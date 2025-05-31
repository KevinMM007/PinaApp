import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/models/perfil_productor.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/utils/validators.dart';
import 'package:pina_app/widgets/common/custom_button.dart';
import 'package:pina_app/widgets/common/custom_text_field.dart';

class EditProfileProductorScreen extends StatefulWidget {
  const EditProfileProductorScreen({Key? key}) : super(key: key);

  @override
  _EditProfileProductorScreenState createState() => _EditProfileProductorScreenState();
}

class _EditProfileProductorScreenState extends State<EditProfileProductorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingLocalSave = false; // Estado local de guardado
  
  // Controladores
  late TextEditingController _nombreFincaController;
  late TextEditingController _hectareasController;
  late TextEditingController _capacidadProductivaController;
  late TextEditingController _anosExperienciaController;
  late TextEditingController _equipoDisponibleController;
  late TextEditingController _temporadaCosechaController;
  
  // Variables de estado
  List<String> _variedadesSeleccionadas = [];
  List<String> _certificacionesSeleccionadas = [];
  String _tipoSuelo = '';
  String _metodoCultivo = 'tradicional';

  // Opciones disponibles
  final List<String> _tiposSuelo = [
    'Arcilloso',
    'Arenoso',
    'Franco',
    'Limoso',
    'Volcánico',
    'Otro'
  ];

  final List<String> _metodosCultivo = [
    'tradicional',
    'orgánico',
    'mixto'
  ];

  final List<String> _certificacionesDisponibles = [
    'Orgánico',
    'GlobalGAP',
    'Fair Trade',
    'Rainforest Alliance',
    'HACCP',
    'ISO 22000',
    'Otra'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final perfil = authProvider.userProfile?.perfilProductor ?? PerfilProductor();
    
    _nombreFincaController = TextEditingController(text: perfil.nombreFinca);
    _hectareasController = TextEditingController(text: perfil.hectareas.toString());
    _capacidadProductivaController = TextEditingController(
      text: perfil.capacidadProductivaMensual.toString()
    );
    _anosExperienciaController = TextEditingController(
      text: perfil.anosExperiencia.toString()
    );
    _equipoDisponibleController = TextEditingController(text: perfil.equipoDisponible);
    _temporadaCosechaController = TextEditingController(text: perfil.temporadaCosecha);
    
    _variedadesSeleccionadas = List.from(perfil.variedadesCultivadas);
    _certificacionesSeleccionadas = List.from(perfil.certificaciones);
    _tipoSuelo = perfil.tipoSuelo;
    _metodoCultivo = perfil.metodoCultivo;
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
      setState(() {
        _isLoadingLocalSave = true;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final perfilDatos = {
        'nombreFinca': _nombreFincaController.text.trim(),
        'hectareas': double.tryParse(_hectareasController.text) ?? 0.0,
        'variedadesCultivadas': _variedadesSeleccionadas,
        'capacidadProductivaMensual': double.tryParse(_capacidadProductivaController.text) ?? 0.0,
        'certificaciones': _certificacionesSeleccionadas,
        'tipoSuelo': _tipoSuelo,
        'metodoCultivo': _metodoCultivo,
        'ubicacionFinca': {}, // TODO: Implementar selector de ubicación
        'anosExperiencia': int.tryParse(_anosExperienciaController.text) ?? 0,
        'equipoDisponible': _equipoDisponibleController.text.trim(),
        'temporadaCosecha': _temporadaCosechaController.text.trim(),
      };

      final success = await authProvider.actualizarPerfilEspecifico(perfilDatos);

      setState(() {
        _isLoadingLocalSave = false;
      });

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
              children: [
                // Información de la Finca
                Card(
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
                          prefixIcon: const Icon(Icons.agriculture),
                          validator: (value) => Validators.validateRequired(value, 'el nombre de la finca'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Hectáreas',
                          controller: _hectareasController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.straighten),
                          validator: (value) => Validators.validatePositiveNumber(value, 'las hectáreas'),
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
                ),
                
                const SizedBox(height: 16),
                
                // Producción
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información de Producción',
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
                                return FilterChip(
                                  label: Text(variedad),
                                  selected: _variedadesSeleccionadas.contains(variedad),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _variedadesSeleccionadas.add(variedad);
                                      } else {
                                        _variedadesSeleccionadas.remove(variedad);
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
                          label: 'Capacidad productiva mensual (toneladas)',
                          controller: _capacidadProductivaController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.scale),
                          validator: (value) => Validators.validatePositiveNumber(value, 'la capacidad productiva'),
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
                            Row(
                              children: _metodosCultivo.map((metodo) {
                                return Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(
                                      metodo.substring(0, 1).toUpperCase() + 
                                      metodo.substring(1),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    value: metodo,
                                    groupValue: _metodoCultivo,
                                    onChanged: (value) {
                                      setState(() {
                                        _metodoCultivo = value!;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Temporada de cosecha',
                          controller: _temporadaCosechaController,
                          prefixIcon: const Icon(Icons.calendar_month),
                          hint: 'Ejemplo: Enero - Marzo, Julio - Septiembre',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Experiencia y Certificaciones
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Experiencia y Certificaciones',
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
                          prefixIcon: const Icon(Icons.timeline),
                          validator: (value) => Validators.validatePositiveNumber(value, 'los años de experiencia'),
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
                              children: _certificacionesDisponibles.map((certificacion) {
                                return FilterChip(
                                  label: Text(certificacion),
                                  selected: _certificacionesSeleccionadas.contains(certificacion),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _certificacionesSeleccionadas.add(certificacion);
                                      } else {
                                        _certificacionesSeleccionadas.remove(certificacion);
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
                          label: 'Equipo disponible',
                          controller: _equipoDisponibleController,
                          keyboardType: TextInputType.multiline,
                          prefixIcon: const Icon(Icons.build),
                          hint: 'Tractores, sistemas de riego, etc.',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                CustomButton(
                  text: 'Guardar Perfil de Productor',
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
