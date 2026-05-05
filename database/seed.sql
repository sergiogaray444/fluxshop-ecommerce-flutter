-- =====================================================
-- FluxShop - Datos de ejemplo (seed)
-- Ejecutar después de schema.sql
-- =====================================================

-- Si ya ejecutaste el seed antes, limpia primero:
-- DELETE FROM order_items; DELETE FROM orders; DELETE FROM products;
-- ALTER SEQUENCE products_id_seq RESTART WITH 1;

-- Productos tech con precios en COP e imágenes de assets locales
INSERT INTO products (name, description, price, image_url, category, stock) VALUES
(
    'Laptop Lenovo IdeaPad 3',
    'Procesador Intel Core i5 12ª gen, 8GB RAM, 512GB SSD. Pantalla 15.6" Full HD. Perfecta para estudio y trabajo profesional.',
    2899000,
    'assets/images/products/laptop.jpg',
    'Portátiles',
    10
),
(
    'Samsung Galaxy A55',
    'Pantalla Super AMOLED 6.6", triple cámara 50MP, 8GB RAM y batería 5000mAh con carga rápida de 25W.',
    1499000,
    'assets/images/products/smartphone.jpg',
    'Smartphones',
    15
),
(
    'Audífonos Sony WH-1000XM5',
    'Cancelación activa de ruido líder en la industria, 30h de batería, Hi-Res Audio y micrófono con IA integrada.',
    1199000,
    'assets/images/products/headphones.jpg',
    'Audio',
    20
),
(
    'iPad 10ª Generación',
    'Pantalla Liquid Retina 10.9", chip A14 Bionic, 64GB almacenamiento y conector USB-C. Compatible con Apple Pencil.',
    2299000,
    'assets/images/products/tablet.jpg',
    'Tablets',
    8
),
(
    'Monitor LG 24" Full HD',
    'Panel IPS 75Hz, resolución 1920×1080, entradas HDMI y VGA. Colores precisos y amplio ángulo de visión para home office.',
    699000,
    'assets/images/products/monitor.jpg',
    'Monitores',
    12
),
(
    'Teclado Mecánico Redragon K552',
    'Switches Outemu Blue, retroiluminación LED roja, diseño compacto TKL y base metálica resistente. Ideal para gaming y programación.',
    189000,
    'assets/images/products/keyboard.jpg',
    'Periféricos',
    30
),
(
    'Mouse Logitech MX Master 3S',
    'Sensor 8000 DPI, scroll MagSpeed electromagnético, conexión USB o Bluetooth. Diseño ergonómico para uso prolongado.',
    399000,
    'assets/images/products/mouse.jpg',
    'Periféricos',
    25
),
(
    'Smartwatch Samsung Galaxy Watch 6',
    'Pantalla Super AMOLED 1.5", monitor de salud 24/7, GPS integrado, resistencia al agua 5ATM y batería de hasta 40 horas.',
    799000,
    'assets/images/products/smartwatch.jpg',
    'Wearables',
    14
);

-- Usuario de prueba para desarrollo
-- IMPORTANTE: En producción se debe hashear la contraseña con bcrypt
INSERT INTO users (name, email, password, phone, address) VALUES
(
    'Usuario Demo',
    'demo@fluxshop.com',
    'demo1234',
    '+57 300 123 4567',
    'Calle 123 #45-67, Bogotá, Colombia'
);
