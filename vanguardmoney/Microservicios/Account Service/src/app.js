require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

// Importar configuraciones
const { testConnection } = require('./config/sequelize');
const { syncDatabase } = require('./models');
const { specs, swaggerUi, swaggerOptions } = require('./config/swagger');

// Importar middleware
const { generalLimiter } = require('./middleware/rateLimiter');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

// Importar rutas
const indexRoutes = require('./routes/index');
const authRoutes = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware de seguridad
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "fonts.googleapis.com"],
      fontSrc: ["'self'", "fonts.gstatic.com"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "validator.swagger.io"]
    }
  }
}));

// CORS configuration
const corsOptions = {
  origin: process.env.NODE_ENV === 'production' 
    ? process.env.ALLOWED_ORIGINS?.split(',') || ['https://yourdomain.com']
    : ['http://localhost:3000', 'http://127.0.0.1:3000', 'http://localhost:8080'],
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
};

app.use(cors(corsOptions));

// Middleware de parsing
app.use(express.json({ 
  limit: '10mb',
  strict: true
}));
app.use(express.urlencoded({ 
  extended: true, 
  limit: '10mb' 
}));

// Rate limiting global
app.use(generalLimiter);

// Logging middleware (solo en desarrollo)
if (process.env.NODE_ENV === 'development') {
  app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path} - IP: ${req.ip}`);
    next();
  });
}

// Health check endpoint (debe ir antes que las rutas principales)
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Servicio funcionando correctamente',
    data: {
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV || 'development'
    }
  });
});

// Documentación Swagger
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs, swaggerOptions));

// Redireccionar /docs a /api-docs para conveniencia
app.get('/docs', (req, res) => {
  res.redirect('/api-docs');
});

// Rutas principales
app.use('/', indexRoutes);
app.use('/auth', authRoutes);

// Middleware de manejo de errores (debe ir al final)
app.use(notFoundHandler);
app.use(errorHandler);

// Función para inicializar el servidor
const startServer = async () => {
  try {
    // Probar conexión a la base de datos
    console.log('🔄 Probando conexión a la base de datos...');
    await testConnection();
    
    // Sincronizar modelos con la base de datos
    console.log('🔄 Sincronizando base de datos...');
    await syncDatabase();
    
    // Iniciar servidor
    const server = app.listen(PORT, () => {
      console.log('\\n' + '='.repeat(50));
      console.log('🚀 Microservicio de Autenticación iniciado exitosamente');
      console.log('='.repeat(50));
      console.log(`📡 Servidor corriendo en: http://localhost:${PORT}`);
      console.log(`📚 Documentación Swagger: http://localhost:${PORT}/api-docs`);
      console.log(`🏥 Health check: http://localhost:${PORT}/health`);
      console.log(`🌍 Entorno: ${process.env.NODE_ENV || 'development'}`);
      console.log(`💾 Base de datos: ${process.env.DB_DIALECT || 'sqlite'}`);
      console.log('='.repeat(50) + '\\n');
    });
    
    // Manejo de cierre graceful
    const gracefulShutdown = (signal) => {
      console.log(`\\n⚠️ Recibida señal ${signal}. Cerrando servidor...`);
      
      server.close(async () => {
        console.log('🔄 Cerrando conexiones de base de datos...');
        
        try {
          const { sequelize } = require('./config/sequelize');
          await sequelize.close();
          console.log('✅ Conexiones cerradas correctamente');
          process.exit(0);
        } catch (error) {
          console.error('❌ Error al cerrar conexiones:', error);
          process.exit(1);
        }
      });
      
      // Forzar cierre después de 10 segundos
      setTimeout(() => {
        console.log('⚠️ Forzando cierre del servidor...');
        process.exit(1);
      }, 10000);
    };
    
    // Escuchar señales de cierre
    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));
    
    // Manejo de errores no capturados
    process.on('uncaughtException', (error) => {
      console.error('❌ Uncaught Exception:', error);
      process.exit(1);
    });
    
    process.on('unhandledRejection', (reason, promise) => {
      console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
      process.exit(1);
    });
    
  } catch (error) {
    console.error('❌ Error al inicializar el servidor:', error);
    process.exit(1);
  }
};

// Solo iniciar el servidor si este archivo se ejecuta directamente
if (require.main === module) {
  startServer();
}

// Exportar app para testing
module.exports = app;
