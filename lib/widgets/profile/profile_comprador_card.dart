import 'package:flutter/material.dart';
import 'package:pina_app/models/usuario.dart';

class ProfileCompradorCard extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onEdit;

  const ProfileCompradorCard({
    Key? key,
    required this.usuario,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final perfil = usuario.perfilComprador;
    
    if (perfil == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.business,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Perfil de Comprador Incompleto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completa tu perfil para que los productores conozcan tus necesidades.',
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
                      Icons.business,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Información del Comprador',
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
              Icons.category,
              'Tipo de comprador',
              perfil.tipoComprador.substring(0, 1).toUpperCase() + 
              perfil.tipoComprador.substring(1),
            ),
            const SizedBox(height: 8),
            
            if (perfil.volumenCompraMensual > 0) ...[
              _buildInfoRow(
                Icons.scale,
                'Volumen mensual',
                '${perfil.volumenCompraMensual} toneladas',
              ),
              const SizedBox(height: 8),
            ],
            
            _buildInfoRow(
              Icons.schedule,
              'Frecuencia de compra',
              perfil.frecuenciaCompra.substring(0, 1).toUpperCase() + 
              perfil.frecuenciaCompra.substring(1),
            ),
            const SizedBox(height: 8),
            
            _buildInfoRow(
              Icons.payment,
              'Método de pago',
              perfil.metodoPago.substring(0, 1).toUpperCase() + 
              perfil.metodoPago.substring(1),
            ),
            const SizedBox(height: 8),
            
            if (perfil.diasCredito > 0) ...[
              _buildInfoRow(
                Icons.calendar_today,
                'Días de crédito',
                '${perfil.diasCredito} días',
              ),
              const SizedBox(height: 8),
            ],
            
            if (perfil.contactoComercial.isNotEmpty) ...[
              _buildInfoRow(
                Icons.person_pin,
                'Contacto comercial',
                perfil.contactoComercial,
              ),
              const SizedBox(height: 8),
            ],
            
            if (perfil.horarioAtencion.isNotEmpty) ...[
              _buildInfoRow(
                Icons.access_time,
                'Horario de atención',
                perfil.horarioAtencion,
              ),
              const SizedBox(height: 8),
            ],
            
            // Rango de precios
            if (perfil.rangoPrecios['min'] != null && perfil.rangoPrecios['max'] != null) ...[
              _buildInfoRow(
                Icons.attach_money,
                'Rango de precios',
                '\$${perfil.rangoPrecios['min']!.toStringAsFixed(2)} - \$${perfil.rangoPrecios['max']!.toStringAsFixed(2)} por kg',
              ),
              const SizedBox(height: 8),
            ],
            
            // Servicios especiales
            if (perfil.requiereTransporte) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Requiere transporte',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Variedades de interés
            if (perfil.variedadesInteres.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Variedades de interés:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: perfil.variedadesInteres.map((variedad) => 
                  Chip(
                    label: Text(
                      variedad,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue.shade100,
                    side: BorderSide(color: Colors.blue.shade300),
                  ),
                ).toList(),
              ),
            ],
            
            // Calidades preferidas
            if (perfil.calidadesPreferidas.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Calidades preferidas:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: perfil.calidadesPreferidas.map((calidad) => 
                  Chip(
                    label: Text(
                      calidad,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.green.shade100,
                    side: BorderSide(color: Colors.green.shade300),
                  ),
                ).toList(),
              ),
            ],
            
            // Certificaciones requeridas
            if (perfil.certificacionesRequeridas.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Certificaciones requeridas:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: perfil.certificacionesRequeridas.map((cert) => 
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
