const { DataTypes } = require('sequelize');
const bcrypt = require('bcrypt');
const { sequelize } = require('../config/sequelize');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    allowNull: false
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: {
      msg: 'Este email ya está registrado'
    },
    validate: {
      isEmail: {
        msg: 'Debe proporcionar un email válido'
      },
      notEmpty: {
        msg: 'El email es requerido'
      },
      len: {
        args: [5, 255],
        msg: 'El email debe tener entre 5 y 255 caracteres'
      }
    }
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      notEmpty: {
        msg: 'La contraseña es requerida'
      },
      len: {
        args: [8, 255],
        msg: 'La contraseña debe tener al menos 8 caracteres'
      },
      isStrongPassword(value) {
        // Al menos una mayúscula, una minúscula, un número y un carácter especial
        const strongPasswordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/;
        if (!strongPasswordRegex.test(value)) {
          throw new Error('La contraseña debe contener al menos: una minúscula, una mayúscula, un número y un carácter especial');
        }
      }
    }
  },
  firstName: {
    type: DataTypes.STRING,
    allowNull: true,
    validate: {
      len: {
        args: [0, 50],
        msg: 'El nombre debe tener máximo 50 caracteres'
      }
    }
  },
  lastName: {
    type: DataTypes.STRING,
    allowNull: true,
    validate: {
      len: {
        args: [0, 50],
        msg: 'El apellido debe tener máximo 50 caracteres'
      }
    }
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    allowNull: false
  },
  lastLoginAt: {
    type: DataTypes.DATE,
    allowNull: true
  }
}, {
  tableName: 'users',
  hooks: {
    // Hook para hashear la contraseña antes de crear el usuario
    beforeCreate: async (user) => {
      if (user.password) {
        const saltRounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
        user.password = await bcrypt.hash(user.password, saltRounds);
      }
    },
    // Hook para hashear la contraseña antes de actualizar si cambió
    beforeUpdate: async (user) => {
      if (user.changed('password') && user.password) {
        const saltRounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
        user.password = await bcrypt.hash(user.password, saltRounds);
      }
    }
  }
});

// Métodos de instancia
User.prototype.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

User.prototype.updateLastLogin = async function() {
  this.lastLoginAt = new Date();
  await this.save({ fields: ['lastLoginAt'] });
};

// Método para obtener datos seguros del usuario (sin contraseña)
User.prototype.toSafeObject = function() {
  const { password, deletedAt, ...safeUser } = this.toJSON();
  return safeUser;
};

// Métodos de clase
User.findByEmail = async function(email) {
  return this.findOne({
    where: { email: email.toLowerCase() }
  });
};

module.exports = User;
