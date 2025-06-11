import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/models/transaccion.dart';
import 'package:pina_app/models/usuario.dart';
import 'package:pina_app/providers/auth_provider.dart';
import 'package:pina_app/services/rating_service.dart';
import 'package:pina_app/widgets/common/animated_buttons.dart';

class RatingScreen extends StatefulWidget {
  final Transaccion transaccion;
  final Usuario usuarioACalificar;
  final String tipoCalificador; // 'productor' o 'comprador'

  const RatingScreen({
    Key? key,
    required this.transaccion,
    required this.usuarioACalificar,
    required this.tipoCalificador,
  }) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen>
    with TickerProviderStateMixin {
  final _ratingService = RatingService();
  final _comentarioController = TextEditingController();

  late AnimationController _starsController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  double _puntuacion = 0;
  final List<String> _aspectosSeleccionados = [];
  bool _isLoading = false;

  late List<String> _aspectosDisponibles;
  late List<AnimationController> _starControllers;
  late List<Animation<double>> _starAnimations;

  @override
  void initState() {
    super.initState();

    _aspectosDisponibles =
        _ratingService.getAspectosPositivos(widget.tipoCalificador);

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Animaciones individuales para cada estrella
    _starControllers = List.generate(
        5,
        (index) => AnimationController(
              duration: Duration(milliseconds: 200 + (index * 100)),
              vsync: this,
            ));

    _starAnimations = _starControllers
        .map((controller) => Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.elasticOut,
            )))
        .toList();

    _fadeController.forward();

    // Animar estrellas en secuencia
    Future.delayed(const Duration(milliseconds: 300), () {
      for (int i = 0; i < _starControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 100), () {
          if (mounted) {
            _starControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _starsController.dispose();
    _fadeController.dispose();
    _comentarioController.dispose();
    for (final controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _enviarCalificacion() async {
    if (_puntuacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una calificación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final calificador = authProvider.userProfile!;

      final success = await _ratingService.crearCalificacion(
        transaccionId: widget.transaccion.id,
        calificadorId: calificador.id,
        calificadorNombre: calificador.nombreCompleto,
        calificadoId: widget.usuarioACalificar.id,
        calificadoNombre: widget.usuarioACalificar.nombreCompleto,
        tipoCalificador: widget.tipoCalificador,
        puntuacion: _puntuacion,
        comentario: _comentarioController.text.trim().isEmpty
            ? null
            : _comentarioController.text.trim(),
        aspectosPositivos: _aspectosSeleccionados,
      );

      if (success) {
        // Mostrar animación de éxito
        await _mostrarExito();
        Navigator.pop(context, true);
      } else {
        throw Exception('No se pudo enviar la calificación');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar la calificación: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _mostrarExito() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Calificación enviada!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gracias por tu opinión',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Calificar',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Información del usuario a calificar
              _buildUserInfo(),
              const SizedBox(height: 32),

              // Estrellas de calificación
              _buildRatingStars(),
              const SizedBox(height: 24),

              // Texto descriptivo de la calificación
              _buildRatingDescription(),
              const SizedBox(height: 32),

              // Aspectos positivos
              _buildAspectosPositivos(),
              const SizedBox(height: 24),

              // Comentario
              _buildComentarioField(),
              const SizedBox(height: 32),

              // Botón de enviar
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: AppTheme.createShadow(
              elevation: AppTheme.elevationMedium,
              color: AppTheme.primaryGreen,
              opacity: 0.3,
            ),
          ),
          child: Center(
            child: Text(
              widget.usuarioACalificar.nombreCompleto[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Califica a ${widget.usuarioACalificar.nombreCompleto}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.tipoCalificador == 'productor'
                ? 'Como comprador'
                : 'Como vendedor',
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isSelected = starNumber <= _puntuacion;

        return ScaleTransition(
          scale: _starAnimations[index],
          child: GestureDetector(
            onTap: () {
              setState(() {
                _puntuacion = starNumber.toDouble();
              });

              // Animar la estrella seleccionada
              _starControllers[index].forward(from: 0.8);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              child: Icon(
                isSelected ? Icons.star : Icons.star_border,
                size: 40,
                color:
                    isSelected ? AppTheme.accentOrange : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRatingDescription() {
    String descripcion = '';
    Color color = AppTheme.textSecondary;

    switch (_puntuacion.toInt()) {
      case 1:
        descripcion = 'Muy malo';
        color = Colors.red;
        break;
      case 2:
        descripcion = 'Malo';
        color = Colors.orange;
        break;
      case 3:
        descripcion = 'Regular';
        color = Colors.amber;
        break;
      case 4:
        descripcion = 'Bueno';
        color = AppTheme.primaryGreen;
        break;
      case 5:
        descripcion = '¡Excelente!';
        color = AppTheme.primaryGreen;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        descripcion,
        key: ValueKey(descripcion),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAspectosPositivos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aspectos positivos (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _aspectosDisponibles.map((aspecto) {
            final isSelected = _aspectosSeleccionados.contains(aspecto);

            return FilterChip(
              label: Text(aspecto),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _aspectosSeleccionados.add(aspecto);
                  } else {
                    _aspectosSeleccionados.remove(aspecto);
                  }
                });
              },
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryGreen,
              labelStyle: TextStyle(
                color:
                    isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.divider,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildComentarioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentario (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: TextFormField(
            controller: _comentarioController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Comparte tu experiencia...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle:
                  TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedElevatedButton(
        onPressed: _isLoading ? null : _enviarCalificacion,
        backgroundColor: AppTheme.primaryGreen,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Enviar calificación',
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
