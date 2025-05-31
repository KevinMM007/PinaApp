class PerfilProductor {
  final String nombreFinca;
  final double hectareas;
  final List<String> variedadesCultivadas;
  final double capacidadProductivaMensual; // en toneladas
  final List<String> certificaciones;
  final String tipoSuelo;
  final String metodoCultivo; // orgánico, tradicional, mixto
  final Map<String, dynamic> ubicacionFinca; // lat, lng, direccion
  final int anosExperiencia;
  final String equipoDisponible;
  final String temporadaCosecha;

  PerfilProductor({
    this.nombreFinca = '',
    this.hectareas = 0.0,
    this.variedadesCultivadas = const [],
    this.capacidadProductivaMensual = 0.0,
    this.certificaciones = const [],
    this.tipoSuelo = '',
    this.metodoCultivo = 'tradicional',
    this.ubicacionFinca = const {},
    this.anosExperiencia = 0,
    this.equipoDisponible = '',
    this.temporadaCosecha = '',
  });

  factory PerfilProductor.fromMap(Map<String, dynamic> map) {
    return PerfilProductor(
      nombreFinca: map['nombreFinca'] ?? '',
      hectareas: map['hectareas']?.toDouble() ?? 0.0,
      variedadesCultivadas: List<String>.from(map['variedadesCultivadas'] ?? []),
      capacidadProductivaMensual: map['capacidadProductivaMensual']?.toDouble() ?? 0.0,
      certificaciones: List<String>.from(map['certificaciones'] ?? []),
      tipoSuelo: map['tipoSuelo'] ?? '',
      metodoCultivo: map['metodoCultivo'] ?? 'tradicional',
      ubicacionFinca: Map<String, dynamic>.from(map['ubicacionFinca'] ?? {}),
      anosExperiencia: map['anosExperiencia']?.toInt() ?? 0,
      equipoDisponible: map['equipoDisponible'] ?? '',
      temporadaCosecha: map['temporadaCosecha'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreFinca': nombreFinca,
      'hectareas': hectareas,
      'variedadesCultivadas': variedadesCultivadas,
      'capacidadProductivaMensual': capacidadProductivaMensual,
      'certificaciones': certificaciones,
      'tipoSuelo': tipoSuelo,
      'metodoCultivo': metodoCultivo,
      'ubicacionFinca': ubicacionFinca,
      'anosExperiencia': anosExperiencia,
      'equipoDisponible': equipoDisponible,
      'temporadaCosecha': temporadaCosecha,
    };
  }

  PerfilProductor copyWith({
    String? nombreFinca,
    double? hectareas,
    List<String>? variedadesCultivadas,
    double? capacidadProductivaMensual,
    List<String>? certificaciones,
    String? tipoSuelo,
    String? metodoCultivo,
    Map<String, dynamic>? ubicacionFinca,
    int? anosExperiencia,
    String? equipoDisponible,
    String? temporadaCosecha,
  }) {
    return PerfilProductor(
      nombreFinca: nombreFinca ?? this.nombreFinca,
      hectareas: hectareas ?? this.hectareas,
      variedadesCultivadas: variedadesCultivadas ?? this.variedadesCultivadas,
      capacidadProductivaMensual: capacidadProductivaMensual ?? this.capacidadProductivaMensual,
      certificaciones: certificaciones ?? this.certificaciones,
      tipoSuelo: tipoSuelo ?? this.tipoSuelo,
      metodoCultivo: metodoCultivo ?? this.metodoCultivo,
      ubicacionFinca: ubicacionFinca ?? this.ubicacionFinca,
      anosExperiencia: anosExperiencia ?? this.anosExperiencia,
      equipoDisponible: equipoDisponible ?? this.equipoDisponible,
      temporadaCosecha: temporadaCosecha ?? this.temporadaCosecha,
    );
  }
}
