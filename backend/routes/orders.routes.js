const router = require('express').Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// POST /orders
router.post('/', auth, async (req, res) => {
  const { user_id, total, items, shipping_address, shipping_city, shipping_zip, payment_method } = req.body;

  if (!user_id || !total || !items || items.length === 0) {
    return res.status(400).json({ message: 'Datos de la orden incompletos' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const orderResult = await client.query(
      `INSERT INTO orders (user_id, total, shipping_address, shipping_city, shipping_zip, payment_method)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
      [user_id, total, shipping_address || null, shipping_city || null, shipping_zip || null, payment_method || 'card']
    );
    const orderId = orderResult.rows[0].id;

    for (const item of items) {
      // Restar stock verificando que sea suficiente (UPDATE condicional)
      const stockResult = await client.query(
        `UPDATE products SET stock = stock - $1
         WHERE id = $2 AND stock >= $1
         RETURNING stock`,
        [item.quantity, item.product_id]
      );

      if (stockResult.rows.length === 0) {
        throw new Error(`Stock insuficiente para uno de los productos. Ajusta la cantidad en el carrito.`);
      }

      await client.query(
        `INSERT INTO order_items (order_id, product_id, quantity, unit_price)
         VALUES ($1, $2, $3, $4)`,
        [orderId, item.product_id, item.quantity, item.unit_price]
      );
    }

    await client.query('COMMIT');
    res.status(201).json({ message: 'Orden creada exitosamente', order_id: orderId });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error al crear orden:', err.message);
    const userMessage = err.message.includes('Stock insuficiente')
      ? err.message
      : 'Error al crear la orden';
    res.status(400).json({ message: userMessage });
  } finally {
    client.release();
  }
});

// GET /orders?user_id=X
router.get('/', auth, async (req, res) => {
  const { user_id } = req.query;

  if (!user_id) {
    return res.status(400).json({ message: 'user_id requerido' });
  }

  try {
    const result = await pool.query(
      `SELECT o.id, o.total, o.status, o.created_at,
              o.shipping_address, o.shipping_city, o.shipping_zip, o.payment_method,
              json_agg(json_build_object(
                'product_id', oi.product_id,
                'product_name', p.name,
                'quantity', oi.quantity,
                'unit_price', oi.unit_price
              ) ORDER BY oi.id) AS items
       FROM orders o
       JOIN order_items oi ON oi.order_id = o.id
       JOIN products p ON p.id = oi.product_id
       WHERE o.user_id = $1
       GROUP BY o.id
       ORDER BY o.created_at DESC`,
      [user_id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error al obtener órdenes:', err.message);
    res.status(500).json({ message: 'Error al obtener órdenes' });
  }
});

module.exports = router;
