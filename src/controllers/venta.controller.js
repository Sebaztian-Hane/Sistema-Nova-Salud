import ventasService from '../services/ventas.service'
class VentaController {
  
  // POST /api/ventas
  async crear(req, res, next) {
    try {
      const venta = await ventaService.crearVenta({
        ...req.body,
        usuarioId: req.user?.id || 1 // Temporal
      })
      
      res.json({ 
        ok: true, 
        data: venta,
        message: `Venta ${venta.numeroTicket} completada` 
      })
    } catch (error) {
      next(error)
    }
  }
}

export default new VentaController() 