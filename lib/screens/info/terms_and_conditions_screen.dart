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
              'Al acceder y utilizar PiñaApp, usted acepta cumplir y estar sujeto a estos Términos y Condiciones. Si no está de acuerdo con alguna parte de estos términos, no debe usar nuestra aplicación.',
            ),
            _buildSection(
              '2. Descripción del Servicio',
              'PiñaApp es una plataforma digital que conecta productores, compradores y transportistas en el mercado de la piña. Facilitamos la comunicación y las transacciones entre las partes, pero no somos responsables de la calidad, entrega o pago de los productos.',
            ),
            _buildSection(
              '3. Registro y Cuenta',
              '• Debe proporcionar información precisa y completa al registrarse.\n'
              '• Es responsable de mantener la confidencialidad de su cuenta.\n'
              '• Debe notificarnos inmediatamente sobre cualquier uso no autorizado.\n'
              '• Debe ser mayor de 18 años para usar este servicio.',
            ),
            _buildSection(
              '4. Uso Aceptable',
              'Los usuarios se comprometen a:\n'
              '• No usar la plataforma para actividades ilegales.\n'
              '• No publicar contenido falso o engañoso.\n'
              '• No acosar o dañar a otros usuarios.\n'
              '• Respetar los derechos de propiedad intelectual.',
            ),
            _buildSection(
              '5. Transacciones',
              '• PiñaApp facilita la conexión entre usuarios pero no es parte de las transacciones.\n'
              '• Los usuarios son responsables de cumplir con sus acuerdos.\n'
              '• Recomendamos verificar la identidad y credibilidad de otros usuarios.\n'
              '• PiñaApp no garantiza la calidad de productos o servicios.',
            ),
            _buildSection(
              '6. Comisiones y Pagos',
              '• PiñaApp puede cobrar comisiones por ciertas transacciones.\n'
              '• Las tarifas se comunicarán claramente antes de confirmar.\n'
              '• Los pagos entre usuarios son responsabilidad de las partes.',
            ),
            _buildSection(
              '7. Propiedad Intelectual',
              'Todo el contenido de PiñaApp, incluyendo textos, gráficos, logos, y software, es propiedad de PiñaApp o sus licenciantes y está protegido por las leyes de propiedad intelectual.',
            ),
            _buildSection(
              '8. Limitación de Responsabilidad',
              'PiñaApp no será responsable por:\n'
              '• Pérdidas o daños resultantes del uso de la plataforma.\n'
              '• Disputas entre usuarios.\n'
              '• Pérdida de datos o interrupciones del servicio.\n'
              '• Contenido publicado por usuarios.',
            ),
            _buildSection(
              '9. Privacidad',
              'El uso de nuestros servicios está sujeto a nuestra Política de Privacidad, que describe cómo recopilamos, usamos y protegemos su información personal.',
            ),
            _buildSection(
              '10. Modificaciones',
              'PiñaApp se reserva el derecho de modificar estos términos en cualquier momento. Los cambios entrarán en vigor al publicarse en la aplicación.',
            ),
            _buildSection(
              '11. Terminación',
              'Podemos suspender o terminar su cuenta si viola estos términos o por cualquier otra razón a nuestra discreción.',
            ),
            _buildSection(
              '12. Ley Aplicable',
              'Estos términos se regirán por las leyes de México y cualquier disputa se resolverá en los tribunales competentes.',
            ),
            _buildSection(
              '13. Contacto',
              'Para preguntas sobre estos términos, contáctenos en:\n'
              'Email: legal@pinaapp.mx\n'
              'Teléfono: +52 (555) 123-4567',
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Entendido'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
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
    );
  }
}
