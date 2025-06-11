import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pina_app/models/calificacion.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Aspectos positivos predefinidos
  static const List<String> aspectosProductor = [
    'Producto de calidad',
    'Entrega puntual',
    'Buena comunicación',
    'Precio justo',
    'Empaque adecuado',
    'Cantidad correcta',
    'Respuesta rápida',
    'Confiable',
  ];

  static const List<String> aspectosComprador = [
    'Pago puntual',
    'Comunicación clara',
    'Trato respetuoso',
    'Negociación justa',
    'Comprador serio',
    'Proceso rápido',
    'Confiable',
    'Recomendable',
  ];

  // Crear una calificación
  Future<bool> crearCalificacion({
    required String transaccionId,
    required String calificadorId,
    required String calificadorNombre,
    required String calificadoId,
    required String calificadoNombre,
    required String tipoCalificador,
    required double puntuacion,
    String? comentario,
    List<String> aspectosPositivos = const [],
  }) async {
    try {
      // Verificar si ya existe una calificación para esta transacción
      final existente = await _firestore
          .collection('calificaciones')
          .where('transaccionId', isEqualTo: transaccionId)
          .where('calificadorId', isEqualTo: calificadorId)
          .get();

      if (existente.docs.isNotEmpty) {
        print('Ya existe una calificación para esta transacción');
        return false;
      }

      // Crear la calificación
      await _firestore.collection('calificaciones').add({
        'transaccionId': transaccionId,
        'calificadorId': calificadorId,
        'calificadorNombre': calificadorNombre,
        'calificadoId': calificadoId,
        'calificadoNombre': calificadoNombre,
        'tipoCalificador': tipoCalificador,
        'puntuacion': puntuacion,
        'comentario': comentario,
        'aspectosPositivos': aspectosPositivos,
        'fechaCreacion': Timestamp.now(),
      });

      // Actualizar resumen de calificaciones del usuario calificado
      await _actualizarResumenCalificaciones(calificadoId);

      // Crear notificación
      await _crearNotificacion(
        usuarioId: calificadoId,
        tipo: 'nueva_calificacion',
        titulo: 'Nueva calificación recibida',
        mensaje: '$calificadorNombre te ha calificado con $puntuacion estrellas',
        datos: {
          'transaccionId': transaccionId,
          'calificadorId': calificadorId,
        },
      );

      // Marcar la transacción como calificada
      await _marcarTransaccionCalificada(transaccionId, calificadorId);

      return true;
    } catch (e) {
      print('Error creando calificación: $e');
      return false;
    }
  }

  // Obtener calificaciones de un usuario
  Stream<List<Calificacion>> getCalificacionesUsuario(String usuarioId) {
    return _firestore
        .collection('calificaciones')
        .where('calificadoId', isEqualTo: usuarioId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Calificacion.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Obtener resumen de calificaciones
  Stream<ResumenCalificaciones?> getResumenCalificaciones(String usuarioId) {
    return _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('estadisticas')
        .doc('calificaciones')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return ResumenCalificaciones.fromMap(snapshot.data()!);
    });
  }

  // Actualizar resumen de calificaciones
  Future<void> _actualizarResumenCalificaciones(String usuarioId) async {
    try {
      // Obtener todas las calificaciones del usuario
      final calificacionesSnapshot = await _firestore
          .collection('calificaciones')
          .where('calificadoId', isEqualTo: usuarioId)
          .get();

      if (calificacionesSnapshot.docs.isEmpty) return;

      final calificaciones = calificacionesSnapshot.docs
          .map((doc) => Calificacion.fromMap(doc.id, doc.data()))
          .toList();

      // Calcular estadísticas
      double sumaPuntuaciones = 0;
      Map<String, int> distribucionEstrellas = {
        '1': 0,
        '2': 0,
        '3': 0,
        '4': 0,
        '5': 0,
      };
      Map<String, int> frecuenciaAspectos = {};

      for (final calificacion in calificaciones) {
        sumaPuntuaciones += calificacion.puntuacion;
        distribucionEstrellas[calificacion.puntuacion.toInt().toString()] =
            (distribucionEstrellas[calificacion.puntuacion.toInt().toString()] ?? 0) + 1;

        for (final aspecto in calificacion.aspectosPositivos) {
          frecuenciaAspectos[aspecto] = (frecuenciaAspectos[aspecto] ?? 0) + 1;
        }
      }

      // Obtener los 5 aspectos más frecuentes
      final aspectosOrdenados = frecuenciaAspectos.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final aspectosMasFreecuentes = aspectosOrdenados
          .take(5)
          .map((e) => e.key)
          .toList();

      // Guardar resumen
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('estadisticas')
          .doc('calificaciones')
          .set({
        'usuarioId': usuarioId,
        'promedioGeneral': sumaPuntuaciones / calificaciones.length,
        'totalCalificaciones': calificaciones.length,
        'distribucionEstrellas': distribucionEstrellas,
        'aspectosMasFreecuentes': aspectosMasFreecuentes,
        'ultimaActualizacion': Timestamp.now(),
      });
    } catch (e) {
      print('Error actualizando resumen de calificaciones: $e');
    }
  }

  // Verificar si un usuario puede calificar una transacción
  Future<bool> puedeCalificar(String transaccionId, String calificadorId) async {
    try {
      // Verificar si ya existe una calificación
      final calificacionExistente = await _firestore
          .collection('calificaciones')
          .where('transaccionId', isEqualTo: transaccionId)
          .where('calificadorId', isEqualTo: calificadorId)
          .get();

      return calificacionExistente.docs.isEmpty;
    } catch (e) {
      print('Error verificando si puede calificar: $e');
      return false;
    }
  }

  // Obtener calificación de una transacción específica
  Future<Calificacion?> getCalificacionTransaccion(
    String transaccionId,
    String calificadorId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('calificaciones')
          .where('transaccionId', isEqualTo: transaccionId)
          .where('calificadorId', isEqualTo: calificadorId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return Calificacion.fromMap(
        querySnapshot.docs.first.id,
        querySnapshot.docs.first.data(),
      );
    } catch (e) {
      print('Error obteniendo calificación de transacción: $e');
      return null;
    }
  }

  // Marcar transacción como calificada
  Future<void> _marcarTransaccionCalificada(
    String transaccionId,
    String calificadorId,
  ) async {
    try {
      final transaccionRef = _firestore.collection('transacciones').doc(transaccionId);
      final transaccionDoc = await transaccionRef.get();

      if (!transaccionDoc.exists) return;

      final data = transaccionDoc.data()!;
      Map<String, bool> calificaciones = Map<String, bool>.from(data['calificaciones'] ?? {});
      calificaciones[calificadorId] = true;

      await transaccionRef.update({
        'calificaciones': calificaciones,
      });
    } catch (e) {
      print('Error marcando transacción como calificada: $e');
    }
  }

  // Crear notificación
  Future<void> _crearNotificacion({
    required String usuarioId,
    required String tipo,
    required String titulo,
    required String mensaje,
    required Map<String, dynamic> datos,
  }) async {
    try {
      await _firestore.collection('notificaciones').add({
        'usuarioId': usuarioId,
        'tipo': tipo,
        'titulo': titulo,
        'mensaje': mensaje,
        'datos': datos,
        'leido': false,
        'fechaCreacion': Timestamp.now(),
      });
    } catch (e) {
      print('Error creando notificación: $e');
    }
  }

  // Obtener aspectos positivos según el tipo
  List<String> getAspectosPositivos(String tipoCalificador) {
    return tipoCalificador == 'productor' ? aspectosComprador : aspectosProductor;
  }
}
