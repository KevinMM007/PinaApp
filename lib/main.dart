import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/product_provider.dart';
import 'package:pina_app/screens/auth/login_screen.dart';
import 'package:pina_app/screens/auth/register_screen.dart';
import 'package:pina_app/screens/auth/forgot_password_screen.dart';
import 'package:pina_app/screens/auth/email_verification_screen.dart';
import 'package:pina_app/screens/home_screen.dart';
import 'package:pina_app/screens/marketplace/marketplace_screen.dart';
import 'package:pina_app/screens/marketplace/product_detail_screen.dart';
import 'package:pina_app/screens/marketplace/add_product_screen.dart';
import 'package:pina_app/screens/profile/profile_screen.dart';
import 'package:pina_app/screens/profile/edit_profile_screen.dart';
import 'package:pina_app/screens/profile/settings_screen.dart';
import 'package:pina_app/screens/legal/terms_and_conditions_screen.dart';
import 'package:pina_app/screens/legal/privacy_policy_screen.dart';
import 'package:pina_app/screens/help/help_screen.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/config/firebase_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('✅ Firebase inicializado correctamente');

    // Configurar Firestore usando la configuración centralizada
    if (FirebaseConfig.enablePersistence) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: FirebaseConfig.cacheSize,
      );
      print('✅ Firestore configurado CON persistencia');
    } else {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
      print('⚠️ Firestore configurado SIN persistencia (temporal)');
    }
  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'PiñaApp',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          '/email_verification': (context) => const EmailVerificationScreen(),
          '/home': (context) => const HomeScreen(),
          '/marketplace': (context) => const MarketplaceScreen(),
          '/product_detail': (context) => const ProductDetailScreen(),
          '/add_product': (context) => const AddProductScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit_profile': (context) => const EditProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/terms': (context) => const TermsAndConditionsScreen(),
          '/privacy': (context) => const PrivacyPolicyScreen(),
          '/help': (context) => const HelpScreen(),
        },
      ),
    );
  }
}

// Widget para manejar el estado de autenticación
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Timer? _initTimeout;
  bool _timeoutReached = false;

  @override
  void initState() {
    super.initState();
    // Agregar timeout configurado para la inicialización
    _initTimeout =
        Timer(const Duration(seconds: FirebaseConfig.initTimeout), () {
      if (mounted &&
          !Provider.of<AuthProvider>(context, listen: false).isInitialized) {
        setState(() {
          _timeoutReached = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _initTimeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        print(
            '🔄 AuthWrapper - Authenticated: ${authProvider.isAuthenticated}, Loading: ${authProvider.isLoading}');

        // Si se alcanzó el timeout, mostrar pantalla de error
        if (_timeoutReached) {
          return _ErrorScreen(onRetry: () {
            setState(() {
              _timeoutReached = false;
            });
            // Forzar recarga
            authProvider.recargarPerfil(forceServerFetch: true);
          });
        }

        // Si aún no se ha inicializado, mostrar splash
        if (!authProvider.isInitialized) {
          return const _SplashScreen();
        }

        // Si está autenticado, mostrar HomeScreen
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        // Si no está autenticado, mostrar LoginScreen
        return const LoginScreen();
      },
    );
  }
}

// Pantalla de carga inicial mejorada
class _SplashScreen extends StatefulWidget {
  const _SplashScreen({Key? key}) : super(key: key);

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _particlesController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controlador del logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Controlador del texto
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Controlador del progress
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Controlador de partículas
    _particlesController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    // Animaciones del logo
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));
    
    // Animaciones del texto
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
    
    // Animación del progress
    _progressFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    // Secuencia de animaciones
    _startAnimationSequence();
  }
  
  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen,
              AppTheme.accentGreen,
              AppTheme.primaryGold,
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Partículas de fondo
            _buildFloatingParticles(),
            
            // Contenido principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animado
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotationAnimation.value * 0.1,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(70),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_florist,
                              size: 90,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Texto animado
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textFadeAnimation,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: Column(
                            children: [
                              const Text(
                                'PiñaApp',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 8,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Conectando productores 🍍',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.95),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 64),
                  
                  // Indicador de progreso animado
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _progressFadeAnimation,
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particlesController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(_particlesController.value),
          size: Size.infinite,
        );
      },
    );
  }
}

// Painter para las partículas flotantes
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  
  ParticlesPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    // Crear partículas en posiciones animadas
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20 * i + 
          (animationValue * 100 + i * 50) % size.width) % size.width;
      final y = (size.height / 20 * i + 
          (animationValue * 80 + i * 30) % size.height) % size.height;
      
      final radius = 2.0 + (i % 3);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Pantalla de error cuando hay problemas de conexión
class _ErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorScreen({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Problema de conexión',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No se puede conectar con el servidor.\nVerifica tu conexión a internet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Cerrar la app
                  SystemNavigator.pop();
                },
                child: const Text(
                  'Cerrar aplicación',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
