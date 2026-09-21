/* ============================================================================
   AUTH & ROLE ROUTE GUARD: js/auth.js
   SYSTEM: Login, Register, Logout & Role-based Authorization
   ============================================================================ */

const AuthModule = {
  // Register User (Role is strictly forced to USER)
  async register({ full_name, email, password, phone }) {
    const sb = getSupabase();
    const { data, error } = await sb.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name,
          phone,
          role: "USER" // Client signups can NEVER assign staff roles
        }
      }
    });

    if (error) {
      if (error.message && error.message.includes("Failed to fetch")) {
        throw new Error("Gagal terhubung ke Supabase. Harap isi SUPABASE_ANON_KEY di js/config.js dengan Anon Key proyek Anda (Supabase Dashboard -> Project Settings -> API).");
      }
      throw error;
    }
    return data;
  },

  // Login User / Staff
  async login({ email, password }) {
    const sb = getSupabase();
    const { data, error } = await sb.auth.signInWithPassword({ email, password });
    if (error) {
      if (error.message && error.message.includes("Failed to fetch")) {
        throw new Error("Gagal terhubung ke Supabase. Harap isi SUPABASE_ANON_KEY di js/config.js dengan Anon Key proyek Anda (Supabase Dashboard -> Project Settings -> API).");
      }
      throw error;
    }

    const profile = await getCurrentUserProfile();
    return { session: data.session, profile };
  },

  // Logout User
  async logout() {
    const sb = getSupabase();
    await sb.auth.signOut();
    window.location.href = "/login.html";
  },

  // Role Guard Check for Pages
  async requireRole(allowedRoles = []) {
    const profile = await getCurrentUserProfile();

    if (!profile) {
      window.location.href = `/login.html?redirect=${encodeURIComponent(window.location.pathname)}`;
      return null;
    }

    if (allowedRoles.length > 0 && !allowedRoles.includes(profile.role)) {
      alert(`Akses Ditolak: Halaman ini memerlukan hak akses [${allowedRoles.join(", ")}].`);
      if (profile.role === "KASIR") window.location.href = "/cashier/dashboard.html";
      else if (profile.role === "DAPUR") window.location.href = "/kitchen/dashboard.html";
      else if (profile.role === "ADMIN") window.location.href = "/admin/dashboard.html";
      else window.location.href = "/user/home.html";
      return null;
    }

    return profile;
  }
};
