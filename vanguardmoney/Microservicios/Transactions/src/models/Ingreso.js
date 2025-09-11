const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Ingreso = sequelize.define('Ingreso', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  id_usuario: { type: DataTypes.INTEGER, allowNull: false },
  monto_ingreso: { type: DataTypes.FLOAT, allowNull: false },
  fecha: { type: DataTypes.DATEONLY, allowNull: false },
  hora: { type: DataTypes.TIME, allowNull: false },
  lugar: { type: DataTypes.STRING, allowNull: false }
}, { tableName: 'ingresos', timestamps: false });

module.exports = Ingreso;
