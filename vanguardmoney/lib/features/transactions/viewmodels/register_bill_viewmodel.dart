import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/register_bill_model.dart';

class RegisterBillViewModel extends ChangeNotifier {
  final TextEditingController proveedorController = TextEditingController();
  final TextEditingController montoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController lugarLocalController = TextEditingController();

  String? categoriaSeleccionada;

  void setCategoria(String? nuevaCategoria) {
    categoriaSeleccionada = nuevaCategoria;
    notifyListeners();
  }

  void limpiarFormulario() {
    proveedorController.clear();
    montoController.clear();
    descripcionController.clear();
    lugarLocalController.clear();
    categoriaSeleccionada = null;
    notifyListeners();
  }

  Factura crearFactura(String idUsuario) {
    return Factura(
      idUsuario: idUsuario,
      proveedor: proveedorController.text,
      monto: double.tryParse(montoController.text) ?? 0.0,
      descripcion: descripcionController.text,
      lugarLocal: lugarLocalController.text,
      categoria: categoriaSeleccionada ?? '',
    );
  }

  Future<void> guardarFacturaEnFirebase(String idUsuario) async {
    final factura = crearFactura(idUsuario);
    await FirebaseFirestore.instance
        .collection('facturas')
        .add(factura.toMap());
    limpiarFormulario();
  }
}
