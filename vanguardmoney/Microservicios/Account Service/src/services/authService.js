const jwt = require('jsonwebtoken');
const { User } = require('../models');

/**
 * Servicio para generar JWT
 */
const generateToken = (userId) => {
  return jwt.sign(
    { userId }, 
    process.env.JWT_SECRET,
    { 
      expiresIn: process.env.JWT_EXPIRES_IN || '24h',
      issuer: 'auth-microservice',
      subject: userId.toString()
    }
  );
};

/**
 * Servicio para registrar un nuevo usuario
 */
const registerUser = async (userData) => {
  try {
    // Normalizar email a minúsculas
    const normalizedData = {
      ...userData,
      email: userData.email.toLowerCase()
    };

    // Verificar si el usuario ya existe
    const existingUser = await User.findByEmail(normalizedData.email);
    if (existingUser) {
      throw new Error('EMAIL_ALREADY_EXISTS');
    }

    // Crear el usuario (la contraseña se hasheará automáticamente)
    const user = await User.create(normalizedData);

    // Generar token
    const token = generateToken(user.id);

    return {
      success: true,
      message: 'Usuario registrado exitosamente',
      data: {
        user: user.toSafeObject(),
        token,
        expiresIn: process.env.JWT_EXPIRES_IN || '24h'
      }
    };

  } catch (error) {
    if (error.message === 'EMAIL_ALREADY_EXISTS') {
      throw error;
    }
    
    if (error.name === 'SequelizeValidationError' || 
        error.name === 'SequelizeUniqueConstraintError') {
      throw error;
    }

    throw new Error('REGISTRATION_FAILED');
  }
};

/**
 * Servicio para autenticar usuario (login)
 */
const loginUser = async (email, password) => {
  try {
    // Buscar usuario por email
    const user = await User.findByEmail(email.toLowerCase());
    
    if (!user) {
      throw new Error('INVALID_CREDENTIALS');
    }

    // Verificar si el usuario está activo
    if (!user.isActive) {
      throw new Error('USER_INACTIVE');
    }

    // Verificar contraseña
    const isPasswordValid = await user.comparePassword(password);
    
    if (!isPasswordValid) {
      throw new Error('INVALID_CREDENTIALS');
    }

    // Actualizar último login
    await user.updateLastLogin();

    // Generar token
    const token = generateToken(user.id);

    return {
      success: true,
      message: 'Inicio de sesión exitoso',
      data: {
        user: user.toSafeObject(),
        token,
        expiresIn: process.env.JWT_EXPIRES_IN || '24h'
      }
    };

  } catch (error) {
    if (['INVALID_CREDENTIALS', 'USER_INACTIVE'].includes(error.message)) {
      throw error;
    }
    
    throw new Error('LOGIN_FAILED');
  }
};

/**
 * Servicio para verificar token
 */
const verifyToken = async (token) => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    const user = await User.findByPk(decoded.userId);
    
    if (!user || !user.isActive) {
      throw new Error('INVALID_TOKEN');
    }

    return {
      success: true,
      message: 'Token válido',
      data: {
        user: user.toSafeObject(),
        tokenData: decoded
      }
    };

  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw new Error('TOKEN_EXPIRED');
    }
    
    if (error.name === 'JsonWebTokenError') {
      throw new Error('INVALID_TOKEN');
    }
    
    throw new Error('TOKEN_VERIFICATION_FAILED');
  }
};

/**
 * Servicio para obtener perfil de usuario
 */
const getUserProfile = async (userId) => {
  try {
    const user = await User.findByPk(userId);
    
    if (!user) {
      throw new Error('USER_NOT_FOUND');
    }

    return {
      success: true,
      message: 'Perfil obtenido exitosamente',
      data: {
        user: user.toSafeObject()
      }
    };

  } catch (error) {
    if (error.message === 'USER_NOT_FOUND') {
      throw error;
    }
    
    throw new Error('PROFILE_FETCH_FAILED');
  }
};

module.exports = {
  registerUser,
  loginUser,
  verifyToken,
  getUserProfile,
  generateToken
};
