import 'package:flutter/material.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/screens/marketplace/marketplace_screen.dart';
import 'package:pina_app/screens/profile/profile_screen.dart';
import 'package:pina_app/widgets/common/animated_buttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late AnimationController _appBarAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Color?> _appBarColorAnimation;

  // Pantallas principales de la aplicación
  final List<Widget> _screens = [
    const MarketplaceScreen(),
    const _MessagesScreen(), // Pantalla temporal para mensajes
    const ProfileScreen(),
  ];

  final List<String> _screenTitles = [
    'Mercado',
    'Mensajes',
    'Perfil',
  ];

  final List<IconData> _screenIcons = [
    Icons.store,
    Icons.message,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Controlador para animación del FAB
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Controlador para animación del AppBar
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _appBarColorAnimation = ColorTween(
      begin: AppTheme.primaryGreen,
      end: AppTheme.accentGreen,
    ).animate(CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animaciones
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      // Animar cambio de página
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );

      // Animar AppBar si es necesario
      if (index == 1) {
        // Mensajes
        _appBarAnimationController.forward();
      } else {
        _appBarAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // AppBar personalizado
            _buildCustomAppBar(),
            // Contenido principal
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: _screens,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCustomAppBar() {
    return AnimatedBuilder(
      animation: _appBarColorAnimation,
      builder: (context, child) {
        return Container(
          height: MediaQuery.of(context).padding.top + 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _appBarColorAnimation.value ?? AppTheme.primaryGreen,
                AppTheme.primaryGreen,
              ],
            ),
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
                  // Logo y título
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.local_florist,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppTheme.space12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              AppConstants.appName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              _screenTitles[_currentIndex],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Acciones del AppBar
                  if (_currentIndex == 0) // Solo en Marketplace
                    IconButtonWithRipple(
                      icon: Icons.notifications_outlined,
                      onPressed: () {
                        // TODO: Implementar notificaciones
                      },
                      iconColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      size: 40,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: List.generate(_screens.length, (index) {
            final isSelected = _currentIndex == index;
            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _screenIcons[index],
                  size: 24,
                ),
              ),
              label: _screenTitles[index],
            );
          }),
        ),
      ),
    );
  }
}

// Pantalla temporal para mensajes
class _MessagesScreen extends StatefulWidget {
  const _MessagesScreen({Key? key}) : super(key: key);

  @override
  State<_MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<_MessagesScreen>
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
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
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
                    child: const Icon(
                      Icons.message_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space24),
                  Text(
                    'Mensajes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppTheme.space12),
                  Text(
                    'Esta funcionalidad estará disponible\nen el módulo 2 de la aplicación',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.space32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space20,
                      vertical: AppTheme.space12,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.createShadow(
                        elevation: AppTheme.elevationLow,
                        color: AppTheme.primaryGold,
                        opacity: 0.3,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: AppTheme.space8),
                        Text(
                          'Próximamente',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
