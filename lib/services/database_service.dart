import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pina_app/models/producto.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colección de productos
  final CollectionReference _productosCollection = 
      FirebaseFirestore.instance.collection('productos');

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
}