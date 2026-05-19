const router = require('express').Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// GET /products
router.get('/', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products ORDER BY id');
    res.json(result.rows);
  } catch (err) {
    console.error('Error al obtener productos:', err.message);
    res.status(500).json({ message: 'Error al obtener productos' });
  }
});

// GET /products/:id
router.get('/:id', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error al obtener producto:', err.message);
    res.status(500).json({ message: 'Error al obtener el producto' });
  }
});

module.exports = router;
