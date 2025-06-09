import 'package:flutter/material.dart';
import 'package:pina_app/models/producto.dart';
import 'package:pina_app/services/database_service.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Producto> _productos = [];
  Producto? _productoSeleccionado;
  bool _isLoading = false;
  String _error = '';
  
  // Getters
  List<Producto> get productos => _productos;
  Producto? get productoSeleccionado => _productoSeleccionado;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Cargar todos los productos
  void cargarProductos() {
    _isLoading = true;
    notifyListeners();
    
    _databaseService.productos.listen((productosList) {
      _productos = productosList;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = 'Error al cargar productos: $e';
      _isLoading = false;
      notifyListeners();
    });
  }

  // Seleccionar un producto para mostrar detalles
  Future<void> seleccionarProducto(String id) async {
    _error = '';
    
    try {
      // Primero intentar obtener el producto de la lista cargada
      final productoCached = _productos.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Producto no encontrado en cache'),
      );
      
      // Si lo encontramos en cache, usarlo inmediatamente sin loading
      _productoSeleccionado = productoCached;
      notifyListeners();
      
      // Luego actualizar desde la base de datos en segundo plano
      _databaseService.getProducto(id).then((producto) {
        _productoSeleccionado = producto;
        notifyListeners();
      }).catchError((e) {
        print('Error actualizando producto: $e');
      });
    } catch (e) {
      // Si no está en cache, obtenerlo sin mostrar loading
      try {
        _productoSeleccionado = await _databaseService.getProducto(id);
        notifyListeners();
      } catch (e) {
        _error = 'Error al obtener el producto: $e';
        notifyListeners();
      }
    }
  }

  // Añadir un nuevo producto
  Future<bool> agregarProducto(Producto producto) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      await _databaseService.addProducto(producto);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Actualizar un producto existente
  Future<bool> actualizarProducto(Producto producto) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      await _databaseService.updateProducto(producto);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Eliminar un producto
  Future<bool> eliminarProducto(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      await _databaseService.deleteProducto(id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}