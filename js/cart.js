/* ============================================================================
   CART STORE: js/cart.js
   SYSTEM: Local Cart State Management, Price Snapshots, & Total Calculation
   ============================================================================ */

const CartStore = {
  STORAGE_KEY: "gacoan_cart_v1",

  getCart() {
    try {
      const data = localStorage.getItem(this.STORAGE_KEY);
      return data ? JSON.parse(data) : { order_type: "DINE_IN", table_id: null, table_number: null, items: [], promo: null, notes: "" };
    } catch {
      return { order_type: "DINE_IN", table_id: null, table_number: null, items: [], promo: null, notes: "" };
    }
  },

  saveCart(cart) {
    localStorage.setItem(this.STORAGE_KEY, JSON.stringify(cart));
    window.dispatchEvent(new CustomEvent("cartUpdated", { detail: cart }));
  },

  setOrderType(order_type, table_id = null, table_number = null) {
    const cart = this.getCart();
    cart.order_type = order_type;
    cart.table_id = table_id;
    cart.table_number = table_number;
    this.saveCart(cart);
  },

  addItem(product, qty = 1, level = null, notes = "") {
    const cart = this.getCart();
    const itemKey = `${product.id}_${level || '0'}_${notes || ''}`;

    const existingIndex = cart.items.findIndex(i => i.item_key === itemKey);

    if (existingIndex >= 0) {
      cart.items[existingIndex].quantity += qty;
      cart.items[existingIndex].subtotal = cart.items[existingIndex].quantity * cart.items[existingIndex].price_snapshot;
    } else {
      cart.items.push({
        item_key: itemKey,
        product_id: product.id,
        product_name: product.name + (level ? ` (Level ${level})` : ''),
        image_url: product.image_url,
        price_snapshot: Number(product.base_price),
        quantity: qty,
        subtotal: qty * Number(product.base_price),
        notes: notes || '',
        level: level
      });
    }

    this.saveCart(cart);
    Utils.showToast(`${product.name} ditambahkan ke keranjang`, "success");
  },

  updateQty(itemKey, delta) {
    const cart = this.getCart();
    const index = cart.items.findIndex(i => i.item_key === itemKey);
    if (index >= 0) {
      cart.items[index].quantity += delta;
      if (cart.items[index].quantity <= 0) {
        cart.items.splice(index, 1);
      } else {
        cart.items[index].subtotal = cart.items[index].quantity * cart.items[index].price_snapshot;
      }
      this.saveCart(cart);
    }
  },

  applyPromo(promo) {
    const cart = this.getCart();
    cart.promo = promo;
    this.saveCart(cart);
    Utils.showToast(`Promo ${promo.code} diterapkan!`, "success");
  },

  removePromo() {
    const cart = this.getCart();
    cart.promo = null;
    this.saveCart(cart);
  },

  clearCart() {
    localStorage.removeItem(this.STORAGE_KEY);
    window.dispatchEvent(new CustomEvent("cartUpdated", { detail: this.getCart() }));
  },

  getTotals() {
    const cart = this.getCart();
    const subtotal = cart.items.reduce((sum, item) => sum + item.subtotal, 0);

    let discount = 0;
    if (cart.promo) {
      if (subtotal >= (cart.promo.min_purchase || 0)) {
        if (cart.promo.discount_type === "PERCENTAGE") {
          discount = (subtotal * cart.promo.discount_value) / 100;
        } else {
          discount = cart.promo.discount_value;
        }
      }
    }

    const taxableBase = Math.max(0, subtotal - discount);
    const tax = Math.round(taxableBase * window.APP_CONFIG.DEFAULT_TAX_RATE);
    const service = Math.round(taxableBase * window.APP_CONFIG.DEFAULT_SERVICE_RATE);
    const grandTotal = taxableBase + tax + service;

    return {
      itemCount: cart.items.reduce((sum, item) => sum + item.quantity, 0),
      subtotal,
      discount,
      tax,
      service,
      grandTotal
    };
  }
};
