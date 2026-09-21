/* ============================================================================
   SUPABASE CLIENT WRAPPER: js/supabase-client.js
   SYSTEM: Centralized Supabase JS SDK Initialization & DB Helpers
   ============================================================================ */

(function () {
  if (typeof supabase === 'undefined') {
    console.warn("Supabase SDK UMD is not loaded yet. Retrying initialization...");
  } else {
    window.supabaseClient = supabase.createClient(
      window.APP_CONFIG.SUPABASE_URL,
      window.APP_CONFIG.SUPABASE_ANON_KEY
    );
  }
})();

// Helper to get active Supabase client instance safely
function getSupabase() {
  if (!window.supabaseClient && typeof supabase !== 'undefined') {
    window.supabaseClient = supabase.createClient(
      window.APP_CONFIG.SUPABASE_URL,
      window.APP_CONFIG.SUPABASE_ANON_KEY
    );
  }
  return window.supabaseClient;
}

// Fetch current logged in user & role profile
async function getCurrentUserProfile() {
  const sb = getSupabase();
  if (!sb) return null;

  const { data: { session }, error: sessionError } = await sb.auth.getSession();
  if (sessionError || !session?.user) return null;

  const { data: profile, error: profileError } = await sb
    .from("profiles")
    .select("*")
    .eq("id", session.user.id)
    .single();

  if (profileError || !profile) {
    return {
      id: session.user.id,
      email: session.user.email,
      full_name: session.user.user_metadata?.full_name || "User",
      role: "USER"
    };
  }

  return profile;
}

// Call Supabase Edge Functions with user Bearer token
async function callEdgeFunction(functionName, payload = {}) {
  const sb = getSupabase();
  const { data: { session } } = await sb.auth.getSession();

  const token = session?.access_token || window.APP_CONFIG.SUPABASE_ANON_KEY;

  const response = await fetch(`${window.APP_CONFIG.SUPABASE_URL}/functions/v1/${functionName}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${token}`,
      "apikey": window.APP_CONFIG.SUPABASE_ANON_KEY
    },
    body: JSON.stringify(payload)
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.error || `Edge Function Error: ${functionName}`);
  }
  return data;
}
