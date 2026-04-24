import { Router } from 'express'
const router = Router()

import ventaController from '../controllers/venta.controller'
router.post('/', ventaController.crear)

export default router