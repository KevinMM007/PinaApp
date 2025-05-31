import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/models/producto.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/product_provider.dart';
import 'package:pina_app/widgets/product/product_card.dart';
import 'package:pina_app/widgets/common/state_widgets.dart';
import 'package:pina_app/widgets/common/animated_buttons.dart';
import 'package:pina_app/widgets/common/enhanced_ui_components.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with TickerProviderStateMixin {
  String _filterVariedad = 'Todas';
  bool _isGridView = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late AnimationController _filterAnimationController;
  late AnimationController _searchAnimationController;
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
    _searchController.dispose();
    super.dispose();
  }

  /// Helper method para filtrar productos
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
              producto.ubicacion
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
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

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final esProductor =
        authProvider.userProfile?.tipo == AppConstants.rolProductor;

    return Scaffold(
      body: Column(
        children: [
          // Barra de búsqueda animada
          _buildSearchBar(),
          // Filtros animados
          _buildFilterChips(),
          // Lista de productos
          _buildProductsList(productProvider),
        ],
      ),
      // Botón flotante mejorado para productores
      floatingActionButton: esProductor ? _buildFloatingActionButton() : null,
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
              // Botón de vista
              Container(
                margin: const EdgeInsets.only(right: AppTheme.space8),
                child: IconButtonWithRipple(
                  icon: _isGridView ? Icons.view_list : Icons.grid_view,
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                  size: 44,
                  iconColor: AppTheme.primaryGreen,
                  backgroundColor: AppTheme.accentGreen.withOpacity(0.1),
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
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: AppTheme.space8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
          itemCount: ['Todas', ...AppConstants.variedadesPina].length,
          itemBuilder: (context, index) {
            final variedad =
                index == 0 ? 'Todas' : AppConstants.variedadesPina[index - 1];
            final isSelected = _filterVariedad == variedad;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: AppTheme.space8),
              child: FilterChip(
                label: Text(
                  variedad,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
    );
  }

  Widget _buildProductsList(ProductProvider productProvider) {
    return Expanded(
      child: productProvider.isLoading
          ? const ProductCardSkeleton(count: 5)
          : productProvider.productos.isEmpty
              ? EmptyWidget(
                  title: 'No hay productos',
                  message: '¡Sé el primero en publicar productos frescos!',
                  icon: Icons.store_outlined,
                  onAction: () {
                    Navigator.pushNamed(context, '/add_product');
                  },
                  actionButtonText: 'Publicar producto',
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
      child: _isGridView
          ? _buildGridView(filteredProducts)
          : _buildListView(filteredProducts),
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

  Widget _buildFloatingActionButton() {
    return AnimatedFloatingActionButton(
      icon: Icons.add,
      tooltip: 'Agregar producto',
      onPressed: () {
        Navigator.pushNamed(context, '/add_product');
      },
      isExtended: false,
      gradient: AppTheme.goldGradient,
    );
  }
}
