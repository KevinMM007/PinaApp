import 'package:flutter/material.dart';
import 'package:pina_app/config/theme.dart';

class AdvancedFiltersDialog extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const AdvancedFiltersDialog({
    Key? key,
    required this.currentFilters,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<AdvancedFiltersDialog> createState() => _AdvancedFiltersDialogState();
}

class _AdvancedFiltersDialogState extends State<AdvancedFiltersDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Filtros de precio
  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _priceFilterEnabled = false;

  // Filtros de ubicación
  String _selectedRegion = 'Todas';
  double _maxDistance = 50.0;
  bool _locationFilterEnabled = false;

  // Filtros de calidad
  List<String> _selectedQualities = [];
  final List<String> _availableQualities = ['Premium', 'Estándar', 'Segunda'];

  // Filtros de fecha
  DateTimeRange? _dateRange;
  bool _dateFilterEnabled = false;

  // Filtros de cantidad
  double _minQuantity = 0;
  bool _quantityFilterEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _initializeFilters();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeFilters() {
    // Inicializar con filtros actuales
    final filters = widget.currentFilters;

    if (filters['priceMin'] != null && filters['priceMax'] != null) {
      _priceRange = RangeValues(
        filters['priceMin']?.toDouble() ?? 0,
        filters['priceMax']?.toDouble() ?? 1000,
      );
      _priceFilterEnabled = true;
    }

    if (filters['region'] != null) {
      _selectedRegion = filters['region'];
      _locationFilterEnabled = true;
    }

    if (filters['qualities'] != null) {
      _selectedQualities = List<String>.from(filters['qualities']);
    }

    if (filters['dateRange'] != null) {
      _dateRange = filters['dateRange'];
      _dateFilterEnabled = true;
    }

    if (filters['minQuantity'] != null) {
      _minQuantity = filters['minQuantity']?.toDouble() ?? 0;
      _quantityFilterEnabled = true;
    }
  }

  Map<String, dynamic> _buildFiltersMap() {
    Map<String, dynamic> filters = {};

    if (_priceFilterEnabled) {
      filters['priceMin'] = _priceRange.start;
      filters['priceMax'] = _priceRange.end;
    }

    if (_locationFilterEnabled && _selectedRegion != 'Todas') {
      filters['region'] = _selectedRegion;
      filters['maxDistance'] = _maxDistance;
    }

    if (_selectedQualities.isNotEmpty) {
      filters['qualities'] = _selectedQualities;
    }

    if (_dateFilterEnabled && _dateRange != null) {
      filters['dateRange'] = _dateRange;
    }

    if (_quantityFilterEnabled && _minQuantity > 0) {
      filters['minQuantity'] = _minQuantity;
    }

    return filters;
  }

  void _clearAllFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _priceFilterEnabled = false;
      _selectedRegion = 'Todas';
      _maxDistance = 50.0;
      _locationFilterEnabled = false;
      _selectedQualities.clear();
      _dateRange = null;
      _dateFilterEnabled = false;
      _minQuantity = 0;
      _quantityFilterEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Dialog.fullscreen(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPriceFilters(),
                    _buildLocationFilters(),
                    _buildQualityFilters(),
                    _buildDateQuantityFilters(),
                  ],
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: Colors.white,
      title: const Text(
        'Filtros Avanzados',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close),
      ),
      actions: [
        TextButton(
          onPressed: _clearAllFilters,
          child: const Text(
            'Limpiar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryGreen,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primaryGreen,
        tabs: const [
          Tab(text: 'Precio'),
          Tab(text: 'Ubicación'),
          Tab(text: 'Calidad'),
          Tab(text: 'Fecha/Cant.'),
        ],
      ),
    );
  }

  Widget _buildPriceFilters() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Filtrar por precio'),
            value: _priceFilterEnabled,
            onChanged: (value) {
              setState(() {
                _priceFilterEnabled = value;
              });
            },
            activeColor: AppTheme.primaryGreen,
          ),
          if (_priceFilterEnabled) ...[
            const SizedBox(height: AppTheme.space16),
            Text(
              'Rango de precio: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.space16),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 1000,
              divisions: 100,
              activeColor: AppTheme.primaryGreen,
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            const SizedBox(height: AppTheme.space16),
            Row(
              children: [
                Expanded(
                  child: _buildPriceInput('Mínimo', _priceRange.start, (value) {
                    setState(() {
                      _priceRange = RangeValues(value, _priceRange.end);
                    });
                  }),
                ),
                const SizedBox(width: AppTheme.space16),
                Expanded(
                  child: _buildPriceInput('Máximo', _priceRange.end, (value) {
                    setState(() {
                      _priceRange = RangeValues(_priceRange.start, value);
                    });
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceInput(
      String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value.round().toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '\$',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (text) {
            final newValue = double.tryParse(text) ?? value;
            onChanged(newValue);
          },
        ),
      ],
    );
  }

  Widget _buildLocationFilters() {
    final regions = [
      'Todas',
      'Veracruz',
      'Oaxaca',
      'Tabasco',
      'Chiapas',
      'Yucatán'
    ];

    return Padding(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Filtrar por ubicación'),
            value: _locationFilterEnabled,
            onChanged: (value) {
              setState(() {
                _locationFilterEnabled = value;
              });
            },
            activeColor: AppTheme.primaryGreen,
          ),
          if (_locationFilterEnabled) ...[
            const SizedBox(height: AppTheme.space16),
            const Text(
              'Región:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppTheme.space8),
            Wrap(
              spacing: 8,
              children: regions.map((region) {
                final isSelected = _selectedRegion == region;
                return FilterChip(
                  label: Text(region),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRegion = region;
                    });
                  },
                  selectedColor: AppTheme.primaryGreen,
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.space24),
            Text(
              'Distancia máxima: ${_maxDistance.round()} km',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _maxDistance,
              min: 5,
              max: 200,
              divisions: 39,
              activeColor: AppTheme.primaryGreen,
              onChanged: (value) {
                setState(() {
                  _maxDistance = value;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQualityFilters() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calidad del producto:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.space16),
          ..._availableQualities.map((quality) {
            final isSelected = _selectedQualities.contains(quality);
            return CheckboxListTile(
              title: Text(quality),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedQualities.add(quality);
                  } else {
                    _selectedQualities.remove(quality);
                  }
                });
              },
              activeColor: AppTheme.primaryGreen,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDateQuantityFilters() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtro de fecha
          SwitchListTile(
            title: const Text('Filtrar por fecha de publicación'),
            value: _dateFilterEnabled,
            onChanged: (value) {
              setState(() {
                _dateFilterEnabled = value;
              });
            },
            activeColor: AppTheme.primaryGreen,
          ),
          if (_dateFilterEnabled) ...[
            const SizedBox(height: AppTheme.space8),
            ListTile(
              title: Text(_dateRange == null
                  ? 'Seleccionar rango de fechas'
                  : 'Del ${_dateRange!.start.day}/${_dateRange!.start.month} al ${_dateRange!.end.day}/${_dateRange!.end.month}'),
              trailing: const Icon(Icons.date_range),
              onTap: _selectDateRange,
            ),
          ],
          const SizedBox(height: AppTheme.space24),

          // Filtro de cantidad
          SwitchListTile(
            title: const Text('Filtrar por cantidad mínima'),
            value: _quantityFilterEnabled,
            onChanged: (value) {
              setState(() {
                _quantityFilterEnabled = value;
              });
            },
            activeColor: AppTheme.primaryGreen,
          ),
          if (_quantityFilterEnabled) ...[
            const SizedBox(height: AppTheme.space16),
            Text(
              'Cantidad mínima: ${_minQuantity.round()} kg',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _minQuantity,
              min: 0,
              max: 1000,
              divisions: 100,
              activeColor: AppTheme.primaryGreen,
              onChanged: (value) {
                setState(() {
                  _minQuantity = value;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: AppTheme.space16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onFiltersApplied(_buildFiltersMap());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Aplicar Filtros'),
            ),
          ),
        ],
      ),
    );
  }
}
