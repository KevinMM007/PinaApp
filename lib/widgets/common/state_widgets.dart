import 'package:flutter/material.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/widgets/common/animated_buttons.dart';

/// Widget para mostrar estado de carga con animaciones
class LoadingWidget extends StatefulWidget {
  final String message;
  final bool showSpinner;
  final Widget? customIcon;

  const LoadingWidget({
    Key? key,
    this.message = 'Cargando...',
    this.showSpinner = true,
    this.customIcon,
  }) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: AppTheme.createShadow(
                        elevation: AppTheme.elevationMedium,
                        color: AppTheme.primaryGreen,
                        opacity: 0.3,
                      ),
                    ),
                    child: widget.customIcon ??
                        (widget.showSpinner
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 3,
                              )
                            : const Icon(
                                Icons.local_florist,
                                size: 40,
                                color: Colors.white,
                              )),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.space24),
          Text(
            widget.message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar estado de error con opción de reintentar
class ErrorWidget extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryButtonText;
  final IconData? icon;

  const ErrorWidget({
    Key? key,
    this.title = 'Algo salió mal',
    this.message =
        'Ha ocurrido un error inesperado. Por favor, intenta de nuevo.',
    this.onRetry,
    this.retryButtonText = 'Reintentar',
    this.icon,
  }) : super(key: key);

  @override
  State<ErrorWidget> createState() => _ErrorWidgetState();
}

class _ErrorWidgetState extends State<ErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de error animado
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.error.withOpacity(0.8),
                          AppTheme.error,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: AppTheme.createShadow(
                        elevation: AppTheme.elevationMedium,
                        color: AppTheme.error,
                        opacity: 0.3,
                      ),
                    ),
                    child: Icon(
                      widget.icon ?? Icons.error_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppTheme.space24),

            // Contenido animado
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Título
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppTheme.space16),

                  // Mensaje
                  Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppTheme.space32),

                  // Botón de reintentar
                  if (widget.onRetry != null)
                    GradientButton(
                      text: widget.retryButtonText,
                      icon: Icons.refresh,
                      onPressed: widget.onRetry,
                      gradient: AppTheme.warmGradient,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar estado vacío con ilustración
class EmptyWidget extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionButtonText;
  final IconData? icon;
  final Widget? illustration;

  const EmptyWidget({
    Key? key,
    this.title = 'No hay contenido',
    this.message = 'No encontramos nada aquí. ¡Sé el primero en agregar algo!',
    this.onAction,
    this.actionButtonText,
    this.icon,
    this.illustration,
  }) : super(key: key);

  @override
  State<EmptyWidget> createState() => _EmptyWidgetState();
}

class _EmptyWidgetState extends State<EmptyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustración o icono
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: widget.illustration ??
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.textHint.withOpacity(0.5),
                              AppTheme.textHint.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Icon(
                          widget.icon ?? Icons.inbox_outlined,
                          size: 60,
                          color: AppTheme.textHint,
                        ),
                      ),
                );
              },
            ),

            const SizedBox(height: AppTheme.space24),

            // Contenido con fade
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Título
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppTheme.space12),

                  // Mensaje
                  Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppTheme.space32),

                  // Botón de acción
                  if (widget.onAction != null &&
                      widget.actionButtonText != null)
                    AnimatedOutlinedButton(
                      text: widget.actionButtonText!,
                      icon: Icons.add,
                      onPressed: widget.onAction,
                      borderColor: AppTheme.primaryGreen,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar estado de búsqueda sin resultados
class NoResultsWidget extends StatelessWidget {
  final String searchTerm;
  final VoidCallback? onClearSearch;

  const NoResultsWidget({
    Key? key,
    required this.searchTerm,
    this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Sin resultados',
      message: 'No encontramos productos que coincidan con "$searchTerm".',
      actionButtonText: 'Limpiar búsqueda',
      onAction: onClearSearch,
      icon: Icons.search_off,
    );
  }
}

/// Widget para mostrar estado de conexión perdida
class ConnectionErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const ConnectionErrorWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      title: 'Sin conexión',
      message: 'Verifica tu conexión a internet e intenta nuevamente.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryButtonText: 'Reintentar',
    );
  }
}

/// Widget para mostrar mantenimiento o actualización
class MaintenanceWidget extends StatelessWidget {
  final String? estimatedTime;

  const MaintenanceWidget({
    Key? key,
    this.estimatedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Mantenimiento',
      message: estimatedTime != null
          ? 'Estamos mejorando la aplicación. Tiempo estimado: $estimatedTime'
          : 'Estamos mejorando la aplicación. Vuelve pronto.',
      icon: Icons.build,
    );
  }
}
