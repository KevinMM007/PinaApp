import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/models/mensaje.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/services/chat_service.dart';
import 'package:intl/intl.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> with SingleTickerProviderStateMixin {
  final _chatService = ChatService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final formatDate = DateFormat('dd/MM');
  final formatTime = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Ejecutar diagnóstico
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        _chatService.diagnosticarConversaciones(authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    print('👤 Usuario actual en ConversationsScreen: ${authProvider.user?.uid}');
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mensajes',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Badge de mensajes no leídos
          StreamBuilder<int>(
            stream: _chatService.getTotalMensajesNoLeidos(authProvider.user!.uid),
            builder: (context, snapshot) {
              final totalNoLeidos = snapshot.data ?? 0;
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mark_email_read, color: AppTheme.textPrimary),
                    onPressed: () {
                      // TODO: Marcar todos como leídos
                    },
                  ),
                  if (totalNoLeidos > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          totalNoLeidos > 99 ? '99+' : totalNoLeidos.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildConversationsList(authProvider.user!.uid),
        ),
      ),
    );
  }

  Widget _buildConversationsList(String currentUserId) {
    print('🔨 Construyendo lista de conversaciones para: $currentUserId');
    
    return StreamBuilder<List<Conversacion>>(
      stream: _chatService.getConversaciones(currentUserId),
      builder: (context, snapshot) {
        print('📊 Estado del snapshot: ${snapshot.connectionState}');
        print('📁 Tiene datos: ${snapshot.hasData}');
        print('❌ Tiene error: ${snapshot.hasError}');
        
        if (snapshot.hasError) {
          print('🛑 Error: ${snapshot.error}');
        }
        
        if (snapshot.hasData) {
          print('📩 Número de conversaciones: ${snapshot.data?.length ?? 0}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 100,
                  color: AppTheme.textSecondary.withOpacity(0.3),
                ),
                const SizedBox(height: 24),
                Text(
                  'No tienes conversaciones',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.6),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Contacta a un vendedor para iniciar una conversación',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.4),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/marketplace'),
                  icon: const Icon(Icons.search),
                  label: const Text('Explorar productos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }
        
        final conversaciones = snapshot.data!;
        
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: conversaciones.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            indent: 88,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final conversacion = conversaciones[index];
            return _buildConversationItem(conversacion, currentUserId);
          },
        );
      },
    );
  }

  Widget _buildConversationItem(Conversacion conversacion, String currentUserId) {
    // Obtener el ID y nombre del otro usuario
    final otroUsuarioId = conversacion.participantes.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    final otroUsuarioNombre = conversacion.participantesInfo[otroUsuarioId] ?? 'Usuario';
    
    // Mensajes no leídos para el usuario actual
    final mensajesNoLeidos = conversacion.mensajesNoLeidos[currentUserId] ?? 0;
    
    // Formatear fecha
    String fechaFormateada = '';
    if (conversacion.fechaUltimoMensaje != null) {
      final ahora = DateTime.now();
      final fecha = conversacion.fechaUltimoMensaje!;
      
      if (fecha.day == ahora.day && fecha.month == ahora.month && fecha.year == ahora.year) {
        fechaFormateada = formatTime.format(fecha);
      } else if (fecha.day == ahora.day - 1 && fecha.month == ahora.month && fecha.year == ahora.year) {
        fechaFormateada = 'Ayer';
      } else if (fecha.year == ahora.year) {
        fechaFormateada = formatDate.format(fecha);
      } else {
        fechaFormateada = DateFormat('dd/MM/yyyy').format(fecha);
      }
    }
    
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {
            'conversacionId': conversacion.id,
            'otroUsuarioId': otroUsuarioId,
            'otroUsuarioNombre': otroUsuarioNombre,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.createShadow(
                      elevation: AppTheme.elevationLow,
                      color: AppTheme.primaryGreen,
                      opacity: 0.3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      otroUsuarioNombre[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Indicador de mensajes no leídos
                if (mensajesNoLeidos > 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      child: Text(
                        mensajesNoLeidos > 99 ? '99+' : mensajesNoLeidos.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Información de la conversación
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          otroUsuarioNombre,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: mensajesNoLeidos > 0 ? FontWeight.w700 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        fechaFormateada,
                        style: TextStyle(
                          color: mensajesNoLeidos > 0 
                              ? AppTheme.primaryGreen 
                              : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: mensajesNoLeidos > 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (conversacion.productoNombre != null)
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_basket,
                          size: 14,
                          color: AppTheme.textSecondary.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            conversacion.productoNombre!,
                            style: TextStyle(
                              color: AppTheme.textSecondary.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    conversacion.ultimoMensaje ?? 'Sin mensajes',
                    style: TextStyle(
                      color: mensajesNoLeidos > 0 
                          ? AppTheme.textPrimary 
                          : AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: mensajesNoLeidos > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
