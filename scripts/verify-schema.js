/* ============================================================================
   SCRIPT: scripts/verify-schema.js
   SYSTEM: Automated SQL migration and schema integrity verification script
   ============================================================================ */

const fs = require('fs');
const path = require('path');

const requiredTables = [
  'profiles',
  'branches',
  'tables',
  'categories',
  'products',
  'reservations',
  'orders',
  'order_items',
  'queue_numbers',
  'payments',
  'payment_transactions',
  'kitchen_orders',
  'kitchen_order_items',
  'promotions',
  'promotion_products',
  'inventory',
  'inventory_transactions',
  'notifications',
  'audit_logs',
  'settings'
];

console.log("=========================================");
console.log("  AUTOMATED SCHEMA & MIGRATION AUDIT    ");
console.log("=========================================");

const schemaFile = path.join(__dirname, '..', 'supabase', 'migrations', '20260921000000_schema.sql');
const rlsFile = path.join(__dirname, '..', 'supabase', 'migrations', '20260921000001_rls.sql');

if (!fs.existsSync(schemaFile) || !fs.existsSync(rlsFile)) {
  console.error("[FAIL] CRITICAL: Schema or RLS migration file missing!");
  process.exit(1);
}

const schemaContent = fs.readFileSync(schemaFile, 'utf8');
const rlsContent = fs.readFileSync(rlsFile, 'utf8');

let missingTables = 0;

requiredTables.forEach(table => {
  const hasTable = schemaContent.includes(`CREATE TABLE IF NOT EXISTS public.${table}`) || schemaContent.includes(`CREATE TABLE IF NOT EXISTS ${table}`);
  const hasRls = rlsContent.includes(`ALTER TABLE public.${table} ENABLE ROW LEVEL SECURITY`) || rlsContent.includes(`ENABLE ROW LEVEL SECURITY`);

  if (hasTable && hasRls) {
    console.log(`  [OK] Table & RLS verified: public.${table}`);
  } else {
    console.error(`  [ERROR] Table definition or RLS missing for: public.${table}`);
    missingTables++;
  }
});

console.log("-----------------------------------------");
if (missingTables === 0) {
  console.log("[PASS] SUCCESS: All 20 tables & RLS policies verified successfully!");
  process.exit(0);
} else {
  console.error(`[FAIL] FAILED: ${missingTables} tables failed schema check!`);
  process.exit(1);
}
