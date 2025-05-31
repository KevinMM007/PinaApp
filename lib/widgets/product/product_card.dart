import 'package:flutter/material.dart';
import 'package:pina_app/models/producto.dart';
import 'package:pina_app/config/theme.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatefulWidget {
  final Producto producto;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.producto,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: AppTheme.elevationMedium,
      end: AppTheme.elevationHigh,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppTheme.space8,
                vertical: AppTheme.space6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: AppTheme.createShadow(
                  elevation: _elevationAnimation.value,
                  opacity: 0.15,
                ),
              ),
              child: Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                color: AppTheme.cardWhite,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  splashColor: AppTheme.primaryGreen.withOpacity(0.1),
                  highlightColor: AppTheme.primaryGreen.withOpacity(0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del producto con overlay gradiente
                      _buildImageSection(),
                      // Información del producto
                      _buildInfoSection(formatCurrency),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusLarge),
      ),
      child: Stack(
        children: [
          // Imagen principal
          widget.producto.fotos.isNotEmpty
              ? Image.network(
                  widget.producto.fotos[0],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Container(
                      height: 180,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.backgroundLight,
                            AppTheme.divider,
                          ],
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 3,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                )
              : _buildPlaceholderImage(),

          // Overlay gradiente sutil
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Badge de calidad
          Positioned(
            top: AppTheme.space12,
            right: AppTheme.space12,
            child: _buildQualityBadge(),
          ),

          // Indicador de múltiples fotos
          if (widget.producto.fotos.length > 1)
            Positioned(
              top: AppTheme.space12,
              left: AppTheme.space12,
              child: _buildPhotoCountIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.local_florist,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildQualityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.createShadow(
          elevation: AppTheme.elevationLow,
          opacity: 0.2,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: Colors.white,
          ),
          SizedBox(width: AppTheme.space4),
          Text(
            'Premium',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCountIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_library,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: AppTheme.space4),
          Text(
            '${widget.producto.fotos.length}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(NumberFormat formatCurrency) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del producto
          Text(
            widget.producto.titulo,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppTheme.space8),

          // Variedad con icono
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space8,
                  vertical: AppTheme.space4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.eco,
                      size: 14,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: AppTheme.space4),
                    Text(
                      widget.producto.variedad,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.space12),

          // Precio y cantidad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Precio con gradiente
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space12,
                  vertical: AppTheme.space6,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.warmGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  boxShadow: AppTheme.createShadow(
                    elevation: AppTheme.elevationLow,
                    color: AppTheme.accentOrange,
                    opacity: 0.3,
                  ),
                ),
                child: Text(
                  formatCurrency.format(widget.producto.precio),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              // Cantidad disponible
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space8,
                  vertical: AppTheme.space4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: AppTheme.divider,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${widget.producto.cantidadDisponible} ${widget.producto.unidadPrecio}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.space12),

          // Ubicación
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppTheme.textSecondary.withOpacity(0.8),
              ),
              const SizedBox(width: AppTheme.space4),
              Expanded(
                child: Text(
                  widget.producto.ubicacion,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.space8),

          // Línea divisoria sutil
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.divider,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
