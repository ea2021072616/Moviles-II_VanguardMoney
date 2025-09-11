const { body, validationResult } = require('express-validator');
const authService = require('../services/authService');

/**
 * Validaciones para registro de usuario
 */
const registerValidation = [
  body('email')
    .isEmail()
    .withMessage('Debe proporcionar un email válido')
    .normalizeEmail()
    .isLength({ min: 5, max: 255 })
    .withMessage('El email debe tener entre 5 y 255 caracteres'),
  
  body('password')
    .isLength({ min: 8 })
    .withMessage('La contraseña debe tener al menos 8 caracteres')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('La contraseña debe contener al menos: una minúscula, una mayúscula, un número y un carácter especial (@$!%*?&)'),
  
  body('firstName')
    .optional()
    .isLength({ max: 50 })
    .withMessage('El nombre debe tener máximo 50 caracteres')
    .trim(),
  
  body('lastName')
    .optional()
    .isLength({ max: 50 })
    .withMessage('El apellido debe tener máximo 50 caracteres')
    .trim()
];

/**
 * Validaciones para login
 */
const loginValidation = [
  body('email')
    .isEmail()
    .withMessage('Debe proporcionar un email válido')
    .normalizeEmail(),
  
  body('password')
    .notEmpty()
    .withMessage('La contraseña es requerida')
];

/**
 * Middleware para manejar errores de validación
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Error de validación',
      error: 'VALIDATION_ERROR',
      details: errors.array().map(error => ({
        field: error.path || error.param,
        message: error.msg,
        value: error.value
      }))
    });
  }
  
  next();
};

/**
 * Controller para registro de usuario
 */
const register = async (req, res, next) => {
  try {
    const { email, password, firstName, lastName } = req.body;
    
    const result = await authService.registerUser({
      email,
      password,
      firstName,
      lastName
    });
    
    res.status(201).json(result);
    
  } catch (error) {
    // Manejar errores específicos
    if (error.message === 'EMAIL_ALREADY_EXISTS') {
      return res.status(409).json({
        success: false,
        message: 'Este email ya está registrado',
        error: 'EMAIL_ALREADY_EXISTS'
      });
    }
    
    if (error.message === 'REGISTRATION_FAILED') {
      return res.status(500).json({
        success: false,
        message: 'Error al registrar el usuario',
        error: 'REGISTRATION_FAILED'
      });
    }
    
    // Pasar otros errores al middleware de manejo de errores
    next(error);
  }
};

/**
 * Controller para login de usuario
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    
    const result = await authService.loginUser(email, password);
    
    res.status(200).json(result);
    
  } catch (error) {
    // Manejar errores específicos
    if (error.message === 'INVALID_CREDENTIALS') {
      return res.status(401).json({
        success: false,
        message: 'Credenciales inválidas',
        error: 'INVALID_CREDENTIALS'
      });
    }
    
    if (error.message === 'USER_INACTIVE') {
      return res.status(401).json({
        success: false,
        message: 'Usuario inactivo. Contacta al administrador',
        error: 'USER_INACTIVE'
      });
    }
    
    if (error.message === 'LOGIN_FAILED') {
      return res.status(500).json({
        success: false,
        message: 'Error al iniciar sesión',
        error: 'LOGIN_FAILED'
      });
    }
    
    // Pasar otros errores al middleware de manejo de errores
    next(error);
  }
};

/**
 * Controller para verificar token
 */
const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Token requerido',
        error: 'NO_TOKEN'
      });
    }
    
    const result = await authService.verifyToken(token);
    
    res.status(200).json(result);
    
  } catch (error) {
    if (error.message === 'TOKEN_EXPIRED') {
      return res.status(401).json({
        success: false,
        message: 'Token expirado',
        error: 'TOKEN_EXPIRED'
      });
    }
    
    if (error.message === 'INVALID_TOKEN') {
      return res.status(401).json({
        success: false,
        message: 'Token inválido',
        error: 'INVALID_TOKEN'
      });
    }
    
    if (error.message === 'TOKEN_VERIFICATION_FAILED') {
      return res.status(500).json({
        success: false,
        message: 'Error al verificar el token',
        error: 'TOKEN_VERIFICATION_FAILED'
      });
    }
    
    next(error);
  }
};

/**
 * Controller para obtener perfil del usuario autenticado
 */
const getProfile = async (req, res, next) => {
  try {
    // El middleware de autenticación ya validó el token y añadió el usuario a req.user
    const result = await authService.getUserProfile(req.user.id);
    
    res.status(200).json(result);
    
  } catch (error) {
    if (error.message === 'USER_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado',
        error: 'USER_NOT_FOUND'
      });
    }
    
    if (error.message === 'PROFILE_FETCH_FAILED') {
      return res.status(500).json({
        success: false,
        message: 'Error al obtener el perfil',
        error: 'PROFILE_FETCH_FAILED'
      });
    }
    
    next(error);
  }
};

module.exports = {
  register,
  login,
  verifyToken,
  getProfile,
  registerValidation,
  loginValidation,
  handleValidationErrors
};
