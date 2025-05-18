class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String tipo;  // "productor", "comprador", "transportista"
  final String fotoPerfil;
  final String ubicacion;
  final double calificacionPromedio;
  final int numeroTransacciones;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.tipo,
    this.fotoPerfil = '',
    this.ubicacion = '',
    this.calificacionPromedio = 0.0,
    this.numeroTransacciones = 0,
  });

  factory Usuario.fromMap(Map<String, dynamic> map, String id) {
    return Usuario(
      id: id,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      tipo: map['tipo'] ?? '',
      fotoPerfil: map['fotoPerfil'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
      calificacionPromedio: map['calificacionPromedio']?.toDouble() ?? 0.0,
      numeroTransacciones: map['numeroTransacciones']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'tipo': tipo,
      'fotoPerfil': fotoPerfil,
      'ubicacion': ubicacion,
      'calificacionPromedio': calificacionPromedio,
      'numeroTransacciones': numeroTransacciones,
    };
  }
}