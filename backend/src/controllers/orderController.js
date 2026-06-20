const { sequelize, Order, OrderItem, CartItem, Product, Address, Notification } = require('../models');
const asyncHandler = require('../utils/asyncHandler');

const TAX_RATE = 0.075;
const SHIPPING_FLAT = 25;

// POST /api/orders/checkout  — transactional, mock payment
exports.checkout = asyncHandler(async (req, res) => {
  const { addressId, paymentMethod = 'card' } = req.body;
  const userId = req.user.id;

  const address = await Address.findOne({ where: { id: addressId, userId } });
  if (!address) return res.status(400).json({ message: 'Invalid shipping address' });

  const cart = await CartItem.findAll({ where: { userId }, include: [{ model: Product, as: 'product' }] });
  if (!cart.length) return res.status(400).json({ message: 'Cart is empty' });

  const result = await sequelize.transaction(async (t) => {
    let subtotal = 0;
    for (const c of cart) {
      if (c.quantity > c.product.stockQty)
        throw Object.assign(new Error(`Insufficient stock for ${c.product.title}`), { status: 409 });
      subtotal += Number(c.product.price) * c.quantity;
    }
    const tax = +(subtotal * TAX_RATE).toFixed(2);
    const shippingFee = SHIPPING_FLAT;
    const total = +(subtotal + tax + shippingFee).toFixed(2);

    // Mock payment gateway resolution
    const paymentRef = `MOCK-${paymentMethod.toUpperCase()}-${Date.now()}`;

    const order = await Order.create({
      userId, addressId, subtotal, tax, shippingFee, total,
      status: 'paid', paymentRef, trackingCode: `LH-${Math.floor(100000 + Math.random() * 900000)}`,
    }, { transaction: t });

    for (const c of cart) {
      await OrderItem.create({
        orderId: order.id, productId: c.productId,
        unitPrice: c.product.price, quantity: c.quantity,
      }, { transaction: t });
      c.product.stockQty -= c.quantity;
      await c.product.save({ transaction: t });
    }

    await CartItem.destroy({ where: { userId }, transaction: t });
    await Notification.create({
      userId, title: 'Order confirmed',
      body: `Your order #${order.trackingCode} has been placed successfully.`,
    }, { transaction: t });

    return order;
  });

  res.status(201).json({ data: result });
});

exports.myOrders = asyncHandler(async (req, res) => {
  const orders = await Order.findAll({
    where: { userId: req.user.id },
    include: [{ model: OrderItem, as: 'items', include: [{ model: Product, as: 'product', attributes: ['title', 'thumbnailUrl'] }] }],
    order: [['createdAt', 'DESC']],
  });
  res.json({ data: orders });
});

exports.getOrder = asyncHandler(async (req, res) => {
  const order = await Order.findOne({
    where: { id: req.params.id, userId: req.user.id },
    include: [
      { model: OrderItem, as: 'items', include: [{ model: Product, as: 'product', attributes: ['title', 'thumbnailUrl'] }] },
      { model: Address, as: 'address' },
    ],
  });
  if (!order) return res.status(404).json({ message: 'Order not found' });
  res.json({ data: order });
});
