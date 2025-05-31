import 'package:flutter/material.dart';
import 'package:pina_app/models/usuario.dart';
import 'package:pina_app/config/constants.dart';

class ProfileCompletionCard extends StatelessWidget {
  final Usuario user;

  const ProfileCompletionCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completionData = _calculateCompletion();
    final percentage = completionData['percentage'] as double;
    final missingItems = completionData['missing'] as List<String>;

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Completa tu perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Barra de progreso
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(percentage < 50
                        ? Colors.red
                        : percentage < 80
                            ? Colors.orange
                            : Colors.green),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${percentage.toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Para completar tu perfil y aparecer en las búsquedas, completa la siguiente información:',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // Lista de elementos faltantes
            ...missingItems
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/edit_profile');
                },
                icon: const Icon(Icons.edit),
                label: const Text('Completar Perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateCompletion() {
    List<String> missing = [];
    int totalFields = 0;
    int completedFields = 0;

    // Campos básicos
    totalFields += 4;
    if (user.nombre.isNotEmpty) {
      completedFields++;
    } else {
      missing.add('Nombre completo');
    }

    if (user.telefono.isNotEmpty) {
      completedFields++;
    } else {
      missing.add('Número de teléfono');
    }

    if (user.ubicacion.isNotEmpty) {
      completedFields++;
    } else {
      missing.add('Ubicación');
    }

    if (user.fotoPerfil.isNotEmpty) {
      completedFields++;
    } else {
      missing.add('Foto de perfil');
    }

    // Campos específicos por rol
    switch (user.tipo) {
      case AppConstants.rolProductor:
        totalFields += 4;
        if (user.perfilProductor?.nombreFinca.isNotEmpty == true) {
          completedFields++;
        } else {
          missing.add('Nombre de la finca');
        }

        if ((user.perfilProductor?.hectareas ?? 0) > 0) {
          completedFields++;
        } else {
          missing.add('Hectáreas de cultivo');
        }

        if (user.perfilProductor?.variedadesCultivadas.isNotEmpty == true) {
          completedFields++;
        } else {
          missing.add('Variedades cultivadas');
        }

        if ((user.perfilProductor?.capacidadProductivaMensual ?? 0) > 0) {
          completedFields++;
        } else {
          missing.add('Capacidad productiva');
        }
        break;

      case AppConstants.rolComprador:
        totalFields += 4;
        if (user.perfilComprador?.nombreEmpresa.isNotEmpty == true) {
          completedFields++;
        } else {
          missing.add('Nombre de la empresa');
        }

        if ((user.perfilComprador?.volumenCompraMensual ?? 0) > 0) {
          completedFields++;
        } else {
          missing.add('Volumen de compra mensual');
        }

        if (user.perfilComprador?.variedadesInteres.isNotEmpty == true) {
          completedFields++;
        } else {
          missing.add('Variedades de interés');
        }

        if (user.perfilComprador?.tipoComprador.isNotEmpty == true) {
          completedFields++;
        } else {
          missing.add('Tipo de comprador');
        }
        break;

      case AppConstants.rolTransportista:
        totalFields += 4;
        if (user.perfilTransportista?.nombreEmpresa.isNotEmpty == true) {
          completedFields++;
        } else {
          missing.add('Nombre de la empresa');
        }

        if (user.perfilTransportista?.vehiculos.isNotEmpty == true) {
          completedFields++;
        } else {
          missing.add('Vehículos disponibles');
        }

        if ((user.perfilTransportista?.capacidadTotalToneladas ?? 0) > 0) {
          completedFields++;
        } else {
          missing.add('Capacidad total');
        }

        if (user.perfilTransportista?.tiposCarga.isNotEmpty == true) {
          completedFields++;
        } else {
          missing.add('Tipos de carga');
        }
        break;
    }

    double percentage =
        totalFields > 0 ? (completedFields / totalFields) * 100 : 0;

    return {
      'percentage': percentage,
      'missing': missing,
      'completed': completedFields,
      'total': totalFields,
    };
  }
}
