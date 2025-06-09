class Favorito {
  final String? id;
  final String userId;
  final String productoId;
  final DateTime fechaAgregado;

  Favorito({
    this.id,
    required this.userId,
    required this.productoId,
    required this.fechaAgregado,
  });

  factory Favorito.fromMap(Map<String, dynamic> map, String id) {
    return Favorito(
      id: id,
      userId: map['userId'] ?? '',
      productoId: map['productoId'] ?? '',
      fechaAgregado: (map['fechaAgregado'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productoId': productoId,
      'fechaAgregado': fechaAgregado,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Favorito &&
        other.userId == userId &&
        other.productoId == productoId;
  }

  @override
  int get hashCode => userId.hashCode ^ productoId.hashCode;
}
