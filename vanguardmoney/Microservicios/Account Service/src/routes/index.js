const express = require('express');
const router = express.Router();

/**
 * @swagger
 * /health:
 *   get:
 *     summary: Verificar estado de salud del servicio
 *     tags: [Sistema]
 *     responses:
 *       200:
 *         description: Servicio funcionando correctamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Servicio de autenticación funcionando correctamente"
 *                 data:
 *                   type: object
 *                   properties:
 *                     timestamp:
 *                       type: string
 *                       format: date-time
 *                     uptime:
 *                       type: number
 *                       description: Tiempo activo en segundos
 *                     environment:
 *                       type: string
 *                       description: Entorno de ejecución
 *                     version:
 *                       type: string
 *                       description: Versión del servicio
 */
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Servicio de autenticación funcionando correctamente',
    data: {
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV || 'development',
      version: process.env.npm_package_version || '1.0.0'
    }
  });
});

/**
 * @swagger
 * /:
 *   get:
 *     summary: Endpoint raíz del microservicio
 *     tags: [Sistema]
 *     responses:
 *       200:
 *         description: Información básica del microservicio
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     name:
 *                       type: string
 *                     version:
 *                       type: string
 *                     description:
 *                       type: string
 *                     endpoints:
 *                       type: array
 *                       items:
 *                         type: string
 */
router.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Bienvenido al Microservicio de Autenticación',
    data: {
      name: 'Auth Microservice',
      version: '1.0.0',
      description: 'Microservicio RESTful de autenticación y registro de usuarios',
      endpoints: [
        'POST /auth/register - Registrar usuario',
        'POST /auth/login - Iniciar sesión',
        'POST /auth/verify - Verificar token',
        'GET /auth/profile - Obtener perfil (requiere autenticación)',
        'GET /health - Estado del servicio',
        'GET /api-docs - Documentación Swagger'
      ]
    }
  });
});

module.exports = router;
