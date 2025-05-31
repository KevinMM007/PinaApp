import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/utils/validators.dart';
import 'package:pina_app/widgets/common/custom_button.dart';
import 'package:pina_app/widgets/common/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailEnviado = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _recuperarContrasena() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.recuperarContrasena(
        _emailController.text.trim(),
      );

      if (success) {
        setState(() {
          _emailEnviado = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de recuperación enviado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (authProvider.error.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Icono
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.orange, width: 3),
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 50,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 32),

                if (!_emailEnviado) ...[
                  // Instrucciones
                  const Text(
                    'Recupera tu contraseña',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Ingresa tu correo electrónico y te enviaremos las instrucciones para restablecer tu contraseña.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  CustomTextField(
                    label: 'Correo electrónico',
                    hint: 'ejemplo@correo.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: Validators.validateEmail,
                  ),

                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Enviar Instrucciones',
                    isLoading: authProvider.isLoading,
                    onPressed: _recuperarContrasena,
                    width: double.infinity,
                  ),
                ] else ...[
                  // Confirmación de envío
                  const Icon(
                    Icons.mark_email_read,
                    size: 80,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '¡Email enviado!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Hemos enviado las instrucciones para restablecer tu contraseña a:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _emailController.text.trim(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Revisa tu bandeja de entrada y la carpeta de spam. El enlace de recuperación expira en 1 hora.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _emailEnviado = false;
                            });
                          },
                          child: const Text('Cambiar Email'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: 'Reenviar',
                          onPressed: _recuperarContrasena,
                          isLoading: authProvider.isLoading,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Volver al inicio de sesión',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
