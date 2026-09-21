# Cafe Online & Offline Ordering + POS + Kitchen Display + Reservation + Inventory System

Production-oriented web application for modern fast-casual dining and cafe operations (inspired by Mie Gacoan Sidoarjo Pabean operational workflows).

Built with **HTML5, Vanilla CSS3, JavaScript ES6+**, powered by **Supabase** (PostgreSQL, Auth, Realtime, Edge Functions) and **Midtrans Snap Payment Gateway**.

---

## 🏗️ 1. Architecture Overview

- **Frontend**: Mobile-first UI for Customers; Desktop/Tablet touchscreen-optimized UI for Cashiers (POS), Kitchen (KDS), and Admins. Zero external JS frameworks (No React/Vue/Angular).
- **Database**: 20 normalized PostgreSQL tables on Supabase with foreign keys, check constraints, state machine triggers, and unique daily queue number generators (`D001`, `T002`).
- **Security & RLS**: 100% strict Row-Level Security (RLS) policies across 4 distinct roles (`USER`, `KASIR`, `DAPUR`, `ADMIN`). Midtrans Server Key and Supabase Service Role Key are strictly restricted to Edge Function environment secrets.
- **Payment Handling**: Server-side price recalculation and Midtrans Snap token generation via Supabase Edge Functions (`create-midtrans-transaction`) and SHA-512 signature verified webhook handling (`midtrans-webhook`).
- **Realtime Sync**: Supabase WebSockets stream live order events to Cashier POS, Kitchen Display System (KDS), and Customer tracking receipts without manual page refresh.

---

## 👥 2. System Roles & Authorization Matrix

| Role | Access Level & Permissions | Default Portal Landing |
| :--- | :--- | :--- |
| **`USER`** | Browse menu, Dine In table selector, Take Away order, Cart, Promo voucher application, Midtrans payment, Realtime order tracking, Table reservation. | `user/home.html` |
| **`KASIR`** | View live branch order stream, validate cash payments, confirm orders, send tickets to kitchen, manual walk-in POS order input, table reservation manager, public queue display screen. | `cashier/dashboard.html` |
| **`DAPUR`** | Touchscreen KDS ticket board (`NEW` -> `PREPARING` -> `READY`), start cooking, mark ready, live elapsed timer tracking. | `kitchen/dashboard.html` |
| **`ADMIN`** | Master data CRUD (`products`, `categories`), inventory stock control, stock in/waste logging, promotions manager, user & staff role assignment, sales reports, tax/service charge settings, audit trail. | `admin/dashboard.html` |

---

## 🛠️ 3. Setup & Database Migration Instructions

### Database Setup
1. Execute `supabase/migrations/20260921000000_schema.sql` on your Supabase SQL Editor.
2. Execute `supabase/migrations/20260921000001_rls.sql` to apply Row-Level Security policies.
3. Execute `supabase/seed.sql` to populate default branch (`Mie Gacoan Sidoarjo Pabean`), dining tables (`Table 01` - `Table 10`), 5 categories, 15+ products, initial inventory, and active promotions.

### Edge Functions Deployment
Deploy Edge Functions to Supabase CLI:

```bash
# 1. Login to Supabase CLI
supabase login

# 2. Link your project
supabase link --project-ref your-project-ref

# 3. Set Edge Function Secrets (NEVER INJECT SECRETS ON FRONTEND)
supabase secrets set MIDTRANS_SERVER_KEY="SB-Mid-server-XXXXXX"
supabase secrets set MIDTRANS_IS_PRODUCTION="false"

# 4. Deploy Functions
supabase functions deploy create-midtrans-transaction
supabase functions deploy midtrans-webhook
```

---

## 📱 4. Page Directory & Route Mapping

### User Portal
- `index.html` - System Landing Splash & Portal Selector
- `login.html` & `register.html` - Authentication & Registration
- `user/home.html` - Customer Hub (Branch info, Order type switcher, Table picker, Active promos)
- `user/menu.html` - Interactive Menu Catalog (Category filters, Search, Level Pedas modal, Floating cart bar)
- `user/cart.html` - Shopping Cart Review (Promo voucher code application, Summary calculation)
- `user/checkout.html` - Checkout Form (Customer details, Dine In verification)
- `user/payment.html` - Midtrans Snap Payment & QRIS Display
- `user/orders.html` & `user/order-detail.html` - Realtime Order History & Receipt Tracking
- `user/reservation.html` & `user/reservation-detail.html` - Table Reservation & Status Tracker
- `user/profile.html` - User Account Dashboard

### Cashier / POS Portal
- `cashier/dashboard.html` - Realtime POS Order Counter & Quick Actions
- `cashier/manual-order.html` - Offline Walk-In POS Interface (Cash change calculator, Instant queue generation)
- `cashier/orders.html` - Order Queue & Payment Confirmation Table
- `cashier/queue.html` - Public / Dining Hall Live Queue Screen (`PREPARING` vs `READY`)
- `cashier/reservations.html` - Cashier Table Reservation Manager

### Kitchen Display System (KDS)
- `kitchen/dashboard.html` - Touchscreen 3-Column KDS Board (`NEW` -> `PREPARING` -> `READY`)

### Admin Management Portal
- `admin/dashboard.html` - Executive Revenue Metrics & Low Stock Alert Dashboard
- `admin/products.html` - Menu Product Catalog CRUD & Availability Toggles
- `admin/categories.html` - Category CRUD & Display Ordering
- `admin/inventory.html` - Realtime Inventory Control & Stock Movement Logs (`STOCK_IN`, `WASTE`)
- `admin/promotions.html` - Discount Voucher Manager
- `admin/users.html` - Staff & User Role Management
- `admin/reports.html` - Sales Revenue & Order Analytics
- `admin/settings.html` - System Tax (10%) & Service Charge (5%) Settings
- `admin/audit-logs.html` - Audit Trail Activity Log

---

## 🔒 5. Security & Verification Audit

- ✅ **No Secret Key Leakage**: Midtrans Server Key and Supabase Service Role Key are used exclusively inside Deno Edge Functions environment secrets.
- ✅ **Server-Side Price Calculation**: Order grand total, tax, service charge, and discounts are recalculated in Edge Functions / PostgreSQL to prevent price tampering via client devtools.
- ✅ **Atomic Stock Deduction**: Inventory deductions use PostgreSQL row locking (`FOR UPDATE`) to prevent race conditions or negative stock levels.
- ✅ **Table Double Booking Prevention**: PostgreSQL trigger `trg_check_reservation_conflict` rejects overlapping table reservations for identical dates and times.
- ✅ **Idempotent Webhooks**: SHA-512 signature verified webhooks guarantee payment notifications are never processed twice.

---

## 📄 License
© 2026 Mie Gacoan Sidoarjo Pabean Production Build. All rights reserved.
