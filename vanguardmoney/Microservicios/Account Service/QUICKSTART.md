# 🚀 Guía de Inicio Rápido

## Iniciar el Microservicio

### Opción 1: Docker (Recomendado)

```bash
# 1. Clonar y navegar al proyecto
cd auth-microservice

# 2. Desarrollo rápido (solo SQLite)
docker-compose -f docker-compose.dev.yml up --build

# 3. Acceder a la documentación
# http://localhost:3000/api-docs
```

### Opción 2: Local

```bash
# 1. Instalar dependencias
npm install

# 2. Configurar entorno
cp .env.example .env

# 3. Iniciar
npm run dev
```

## 🔥 Probar la API

### 1. Registrar Usuario

```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@ejemplo.com",
    "password": "TestPassword123!",
    "firstName": "Usuario",
    "lastName": "Prueba"
  }'
```

### 2. Iniciar Sesión

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@ejemplo.com",
    "password": "TestPassword123!"
  }'
```

### 3. Usar Token

```bash
# Copia el token de la respuesta anterior
curl -X GET http://localhost:3000/auth/profile \
  -H "Authorization: Bearer TU_TOKEN_AQUI"
```

## ✅ Verificar Estado

```bash
# Health check
curl http://localhost:3000/health

# Info del servicio
curl http://localhost:3000/
```

¡El microservicio está listo para usar! 🎉
