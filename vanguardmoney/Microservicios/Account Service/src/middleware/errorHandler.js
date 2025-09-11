/**
 * Middleware global de manejo de errores
 */
const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Errores de validación de Sequelize
  if (err.name === 'SequelizeValidationError') {
    const errors = err.errors.map(error => ({
      field: error.path,
      message: error.message
    }));
    
    return res.status(400).json({
      success: false,
      message: 'Error de validación',
      error: 'VALIDATION_ERROR',
      details: errors
    });
  }

  // Error de email único de Sequelize
  if (err.name === 'SequelizeUniqueConstraintError') {
    return res.status(409).json({
      success: false,
      message: 'Este email ya está registrado',
      error: 'EMAIL_ALREADY_EXISTS'
    });
  }

  // Errores de base de datos
  if (err.name === 'SequelizeDatabaseError') {
    return res.status(500).json({
      success: false,
      message: 'Error de base de datos',
      error: 'DATABASE_ERROR'
    });
  }

  // Error por defecto
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Error interno del servidor',
    error: err.code || 'INTERNAL_ERROR'
  });
};

/**
 * Middleware para manejar rutas no encontradas
 */
const notFoundHandler = (req, res) => {
  res.status(404).json({
    success: false,
    message: `Ruta ${req.method} ${req.path} no encontrada`,
    error: 'ROUTE_NOT_FOUND'
  });
};

module.exports = {
  errorHandler,
  notFoundHandler
};
