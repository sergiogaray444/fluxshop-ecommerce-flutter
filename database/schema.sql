-- =====================================================
-- FluxShop - Esquema de base de datos PostgreSQL
-- Proyecto Final: Aplicaciones Móviles con Flutter
-- =====================================================

-- Crear la base de datos (ejecutar como superusuario)
-- CREATE DATABASE fluxshop;

-- =====================================================
-- Tabla: users
-- Almacena los usuarios registrados en la aplicación
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100)  NOT NULL,
    email      VARCHAR(150)  UNIQUE NOT NULL,
    password   VARCHAR(255)  NOT NULL,
    phone      VARCHAR(20),
    address    TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Tabla: products
-- Catálogo de productos disponibles en la tienda
-- =====================================================
CREATE TABLE IF NOT EXISTS products (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(200)   NOT NULL,
    description TEXT,
    price       DECIMAL(10, 2) NOT NULL,
    image_url   VARCHAR(500),
    category    VARCHAR(100),
    stock       INTEGER        DEFAULT 0,
    created_at  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Tabla: orders
-- Cabecera de cada compra realizada por un usuario
-- =====================================================
CREATE TABLE IF NOT EXISTS orders (
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total      DECIMAL(10, 2) NOT NULL,
    status     VARCHAR(50)    DEFAULT 'confirmed',
    created_at TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Tabla: order_items
-- Productos incluidos en cada orden
-- El unit_price guarda el precio al momento de la compra
-- (el precio del producto puede cambiar después)
-- =====================================================
CREATE TABLE IF NOT EXISTS order_items (
    id         SERIAL PRIMARY KEY,
    order_id   INTEGER        NOT NULL REFERENCES orders(id)   ON DELETE CASCADE,
    product_id INTEGER        NOT NULL REFERENCES products(id),
    quantity   INTEGER        NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);
