import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/widgets/common/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Variables de configuración
  bool _notificacionesEmail = true;
  bool _notificacionesPush = true;
  bool _mostrarTelefono = true;
  bool _mostrarUbicacion = true;
  String _idioma = 'es';
  String _tema = 'claro';
  bool _isLoadingLocalSave = false; // Estado local de guardado

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  void _cargarConfiguracion() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final config = authProvider.userProfile?.configuracion ?? {};
    
    setState(() {
      _notificacionesEmail = config['notificacionesEmail'] ?? true;
      _notificacionesPush = config['notificacionesPush'] ?? true;
      _mostrarTelefono = config['mostrarTelefono'] ?? true;
      _mostrarUbicacion = config['mostrarUbicacion'] ?? true;
      _idioma = config['idioma'] ?? 'es';
      _tema = config['tema'] ?? 'claro';
    });
  }

  Future<void> _guardarConfiguracion() async {
    setState(() {
      _isLoadingLocalSave = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final configuracion = {
      'notificacionesEmail': _notificacionesEmail,
      'notificacionesPush': _notificacionesPush,
      'mostrarTelefono': _mostrarTelefono,
      'mostrarUbicacion': _mostrarUbicacion,
      'idioma': _idioma,
      'tema': _tema,
    };

    final success = await authProvider.actualizarConfiguracion(configuracion);

    setState(() {
      _isLoadingLocalSave = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración guardada correctamente'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Notificaciones
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notificaciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        SwitchListTile(
                          title: const Text('Notificaciones por email'),
                          subtitle: const Text('Recibir notificaciones en tu correo'),
                          value: _notificacionesEmail,
                          onChanged: (value) {
                            setState(() {
                              _notificacionesEmail = value;
                            });
                          },
                        ),
                        
                        SwitchListTile(
                          title: const Text('Notificaciones push'),
                          subtitle: const Text('Recibir notificaciones en la app'),
                          value: _notificacionesPush,
                          onChanged: (value) {
                            setState(() {
                              _notificacionesPush = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Privacidad
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Privacidad',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        SwitchListTile(
                          title: const Text('Mostrar teléfono'),
                          subtitle: const Text('Permitir que otros usuarios vean tu teléfono'),
                          value: _mostrarTelefono,
                          onChanged: (value) {
                            setState(() {
                              _mostrarTelefono = value;
                            });
                          },
                        ),
                        
                        SwitchListTile(
                          title: const Text('Mostrar ubicación'),
                          subtitle: const Text('Permitir que otros usuarios vean tu ubicación'),
                          value: _mostrarUbicacion,
                          onChanged: (value) {
                            setState(() {
                              _mostrarUbicacion = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Apariencia
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Apariencia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('Idioma'),
                          subtitle: Text(_idioma == 'es' ? 'Español' : 'English'),
                          trailing: DropdownButton<String>(
                            value: _idioma,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 'es',
                                child: Text('Español'),
                              ),
                              DropdownMenuItem(
                                value: 'en',
                                child: Text('English'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _idioma = value!;
                              });
                            },
                          ),
                        ),
                        
                        const Divider(),
                        
                        ListTile(
                          leading: const Icon(Icons.brightness_6),
                          title: const Text('Tema'),
                          subtitle: Text(_tema == 'claro' ? 'Claro' : 'Oscuro'),
                          trailing: DropdownButton<String>(
                            value: _tema,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 'claro',
                                child: Text('Claro'),
                              ),
                              DropdownMenuItem(
                                value: 'oscuro',
                                child: Text('Oscuro'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _tema = value!;
                              });
                              // TODO: Implementar cambio de tema
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cambio de tema próximamente disponible'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Cuenta
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Acerca de'),
                        subtitle: const Text('Información de la aplicación'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _mostrarAcercaDe();
                        },
                      ),
                      
                      const Divider(height: 1),
                      
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Ayuda'),
                        subtitle: const Text('Centro de ayuda y soporte'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/help');
                        },
                      ),
                      
                      const Divider(height: 1),
                      
                      ListTile(
                        leading: const Icon(Icons.policy_outlined),
                        title: const Text('Términos y Condiciones'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/terms');
                        },
                      ),
                      
                      const Divider(height: 1),
                      
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Política de Privacidad'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/privacy');
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Zona peligrosa
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Zona Peligrosa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        ListTile(
                          leading: const Icon(Icons.delete_forever, color: Colors.red),
                          title: const Text('Eliminar cuenta'),
                          subtitle: const Text('Esta acción no se puede deshacer'),
                          onTap: () {
                            _mostrarDialogoEliminarCuenta();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                CustomButton(
                  text: 'Guardar Configuración',
                  onPressed: _guardarConfiguracion,
                  isLoading: _isLoadingLocalSave, // Usar estado local
                  width: double.infinity,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _mostrarAcercaDe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de PiñaApp'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PiñaApp v1.0.0'),
            SizedBox(height: 8),
            Text('Aplicación para conectar productores y compradores de piña.'),
            SizedBox(height: 16),
            Text('Desarrollado con Flutter'),
            Text('© 2025 PiñaApp'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminarCuenta() {
    final passwordController = TextEditingController();
    bool isPasswordEmpty = true;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Eliminar Cuenta',
                style: TextStyle(color: Colors.red),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '⚠️ Esta acción eliminará permanentemente tu cuenta y todos tus datos. No se puede deshacer.',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Para confirmar, ingresa tu contraseña:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    onChanged: (value) {
                      setDialogState(() {
                        isPasswordEmpty = value.trim().isEmpty;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      helperText: 'Ingresa tu contraseña actual',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    passwordController.dispose();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: isPasswordEmpty || authProvider.isLoading
                          ? null
                          : () async {
                              // Ocultar el teclado
                              FocusScope.of(context).unfocus();
                              
                              try {
                                final success = await authProvider.eliminarCuenta(
                                  passwordController.text.trim(),
                                );

                                if (success && context.mounted) {
                                  // Cerrar el diálogo primero
                                  Navigator.pop(context);
                                  
                                  // Mostrar mensaje de éxito
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cuenta eliminada correctamente'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  
                                  // El AuthWrapper se encargará de mostrar la pantalla de login
                                  // ya que el usuario ya no está autenticado
                                } else if (context.mounted && !success) {
                                  // Mostrar error pero no cerrar el diálogo
                                  String errorMessage = authProvider.error;
                                  if (errorMessage.contains('wrong-password')) {
                                    errorMessage = 'Contraseña incorrecta';
                                  } else if (errorMessage.isEmpty) {
                                    errorMessage = 'Error al eliminar la cuenta';
                                  }
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMessage),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error inesperado: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Eliminar'),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Limpiar el controlador cuando se cierre el diálogo
      passwordController.dispose();
    });
  }
}
