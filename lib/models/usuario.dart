import 'perfil_productor.dart';
import 'perfil_comprador.dart';
import 'perfil_transportista.dart';

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String tipo; // "productor", "comprador", "transportista"
  final String fotoPerfil;
  final String ubicacion;
  final double? latitud;
  final double? longitud;
  final double calificacionPromedio;
  final int numeroTransacciones;
  final bool perfilCompleto;
  final bool verificado;
  final DateTime? fechaVerificacion;
  final DateTime fechaRegistro;
  final DateTime? ultimaActividad;
  final Map<String, dynamic> configuracion;

  // Perfiles específicos por rol
  final PerfilProductor? perfilProductor;
  final PerfilComprador? perfilComprador;
  final PerfilTransportista? perfilTransportista;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.tipo,
    this.fotoPerfil = '',
    this.ubicacion = '',
    this.latitud,
    this.longitud,
    this.calificacionPromedio = 0.0,
    this.numeroTransacciones = 0,
    this.perfilCompleto = false,
    this.verificado = false,
    this.fechaVerificacion,
    DateTime? fechaRegistro,
    this.ultimaActividad,
    this.configuracion = const {},
    this.perfilProductor,
    this.perfilComprador,
    this.perfilTransportista,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  factory Usuario.fromMap(Map<String, dynamic> map, String id) {
    // Función helper para parsear timestamps de forma segura
    DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return null;
      
      try {
        // Caso 1: Es un Timestamp de Firestore
        if (timestamp.runtimeType.toString().contains('Timestamp')) {
          return timestamp.toDate();
        }
        
        // Caso 2: Es un Map con _seconds y _nanoseconds
        if (timestamp is Map) {
          if (timestamp.containsKey('_seconds')) {
            final seconds = timestamp['_seconds'] as int;
            final nanoseconds = (timestamp['_nanoseconds'] ?? 0) as int;
            return DateTime.fromMillisecondsSinceEpoch(
              seconds * 1000 + (nanoseconds ~/ 1000000)
            );
          }
        }
        
        // Caso 3: Es un DateTime
        if (timestamp is DateTime) {
          return timestamp;
        }
        
        // Caso 4: Es un String ISO
        if (timestamp is String) {
          return DateTime.tryParse(timestamp);
        }
        
        // Caso 5: Es un número (milliseconds)
        if (timestamp is num) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
        }
      } catch (e) {
        print('Error parseando timestamp: $e');
      }
      
      return null;
    }

    try {
      return Usuario(
        id: id,
        nombre: map['nombre'] ?? '',
        email: map['email'] ?? '',
        telefono: map['telefono'] ?? '',
        tipo: map['tipo'] ?? 'productor',
        fotoPerfil: map['fotoPerfil'] ?? '',
        ubicacion: map['ubicacion'] ?? '',
        latitud: map['coordenadas']?['latitud']?.toDouble(),
        longitud: map['coordenadas']?['longitud']?.toDouble(),
        calificacionPromedio: (map['calificacionPromedio'] ?? 0.0).toDouble(),
        numeroTransacciones: (map['numeroTransacciones'] ?? 0).toInt(),
        perfilCompleto: map['perfilCompleto'] ?? false,
        verificado: map['verificado'] ?? false,
        fechaVerificacion: parseTimestamp(map['fechaVerificacion']),
        fechaRegistro: parseTimestamp(map['fechaRegistro']) ?? DateTime.now(),
        ultimaActividad: parseTimestamp(map['ultimaActividad']),
        configuracion: Map<String, dynamic>.from(map['configuracion'] ?? {}),
        perfilProductor: map['perfilProductor'] != null
            ? PerfilProductor.fromMap(Map<String, dynamic>.from(map['perfilProductor']))
            : null,
        perfilComprador: map['perfilComprador'] != null
            ? PerfilComprador.fromMap(Map<String, dynamic>.from(map['perfilComprador']))
            : null,
        perfilTransportista: map['perfilTransportista'] != null
            ? PerfilTransportista.fromMap(Map<String, dynamic>.from(map['perfilTransportista']))
            : null,
      );
    } catch (e) {
      print('Error parseando Usuario: $e');
      print('Map data: $map');
      // Retornar un usuario con datos mínimos en caso de error
      return Usuario(
        id: id,
        nombre: map['nombre'] ?? 'Usuario',
        email: map['email'] ?? '',
        telefono: map['telefono'] ?? '',
        tipo: map['tipo'] ?? 'productor',
        fechaRegistro: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'tipo': tipo,
      'fotoPerfil': fotoPerfil,
      'ubicacion': ubicacion,
      'coordenadas': (latitud != null && longitud != null) ? {
        'latitud': latitud,
        'longitud': longitud,
      } : null,
      'calificacionPromedio': calificacionPromedio,
      'numeroTransacciones': numeroTransacciones,
      'perfilCompleto': perfilCompleto,
      'verificado': verificado,
      'fechaVerificacion': fechaVerificacion,
      'fechaRegistro': fechaRegistro,
      'ultimaActividad': ultimaActividad,
      'configuracion': configuracion,
      'perfilProductor': perfilProductor?.toMap(),
      'perfilComprador': perfilComprador?.toMap(),
      'perfilTransportista': perfilTransportista?.toMap(),
    };
  }

  Usuario copyWith({
    String? nombre,
    String? email,
    String? telefono,
    String? tipo,
    String? fotoPerfil,
    String? ubicacion,
    double? latitud,
    double? longitud,
    double? calificacionPromedio,
    int? numeroTransacciones,
    bool? perfilCompleto,
    bool? verificado,
    DateTime? fechaVerificacion,
    DateTime? fechaRegistro,
    DateTime? ultimaActividad,
    Map<String, dynamic>? configuracion,
    PerfilProductor? perfilProductor,
    PerfilComprador? perfilComprador,
    PerfilTransportista? perfilTransportista,
  }) {
    return Usuario(
      id: id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      tipo: tipo ?? this.tipo,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      ubicacion: ubicacion ?? this.ubicacion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      numeroTransacciones: numeroTransacciones ?? this.numeroTransacciones,
      perfilCompleto: perfilCompleto ?? this.perfilCompleto,
      verificado: verificado ?? this.verificado,
      fechaVerificacion: fechaVerificacion ?? this.fechaVerificacion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimaActividad: ultimaActividad ?? this.ultimaActividad,
      configuracion: configuracion ?? this.configuracion,
      perfilProductor: perfilProductor ?? this.perfilProductor,
      perfilComprador: perfilComprador ?? this.perfilComprador,
      perfilTransportista: perfilTransportista ?? this.perfilTransportista,
    );
  }

  // Helper methods
  bool get tienePerfilCompleto {
    switch (tipo) {
      case 'productor':
        return perfilProductor != null &&
            perfilProductor!.nombreFinca.isNotEmpty &&
            perfilProductor!.hectareas > 0;
      case 'comprador':
        return perfilComprador != null &&
            perfilComprador!.nombreEmpresa.isNotEmpty &&
            perfilComprador!.volumenCompraMensual > 0;
      case 'transportista':
        return perfilTransportista != null &&
            perfilTransportista!.nombreEmpresa.isNotEmpty &&
            perfilTransportista!.vehiculos.isNotEmpty;
      default:
        return false;
    }
  }

  String get nombreCompleto {
    switch (tipo) {
      case 'productor':
        return perfilProductor?.nombreFinca.isNotEmpty == true
            ? '$nombre - ${perfilProductor!.nombreFinca}'
            : nombre;
      case 'comprador':
      case 'transportista':
        String empresa = tipo == 'comprador'
            ? perfilComprador?.nombreEmpresa ?? ''
            : perfilTransportista?.nombreEmpresa ?? '';
        return empresa.isNotEmpty ? '$nombre - $empresa' : nombre;
      default:
        return nombre;
    }
  }
}
