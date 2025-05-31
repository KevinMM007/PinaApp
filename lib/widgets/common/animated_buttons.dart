import 'package:flutter/material.dart';
import 'package:pina_app/config/theme.dart';

/// Botón principal con gradiente y animaciones
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final Gradient? gradient;
  final Color? textColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.gradient,
    this.textColor,
    this.elevation,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
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
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: isEnabled ? (_) => _animationController.forward() : null,
              onTapUp: isEnabled ? (_) => _animationController.reverse() : null,
              onTapCancel: isEnabled ? () => _animationController.reverse() : null,
              child: Container(
                width: widget.isExpanded ? double.infinity : null,
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? (widget.gradient ?? AppTheme.primaryGradient)
                      : LinearGradient(
                          colors: [
                            AppTheme.textHint,
                            AppTheme.textHint.withOpacity(0.8),
                          ],
                        ),
                  borderRadius: widget.borderRadius ??
                      BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: isEnabled
                      ? AppTheme.createShadow(
                          elevation: widget.elevation ?? AppTheme.elevationMedium,
                          color: AppTheme.primaryGreen,
                          opacity: 0.3,
                        )
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isEnabled ? widget.onPressed : null,
                    borderRadius: widget.borderRadius ??
                        BorderRadius.circular(AppTheme.radiusMedium),
                    child: Padding(
                      padding: widget.padding ??
                          const EdgeInsets.symmetric(
                            vertical: AppTheme.space16,
                            horizontal: AppTheme.space24,
                          ),
                      child: Row(
                        mainAxisSize: widget.isExpanded
                            ? MainAxisSize.max
                            : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          else if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 20,
                              color: widget.textColor ?? Colors.white,
                            ),
                            const SizedBox(width: AppTheme.space8),
                          ],
                          if (!widget.isLoading)
                            Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: widget.textColor ?? Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                        ],
                      ),
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
}

/// Botón outlined con animaciones
class AnimatedOutlinedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final Color? borderColor;
  final Color? textColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AnimatedOutlinedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.borderColor,
    this.textColor,
    this.borderWidth = 2,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<AnimatedOutlinedButton> createState() => _AnimatedOutlinedButtonState();
}

class _AnimatedOutlinedButtonState extends State<AnimatedOutlinedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _backgroundColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: (widget.borderColor ?? AppTheme.primaryGreen).withOpacity(0.1),
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
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final borderColor = widget.borderColor ?? AppTheme.primaryGreen;
    final textColor = widget.textColor ?? borderColor;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled ? (_) => _animationController.forward() : null,
            onTapUp: isEnabled ? (_) => _animationController.reverse() : null,
            onTapCancel: isEnabled ? () => _animationController.reverse() : null,
            child: Container(
              width: widget.isExpanded ? double.infinity : null,
              decoration: BoxDecoration(
                color: _backgroundColorAnimation.value,
                border: Border.all(
                  color: isEnabled ? borderColor : AppTheme.textHint,
                  width: widget.borderWidth,
                ),
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: widget.borderRadius ??
                      BorderRadius.circular(AppTheme.radiusMedium),
                  child: Padding(
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(
                          vertical: AppTheme.space16,
                          horizontal: AppTheme.space24,
                        ),
                    child: Row(
                      mainAxisSize: widget.isExpanded
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isEnabled ? textColor : AppTheme.textHint,
                              ),
                            ),
                          )
                        else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 20,
                            color: isEnabled ? textColor : AppTheme.textHint,
                          ),
                          const SizedBox(width: AppTheme.space8),
                        ],
                        if (!widget.isLoading)
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isEnabled ? textColor : AppTheme.textHint,
                              letterSpacing: 0.5,
                            ),
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
}

/// Floating Action Button mejorado con animaciones
class AnimatedFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool isExtended;
  final String? label;
  final Gradient? gradient;

  const AnimatedFloatingActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.isExtended = false,
    this.label,
    this.gradient,
  }) : super(key: key);

  @override
  State<AnimatedFloatingActionButton> createState() =>
      _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState
    extends State<AnimatedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.gradient ?? AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(
                    widget.isExtended ? AppTheme.radiusLarge : 28,
                  ),
                  boxShadow: AppTheme.createShadow(
                    elevation: AppTheme.elevationHigh,
                    color: AppTheme.primaryGold,
                    opacity: 0.4,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    borderRadius: BorderRadius.circular(
                      widget.isExtended ? AppTheme.radiusLarge : 28,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(
                        widget.isExtended ? AppTheme.space12 : AppTheme.space16,
                      ),
                      child: widget.isExtended && widget.label != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.icon,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: AppTheme.space8),
                                Text(
                                  widget.label!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            )
                          : Icon(
                              widget.icon,
                              size: 24,
                              color: Colors.white,
                            ),
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
}

/// Botón de icono con efecto ripple
class IconButtonWithRipple extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const IconButtonWithRipple({
    Key? key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 48,
    this.tooltip,
  }) : super(key: key);

  @override
  State<IconButtonWithRipple> createState() => _IconButtonWithRippleState();
}

class _IconButtonWithRippleState extends State<IconButtonWithRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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
    final iconColor = widget.iconColor ?? AppTheme.primaryGreen;
    final backgroundColor = widget.backgroundColor ?? AppTheme.surfaceWhite;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: AppTheme.createShadow(
                elevation: AppTheme.elevationLow,
                opacity: 0.1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(widget.size / 2),
                splashColor: iconColor.withOpacity(0.2),
                highlightColor: iconColor.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: widget.size * 0.5,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
