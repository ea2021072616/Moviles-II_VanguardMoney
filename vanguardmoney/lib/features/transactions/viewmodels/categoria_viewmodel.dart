import 'package:flutter/material.dart';
import '../models/categoria_model.dart';
import '../services/categoria_service.dart';

class CategoriaViewModel extends ChangeNotifier {
  final CategoriaService _categoriaService = CategoriaService();

  List<CategoriaModel> _categorias = [];
  List<CategoriaModel> _categoriasPersonalizadas = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<CategoriaModel> get categorias => _categorias;
  List<CategoriaModel> get categoriasPersonalizadas =>
      _categoriasPersonalizadas;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Controladores para los formularios
  final TextEditingController nombreCategoriaController =
      TextEditingController();
  final TextEditingController editarCategoriaController =
      TextEditingController();

  // Cargar categorías (base + personalizadas)
  Future<void> cargarCategorias(String idUsuario, TipoCategoria tipo) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _categorias = await _categoriaService.obtenerCategorias(idUsuario, tipo);
    } catch (e) {
      _errorMessage = 'Error al cargar categorías: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar solo categorías personalizadas
  Future<void> cargarCategoriasPersonalizadas(
    String idUsuario,
    TipoCategoria tipo,
  ) async {
    try {
      _categoriasPersonalizadas = await _categoriaService
          .obtenerCategoriasPersonalizadas(idUsuario, tipo);
      notifyListeners();
    } catch (e) {
      _errorMessage =
          'Error al cargar categorías personalizadas: ${e.toString()}';
      notifyListeners();
    }
  }

  // Agregar nueva categoría personalizada
  Future<bool> agregarCategoriaPersonalizada(
    String idUsuario,
    TipoCategoria tipo,
  ) async {
    if (nombreCategoriaController.text.trim().isEmpty) {
      _errorMessage = 'El nombre de la categoría no puede estar vacío';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final resultado = await _categoriaService.agregarCategoriaPersonalizada(
        idUsuario,
        nombreCategoriaController.text.trim(),
        tipo,
      );

      if (resultado) {
        // Recargar categorías para incluir la nueva
        await cargarCategorias(idUsuario, tipo);
        await cargarCategoriasPersonalizadas(idUsuario, tipo);
        nombreCategoriaController.clear();
        _errorMessage = '';
      } else {
        _errorMessage = 'Ya existe una categoría con ese nombre';
      }

      return resultado;
    } catch (e) {
      _errorMessage = 'Error al agregar categoría: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Editar categoría personalizada
  Future<bool> editarCategoriaPersonalizada(
    String idCategoria,
    String idUsuario,
    TipoCategoria tipo,
  ) async {
    if (editarCategoriaController.text.trim().isEmpty) {
      _errorMessage = 'El nombre de la categoría no puede estar vacío';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final resultado = await _categoriaService.editarCategoriaPersonalizada(
        idCategoria,
        editarCategoriaController.text.trim(),
        idUsuario,
      );

      if (resultado) {
        // Recargar categorías para reflejar los cambios
        await cargarCategorias(idUsuario, tipo);
        await cargarCategoriasPersonalizadas(idUsuario, tipo);
        editarCategoriaController.clear();
        _errorMessage = '';
      } else {
        _errorMessage = 'Error al editar la categoría';
      }

      return resultado;
    } catch (e) {
      _errorMessage = 'Error al editar categoría: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar categoría personalizada
  Future<bool> eliminarCategoriaPersonalizada(
    String idCategoria,
    String idUsuario,
    TipoCategoria tipo,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final resultado = await _categoriaService.eliminarCategoriaPersonalizada(
        idCategoria,
        idUsuario,
      );

      if (resultado) {
        // Recargar categorías para reflejar los cambios
        await cargarCategorias(idUsuario, tipo);
        await cargarCategoriasPersonalizadas(idUsuario, tipo);
        _errorMessage = '';
      } else {
        _errorMessage = 'Error al eliminar la categoría';
      }

      return resultado;
    } catch (e) {
      _errorMessage = 'Error al eliminar categoría: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar formularios
  void limpiarFormularios() {
    nombreCategoriaController.clear();
    editarCategoriaController.clear();
    _errorMessage = '';
    notifyListeners();
  }

  // Limpiar mensaje de error
  void limpiarError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Obtener categorías por tipo
  List<CategoriaModel> obtenerCategoriasPorTipo(TipoCategoria tipo) {
    return _categorias.where((categoria) => categoria.tipo == tipo).toList();
  }

  // Obtener nombres de categorías para dropdown
  List<String> obtenerNombresCategorias(TipoCategoria tipo) {
    return obtenerCategoriasPorTipo(
      tipo,
    ).map((categoria) => categoria.nombre).toList();
  }

  // Verificar si una categoría es personalizada
  bool esCategoriaPersonalizada(String nombreCategoria, TipoCategoria tipo) {
    final categoria = _categorias.firstWhere(
      (cat) => cat.nombre == nombreCategoria && cat.tipo == tipo,
      orElse: () => CategoriaModel(
        id: '',
        nombre: '',
        tipo: tipo,
        esPersonalizada: false,
      ),
    );

    return categoria.esPersonalizada;
  }

  // Obtener categoría por nombre
  CategoriaModel? obtenerCategoriaPorNombre(String nombre, TipoCategoria tipo) {
    try {
      return _categorias.firstWhere(
        (categoria) => categoria.nombre == nombre && categoria.tipo == tipo,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    nombreCategoriaController.dispose();
    editarCategoriaController.dispose();
    super.dispose();
  }
}
