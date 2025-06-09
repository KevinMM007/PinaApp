import 'package:flutter/material.dart';
import 'package:pina_app/models/necesidad_compra.dart';
import 'package:pina_app/config/theme.dart';
import 'package:intl/intl.dart';

class NecesidadCard extends StatefulWidget {
  final NecesidadCompra necesidad;
  final VoidCallback onTap;

  const NecesidadCard({
    Key? key,
    required this.necesidad,
    required this.onTap,
  }) : super(key: key);

  @override
  State<NecesidadCard> createState() => _NecesidadCardState();
}

class _NecesidadCardState extends State<NecesidadCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

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
      decimalDigits: 0,
    );
    final formatDate = DateFormat('dd/MM/yyyy');

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
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con título y estado
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.necesidad.titulo,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppTheme.space8),
                            _buildStatusBadge(),
                          ],
                        ),

                        const SizedBox(height: AppTheme.space12),

                        // Información principal
                        Row(
                          children: [
                            // Variedad
                            Expanded(
                              child: _buildInfoChip(
                                icon: Icons.eco,
                                label: widget.necesidad.variedad,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: AppTheme.space8),
                            // Calidad
                            Expanded(
                              child: _buildInfoChip(
                                icon: Icons.star_outline,
                                label: widget.necesidad.calidad,
                                color: AppTheme.accentOrange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.space12),

                        // Descripción
                        Text(
                          widget.necesidad.descripcion,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: AppTheme.space16),

                        // Información de presupuesto y cantidad
                        Row(
                          children: [
                            // Presupuesto
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.space12,
                                  vertical: AppTheme.space8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.warmGradient,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Presupuesto',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      widget.necesidad.presupuestoFormateado,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: AppTheme.space8),

                            // Cantidad
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.space12,
                                  vertical: AppTheme.space8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundLight,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                  border: Border.all(color: AppTheme.divider),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Cantidad',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${widget.necesidad.cantidadRequerida} ${widget.necesidad.unidad}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.space12),

                        // Footer con ubicación y fecha
                        Row(
                          children: [
                            // Ubicación
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppTheme.textSecondary.withOpacity(0.8),
                            ),
                            const SizedBox(width: AppTheme.space4),
                            Expanded(
                              child: Text(
                                widget.necesidad.ubicacionPreferida,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppTheme.space8),
                            // Fecha límite
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.space8,
                                vertical: AppTheme.space4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.necesidad.isExpired 
                                    ? Colors.red.withOpacity(0.1)
                                    : widget.necesidad.diasRestantes <= 3
                                        ? Colors.orange.withOpacity(0.1)
                                        : AppTheme.accentGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 12,
                                    color: widget.necesidad.isExpired 
                                        ? Colors.red
                                        : widget.necesidad.diasRestantes <= 3
                                            ? Colors.orange
                                            : AppTheme.accentGreen,
                                  ),
                                  const SizedBox(width: AppTheme.space4),
                                  Text(
                                    widget.necesidad.isExpired 
                                        ? 'Vencida'
                                        : '${widget.necesidad.diasRestantes}d',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: widget.necesidad.isExpired 
                                          ? Colors.red
                                          : widget.necesidad.diasRestantes <= 3
                                              ? Colors.orange
                                              : AppTheme.accentGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    final isActive = widget.necesidad.activa && !widget.necesidad.isExpired;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryGreen : Colors.red,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.schedule,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: AppTheme.space4),
          Text(
            isActive ? 'Activa' : 'Vencida',
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppTheme.space4),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
