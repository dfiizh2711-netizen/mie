/* ============================================================================
   UTILITIES: js/utils.js
   SYSTEM: Formatting, Toasts, Modals, and Status Badge Helpers
   ============================================================================ */

const Utils = {
  // Format Currency to Indonesian Rupiah
  formatRupiah(amount) {
    const num = Number(amount) || 0;
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0
    }).format(num).replace('Rp', 'Rp ');
  },

  // Format Datetime
  formatDateTime(dateStr) {
    if (!dateStr) return '-';
    const date = new Date(dateStr);
    return new Intl.DateTimeFormat('id-ID', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date);
  },

  // Toast Notifications
  showToast(message, type = 'info') {
    let container = document.getElementById('toast-container');
    if (!container) {
      container = document.createElement('div');
      container.id = 'toast-container';
      container.className = 'toast-container';
      document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;

    let icon = 'ℹ️';
    if (type === 'success') icon = '✅';
    if (type === 'error') icon = '❌';
    if (type === 'warning') icon = '⚠️';

    toast.innerHTML = `<span>${icon}</span><span>${message}</span>`;
    container.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(-10px)';
      setTimeout(() => toast.remove(), 300);
    }, 3000);
  },

  // Modal Open / Close
  openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) modal.classList.add('active');
  },

  closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) modal.classList.remove('active');
  },

  // Status Badge Class & Label Map
  getOrderStatusBadge(status) {
    const map = {
      'CART': { class: 'badge-completed', label: 'Cart' },
      'PENDING_PAYMENT': { class: 'badge-pending', label: 'Menunggu Pembayaran' },
      'PAID': { class: 'badge-paid', label: 'Sudah Dibayar' },
      'CONFIRMED': { class: 'badge-paid', label: 'Dikonfirmasi' },
      'PREPARING': { class: 'badge-preparing', label: 'Sedang Disiapkan' },
      'READY': { class: 'badge-ready', label: 'Siap Diambil' },
      'COMPLETED': { class: 'badge-completed', label: 'Selesai' },
      'CANCELLED': { class: 'badge-cancelled', label: 'Dibatalkan' },
      'EXPIRED': { class: 'badge-cancelled', label: 'Kadaluarsa' }
    };
    return map[status] || { class: 'badge-completed', label: status };
  },

  // Order Type Badge Map
  getOrderTypeBadge(type) {
    if (type === 'DINE_IN') return '<span class="badge badge-dinein">Dine In</span>';
    return '<span class="badge badge-takeaway">Take Away</span>';
  },

  // Dynamic Product Image Resolver with relative path fixing
  getProductImage(imageUrl, slug) {
    const slugMap = {
      'mie-hompimpa': 'asset/miehompimpa.webp',
      'mie-gacoan': 'asset/mie gacoan.webp',
      'mie-suit': 'asset/miesuit.webp',
      'udang-keju': 'asset/udangkeju.webp',
      'udang-rambutan': 'asset/udahngrambutan.webp',
      'siomay-udang': 'asset/siomay.webp',
      'lumpia-udang': 'asset/lumpiaudang.webp',
      'pangsit-goreng-extra': 'asset/pangsitgoreng.webp',
      'es-gobak-sodor': 'asset/esgobaksodor.webp',
      'es-teklek': 'asset/thaitea.webp',
      'es-sluku-bathok': 'asset/thaigreentea.webp',
      'es-petak-sumpet': 'asset/orange.webp',
      'teh-manis-dingin': 'asset/Tea.webp',
      'lemon-tea': 'asset/lemontea.webp',
      'air-mineral-600ml': 'asset/airmineral.webp',
      'paket-mantap-hompimpa': 'asset/hero-banner.png'
    };

    let target = imageUrl || slugMap[slug] || 'asset/hero-banner.png';

    // If image URL is an external link (http/https), return as is
    if (target.startsWith('http://') || target.startsWith('https://')) {
      return target;
    }

    // Determine path prefix based on depth of current document
    const isSubdir = window.location.pathname.includes('/user/') ||
                     window.location.pathname.includes('/cashier/') ||
                     window.location.pathname.includes('/kitchen/') ||
                     window.location.pathname.includes('/admin/');

    if (isSubdir && !target.startsWith('../')) {
      return '../' + target.replace(/^\//, '');
    } else if (!isSubdir && target.startsWith('../')) {
      return target.replace(/^\.\.\//, '');
    }

    return target;
  },

  // Image Error Fallback Handler
  handleImageError(imgEl, fallbackSrc) {
    if (!imgEl) return;
    imgEl.onerror = null;
    const isSubdir = window.location.pathname.includes('/user/') ||
                     window.location.pathname.includes('/cashier/') ||
                     window.location.pathname.includes('/kitchen/') ||
                     window.location.pathname.includes('/admin/');
    const defaultFallback = isSubdir ? '../asset/hero-banner.png' : 'asset/hero-banner.png';
    imgEl.src = fallbackSrc || defaultFallback;
  },

  // Sync / Create Kitchen Order Ticket for confirmed/paid orders
  async syncKitchenTicket(orderId) {
    if (!orderId) return;
    try {
      const sb = getSupabase();
      // Check master order status first
      const { data: order } = await sb.from("orders").select("order_status").eq("id", orderId).maybeSingle();
      if (!order || ["COMPLETED", "CANCELLED", "EXPIRED", "REFUNDED"].includes(order.order_status)) {
        return; // Do not sync kitchen ticket for completed or cancelled orders
      }

      const { data: existingKo } = await sb.from("kitchen_orders").select("id").eq("order_id", orderId).maybeSingle();
      if (!existingKo) {
        let initialStatus = "NEW";
        if (order.order_status === "PREPARING") initialStatus = "PREPARING";
        else if (order.order_status === "READY") initialStatus = "READY";

        const { data: newKo, error: koErr } = await sb.from("kitchen_orders").insert({
          order_id: orderId,
          status: initialStatus
        }).select().single();

        if (newKo && !koErr) {
          const { data: items } = await sb.from("order_items").select("*").eq("order_id", orderId);
          if (items && items.length > 0) {
            const koItems = items.map(it => ({
              kitchen_order_id: newKo.id,
              order_item_id: it.id,
              product_name: it.product_name,
              quantity: it.quantity,
              notes: it.notes || "",
              status: initialStatus
            }));
            await sb.from("kitchen_order_items").insert(koItems);
          }
        }
      }
    } catch (err) {
      console.warn("syncKitchenTicket warning:", err);
    }
  }
};

