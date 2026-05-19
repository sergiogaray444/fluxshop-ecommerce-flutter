const router = require('express').Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db');

const generateTokens = (userId) => {
  const accessToken = jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: '2h' }
  );
  const refreshToken = jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
  );
  return { accessToken, refreshToken };
};

// POST /auth/register
router.post('/register', async (req, res) => {
  const { name, apellidos, username, email, password } = req.body;

  if (!name || !apellidos || !username || !email || !password) {
    return res.status(400).json({ message: 'Todos los campos son requeridos' });
  }
  if (password.length < 8) {
    return res.status(400).json({ message: 'La contraseña debe tener al menos 8 caracteres' });
  }

  try {
    const emailCheck = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (emailCheck.rows.length > 0) {
      return res.status(400).json({ message: 'El correo ya está registrado' });
    }

    const usernameCheck = await pool.query('SELECT id FROM users WHERE username = $1', [username]);
    if (usernameCheck.rows.length > 0) {
      return res.status(400).json({ message: 'El nombre de usuario ya está en uso' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO users (name, apellidos, username, email, password)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, name, apellidos, username, email, phone, address`,
      [name, apellidos, username, email, hashedPassword]
    );

    const user = result.rows[0];
    const { accessToken, refreshToken } = generateTokens(user.id);

    res.status(201).json({ user, accessToken, refreshToken });
  } catch (err) {
    console.error('Error en registro:', err.message);
    res.status(500).json({ message: 'Error al registrar usuario' });
  }
});

// POST /auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Correo y contraseña son requeridos' });
  }

  try {
    const result = await pool.query(
      `SELECT id, name, apellidos, username, email, phone, address, password
       FROM users WHERE email = $1`,
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Correo o contraseña incorrectos' });
    }

    const user = result.rows[0];
    const isValid = await bcrypt.compare(password, user.password);

    if (!isValid) {
      return res.status(401).json({ message: 'Correo o contraseña incorrectos' });
    }

    const { password: _, ...userWithoutPassword } = user;
    const { accessToken, refreshToken } = generateTokens(user.id);

    res.json({ user: userWithoutPassword, accessToken, refreshToken });
  } catch (err) {
    console.error('Error en login:', err.message);
    res.status(500).json({ message: 'Error al iniciar sesión' });
  }
});

// POST /auth/refresh
router.post('/refresh', async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return res.status(400).json({ message: 'Refresh token requerido' });
  }

  try {
    const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);
    const { accessToken, refreshToken: newRefreshToken } = generateTokens(decoded.userId);
    res.json({ accessToken, refreshToken: newRefreshToken });
  } catch (err) {
    return res.status(401).json({ message: 'Refresh token inválido o expirado' });
  }
});

module.exports = router;
