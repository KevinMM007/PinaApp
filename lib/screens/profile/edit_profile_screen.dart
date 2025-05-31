import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/utils/validators.dart';
import 'package:pina_app/widgets/common/custom_button.dart';
import 'package:pina_app/widgets/common/custom_text_field.dart';
import 'package:pina_app/screens/profile/edit_profile_productor_screen.dart';
import 'package:pina_app/screens/profile/edit_profile_comprador_screen.dart';
import 'package:pina_app/screens/profile/edit_profile_transportista_screen.dart';
import 'package:pina_app/services/storage_service.dart';
import 'package:pina_app/widgets/common/photo_picker_widget.dart';
import 'package:pina_app/widgets/common/location_picker_widget.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();
  
  // Controladores para información básica
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _ubicacionController;
  
  // Variables para foto y ubicación
  bool _isUploadingPhoto = false;
  String? _newPhotoUrl;
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userProfile!;
    
    _nombreController = TextEditingController(text: user.nombre);
    _telefonoController = TextEditingController(text: user.telefono);
    _ubicacionController = TextEditingController(text: user.ubicacion);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _guardarInformacionBasica() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Primero actualizar información básica
      final success = await authProvider.actualizarPerfilBasico(
        nombre: _nombreController.text.trim(),
        telefono: _telefonoController.text.trim(),
        ubicacion: _ubicacionController.text.trim(),
      );

      if (success) {
        // Si hay coordenadas seleccionadas, actualizar ubicación con coordenadas
        if (_selectedLatitude != null && _selectedLongitude != null) {
          await authProvider.actualizarUbicacion(
            ubicacion: _ubicacionController.text.trim(),
            latitud: _selectedLatitude!,
            longitud: _selectedLongitude!,
          );
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información actualizada correctamente'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userProfile!;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Editar Perfil'),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.person),
                  text: 'Información Básica',
                ),
                Tab(
                  icon: Icon(Icons.business),
                  text: 'Perfil Profesional',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Pestaña 1: Información Básica
              _buildBasicInfoTab(authProvider),
              
              // Pestaña 2: Perfil Específico por Rol
              _buildProfessionalTab(user.tipo),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoTab(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Avatar section
            _buildAvatarSection(),
            
            const SizedBox(height: 32),
            
            // Información personal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      label: 'Nombre completo',
                      controller: _nombreController,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: Validators.validateName,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      label: 'Teléfono',
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: Validators.validatePhone,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    LocationPickerWidget(
                      initialLatitude: _selectedLatitude,
                      initialLongitude: _selectedLongitude,
                      hintText: 'Selecciona tu ubicación',
                      onLocationSelected: (latitude, longitude, address) {
                        setState(() {
                          _selectedLatitude = latitude;
                          _selectedLongitude = longitude;
                          _ubicacionController.text = address;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Información de cuenta
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de Cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Correo electrónico'),
                      subtitle: Text(authProvider.user?.email ?? ''),
                      trailing: authProvider.isEmailVerified
                          ? const Icon(Icons.verified, color: Colors.green)
                          : const Icon(Icons.warning, color: Colors.orange),
                    ),
                    
                    if (!authProvider.isEmailVerified) ...[
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.verified_user, color: Colors.orange),
                        title: const Text('Verificar email'),
                        subtitle: const Text('Tu email no está verificado'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/email_verification');
                        },
                      ),
                    ],
                    
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Cambiar contraseña'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _mostrarDialogoCambiarContrasena();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            CustomButton(
              text: 'Guardar Cambios',
              onPressed: _guardarInformacionBasica,
              isLoading: authProvider.isLoading,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Usar la nueva foto si existe, o la foto actual del perfil
        final displayPhotoUrl = _newPhotoUrl ?? authProvider.userProfile?.fotoPerfil;
        
        print('🖼️ Construyendo avatar - URL: ${displayPhotoUrl ?? "Sin foto"}');
        print('   - isUploadingPhoto: $_isUploadingPhoto');
        
        return Center(
          child: PhotoPickerWidget(
            currentPhotoUrl: displayPhotoUrl,
            size: 120,
            isLoading: _isUploadingPhoto,
            onPhotoSelected: (XFile image) async {
              print('🖼️ onPhotoSelected llamado');
              await _subirFotoPerfil(image);
            },
          ),
        );
      },
    );
  }

  Future<void> _subirFotoPerfil(XFile image) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Verificar si Storage está habilitado
    if (!AppConstants.storageEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La subida de fotos estará disponible próximamente'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      print('📸 Iniciando subida de foto de perfil...');
      
      // Subir imagen a Firebase Storage
      final photoUrl = await _storageService.subirImagenPerfil(
        userId: authProvider.user!.uid,
        imagen: image,
      );

      if (photoUrl != null) {
        print('✅ Foto subida a Storage: $photoUrl');
        
        // Actualizar URL en estado local inmediatamente
        setState(() {
          _newPhotoUrl = photoUrl;
        });
        
        // Actualizar en Firestore
        final success = await authProvider.actualizarFotoPerfil(photoUrl);
        
        if (success) {
          print('✅ Foto actualizada en Firestore');
          
          // Forzar recarga del perfil para asegurar que se actualice
          await authProvider.recargarPerfil(forceServerFetch: true);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto de perfil actualizada'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          print('❌ Error actualizando en Firestore');
          
          // Si falla, eliminar la imagen subida
          await _storageService.eliminarImagen(photoUrl);
          setState(() {
            _newPhotoUrl = null;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al actualizar foto: ${authProvider.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        print('❌ No se pudo subir la imagen a Storage');
        throw Exception('No se pudo subir la imagen');
      }
    } catch (e) {
      print('❌ Error en _subirFotoPerfil: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
          // Limpiar la URL temporal después de actualizar
          if (_newPhotoUrl != null && authProvider.userProfile?.fotoPerfil == _newPhotoUrl) {
            _newPhotoUrl = null;
          }
        });
      }
    }
  }

  Widget _buildProfessionalTab(String tipo) {
    switch (tipo) {
      case AppConstants.rolProductor:
        return const EditProfileProductorScreen();
      case AppConstants.rolComprador:
        return const EditProfileCompradorScreen();
      case AppConstants.rolTransportista:
        return const EditProfileTransportistaScreen();
      default:
        return const Center(
          child: Text('Tipo de perfil no reconocido'),
        );
    }
  }

  void _mostrarDialogoCambiarContrasena() {
    final contrasenaActualController = TextEditingController();
    final nuevaContrasenaController = TextEditingController();
    final confirmarContrasenaController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: contrasenaActualController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) => Validators.validateRequired(value, 'la contraseña actual'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nuevaContrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmarContrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value != nuevaContrasenaController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          final success = await authProvider.cambiarContrasena(
                            contrasenaActual: contrasenaActualController.text,
                            nuevaContrasena: nuevaContrasenaController.text,
                          );

                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contraseña actualizada correctamente'),
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
                      },
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cambiar'),
              );
            },
          ),
        ],
      ),
    );
  }
}
