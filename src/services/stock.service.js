import prisma from '../utils/prisma.js'

class StockService {
  
  // BÚSQUEDA RÁPIDA DE PRODUCTOS PARA VENTA
  async buscarProductos(termino) {
    const productos = await prisma.producto.findMany({
      where: {
        activo: true,
        OR: [
          { nombreComercial: { contains: termino, mode: 'insensitive' } },
          { principioActivo: { contains: termino, mode: 'insensitive' } },
          { laboratorio: { nombre: { contains: termino, mode: 'insensitive' } } },
          { codigoBarras: { contains: termino } }
        ]
      },
      include: {
        laboratorio: { select: { nombre: true } },
        categoria: { select: { nombre: true, requiereReceta: true } },
        presentacion: { select: { nombre: true } },
        lotes: {
          where: {
            stockActual: { gt: 0 },
            fechaVencimiento: { gt: new Date() },
            activo: true
          },
          select: {
            stockActual: true,
            fechaVencimiento: true
          }
        }
      },
      take: 20, // Limitar resultados para velocidad
      orderBy: { nombreComercial: 'asc' }
    })

    // Calcular stock total por producto
    return productos.map(p => {
      const stockTotal = p.lotes.reduce((sum, lote) => sum + lote.stockActual, 0)
      return {
        id: p.id,
        codigoBarras: p.codigoBarras,
        nombre: p.nombreComercial,
        principioActivo: p.principioActivo,
        laboratorio: p.laboratorio.nombre,
        precioVenta: Number(p.precioVenta),
        stockActual: stockTotal,
        stockMinimo: p.stockMinimo,
        requiereReceta: p.categoria.requiereReceta,
        // Alerta visual para frontend
        estado: stockTotal === 0 ? 'AGOTADO' 
              : stockTotal <= p.stockMinimo ? 'CRITICO' 
              : 'DISPONIBLE'
      }
    })
  }

  // Obtener producto específico para venta
  async obtenerProductoParaVenta(productoId) {
    const producto = await prisma.producto.findUnique({
      where: { id: productoId, activo: true },
      include: {
        laboratorio: { select: { nombre: true } },
        lotes: {
          where: {
            stockActual: { gt: 0 },
            fechaVencimiento: { gt: new Date() },
            activo: true
          },
          orderBy: { fechaVencimiento: 'asc' }, // FEFO
          select: {
            id: true,
            numeroLote: true,
            stockActual: true,
            fechaVencimiento: true
          }
        }
      }
    })

    if (!producto) return null

    const stockTotal = producto.lotes.reduce((sum, l) => sum + l.stockActual, 0)
    
    return {
      ...producto,
      stockActual: stockTotal,
      precioVenta: Number(producto.precioVenta)
    }
  }
}

export default new StockService()