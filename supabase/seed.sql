-- ============================================================================
-- SEED DATA: seed.sql
-- SYSTEM: Production Seed Data for Mie Gacoan Sidoarjo Pabean
-- ============================================================================

-- 1. SEED DEFAULT BRANCH
INSERT INTO public.branches (id, code, name, address, phone, is_active)
VALUES (
    'b0000000-0000-0000-0000-000000000001'::uuid,
    'GCN-SDA-01',
    'Mie Gacoan - Sidoarjo Pabean',
    'Jl. Raya Pabean No. 88, Sedati, Sidoarjo',
    '0812-3456-7890',
    true
)
ON CONFLICT (code) DO NOTHING;

-- 2. SEED TABLES (Table 01 - Table 10)
INSERT INTO public.tables (branch_id, table_number, capacity, status)
VALUES
    ('b0000000-0000-0000-0000-000000000001'::uuid, 'Table 01', 2, 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000001'::uuid, 'Table 02', 2, 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000001'::uuid, 'Table 03', 4, 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000001'::uuid, 'Table 04', 4, 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000001'::uuid, 'Table 05', 4, 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000001'::uuid, 'Table 06', 6, 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000001'::uuid, 'Table 07', 6, 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000001'::uuid, 'Table 08', 8, 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000001'::uuid, 'Table 09', 4, 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000001'::uuid, 'Table 10', 4, 'AVAILABLE')
ON CONFLICT (branch_id, table_number) DO NOTHING;

-- 3. SEED CATEGORIES
INSERT INTO public.categories (id, name, slug, display_order, is_active)
VALUES
    ('c0000000-0000-0000-0000-000000000001'::uuid, 'Mie', 'mie', 1, true),
    ('c0000000-0000-0000-0000-000000000002'::uuid, 'Dimsum', 'dimsum', 2, true),
    ('c0000000-0000-0000-0000-000000000003'::uuid, 'Minuman', 'minuman', 3, true),
    ('c0000000-0000-0000-0000-000000000004'::uuid, 'Snack', 'snack', 4, true),
    ('c0000000-0000-0000-0000-000000000005'::uuid, 'Paket', 'paket', 5, true)
ON CONFLICT (slug) DO NOTHING;

-- 4. SEED PRODUCTS (15+ ITEMS)
INSERT INTO public.products (id, category_id, name, slug, description, image_url, base_price, is_active, is_available)
VALUES
    -- MIE
    ('p0000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, 'Mie Hompimpa', 'mie-hompimpa', 'Mie pedas gurih asin lezat dengan taburan ayam cincang & pangsit goreng krispi.', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&auto=format&fit=crop&q=60', 10000, true, true),
    ('p0000000-0000-0000-0000-000000000002'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, 'Mie Gacoan', 'mie-gacoan', 'Mie pedas manis favorit dengan bumbu istimewa, taburan ayam & pangsit krispi.', 'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=500&auto=format&fit=crop&q=60', 10000, true, true),
    ('p0000000-0000-0000-0000-000000000003'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, 'Mie Suit', 'mie-suit', 'Mie gurih tanpa pedas cocok untuk anak & penyuka rasa original.', 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=500&auto=format&fit=crop&q=60', 10000, true, true),

    -- DIMSUM
    ('p0000000-0000-0000-0000-000000000004'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, 'Udang Keju', 'udang-keju', 'Dimsum udang olahan renyah di luar dengan lelehan keju mozarella di dalam.', 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=500&auto=format&fit=crop&q=60', 9000, true, true),
    ('p0000000-0000-0000-0000-000000000005'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, 'Udang Rambutan', 'udang-rambutan', 'Bola udang dilapisi kulit pangsit renyah menyerupai buah rambutan.', 'https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?w=500&auto=format&fit=crop&q=60', 9000, true, true),
    ('p0000000-0000-0000-0000-000000000006'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, 'Siomay Udang', 'siomay-udang', 'Siomay kukus lembut berisi olahan udang dan ayam gurih.', 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=500&auto=format&fit=crop&q=60', 9000, true, true),
    ('p0000000-0000-0000-0000-000000000007'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, 'Lumpia Udang', 'lumpia-udang', 'Lumpia goreng isi daging udang olahan spesial rasanya mantap.', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format&fit=crop&q=60', 9000, true, true),
    ('p0000000-0000-0000-0000-000000000008'::uuid, 'c0000000-0000-0000-0000-000000000004'::uuid, 'Pangsit Goreng Extra', 'pangsit-goreng-extra', 'Pangsit renyah jumbo isi ayam gurih pas untuk camilan.', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&auto=format&fit=crop&q=60', 9500, true, true),

    -- MINUMAN
    ('p0000000-0000-0000-0000-000000000009'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Es Gobak Sodor', 'es-gobak-sodor', 'Es buah segar kombinasi jelly, cincau, dan buah tropis manis.', 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=500&auto=format&fit=crop&q=60', 8500, true, true),
    ('p0000000-0000-0000-0000-000000000010'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Es Teklek', 'es-teklek', 'Es racikan spesial sirup cocopandan manis dingin menyegarkan.', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=60', 8500, true, true),
    ('p0000000-0000-0000-0000-000000000011'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Es Sluku Bathok', 'es-sluku-bathok', 'Es susu rasa manis perpaduan jelly kelapa muda segar.', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=60', 8500, true, true),
    ('p0000000-0000-0000-0000-000000000012'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Es Petak Sumpet', 'es-petak-sumpet', 'Es jeruk peras alami manis asam dingin pelepas dahaga.', 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=500&auto=format&fit=crop&q=60', 8500, true, true),
    ('p0000000-0000-0000-0000-000000000013'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Teh Manis Dingin', 'teh-manis-dingin', 'Es teh manis segar pelepas dahaga.', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=500&auto=format&fit=crop&q=60', 4000, true, true),
    ('p0000000-0000-0000-0000-000000000014'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Air Mineral 600ml', 'air-mineral-600ml', 'Air mineral dingin kemasan botol 600ml.', 'https://images.unsplash.com/photo-1560023907-5f313c8754b9?w=500&auto=format&fit=crop&q=60', 4000, true, true),

    -- PAKET
    ('p0000000-0000-0000-0000-000000000015'::uuid, 'c0000000-0000-0000-0000-000000000005'::uuid, 'Paket Mantap Hompimpa', 'paket-mantap-hompimpa', 'Mie Hompimpa + Udang Keju + Es Gobak Sodor (Hemat Rp 2.500)', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&auto=format&fit=crop&q=60', 25000, true, true)
ON CONFLICT (slug) DO NOTHING;

-- 5. SEED INITIAL INVENTORY
INSERT INTO public.inventory (branch_id, product_id, current_stock, min_stock, unit)
SELECT 
    'b0000000-0000-0000-0000-000000000001'::uuid,
    id,
    100,
    15,
    'pcs'
FROM public.products
ON CONFLICT (branch_id, product_id) DO NOTHING;

-- 6. SEED PROMOTIONS
INSERT INTO public.promotions (id, code, name, description, discount_type, discount_value, min_purchase, start_date, end_date, is_active)
VALUES
    (
        'pr000000-0000-0000-0000-000000000001'::uuid,
        'GACOAN10',
        'Diskon 10% Semua Menu',
        'Diskon 10% untuk semua menu mie dan dimsum tanpa batas maksimal.',
        'PERCENTAGE',
        10,
        20000,
        now() - INTERVAL '1 day',
        now() + INTERVAL '30 days',
        true
    ),
    (
        'pr000000-0000-0000-0000-000000000002'::uuid,
        'HEMAT5K',
        'Potongan Hemat Rp 5.000',
        'Potongan harga Rp 5.000 untuk minimal transaksi Rp 30.000.',
        'FIXED_AMOUNT',
        5000,
        30000,
        now() - INTERVAL '1 day',
        now() + INTERVAL '30 days',
        true
    )
ON CONFLICT (code) DO NOTHING;
