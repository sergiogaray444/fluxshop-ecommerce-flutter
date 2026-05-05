require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

// Configuración de conexión a PostgreSQL
// Cambia los valores según tu instalación local
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT),
});

// ====================================================
// AUTH - Registro e inicio de sesión
// ====================================================

// POST /auth/register — Registrar nuevo usuario
app.post('/auth/register', async (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Todos los campos son requeridos' });
  }

  try {
    const existing = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );
    if (existing.rows.length > 0) {
      return res.status(400).json({ message: 'El correo ya está registrado' });
    }

    const result = await pool.query(
      `INSERT INTO users (name, email, password)
       VALUES ($1, $2, $3)
       RETURNING id, name, email, phone, address`,
      [name, email, password]
    );

    res.status(201).json({ user: result.rows[0] });
  } catch (err) {
    console.error('Error en registro:', err.message);
    res.status(500).json({ message: 'Error al registrar usuario' });
  }
});

// POST /auth/login — Iniciar sesión
app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Correo y contraseña son requeridos' });
  }

  try {
    const result = await pool.query(
      `SELECT id, name, email, phone, address
       FROM users
       WHERE email = $1 AND password = $2`,
      [email, password]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Correo o contraseña incorrectos' });
    }

    res.json({ user: result.rows[0] });
  } catch (err) {
    console.error('Error en login:', err.message);
    res.status(500).json({ message: 'Error al iniciar sesión' });
  }
});

// ====================================================
// PRODUCTS - Catálogo de productos
// ====================================================

// GET /products — Listar todos los productos
app.get('/products', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM products ORDER BY id'
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error al obtener productos:', err.message);
    res.status(500).json({ message: 'Error al obtener productos' });
  }
});

// GET /products/:id — Obtener un producto por id
app.get('/products/:id', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM products WHERE id = $1',
      [req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error al obtener producto:', err.message);
    res.status(500).json({ message: 'Error al obtener el producto' });
  }
});

// ====================================================
// USERS - Actualizar perfil de usuario
// ====================================================

// PUT /users/:id — Actualizar nombre, teléfono y dirección
app.put('/users/:id', async (req, res) => {
  const { name, phone, address } = req.body;
  const { id } = req.params;

  if (!name || name.trim().length < 3) {
    return res.status(400).json({ message: 'El nombre debe tener al menos 3 caracteres' });
  }

  try {
    const result = await pool.query(
      `UPDATE users
       SET name = $1, phone = $2, address = $3
       WHERE id = $4
       RETURNING id, name, email, phone, address`,
      [name.trim(), phone || null, address || null, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    res.json({ user: result.rows[0] });
  } catch (err) {
    console.error('Error al actualizar perfil:', err.message);
    res.status(500).json({ message: 'Error al actualizar el perfil' });
  }
});

// ====================================================
// ORDERS - Registro de compras
// ====================================================

// POST /orders — Crear una nueva orden con sus ítems
app.post('/orders', async (req, res) => {
  const { user_id, total, items } = req.body;

  if (!user_id || !total || !items || items.length === 0) {
    return res.status(400).json({ message: 'Datos de la orden incompletos' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Insertar la cabecera de la orden
    const orderResult = await client.query(
      `INSERT INTO orders (user_id, total) VALUES ($1, $2) RETURNING id`,
      [user_id, total]
    );
    const orderId = orderResult.rows[0].id;

    // Insertar cada ítem de la orden
    for (const item of items) {
      await client.query(
        `INSERT INTO order_items (order_id, product_id, quantity, unit_price)
         VALUES ($1, $2, $3, $4)`,
        [orderId, item.product_id, item.quantity, item.unit_price]
      );
    }

    await client.query('COMMIT');
    res.status(201).json({
      message: 'Orden creada exitosamente',
      order_id: orderId,
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error al crear orden:', err.message);
    res.status(500).json({ message: 'Error al crear la orden' });
  } finally {
    client.release();
  }
});

// ====================================================
// Arrancar el servidor
// ====================================================
const PORT = process.env.PORT ?? 3000;
app.listen(PORT, () => {
  console.log(`Servidor FluxShop corriendo en http://localhost:${PORT}`);
});
