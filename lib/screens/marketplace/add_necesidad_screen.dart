import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/models/necesidad_compra.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/necesidades_provider.dart';
import 'package:pina_app/utils/validators.dart';
import 'package:pina_app/widgets/common/custom_button.dart';
import 'package:pina_app/widgets/common/custom_text_field.dart';
import 'package:pina_app/widgets/common/location_picker_widget.dart';

class AddNecesidadScreen extends StatefulWidget {
  const AddNecesidadScreen({Key? key}) : super(key: key);

  @override
  State<AddNecesidadScreen> createState() => _AddNecesidadScreenState();
}

class _AddNecesidadScreenState extends State<AddNecesidadScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Controladores de texto
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _presupuestoMinController = TextEditingController();
  final _presupuestoMaxController = TextEditingController();
  final _cantidadController = TextEditingController();

  // Variables de estado
  String _variedad = AppConstants.variedadesPina[0];
  String _calidad = 'Estándar';
  String _unidad = 'kg';
  String _ubicacionTexto = '';
  double? _latitud;
  double? _longitud;
  DateTime _fechaLimite = DateTime.now().add(const Duration(days: 30));

  final List<String> _calidades = ['Premium', 'Estándar', 'Segunda', 'Cualquiera'];
  final List<String> _unidades = ['kg', 'tonelada', 'pieza'];

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _tituloController.dispose();
    _descripcionController.dispose();
    _presupuestoMinController.dispose();
    _presupuestoMaxController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _guardarNecesidad() async {
    if (_formKey.currentState!.validate() && _ubicacionTexto.isNotEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final necesidadesProvider = Provider.of<NecesidadesProvider>(context, listen: false);

      final presupuestoMin = double.parse(_presupuestoMinController.text);
      final presupuestoMax = double.parse(_presupuestoMaxController.text);

      if (presupuestoMin > presupuestoMax) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El presupuesto mínimo no puede ser mayor al máximo'),
          ),
        );
        return;
      }

      final necesidad = NecesidadCompra(
        idComprador: authProvider.user!.uid,
        titulo: _tituloController.text.trim(),
        variedad: _variedad,
        descripcion: _descripcionController.text.trim(),
        presupuestoMin: presupuestoMin,
        presupuestoMax: presupuestoMax,
        cantidadRequerida: double.parse(_cantidadController.text),
        unidad: _unidad,
        calidad: _calidad,
        ubicacionPreferida: _ubicacionTexto,
        latitudPreferida: _latitud,
        longitudPreferida: _longitud,
        fechaLimite: _fechaLimite,
        fechaPublicacion: DateTime.now(),
      );

      final success = await necesidadesProvider.agregarNecesidad(necesidad);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Necesidad publicada correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(necesidadesProvider.error)),
        );
      }
    } else if (_ubicacionTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una ubicación')),
      );
    }
  }

  Future<void> _selectFechaLimite() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaLimite,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _fechaLimite = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final necesidadesProvider = Provider.of<NecesidadesProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              AppTheme.backgroundLight,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildCustomAppBar(),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(AppTheme.space16),
                    children: [
                      _buildSectionTitle('Información Básica'),
                      const SizedBox(height: AppTheme.space16),
                      
                      CustomTextField(
                        label: 'Título de la necesidad',
                        hint: 'Ej: Busco piña MD2 para exportación',
                        controller: _tituloController,
                        validator: (value) => Validators.validateRequired(value, 'el título'),
                      ),
                      const SizedBox(height: AppTheme.space16),

                      // Variedad
                      _buildDropdown(
                        label: 'Variedad requerida',
                        value: _variedad,
                        items: AppConstants.variedadesPina,
                        onChanged: (value) => setState(() => _variedad = value!),
                      ),
                      const SizedBox(height: AppTheme.space16),

                      CustomTextField(
                        label: 'Descripción detallada',
                        hint: 'Describe específicamente lo que necesitas',
                        controller: _descripcionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        validator: Validators.validateDescription,
                      ),
                      const SizedBox(height: AppTheme.space24),

                      _buildSectionTitle('Especificaciones'),
                      const SizedBox(height: AppTheme.space16),

                      // Presupuesto
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Presupuesto mínimo',
                              hint: 'Ej: 10',
                              controller: _presupuestoMinController,
                              keyboardType: TextInputType.number,
                              validator: (value) => Validators.validatePositiveNumber(value, 'el presupuesto mínimo'),
                            ),
                          ),
                          const SizedBox(width: AppTheme.space16),
                          Expanded(
                            child: CustomTextField(
                              label: 'Presupuesto máximo',
                              hint: 'Ej: 25',
                              controller: _presupuestoMaxController,
                              keyboardType: TextInputType.number,
                              validator: (value) => Validators.validatePositiveNumber(value, 'el presupuesto máximo'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space16),

                      // Cantidad y unidad
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              label: 'Cantidad requerida',
                              hint: 'Ej: 1000',
                              controller: _cantidadController,
                              keyboardType: TextInputType.number,
                              validator: (value) => Validators.validatePositiveNumber(value, 'la cantidad'),
                            ),
                          ),
                          const SizedBox(width: AppTheme.space16),
                          Expanded(
                            flex: 1,
                            child: _buildDropdown(
                              label: 'Unidad',
                              value: _unidad,
                              items: _unidades,
                              onChanged: (value) => setState(() => _unidad = value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space16),

                      // Calidad
                      _buildDropdown(
                        label: 'Calidad requerida',
                        value: _calidad,
                        items: _calidades,
                        onChanged: (value) => setState(() => _calidad = value!),
                      ),
                      const SizedBox(height: AppTheme.space24),

                      _buildSectionTitle('Ubicación y Tiempo'),
                      const SizedBox(height: AppTheme.space16),

                      // Ubicación
                      LocationPickerWidget(
                        hintText: 'Selecciona tu ubicación preferida para entrega',
                        onLocationSelected: (latitude, longitude, address) {
                          setState(() {
                            _latitud = latitude;
                            _longitud = longitude;
                            _ubicacionTexto = address;
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.space16),

                      // Fecha límite
                      _buildDateSelector(),
                      const SizedBox(height: AppTheme.space32),

                      CustomButton(
                        text: 'Publicar Necesidad',
                        isLoading: necesidadesProvider.isLoading,
                        onPressed: _guardarNecesidad,
                        width: double.infinity,
                      ),
                      const SizedBox(height: AppTheme.space16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      height: MediaQuery.of(context).padding.top + 60,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space16,
            vertical: AppTheme.space8,
          ),
          child: Row(
            children: [
              // Botón de retroceso
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              // Título
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nueva Necesidad',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Publica lo que necesitas comprar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppTheme.space8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.space8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.divider),
            boxShadow: AppTheme.createShadow(
              elevation: AppTheme.elevationLow,
              opacity: 0.05,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha límite',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.space8),
        InkWell(
          onTap: _selectFechaLimite,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space16,
              vertical: AppTheme.space12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: AppTheme.divider),
              boxShadow: AppTheme.createShadow(
                elevation: AppTheme.elevationLow,
                opacity: 0.05,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Text(
                    '${_fechaLimite.day}/${_fechaLimite.month}/${_fechaLimite.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        Text(
          'Los productores podrán ofertar hasta esta fecha',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
