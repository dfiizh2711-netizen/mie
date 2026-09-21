/* ============================================================================
   CONFIG: js/config.js
   SYSTEM: Client Side Configuration & Key Placeholders
   ============================================================================ */

window.APP_CONFIG = {
  // Supabase Connection (Publishable / Anon key ONLY)
  // Ensure your Supabase project keys are replaced when linking a real project instance
  SUPABASE_URL: window.env?.SUPABASE_URL || "https://your-supabase-project.supabase.co",
  SUPABASE_ANON_KEY: window.env?.SUPABASE_ANON_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRlc3QiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYwMDAwMDAwMCwiZXhwIjoyMDAwMDAwMDAwfQ.placeholder",

  // Midtrans Snap Client Key (Client Key ONLY - Safe for frontend UMD)
  MIDTRANS_CLIENT_KEY: window.env?.MIDTRANS_CLIENT_KEY || "SB-Mid-client-demo123456",

  // Default Branch ID (Mie Gacoan Sidoarjo Pabean)
  DEFAULT_BRANCH_ID: "b0000000-0000-0000-0000-000000000001",

  // System tax & service rates (Fallback default)
  DEFAULT_TAX_RATE: 0.10,
  DEFAULT_SERVICE_RATE: 0.05,
};
