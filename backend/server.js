require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/auth',     require('./routes/auth.routes'));
app.use('/products', require('./routes/products.routes'));
app.use('/orders',   require('./routes/orders.routes'));
app.use('/users',    require('./routes/users.routes'));

const PORT = process.env.PORT ?? 3000;
app.listen(PORT, () => {
  console.log(`Servidor FluxShop corriendo en http://localhost:${PORT}`);
});
