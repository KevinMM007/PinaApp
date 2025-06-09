import 'package:flutter/material.dart';
import 'package:pina_app/models/necesidad_compra.dart';
import 'package:pina_app/services/database_service.dart';

class NecesidadesProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<NecesidadCompra> _necesidades = [];
  NecesidadCompra? _necesidadSeleccionada;
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<NecesidadCompra> get necesidades => _necesidades;
  List<NecesidadCompra> get necesidadesActivas => 
      _necesidades.where((n) => n.activa && !n.isExpired).toList();
  List<NecesidadCompra> get necesidadesVencidas => 
      _necesidades.where((n) => n.isExpired).toList();
  NecesidadCompra? get necesidadSeleccionada => _necesidadSeleccionada;
  bool get isLoading => _isLoading;
  String get error => _error;

  /// Cargar todas las necesidades
  void cargarNecesidades() {
    _isLoading = true;
    notifyListeners();
    
    _databaseService.necesidades.listen((necesidadesList) {
      _necesidades = necesidadesList;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = 'Error al cargar necesidades: $e';
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Cargar necesidades de un comprador específico
  void cargarNecesidadesPorComprador(String idComprador) {
    _isLoading = true;
    notifyListeners();
    
    _databaseService.getNecesidadesPorComprador(idComprador).listen((necesidadesList) {
      _necesidades = necesidadesList;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = 'Error al cargar necesidades: $e';
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Seleccionar una necesidad para mostrar detalles
  Future<void> seleccionarNecesidad(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      _necesidadSeleccionada = await _databaseService.getNecesidad(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al obtener la necesidad: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Agregar una nueva necesidad
  Future<bool> agregarNecesidad(NecesidadCompra necesidad) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      await _databaseService.addNecesidad(necesidad);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar necesidad: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Actualizar una necesidad existente
  Future<bool> actualizarNecesidad(NecesidadCompra necesidad) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      await _databaseService.updateNecesidad(necesidad);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar necesidad: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Desactivar una necesidad (marcar como no activa)
  Future<bool> desactivarNecesidad(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      final necesidad = _necesidades.firstWhere((n) => n.id == id);
      final necesidadActualizada = NecesidadCompra(
        id: necesidad.id,
        idComprador: necesidad.idComprador,
        titulo: necesidad.titulo,
        variedad: necesidad.variedad,
        descripcion: necesidad.descripcion,
        presupuestoMin: necesidad.presupuestoMin,
        presupuestoMax: necesidad.presupuestoMax,
        cantidadRequerida: necesidad.cantidadRequerida,
        unidad: necesidad.unidad,
        calidad: necesidad.calidad,
        ubicacionPreferida: necesidad.ubicacionPreferida,
        latitudPreferida: necesidad.latitudPreferida,
        longitudPreferida: necesidad.longitudPreferida,
        fechaLimite: necesidad.fechaLimite,
        fechaPublicacion: necesidad.fechaPublicacion,
        activa: false,
      );
      
      await _databaseService.updateNecesidad(necesidadActualizada);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al desactivar necesidad: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Eliminar una necesidad
  Future<bool> eliminarNecesidad(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      await _databaseService.deleteNecesidad(id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar necesidad: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Buscar necesidades que coincidan con un producto
  List<NecesidadCompra> buscarNecesidadesParaProducto({
    required String variedad,
    required double precio,
    required String calidad,
  }) {
    return necesidadesActivas.where((necesidad) {
      final variedadCoincide = necesidad.variedad.toLowerCase() == variedad.toLowerCase();
      final precioEnRango = precio >= necesidad.presupuestoMin && precio <= necesidad.presupuestoMax;
      final calidadCoincide = necesidad.calidad.toLowerCase() == calidad.toLowerCase() || 
                              necesidad.calidad.toLowerCase() == 'cualquiera';
      
      return variedadCoincide && precioEnRango && calidadCoincide;
    }).toList();
  }

  /// Limpiar datos
  void limpiar() {
    _necesidades.clear();
    _necesidadSeleccionada = null;
    _error = '';
    notifyListeners();
  }
}
