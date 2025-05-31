import 'package:flutter/material.dart';
import 'package:pina_app/services/user_sync_service.dart';

/// Widget temporal para depurar y reparar problemas de sincronización
///
/// Agrégalo temporalmente en tu LoginScreen:
/// ```dart
/// Column(
///   children: [
///     // ... tu código existente ...
///     SyncDebugWidget(), // Agregar esto
///   ],
/// )
/// ```
class SyncDebugWidget extends StatefulWidget {
  const SyncDebugWidget({Key? key}) : super(key: key);

  @override
  State<SyncDebugWidget> createState() => _SyncDebugWidgetState();
}

class _SyncDebugWidgetState extends State<SyncDebugWidget> {
  bool _isChecking = false;
  String _status = '';

  Future<void> _checkAndSync() async {
    setState(() {
      _isChecking = true;
      _status = 'Verificando...';
    });

    try {
      // Verificar estado actual
      final status = await UserSyncService.checkCurrentUserSync();

      setState(() {
        _status = status.message;
      });

      // Si hay usuario en Auth pero no documento, crear automáticamente
      if (status.hasAuth && !status.hasDocument) {
        setState(() {
          _status = 'Creando documento faltante...';
        });

        await Future.delayed(const Duration(seconds: 1));

        final result = await UserSyncService.syncAuthWithFirestore();

        setState(() {
          if (result['created'] == 1) {
            _status = '✅ Documento creado exitosamente';
          } else if (result['errors'] > 0) {
            _status = '❌ Error: ${result['details'].join('\n')}';
          } else {
            _status = '✅ El documento ya existe';
          }
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔧 Herramienta de Debug',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          if (_status.isNotEmpty)
            Text(
              _status,
              style: TextStyle(
                fontSize: 12,
                color: _status.contains('✅')
                    ? Colors.green
                    : _status.contains('❌')
                        ? Colors.red
                        : Colors.black87,
              ),
            ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _isChecking ? null : _checkAndSync,
            icon: _isChecking
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.sync),
            label: Text(_isChecking ? 'Verificando...' : 'Verificar y Reparar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Verifica si tu usuario tiene documento en Firestore',
            style: TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget simplificado para agregar después del botón de login
class QuickSyncButton extends StatelessWidget {
  const QuickSyncButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        // Mostrar diálogo de progreso
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Verificando sincronización...'),
              ],
            ),
          ),
        );

        try {
          // Verificar estado
          final status = await UserSyncService.checkCurrentUserSync();

          // Si necesita sincronización
          if (status.hasAuth && !status.hasDocument) {
            final result = await UserSyncService.syncAuthWithFirestore();

            Navigator.pop(context);

            // Mostrar resultado
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['created'] == 1
                    ? '✅ Perfil sincronizado correctamente'
                    : '❌ Error sincronizando perfil'),
                backgroundColor:
                    result['created'] == 1 ? Colors.green : Colors.red,
              ),
            );
          } else {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(status.message),
                backgroundColor: status.isSync ? Colors.green : Colors.orange,
              ),
            );
          }
        } catch (e) {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      icon: const Icon(Icons.sync_problem, size: 16),
      label: const Text('¿Problemas al iniciar sesión?'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.orange,
      ),
    );
  }
}
