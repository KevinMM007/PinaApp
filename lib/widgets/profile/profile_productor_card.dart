import 'package:flutter/material.dart';
import 'package:pina_app/models/usuario.dart';

class ProfileProductorCard extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onEdit;

  const ProfileProductorCard({
    Key? key,
    required this.usuario,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final perfil = usuario.perfilProductor;
    
    if (perfil == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.agriculture,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Perfil de Productor Incompleto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completa tu perfil para que los compradores puedan encontrarte más fácilmente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Completar Perfil'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.agriculture,
                      color: Colors.green[700],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Información del Productor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  color: Colors.grey[600],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información de la finca
            if (perfil.nombreFinca.isNotEmpty) ...[
              _buildInfoRow(
                Icons.home,
                'Finca',
                perfil.nombreFinca,
              ),
              const SizedBox(height: 8),
            ],
            
            if (perfil.hectareas > 0) ...[
              _buildInfoRow(
                Icons.straighten,
                'Área cultivada',
                '${perfil.hectareas} hectáreas',
              ),
              const SizedBox(height: 8),
            ],
            
            if (perfil.capacidadProductivaMensual > 0) ...[
              _buildInfoRow(
                Icons.scale,
                'Capacidad mensual',
                '${perfil.capacidadProductivaMensual} toneladas',
              ),
              const SizedBox(height: 8),
            ],
            
            if (perfil.anosExperiencia > 0) ...[
              _buildInfoRow(
                Icons.timeline,
                'Experiencia',
                '${perfil.anosExperiencia} años',
              ),
              const SizedBox(height: 8),
            ],
            
            if (perfil.metodoCultivo.isNotEmpty) ...[
              _buildInfoRow(
                Icons.eco,
                'Método de cultivo',
                perfil.metodoCultivo.substring(0, 1).toUpperCase() + 
                perfil.metodoCultivo.substring(1),
              ),
              const SizedBox(height: 8),
            ],
            
            if (perfil.tipoSuelo.isNotEmpty) ...[
              _buildInfoRow(
                Icons.terrain,
                'Tipo de suelo',
                perfil.tipoSuelo,
              ),
              const SizedBox(height: 8),
            ],
            
            if (perfil.temporadaCosecha.isNotEmpty) ...[
              _buildInfoRow(
                Icons.calendar_month,
                'Temporada de cosecha',
                perfil.temporadaCosecha,
              ),
              const SizedBox(height: 8),
            ],
            
            if (perfil.equipoDisponible.isNotEmpty) ...[
              _buildInfoRow(
                Icons.build,
                'Equipo disponible',
                perfil.equipoDisponible,
              ),
              const SizedBox(height: 8),
            ],
            
            // Variedades cultivadas
            if (perfil.variedadesCultivadas.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Variedades cultivadas:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: perfil.variedadesCultivadas.map((variedad) => 
                  Chip(
                    label: Text(
                      variedad,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.green.shade100,
                    side: BorderSide(color: Colors.green.shade300),
                  ),
                ).toList(),
              ),
            ],
            
            // Certificaciones
            if (perfil.certificaciones.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Certificaciones:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: perfil.certificaciones.map((cert) => 
                  Chip(
                    label: Text(
                      cert,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue.shade100,
                    side: BorderSide(color: Colors.blue.shade300),
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
