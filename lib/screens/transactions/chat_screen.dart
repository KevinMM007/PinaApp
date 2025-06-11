import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/models/mensaje.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/services/chat_service.dart';
import 'package:pina_app/services/offer_service.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = ChatService();
  final _offerService = OfferService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? _conversacionId;
  String? _otroUsuarioId;
  String? _otroUsuarioNombre;
  final bool _isLoading = false;

  final formatTime = DateFormat('HH:mm');
  final formatDate = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _conversacionId = args['conversacionId'];
    _otroUsuarioId = args['otroUsuarioId'];
    _otroUsuarioNombre = args['otroUsuarioNombre'];

    // Marcar mensajes como leídos
    if (_conversacionId != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _chatService.marcarMensajesComoLeidos(
        _conversacionId!,
        authProvider.user!.uid,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje() async {
    final mensaje = _messageController.text.trim();
    if (mensaje.isEmpty || _conversacionId == null) return;

    _messageController.clear();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usuario = authProvider.userProfile!;

    await _chatService.enviarMensaje(
      conversacionId: _conversacionId!,
      senderId: usuario.id,
      senderNombre: usuario.nombreCompleto,
      receiverId: _otroUsuarioId!,
      contenido: mensaje,
    );

    // Scroll al final
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Mensajes
            Expanded(
              child: _buildMessagesList(authProvider.user!.uid),
            ),

            // Input de mensaje
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (_otroUsuarioNombre ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nombre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _otroUsuarioNombre ?? 'Usuario',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'En línea',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
          onPressed: () => _mostrarOpcionesChat(),
        ),
      ],
    );
  }

  Widget _buildMessagesList(String currentUserId) {
    if (_conversacionId == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }

    return StreamBuilder<List<Mensaje>>(
      stream: _chatService.getMensajes(_conversacionId!),
      builder: (context, snapshot) {
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
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: AppTheme.textSecondary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay mensajes aún',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia la conversación',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.4),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final mensajes = snapshot.data!;

        // Agrupar mensajes por fecha
        Map<String, List<Mensaje>> mensajesPorFecha = {};
        for (final mensaje in mensajes) {
          final fecha = formatDate.format(mensaje.fechaEnvio);
          if (!mensajesPorFecha.containsKey(fecha)) {
            mensajesPorFecha[fecha] = [];
          }
          mensajesPorFecha[fecha]!.add(mensaje);
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: mensajesPorFecha.length,
          itemBuilder: (context, index) {
            final fecha = mensajesPorFecha.keys.elementAt(index);
            final mensajesDelDia = mensajesPorFecha[fecha]!;

            return Column(
              children: [
                // Separador de fecha
                _buildDateSeparator(fecha),

                // Mensajes del día
                ...mensajesDelDia.map((mensaje) {
                  final esPropio = mensaje.senderId == currentUserId;

                  if (mensaje.tipo == 'oferta') {
                    return _buildOfferMessage(mensaje, esPropio);
                  }

                  return _buildMessage(mensaje, esPropio);
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateSeparator(String fecha) {
    final hoy = formatDate.format(DateTime.now());
    final ayer =
        formatDate.format(DateTime.now().subtract(const Duration(days: 1)));

    String textoFecha = fecha;
    if (fecha == hoy) {
      textoFecha = 'Hoy';
    } else if (fecha == ayer) {
      textoFecha = 'Ayer';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              color: AppTheme.divider,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              textoFecha,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(
            child: Divider(
              color: AppTheme.divider,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Mensaje mensaje, bool esPropio) {
    return Align(
      alignment: esPropio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              esPropio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: esPropio ? AppTheme.primaryGradient : null,
                color: esPropio ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(esPropio ? 16 : 4),
                  bottomRight: Radius.circular(esPropio ? 4 : 16),
                ),
                boxShadow: AppTheme.createShadow(
                  elevation: AppTheme.elevationLow,
                  opacity: 0.1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mensaje.contenido,
                    style: TextStyle(
                      color: esPropio ? Colors.white : AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime.format(mensaje.fechaEnvio),
                  style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
                if (esPropio) ...[
                  const SizedBox(width: 4),
                  Icon(
                    mensaje.leido ? Icons.done_all : Icons.done,
                    size: 14,
                    color: mensaje.leido
                        ? AppTheme.primaryGreen
                        : AppTheme.textSecondary.withOpacity(0.6),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferMessage(Mensaje mensaje, bool esPropio) {
    final datos = mensaje.datosAdicionales!;
    final formatCurrency =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);

    return Align(
      alignment: esPropio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment:
              esPropio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.warmGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.createShadow(
                  elevation: AppTheme.elevationMedium,
                  color: AppTheme.accentOrange,
                  opacity: 0.3,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Oferta realizada',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          datos['productoNombre'] ?? 'Producto',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Precio: ${formatCurrency.format(datos['precio'])}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Cantidad: ${datos['cantidad']} ${datos['unidad']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${formatCurrency.format((datos['precio'] ?? 0) * (datos['cantidad'] ?? 0))}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!esPropio) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                _responderOferta(datos['ofertaId'], 'aceptar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('Aceptar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _responderOferta(datos['ofertaId'], 'rechazar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('Rechazar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatTime.format(mensaje.fechaEnvio),
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Campo de texto
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _enviarMensaje(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file,
                        color: AppTheme.textSecondary),
                    onPressed: () {
                      // TODO: Implementar adjuntar archivos
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Función de adjuntar archivos próximamente'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botón de enviar
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _enviarMensaje,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesChat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Ver perfil'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar al perfil del usuario
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Eliminar conversación',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _eliminarConversacion();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _responderOferta(String ofertaId, String accion) async {
    // TODO: Implementar respuesta a ofertas
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de $accion oferta próximamente'),
      ),
    );
  }

  Future<void> _eliminarConversacion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar conversación'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar esta conversación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && _conversacionId != null) {
      final success = await _chatService.eliminarConversacion(_conversacionId!);
      if (success) {
        Navigator.pop(context);
      }
    }
  }
}
