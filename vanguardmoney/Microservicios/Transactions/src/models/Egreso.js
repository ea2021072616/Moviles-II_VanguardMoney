const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Egreso = sequelize.define('Egreso', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  id_usuario: { type: DataTypes.INTEGER, allowNull: false },
  monto_egreso: { type: DataTypes.FLOAT, allowNull: false },
  fecha: { type: DataTypes.DATEONLY, allowNull: false },
  hora: { type: DataTypes.TIME, allowNull: false },
  lugar: { type: DataTypes.STRING, allowNull: false }
}, { tableName: 'egresos', timestamps: false });

module.exports = Egreso;
