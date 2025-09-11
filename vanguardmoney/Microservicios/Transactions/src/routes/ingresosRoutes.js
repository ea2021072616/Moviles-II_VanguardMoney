const express = require('express');
const router = express.Router();
const { registrarIngreso } = require('../controllers/ingresosController');
const authMiddleware = require('../middlewares/authMiddleware');

/**
 * @openapi
 * /registrar/ingresos_dinero:
 *   post:
 *     summary: Registrar un ingreso de dinero (requiere JWT)
 *     tags:
 *       - Ingresos
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - id_usuario
 *               - monto_ingreso
 *               - fecha
 *               - hora
 *               - lugar
 *             properties:
 *               id_usuario:
 *                 type: integer
 *               monto_ingreso:
 *                 type: number
 *               fecha:
 *                 type: string
 *                 format: date
 *               hora:
 *                 type: string
 *                 example: "10:00:00"
 *               lugar:
 *                 type: string
 *     responses:
 *       201:
 *         description: Ingreso registrado con éxito
 *       400:
 *         description: Datos inválidos
 *       401:
 *         description: Token requerido
 */
router.post('/registrar/ingresos_dinero', registrarIngreso);

module.exports = router;
