import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/product_provider.dart';
import 'package:pina_app/providers/favorites_provider.dart';
import 'package:pina_app/providers/necesidades_provider.dart';
import 'package:pina_app/screens/auth/login_screen.dart';
import 'package:pina_app/screens/splash/splash_screen.dart';
import 'package:pina_app/screens/auth/register_screen.dart';
import 'package:pina_app/screens/auth/forgot_password_screen.dart';
import 'package:pina_app/screens/auth/email_verification_screen.dart';
import 'package:pina_app/screens/home_screen.dart';
import 'package:pina_app/screens/marketplace/marketplace_screen.dart';
import 'package:pina_app/screens/marketplace/product_detail_screen.dart';
import 'package:pina_app/screens/marketplace/add_product_screen.dart';
import 'package:pina_app/screens/marketplace/favorites_screen.dart';
import 'package:pina_app/screens/marketplace/necesidades_screen.dart';
import 'package:pina_app/screens/marketplace/add_necesidad_screen.dart';
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
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => NecesidadesProvider()),
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
          '/favorites': (context) => const FavoritesScreen(),
          '/necesidades': (context) => const NecesidadesScreen(),
          '/add_necesidad': (context) => const AddNecesidadScreen(),
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

        // Si no está inicializado, mostrar splash screen
        if (!authProvider.isInitialized) {
          return const SplashScreen();
        }

        // Si está autenticado, inicializar providers dependientes y mostrar HomeScreen
        if (authProvider.isAuthenticated) {
          // Inicializar providers dependientes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.user != null) {
              final favoritesProvider =
                  Provider.of<FavoritesProvider>(context, listen: false);
              final necesidadesProvider =
                  Provider.of<NecesidadesProvider>(context, listen: false);

              // Cargar favoritos del usuario
              favoritesProvider.cargarFavoritos(authProvider.user!.uid);

              // Cargar necesidades generales (no específicas del usuario)
              necesidadesProvider.cargarNecesidades();
            }
          });

          return const HomeScreen();
        }

        // Si no está autenticado, mostrar LoginScreen
        return const LoginScreen();
      },
    );
  }
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
