class NecesidadCompra {
  final String? id;
  final String idComprador;
  final String titulo;
  final String variedad;
  final String descripcion;
  final double presupuestoMin;
  final double presupuestoMax;
  final double cantidadRequerida;
  final String unidad;
  final String calidad;
  final String ubicacionPreferida;
  final double? latitudPreferida;
  final double? longitudPreferida;
  final DateTime fechaLimite;
  final DateTime fechaPublicacion;
  final bool activa;

  NecesidadCompra({
    this.id,
    required this.idComprador,
    required this.titulo,
    required this.variedad,
    required this.descripcion,
    required this.presupuestoMin,
    required this.presupuestoMax,
    required this.cantidadRequerida,
    required this.unidad,
    required this.calidad,
    required this.ubicacionPreferida,
    this.latitudPreferida,
    this.longitudPreferida,
    required this.fechaLimite,
    required this.fechaPublicacion,
    this.activa = true,
  });

  factory NecesidadCompra.fromMap(Map<String, dynamic> map, String id) {
    return NecesidadCompra(
      id: id,
      idComprador: map['idComprador'] ?? '',
      titulo: map['titulo'] ?? '',
      variedad: map['variedad'] ?? '',
      descripcion: map['descripcion'] ?? '',
      presupuestoMin: map['presupuestoMin']?.toDouble() ?? 0.0,
      presupuestoMax: map['presupuestoMax']?.toDouble() ?? 0.0,
      cantidadRequerida: map['cantidadRequerida']?.toDouble() ?? 0.0,
      unidad: map['unidad'] ?? 'kg',
      calidad: map['calidad'] ?? '',
      ubicacionPreferida: map['ubicacionPreferida'] ?? '',
      latitudPreferida: map['latitudPreferida']?.toDouble(),
      longitudPreferida: map['longitudPreferida']?.toDouble(),
      fechaLimite: (map['fechaLimite'] as dynamic)?.toDate() ?? DateTime.now(),
      fechaPublicacion: (map['fechaPublicacion'] as dynamic)?.toDate() ?? DateTime.now(),
      activa: map['activa'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idComprador': idComprador,
      'titulo': titulo,
      'variedad': variedad,
      'descripcion': descripcion,
      'presupuestoMin': presupuestoMin,
      'presupuestoMax': presupuestoMax,
      'cantidadRequerida': cantidadRequerida,
      'unidad': unidad,
      'calidad': calidad,
      'ubicacionPreferida': ubicacionPreferida,
      'latitudPreferida': latitudPreferida,
      'longitudPreferida': longitudPreferida,
      'fechaLimite': fechaLimite,
      'fechaPublicacion': fechaPublicacion,
      'activa': activa,
    };
  }

  /// Verificar si la necesidad está vencida
  bool get isExpired => DateTime.now().isAfter(fechaLimite);

  /// Días restantes hasta el vencimiento
  int get diasRestantes {
    if (isExpired) return 0;
    return fechaLimite.difference(DateTime.now()).inDays;
  }

  /// Rango de presupuesto formateado
  String get presupuestoFormateado {
    if (presupuestoMin == presupuestoMax) {
      return '\$${presupuestoMin.toStringAsFixed(0)}';
    }
    return '\$${presupuestoMin.toStringAsFixed(0)} - \$${presupuestoMax.toStringAsFixed(0)}';
  }
}
