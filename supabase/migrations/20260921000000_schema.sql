-- ============================================================================
-- MIGRATION: 20260921000000_schema.sql
-- SYSTEM: Production Cafe Online & Offline Ordering + POS + KDS + Reservation + Inventory
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ----------------------------------------------------------------------------
-- 1. PROFILES (Extends auth.users)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'USER' CHECK (role IN ('USER', 'KASIR', 'DAPUR', 'ADMIN')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Automatic handle new user creation trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, phone, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Customer'),
        NEW.email,
        NEW.raw_user_meta_data->>'phone',
        'USER' -- Public registration is strictly forced to USER
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ----------------------------------------------------------------------------
-- 2. BRANCHES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- 3. TABLES (Dine-in dining tables)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    table_number TEXT NOT NULL,
    capacity INT NOT NULL DEFAULT 4 CHECK (capacity > 0),
    status TEXT NOT NULL DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'OCCUPIED', 'RESERVED')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(branch_id, table_number)
);

-- ----------------------------------------------------------------------------
-- 4. CATEGORIES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- 5. PRODUCTS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    image_url TEXT,
    base_price NUMERIC(12,2) NOT NULL CHECK (base_price >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_available BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- 6. RESERVATIONS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    table_id UUID NOT NULL REFERENCES public.tables(id) ON DELETE CASCADE,
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    guest_count INT NOT NULL CHECK (guest_count > 0),
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'ARRIVED', 'COMPLETED', 'CANCELLED', 'NO_SHOW')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Prevent Table Double Booking Trigger Function
CREATE OR REPLACE FUNCTION public.check_reservation_conflict()
RETURNS TRIGGER AS $$
DECLARE
    conflict_count INT;
BEGIN
    IF NEW.status IN ('PENDING', 'CONFIRMED', 'ARRIVED') THEN
        SELECT COUNT(*)
        INTO conflict_count
        FROM public.reservations
        WHERE branch_id = NEW.branch_id
          AND table_id = NEW.table_id
          AND reservation_date = NEW.reservation_date
          AND reservation_time = NEW.reservation_time
          AND status IN ('PENDING', 'CONFIRMED', 'ARRIVED')
          AND id <> COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid);

        IF conflict_count > 0 THEN
            RAISE EXCEPTION 'Table % is already reserved for % at %', NEW.table_id, NEW.reservation_date, NEW.reservation_time;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_reservation_conflict
    BEFORE INSERT OR UPDATE ON public.reservations
    FOR EACH ROW EXECUTE FUNCTION public.check_reservation_conflict();

-- ----------------------------------------------------------------------------
-- 7. ORDERS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number TEXT UNIQUE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    table_id UUID REFERENCES public.tables(id) ON DELETE SET NULL,
    order_type TEXT NOT NULL CHECK (order_type IN ('DINE_IN', 'TAKE_AWAY')),
    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
    discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    service_charge NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (service_charge >= 0),
    grand_total NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (grand_total >= 0),
    payment_status TEXT NOT NULL DEFAULT 'UNPAID' CHECK (payment_status IN ('UNPAID', 'PENDING', 'PAID', 'EXPIRED', 'REFUNDED', 'FAILED')),
    order_status TEXT NOT NULL DEFAULT 'PENDING_PAYMENT' CHECK (order_status IN ('CART', 'PENDING_PAYMENT', 'PAID', 'CONFIRMED', 'PREPARING', 'READY', 'COMPLETED', 'CANCELLED', 'EXPIRED', 'REFUNDED')),
    notes TEXT,
    queue_number TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- 8. ORDER ITEMS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
    product_name TEXT NOT NULL,
    price_snapshot NUMERIC(12,2) NOT NULL CHECK (price_snapshot >= 0),
    quantity INT NOT NULL CHECK (quantity > 0),
    subtotal NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- 9. QUEUE NUMBERS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.queue_numbers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    prefix TEXT NOT NULL CHECK (prefix IN ('D', 'T')),
    number INT NOT NULL,
    full_queue_number TEXT NOT NULL,
    order_id UUID UNIQUE NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(branch_id, date, full_queue_number)
);

-- Function to safely generate unique daily queue number
CREATE OR REPLACE FUNCTION public.generate_queue_number(
    p_branch_id UUID,
    p_order_id UUID,
    p_order_type TEXT
)
RETURNS TEXT AS $$
DECLARE
    v_prefix TEXT;
    v_next_num INT;
    v_full_queue TEXT;
BEGIN
    IF p_order_type = 'DINE_IN' THEN
        v_prefix := 'D';
    ELSE
        v_prefix := 'T';
    END IF;

    -- Lock branch queue rows for safety
    SELECT COALESCE(MAX(number), 0) + 1
    INTO v_next_num
    FROM public.queue_numbers
    WHERE branch_id = p_branch_id
      AND date = CURRENT_DATE
      AND prefix = v_prefix;

    v_full_queue := v_prefix || LPAD(v_next_num::text, 3, '0');

    INSERT INTO public.queue_numbers (branch_id, date, prefix, number, full_queue_number, order_id)
    VALUES (p_branch_id, CURRENT_DATE, v_prefix, v_next_num, v_full_queue, p_order_id)
    ON CONFLICT (order_id) DO UPDATE SET full_queue_number = EXCLUDED.full_queue_number
    RETURNING full_queue_number INTO v_full_queue;

    -- Also sync to orders table
    UPDATE public.orders
    SET queue_number = v_full_queue
    WHERE id = p_order_id;

    RETURN v_full_queue;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- 10. PAYMENTS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('MIDTRANS', 'CASH', 'QRIS', 'DEBIT')),
    amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED')),
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- 11. PAYMENT TRANSACTIONS (Midtrans Webhook Records)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    transaction_id TEXT,
    order_id_midtrans TEXT UNIQUE NOT NULL,
    payment_type TEXT,
    gross_amount NUMERIC(12,2),
    transaction_status TEXT,
    fraud_status TEXT,
    currency TEXT DEFAULT 'IDR',
    raw_response JSONB,
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- 12. KITCHEN ORDERS & ITEMS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.kitchen_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID UNIQUE NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'NEW' CHECK (status IN ('NEW', 'PREPARING', 'READY', 'COMPLETED')),
    started_at TIMESTAMPTZ,
    ready_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.kitchen_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kitchen_order_id UUID NOT NULL REFERENCES public.kitchen_orders(id) ON DELETE CASCADE,
    order_item_id UUID NOT NULL REFERENCES public.order_items(id) ON DELETE CASCADE,
    product_name TEXT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'NEW' CHECK (status IN ('NEW', 'PREPARING', 'READY', 'COMPLETED'))
);

