const { sequelize } = require('../config/sequelize');
const User = require('./User');

// Objeto que contiene todos los modelos
const models = {
  User,
  sequelize
};

// Sync database
const syncDatabase = async () => {
  try {
    await sequelize.sync({ alter: true }); // Use { force: true } only in development to recreate tables
    console.log('✅ Database synchronized successfully');
  } catch (error) {
    console.error('❌ Error synchronizing database:', error);
    throw error;
  }
};

module.exports = {
  ...models,
  syncDatabase
};
