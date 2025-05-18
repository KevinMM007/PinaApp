import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/providers/product_provider.dart';
import 'package:pina_app/screens/auth/login_screen.dart';
import 'package:pina_app/screens/auth/register_screen.dart';
import 'package:pina_app/screens/home_screen.dart';
import 'package:pina_app/screens/marketplace/marketplace_screen.dart';
import 'package:pina_app/screens/marketplace/product_detail_screen.dart';
import 'package:pina_app/screens/marketplace/add_product_screen.dart';
import 'package:pina_app/config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'PiñaApp',
            theme: AppTheme.lightTheme,
            home: authProvider.isAuthenticated ? const HomeScreen() : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/marketplace': (context) => const MarketplaceScreen(),
              '/product_detail': (context) => const ProductDetailScreen(),
              '/add_product': (context) => const AddProductScreen(),
            },
          );
        },
      ),
    );
  }
}