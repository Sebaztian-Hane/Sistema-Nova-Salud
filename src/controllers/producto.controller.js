import stockService from '../services/stock.service'
class ProductoController {
  
  // GET /api/productos/buscar?q=ibuprofeno
  async buscar(req, res, next) {
    try {
      const { q } = req.query
      
      if (!q || q.length < 2) {
        return res.json({ ok: true, data: [] })
      }

      const resultados = await stockService.buscarProductos(q)
      res.json({ ok: true, data: resultados })
      
    } catch (error) {
      next(error)
    }
  }

  // GET /api/productos/:id/stock
  async obtenerStock(req, res, next) {
    try {
      const { id } = req.params
      const producto = await stockService.obtenerProductoParaVenta(parseInt(id))
      
      if (!producto) {
        return res.status(404).json({ ok: false, message: 'Producto no encontrado' })
      }
      
      res.json({ ok: true, data: producto })
    } catch (error) {
      next(error)
    }
  }

  // GET /api/productos/alertas
  async obtenerAlertasStock(req, res, next) {
    try {
      const productos = await stockService.buscarProductos('') // Todos
      const criticos = productos.filter(p => p.estado === 'CRITICO' || p.estado === 'AGOTADO')
      res.json({ ok: true, data: criticos })
    } catch (error) {
      next(error)
    }
  }
}

export default new ProductoController()