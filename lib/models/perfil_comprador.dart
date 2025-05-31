class PerfilComprador {
  final String tipoComprador; // minorista, mayorista, exportador, procesador
  final String nombreEmpresa;
  final double volumenCompraMensual; // en toneladas
  final List<String> variedadesInteres;
  final List<String> calidadesPreferidas;
  final Map<String, double> rangoPrecios; // min, max por kg
  final List<String> ubicacionesEntrega;
  final String metodoPago; // contado, credito, mixto
  final int diasCredito;
  final List<String> certificacionesRequeridas;
  final String frecuenciaCompra; // semanal, quincenal, mensual
  final bool requiereTransporte;
  final String contactoComercial;
  final String horarioAtencion;

  PerfilComprador({
    this.tipoComprador = 'minorista',
    this.nombreEmpresa = '',
    this.volumenCompraMensual = 0.0,
    this.variedadesInteres = const [],
    this.calidadesPreferidas = const [],
    this.rangoPrecios = const {},
    this.ubicacionesEntrega = const [],
    this.metodoPago = 'contado',
    this.diasCredito = 0,
    this.certificacionesRequeridas = const [],
    this.frecuenciaCompra = 'mensual',
    this.requiereTransporte = false,
    this.contactoComercial = '',
    this.horarioAtencion = '',
  });

  factory PerfilComprador.fromMap(Map<String, dynamic> map) {
    return PerfilComprador(
      tipoComprador: map['tipoComprador'] ?? 'minorista',
      nombreEmpresa: map['nombreEmpresa'] ?? '',
      volumenCompraMensual: map['volumenCompraMensual']?.toDouble() ?? 0.0,
      variedadesInteres: List<String>.from(map['variedadesInteres'] ?? []),
      calidadesPreferidas: List<String>.from(map['calidadesPreferidas'] ?? []),
      rangoPrecios: Map<String, double>.from(
        map['rangoPrecios']?.map((k, v) => MapEntry(k, v?.toDouble() ?? 0.0)) ?? {}
      ),
      ubicacionesEntrega: List<String>.from(map['ubicacionesEntrega'] ?? []),
      metodoPago: map['metodoPago'] ?? 'contado',
      diasCredito: map['diasCredito']?.toInt() ?? 0,
      certificacionesRequeridas: List<String>.from(map['certificacionesRequeridas'] ?? []),
      frecuenciaCompra: map['frecuenciaCompra'] ?? 'mensual',
      requiereTransporte: map['requiereTransporte'] ?? false,
      contactoComercial: map['contactoComercial'] ?? '',
      horarioAtencion: map['horarioAtencion'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipoComprador': tipoComprador,
      'nombreEmpresa': nombreEmpresa,
      'volumenCompraMensual': volumenCompraMensual,
      'variedadesInteres': variedadesInteres,
      'calidadesPreferidas': calidadesPreferidas,
      'rangoPrecios': rangoPrecios,
      'ubicacionesEntrega': ubicacionesEntrega,
      'metodoPago': metodoPago,
      'diasCredito': diasCredito,
      'certificacionesRequeridas': certificacionesRequeridas,
      'frecuenciaCompra': frecuenciaCompra,
      'requiereTransporte': requiereTransporte,
      'contactoComercial': contactoComercial,
      'horarioAtencion': horarioAtencion,
    };
  }

  PerfilComprador copyWith({
    String? tipoComprador,
    String? nombreEmpresa,
    double? volumenCompraMensual,
    List<String>? variedadesInteres,
    List<String>? calidadesPreferidas,
    Map<String, double>? rangoPrecios,
    List<String>? ubicacionesEntrega,
    String? metodoPago,
    int? diasCredito,
    List<String>? certificacionesRequeridas,
    String? frecuenciaCompra,
    bool? requiereTransporte,
    String? contactoComercial,
    String? horarioAtencion,
  }) {
    return PerfilComprador(
      tipoComprador: tipoComprador ?? this.tipoComprador,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      volumenCompraMensual: volumenCompraMensual ?? this.volumenCompraMensual,
      variedadesInteres: variedadesInteres ?? this.variedadesInteres,
      calidadesPreferidas: calidadesPreferidas ?? this.calidadesPreferidas,
      rangoPrecios: rangoPrecios ?? this.rangoPrecios,
      ubicacionesEntrega: ubicacionesEntrega ?? this.ubicacionesEntrega,
      metodoPago: metodoPago ?? this.metodoPago,
      diasCredito: diasCredito ?? this.diasCredito,
      certificacionesRequeridas: certificacionesRequeridas ?? this.certificacionesRequeridas,
      frecuenciaCompra: frecuenciaCompra ?? this.frecuenciaCompra,
      requiereTransporte: requiereTransporte ?? this.requiereTransporte,
      contactoComercial: contactoComercial ?? this.contactoComercial,
      horarioAtencion: horarioAtencion ?? this.horarioAtencion,
    );
  }
}
