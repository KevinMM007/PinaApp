import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/models/producto.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/product_provider.dart';
import 'package:pina_app/widgets/product/favorite_button.dart';
import 'package:pina_app/widgets/common/animated_buttons.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  String? _productId;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final productId = ModalRoute.of(context)!.settings.arguments as String;
    if (_productId != productId) {
      _productId = productId;
      // Cargar producto sin esperar para evitar pantallas de carga
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadProduct();
      });
    }
  }

  Future<void> _loadProduct() async {
    if (_productId == null) return;

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    await productProvider.seleccionarProducto(_productId!);

    // Iniciar animaciones después de cargar
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final Producto? producto = productProvider.productoSeleccionado;
    final bool esPropio = producto?.idVendedor == authProvider.user?.uid;
    final formatCurrency =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);
    final formatDate = DateFormat('dd/MM/yyyy');

    return Scaffold(
      body: producto == null
          ? const SizedBox.shrink() // No mostrar nada mientras carga
          : _buildProductContent(
              producto, esPropio, formatCurrency, formatDate, authProvider),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Producto no encontrado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContent(
      Producto producto,
      bool esPropio,
      NumberFormat formatCurrency,
      DateFormat formatDate,
      AuthProvider authProvider) {
    return CustomScrollView(
      slivers: [
        // App Bar personalizado con imagen
        SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          elevation: 0,
          backgroundColor: AppTheme.primaryGreen,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FavoriteButton(
                  productoId: producto.id!,
                  size: 40,
                  showBackground: false,
                ),
              ),
            ),
            if (esPropio)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () =>
                        _mostrarMenuOpciones(context, producto.id ?? ''),
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ),
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageGallery(producto),
          ),
        ),

        // Contenido del producto
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildProductInfo(
                  producto, formatCurrency, formatDate, esPropio, authProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(Producto producto) {
    if (producto.fotos.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo2.png',
                width: 80,
                height: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              const Text(
                'Piña',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: producto.fotos.length,
          itemBuilder: (context, index) {
            return Hero(
              tag: 'product-image-${producto.id}',
              child: Image.network(
                producto.fotos[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          size: 50, color: Colors.white),
                    ),
                  );
                },
              ),
            );
          },
        ),

        // Indicadores de página
        if (producto.fotos.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                producto.fotos.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: index == _currentImageIndex ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: index == _currentImageIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo(Producto producto, NumberFormat formatCurrency,
      DateFormat formatDate, bool esPropio, AuthProvider authProvider) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y badges
            _buildHeader(producto),
            const SizedBox(height: 20),

            // Precio y cantidad
            _buildPriceSection(producto, formatCurrency),
            const SizedBox(height: 24),

            // Descripción
            _buildDescriptionSection(producto),
            const SizedBox(height: 24),

            // Información adicional
            _buildInfoCards(producto, formatDate),
            const SizedBox(height: 32),

            // Botones de acción
            if (!esPropio &&
                authProvider.userProfile?.tipo == AppConstants.rolComprador)
              _buildActionButtons(producto),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Producto producto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          producto.titulo,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildBadge(
              label: producto.variedad,
              icon: Icons.eco,
              gradient: AppTheme.primaryGradient,
            ),
            _buildBadge(
              label: producto.calidad,
              icon: _getQualityIcon(producto.calidad),
              gradient: _getQualityGradient(producto.calidad),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(
      {required String label,
      required IconData icon,
      required LinearGradient gradient}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.createShadow(
          elevation: AppTheme.elevationLow,
          opacity: 0.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(Producto producto, NumberFormat formatCurrency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.warmGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.createShadow(
          elevation: AppTheme.elevationMedium,
          color: AppTheme.accentOrange,
          opacity: 0.3,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Precio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                formatCurrency.format(producto.precio),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'por ${producto.unidadPrecio}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Disponible',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${producto.cantidadDisponible}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                producto.unidadPrecio,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Producto producto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Text(
            producto.descripcion,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(Producto producto, DateFormat formatDate) {
    return Column(
      children: [
        _buildInfoCard(
          icon: Icons.location_on,
          title: 'Ubicación',
          value: producto.ubicacion,
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.calendar_today,
          title: 'Fecha de publicación',
          value: formatDate.format(producto.fechaPublicacion),
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.createShadow(
          elevation: AppTheme.elevationLow,
          opacity: 0.1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Producto producto) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: AnimatedElevatedButton(
            onPressed: () {
              // TODO: Implementar chat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de chat próximamente')),
              );
            },
            backgroundColor: AppTheme.primaryGreen,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Contactar vendedor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: AnimatedElevatedButton(
            onPressed: () {
              // TODO: Implementar ofertas
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Función de ofertas próximamente')),
              );
            },
            backgroundColor: AppTheme.accentOrange,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Hacer oferta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getQualityIcon(String calidad) {
    switch (calidad.toLowerCase()) {
      case 'premium':
        return Icons.star;
      case 'estándar':
      case 'estandar':
        return Icons.check_circle;
      case 'segunda':
        return Icons.eco;
      default:
        return Icons.local_florist;
    }
  }

  LinearGradient _getQualityGradient(String calidad) {
    switch (calidad.toLowerCase()) {
      case 'premium':
        return AppTheme.goldGradient;
      case 'estándar':
      case 'estandar':
        return AppTheme.primaryGradient;
      case 'segunda':
        return LinearGradient(
          colors: [Colors.grey[600]!, Colors.grey[700]!],
        );
      default:
        return AppTheme.primaryGradient;
    }
  }

  void _mostrarMenuOpciones(BuildContext context, String productoId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Eliminar producto',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoEliminar(context, productoId);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context, String productoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar producto'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este producto? Esta acción no se puede deshacer.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final productProvider =
                  Provider.of<ProductProvider>(context, listen: false);
              final success =
                  await productProvider.eliminarProducto(productoId);

              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto eliminado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(productProvider.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
