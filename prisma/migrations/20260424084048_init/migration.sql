-- CreateEnum
CREATE TYPE "RolUsuario" AS ENUM ('ADMIN', 'FARMACEUTICO', 'VENDEDOR', 'ALMACEN');

-- CreateEnum
CREATE TYPE "MetodoPago" AS ENUM ('EFECTIVO', 'TARJETA', 'YAPE', 'PLIN', 'TRANSFERENCIA');

-- CreateEnum
CREATE TYPE "EstadoVenta" AS ENUM ('COMPLETADA', 'ANULADA', 'PENDIENTE');

-- CreateTable
CREATE TABLE "laboratorios" (
    "id" SERIAL NOT NULL,
    "nombre" VARCHAR(100) NOT NULL,
    "contacto" VARCHAR(100),
    "telefono" VARCHAR(20),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "laboratorios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "categorias" (
    "id" SERIAL NOT NULL,
    "nombre" VARCHAR(100) NOT NULL,
    "descripcion" TEXT,
    "requiere_receta" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "categorias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "presentaciones" (
    "id" SERIAL NOT NULL,
    "nombre" VARCHAR(50) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "presentaciones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "productos" (
    "id" SERIAL NOT NULL,
    "codigo_barras" VARCHAR(50) NOT NULL,
    "nombre_comercial" VARCHAR(200) NOT NULL,
    "principio_activo" VARCHAR(200) NOT NULL,
    "concentracion" VARCHAR(50),
    "laboratorio_id" INTEGER NOT NULL,
    "categoria_id" INTEGER NOT NULL,
    "presentacion_id" INTEGER NOT NULL,
    "stock_minimo" INTEGER NOT NULL DEFAULT 5,
    "stock_maximo" INTEGER NOT NULL DEFAULT 50,
    "precio_compra" DECIMAL(10,2),
    "precio_venta" DECIMAL(10,2) NOT NULL,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "productos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lotes" (
    "id" SERIAL NOT NULL,
    "producto_id" INTEGER NOT NULL,
    "numero_lote" VARCHAR(50) NOT NULL,
    "fecha_vencimiento" DATE NOT NULL,
    "stock_inicial" INTEGER NOT NULL,
    "stock_actual" INTEGER NOT NULL,
    "fecha_compra" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "precio_compra_unitario" DECIMAL(10,2),
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "lotes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "precio_historial" (
    "id" SERIAL NOT NULL,
    "producto_id" INTEGER NOT NULL,
    "precio_anterior" DECIMAL(10,2),
    "precio_nuevo" DECIMAL(10,2) NOT NULL,
    "motivo" VARCHAR(200),
    "usuario_id" INTEGER,
    "fecha_cambio" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "precio_historial_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "clientes" (
    "id" SERIAL NOT NULL,
    "dni" VARCHAR(20),
    "nombres" VARCHAR(100) NOT NULL,
    "apellidos" VARCHAR(100),
    "telefono" VARCHAR(20),
    "email" VARCHAR(100),
    "fecha_nacimiento" DATE,
    "alergias" TEXT,
    "enfermedades_cronicas" TEXT,
    "puntos_fidelizacion" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ventas" (
    "id" SERIAL NOT NULL,
    "numero_ticket" VARCHAR(20) NOT NULL,
    "cliente_id" INTEGER,
    "subtotal" DECIMAL(10,2) NOT NULL,
    "igv" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "total" DECIMAL(10,2) NOT NULL,
    "metodo_pago" "MetodoPago" NOT NULL,
    "monto_pagado" DECIMAL(10,2),
    "vuelto" DECIMAL(10,2),
    "estado" "EstadoVenta" NOT NULL DEFAULT 'COMPLETADA',
    "usuario_id" INTEGER,
    "observaciones" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ventas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "detalle_venta" (
    "id" SERIAL NOT NULL,
    "venta_id" INTEGER NOT NULL,
    "producto_id" INTEGER NOT NULL,
    "lote_id" INTEGER NOT NULL,
    "cantidad" INTEGER NOT NULL,
    "precio_unitario" DECIMAL(10,2) NOT NULL,
    "descuento" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "detalle_venta_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "alertas_stock" (
    "id" SERIAL NOT NULL,
    "producto_id" INTEGER NOT NULL,
    "stock_minimo_override" INTEGER,
    "stock_maximo_override" INTEGER,
    "notificar_email" VARCHAR(100),
    "ultima_notificacion" TIMESTAMP(3),
    "activa" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "alertas_stock_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "usuarios" (
    "id" SERIAL NOT NULL,
    "username" VARCHAR(50) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "nombre_completo" VARCHAR(100) NOT NULL,
    "rol" "RolUsuario" NOT NULL,
    "email" VARCHAR(100) NOT NULL,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "ultimo_acceso" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "laboratorios_nombre_key" ON "laboratorios"("nombre");

-- CreateIndex
CREATE UNIQUE INDEX "categorias_nombre_key" ON "categorias"("nombre");

-- CreateIndex
CREATE UNIQUE INDEX "presentaciones_nombre_key" ON "presentaciones"("nombre");

-- CreateIndex
CREATE UNIQUE INDEX "productos_codigo_barras_key" ON "productos"("codigo_barras");

-- CreateIndex
CREATE INDEX "productos_nombre_comercial_idx" ON "productos"("nombre_comercial");

-- CreateIndex
CREATE INDEX "productos_principio_activo_idx" ON "productos"("principio_activo");

-- CreateIndex
CREATE INDEX "productos_laboratorio_id_idx" ON "productos"("laboratorio_id");

-- CreateIndex
CREATE INDEX "productos_activo_idx" ON "productos"("activo");

-- CreateIndex
CREATE INDEX "lotes_fecha_vencimiento_stock_actual_idx" ON "lotes"("fecha_vencimiento", "stock_actual");

-- CreateIndex
CREATE UNIQUE INDEX "lotes_producto_id_numero_lote_key" ON "lotes"("producto_id", "numero_lote");

-- CreateIndex
CREATE UNIQUE INDEX "clientes_dni_key" ON "clientes"("dni");

-- CreateIndex
CREATE INDEX "clientes_dni_idx" ON "clientes"("dni");

-- CreateIndex
CREATE UNIQUE INDEX "ventas_numero_ticket_key" ON "ventas"("numero_ticket");

-- CreateIndex
CREATE INDEX "ventas_created_at_idx" ON "ventas"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "alertas_stock_producto_id_key" ON "alertas_stock"("producto_id");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_username_key" ON "usuarios"("username");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_email_key" ON "usuarios"("email");

-- AddForeignKey
ALTER TABLE "productos" ADD CONSTRAINT "productos_laboratorio_id_fkey" FOREIGN KEY ("laboratorio_id") REFERENCES "laboratorios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "productos" ADD CONSTRAINT "productos_categoria_id_fkey" FOREIGN KEY ("categoria_id") REFERENCES "categorias"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "productos" ADD CONSTRAINT "productos_presentacion_id_fkey" FOREIGN KEY ("presentacion_id") REFERENCES "presentaciones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lotes" ADD CONSTRAINT "lotes_producto_id_fkey" FOREIGN KEY ("producto_id") REFERENCES "productos"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "precio_historial" ADD CONSTRAINT "precio_historial_producto_id_fkey" FOREIGN KEY ("producto_id") REFERENCES "productos"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ventas" ADD CONSTRAINT "ventas_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "clientes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "detalle_venta" ADD CONSTRAINT "detalle_venta_venta_id_fkey" FOREIGN KEY ("venta_id") REFERENCES "ventas"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "detalle_venta" ADD CONSTRAINT "detalle_venta_producto_id_fkey" FOREIGN KEY ("producto_id") REFERENCES "productos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "detalle_venta" ADD CONSTRAINT "detalle_venta_lote_id_fkey" FOREIGN KEY ("lote_id") REFERENCES "lotes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "alertas_stock" ADD CONSTRAINT "alertas_stock_producto_id_fkey" FOREIGN KEY ("producto_id") REFERENCES "productos"("id") ON DELETE CASCADE ON UPDATE CASCADE;
