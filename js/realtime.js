/* ============================================================================
   REALTIME SYNCHRONIZER: js/realtime.js
   SYSTEM: Centralized Supabase Realtime WebSockets Listener
   ============================================================================ */

const RealtimeManager = {
  activeChannels: {},

  // Subscribe to live Order status changes for a specific user order
  subscribeUserOrder(orderId, onUpdateCallback) {
    const sb = getSupabase();
    if (!sb || !orderId) return;

    const channelName = `order_${orderId}`;
    if (this.activeChannels[channelName]) return;

    const channel = sb
      .channel(channelName)
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'orders',
          filter: `id=eq.${orderId}`
        },
        (payload) => {
          console.log("Realtime User Order Update:", payload);
          if (onUpdateCallback) onUpdateCallback(payload.new);
        }
      )
      .subscribe();

    this.activeChannels[channelName] = channel;
  },

  // Subscribe to Cashier Live Order Stream
  subscribeCashierOrders(onNewOrderCallback, onUpdateOrderCallback) {
    const sb = getSupabase();
    if (!sb) return;

    const channelName = 'cashier_orders_channel';
    if (this.activeChannels[channelName]) return;

    const channel = sb
      .channel(channelName)
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'orders' },
        (payload) => {
          console.log("Cashier New Order Received:", payload);
          Utils.showToast(`Pesanan Baru Masuk! #${payload.new.order_number}`, "info");
          if (onNewOrderCallback) onNewOrderCallback(payload.new);
        }
      )
      .on(
        'postgres_changes',
        { event: 'UPDATE', schema: 'public', table: 'orders' },
        (payload) => {
          console.log("Cashier Order Updated:", payload);
          if (onUpdateOrderCallback) onUpdateOrderCallback(payload.new);
        }
      )
      .subscribe();

    this.activeChannels[channelName] = channel;
  },

  // Subscribe to Kitchen Display Tickets
  subscribeKitchenTickets(onTicketUpdateCallback) {
    const sb = getSupabase();
    if (!sb) return;

    const channelName = 'kitchen_tickets_channel';
    if (this.activeChannels[channelName]) return;

    const channel = sb
      .channel(channelName)
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'kitchen_orders' },
        (payload) => {
          console.log("Kitchen Ticket Event:", payload);
          if (payload.eventType === 'INSERT') {
            Utils.showToast("Tiket Dapur Baru Masuk!", "warning");
          }
          if (onTicketUpdateCallback) onTicketUpdateCallback(payload);
        }
      )
      .subscribe();

    this.activeChannels[channelName] = channel;
  },

  unsubscribeAll() {
    const sb = getSupabase();
    if (!sb) return;

    Object.keys(this.activeChannels).forEach(key => {
      sb.removeChannel(this.activeChannels[key]);
    });
    this.activeChannels = {};
  }
};
