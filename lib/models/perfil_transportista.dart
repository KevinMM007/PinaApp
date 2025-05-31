class PerfilTransportista {
  final String nombreEmpresa;
  final List<Map<String, dynamic>> vehiculos; // tipo, capacidad, modelo, placas
  final double capacidadTotalToneladas;
  final List<String> rutasHabituales;
  final List<String> tiposCarga; // refrigerada, seca, mixta
  final bool tieneSeguro;
  final Map<String, dynamic> seguros; // cobertura, vigencia
  final List<String> certificaciones; // transporte, calidad, etc
  final String tipoServicio; // local, nacional, internacional
  final Map<String, double> tarifas; // por km, por tonelada
  final List<String> diasDisponibles;
  final String horarioServicio;
  final bool servicioUrgente;
  final double calificacionPromedio;
  final int viajesRealizados;
  final List<String> equipoEspecial; // montacargas, refrigeración, etc

  PerfilTransportista({
    this.nombreEmpresa = '',
    this.vehiculos = const [],
    this.capacidadTotalToneladas = 0.0,
    this.rutasHabituales = const [],
    this.tiposCarga = const [],
    this.tieneSeguro = false,
    this.seguros = const {},
    this.certificaciones = const [],
    this.tipoServicio = 'local',
    this.tarifas = const {},
    this.diasDisponibles = const [],
    this.horarioServicio = '',
    this.servicioUrgente = false,
    this.calificacionPromedio = 0.0,
    this.viajesRealizados = 0,
    this.equipoEspecial = const [],
  });

  factory PerfilTransportista.fromMap(Map<String, dynamic> map) {
    return PerfilTransportista(
      nombreEmpresa: map['nombreEmpresa'] ?? '',
      vehiculos: List<Map<String, dynamic>>.from(map['vehiculos'] ?? []),
      capacidadTotalToneladas: map['capacidadTotalToneladas']?.toDouble() ?? 0.0,
      rutasHabituales: List<String>.from(map['rutasHabituales'] ?? []),
      tiposCarga: List<String>.from(map['tiposCarga'] ?? []),
      tieneSeguro: map['tieneSeguro'] ?? false,
      seguros: Map<String, dynamic>.from(map['seguros'] ?? {}),
      certificaciones: List<String>.from(map['certificaciones'] ?? []),
      tipoServicio: map['tipoServicio'] ?? 'local',
      tarifas: Map<String, double>.from(
        map['tarifas']?.map((k, v) => MapEntry(k, v?.toDouble() ?? 0.0)) ?? {}
      ),
      diasDisponibles: List<String>.from(map['diasDisponibles'] ?? []),
      horarioServicio: map['horarioServicio'] ?? '',
      servicioUrgente: map['servicioUrgente'] ?? false,
      calificacionPromedio: map['calificacionPromedio']?.toDouble() ?? 0.0,
      viajesRealizados: map['viajesRealizados']?.toInt() ?? 0,
      equipoEspecial: List<String>.from(map['equipoEspecial'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreEmpresa': nombreEmpresa,
      'vehiculos': vehiculos,
      'capacidadTotalToneladas': capacidadTotalToneladas,
      'rutasHabituales': rutasHabituales,
      'tiposCarga': tiposCarga,
      'tieneSeguro': tieneSeguro,
      'seguros': seguros,
      'certificaciones': certificaciones,
      'tipoServicio': tipoServicio,
      'tarifas': tarifas,
      'diasDisponibles': diasDisponibles,
      'horarioServicio': horarioServicio,
      'servicioUrgente': servicioUrgente,
      'calificacionPromedio': calificacionPromedio,
      'viajesRealizados': viajesRealizados,
      'equipoEspecial': equipoEspecial,
    };
  }

  PerfilTransportista copyWith({
    String? nombreEmpresa,
    List<Map<String, dynamic>>? vehiculos,
    double? capacidadTotalToneladas,
    List<String>? rutasHabituales,
    List<String>? tiposCarga,
    bool? tieneSeguro,
    Map<String, dynamic>? seguros,
    List<String>? certificaciones,
    String? tipoServicio,
    Map<String, double>? tarifas,
    List<String>? diasDisponibles,
    String? horarioServicio,
    bool? servicioUrgente,
    double? calificacionPromedio,
    int? viajesRealizados,
    List<String>? equipoEspecial,
  }) {
    return PerfilTransportista(
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      vehiculos: vehiculos ?? this.vehiculos,
      capacidadTotalToneladas: capacidadTotalToneladas ?? this.capacidadTotalToneladas,
      rutasHabituales: rutasHabituales ?? this.rutasHabituales,
      tiposCarga: tiposCarga ?? this.tiposCarga,
      tieneSeguro: tieneSeguro ?? this.tieneSeguro,
      seguros: seguros ?? this.seguros,
      certificaciones: certificaciones ?? this.certificaciones,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      tarifas: tarifas ?? this.tarifas,
      diasDisponibles: diasDisponibles ?? this.diasDisponibles,
      horarioServicio: horarioServicio ?? this.horarioServicio,
      servicioUrgente: servicioUrgente ?? this.servicioUrgente,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      viajesRealizados: viajesRealizados ?? this.viajesRealizados,
      equipoEspecial: equipoEspecial ?? this.equipoEspecial,
    );
  }
}
