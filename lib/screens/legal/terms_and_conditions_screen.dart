import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Términos y Condiciones de PiñaApp',
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
              '1. Aceptación de los Términos',
              'Al descargar, instalar y usar PiñaApp, usted acepta estar sujeto a estos términos y condiciones. Si no está de acuerdo con estos términos, no debe usar la aplicación.',
            ),
            _buildSection(
              '2. Descripción del Servicio',
              'PiñaApp es una plataforma digital que conecta productores, compradores y transportistas de piña. Facilitamos la comunicación y transacción entre las partes, pero no somos responsables de la calidad, entrega o pago de los productos.',
            ),
            _buildSection(
              '3. Registro de Usuario',
              'Para usar PiñaApp, debe registrarse proporcionando información veraz y actualizada. Es responsable de mantener la confidencialidad de su cuenta y contraseña.',
            ),
            _buildSection(
              '4. Uso Permitido',
              'Usted se compromete a:\n'
              '• Usar la aplicación solo para fines legales\n'
              '• No publicar contenido falso o engañoso\n'
              '• No violar derechos de propiedad intelectual\n'
              '• No usar la aplicación para actividades fraudulentas\n'
              '• Respetar a otros usuarios de la plataforma',
            ),
            _buildSection(
              '5. Transacciones',
              'PiñaApp no es parte de las transacciones entre usuarios. Las negociaciones, acuerdos y pagos son responsabilidad exclusiva de las partes involucradas.',
            ),
            _buildSection(
              '6. Comisiones',
              'PiñaApp puede cobrar comisiones por el uso de la plataforma. Estas comisiones serán claramente comunicadas antes de cualquier transacción.',
            ),
            _buildSection(
              '7. Privacidad',
              'El uso de sus datos personales está regido por nuestra Política de Privacidad, que forma parte integral de estos términos.',
            ),
            _buildSection(
              '8. Propiedad Intelectual',
              'Todo el contenido de PiñaApp, incluyendo textos, gráficos, logos, y software, es propiedad de PiñaApp o sus licenciantes y está protegido por leyes de propiedad intelectual.',
            ),
            _buildSection(
              '9. Limitación de Responsabilidad',
              'PiñaApp no será responsable por pérdidas o daños indirectos, incidentales o consecuentes que resulten del uso de la plataforma.',
            ),
            _buildSection(
              '10. Modificaciones',
              'Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios entrarán en vigor al publicarse en la aplicación.',
            ),
            _buildSection(
              '11. Terminación',
              'Podemos suspender o terminar su acceso a PiñaApp si viola estos términos o por cualquier otra razón a nuestra discreción.',
            ),
            _buildSection(
              '12. Ley Aplicable',
              'Estos términos se rigen por las leyes de México y cualquier disputa será resuelta en los tribunales competentes de dicho país.',
            ),
            _buildSection(
              '13. Contacto',
              'Para preguntas sobre estos términos, contáctenos a través de:\n'
              'Email: legal@pinaapp.com\n'
              'Teléfono: +52 1234567890',
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
