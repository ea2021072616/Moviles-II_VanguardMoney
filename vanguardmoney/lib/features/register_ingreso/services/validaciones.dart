String? validarMonto(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El monto es obligatorio';
  }
  final monto = double.tryParse(value);
  if (monto == null || monto <= 0) {
    return 'Ingrese un monto válido';
  }
  return null;
}

String? validarFecha(DateTime? value) {
  if (value == null) {
    return 'La fecha es obligatoria';
  }
  return null;
}

String? validarDescripcion(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'La descripción es obligatoria';
  }
  return null;
}

String? validarCategoria(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'La categoría es obligatoria';
  }
  return null;
}

String? validarMetodoPago(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El método de pago es obligatorio';
  }
  return null;
}

String? validarOrigen(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El origen es obligatorio';
  }
  return null;
}

String? validarProveedor(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El proveedor es obligatorio';
  }
  return null;
}

String? validarLugarLocal(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El lugar/local es obligatorio';
  }
  return null;
}