# 🔐 Microservicio de Autenticación

Microservicio RESTful completo para autenticación y registro de usuarios con JWT, construido con Node.js, Express, Sequelize, y totalmente dockerizado.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Tecnologías](#-tecnologías)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [API Endpoints](#-api-endpoints)
- [Docker](#-docker)
- [Configuración](#-configuración)
- [Testing](#-testing)
- [Contribución](#-contribución)

## ✨ Características

- ✅ **Registro y autenticación** de usuarios con JWT
- ✅ **Contraseñas seguras** con bcrypt y validación robusta
- ✅ **Base de datos flexible**: SQLite (desarrollo) y MySQL (producción)
- ✅ **Validación completa** de datos de entrada con express-validator
- ✅ **Rate limiting** para protección contra ataques
- ✅ **Documentación interactiva** con Swagger UI
- ✅ **Dockerización completa** para desarrollo y producción
- ✅ **Middleware de seguridad** con Helmet y CORS
- ✅ **Manejo robusto de errores** y logging
- ✅ **Health checks** y monitoreo
- ✅ **Arquitectura escalable** lista para OAuth2/social login

## 🛠 Tecnologías

| Categoría | Tecnología | Versión | Propósito |
|-----------|------------|---------|-----------|
| **Runtime** | Node.js | ≥16.0 | Entorno de ejecución |
| **Framework** | Express | ^4.18 | Framework web |
| **ORM** | Sequelize | ^6.32 | Mapeo objeto-relacional |
| **Base de datos** | SQLite/MySQL | - | Almacenamiento de datos |
| **Autenticación** | JWT | ^9.0 | Tokens de autenticación |
| **Hashing** | bcrypt | ^5.1 | Hash de contraseñas |
| **Documentación** | Swagger | ^6.2 | API documentation |
| **Contenedores** | Docker | - | Containerización |

## 🚀 Instalación

### Prerrequisitos

- Node.js ≥16.0
- npm ≥8.0
- Docker (opcional pero recomendado)

### Instalación Local

```bash
# Clonar el repositorio
git clone <repository-url>
cd auth-microservice

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env

# Iniciar en modo desarrollo
npm run dev
```

### Con Docker (Recomendado)

```bash
# Solo el microservicio (desarrollo)
docker-compose -f docker-compose.dev.yml up --build

# Stack completo con MySQL (producción)
docker-compose up --build

# Con Nginx y Redis
docker-compose --profile production up --build
```

## 📖 Uso

### Iniciar el Servidor

```bash
# Desarrollo
npm run dev

# Producción
npm start

# Con Docker
docker-compose up
```

### Acceder a la Documentación

Una vez iniciado el servidor, puedes acceder a:

- **API Documentation**: http://localhost:3000/api-docs
- **Health Check**: http://localhost:3000/health
- **Service Info**: http://localhost:3000/

## 🔌 API Endpoints

### Autenticación

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| `POST` | `/auth/register` | Registrar usuario | No |
| `POST` | `/auth/login` | Iniciar sesión | No |
| `POST` | `/auth/verify` | Verificar token | No |
| `GET` | `/auth/profile` | Obtener perfil | Sí |

### Sistema

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/health` | Estado del servicio |
| `GET` | `/` | Información del servicio |

### Ejemplos de Uso

#### Registrar Usuario

```bash
curl -X POST http://localhost:3000/auth/register \\
  -H "Content-Type: application/json" \\
  -d '{
    "email": "usuario@ejemplo.com",
    "password": "MiPassword123!",
    "firstName": "Juan",
    "lastName": "Pérez"
  }'
```

#### Iniciar Sesión

```bash
curl -X POST http://localhost:3000/auth/login \\
  -H "Content-Type: application/json" \\
  -d '{
    "email": "usuario@ejemplo.com",
    "password": "MiPassword123!"
  }'
```

#### Obtener Perfil

```bash
curl -X GET http://localhost:3000/auth/profile \\
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 🐳 Docker

### Comandos Útiles

```bash
# Desarrollo (solo microservicio)
docker-compose -f docker-compose.dev.yml up --build

# Producción (con MySQL)
docker-compose up --build

# Detener servicios
docker-compose down

# Ver logs
docker-compose logs -f auth-service

# Ejecutar en segundo plano
docker-compose up -d
```

### Configuración de Docker

- **Desarrollo**: Usa SQLite y monta el código fuente
- **Producción**: Usa MySQL con volúmenes persistentes
- **Health Checks**: Configurados para todos los servicios
- **Redes**: Aislamiento con redes Docker personalizadas

## ⚙️ Configuración

### Variables de Entorno

Copia `.env.example` a `.env` y configura:

```bash
# Servidor
PORT=3000
NODE_ENV=development

# Base de datos (SQLite para desarrollo)
DB_DIALECT=sqlite
DB_STORAGE=./auth_database.sqlite

# Base de datos (MySQL para producción)
DB_HOST=localhost
DB_PORT=3306
DB_NAME=auth_db
DB_USER=your_username
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRES_IN=24h

# Seguridad
BCRYPT_ROUNDS=12
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### Requisitos de Contraseña

Las contraseñas deben cumplir:
- Mínimo 8 caracteres
- Al menos una letra minúscula
- Al menos una letra mayúscula
- Al menos un número
- Al menos un carácter especial (@$!%*?&)

## 🧪 Testing

```bash
# Ejecutar tests
npm test

# Tests con coverage
npm run test:coverage

# Tests en modo watch
npm run test:watch
```

## 📁 Estructura del Proyecto

```
auth-microservice/
├── src/
│   ├── config/           # Configuraciones
│   │   ├── database.js
│   │   ├── sequelize.js
│   │   └── swagger.js
│   ├── controllers/      # Controladores
│   │   └── authController.js
│   ├── middleware/       # Middleware personalizado
│   │   ├── auth.js
│   │   ├── errorHandler.js
│   │   └── rateLimiter.js
│   ├── models/           # Modelos de Sequelize
│   │   ├── User.js
│   │   └── index.js
│   ├── routes/           # Definición de rutas
│   │   ├── auth.js
│   │   └── index.js
│   ├── services/         # Lógica de negocio
│   │   └── authService.js
│   └── app.js           # Aplicación principal
├── docker-compose.yml    # Docker para producción
├── docker-compose.dev.yml # Docker para desarrollo
├── Dockerfile
├── .env.example
├── package.json
└── README.md
```

## 🔒 Seguridad

### Medidas Implementadas

- **Helmet**: Headers de seguridad HTTP
- **CORS**: Configuración restrictiva de origen
- **Rate Limiting**: Protección contra ataques de fuerza bruta
- **JWT**: Tokens seguros con expiración
- **bcrypt**: Hash seguro de contraseñas con salt
- **Validación**: Validación exhaustiva de datos de entrada
- **HTTPS Ready**: Preparado para certificados SSL

### Recomendaciones de Producción

1. **Cambiar secretos**: Actualiza `JWT_SECRET` y otros secretos
2. **HTTPS**: Usa siempre HTTPS en producción
3. **Variables de entorno**: No hardcodees credenciales
4. **Rate limiting**: Ajusta límites según tu uso
5. **Monitoring**: Implementa logging y monitoreo
6. **Backup**: Configura backups automáticos de BD

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 🆘 Soporte

Si tienes preguntas o necesitas ayuda:

1. Revisa la [documentación Swagger](http://localhost:3000/api-docs)
2. Verifica los logs con `docker-compose logs -f`
3. Crea un issue en GitHub
4. Contacta al equipo de desarrollo

## 🚀 Próximas Características

- [ ] OAuth2 integration (Google, Facebook, GitHub)
- [ ] Password reset functionality
- [ ] Email verification
- [ ] User roles and permissions
- [ ] Session management
- [ ] Audit logging
- [ ] Multi-factor authentication (2FA)

---

**¡Gracias por usar el Microservicio de Autenticación! 🎉**
