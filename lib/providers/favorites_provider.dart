import 'package:flutter/material.dart';
import 'package:pina_app/models/favorito.dart';
import 'package:pina_app/models/producto.dart';
import 'package:pina_app/services/database_service.dart';

class FavoritesProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Favorito> _favoritos = [];
  List<Producto> _productosFavoritos = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<Favorito> get favoritos => _favoritos;
  List<Producto> get productosFavoritos => _productosFavoritos;
  bool get isLoading => _isLoading;
  String get error => _error;

  /// Verificar si un producto está en favoritos
  bool isFavorite(String productoId) {
    return _favoritos.any((favorito) => favorito.productoId == productoId);
  }

  /// Cargar favoritos del usuario
  Future<void> cargarFavoritos(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _favoritos = await _databaseService.getFavoritos(userId);
      await _cargarProductosFavoritos();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar favoritos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar productos de los favoritos
  Future<void> _cargarProductosFavoritos() async {
    _productosFavoritos = [];
    for (final favorito in _favoritos) {
      try {
        final producto =
            await _databaseService.getProducto(favorito.productoId);
        if (producto != null) {
          _productosFavoritos.add(producto);
        }
      } catch (e) {
        // Si un producto no existe, remover de favoritos
        await removerFavorito(favorito.productoId);
      }
    }
  }

  /// Añadir producto a favoritos
  Future<bool> agregarFavorito(String userId, String productoId) async {
    if (isFavorite(productoId)) {
      return true; // Ya está en favoritos
    }

    try {
      final favorito = Favorito(
        userId: userId,
        productoId: productoId,
        fechaAgregado: DateTime.now(),
      );

      final favoritoId = await _databaseService.addFavorito(favorito);

      // Actualizar el favorito local con el ID correcto
      final favoritoConId = Favorito(
        id: favoritoId,
        userId: userId,
        productoId: productoId,
        fechaAgregado: favorito.fechaAgregado,
      );

      _favoritos.add(favoritoConId);

      // Cargar el producto y añadirlo a la lista
      final producto = await _databaseService.getProducto(productoId);
      if (producto != null) {
        _productosFavoritos.add(producto);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar favorito: $e';
      print('Error agregando favorito: $e'); // Debug
      notifyListeners();
      return false;
    }
  }

  /// Remover producto de favoritos
  Future<bool> removerFavorito(String productoId) async {
    try {
      print(
          '🔍 Buscando favorito para remover - ProductoId: $productoId'); // Debug
      print(
          '📄 Favoritos actuales: ${_favoritos.map((f) => f.productoId).toList()}'); // Debug

      // Buscar el favorito que coincida con el productoId
      final favoritoIndex =
          _favoritos.indexWhere((f) => f.productoId == productoId);

      if (favoritoIndex == -1) {
        print('⚠️ Favorito no encontrado en la lista local'); // Debug
        return false;
      }

      final favorito = _favoritos[favoritoIndex];
      print('📝 Favorito encontrado - ID: ${favorito.id}'); // Debug

      // Eliminar de la base de datos si tiene ID
      if (favorito.id != null && favorito.id!.isNotEmpty) {
        await _databaseService.deleteFavorito(favorito.id!);
        print('🗑️ Favorito eliminado de la base de datos'); // Debug
      }

      // Remover de las listas locales
      _favoritos.removeWhere((f) => f.productoId == productoId);
      _productosFavoritos.removeWhere((p) => p.id == productoId);

      print('📋 Favoritos restantes: ${_favoritos.length}'); // Debug
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al remover favorito: $e';
      print('❌ Error removiendo favorito: $e'); // Debug
      notifyListeners();
      return false;
    }
  }

  /// Toggle favorito (agregar si no existe, remover si existe)
  Future<bool> toggleFavorito(String userId, String productoId) async {
    print(
        '🔄 Toggle favorito - ProductoId: $productoId, isCurrentlyFavorite: ${isFavorite(productoId)}'); // Debug

    if (isFavorite(productoId)) {
      print('▶️ Removiendo favorito...'); // Debug
      final result = await removerFavorito(productoId);
      print(
          '✅ Resultado remover: $result, isNowFavorite: ${isFavorite(productoId)}'); // Debug
      return result;
    } else {
      print('▶️ Agregando favorito...'); // Debug
      final result = await agregarFavorito(userId, productoId);
      print(
          '✅ Resultado agregar: $result, isNowFavorite: ${isFavorite(productoId)}'); // Debug
      return result;
    }
  }

  /// Limpiar favoritos
  void limpiarFavoritos() {
    _favoritos.clear();
    _productosFavoritos.clear();
    _error = '';
    notifyListeners();
  }
}
