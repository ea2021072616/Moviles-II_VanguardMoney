const { Egreso } = require('../models');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');

dotenv.config();

exports.registrarEgreso = async (req, res) => {
  try {
    const { id_usuario, monto_egreso, fecha, hora, lugar } = req.body;
    if (!id_usuario || !monto_egreso || !fecha || !hora || !lugar) {
      return res.status(400).json({ message: 'Todos los campos son obligatorios' });
    }

    const egreso = await Egreso.create({ id_usuario, monto_egreso, fecha, hora, lugar });

    // Generar JWT
    const token = jwt.sign({ id_usuario }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN });

    res.status(201).json({ egreso, token });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
