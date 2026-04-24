import { Router } from 'express'
const router = Router()
import productoController from '../controllers/producto.controller'

router.get('/buscar', productoController.buscar)
router.get('/alertas', productoController.obtenerAlertasStock)
router.get('/:id/stock', productoController.obtenerStock)

export default router