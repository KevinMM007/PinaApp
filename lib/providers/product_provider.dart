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
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      _productoSeleccionado = await _databaseService.getProducto(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al obtener el producto: $e';
      _isLoading = false;
      notifyListeners();
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