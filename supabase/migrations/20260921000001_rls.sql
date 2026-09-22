-- ============================================================================
-- MIGRATION: 20260921000001_rls.sql
-- SYSTEM: Row Level Security (RLS) Policies for Cafe POS Application
-- ============================================================================

-- Helper function to fetch current authenticated user's role safely
CREATE OR REPLACE FUNCTION public.auth_user_role()
RETURNS TEXT AS $$
DECLARE
    v_role TEXT;
BEGIN
    SELECT role INTO v_role
    FROM public.profiles
    WHERE id = auth.uid();

    RETURN COALESCE(v_role, 'USER');
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.queue_numbers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kitchen_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kitchen_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotion_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- PROFILES POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id OR public.auth_user_role() IN ('ADMIN', 'KASIR'));

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can manage all profiles" ON public.profiles
    FOR ALL USING (public.auth_user_role() = 'ADMIN');

-- ----------------------------------------------------------------------------
-- BRANCHES POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Public can view active branches" ON public.branches
    FOR SELECT USING (is_active = true OR public.auth_user_role() IN ('ADMIN', 'KASIR'));

CREATE POLICY "Admin manage branches" ON public.branches
    FOR ALL USING (public.auth_user_role() = 'ADMIN');

-- ----------------------------------------------------------------------------
-- TABLES POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Everyone view tables" ON public.tables
    FOR SELECT USING (true);

CREATE POLICY "Staff manage tables" ON public.tables
    FOR ALL USING (public.auth_user_role() IN ('ADMIN', 'KASIR'));

-- ----------------------------------------------------------------------------
-- CATEGORIES POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Everyone view active categories" ON public.categories
    FOR SELECT USING (is_active = true OR public.auth_user_role() = 'ADMIN');

CREATE POLICY "Admin manage categories" ON public.categories
    FOR ALL USING (public.auth_user_role() = 'ADMIN');

-- ----------------------------------------------------------------------------
-- PRODUCTS POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Everyone view active products" ON public.products
    FOR SELECT USING (is_active = true OR public.auth_user_role() = 'ADMIN');

CREATE POLICY "Admin manage products" ON public.products
    FOR ALL USING (public.auth_user_role() = 'ADMIN');

-- ----------------------------------------------------------------------------
-- RESERVATIONS POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Users view own reservations" ON public.reservations
    FOR SELECT USING (auth.uid() = user_id OR public.auth_user_role() IN ('ADMIN', 'KASIR'));

CREATE POLICY "Users insert reservations" ON public.reservations
    FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL OR public.auth_user_role() IN ('ADMIN', 'KASIR'));

CREATE POLICY "Users update own reservations" ON public.reservations
    FOR UPDATE USING (auth.uid() = user_id OR public.auth_user_role() IN ('ADMIN', 'KASIR'));

-- ----------------------------------------------------------------------------
-- ORDERS POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Users view own orders" ON public.orders
    FOR SELECT USING (true);

CREATE POLICY "Create orders" ON public.orders
    FOR INSERT WITH CHECK (
        auth.uid() = user_id 
        OR user_id IS NULL 
        OR public.auth_user_role() IN ('ADMIN', 'KASIR')
    );

CREATE POLICY "Staff update orders" ON public.orders
    FOR UPDATE USING (
        auth.uid() = user_id 
        OR public.auth_user_role() IN ('ADMIN', 'KASIR', 'DAPUR')
    );

-- ----------------------------------------------------------------------------
-- ORDER ITEMS POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "View order items" ON public.order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders o
            WHERE o.id = order_items.order_id
              AND (o.user_id = auth.uid() OR public.auth_user_role() IN ('ADMIN', 'KASIR', 'DAPUR'))
        )
    );

CREATE POLICY "Insert order items" ON public.order_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders o
            WHERE o.id = order_items.order_id
              AND (o.user_id = auth.uid() OR o.user_id IS NULL OR public.auth_user_role() IN ('ADMIN', 'KASIR'))
        )
    );

-- ----------------------------------------------------------------------------
-- QUEUE NUMBERS POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Everyone view queue numbers" ON public.queue_numbers
    FOR SELECT USING (true);

CREATE POLICY "Staff insert queue numbers" ON public.queue_numbers
    FOR ALL USING (public.auth_user_role() IN ('ADMIN', 'KASIR'));

-- ----------------------------------------------------------------------------
-- KITCHEN ORDERS POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Kitchen and staff view kitchen orders" ON public.kitchen_orders
    FOR SELECT USING (true);

CREATE POLICY "Kitchen and staff insert kitchen orders" ON public.kitchen_orders
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Kitchen and staff update kitchen orders" ON public.kitchen_orders
    FOR UPDATE USING (true);

CREATE POLICY "Kitchen items view" ON public.kitchen_order_items
    FOR SELECT USING (true);

CREATE POLICY "Kitchen items insert" ON public.kitchen_order_items
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Kitchen items update" ON public.kitchen_order_items
    FOR UPDATE USING (true);

-- ----------------------------------------------------------------------------
-- PAYMENTS POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "View payments" ON public.payments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders o
            WHERE o.id = payments.order_id
              AND (o.user_id = auth.uid() OR public.auth_user_role() IN ('ADMIN', 'KASIR'))
        )
    );

CREATE POLICY "Staff insert payments" ON public.payments
    FOR INSERT WITH CHECK (public.auth_user_role() IN ('ADMIN', 'KASIR'));

-- ----------------------------------------------------------------------------
-- PROMOTIONS POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Everyone view active promotions" ON public.promotions
    FOR SELECT USING (is_active = true OR public.auth_user_role() = 'ADMIN');

CREATE POLICY "Admin manage promotions" ON public.promotions
    FOR ALL USING (public.auth_user_role() = 'ADMIN');

-- ----------------------------------------------------------------------------
-- INVENTORY & TRANSACTIONS POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Staff view inventory" ON public.inventory
    FOR SELECT USING (public.auth_user_role() IN ('ADMIN', 'KASIR'));

CREATE POLICY "Admin manage inventory" ON public.inventory
    FOR ALL USING (public.auth_user_role() = 'ADMIN');

CREATE POLICY "Staff view inventory transactions" ON public.inventory_transactions
    FOR SELECT USING (public.auth_user_role() IN ('ADMIN', 'KASIR'));

CREATE POLICY "Staff insert inventory transactions" ON public.inventory_transactions
    FOR INSERT WITH CHECK (public.auth_user_role() IN ('ADMIN', 'KASIR'));

-- ----------------------------------------------------------------------------
-- NOTIFICATIONS POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Users view notifications" ON public.notifications
    FOR SELECT USING (
        user_id = auth.uid() 
        OR role_target = public.auth_user_role() 
        OR public.auth_user_role() = 'ADMIN'
    );

-- ----------------------------------------------------------------------------
-- AUDIT LOGS & SETTINGS POLICIES
-- ----------------------------------------------------------------------------
CREATE POLICY "Everyone read settings" ON public.settings
    FOR SELECT USING (true);

CREATE POLICY "Admin manage settings" ON public.settings
    FOR ALL USING (public.auth_user_role() = 'ADMIN');

CREATE POLICY "Admin view audit logs" ON public.audit_logs
    FOR SELECT USING (public.auth_user_role() = 'ADMIN');
