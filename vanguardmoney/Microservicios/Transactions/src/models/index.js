const sequelize = require('../config/database');
const Ingreso = require('./Ingreso');
const Egreso = require('./Egreso');

module.exports = { sequelize, Ingreso, Egreso };
