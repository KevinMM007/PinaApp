import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Política de Privacidad de PiñaApp',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Información que Recopilamos',
              'Recopilamos información que usted nos proporciona directamente:\n'
              '• Información de registro (nombre, email, teléfono)\n'
              '• Información de perfil (ubicación, tipo de usuario)\n'
              '• Información de productos y transacciones\n'
              '• Fotografías de perfil y productos\n'
              '• Comunicaciones con otros usuarios',
            ),
            _buildSection(
              '2. Uso de la Información',
              'Utilizamos su información para:\n'
              '• Proporcionar y mejorar nuestros servicios\n'
              '• Conectar productores, compradores y transportistas\n'
              '• Enviar notificaciones sobre transacciones\n'
              '• Prevenir fraudes y actividades ilegales\n'
              '• Cumplir con obligaciones legales',
            ),
            _buildSection(
              '3. Compartir Información',
              'Compartimos su información con:\n'
              '• Otros usuarios (según sus configuraciones de privacidad)\n'
              '• Proveedores de servicios (hosting, analytics)\n'
              '• Autoridades cuando sea requerido por ley\n'
              '• Nunca vendemos su información personal',
            ),
            _buildSection(
              '4. Ubicación',
              'Solicitamos acceso a su ubicación para:\n'
              '• Mostrar productos y servicios cercanos\n'
              '• Facilitar la logística de entrega\n'
              '• Mejorar la experiencia de usuario\n'
              'Puede desactivar el acceso a ubicación en cualquier momento.',
            ),
            _buildSection(
              '5. Seguridad',
              'Implementamos medidas de seguridad para proteger su información:\n'
              '• Encriptación de datos sensibles\n'
              '• Acceso limitado a información personal\n'
              '• Monitoreo de actividades sospechosas\n'
              '• Actualizaciones regulares de seguridad',
            ),
            _buildSection(
              '6. Sus Derechos',
              'Usted tiene derecho a:\n'
              '• Acceder a su información personal\n'
              '• Corregir información incorrecta\n'
              '• Solicitar la eliminación de su cuenta\n'
              '• Exportar sus datos\n'
              '• Limitar el uso de su información',
            ),
            _buildSection(
              '7. Retención de Datos',
              'Conservamos su información mientras:\n'
              '• Su cuenta esté activa\n'
              '• Sea necesario para nuestros servicios\n'
              '• Lo requiera la ley\n'
              'Puede solicitar la eliminación en cualquier momento.',
            ),
            _buildSection(
              '8. Menores de Edad',
              'PiñaApp no está dirigido a menores de 18 años. No recopilamos intencionalmente información de menores.',
            ),
            _buildSection(
              '9. Cambios en la Política',
              'Podemos actualizar esta política periódicamente. Le notificaremos sobre cambios significativos a través de la aplicación.',
            ),
            _buildSection(
              '10. Cookies y Tecnologías Similares',
              'Utilizamos cookies y tecnologías similares para:\n'
              '• Mantener su sesión activa\n'
              '• Recordar sus preferencias\n'
              '• Analizar el uso de la aplicación\n'
              '• Mejorar nuestros servicios',
            ),
            _buildSection(
              '11. Transferencia Internacional',
              'Sus datos pueden ser transferidos y procesados en países distintos al suyo. Tomamos medidas para proteger su información sin importar dónde se procese.',
            ),
            _buildSection(
              '12. Contacto',
              'Para preguntas sobre privacidad, contáctenos:\n'
              'Email: privacidad@pinaapp.com\n'
              'Teléfono: +52 1234567890\n'
              'Dirección: Calle Principal 123, Ciudad, México',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '© ${DateTime.now().year} PiñaApp. Todos los derechos reservados.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
