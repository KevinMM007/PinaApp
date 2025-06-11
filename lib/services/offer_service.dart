import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pina_app/models/oferta.dart';

class OfferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear una nueva oferta
  Future<String?> crearOferta({
    required String productoId,
    required String compradorId,
    required String compradorNombre,
    required String compradorFoto,
    required String productorId,
    required String productorNombre,
    required double precioOfertado,
    required double cantidadSolicitada,
    required String unidadMedida,
    String? mensaje,
  }) async {
    try {
      final docRef = await _firestore.collection('ofertas').add({
        'productoId': productoId,
        'compradorId': compradorId,
        'compradorNombre': compradorNombre,
        'compradorFoto': compradorFoto,
        'productorId': productorId,
        'productorNombre': productorNombre,
        'precioOfertado': precioOfertado,
        'cantidadSolicitada': cantidadSolicitada,
        'unidadMedida': unidadMedida,
        'estado': 'pendiente',
        'mensaje': mensaje,
        'fechaCreacion': Timestamp.now(),
      });

      // Crear notificación para el productor
      await _crearNotificacion(
        usuarioId: productorId,
        tipo: 'nueva_oferta',
        titulo: 'Nueva oferta recibida',
        mensaje: '$compradorNombre ha hecho una oferta por tu producto',
        datos: {
          'ofertaId': docRef.id,
          'productoId': productoId,
        },
      );

      return docRef.id;
    } catch (e) {
      print('Error creando oferta: $e');
      return null;
    }
  }

  // Obtener ofertas para un producto
  Stream<List<Oferta>> getOfertasPorProducto(String productoId) {
    return _firestore
        .collection('ofertas')
        .where('productoId', isEqualTo: productoId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Oferta.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Obtener ofertas hechas por un comprador
  Stream<List<Oferta>> getOfertasPorComprador(String compradorId) {
    return _firestore
        .collection('ofertas')
        .where('compradorId', isEqualTo: compradorId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Oferta.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Obtener ofertas recibidas por un productor
  Stream<List<Oferta>> getOfertasPorProductor(String productorId) {
    return _firestore
        .collection('ofertas')
        .where('productorId', isEqualTo: productorId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Oferta.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Aceptar una oferta
  Future<bool> aceptarOferta(String ofertaId, String? respuesta) async {
    try {
      await _firestore.collection('ofertas').doc(ofertaId).update({
        'estado': 'aceptada',
        'respuesta': respuesta,
        'fechaRespuesta': Timestamp.now(),
      });

      // Obtener datos de la oferta para la notificación
      final ofertaDoc =
          await _firestore.collection('ofertas').doc(ofertaId).get();
      final ofertaData = ofertaDoc.data()!;

      // Crear notificación para el comprador
      await _crearNotificacion(
        usuarioId: ofertaData['compradorId'],
        tipo: 'oferta_aceptada',
        titulo: '¡Oferta aceptada!',
        mensaje: '${ofertaData['productorNombre']} ha aceptado tu oferta',
        datos: {
          'ofertaId': ofertaId,
          'productoId': ofertaData['productoId'],
        },
      );

      return true;
    } catch (e) {
      print('Error aceptando oferta: $e');
      return false;
    }
  }

  // Rechazar una oferta
  Future<bool> rechazarOferta(String ofertaId, String? respuesta) async {
    try {
      await _firestore.collection('ofertas').doc(ofertaId).update({
        'estado': 'rechazada',
        'respuesta': respuesta,
        'fechaRespuesta': Timestamp.now(),
      });

      // Obtener datos de la oferta para la notificación
      final ofertaDoc =
          await _firestore.collection('ofertas').doc(ofertaId).get();
      final ofertaData = ofertaDoc.data()!;

      // Crear notificación para el comprador
      await _crearNotificacion(
        usuarioId: ofertaData['compradorId'],
        tipo: 'oferta_rechazada',
        titulo: 'Oferta rechazada',
        mensaje: '${ofertaData['productorNombre']} ha rechazado tu oferta',
        datos: {
          'ofertaId': ofertaId,
          'productoId': ofertaData['productoId'],
        },
      );

      return true;
    } catch (e) {
      print('Error rechazando oferta: $e');
      return false;
    }
  }

  // Hacer una contraoferta
  Future<bool> hacerContraoferta(
    String ofertaId,
    double precioContraoferta,
    String? respuesta,
  ) async {
    try {
      await _firestore.collection('ofertas').doc(ofertaId).update({
        'estado': 'contraoferta',
        'precioContraoferta': precioContraoferta,
        'respuesta': respuesta,
        'fechaRespuesta': Timestamp.now(),
      });

      // Obtener datos de la oferta para la notificación
      final ofertaDoc =
          await _firestore.collection('ofertas').doc(ofertaId).get();
      final ofertaData = ofertaDoc.data()!;

      // Crear notificación para el comprador
      await _crearNotificacion(
        usuarioId: ofertaData['compradorId'],
        tipo: 'contraoferta_recibida',
        titulo: 'Contraoferta recibida',
        mensaje: '${ofertaData['productorNombre']} ha hecho una contraoferta',
        datos: {
          'ofertaId': ofertaId,
          'productoId': ofertaData['productoId'],
        },
      );

      return true;
    } catch (e) {
      print('Error haciendo contraoferta: $e');
      return false;
    }
  }

  // Cancelar una oferta (solo por el comprador)
  Future<bool> cancelarOferta(String ofertaId) async {
    try {
      await _firestore.collection('ofertas').doc(ofertaId).update({
        'estado': 'cancelada',
        'fechaRespuesta': Timestamp.now(),
      });

      return true;
    } catch (e) {
      print('Error cancelando oferta: $e');
      return false;
    }
  }

  // Obtener estadísticas de ofertas para un producto
  Future<Map<String, dynamic>> getEstadisticasOfertasProducto(
      String productoId) async {
    try {
      final querySnapshot = await _firestore
          .collection('ofertas')
          .where('productoId', isEqualTo: productoId)
          .get();

      final ofertas = querySnapshot.docs
          .map((doc) => Oferta.fromMap(doc.id, doc.data()))
          .toList();

      if (ofertas.isEmpty) {
        return {
          'totalOfertas': 0,
          'ofertasAceptadas': 0,
          'ofertasRechazadas': 0,
          'ofertasPendientes': 0,
          'precioPromedio': 0.0,
          'precioMaximo': 0.0,
          'precioMinimo': 0.0,
        };
      }

      final precios = ofertas.map((o) => o.precioOfertado).toList();
      precios.sort();

      return {
        'totalOfertas': ofertas.length,
        'ofertasAceptadas': ofertas.where((o) => o.estado == 'aceptada').length,
        'ofertasRechazadas':
            ofertas.where((o) => o.estado == 'rechazada').length,
        'ofertasPendientes':
            ofertas.where((o) => o.estado == 'pendiente').length,
        'precioPromedio': precios.reduce((a, b) => a + b) / precios.length,
        'precioMaximo': precios.last,
        'precioMinimo': precios.first,
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {};
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
}
