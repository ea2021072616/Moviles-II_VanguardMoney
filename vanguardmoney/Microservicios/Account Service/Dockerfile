# Usar imagen base oficial de Node.js (versión LTS)
FROM node:18-alpine

# Establecer metadatos de la imagen
LABEL maintainer="Auth Service Team <auth-team@ejemplo.com>"
LABEL description="Microservicio RESTful de autenticación y registro de usuarios"
LABEL version="1.0.0"

# Crear un usuario no-root para ejecutar la aplicación (por seguridad)
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de dependencias
COPY package*.json ./

# Instalar dependencias de producción únicamente
RUN npm ci --only=production && npm cache clean --force

# Copiar el código fuente
COPY --chown=nextjs:nodejs src/ ./src/

# Crear directorio para la base de datos SQLite y darle permisos
RUN mkdir -p /app/data && chown -R nextjs:nodejs /app/data

# Exponer el puerto que usa la aplicación
EXPOSE 3000

# Cambiar al usuario no-root
USER nextjs

# Variables de entorno por defecto (pueden ser sobrescritas)
ENV NODE_ENV=production
ENV PORT=3000
ENV DB_STORAGE=/app/data/auth_database.sqlite

# Comando para iniciar la aplicación
CMD ["node", "src/app.js"]

# Health check para Docker
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "const http = require('http'); const options = { host: 'localhost', port: process.env.PORT || 3000, path: '/health', timeout: 2000 }; const req = http.get(options, (res) => { if (res.statusCode === 200) { process.exit(0); } else { process.exit(1); } }); req.on('error', () => { process.exit(1); }); req.end();"
