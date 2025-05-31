import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/screens/profile/edit_profile_screen.dart';
import 'package:pina_app/screens/profile/settings_screen.dart';
import 'package:pina_app/widgets/profile/profile_completion_card.dart';
import 'package:pina_app/utils/firebase_debug_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Intentar cargar el perfil si no está cargado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userProfile == null && !authProvider.isLoading) {
        authProvider.recargarPerfil();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Si no hay usuario autenticado, mostrar mensaje
          if (!authProvider.isAuthenticated) {
            return const Center(
              child: Text('No hay usuario autenticado'),
            );
          }

          final user = authProvider.userProfile;

          // Si está cargando
          if (authProvider.isLoading && user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando perfil...'),
                ],
              ),
            );
          }

          // Si hay error
          if (authProvider.error.isNotEmpty && user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error al cargar perfil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authProvider.error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        authProvider.clearError();
                        authProvider.recargarPerfil();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Botón de depuración (solo en modo debug)
                    if (const bool.fromEnvironment('dart.vm.product') ==
                        false) ...[
                      TextButton.icon(
                        onPressed: () async {
                          // Mostrar diálogo de depuración
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const AlertDialog(
                              title: Text('Depuración de Firebase'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Ejecutando diagnóstico...'),
                                ],
                              ),
                            ),
                          );

                          // Ejecutar diagnóstico
                          await FirebaseDebugUtils.verificarEstadoFirebase();

                          Navigator.pop(context);

                          // Mostrar opciones de reparación
                          final opcion = await showDialog<String>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Opciones de reparación'),
                              content: const Text(
                                  'Selecciona una opción para intentar solucionar el problema:'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'cancelar'),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'reparar'),
                                  child: const Text('Reparar documento'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'limpiar'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                  ),
                                  child: const Text('Limpiar caché'),
                                ),
                              ],
                            ),
                          );

                          if (opcion == 'reparar') {
                            final reparado = await FirebaseDebugUtils
                                .repararDocumentoUsuario();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(reparado
                                    ? 'Documento reparado. Recargando perfil...'
                                    : 'No se pudo reparar el documento.'),
                                backgroundColor:
                                    reparado ? Colors.green : Colors.orange,
                              ),
                            );
                            if (reparado) {
                              authProvider.recargarPerfil();
                            }
                          } else if (opcion == 'limpiar') {
                            final limpiado = await FirebaseDebugUtils
                                .limpiarCacheYRecargar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(limpiado
                                    ? 'Caché limpiado. Recargando perfil...'
                                    : 'No se pudo limpiar el caché. Intenta cerrar sesión y volver a entrar.'),
                                backgroundColor:
                                    limpiado ? Colors.green : Colors.orange,
                              ),
                            );
                            if (limpiado) {
                              // Forzar recarga desde servidor
                              authProvider.recargarPerfil(
                                  forceServerFetch: true);
                            }
                          }
                        },
                        icon: const Icon(Icons.bug_report),
                        label: const Text('Diagnóstico'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          // Si no hay perfil y no está cargando ni hay error
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando perfil...'),
                ],
              ),
            );
          }

          // Mostrar el perfil
          return RefreshIndicator(
            onRefresh: () async {
              await authProvider.recargarPerfil();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header del perfil
                  _buildProfileHeader(context, user, authProvider),

                  const SizedBox(height: 20),

                  // Tarjeta de completitud del perfil
                  if (!user.tienePerfilCompleto)
                    ProfileCompletionCard(user: user),

                  if (!user.tienePerfilCompleto) const SizedBox(height: 20),

                  // Información específica por rol
                  _buildRoleSpecificContent(context, user),

                  const SizedBox(height: 20),

                  // Estadísticas generales
                  _buildStatsSection(user),

                  const SizedBox(height: 20),

                  // Acciones rápidas
                  _buildQuickActions(context, authProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, user, AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: user.fotoPerfil.isNotEmpty
                      ? NetworkImage(user.fotoPerfil)
                      : null,
                  child: user.fotoPerfil.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[600],
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: user.verificado ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      user.verificado ? Icons.verified : Icons.pending,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nombre y verificación
            Text(
              user.nombreCompleto,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.tipo).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getRoleColor(user.tipo),
                    ),
                  ),
                  child: Text(
                    _getRoleDisplayName(user.tipo),
                    style: TextStyle(
                      color: _getRoleColor(user.tipo),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (!authProvider.isEmailVerified) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      'Email no verificado',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            if (user.ubicacion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.ubicacion,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSpecificContent(BuildContext context, user) {
    switch (user.tipo) {
      case AppConstants.rolProductor:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información del Productor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (user.perfilProductor?.nombreFinca.isNotEmpty == true)
                  Text('Finca: ${user.perfilProductor!.nombreFinca}')
                else
                  const Text('Perfil de productor incompleto'),
              ],
            ),
          ),
        );
      case AppConstants.rolComprador:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información del Comprador',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (user.perfilComprador?.nombreEmpresa.isNotEmpty == true)
                  Text('Empresa: ${user.perfilComprador!.nombreEmpresa}')
                else
                  const Text('Perfil de comprador incompleto'),
              ],
            ),
          ),
        );
      case AppConstants.rolTransportista:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información del Transportista',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (user.perfilTransportista?.nombreEmpresa.isNotEmpty == true)
                  Text('Empresa: ${user.perfilTransportista!.nombreEmpresa}')
                else
                  const Text('Perfil de transportista incompleto'),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatsSection(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Calificación',
                    user.calificacionPromedio.toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Transacciones',
                    user.numeroTransacciones.toString(),
                    Icons.handshake,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Miembro desde',
                    '${user.fechaRegistro.year}',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, AuthProvider authProvider) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('Editar Perfil'),
            subtitle: const Text('Actualiza tu información personal'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Configuración'),
            subtitle: const Text('Preferencias y privacidad'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          if (!authProvider.isEmailVerified) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.verified_user, color: Colors.orange),
              title: const Text('Verificar Email'),
              subtitle: const Text('Confirma tu dirección de correo'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/email_verification');
              },
            ),
          ],
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content:
                      const Text('¿Estás seguro de que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (result == true) {
                await authProvider.cerrarSesion();
                // No navegar manualmente, el AuthWrapper manejará el cambio
              }
            },
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String tipo) {
    switch (tipo) {
      case AppConstants.rolProductor:
        return Colors.green;
      case AppConstants.rolComprador:
        return Colors.blue;
      case AppConstants.rolTransportista:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(String tipo) {
    switch (tipo) {
      case AppConstants.rolProductor:
        return 'Productor';
      case AppConstants.rolComprador:
        return 'Comprador';
      case AppConstants.rolTransportista:
        return 'Transportista';
      default:
        return 'Usuario';
    }
  }
}