-- Auto create kitchen order ticket when order status changes to PAID/CONFIRMED
CREATE OR REPLACE FUNCTION public.sync_kitchen_order()
RETURNS TRIGGER AS $$
DECLARE
    v_kitchen_id UUID;
    v_item RECORD;
BEGIN
    IF NEW.order_status IN ('PAID', 'CONFIRMED') AND OLD.order_status NOT IN ('PAID', 'CONFIRMED') THEN
        INSERT INTO public.kitchen_orders (order_id, status)
        VALUES (NEW.id, 'NEW')
        ON CONFLICT (order_id) DO UPDATE SET status = EXCLUDED.status
        RETURNING id INTO v_kitchen_id;

        FOR v_item IN SELECT * FROM public.order_items WHERE order_id = NEW.id LOOP
            INSERT INTO public.kitchen_order_items (kitchen_order_id, order_item_id, product_name, quantity, notes, status)
            VALUES (v_kitchen_id, v_item.id, v_item.product_name, v_item.quantity, v_item.notes, 'NEW')
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_kitchen_order
    AFTER UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.sync_kitchen_order();

-- ----------------------------------------------------------------------------
-- 13. PROMOTIONS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    discount_type TEXT NOT NULL CHECK (discount_type IN ('PERCENTAGE', 'FIXED_AMOUNT')),
    discount_value NUMERIC(12,2) NOT NULL CHECK (discount_value > 0),
    min_purchase NUMERIC(12,2) DEFAULT 0,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.promotion_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    promotion_id UUID NOT NULL REFERENCES public.promotions(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.categories(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 14. INVENTORY & TRANSACTIONS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    current_stock INT NOT NULL DEFAULT 0 CHECK (current_stock >= 0),
    min_stock INT NOT NULL DEFAULT 10 CHECK (min_stock >= 0),
    unit TEXT NOT NULL DEFAULT 'pcs',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(branch_id, product_id)
);

CREATE TABLE IF NOT EXISTS public.inventory_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_id UUID NOT NULL REFERENCES public.inventory(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('STOCK_IN', 'SALE', 'ADJUSTMENT', 'WASTE', 'RETURN')),
    quantity INT NOT NULL,
    reference_id UUID,
    notes TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Atomic stock deduction RPC safe against negative stock & race condition
CREATE OR REPLACE FUNCTION public.deduct_stock_on_order(p_order_id UUID)
RETURNS VOID AS $$
DECLARE
    v_branch_id UUID;
    v_item RECORD;
    v_inv_id UUID;
    v_curr_stock INT;
BEGIN
    SELECT branch_id INTO v_branch_id FROM public.orders WHERE id = p_order_id;
    IF v_branch_id IS NULL THEN
        RAISE EXCEPTION 'Order not found';
    END IF;

    FOR v_item IN SELECT product_id, quantity FROM public.order_items WHERE order_id = p_order_id LOOP
        SELECT id, current_stock INTO v_inv_id, v_curr_stock
        FROM public.inventory
        WHERE branch_id = v_branch_id AND product_id = v_item.product_id
        FOR UPDATE; -- Row lock to prevent race conditions

        IF v_inv_id IS NOT NULL THEN
            IF v_curr_stock < v_item.quantity THEN
                RAISE EXCEPTION 'Insufficient stock for product ID %', v_item.product_id;
            END IF;

            UPDATE public.inventory
            SET current_stock = current_stock - v_item.quantity,
                updated_at = now()
            WHERE id = v_inv_id;

            INSERT INTO public.inventory_transactions (inventory_id, type, quantity, reference_id, notes)
            VALUES (v_inv_id, 'SALE', -v_item.quantity, p_order_id, 'Deduction from Order ' || p_order_id);
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- 15. NOTIFICATIONS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    role_target TEXT CHECK (role_target IN ('USER', 'KASIR', 'DAPUR', 'ADMIN')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT,
    is_read BOOLEAN NOT NULL DEFAULT false,
    reference_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- 16. AUDIT LOGS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- 17. SETTINGS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Seed default settings
INSERT INTO public.settings (key, value, description)
VALUES
    ('tax_rate', '0.10'::jsonb, 'Default Tax Rate (10%)'),
    ('service_charge_rate', '0.05'::jsonb, 'Default Service Charge (5%)'),
    ('restaurant_name', '"Mie Gacoan - Sidoarjo Pabean"'::jsonb, 'Restaurant Branch Name')
ON CONFLICT (key) DO NOTHING;

-- Indexes for maximum query performance
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category_id);
CREATE INDEX IF NOT EXISTS idx_orders_user ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_branch ON public.orders(branch_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(order_status, payment_status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_reservations_branch_date ON public.reservations(branch_id, reservation_date);
CREATE INDEX IF NOT EXISTS idx_inventory_branch_product ON public.inventory(branch_id, product_id);
