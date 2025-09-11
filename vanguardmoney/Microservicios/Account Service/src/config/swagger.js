const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Auth Microservice API',
      version: '1.0.0',
      description: `
        Microservicio RESTful de autenticación y registro de usuarios.
        
        ## Características
        - Registro y autenticación de usuarios
        - Autenticación JWT con tokens seguros
        - Validación robusta de datos
        - Rate limiting para protección contra ataques
        - Base de datos SQLite (desarrollo) y MySQL (producción)
        - Contraseñas hasheadas con bcrypt
        
        ## Autenticación
        La mayoría de endpoints requieren un token JWT válido enviado en el header Authorization:
        \`Authorization: Bearer <token>\`
        
        ## Errores
        Todas las respuestas siguen el formato:
        \`\`\`json
        {
          "success": boolean,
          "message": "string",
          "error": "ERROR_CODE",
          "data": {} // solo en respuestas exitosas
        }
        \`\`\`
      `,
      contact: {
        name: 'Auth Service Team',
        email: 'auth-team@ejemplo.com'
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT'
      }
    },
    servers: [
      {
        url: process.env.NODE_ENV === 'production' 
          ? 'https://api.ejemplo.com' 
          : `http://localhost:${process.env.PORT || 3000}`,
        description: process.env.NODE_ENV === 'production' 
          ? 'Servidor de producción' 
          : 'Servidor de desarrollo'
      }
    ],
    tags: [
      {
        name: 'Autenticación',
        description: 'Endpoints para registro, login y verificación de tokens'
      },
      {
        name: 'Usuario',
        description: 'Endpoints relacionados con información del usuario'
      },
      {
        name: 'Sistema',
        description: 'Endpoints del sistema y monitoreo'
      }
    ]
  },
  apis: [
    './src/routes/*.js', // paths to files containing OpenAPI definitions
  ],
};

const specs = swaggerJsdoc(options);

// Configuración personalizada para Swagger UI
const swaggerOptions = {
  explorer: true,
  swaggerOptions: {
    persistAuthorization: true,
    displayRequestDuration: true,
    docExpansion: 'none',
    filter: true,
    showExtensions: true,
    tryItOutEnabled: true
  },
  customCss: `
    .swagger-ui .topbar { 
      background-color: #2c3e50; 
    }
    .swagger-ui .topbar-wrapper img { 
      content: url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjQwIiB2aWV3Qm94PSIwIDAgMTAwIDQwIiBmaWxsPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8dGV4dCB4PSI1MCIgeT0iMjIiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIiBmb250LXNpemU9IjE0IiBmb250LWZhbWlseT0iQXJpYWwiPkF1dGggQVBJPC90ZXh0Pgo8L3N2Zz4=');
    }
    .swagger-ui .info h1 { 
      color: #2c3e50; 
    }
  `,
  customSiteTitle: 'Auth Microservice - API Documentation'
};

module.exports = {
  specs,
  swaggerUi,
  swaggerOptions
};
