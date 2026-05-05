# FluxShop

E-commerce de tecnología desarrollado en Flutter como proyecto final de la materia **Aplicaciones Móviles**.

---

## Descripción

FluxShop es una aplicación móvil de comercio electrónico enfocada en productos tecnológicos. Permite a los usuarios registrarse, iniciar sesión, explorar un catálogo de productos, agregarlos al carrito y confirmar pedidos. Los datos se persisten en una base de datos PostgreSQL a través de una API REST desarrollada en Node.js.

---

## Tecnologías utilizadas

| Capa | Tecnología |
|------|-----------|
| Frontend | Flutter / Dart |
| Gestión de estado | Provider (ChangeNotifier) |
| Cliente HTTP | Dio |
| Backend | Node.js + Express |
| Base de datos | PostgreSQL |
| Variables de entorno | dotenv |
| Sesión local | SharedPreferences |

---

## Funcionalidades

- Registro e inicio de sesión de usuarios
- Listado de productos tecnológicos con precios en COP
- Detalle de producto con descripción, stock y selector de cantidad
- Carrito de compras con ajuste de cantidades
- Confirmación de pedido registrado en base de datos
- Perfil del usuario con información de cuenta
- Edición de nombre, teléfono y dirección
- Persistencia de sesión entre cierres de la app
- Modo demo con productos de ejemplo cuando el servidor no está disponible

---

## Estructura del proyecto

```
fluxshop/
├── lib/
│   ├── core/
│   │   ├── constants/       # URLs de la API (ApiConstants)
│   │   ├── navigation/      # Rutas nombradas (AppRoutes)
│   │   ├── theme/           # Tema visual de la app (AppTheme)
│   │   ├── utils/           # Utilidades (formatCOP)
│   │   └── widgets/         # Widgets reutilizables (ProductImage)
│   ├── models/              # Modelos de datos (UserModel, ProductModel, CartItemModel)
│   ├── services/            # Llamadas HTTP a la API (AuthService, ProductService, OrderService)
│   ├── providers/           # Estado global con Provider (AuthProvider, ProductProvider, CartProvider...)
│   └── screens/             # Pantallas de la app (login, home, carrito, perfil, etc.)
├── assets/
│   └── images/products/     # Imágenes locales de productos
├── backend/
│   ├── server.js            # API REST con Express
│   ├── .env                 # Credenciales de la BD (no se sube al repositorio)
│   └── .env.example         # Plantilla de configuración
└── database/
    ├── schema.sql           # Estructura de las tablas
    ├── seed.sql             # Datos iniciales (productos y usuario demo)
    └── update_product_images.sql  # Script para actualizar rutas de imágenes
```

---

## Configuración de la base de datos

### 1. Crear la base de datos

Conectarse a PostgreSQL como superusuario y ejecutar:

```sql
CREATE DATABASE fluxshop;
```

### 2. Crear las tablas

```bash
psql -U postgres -d fluxshop -f database/schema.sql
```

### 3. Insertar datos iniciales

```bash
psql -U postgres -d fluxshop -f database/seed.sql
```

### Tablas del sistema

| Tabla | Descripción |
|-------|-------------|
| `users` | Usuarios registrados. Almacena nombre, correo, contraseña, teléfono y dirección. |
| `products` | Catálogo de productos con nombre, descripción, precio, imagen, categoría y stock. |
| `orders` | Cabecera de cada pedido: usuario que compró, total y estado. |
| `order_items` | Detalle de cada pedido: producto, cantidad y precio unitario al momento de la compra. |

---

## Configuración del backend

### 1. Instalar dependencias

```bash
cd backend
npm install
```

### 2. Crear el archivo de variables de entorno

Copiar el archivo de ejemplo y completarlo con los datos de la instalación local:

```bash
cp backend/.env.example backend/.env
```

Contenido del archivo `.env`:

