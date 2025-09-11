const express = require('express');
const router = express.Router();
const { registrarEgreso } = require('../controllers/egresosController');

/**
 * @openapi
 * /registrar/egresos_dinero:
 *   post:
 *     summary: Registrar un egreso de dinero
 *     tags:
 *       - Egresos
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - id_usuario
 *               - monto_egreso
 *               - fecha
 *               - hora
 *               - lugar
 *             properties:
 *               id_usuario:
 *                 type: integer
 *               monto_egreso:
 *                 type: number
 *               fecha:
 *                 type: string
 *                 format: date
 *               hora:
 *                 type: string
 *                 example: "12:30:00"
 *               lugar:
 *                 type: string
 *     responses:
 *       201:
 *         description: Egreso registrado con éxito
 *       400:
 *         description: Datos inválidos
 */
router.post('/registrar/egresos_dinero', registrarEgreso);

module.exports = router;
