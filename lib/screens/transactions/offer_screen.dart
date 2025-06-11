import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/models/producto.dart';
import 'package:pina_app/models/usuario.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/services/offer_service.dart';
import 'package:pina_app/services/chat_service.dart';
import 'package:pina_app/widgets/common/animated_buttons.dart';
import 'package:intl/intl.dart';

class OfferScreen extends StatefulWidget {
  final Producto producto;
  final Usuario vendedor;

  const OfferScreen({
    Key? key,
    required this.producto,
    required this.vendedor,
  }) : super(key: key);

  @override
  _OfferScreenState createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _mensajeController = TextEditingController();

  final _offerService = OfferService();
  final _chatService = ChatService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  double _precioTotal = 0.0;

  final formatCurrency =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);

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

    // Inicializar con el precio del producto
    _precioController.text = widget.producto.precio.toString();
    _calcularTotal();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  void _calcularTotal() {
    final precio = double.tryParse(_precioController.text) ?? 0;
    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
    setState(() {
      _precioTotal = precio * cantidad;
    });
  }

  Future<void> _enviarOferta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final comprador = authProvider.userProfile!;

      // Crear la oferta
      final ofertaId = await _offerService.crearOferta(
        productoId: widget.producto.id!,
        compradorId: comprador.id,
        compradorNombre: comprador.nombreCompleto,
        compradorFoto: comprador.fotoPerfil ?? '',
        productorId: widget.vendedor.id,
        productorNombre: widget.vendedor.nombreCompleto,
        precioOfertado: double.parse(_precioController.text),
        cantidadSolicitada: double.parse(_cantidadController.text),
        unidadMedida: widget.producto.unidadPrecio,
        mensaje: _mensajeController.text.trim().isEmpty
            ? null
            : _mensajeController.text.trim(),
      );

      if (ofertaId != null) {
        // Crear o obtener conversación
        final conversacionId = await _chatService.crearOObtenerConversacion(
          usuario1Id: comprador.id,
          usuario1Nombre: comprador.nombreCompleto,
          usuario2Id: widget.vendedor.id,
          usuario2Nombre: widget.vendedor.nombreCompleto,
          productoId: widget.producto.id,
          productoNombre: widget.producto.titulo,
        );

        if (conversacionId != null) {
          // Enviar mensaje de oferta en el chat
          await _chatService.enviarMensajeOferta(
            conversacionId: conversacionId,
            senderId: comprador.id,
            senderNombre: comprador.nombreCompleto,
            receiverId: widget.vendedor.id,
            ofertaId: ofertaId,
            precio: double.parse(_precioController.text),
            cantidad: double.parse(_cantidadController.text),
            unidad: widget.producto.unidadPrecio,
            productoNombre: widget.producto.titulo,
          );

          // Navegar al chat
          Navigator.pushReplacementNamed(
            context,
            '/chat',
            arguments: {
              'conversacionId': conversacionId,
              'otroUsuarioId': widget.vendedor.id,
              'otroUsuarioNombre': widget.vendedor.nombreCompleto,
            },
          );
        } else {
          throw Exception('Error al crear la conversación');
        }
      } else {
        throw Exception('Error al crear la oferta');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar la oferta: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Hacer oferta',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del producto
                  _buildProductInfo(),
                  const SizedBox(height: 32),

                  // Formulario de oferta
                  _buildOfferForm(),
                  const SizedBox(height: 24),

                  // Resumen de la oferta
                  _buildOfferSummary(),
                  const SizedBox(height: 32),

                  // Botón de enviar
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.createShadow(
          elevation: AppTheme.elevationMedium,
          color: AppTheme.primaryGreen,
          opacity: 0.3,
        ),
      ),
      child: Row(
        children: [
          // Imagen del producto
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: widget.producto.fotos.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(widget.producto.fotos.first),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.producto.fotos.isEmpty
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 40,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.producto.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Vendedor: ${widget.vendedor.nombreCompleto}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.producto.ubicacion,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Precio por unidad
        _buildInputField(
          label: 'Precio por ${widget.producto.unidadPrecio}',
          controller: _precioController,
          prefixIcon: Icons.attach_money,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un precio';
            }
            final precio = double.tryParse(value);
            if (precio == null || precio <= 0) {
              return 'Ingresa un precio válido';
            }
            return null;
          },
          onChanged: (_) => _calcularTotal(),
        ),
        const SizedBox(height: 16),

        // Cantidad
        _buildInputField(
          label: 'Cantidad (${widget.producto.unidadPrecio})',
          controller: _cantidadController,
          prefixIcon: Icons.shopping_basket,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa una cantidad';
            }
            final cantidad = double.tryParse(value);
            if (cantidad == null || cantidad <= 0) {
              return 'Ingresa una cantidad válida';
            }
            if (cantidad > widget.producto.cantidadDisponible) {
              return 'La cantidad excede lo disponible (${widget.producto.cantidadDisponible})';
            }
            return null;
          },
          onChanged: (_) => _calcularTotal(),
        ),
        const SizedBox(height: 16),

        // Mensaje opcional
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: TextFormField(
            controller: _mensajeController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Mensaje (opcional)',
              hintText: 'Agrega un mensaje para el vendedor...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
              hintStyle:
                  TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon, color: AppTheme.primaryGreen),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildOfferSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total de la oferta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.local_offer,
                color: Colors.white.withOpacity(0.9),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency.format(_precioTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'El vendedor podrá aceptar, rechazar o hacer una contraoferta',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedElevatedButton(
        onPressed: _isLoading ? null : _enviarOferta,
        backgroundColor: AppTheme.primaryGreen,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Enviar oferta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
