import 'package:cloud_firestore/cloud_firestore.dart';

class Calificacion {
  final String id;
  final String transaccionId;
  final String calificadorId;
  final String calificadorNombre;
  final String calificadoId;
  final String calificadoNombre;
  final String tipoCalificador; // 'productor', 'comprador'
  final double puntuacion; // 1-5 estrellas
  final String? comentario;
  final List<String> aspectosPositivos; // tags predefinidos
  final DateTime fechaCreacion;

  Calificacion({
    required this.id,
    required this.transaccionId,
    required this.calificadorId,
    required this.calificadorNombre,
    required this.calificadoId,
    required this.calificadoNombre,
    required this.tipoCalificador,
    required this.puntuacion,
    this.comentario,
    required this.aspectosPositivos,
    required this.fechaCreacion,
  });

  factory Calificacion.fromMap(String id, Map<String, dynamic> data) {
    return Calificacion(
      id: id,
      transaccionId: data['transaccionId'] ?? '',
      calificadorId: data['calificadorId'] ?? '',
      calificadorNombre: data['calificadorNombre'] ?? '',
      calificadoId: data['calificadoId'] ?? '',
      calificadoNombre: data['calificadoNombre'] ?? '',
      tipoCalificador: data['tipoCalificador'] ?? '',
      puntuacion: (data['puntuacion'] ?? 0).toDouble(),
      comentario: data['comentario'],
      aspectosPositivos: List<String>.from(data['aspectosPositivos'] ?? []),
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transaccionId': transaccionId,
      'calificadorId': calificadorId,
      'calificadorNombre': calificadorNombre,
      'calificadoId': calificadoId,
      'calificadoNombre': calificadoNombre,
      'tipoCalificador': tipoCalificador,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'aspectosPositivos': aspectosPositivos,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }
}

class ResumenCalificaciones {
  final String usuarioId;
  final double promedioGeneral;
  final int totalCalificaciones;
  final Map<String, int> distribucionEstrellas; // '5': 10, '4': 5, etc
  final List<String> aspectosMasFreecuentes;
  final DateTime? ultimaActualizacion;

  ResumenCalificaciones({
    required this.usuarioId,
    required this.promedioGeneral,
    required this.totalCalificaciones,
    required this.distribucionEstrellas,
    required this.aspectosMasFreecuentes,
    this.ultimaActualizacion,
  });

  factory ResumenCalificaciones.fromMap(Map<String, dynamic> data) {
    return ResumenCalificaciones(
      usuarioId: data['usuarioId'] ?? '',
      promedioGeneral: (data['promedioGeneral'] ?? 0).toDouble(),
      totalCalificaciones: data['totalCalificaciones'] ?? 0,
      distribucionEstrellas: Map<String, int>.from(data['distribucionEstrellas'] ?? {}),
      aspectosMasFreecuentes: List<String>.from(data['aspectosMasFreecuentes'] ?? []),
      ultimaActualizacion: data['ultimaActualizacion'] != null
          ? (data['ultimaActualizacion'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'promedioGeneral': promedioGeneral,
      'totalCalificaciones': totalCalificaciones,
      'distribucionEstrellas': distribucionEstrellas,
      'aspectosMasFreecuentes': aspectosMasFreecuentes,
      'ultimaActualizacion': ultimaActualizacion != null
          ? Timestamp.fromDate(ultimaActualizacion!)
          : null,
    };
  }
}
