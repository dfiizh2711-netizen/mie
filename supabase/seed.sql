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
    ('f0000000-0000-0000-0000-000000000001'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, 'Mie Hompimpa', 'mie-hompimpa', 'Mie pedas gurih asin lezat dengan taburan ayam cincang & pangsit goreng krispi.', 'asset/miehompimpa.webp', 10000, true, true),
    ('f0000000-0000-0000-0000-000000000002'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, 'Mie Gacoan', 'mie-gacoan', 'Mie pedas manis favorit dengan bumbu istimewa, taburan ayam & pangsit krispi.', 'asset/mie gacoan.webp', 10000, true, true),
    ('f0000000-0000-0000-0000-000000000003'::uuid, 'c0000000-0000-0000-0000-000000000001'::uuid, 'Mie Suit', 'mie-suit', 'Mie gurih tanpa pedas cocok untuk anak & penyuka rasa original.', 'asset/miesuit.webp', 10000, true, true),

    -- DIMSUM
    ('f0000000-0000-0000-0000-000000000004'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, 'Udang Keju', 'udang-keju', 'Dimsum udang olahan renyah di luar dengan lelehan keju mozarella di dalam.', 'asset/udangkeju.webp', 9000, true, true),
    ('f0000000-0000-0000-0000-000000000005'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, 'Udang Rambutan', 'udang-rambutan', 'Bola udang dilapisi kulit pangsit renyah menyerupai buah rambutan.', 'asset/udahngrambutan.webp', 9000, true, true),
    ('f0000000-0000-0000-0000-000000000006'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, 'Siomay Udang', 'siomay-udang', 'Siomay kukus lembut berisi olahan udang dan ayam gurih.', 'asset/siomay.webp', 9000, true, true),
    ('f0000000-0000-0000-0000-000000000007'::uuid, 'c0000000-0000-0000-0000-000000000002'::uuid, 'Lumpia Udang', 'lumpia-udang', 'Lumpia goreng isi daging udang olahan spesial rasanya mantap.', 'asset/lumpiaudang.webp', 9000, true, true),
    ('f0000000-0000-0000-0000-000000000008'::uuid, 'c0000000-0000-0000-0000-000000000004'::uuid, 'Pangsit Goreng Extra', 'pangsit-goreng-extra', 'Pangsit renyah jumbo isi ayam gurih pas untuk camilan.', 'asset/pangsitgoreng.webp', 9500, true, true),

    -- MINUMAN
    ('f0000000-0000-0000-0000-000000000009'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Es Gobak Sodor', 'es-gobak-sodor', 'Es buah segar kombinasi jelly, cincau, dan buah tropis manis.', 'asset/esgobaksodor.webp', 8500, true, true),
    ('f0000000-0000-0000-0000-000000000010'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Es Teklek', 'es-teklek', 'Es racikan spesial sirup thai tea manis dingin menyegarkan.', 'asset/thaitea.webp', 8500, true, true),
    ('f0000000-0000-0000-0000-000000000011'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Es Sluku Bathok', 'es-sluku-bathok', 'Es thai green tea segar manis creamy.', 'asset/thaigreentea.webp', 8500, true, true),
    ('f0000000-0000-0000-0000-000000000012'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Es Petak Sumpet', 'es-petak-sumpet', 'Es jeruk peras alami manis asam dingin pelepas dahaga.', 'asset/orange.webp', 8500, true, true),
    ('f0000000-0000-0000-0000-000000000013'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Teh Manis Dingin', 'teh-manis-dingin', 'Es teh manis segar pelepas dahaga.', 'asset/Tea.webp', 4000, true, true),
    ('f0000000-0000-0000-0000-000000000014'::uuid, 'c0000000-0000-0000-0000-000000000003'::uuid, 'Air Mineral 600ml', 'air-mineral-600ml', 'Air mineral dingin kemasan botol 600ml.', 'asset/airmineral.webp', 4000, true, true),

    -- PAKET
    ('f0000000-0000-0000-0000-000000000015'::uuid, 'c0000000-0000-0000-0000-000000000005'::uuid, 'Paket Mantap Hompimpa', 'paket-mantap-hompimpa', 'Mie Hompimpa + Udang Keju + Es Gobak Sodor (Hemat Rp 2.500)', 'asset/hero-banner.png', 25000, true, true)
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
        'e0000000-0000-0000-0000-000000000001'::uuid,
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
        'e0000000-0000-0000-0000-000000000002'::uuid,
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
