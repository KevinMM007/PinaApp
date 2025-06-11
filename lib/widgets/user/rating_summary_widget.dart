import 'package:flutter/material.dart';
import 'package:pina_app/config/theme.dart';
import 'package:pina_app/models/calificacion.dart';
import 'package:pina_app/services/rating_service.dart';

class RatingSummaryWidget extends StatelessWidget {
  final String usuarioId;
  final bool showDetails;

  const RatingSummaryWidget({
    Key? key,
    required this.usuarioId,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ratingService = RatingService();

    return StreamBuilder<ResumenCalificaciones?>(
      stream: ratingService.getResumenCalificaciones(usuarioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryGreen,
            ),
          );
        }

        final resumen = snapshot.data;

        if (resumen == null || resumen.totalCalificaciones == 0) {
          return _buildNoRatings();
        }

        return _buildRatingSummary(resumen);
      },
    );
  }

  Widget _buildNoRatings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Icon(
            Icons.star_outline,
            size: 48,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sin calificaciones aún',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Las calificaciones aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(ResumenCalificaciones resumen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.createShadow(
          elevation: AppTheme.elevationMedium,
          color: AppTheme.primaryGreen,
          opacity: 0.3,
        ),
      ),
      child: Column(
        children: [
          // Promedio general
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                resumen.promedioGeneral.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: _buildStars(resumen.promedioGeneral),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${resumen.totalCalificaciones} calificaciones',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (showDetails) ...[
            const SizedBox(height: 20),
            const Divider(
              color: Colors.white24,
              thickness: 1,
            ),
            const SizedBox(height: 16),

            // Distribución de estrellas
            _buildStarDistribution(resumen.distribucionEstrellas),

            // Aspectos más frecuentes
            if (resumen.aspectosMasFreecuentes.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(
                color: Colors.white24,
                thickness: 1,
              ),
              const SizedBox(height: 16),
              _buildTopAspects(resumen.aspectosMasFreecuentes),
            ],
          ],
        ],
      ),
    );
  }

  List<Widget> _buildStars(double rating) {
    return List.generate(5, (index) {
      final starNumber = index + 1;
      IconData icon;
      Color color = Colors.white;

      if (rating >= starNumber) {
        icon = Icons.star;
      } else if (rating >= starNumber - 0.5) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }

      return Icon(
        icon,
        size: 20,
        color: color,
      );
    });
  }

  Widget _buildStarDistribution(Map<String, int> distribucion) {
    final total = distribucion.values.fold(0, (sum, count) => sum + count);

    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index;
        final count = distribucion[stars.toString()] ?? 0;
        final percentage = total > 0 ? (count / total) * 100 : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '$stars',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.star,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage / 100,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopAspects(List<String> aspectos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lo que más destacan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: aspectos.map((aspecto) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    aspecto,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
