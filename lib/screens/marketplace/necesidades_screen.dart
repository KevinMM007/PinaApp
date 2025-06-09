import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/models/necesidad_compra.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/necesidades_provider.dart';
import 'package:pina_app/widgets/common/enhanced_ui_components.dart';
import 'package:pina_app/widgets/marketplace/necesidad_card.dart';
import 'package:intl/intl.dart';

class NecesidadesScreen extends StatefulWidget {
  const NecesidadesScreen({Key? key}) : super(key: key);

  @override
  State<NecesidadesScreen> createState() => _NecesidadesScreenState();
}

class _NecesidadesScreenState extends State<NecesidadesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String _filterVariedad = 'Todas';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Cargar necesidades y animar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NecesidadesProvider>(context, listen: false)
          .cargarNecesidades();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<NecesidadCompra> _getFilteredNecesidades(
      List<NecesidadCompra> necesidades) {
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

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final esComprador =
        authProvider.userProfile?.tipo == AppConstants.rolComprador;

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
            _buildSearchBar(),
            _buildTabBar(),
            _buildFilterChips(),
            Expanded(child: _buildTabBarView()),
          ],
        ),
      ),
      floatingActionButton: esComprador ? _buildFloatingActionButton() : null,
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
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              // Título
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Necesidades de Compra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Consumer<NecesidadesProvider>(
                      builder: (context, necesidadesProvider, child) {
                        final count =
                            necesidadesProvider.necesidadesActivas.length;
                        return Text(
                          '$count solicitud${count != 1 ? 'es' : ''} activa${count != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Botón de información
              IconButton(
                onPressed: () => _showInfoDialog(),
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Buscar necesidades...',
            prefixIcon: const Icon(
              Icons.search,
              color: AppTheme.textSecondary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
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
        tabs: const [
          Tab(text: 'Activas'),
          Tab(text: 'Vencidas'),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: AppTheme.space8),
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
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildNecesidadesList(activas: true),
        _buildNecesidadesList(activas: false),
      ],
    );
  }

  Widget _buildNecesidadesList({required bool activas}) {
    return Consumer<NecesidadesProvider>(
      builder: (context, necesidadesProvider, child) {
        if (necesidadesProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final necesidades = activas
            ? necesidadesProvider.necesidadesActivas
            : necesidadesProvider.necesidadesVencidas;

        final filteredNecesidades = _getFilteredNecesidades(necesidades);

        if (filteredNecesidades.isEmpty) {
          return _buildEmptyState(activas);
        }

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomRefreshIndicator(
              onRefresh: () async {
                necesidadesProvider.cargarNecesidades();
              },
              refreshText: 'Desliza para actualizar',
              releaseText: 'Suelta para buscar nuevas necesidades',
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.space8),
                itemCount: filteredNecesidades.length,
                itemBuilder: (context, index) {
                  final necesidad = filteredNecesidades[index];

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
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool activas) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: AppTheme.createShadow(
                    elevation: AppTheme.elevationMedium,
                    color: AppTheme.primaryGreen,
                    opacity: 0.3,
                  ),
                ),
                child: Icon(
                  activas ? Icons.shopping_cart_outlined : Icons.schedule,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppTheme.space24),
              Text(
                activas
                    ? 'No hay necesidades activas'
                    : 'No hay necesidades vencidas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: AppTheme.space12),
              Text(
                activas
                    ? 'Los compradores podrán publicar\\nsus necesidades aquí'
                    : 'Las necesidades vencidas\\naparecerán en esta sección',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/add_necesidad');
      },
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_shopping_cart),
      label: const Text('Nueva Necesidad'),
    );
  }

  void _showNecesidadDetail(NecesidadCompra necesidad) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLarge),
              ),
            ),
            child: Column(
              children: [
                // Handle para drag
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppTheme.space16),
                    child: _buildNecesidadDetailContent(necesidad),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNecesidadDetailContent(NecesidadCompra necesidad) {
    final formatCurrency = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 0,
    );
    final formatDate = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y estado
        Row(
          children: [
            Expanded(
              child: Text(
                necesidad.titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: necesidad.isExpired ? Colors.red : AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                necesidad.isExpired ? 'Vencida' : 'Activa',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space16),

        // Información básica
        _buildDetailCard([
          _buildDetailRow('Variedad', necesidad.variedad),
          _buildDetailRow('Calidad', necesidad.calidad),
          _buildDetailRow(
              'Cantidad', '${necesidad.cantidadRequerida} ${necesidad.unidad}'),
          _buildDetailRow('Presupuesto', necesidad.presupuestoFormateado),
        ]),

        const SizedBox(height: AppTheme.space16),

        // Descripción
        _buildDetailCard([
          const Text(
            'Descripción',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            necesidad.descripcion,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ]),

        const SizedBox(height: AppTheme.space16),

        // Ubicación y fechas
        _buildDetailCard([
          _buildDetailRow('Ubicación preferida', necesidad.ubicacionPreferida),
          _buildDetailRow(
              'Fecha límite', formatDate.format(necesidad.fechaLimite)),
          _buildDetailRow(
              'Publicado', formatDate.format(necesidad.fechaPublicacion)),
          if (!necesidad.isExpired)
            _buildDetailRow('Días restantes', '${necesidad.diasRestantes}'),
        ]),
      ],
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.space12),
            const Text('Necesidades de Compra'),
          ],
        ),
        content: const Text(
          'Los compradores pueden publicar sus necesidades específicas para que los productores las vean y puedan ofertar sus productos.\\n\\n'
          '• Los productores pueden ver qué necesitan los compradores\\n'
          '• Los compradores especifican cantidad, calidad y presupuesto\\n'
          '• Las necesidades tienen fecha límite\\n'
          '• Solo los compradores registrados pueden publicar',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
