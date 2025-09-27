import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/categoria_model.dart';

class CategoriaService {
  static const String _collection = 'categorias';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todas las categorías (base + personalizadas del usuario)
  Future<List<CategoriaModel>> obtenerCategorias(
    String idUsuario,
    TipoCategoria tipo,
  ) async {
    List<CategoriaModel> categorias = [];

    // Agregar categorías base
    if (tipo == TipoCategoria.ingreso) {
      categorias.addAll(CategoriaModel.categoriasBaseIngresos);
    } else {
      categorias.addAll(CategoriaModel.categoriasBaseEgresos);
    }

    // Obtener categorías personalizadas del usuario
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('idUsuario', isEqualTo: idUsuario)
          .where('tipo', isEqualTo: tipo.toString().split('.').last)
          .where('esPersonalizada', isEqualTo: true)
          .orderBy('fechaCreacion', descending: false)
          .get();

      final categoriasPersonalizadas = querySnapshot.docs
          .map((doc) => CategoriaModel.fromDocument(doc))
          .toList();

      categorias.addAll(categoriasPersonalizadas);
    } catch (e) {
      print('Error al obtener categorías personalizadas: $e');
    }

    return categorias;
  }

  // Agregar nueva categoría personalizada
  Future<bool> agregarCategoriaPersonalizada(
    String idUsuario,
    String nombre,
    TipoCategoria tipo,
  ) async {
    try {
      // Verificar que no exista una categoría con el mismo nombre
      final existe = await _verificarCategoriaExiste(idUsuario, nombre, tipo);
      if (existe) {
        return false;
      }

      final categoria = CategoriaModel(
        id: _firestore.collection(_collection).doc().id,
        nombre: nombre,
        tipo: tipo,
        esPersonalizada: true,
        idUsuario: idUsuario,
        fechaCreacion: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(categoria.id)
          .set(categoria.toMap());

      return true;
    } catch (e) {
      print('Error al agregar categoría: $e');
      return false;
    }
  }

  // Editar categoría personalizada
  Future<bool> editarCategoriaPersonalizada(
    String idCategoria,
    String nuevoNombre,
    String idUsuario,
  ) async {
    try {
      await _firestore.collection(_collection).doc(idCategoria).update({
        'nombre': nuevoNombre,
      });
      return true;
    } catch (e) {
      print('Error al editar categoría: $e');
      return false;
    }
  }

  // Eliminar categoría personalizada
  Future<bool> eliminarCategoriaPersonalizada(
    String idCategoria,
    String idUsuario,
  ) async {
    try {
      // Verificar que la categoría pertenece al usuario y es personalizada
      final doc = await _firestore
          .collection(_collection)
          .doc(idCategoria)
          .get();

      if (!doc.exists) return false;

      final categoria = CategoriaModel.fromDocument(doc);

      if (!categoria.esPersonalizada || categoria.idUsuario != idUsuario) {
        return false;
      }

      await _firestore.collection(_collection).doc(idCategoria).delete();
      return true;
    } catch (e) {
      print('Error al eliminar categoría: $e');
      return false;
    }
  }

  // Verificar si existe una categoría con el mismo nombre
  Future<bool> _verificarCategoriaExiste(
    String idUsuario,
    String nombre,
    TipoCategoria tipo,
  ) async {
    try {
      // Verificar en categorías base
      final categoriasBase = tipo == TipoCategoria.ingreso
          ? CategoriaModel.categoriasBaseIngresos
          : CategoriaModel.categoriasBaseEgresos;

      final existeEnBase = categoriasBase.any(
        (cat) => cat.nombre.toLowerCase() == nombre.toLowerCase(),
      );

      if (existeEnBase) return true;

      // Verificar en categorías personalizadas
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('idUsuario', isEqualTo: idUsuario)
          .where('tipo', isEqualTo: tipo.toString().split('.').last)
          .where('esPersonalizada', isEqualTo: true)
          .get();

      final existeEnPersonalizadas = querySnapshot.docs.any(
        (doc) =>
            doc.data()['nombre'].toString().toLowerCase() ==
            nombre.toLowerCase(),
      );

      return existeEnPersonalizadas;
    } catch (e) {
      print('Error al verificar categoría existente: $e');
      return true; // En caso de error, asumimos que existe para evitar duplicados
    }
  }

  // Obtener solo categorías personalizadas del usuario
  Future<List<CategoriaModel>> obtenerCategoriasPersonalizadas(
    String idUsuario,
    TipoCategoria tipo,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('idUsuario', isEqualTo: idUsuario)
          .where('tipo', isEqualTo: tipo.toString().split('.').last)
          .where('esPersonalizada', isEqualTo: true)
          .orderBy('fechaCreacion', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => CategoriaModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error al obtener categorías personalizadas: $e');
      return [];
    }
  }

  // Stream para escuchar cambios en categorías personalizadas
  Stream<List<CategoriaModel>> streamCategoriasPersonalizadas(
    String idUsuario,
    TipoCategoria tipo,
  ) {
    return _firestore
        .collection(_collection)
        .where('idUsuario', isEqualTo: idUsuario)
        .where('tipo', isEqualTo: tipo.toString().split('.').last)
        .where('esPersonalizada', isEqualTo: true)
        .orderBy('fechaCreacion', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoriaModel.fromDocument(doc))
              .toList(),
        );
  }
}
