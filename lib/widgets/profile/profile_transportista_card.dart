import 'package:flutter/material.dart';
import 'package:pina_app/models/usuario.dart';

class ProfileTransportistaCard extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onEdit;

  const ProfileTransportistaCard({
    Key? key,
    required this.usuario,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final perfil = usuario.perfilTransportista;
    
    if (perfil == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.local_shipping,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Perfil de Transportista Incompleto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completa tu perfil para recibir solicitudes de transporte.',
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
                      Icons.local_shipping,
                      color: Colors.orange[700],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Información del Transportista',
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
            
            // Información de la empresa
            if (perfil.nombreEmpresa.isNotEmpty) ...[
              _buildInfoRow(
                Icons.business,
                'Empresa',
                perfil.nombreEmpresa,
              ),
              const SizedBox(height: 8),
            ],
            
            _buildInfoRow(
              Icons.public,
              'Tipo de servicio',
              perfil.tipoServicio.substring(0, 1).toUpperCase() + 
              perfil.tipoServicio.substring(1),
            ),
            const SizedBox(height: 8),
            
            if (perfil.capacidadTotalToneladas > 0) ...[
              _buildInfoRow(
                Icons.scale,
                'Capacidad total',
                '${perfil.capacidadTotalToneladas} toneladas',
              ),
              const SizedBox(height: 8),
            ],
            
            if (perfil.horarioServicio.isNotEmpty) ...[
              _buildInfoRow(
                Icons.schedule,
                'Horario de servicio',
                perfil.horarioServicio,
              ),
              const SizedBox(height: 8),
            ],
            
            // Tarifas
            if (perfil.tarifas.isNotEmpty) ...[
              if (perfil.tarifas['porKm'] != null && perfil.tarifas['porKm']! > 0) ...[
                _buildInfoRow(
                  Icons.attach_money,
                  'Tarifa por km',
                  '\$${perfil.tarifas['porKm']!.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
              ],
              if (perfil.tarifas['porTonelada'] != null && perfil.tarifas['porTonelada']! > 0) ...[
                _buildInfoRow(
                  Icons.attach_money,
                  'Tarifa por tonelada',
                  '\$${perfil.tarifas['porTonelada']!.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
              ],
            ],
            
            // Estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Calificación',
                    perfil.calificacionPromedio.toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Viajes',
                    perfil.viajesRealizados.toString(),
                    Icons.delivery_dining,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            // Servicios especiales
            const SizedBox(height: 16),
            Row(
              children: [
                if (perfil.tieneSeguro) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 14,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Con seguro',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (perfil.servicioUrgente) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.speed,
                          size: 14,
                          color: Colors.red,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Servicio urgente',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            
            // Vehículos
            if (perfil.vehiculos.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Flota de vehículos:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...perfil.vehiculos.take(3).map((vehiculo) => Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${vehiculo['tipo']} - ${vehiculo['capacidad']} ton',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              if (perfil.vehiculos.length > 3) ...[
                const SizedBox(height: 4),
                Text(
                  'y ${perfil.vehiculos.length - 3} más...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
            
            // Tipos de carga
            if (perfil.tiposCarga.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Tipos de carga:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: perfil.tiposCarga.map((tipo) => 
                  Chip(
                    label: Text(
                      tipo.substring(0, 1).toUpperCase() + tipo.substring(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.orange.shade100,
                    side: BorderSide(color: Colors.orange.shade300),
                  ),
                ).toList(),
              ),
            ],
            
            // Días disponibles
            if (perfil.diasDisponibles.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Días disponibles:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: perfil.diasDisponibles.map((dia) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dia.substring(0, 3),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
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
                    backgroundColor: Colors.purple.shade100,
                    side: BorderSide(color: Colors.purple.shade300),
                  ),
                ).toList(),
              ),
            ],
            
            // Equipo especial
            if (perfil.equipoEspecial.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Equipo especial:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: perfil.equipoEspecial.map((equipo) => 
                  Chip(
                    label: Text(
                      equipo,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.teal.shade100,
                    side: BorderSide(color: Colors.teal.shade300),
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