```
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=tu_contraseña
DB_NAME=fluxshop
DB_PORT=5432
PORT=3000
```

> El archivo `.env` **no se sube al repositorio** porque contiene credenciales. Está excluido en `.gitignore`.

### 3. Iniciar el servidor

```bash
node server.js
```

El servidor queda disponible en `http://localhost:3000`.

---

## Ejecución de Flutter

### Instalar dependencias

```bash
flutter pub get
```

### Ejecutar en Chrome

```bash
flutter run -d chrome
```

> Para ejecutar en emulador Android, cambiar `baseUrl` en `lib/core/constants/api_constants.dart` de `http://localhost:3000` a `http://10.0.2.2:3000`.

---

## Usuario demo

El script `seed.sql` crea un usuario de prueba:

| Campo | Valor |
|-------|-------|
| Correo | demo@fluxshop.com |
| Contraseña | demo1234 |

---

## Endpoints de la API

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/auth/register` | Registrar un nuevo usuario |
| POST | `/auth/login` | Iniciar sesión |
| GET | `/products` | Listar todos los productos |
| GET | `/products/:id` | Obtener un producto por ID |
| PUT | `/users/:id` | Actualizar nombre, teléfono y dirección |
| POST | `/orders` | Crear un nuevo pedido con sus ítems |

---

## Notas de desarrollo

- Las contraseñas se almacenan en texto plano por tratarse de un proyecto académico. En un entorno de producción se usaría hashing con bcrypt.
- El proyecto no implementa autenticación basada en tokens (JWT). La sesión se gestiona localmente con SharedPreferences.
- El modo demo muestra 8 productos de ejemplo cuando el backend no está disponible, para permitir la demostración de la interfaz sin conexión.

---

## Sustentación del proyecto

### ¿Qué hace la app?

FluxShop es una tienda en línea de productos tecnológicos. El usuario puede crear una cuenta, iniciar sesión, ver los productos disponibles con sus precios en pesos colombianos, agregar productos al carrito, ajustar cantidades y confirmar la compra. También puede ver y editar su información personal desde la pantalla de perfil. Todos los datos de usuarios, productos y pedidos se almacenan en una base de datos PostgreSQL.

### ¿Por qué se usa un backend?

Flutter es un framework de frontend: su responsabilidad es mostrar la interfaz y manejar la interacción del usuario. Para acceder a una base de datos de manera segura se necesita una capa intermedia (el backend) que reciba las solicitudes, valide los datos y ejecute las consultas SQL. Conectar Flutter directamente a PostgreSQL expondría las credenciales de la base de datos en el código de la app, lo cual representa un riesgo de seguridad inaceptable.

### ¿Por qué Flutter no se conecta directamente a PostgreSQL?

Las apps móviles y web son accesibles por cualquier persona que instale o inspeccione la aplicación. Si las credenciales de la base de datos estuvieran en el código de Flutter, cualquiera podría extraerlas y acceder a todos los datos. El backend actúa como un guardián: Flutter solo tiene acceso a los endpoints definidos, no a la base de datos completa.

### ¿Cómo funciona el flujo de la app?

```
Flutter (UI)
    ↓  petición HTTP con Dio
Node.js / Express (API REST)
    ↓  consulta SQL con pg
PostgreSQL (base de datos)
    ↑  resultado
Node.js  →  responde JSON
    ↑
