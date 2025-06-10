import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/constants.dart';
import 'package:pina_app/config/theme.dart';
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
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white, // Color de fondo uniforme
          ),
          child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  // Si no hay usuario autenticado, navegar a login
                  if (!authProvider.isAuthenticated) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    });
                    return const Center(
                      child: CircularProgressIndicator(),
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
                    return _buildErrorState(authProvider);
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
        ),
      ),
    );
  }

  Widget _buildErrorState(AuthProvider authProvider) {
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
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Botón de depuración (solo en modo debug)
            if (const bool.fromEnvironment('dart.vm.product') == false) ...[
              TextButton.icon(
                onPressed: () => _showDebugOptions(authProvider),
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

  Future<void> _showDebugOptions(AuthProvider authProvider) async {
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
            onPressed: () => Navigator.pop(context, 'cancelar'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'reparar'),
            child: const Text('Reparar documento'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'limpiar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: const Text('Limpiar caché'),
          ),
        ],
      ),
    );

    if (opcion == 'reparar') {
      final reparado = await FirebaseDebugUtils.repararDocumentoUsuario();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reparado
              ? 'Documento reparado. Recargando perfil...'
              : 'No se pudo reparar el documento.'),
          backgroundColor: reparado ? Colors.green : Colors.orange,
        ),
      );
      if (reparado) {
        authProvider.recargarPerfil();
      }
    } else if (opcion == 'limpiar') {
      final limpiado = await FirebaseDebugUtils.limpiarCacheYRecargar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(limpiado
              ? 'Caché limpiado. Recargando perfil...'
              : 'No se pudo limpiar el caché. Intenta cerrar sesión y volver a entrar.'),
          backgroundColor: limpiado ? Colors.green : Colors.orange,
        ),
      );
      if (limpiado) {
        // Forzar recarga desde servidor
        authProvider.recargarPerfil(forceServerFetch: true);
      }
    }
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
    final user = authProvider.userProfile;
    
    return Column(
      children: [
        // Editar Perfil
        _buildActionTile(
          icon: Icons.edit,
          iconColor: Colors.blue,
          title: 'Editar Perfil',
          subtitle: 'Actualiza tu información personal',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        
        // Mis Favoritos
        _buildActionTile(
          icon: Icons.favorite,
          iconColor: Colors.red,
          title: 'Mis Favoritos',
          subtitle: 'Productos que me interesan',
          onTap: () {
            Navigator.pushNamed(context, '/favorites');
          },
        ),
        const SizedBox(height: 8),
        
        // Solo mostrar para compradores
        if (user?.tipo == AppConstants.rolComprador) ...[
          _buildActionTile(
            icon: Icons.shopping_cart,
            iconColor: Colors.green,
            title: 'Mis Necesidades',
            subtitle: 'Solicitudes de compra publicadas',
            onTap: () {
              Navigator.pushNamed(context, '/necesidades');
            },
          ),
          const SizedBox(height: 8),
        ],
        
        // Configuración
        _buildActionTile(
          icon: Icons.settings,
          iconColor: Colors.grey,
          title: 'Configuración',
          subtitle: 'Preferencias y privacidad',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        
        // Verificar Email
        if (!authProvider.isEmailVerified) ...[
          _buildActionTile(
            icon: Icons.verified_user,
            iconColor: Colors.orange,
            title: 'Verificar Email',
            subtitle: 'Confirma tu dirección de correo',
            onTap: () {
              Navigator.pushNamed(context, '/email_verification');
            },
          ),
          const SizedBox(height: 8),
        ],
        
        // Cerrar Sesión
        _buildActionTile(
          icon: Icons.logout,
          iconColor: Colors.red,
          title: 'Cerrar Sesión',
          subtitle: null,
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
              // Navegar a la pantalla de login
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: iconColor.withOpacity(0.1),
          highlightColor: iconColor.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
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
