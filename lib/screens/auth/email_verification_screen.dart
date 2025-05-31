import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/widgets/common/custom_button.dart';
import 'dart:async';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _puedeReenviar = true;
  int _tiempoRestante = 0;

  @override
  void initState() {
    super.initState();
    _iniciarTimerVerificacion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarTimerVerificacion() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.recargarUsuario();
      
      if (authProvider.isEmailVerified) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  void _iniciarTimerReenvio() {
    setState(() {
      _puedeReenviar = false;
      _tiempoRestante = 60;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tiempoRestante > 0) {
        setState(() {
          _tiempoRestante--;
        });
      } else {
        setState(() {
          _puedeReenviar = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _reenviarEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.reenviarEmailVerificacion();
    
    if (success) {
      _iniciarTimerReenvio();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email de verificación reenviado'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verificarManualmente() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.recargarUsuario();
    
    if (authProvider.isEmailVerified) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email aún no verificado. Revisa tu bandeja de entrada.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Email'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              await authProvider.cerrarSesion();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Salir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono animado
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                child: const Icon(
                  Icons.mark_email_unread,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Verifica tu correo electrónico',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Hemos enviado un enlace de verificación a:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                authProvider.user?.email ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade700,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Haz clic en el enlace del email para verificar tu cuenta. Una vez verificado, serás redirigido automáticamente. Si no encuentras el email, revisa la carpeta de spam.',
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Indicador de verificación automática
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.green.shade600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verificando automáticamente...',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botones de acción
              Column(
                children: [
                  CustomButton(
                    text: 'Ya verifiqué mi email',
                    onPressed: _verificarManualmente,
                    width: double.infinity,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _puedeReenviar ? _reenviarEmail : null,
                      child: Text(
                        _puedeReenviar 
                            ? 'Reenviar email' 
                            : 'Reenviar en ${_tiempoRestante}s',
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Cambiar de cuenta',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
