import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/favorites_provider.dart';

class FavoriteButton extends StatefulWidget {
  final String productoId;
  final double size;
  final bool showBackground;

  const FavoriteButton({
    Key? key,
    required this.productoId,
    this.size = 40,
    this.showBackground = true,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
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

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);

    if (authProvider.user != null) {
      print('Toggling favorite for product: ${widget.productoId}'); // Debug
      print('Current isFavorite status: ${favoritesProvider.isFavorite(widget.productoId)}'); // Debug
      
      final success = await favoritesProvider.toggleFavorito(
        authProvider.user!.uid,
        widget.productoId,
      );

      print('Toggle result: $success'); // Debug
      
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(favoritesProvider.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Pequeña pausa para asegurar que el estado se actualice
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted) {
          // Mostrar feedback al usuario
          final isFavoriteNow = favoritesProvider.isFavorite(widget.productoId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFavoriteNow ? 'Agregado a favoritos' : 'Removido de favoritos'),
              backgroundColor: isFavoriteNow ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoritesProvider, AuthProvider>(
      builder: (context, favoritesProvider, authProvider, child) {
        if (authProvider.user == null) {
          return const SizedBox.shrink();
        }

        final isFavorite = favoritesProvider.isFavorite(widget.productoId);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: widget.showBackground
                        ? BoxDecoration(
                            color: isFavorite
                                ? Colors.red.withOpacity(0.9)
                                : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(widget.size / 2),
                            boxShadow: AppTheme.createShadow(
                              elevation: AppTheme.elevationLow,
                              opacity: 0.2,
                            ),
                          )
                        : null,
                    child: Center(
                      child: _isProcessing
                          ? SizedBox(
                              width: widget.size * 0.5,
                              height: widget.size * 0.5,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: widget.showBackground
                                    ? (isFavorite ? Colors.white : AppTheme.primaryGreen)
                                    : Colors.white,
                              ),
                            )
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                key: ValueKey(isFavorite),
                                size: widget.size * 0.6,
                                color: widget.showBackground
                                    ? (isFavorite ? Colors.white : Colors.red)
                                    : (isFavorite ? Colors.red : Colors.white),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget simplificado para usar en listas donde el espacio es limitado
class SimpleFavoriteButton extends StatelessWidget {
  final String productoId;
  final double size;
  final Color? color;

  const SimpleFavoriteButton({
    Key? key,
    required this.productoId,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FavoriteButton(
      productoId: productoId,
      size: size,
      showBackground: false,
    );
  }
}
