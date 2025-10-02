import 'package:flutter/material.dart';

/// Servicio de validaciones para transacciones
class ValidacionesTransacciones {
  /// Valida que el monto sea válido
  static String? validarMonto(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El monto es requerido';
    }

    final monto = double.tryParse(valor);
    if (monto == null) {
      return 'Ingrese un número válido';
    }

    if (monto <= 0) {
      return 'El monto debe ser mayor a 0';
    }

    return null; // Válido
  }

  /// Valida que la categoría no esté vacía
  static String? validarCategoria(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La categoría es requerida';
    }

    if (valor.trim().isEmpty) {
      return 'La categoría no puede estar vacía';
    }

    return null; // Válido
  }

  /// Valida que el método de pago no esté vacío
  static String? validarMetodoPago(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El método de pago es requerido';
    }

    if (valor.trim().isEmpty) {
      return 'El método de pago no puede estar vacío';
    }

    return null; // Válido
  }

  /// Valida que el origen no esté vacío
  static String? validarOrigen(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El origen es requerido';
    }

    if (valor.trim().isEmpty) {
      return 'El origen no puede estar vacío';
    }

    return null; // Válido
  }

  /// Valida que el proveedor no esté vacío
  static String? validarProveedor(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El proveedor es requerido';
    }

    if (valor.trim().isEmpty) {
      return 'El proveedor no puede estar vacío';
    }

    return null; // Válido
  }

  /// Valida que el lugar no esté vacío
  static String? validarLugar(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El lugar es requerido';
    }

    if (valor.trim().isEmpty) {
      return 'El lugar no puede estar vacío';
    }

    return null; // Válido
  }

  /// Valida que la descripción no exceda el límite de caracteres
  static String? validarDescripcion(String? valor, {int maxLength = 500}) {
    if (valor == null || valor.isEmpty) {
      return null; // La descripción es opcional
    }

    if (valor.length > maxLength) {
      return 'La descripción no puede exceder $maxLength caracteres';
    }

    return null; // Válido
  }

  /// Valida todos los campos de un ingreso
  static String? validarFormularioIngreso({
    required String monto,
    required String categoria,
    required String metodoPago,
    required String origen,
    String? descripcion,
  }) {
    // Validar monto
    final errorMonto = validarMonto(monto);
    if (errorMonto != null) return errorMonto;

    // Validar categoría
    final errorCategoria = validarCategoria(categoria);
    if (errorCategoria != null) return errorCategoria;

    // Validar método de pago
    final errorMetodoPago = validarMetodoPago(metodoPago);
    if (errorMetodoPago != null) return errorMetodoPago;

    // Validar origen
    final errorOrigen = validarOrigen(origen);
    if (errorOrigen != null) return errorOrigen;

    // Validar descripción (opcional)
    if (descripcion != null) {
      final errorDescripcion = validarDescripcion(descripcion);
      if (errorDescripcion != null) return errorDescripcion;
    }

    return null; // Todo válido
  }

  /// Valida todos los campos de un gasto
  static String? validarFormularioGasto({
    required String monto,
    required String categoria,
    required String proveedor,
    required String lugar,
    String? descripcion,
  }) {
    // Validar monto
    final errorMonto = validarMonto(monto);
    if (errorMonto != null) return errorMonto;

    // Validar categoría
    final errorCategoria = validarCategoria(categoria);
    if (errorCategoria != null) return errorCategoria;

    // Validar proveedor
    final errorProveedor = validarProveedor(proveedor);
    if (errorProveedor != null) return errorProveedor;

    // Validar lugar
    final errorLugar = validarLugar(lugar);
    if (errorLugar != null) return errorLugar;

    // Validar descripción (opcional)
    if (descripcion != null) {
      final errorDescripcion = validarDescripcion(descripcion);
      if (errorDescripcion != null) return errorDescripcion;
    }

    return null; // Todo válido
  }

  /// Valida un formulario genérico basado en el tipo
  static String? validarFormulario({
    required String tipo,
    required TextEditingController montoController,
    required TextEditingController categoriaController,
    required TextEditingController descripcionController,
    TextEditingController? metodoPagoController,
    TextEditingController? origenController,
    TextEditingController? proveedorController,
    TextEditingController? lugarController,
  }) {
    if (tipo == 'ingreso') {
      return validarFormularioIngreso(
        monto: montoController.text,
        categoria: categoriaController.text,
        metodoPago: metodoPagoController?.text ?? '',
        origen: origenController?.text ?? '',
        descripcion: descripcionController.text,
      );
    } else if (tipo == 'gasto') {
      return validarFormularioGasto(
        monto: montoController.text,
        categoria: categoriaController.text,
        proveedor: proveedorController?.text ?? '',
        lugar: lugarController?.text ?? '',
        descripcion: descripcionController.text,
      );
    }

    return 'Tipo de transacción no válido';
  }

  /// Valida que un campo de texto no esté vacío
  static String? validarCampoRequerido(String? valor, String nombreCampo) {
    if (valor == null || valor.isEmpty) {
      return '$nombreCampo es requerido';
    }

    if (valor.trim().isEmpty) {
      return '$nombreCampo no puede estar vacío';
    }

    return null; // Válido
  }

  /// Valida un campo numérico
  static String? validarCampoNumerico(
    String? valor,
    String nombreCampo, {
    double? min,
    double? max,
  }) {
    if (valor == null || valor.isEmpty) {
      return '$nombreCampo es requerido';
    }

    final numero = double.tryParse(valor);
    if (numero == null) {
      return '$nombreCampo debe ser un número válido';
    }

    if (min != null && numero < min) {
      return '$nombreCampo debe ser mayor o igual a $min';
    }

    if (max != null && numero > max) {
      return '$nombreCampo debe ser menor o igual a $max';
    }

    return null; // Válido
  }
}
