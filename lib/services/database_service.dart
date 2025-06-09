import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pina_app/models/producto.dart';
import 'package:pina_app/models/favorito.dart';
import 'package:pina_app/models/necesidad_compra.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colecciones de datos
  final CollectionReference _productosCollection = 
      FirebaseFirestore.instance.collection('productos');
  final CollectionReference _favoritosCollection = 
      FirebaseFirestore.instance.collection('favoritos');
  final CollectionReference _necesidadesCollection = 
      FirebaseFirestore.instance.collection('necesidades');

  // Obtener stream de productos
  Stream<List<Producto>> get productos {
    return _productosCollection
        .orderBy('fechaPublicacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Producto.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Obtener productos por vendedor
  Stream<List<Producto>> getProductosPorVendedor(String idVendedor) {
    return _productosCollection
        .where('idVendedor', isEqualTo: idVendedor)
        .orderBy('fechaPublicacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Producto.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Obtener un producto específico
  Future<Producto?> getProducto(String id) async {
    DocumentSnapshot doc = await _productosCollection.doc(id).get();
    if (doc.exists) {
      return Producto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Añadir producto
  Future<String> addProducto(Producto producto) async {
    DocumentReference docRef = await _productosCollection.add(producto.toMap());
    return docRef.id;
  }

  // Actualizar producto
  Future<void> updateProducto(Producto producto) async {
    await _productosCollection.doc(producto.id).update(producto.toMap());
  }

  // Eliminar producto
  Future<void> deleteProducto(String id) async {
    await _productosCollection.doc(id).delete();
  }

  // ===== MÉTODOS PARA FAVORITOS =====

  /// Obtener favoritos de un usuario
  Future<List<Favorito>> getFavoritos(String userId) async {
    QuerySnapshot snapshot = await _favoritosCollection
        .where('userId', isEqualTo: userId)
        .orderBy('fechaAgregado', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => Favorito.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Añadir favorito
  Future<String> addFavorito(Favorito favorito) async {
    // Verificar si ya existe el favorito
    QuerySnapshot existing = await _favoritosCollection
        .where('userId', isEqualTo: favorito.userId)
        .where('productoId', isEqualTo: favorito.productoId)
        .get();
    
    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id; // Ya existe
    }
    
    DocumentReference docRef = await _favoritosCollection.add(favorito.toMap());
    return docRef.id;
  }

  /// Eliminar favorito
  Future<void> deleteFavorito(String id) async {
    try {
      await _favoritosCollection.doc(id).delete();
      print('Favorito eliminado correctamente: $id'); // Debug
    } catch (e) {
      print('Error eliminando favorito $id: $e'); // Debug
      rethrow;
    }
  }

  /// Verificar si un producto es favorito de un usuario
  Future<bool> esFavorito(String userId, String productoId) async {
    QuerySnapshot snapshot = await _favoritosCollection
        .where('userId', isEqualTo: userId)
        .where('productoId', isEqualTo: productoId)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }

  /// Obtener productos favoritos de un usuario
  Future<List<Producto>> getProductosFavoritos(String userId) async {
    final favoritos = await getFavoritos(userId);
    List<Producto> productos = [];
    
    for (final favorito in favoritos) {
      final producto = await getProducto(favorito.productoId);
      if (producto != null) {
        productos.add(producto);
      }
    }
    
    return productos;
  }

  // ===== MÉTODOS PARA NECESIDADES DE COMPRA =====

  /// Obtener stream de necesidades
  Stream<List<NecesidadCompra>> get necesidades {
    return _necesidadesCollection
        .where('activa', isEqualTo: true)
        .orderBy('fechaPublicacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NecesidadCompra.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Obtener necesidades por comprador
  Stream<List<NecesidadCompra>> getNecesidadesPorComprador(String idComprador) {
    return _necesidadesCollection
        .where('idComprador', isEqualTo: idComprador)
        .orderBy('fechaPublicacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NecesidadCompra.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Obtener una necesidad específica
  Future<NecesidadCompra?> getNecesidad(String id) async {
    DocumentSnapshot doc = await _necesidadesCollection.doc(id).get();
    if (doc.exists) {
      return NecesidadCompra.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  /// Añadir necesidad
  Future<String> addNecesidad(NecesidadCompra necesidad) async {
    DocumentReference docRef = await _necesidadesCollection.add(necesidad.toMap());
    return docRef.id;
  }

  /// Actualizar necesidad
  Future<void> updateNecesidad(NecesidadCompra necesidad) async {
    await _necesidadesCollection.doc(necesidad.id).update(necesidad.toMap());
  }

  /// Eliminar necesidad
  Future<void> deleteNecesidad(String id) async {
    await _necesidadesCollection.doc(id).delete();
  }

  /// Buscar necesidades por variedad y rango de precio
  Future<List<NecesidadCompra>> buscarNecesidadesPorCriterios({
    String? variedad,
    double? precioMin,
    double? precioMax,
  }) async {
    Query query = _necesidadesCollection.where('activa', isEqualTo: true);
    
    if (variedad != null && variedad.isNotEmpty && variedad != 'Todas') {
      query = query.where('variedad', isEqualTo: variedad);
    }
    
    QuerySnapshot snapshot = await query.get();
    List<NecesidadCompra> necesidades = snapshot.docs
        .map((doc) => NecesidadCompra.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    
    // Filtrar por rango de precio si se especifica
    if (precioMin != null && precioMax != null) {
      necesidades = necesidades.where((necesidad) => 
          precioMin <= necesidad.presupuestoMax && 
          precioMax >= necesidad.presupuestoMin
      ).toList();
    }
    
    return necesidades;
  }
}