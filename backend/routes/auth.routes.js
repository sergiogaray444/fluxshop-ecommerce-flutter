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

// POST /auth/oauth — Login/registro simulado con Google o Facebook
router.post('/oauth', async (req, res) => {
  const { provider, name, email } = req.body;

  if (!provider || !email || !name) {
    return res.status(400).json({ message: 'Datos OAuth incompletos' });
  }

  try {
    // Buscar si el usuario ya existe
    const existing = await pool.query(
      'SELECT id, name, apellidos, username, email, phone, address, provider FROM users WHERE email = $1',
      [email]
    );

    if (existing.rows.length > 0) {
      const user = existing.rows[0];
      const { accessToken, refreshToken } = generateTokens(user.id);
      return res.json({ user, accessToken, refreshToken });
    }

    // Crear usuario nuevo con provider
    const username = email.split('@')[0].toLowerCase().replace(/[^a-z0-9]/g, '') + Math.floor(Math.random() * 999);
    const result = await pool.query(
      `INSERT INTO users (name, apellidos, username, email, password, provider)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, name, apellidos, username, email, phone, address, provider`,
      [name, '', username, email, 'oauth_user_no_password', provider]
    );

    const user = result.rows[0];
    const { accessToken, refreshToken } = generateTokens(user.id);
    res.status(201).json({ user, accessToken, refreshToken });
  } catch (err) {
    console.error('Error en OAuth:', err.message);
    res.status(500).json({ message: 'Error en autenticación OAuth' });
  }
});

// PUT /auth/change-password — Cambiar contraseña (requiere token)
router.put('/change-password', require('../middleware/auth'), async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  const userId = req.user.userId;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ message: 'Se requieren ambas contraseñas' });
  }
  if (newPassword.length < 8) {
    return res.status(400).json({ message: 'La nueva contraseña debe tener al menos 8 caracteres' });
  }

  try {
    const result = await pool.query('SELECT password FROM users WHERE id = $1', [userId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    const isValid = await bcrypt.compare(currentPassword, result.rows[0].password);
    if (!isValid) {
      return res.status(401).json({ message: 'La contraseña actual es incorrecta' });
    }

    const hashedNew = await bcrypt.hash(newPassword, 10);
    await pool.query('UPDATE users SET password = $1 WHERE id = $2', [hashedNew, userId]);
    res.json({ message: 'Contraseña actualizada correctamente' });
  } catch (err) {
    console.error('Error al cambiar contraseña:', err.message);
    res.status(500).json({ message: 'Error al cambiar la contraseña' });
  }
});

module.exports = router;
