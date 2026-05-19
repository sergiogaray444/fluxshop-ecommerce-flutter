const router = require('express').Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// PUT /users/:id
router.put('/:id', auth, async (req, res) => {
  const { name, apellidos, username, phone, address } = req.body;
  const { id } = req.params;

  if (!name || name.trim().length < 3) {
    return res.status(400).json({ message: 'El nombre debe tener al menos 3 caracteres' });
  }

  try {
    // Verificar que el username no esté tomado por otro usuario
    if (username) {
      const usernameCheck = await pool.query(
        'SELECT id FROM users WHERE username = $1 AND id != $2',
        [username.trim(), id]
      );
      if (usernameCheck.rows.length > 0) {
        return res.status(400).json({ message: 'El nombre de usuario ya está en uso' });
      }
    }

    const result = await pool.query(
      `UPDATE users
       SET name = $1, apellidos = $2, username = $3, phone = $4, address = $5
       WHERE id = $6
       RETURNING id, name, apellidos, username, email, phone, address`,
      [name.trim(), apellidos || null, username?.trim() || null, phone || null, address || null, id]
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

module.exports = router;
