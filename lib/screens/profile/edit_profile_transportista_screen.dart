import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/models/perfil_transportista.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/utils/validators.dart';
import 'package:pina_app/widgets/common/custom_button.dart';
import 'package:pina_app/widgets/common/custom_text_field.dart';

class EditProfileTransportistaScreen extends StatefulWidget {
  const EditProfileTransportistaScreen({Key? key}) : super(key: key);

  @override
  _EditProfileTransportistaScreenState createState() => _EditProfileTransportistaScreenState();
}

class _EditProfileTransportistaScreenState extends State<EditProfileTransportistaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingLocalSave = false; // Estado local de guardado
  
  // Controladores
  late TextEditingController _nombreEmpresaController;
  late TextEditingController _capacidadTotalController;
  late TextEditingController _horarioServicioController;
  late TextEditingController _tarifaPorKmController;
  late TextEditingController _tarifaPorToneladaController;
  
  // Variables de estado
  List<Map<String, dynamic>> _vehiculos = [];
  List<String> _rutasHabituales = [];
  List<String> _tiposCarga = [];
  bool _tieneSeguro = false;
  List<String> _certificaciones = [];
  String _tipoServicio = 'local';
  List<String> _diasDisponibles = [];
  bool _servicioUrgente = false;
  List<String> _equipoEspecial = [];

  // Opciones disponibles
  final List<String> _tiposServicio = [
    'local',
    'nacional',
    'internacional'
  ];

  final List<String> _tiposCargaDisponibles = [
    'refrigerada',
    'seca',
    'mixta'
  ];

  final List<String> _certificacionesDisponibles = [
    'Transporte de Alimentos',
    'HACCP',
    'ISO 9001',
    'SCT',
    'SAGARPA'
  ];

  final List<String> _diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  final List<String> _equiposEspeciales = [
    'Montacargas',
    'Refrigeración',
    'Grúa',
    'Tarimas',
    'Correas de sujeción'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final perfil = authProvider.userProfile?.perfilTransportista ?? PerfilTransportista();
    
    _nombreEmpresaController = TextEditingController(text: perfil.nombreEmpresa);
    _capacidadTotalController = TextEditingController(
      text: perfil.capacidadTotalToneladas.toString()
    );
    _horarioServicioController = TextEditingController(text: perfil.horarioServicio);
    _tarifaPorKmController = TextEditingController(
      text: perfil.tarifas['porKm']?.toString() ?? ''
    );
    _tarifaPorToneladaController = TextEditingController(
      text: perfil.tarifas['porTonelada']?.toString() ?? ''
    );
    
    _vehiculos = List.from(perfil.vehiculos);
    _rutasHabituales = List.from(perfil.rutasHabituales);
    _tiposCarga = List.from(perfil.tiposCarga);
    _tieneSeguro = perfil.tieneSeguro;
    _certificaciones = List.from(perfil.certificaciones);
    _tipoServicio = perfil.tipoServicio;
    _diasDisponibles = List.from(perfil.diasDisponibles);
    _servicioUrgente = perfil.servicioUrgente;
    _equipoEspecial = List.from(perfil.equipoEspecial);
  }

  @override
  void dispose() {
    _nombreEmpresaController.dispose();
    _capacidadTotalController.dispose();
    _horarioServicioController.dispose();
    _tarifaPorKmController.dispose();
    _tarifaPorToneladaController.dispose();
    super.dispose();
  }

  Future<void> _guardarPerfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingLocalSave = true;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final perfilDatos = {
        'nombreEmpresa': _nombreEmpresaController.text.trim(),
        'vehiculos': _vehiculos,
        'capacidadTotalToneladas': double.tryParse(_capacidadTotalController.text) ?? 0.0,
        'rutasHabituales': _rutasHabituales,
        'tiposCarga': _tiposCarga,
        'tieneSeguro': _tieneSeguro,
        'seguros': _tieneSeguro ? {'cobertura': 'Básica', 'vigencia': 'Vigente'} : {},
        'certificaciones': _certificaciones,
        'tipoServicio': _tipoServicio,
        'tarifas': {
          'porKm': double.tryParse(_tarifaPorKmController.text) ?? 0.0,
          'porTonelada': double.tryParse(_tarifaPorToneladaController.text) ?? 0.0,
        },
        'diasDisponibles': _diasDisponibles,
        'horarioServicio': _horarioServicioController.text.trim(),
        'servicioUrgente': _servicioUrgente,
        'calificacionPromedio': 0.0,
        'viajesRealizados': 0,
        'equipoEspecial': _equipoEspecial,
      };

      final success = await authProvider.actualizarPerfilEspecifico(perfilDatos);

      setState(() {
        _isLoadingLocalSave = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil de transportista actualizado correctamente'),
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
                        
                        // Tipo de servicio
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tipo de servicio',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: _tiposServicio.map((tipo) {
                                return Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(
                                      tipo.substring(0, 1).toUpperCase() + 
                                      tipo.substring(1),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    value: tipo,
                                    groupValue: _tipoServicio,
                                    onChanged: (value) {
                                      setState(() {
                                        _tipoServicio = value!;
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
                          label: 'Horario de servicio',
                          controller: _horarioServicioController,
                          prefixIcon: const Icon(Icons.schedule),
                          hint: 'Ej: 24 horas, Lunes a Viernes 8:00-18:00',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Flota de Vehículos
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Flota de Vehículos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _agregarVehiculo,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (_vehiculos.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'No hay vehículos registrados.\nAgrega al menos uno para completar tu perfil.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ..._vehiculos.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> vehiculo = entry.value;
                            return Card(
                              color: Colors.blue.shade50,
                              child: ListTile(
                                leading: Icon(
                                  Icons.local_shipping,
                                  color: Colors.blue.shade700,
                                ),
                                title: Text(vehiculo['tipo'] ?? 'Sin tipo'),
                                subtitle: Text(
                                  'Capacidad: ${vehiculo['capacidad']} ton\n'
                                  'Modelo: ${vehiculo['modelo'] ?? 'N/A'}'
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _vehiculos.removeAt(index);
                                    });
                                  },
                                ),
                                isThreeLine: true,
                              ),
                            );
                          }).toList(),
                        
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Capacidad total (toneladas)',
                          controller: _capacidadTotalController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.scale),
                          validator: (value) => Validators.validatePositiveNumber(value, 'la capacidad total'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Tipos de carga
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tipos de carga que maneja',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _tiposCargaDisponibles.map((tipo) {
                                return FilterChip(
                                  label: Text(tipo.substring(0, 1).toUpperCase() + tipo.substring(1)),
                                  selected: _tiposCarga.contains(tipo),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _tiposCarga.add(tipo);
                                      } else {
                                        _tiposCarga.remove(tipo);
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
                ),
                
                const SizedBox(height: 16),
                
                // Tarifas y Condiciones
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tarifas y Condiciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Tarifa por km (\$)',
                                controller: _tarifaPorKmController,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                label: 'Tarifa por tonelada (\$)',
                                controller: _tarifaPorToneladaController,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Días disponibles
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Días disponibles',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _diasSemana.map((dia) {
                                return FilterChip(
                                  label: Text(dia),
                                  selected: _diasDisponibles.contains(dia),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _diasDisponibles.add(dia);
                                      } else {
                                        _diasDisponibles.remove(dia);
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
                          title: const Text('Cuenta con seguro'),
                          subtitle: const Text('¿Tus vehículos tienen seguro de carga?'),
                          value: _tieneSeguro,
                          onChanged: (value) {
                            setState(() {
                              _tieneSeguro = value;
                            });
                          },
                        ),
                        
                        SwitchListTile(
                          title: const Text('Servicio urgente'),
                          subtitle: const Text('¿Ofreces servicio de entrega urgente?'),
                          value: _servicioUrgente,
                          onChanged: (value) {
                            setState(() {
                              _servicioUrgente = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Certificaciones y Equipo
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Certificaciones y Equipo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                                  selected: _certificaciones.contains(certificacion),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _certificaciones.add(certificacion);
                                      } else {
                                        _certificaciones.remove(certificacion);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Equipo especial
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Equipo especial disponible',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _equiposEspeciales.map((equipo) {
                                return FilterChip(
                                  label: Text(equipo),
                                  selected: _equipoEspecial.contains(equipo),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _equipoEspecial.add(equipo);
                                      } else {
                                        _equipoEspecial.remove(equipo);
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
                ),
                
                const SizedBox(height: 32),
                
                CustomButton(
                  text: 'Guardar Perfil de Transportista',
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

  void _agregarVehiculo() {
    final tipoController = TextEditingController();
    final capacidadController = TextEditingController();
    final modeloController = TextEditingController();
    final placasController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Vehículo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de vehículo',
                  hintText: 'Camión, Camioneta, Tráiler',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacidad (toneladas)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: modeloController,
                decoration: const InputDecoration(
                  labelText: 'Modelo/Año',
                  hintText: 'Ford 2020',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: placasController,
                decoration: const InputDecoration(
                  labelText: 'Placas',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tipoController.text.isNotEmpty && 
                  capacidadController.text.isNotEmpty) {
                setState(() {
                  _vehiculos.add({
                    'tipo': tipoController.text,
                    'capacidad': double.tryParse(capacidadController.text) ?? 0.0,
                    'modelo': modeloController.text,
                    'placas': placasController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
