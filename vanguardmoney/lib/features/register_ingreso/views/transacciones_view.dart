import 'package:flutter/material.dart';
import 'register_ingreso_view.dart';
import 'register_bill_view.dart';

class TransaccionesView extends StatelessWidget {
	final String idUsuario;
	const TransaccionesView({Key? key, required this.idUsuario}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Transacciones'),
			),
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						ElevatedButton(
							onPressed: () {
								Navigator.push(
									context,
									MaterialPageRoute(
										builder: (context) => RegisterIngresoView(idUsuario: idUsuario),
									),
								);
							},
							child: const Text('Registrar Ingreso'),
						),
						const SizedBox(height: 20),
						ElevatedButton(
							onPressed: () {
								Navigator.push(
									context,
									MaterialPageRoute(
										builder: (context) => RegisterBillView(idUsuario: idUsuario),
									),
								);
							},
							child: const Text('Registrar Factura'),
						),
					],
				),
			),
		);
	}
}
