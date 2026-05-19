-- FluxShop — Actualizar imágenes de productos con URLs de Unsplash
-- Ejecutar en psql: psql -U postgres -d fluxshop -f database/update_product_images.sql

UPDATE products SET image_url = 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600&q=80' WHERE id = 1;
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&q=80' WHERE id = 2;
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80' WHERE id = 3;
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1544244015-0df4cec50d37?w=600&q=80' WHERE id = 4;
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=600&q=80' WHERE id = 5;
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&q=80' WHERE id = 6;
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=600&q=80' WHERE id = 7;
UPDATE products SET image_url = 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80' WHERE id = 8;
