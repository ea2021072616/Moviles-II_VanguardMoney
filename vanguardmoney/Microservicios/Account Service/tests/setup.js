// Setup para tests
require('dotenv').config({ path: '.env.test' });

// Mock console.log en tests para evitar spam
global.console = {
  ...console,
  log: jest.fn(),
  error: console.error,
  warn: console.warn,
  info: console.info,
  debug: console.debug,
};

// Variables de entorno para testing
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_jwt_secret';
process.env.DB_DIALECT = 'sqlite';
process.env.DB_STORAGE = ':memory:'; // Base de datos en memoria para tests
