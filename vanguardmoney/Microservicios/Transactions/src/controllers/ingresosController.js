const { Ingreso } = require('../models');

exports.registrarIngreso = async (req, res) => {
  try {
    const { id_usuario, monto_ingreso, fecha, hora, lugar } = req.body;
    if (!id_usuario || !monto_ingreso || !fecha || !hora || !lugar) {
      return res.status(400).json({ message: 'Todos los campos son obligatorios' });
    }

    const ingreso = await Ingreso.create({ id_usuario, monto_ingreso, fecha, hora, lugar });
    res.status(201).json(ingreso);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
