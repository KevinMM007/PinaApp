import 'package:cloud_firestore/cloud_firestore.dart';

class Mensaje {
  final String id;
  final String senderId;
  final String senderNombre;
  final String receiverId;
  final String conversacionId;
  final String contenido;
  final String tipo; // 'texto', 'imagen', 'oferta'
  final DateTime fechaEnvio;
  final bool leido;
  final Map<String, dynamic>? datosAdicionales; // Para ofertas u otros datos

  Mensaje({
    required this.id,
    required this.senderId,
    required this.senderNombre,
    required this.receiverId,
    required this.conversacionId,
    required this.contenido,
    required this.tipo,
    required this.fechaEnvio,
    required this.leido,
    this.datosAdicionales,
  });

  factory Mensaje.fromMap(String id, Map<String, dynamic> data) {
    return Mensaje(
      id: id,
      senderId: data['senderId'] ?? '',
      senderNombre: data['senderNombre'] ?? '',
      receiverId: data['receiverId'] ?? '',
      conversacionId: data['conversacionId'] ?? '',
      contenido: data['contenido'] ?? '',
      tipo: data['tipo'] ?? 'texto',
      fechaEnvio: (data['fechaEnvio'] as Timestamp).toDate(),
      leido: data['leido'] ?? false,
      datosAdicionales: data['datosAdicionales'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderNombre': senderNombre,
      'receiverId': receiverId,
      'conversacionId': conversacionId,
      'contenido': contenido,
      'tipo': tipo,
      'fechaEnvio': Timestamp.fromDate(fechaEnvio),
      'leido': leido,
      'datosAdicionales': datosAdicionales,
    };
  }
}

class Conversacion {
  final String id;
  final List<String> participantes;
  final Map<String, String> participantesInfo; // userId: nombre
  final String? productoId;
  final String? productoNombre;
  final String? ultimoMensaje;
  final DateTime? fechaUltimoMensaje;
  final Map<String, int> mensajesNoLeidos;

  Conversacion({
    required this.id,
    required this.participantes,
    required this.participantesInfo,
    this.productoId,
    this.productoNombre,
    this.ultimoMensaje,
    this.fechaUltimoMensaje,
    required this.mensajesNoLeidos,
  });

  factory Conversacion.fromMap(String id, Map<String, dynamic> data) {
    return Conversacion(
      id: id,
      participantes: List<String>.from(data['participantes'] ?? []),
      participantesInfo: Map<String, String>.from(data['participantesInfo'] ?? {}),
      productoId: data['productoId'],
      productoNombre: data['productoNombre'],
      ultimoMensaje: data['ultimoMensaje'],
      fechaUltimoMensaje: data['fechaUltimoMensaje'] != null
          ? (data['fechaUltimoMensaje'] as Timestamp).toDate()
          : null,
      mensajesNoLeidos: Map<String, int>.from(data['mensajesNoLeidos'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantes': participantes,
      'participantesInfo': participantesInfo,
      'productoId': productoId,
      'productoNombre': productoNombre,
      'ultimoMensaje': ultimoMensaje,
      'fechaUltimoMensaje': fechaUltimoMensaje != null
          ? Timestamp.fromDate(fechaUltimoMensaje!)
          : null,
      'mensajesNoLeidos': mensajesNoLeidos,
    };
  }
}
