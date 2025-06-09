import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/models/producto.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/product_provider.dart';
import 'package:pina_app/providers/necesidades_provider.dart';
import 'package:pina_app/widgets/product/product_card.dart';
import 'package:pina_app/widgets/marketplace/necesidad_card.dart';
import 'package:pina_app/widgets/common/state_widgets.dart';
import 'package:pina_app/widgets/common/animated_buttons.dart';
import 'package:pina_app/widgets/common/enhanced_ui_components.dart';
import 'package:pina_app/widgets/marketplace/advanced_filters_dialog.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with TickerProviderStateMixin {
  String _filterVariedad = 'Todas';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic> _advancedFilters = {};
  int _activeFiltersCount = 0;

  late AnimationController _filterAnimationController;
  late AnimationController _searchAnimationController;
  late TabController _tabController;
  late Animation<Offset> _filterSlideAnimation;
  late Animation<double> _searchFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores de animación
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Inicializar TabController
    _tabController = TabController(length: 2, vsync: this);

    _filterSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _searchFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));

    // Cargar productos y animar interfaz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).cargarProductos();
      Provider.of<NecesidadesProvider>(context, listen: false)
          .cargarNecesidades();
      _startAnimations();
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _searchAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _filterAnimationController.forward();
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    _searchAnimationController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Helper method para filtrar productos con filtros avanzados
  List<Producto> _getFilteredProducts(List<Producto> productos) {
    var filtered = productos;

    // Filtrar por variedad
    if (_filterVariedad != 'Todas') {
      filtered = filtered
          .where((producto) => producto.variedad == _filterVariedad)
          .toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((producto) =>
              producto.titulo
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              producto.variedad
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              producto.descripcion
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              producto.ubicacion
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Aplicar filtros avanzados
    filtered = _applyAdvancedFilters(filtered);

    return filtered;
  }

  /// Aplicar filtros avanzados
  List<Producto> _applyAdvancedFilters(List<Producto> productos) {
    var filtered = productos;

    // Filtro de precio
    if (_advancedFilters['priceMin'] != null &&
        _advancedFilters['priceMax'] != null) {
      final priceMin = _advancedFilters['priceMin'] as double;
      final priceMax = _advancedFilters['priceMax'] as double;
      filtered = filtered
          .where((producto) =>
              producto.precio >= priceMin && producto.precio <= priceMax)
          .toList();
    }

    // Filtro de calidad
    if (_advancedFilters['qualities'] != null) {
      final qualities = _advancedFilters['qualities'] as List<String>;
      if (qualities.isNotEmpty) {
        filtered = filtered
            .where((producto) => qualities.contains(producto.calidad))
            .toList();
      }
    }

    // Filtro de región
    if (_advancedFilters['region'] != null) {
      final region = _advancedFilters['region'] as String;
      filtered = filtered
          .where((producto) =>
              producto.ubicacion.toLowerCase().contains(region.toLowerCase()))
          .toList();
    }

    // Filtro de cantidad mínima
    if (_advancedFilters['minQuantity'] != null) {
      final minQuantity = _advancedFilters['minQuantity'] as double;
      filtered = filtered
          .where((producto) => producto.cantidadDisponible >= minQuantity)
          .toList();
    }

    // Filtro de fecha
    if (_advancedFilters['dateRange'] != null) {
      final dateRange = _advancedFilters['dateRange'] as DateTimeRange;
      filtered = filtered
          .where((producto) =>
              producto.fechaPublicacion.isAfter(dateRange.start) &&
              producto.fechaPublicacion
                  .isBefore(dateRange.end.add(const Duration(days: 1))))
          .toList();
    }

    return filtered;
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  /// Abrir diálogo de filtros avanzados
  Future<void> _showAdvancedFilters() async {
    await showDialog(
      context: context,
      builder: (context) => AdvancedFiltersDialog(
        currentFilters: _advancedFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _advancedFilters = filters;
            _activeFiltersCount = _calculateActiveFiltersCount(filters);
          });
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Productos'),
          Tab(text: 'Necesidades'),
        ],
      ),
    );
  }

  /// Calcular número de filtros activos
  int _calculateActiveFiltersCount(Map<String, dynamic> filters) {
    int count = 0;
    if (filters['priceMin'] != null && filters['priceMax'] != null) count++;
    if (filters['region'] != null) count++;
    if (filters['qualities'] != null &&
        (filters['qualities'] as List).isNotEmpty) {
      count++;
    }
    if (filters['dateRange'] != null) count++;
    if (filters['minQuantity'] != null && filters['minQuantity'] > 0) count++;
    return count;
  }

  /// Limpiar todos los filtros
  void _clearAllFilters() {
    setState(() {
      _filterVariedad = 'Todas';
      _searchQuery = '';
      _searchController.clear();
      _advancedFilters = {};
      _activeFiltersCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final necesidadesProvider = Provider.of<NecesidadesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final esProductor =
        authProvider.userProfile?.tipo == AppConstants.rolProductor;
    final esComprador =
        authProvider.userProfile?.tipo == AppConstants.rolComprador;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda animada
            _buildSearchBar(),
            // Pestañas
            _buildTabBar(),
            // Filtros animados
            _buildFilterChips(),
            // Contenido de las pestañas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductsTab(productProvider),
                  _buildNecesidadesTab(necesidadesProvider),
                ],
              ),
            ),
          ],
        ),
      ),
      // Botón flotante dinámico según la pestaña activa
      floatingActionButton:
          _buildDynamicFAB(productProvider, esProductor, esComprador),
    );
  }

  Widget _buildSearchBar() {
    return FadeTransition(
      opacity: _searchFadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.createShadow(
            elevation: AppTheme.elevationMedium,
            color: AppTheme.primaryGreen,
            opacity: 0.2,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge - 2),
          ),
          child: Row(
            children: [
              // Campo de búsqueda
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar productos, variedades...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.textSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButtonWithRipple(
                            icon: Icons.clear,
                            onPressed: _clearSearch,
                            size: 40,
                            iconColor: AppTheme.textSecondary,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space16,
                      vertical: AppTheme.space12,
                    ),
                  ),
                ),
              ),
              // Botón de filtros avanzados
              Container(
                margin: const EdgeInsets.only(right: AppTheme.space8),
                child: Stack(
                  children: [
                    IconButtonWithRipple(
                      icon: Icons.tune,
                      onPressed: _showAdvancedFilters,
                      size: 44,
                      iconColor: _activeFiltersCount > 0
                          ? Colors.white
                          : AppTheme.primaryGreen,
                      backgroundColor: _activeFiltersCount > 0
                          ? AppTheme.primaryGreen
                          : AppTheme.accentGreen.withOpacity(0.1),
                    ),
                    if (_activeFiltersCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$_activeFiltersCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
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

  Widget _buildFilterChips() {
    return SlideTransition(
      position: _filterSlideAnimation,
      child: Column(
        children: [
          // Indicador de filtros activos
          if (_activeFiltersCount > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space12,
                vertical: AppTheme.space6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: AppTheme.space4),
                  Text(
                    '$_activeFiltersCount filtro${_activeFiltersCount != 1 ? 's' : ''} activo${_activeFiltersCount != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space8),
                  GestureDetector(
                    onTap: _clearAllFilters,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Chips de variedades
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: AppTheme.space8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
              itemCount: ['Todas', ...AppConstants.variedadesPina].length,
              itemBuilder: (context, index) {
                final variedad = index == 0
                    ? 'Todas'
                    : AppConstants.variedadesPina[index - 1];
                final isSelected = _filterVariedad == variedad;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: AppTheme.space8),
                  child: FilterChip(
                    label: Text(
                      variedad,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryGreen,
                    backgroundColor: AppTheme.backgroundLight,
                    checkmarkColor: Colors.white,
                    elevation: isSelected ? AppTheme.elevationMedium : 0,
                    shadowColor: AppTheme.primaryGreen.withOpacity(0.3),
                    onSelected: (selected) {
                      setState(() {
                        _filterVariedad = variedad;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductProvider productProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final esProductor =
        authProvider.userProfile?.tipo == AppConstants.rolProductor;

    return Expanded(
      child: productProvider.isLoading
          ? const ProductCardSkeleton(count: 5)
          : productProvider.productos.isEmpty
              ? EmptyWidget(
                  title: 'No hay productos',
                  message: '¡Sé el primero en publicar productos frescos!',
                  icon: Icons.store_outlined,
                  onAction: esProductor
                      ? () {
                          Navigator.pushNamed(context, '/add_product');
                        }
                      : null,
                  actionButtonText: esProductor ? 'Publicar producto' : null,
                )
              : _buildProductsContent(productProvider),
    );
  }

  Widget _buildProductsContent(ProductProvider productProvider) {
    final filteredProducts = _getFilteredProducts(productProvider.productos);

    if (filteredProducts.isEmpty && _searchQuery.isNotEmpty) {
      return NoResultsWidget(
        searchTerm: _searchQuery,
        onClearSearch: _clearSearch,
      );
    }

    return CustomRefreshIndicator(
    onRefresh: () async {
    productProvider.cargarProductos();
    },
    refreshText: 'Desliza para actualizar productos',
    releaseText: 'Suelta para buscar productos frescos',
    child: _buildListView(filteredProducts),
    );
  }

  Widget _buildListView(List<Producto> productos) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppTheme.space8,
        right: AppTheme.space8,
        bottom: AppTheme.space64, // Espacio para FAB
      ),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];

        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          child: ProductCard(
            producto: producto,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/product_detail',
                arguments: producto.id,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Producto> productos) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.space8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppTheme.space8,
        mainAxisSpacing: AppTheme.space8,
      ),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];

        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 30)),
          curve: Curves.easeOutCubic,
          child: ProductCard(
            producto: producto,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/product_detail',
                arguments: producto.id,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return AnimatedFloatingActionButton(
      icon: icon,
      tooltip: 'Agregar $label',
      onPressed: onPressed,
      isExtended: false,
      gradient: AppTheme.goldGradient,
    );
  }

  Widget _buildProductsTab(ProductProvider productProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final esProductor =
        authProvider.userProfile?.tipo == AppConstants.rolProductor;

    if (productProvider.isLoading) {
      return const ProductCardSkeleton(count: 5);
    }

    if (productProvider.productos.isEmpty) {
      return EmptyWidget(
        title: 'No hay productos',
        message: '¡Sé el primero en publicar productos frescos!',
        icon: Icons.store_outlined,
        onAction: esProductor
            ? () {
                Navigator.pushNamed(context, '/add_product');
              }
            : null,
        actionButtonText: esProductor ? 'Publicar producto' : null,
      );
    }

    return _buildProductsContent(productProvider);
  }

  Widget _buildNecesidadesTab(NecesidadesProvider necesidadesProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final esComprador =
        authProvider.userProfile?.tipo == AppConstants.rolComprador;

    if (necesidadesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final necesidadesFiltradas =
        _getFilteredNecesidades(necesidadesProvider.necesidadesActivas);

    if (necesidadesFiltradas.isEmpty) {
      return EmptyWidget(
        title: 'No hay necesidades',
        message: 'Los compradores pueden publicar sus necesidades aquí',
        icon: Icons.shopping_cart_outlined,
        onAction: esComprador
            ? () {
                Navigator.pushNamed(context, '/add_necesidad');
              }
            : null,
        actionButtonText: esComprador ? 'Publicar necesidad' : null,
      );
    }

    return _buildNecesidadesContent(necesidadesFiltradas);
  }

  Widget _buildNecesidadesContent(List<dynamic> necesidades) {
    return CustomRefreshIndicator(
      onRefresh: () async {
        Provider.of<NecesidadesProvider>(context, listen: false)
            .cargarNecesidades();
      },
      refreshText: 'Desliza para actualizar necesidades',
      releaseText: 'Suelta para buscar nuevas necesidades',
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: AppTheme.space8,
          right: AppTheme.space8,
          bottom: AppTheme.space64, // Espacio para FAB
        ),
        itemCount: necesidades.length,
        itemBuilder: (context, index) {
          final necesidad = necesidades[index];

          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutCubic,
            child: NecesidadCard(
              necesidad: necesidad,
              onTap: () => _showNecesidadDetail(necesidad),
            ),
          );
        },
      ),
    );
  }

  void _showNecesidadDetail(dynamic necesidad) {
    // Navegar a detalle de necesidad o mostrar modal
    Navigator.pushNamed(
      context,
      '/necesidades',
      arguments: necesidad.id,
    );
  }

  Widget _buildDynamicFAB(
      ProductProvider productProvider, bool esProductor, bool esComprador) {
    // Determinar qué pestaña está activa
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final isProductsTab = _tabController.index == 0;

        if (isProductsTab) {
          // Pestaña de productos: mostrar FAB solo para productores cuando hay productos
          if (esProductor && productProvider.productos.isNotEmpty) {
            return _buildFloatingActionButton(
              icon: Icons.add,
              label: 'Producto',
              onPressed: () => Navigator.pushNamed(context, '/add_product'),
            );
          }
        } else {
          // Pestaña de necesidades: mostrar FAB solo para compradores
          if (esComprador) {
            return _buildFloatingActionButton(
              icon: Icons.add_shopping_cart,
              label: 'Necesidad',
              onPressed: () => Navigator.pushNamed(context, '/add_necesidad'),
            );
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Filtrar necesidades con los mismos criterios que los productos
  List<dynamic> _getFilteredNecesidades(List<dynamic> necesidades) {
    var filtered = necesidades;

    // Filtrar por variedad
    if (_filterVariedad != 'Todas') {
      filtered = filtered
          .where((necesidad) => necesidad.variedad == _filterVariedad)
          .toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((necesidad) =>
              necesidad.titulo
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              necesidad.descripcion
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              necesidad.variedad
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              necesidad.ubicacionPreferida
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Aplicar filtros avanzados para necesidades
    filtered = _applyAdvancedFiltersToNecesidades(filtered);

    return filtered;
  }

  /// Aplicar filtros avanzados a necesidades
  List<dynamic> _applyAdvancedFiltersToNecesidades(List<dynamic> necesidades) {
    var filtered = necesidades;

    // Filtro de presupuesto (equivalente al filtro de precio)
    if (_advancedFilters['priceMin'] != null &&
        _advancedFilters['priceMax'] != null) {
      final priceMin = _advancedFilters['priceMin'] as double;
      final priceMax = _advancedFilters['priceMax'] as double;
      filtered = filtered
          .where((necesidad) =>
              necesidad.presupuestoMin <= priceMax &&
              necesidad.presupuestoMax >= priceMin)
          .toList();
    }

    // Filtro de calidad
    if (_advancedFilters['qualities'] != null) {
      final qualities = _advancedFilters['qualities'] as List<String>;
      if (qualities.isNotEmpty) {
        filtered = filtered
            .where((necesidad) =>
                qualities.contains(necesidad.calidad) ||
                necesidad.calidad.toLowerCase() == 'cualquiera')
            .toList();
      }
    }

    // Filtro de región
    if (_advancedFilters['region'] != null) {
      final region = _advancedFilters['region'] as String;
      filtered = filtered
          .where((necesidad) => necesidad.ubicacionPreferida
              .toLowerCase()
              .contains(region.toLowerCase()))
          .toList();
    }

    // Filtro de cantidad (equivalente a cantidad mínima)
    if (_advancedFilters['minQuantity'] != null) {
      final minQuantity = _advancedFilters['minQuantity'] as double;
      filtered = filtered
          .where((necesidad) => necesidad.cantidadRequerida >= minQuantity)
          .toList();
    }

    // Filtro de fecha
    if (_advancedFilters['dateRange'] != null) {
      final dateRange = _advancedFilters['dateRange'] as DateTimeRange;
      filtered = filtered
          .where((necesidad) =>
              necesidad.fechaPublicacion.isAfter(dateRange.start) &&
              necesidad.fechaPublicacion
                  .isBefore(dateRange.end.add(const Duration(days: 1))))
          .toList();
    }

    return filtered;
  }
}
