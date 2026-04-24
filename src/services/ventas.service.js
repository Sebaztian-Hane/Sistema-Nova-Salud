import prisma from '../utils/prisma'
class VentaService {
  
  // CREAR VENTA CON TRANSACCIÓN SEGURA
  async crearVenta(datosVenta) {
    const { clienteId, items, metodoPago, montoPagado, usuarioId } = datosVenta

    return await prisma.$transaction(async (tx) => {
      
      // 1. Calcular totales
      let subtotal = 0
      const detallesParaInsertar = []

      // 2. Verificar stock y preparar detalles
      for (const item of items) {
        const producto = await tx.producto.findUnique({
          where: { id: item.productoId },
          select: { precioVenta: true }
        })

        // Obtener lote según FEFO
        const lote = await tx.lote.findFirst({
          where: {
            productoId: item.productoId,
            stockActual: { gt: 0 },
            fechaVencimiento: { gt: new Date() },
            activo: true
          },
          orderBy: { fechaVencimiento: 'asc' }
        })

        if (!lote || lote.stockActual < item.cantidad) {
          throw new Error(`Stock insuficiente para producto ID ${item.productoId}`)
        }

        const precio = Number(producto.precioVenta)
        const totalLinea = precio * item.cantidad
        subtotal += totalLinea

        detallesParaInsertar.push({
          productoId: item.productoId,
          loteId: lote.id,
          cantidad: item.cantidad,
          precioUnitario: precio
        })
      }

      const igv = subtotal * 0.18
      const total = subtotal + igv

      // 3. Crear cabecera de venta
      const venta = await tx.venta.create({
        data: {
          numeroTicket: `F001-${Date.now().toString().slice(-8)}`,
          clienteId: clienteId || null,
          subtotal,
          igv,
          total,
          metodoPago,
          montoPagado: montoPagado || total,
          vuelto: montoPagado ? montoPagado - total : 0,
          usuarioId,
          detalleVentas: {
            create: detallesParaInsertar
          }
        },
        include: {
          detalleVentas: {
            include: {
              producto: { select: { nombreComercial: true } }
            }
          }
        }
      })

      // 4. Actualizar stock de lotes
      for (const detalle of detallesParaInsertar) {
        await tx.lote.update({
          where: { id: detalle.loteId },
          data: {
            stockActual: { decrement: detalle.cantidad }
          }
        })
      }

      return venta
    })
  }
}

export default new VentaService()