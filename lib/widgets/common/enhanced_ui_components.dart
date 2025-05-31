import 'package:flutter/material.dart';
import 'package:pina_app/config/theme.dart';

/// Widget de pull-to-refresh personalizado con animaciones
class CustomRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String refreshText;
  final String releaseText;
  final Color? indicatorColor;
  final double displacement;

  const CustomRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.refreshText = 'Desliza para actualizar',
    this.releaseText = 'Suelta para actualizar',
    this.indicatorColor,
    this.displacement = 40.0,
  }) : super(key: key);

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _animationController.forward();
    _rotationController.repeat();

    try {
      await widget.onRefresh();
    } finally {
      _rotationController.stop();
      await _animationController.reverse();
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.indicatorColor ?? AppTheme.primaryGreen,
      backgroundColor: AppTheme.cardWhite,
      displacement: widget.displacement,
      strokeWidth: 3.0,
      child: widget.child,
    );
  }
}

/// Loading indicator personalizado con animaciones
class CustomLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool showPulse;

  const CustomLoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 3.0,
    this.showPulse = true,
  }) : super(key: key);

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.showPulse ? _pulseController : _rotationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.showPulse ? _pulseAnimation.value : 1.0,
          child: RotationTransition(
            turns: _rotationController,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: (widget.color ?? AppTheme.primaryGreen)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(widget.strokeWidth * 2),
                child: CircularProgressIndicator(
                  strokeWidth: widget.strokeWidth,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader para cards
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final int count;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.count = 1,
    this.margin,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
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
    return Column(
      children: List.generate(widget.count, (index) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin ?? const EdgeInsets.only(bottom: 8),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [
                      ((_animation.value - 1).clamp(0.0, 1.0)),
                      ((_animation.value).clamp(0.0, 1.0)),
                      ((_animation.value + 1).clamp(0.0, 1.0)),
                    ],
                    colors: [
                      AppTheme.backgroundLight,
                      Colors.grey[300]!,
                      AppTheme.backgroundLight,
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

/// Product Card Skeleton específico
class ProductCardSkeleton extends StatelessWidget {
  final int count;

  const ProductCardSkeleton({
    Key? key,
    this.count = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.space8,
            vertical: AppTheme.space4,
          ),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen skeleton
              SkeletonLoader(
                width: double.infinity,
                height: 180,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
              // Contenido skeleton
              Padding(
                padding: EdgeInsets.all(AppTheme.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    SkeletonLoader(
                      width: 200,
                      height: 20,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(height: AppTheme.space8),
                    // Variedad
                    SkeletonLoader(
                      width: 100,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(height: AppTheme.space12),
                    // Precio y cantidad
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonLoader(
                          width: 80,
                          height: 24,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        SkeletonLoader(
                          width: 60,
                          height: 20,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.space8),
                    // Ubicación
                    SkeletonLoader(
                      width: 150,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Toast personalizado con animaciones
class CustomToast {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        position: position,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss después del duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: AppTheme.success,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.error,
      backgroundColor: AppTheme.error,
    );
  }

  static void warning(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.warning,
      backgroundColor: AppTheme.warning,
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.info,
      backgroundColor: AppTheme.info,
    );
  }
}

enum ToastPosition { top, center, bottom }

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final ToastPosition position;
  final VoidCallback onDismiss;

  const _ToastWidget({
    Key? key,
    required this.message,
    this.icon,
    this.backgroundColor,
    this.textColor,
    required this.position,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // Auto-dismiss con animación
    Future.delayed(const Duration(milliseconds: 2700), () {
      if (mounted) {
        _animationController.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position == ToastPosition.top ? 100 : null,
      bottom: widget.position == ToastPosition.bottom ? 100 : null,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space16,
                      vertical: AppTheme.space12,
                    ),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ?? AppTheme.primaryGreen,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.textColor ?? Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.space8),
                        ],
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              color: widget.textColor ?? Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
