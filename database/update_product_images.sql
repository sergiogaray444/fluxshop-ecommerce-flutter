-- =====================================================
-- FluxShop - Actualizar imágenes a assets locales
-- y cambiar producto 8 (SSD) por Smartwatch
-- =====================================================
-- Ejecutar:
-- psql -U postgres -d fluxshop -f database/update_product_images.sql

UPDATE products SET image_url = 'assets/images/products/laptop.jpg'    WHERE id = 1;
UPDATE products SET image_url = 'assets/images/products/smartphone.jpg' WHERE id = 2;
UPDATE products SET image_url = 'assets/images/products/headphones.jpg' WHERE id = 3;
UPDATE products SET image_url = 'assets/images/products/tablet.jpg'     WHERE id = 4;
UPDATE products SET image_url = 'assets/images/products/monitor.jpg'    WHERE id = 5;
UPDATE products SET image_url = 'assets/images/products/keyboard.jpg'   WHERE id = 6;
UPDATE products SET image_url = 'assets/images/products/mouse.jpg'      WHERE id = 7;

UPDATE products
SET name        = 'Smartwatch Samsung Galaxy Watch 6',
    description = 'Pantalla Super AMOLED 1.5", monitor de salud 24/7, GPS integrado, resistencia al agua 5ATM y batería de hasta 40 horas.',
    price       = 799000,
    image_url   = 'assets/images/products/smartwatch.jpg',
    category    = 'Wearables',
    stock       = 14
WHERE id = 8;
