import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import compression from 'compression'
import morgan from 'morgan'

import productoRoutes from './routes/producto.routes.js'
import ventaRoutes from './routes/venta.routes.js'

const app = express()

// Middlewares
app.use(helmet())
app.use(cors())
app.use(compression())
app.use(morgan('dev'))
app.use(express.json())

// Rutas API
app.use('/api/productos', productoRoutes)
app.use('/api/ventas', ventaRoutes)

// Health Check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() })
})

// Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(err.status || 500).json({
    ok: false,
    message: err.message || 'Error interno del servidor'
  })
})

export default app