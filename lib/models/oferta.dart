import 'package:cloud_firestore/cloud_firestore.dart';

class Oferta {
  final String id;
  final String productoId;
  final String compradorId;
  final String compradorNombre;
  final String compradorFoto;
  final String productorId;
  final String productorNombre;
  final double precioOfertado;
  final double cantidadSolicitada;
  final String unidadMedida;
  final String estado; // 'pendiente', 'aceptada', 'rechazada', 'contraoferta'
  final String? mensaje;
  final String? respuesta;
  final double? precioContraoferta;
  final DateTime fechaCreacion;
  final DateTime? fechaRespuesta;

  Oferta({
    required this.id,
    required this.productoId,
    required this.compradorId,
    required this.compradorNombre,
    required this.compradorFoto,
    required this.productorId,
    required this.productorNombre,
    required this.precioOfertado,
    required this.cantidadSolicitada,
    required this.unidadMedida,
    required this.estado,
    this.mensaje,
    this.respuesta,
    this.precioContraoferta,
    required this.fechaCreacion,
    this.fechaRespuesta,
  });

  factory Oferta.fromMap(String id, Map<String, dynamic> data) {
    return Oferta(
      id: id,
      productoId: data['productoId'] ?? '',
      compradorId: data['compradorId'] ?? '',
      compradorNombre: data['compradorNombre'] ?? '',
      compradorFoto: data['compradorFoto'] ?? '',
      productorId: data['productorId'] ?? '',
      productorNombre: data['productorNombre'] ?? '',
      precioOfertado: (data['precioOfertado'] ?? 0).toDouble(),
      cantidadSolicitada: (data['cantidadSolicitada'] ?? 0).toDouble(),
      unidadMedida: data['unidadMedida'] ?? 'kg',
      estado: data['estado'] ?? 'pendiente',
      mensaje: data['mensaje'],
      respuesta: data['respuesta'],
      precioContraoferta: data['precioContraoferta']?.toDouble(),
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      fechaRespuesta: data['fechaRespuesta'] != null
          ? (data['fechaRespuesta'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'compradorId': compradorId,
      'compradorNombre': compradorNombre,
      'compradorFoto': compradorFoto,
      'productorId': productorId,
      'productorNombre': productorNombre,
      'precioOfertado': precioOfertado,
      'cantidadSolicitada': cantidadSolicitada,
      'unidadMedida': unidadMedida,
      'estado': estado,
      'mensaje': mensaje,
      'respuesta': respuesta,
      'precioContraoferta': precioContraoferta,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaRespuesta': fechaRespuesta != null
          ? Timestamp.fromDate(fechaRespuesta!)
          : null,
    };
  }
}
