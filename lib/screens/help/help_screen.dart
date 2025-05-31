import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Ayuda'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Centro de Ayuda PiñaApp',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Estamos aquí para ayudarte',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),

            // Preguntas Frecuentes
            _buildSection(
              'Preguntas Frecuentes',
              Icons.help_outline,
              [
                _buildFAQItem(
                  '¿Qué es PiñaApp?',
                  'PiñaApp es una plataforma digital que conecta productores de piña con compradores y transportistas, facilitando el comercio directo y justo.',
                ),
                _buildFAQItem(
                  '¿Cómo puedo registrarme?',
                  'Puedes registrarte desde la pantalla de inicio seleccionando "Registrarse" y completando el formulario con tu información básica. Necesitarás verificar tu correo electrónico.',
                ),
                _buildFAQItem(
                  '¿Cómo publico un producto?',
                  'Si eres productor, ve a la sección Marketplace y presiona el botón "+" para agregar un nuevo producto. Incluye fotos, descripción, precio y cantidad disponible.',
                ),
                _buildFAQItem(
                  '¿Cómo contacto a un vendedor?',
                  'En la página de detalles del producto, encontrarás un botón "Contactar" que te permitirá enviar un mensaje directo al vendedor.',
                ),
                _buildFAQItem(
                  '¿PiñaApp cobra comisión?',
                  'PiñaApp puede cobrar una pequeña comisión por transacciones exitosas. Los detalles se mostrarán claramente antes de confirmar cualquier operación.',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Guías de Usuario
            _buildSection(
              'Guías de Usuario',
              Icons.book_outlined,
              [
                _buildGuideItem(
                  context,
                  'Para Productores',
                  'Aprende a publicar productos, gestionar inventario y comunicarte con compradores.',
                  Icons.agriculture,
                ),
                _buildGuideItem(
                  context,
                  'Para Compradores',
                  'Descubre cómo buscar productos, contactar productores y realizar pedidos.',
                  Icons.shopping_cart_outlined,
                ),
                _buildGuideItem(
                  context,
                  'Para Transportistas',
                  'Conoce cómo ofrecer tus servicios y coordinar entregas.',
                  Icons.local_shipping_outlined,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Contacto y Soporte
            _buildSection(
              'Contacto y Soporte',
              Icons.contact_support_outlined,
              [
                _buildContactItem(
                  'Email de Soporte',
                  'soporte@pinaapp.com',
                  Icons.email_outlined,
                  () => _launchEmail('soporte@pinaapp.com'),
                ),
                _buildContactItem(
                  'WhatsApp',
                  '+52 123 456 7890',
                  Icons.chat_outlined,
                  () => _launchWhatsApp('+521234567890'),
                ),
                _buildContactItem(
                  'Teléfono',
                  '+52 123 456 7890',
                  Icons.phone_outlined,
                  () => _launchPhone('+521234567890'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Reportar Problemas
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_outlined, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Reportar un Problema',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Si encuentras algún problema técnico o comportamiento inadecuado, por favor repórtalo inmediatamente.',
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _launchEmail(
                        'soporte@pinaapp.com',
                        subject: 'Reporte de Problema',
                        body:
                            'Por favor describe el problema que encontraste:\n\n',
                      ),
                      icon: const Icon(Icons.report_outlined),
                      label: const Text('Reportar Problema'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Enlaces Útiles
            _buildSection(
              'Enlaces Útiles',
              Icons.link,
              [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Términos y Condiciones'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pushNamed(context, '/terms'),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Política de Privacidad'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pushNamed(context, '/privacy'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Información de Versión
            Center(
              child: Column(
                children: [
                  Text(
                    'PiñaApp v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© ${DateTime.now().year} PiñaApp',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItem(BuildContext context, String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(icon, color: Colors.green[700]),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Implementar navegación a guías detalladas
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Guía detallada próximamente'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactItem(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _launchEmail(String email,
      {String? subject, String? body}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
