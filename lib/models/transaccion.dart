import 'package:cloud_firestore/cloud_firestore.dart';

class Transaccion {
  final String id;
  final String productoId;
  final String productoNombre;
  final String productorId;
  final String productorNombre;
  final String compradorId;
  final String compradorNombre;
  final double cantidad;
  final String unidadMedida;
  final double precioUnitario;
  final double precioTotal;
  final String estado; // 'pendiente', 'completada', 'cancelada'
  final DateTime fechaCreacion;
  final DateTime? fechaCompletada;
  final String? notasAdicionales;
  final Map<String, dynamic>? detallesProducto;

  Transaccion({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.productorId,
    required this.productorNombre,
    required this.compradorId,
    required this.compradorNombre,
    required this.cantidad,
    required this.unidadMedida,
    required this.precioUnitario,
    required this.precioTotal,
    required this.estado,
    required this.fechaCreacion,
    this.fechaCompletada,
    this.notasAdicionales,
    this.detallesProducto,
  });

  factory Transaccion.fromMap(String id, Map<String, dynamic> data) {
    return Transaccion(
      id: id,
      productoId: data['productoId'] ?? '',
      productoNombre: data['productoNombre'] ?? '',
      productorId: data['productorId'] ?? '',
      productorNombre: data['productorNombre'] ?? '',
      compradorId: data['compradorId'] ?? '',
      compradorNombre: data['compradorNombre'] ?? '',
      cantidad: (data['cantidad'] ?? 0).toDouble(),
      unidadMedida: data['unidadMedida'] ?? 'kg',
      precioUnitario: (data['precioUnitario'] ?? 0).toDouble(),
      precioTotal: (data['precioTotal'] ?? 0).toDouble(),
      estado: data['estado'] ?? 'pendiente',
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      fechaCompletada: data['fechaCompletada'] != null
          ? (data['fechaCompletada'] as Timestamp).toDate()
          : null,
      notasAdicionales: data['notasAdicionales'],
      detallesProducto: data['detallesProducto'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'productoNombre': productoNombre,
      'productorId': productorId,
      'productorNombre': productorNombre,
      'compradorId': compradorId,
      'compradorNombre': compradorNombre,
      'cantidad': cantidad,
      'unidadMedida': unidadMedida,
      'precioUnitario': precioUnitario,
      'precioTotal': precioTotal,
      'estado': estado,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaCompletada': fechaCompletada != null
          ? Timestamp.fromDate(fechaCompletada!)
          : null,
      'notasAdicionales': notasAdicionales,
      'detallesProducto': detallesProducto,
    };
  }
}
