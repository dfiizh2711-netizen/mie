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
  }
};
