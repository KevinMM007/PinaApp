class Producto {
  final String? id;
  final String idVendedor;
  final String titulo;
  final String variedad;
  final String descripcion;
  final double precio;
  final String unidadPrecio;
  final double cantidadDisponible;
  final String calidad;
  final List<String> fotos;
  final String ubicacion;
  final DateTime fechaPublicacion;

  Producto({
    this.id,
    required this.idVendedor,
    required this.titulo,
    required this.variedad,
    required this.descripcion,
    required this.precio,
    required this.unidadPrecio,
    required this.cantidadDisponible,
    required this.calidad,
    required this.fotos,
    required this.ubicacion,
    required this.fechaPublicacion,
  });

  factory Producto.fromMap(Map<String, dynamic> map, String id) {
    return Producto(
      id: id,
      idVendedor: map['idVendedor'] ?? '',
      titulo: map['titulo'] ?? '',
      variedad: map['variedad'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: map['precio']?.toDouble() ?? 0.0,
      unidadPrecio: map['unidadPrecio'] ?? 'kg',
      cantidadDisponible: map['cantidadDisponible']?.toDouble() ?? 0.0,
      calidad: map['calidad'] ?? '',
      fotos: List<String>.from(map['fotos'] ?? []),
      ubicacion: map['ubicacion'] ?? '',
      fechaPublicacion: (map['fechaPublicacion'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idVendedor': idVendedor,
      'titulo': titulo,
      'variedad': variedad,
      'descripcion': descripcion,
      'precio': precio,
      'unidadPrecio': unidadPrecio,
      'cantidadDisponible': cantidadDisponible,
      'calidad': calidad,
      'fotos': fotos,
      'ubicacion': ubicacion,
      'fechaPublicacion': fechaPublicacion,
    };
  }
}