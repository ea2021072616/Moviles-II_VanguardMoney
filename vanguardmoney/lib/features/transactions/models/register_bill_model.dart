
class Factura {
  final String idUsuario;
  final String proveedor;
  final double monto;
  final String descripcion;
  final String lugarLocal;
  final String categoria;

  Factura({
    required this.idUsuario,
    required this.proveedor,
    required this.monto,
    required this.descripcion,
    required this.lugarLocal,
    required this.categoria,
  });

  // Para guardar en Firebase
  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'proveedor': proveedor,
      'monto': monto,
      'descripcion': descripcion,
      'lugarLocal': lugarLocal,
      'categoria': categoria,
    };
  }

  // Para leer desde Firebase
  factory Factura.fromMap(Map<String, dynamic> map) {
    return Factura(
      idUsuario: map['idUsuario'] ?? '',
      proveedor: map['proveedor'] ?? '',
      monto: (map['monto'] ?? 0).toDouble(),
      descripcion: map['descripcion'] ?? '',
      lugarLocal: map['lugarLocal'] ?? '',
      categoria: map['categoria'] ?? '',
    );
  }
}