Flutter  →  actualiza la pantalla
```

1. El usuario realiza una acción en Flutter (por ejemplo, presiona "Confirmar pedido").
2. El `CartProvider` llama al `OrderService`, que usa Dio para hacer un `POST /orders`.
3. Express recibe la petición, valida los datos y ejecuta las consultas SQL dentro de una transacción.
4. PostgreSQL guarda el pedido y devuelve el ID generado.
5. Express responde con JSON y Flutter navega a la pantalla de éxito.

### ¿Cómo se manejan los productos?

Los productos se obtienen con `GET /products`. El `ProductProvider` guarda la lista en memoria y la comparte con las pantallas mediante `context.watch`. Si el backend no está disponible, se usa una lista de productos de ejemplo para demostración.

### ¿Cómo se maneja el carrito?

El carrito vive en el `CartProvider` en memoria. Cada vez que el usuario agrega un producto se actualiza la lista interna y se notifica a las pantallas suscritas. Al confirmar el pedido, se llama al backend y el carrito se vacía.

### ¿Cómo se edita el perfil?

La pantalla `EditProfileScreen` tiene un formulario con los campos nombre, teléfono y dirección. Al guardar, el `AuthProvider` llama a `AuthService.updateUser()`, que hace un `PUT /users/:id`. El backend actualiza la fila en `users` y devuelve el usuario actualizado, que reemplaza la sesión local para reflejar los cambios en toda la app.

---

## Preguntas frecuentes de sustentación

**¿Por qué usaste Provider y no GetX o Bloc?**
Provider es el mecanismo de gestión de estado recomendado en el material del curso. Es suficiente para el tamaño de este proyecto y es la opción que se explicó en clase. GetX y Bloc tienen más funcionalidades pero también más complejidad que no se justifica aquí.

**¿Por qué usaste Dio en lugar del paquete `http`?**
Dio ofrece un manejo de errores más claro a través de `DioException`, permite configurar `baseUrl` y timeouts en un solo lugar, y es el cliente HTTP que se usó en los ejemplos del curso. Con el paquete `http` habría que manejar los errores de forma más manual y repetitiva.

**¿Por qué usaste Node.js y no otro backend?**
Node.js es liviano, fácil de instalar y permite levantar un servidor REST en pocas líneas con Express. Para un proyecto académico es una elección práctica porque el código es directo y no requiere configuración extensa.

**¿Por qué PostgreSQL y no MySQL o SQLite?**
PostgreSQL es un motor de base de datos relacional robusto, gratuito y ampliamente usado en la industria. Soporta múltiples conexiones concurrentes y tiene buen soporte para transacciones, lo cual es importante para el manejo de pedidos donde se insertan varias tablas a la vez.

**¿Cómo se guarda una orden en la base de datos?**
Cuando el usuario confirma el carrito, se hace un `POST /orders` con el `user_id`, el total y la lista de ítems. En el backend, la inserción se realiza dentro de una **transacción**: primero se inserta la cabecera en `orders`, se obtiene el `id` generado, y luego se inserta cada ítem en `order_items` con ese `order_id`. Si cualquier inserción falla, se ejecuta `ROLLBACK` y no se guarda nada parcialmente.

**¿Qué hace el archivo `.env`?**
El `.env` guarda las credenciales de la base de datos fuera del código fuente. Al iniciar el servidor, la librería `dotenv` lee ese archivo y expone los valores como variables de entorno (`process.env.DB_PASSWORD`, etc.). Esto evita que las contraseñas queden visibles en el repositorio de código.

**¿Dónde se editan los datos del usuario?**
En la pantalla `EditProfileScreen`, accesible desde el perfil. Permite modificar el nombre (mínimo 3 caracteres), teléfono y dirección. Los datos se actualizan en PostgreSQL y la sesión local se refresca automáticamente para reflejar los cambios en toda la app.

**¿Qué pasa si el servidor no está corriendo?**
Al intentar cargar productos, el `ProductProvider` captura el error de conexión y activa el modo demo, mostrando 8 productos de ejemplo con un aviso naranja en la pantalla. En login y registro se muestra el mensaje de error al usuario sin alternativa, ya que autenticar sin backend no tendría sentido.

**¿Por qué el precio está en COP y no en dólares?**
Porque la tienda está orientada al mercado colombiano. Los precios se almacenan como números en la base de datos y se formatean con puntos como separadores de miles usando la función `formatCOP()`, que convierte `1499000` en `$1.499.000`.
