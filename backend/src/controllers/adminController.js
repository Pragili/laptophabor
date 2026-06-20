const { fn, col, Op } = require('sequelize');
const {
  Product, Order, OrderItem, User, Brand, Category, ProductImage, Notification,
} = require('../models');
const asyncHandler = require('../utils/asyncHandler');

/* ---------- Dashboard ---------- */
exports.dashboard = asyncHandler(async (req, res) => {
  const [revenueRow, orderCount, userCount, lowStock] = await Promise.all([
    Order.findOne({ attributes: [[fn('COALESCE', fn('SUM', col('total')), 0), 'revenue']], where: { status: { [Op.ne]: 'cancelled' } }, raw: true }),
    Order.count(),
    User.count({ where: { role: 'customer' } }),
    Product.count({ where: { stockQty: { [Op.lte]: 5 } } }),
  ]);

  const recentOrdersRaw = await Order.findAll({
    include: [{ model: User, as: 'user', attributes: ['fullName'] }],
    order: [['createdAt', 'DESC']], limit: 6,
  });
  const recentOrders = recentOrdersRaw.map((o) => ({
    id: o.id, trackingCode: o.trackingCode, status: o.status,
    total: o.total, createdAt: o.createdAt,
    customer: o.user ? o.user.fullName : 'Customer',
  }));

  const lowStockProducts = await Product.findAll({
    where: { stockQty: { [Op.lte]: 5 } },
    attributes: ['title', 'stockQty', 'thumbnailUrl'],
    order: [['stockQty', 'ASC']], limit: 8,
  });

  // Revenue for the last 7 days, bucketed by weekday.
  const since = new Date(Date.now() - 6 * 24 * 60 * 60 * 1000);
  since.setHours(0, 0, 0, 0);
  const weekOrders = await Order.findAll({
    where: { status: { [Op.ne]: 'cancelled' }, createdAt: { [Op.gte]: since } },
    attributes: ['total', 'createdAt'], raw: true,
  });
  const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const salesSeries = [];
  for (let i = 6; i >= 0; i--) {
    const day = new Date(Date.now() - i * 24 * 60 * 60 * 1000);
    const value = weekOrders
      .filter((o) => new Date(o.createdAt).toDateString() === day.toDateString())
      .reduce((s, o) => s + Number(o.total), 0);
    salesSeries.push({ label: labels[day.getDay()], value });
  }

  res.json({
    metrics: {
      revenue: Number(revenueRow.revenue) || 0,
      orders: orderCount,
      users: userCount,
      lowStock,
    },
    salesSeries,
    recentOrders,
    lowStockProducts,
  });
});

/* ---------- Product CRUD ---------- */
const slugify = (s) => s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');

exports.createProduct = asyncHandler(async (req, res) => {
  const b = req.body;
  const product = await Product.create({
    title: b.title, slug: slugify(`${b.title}-${Date.now()}`),
    brandId: b.brandId, categoryId: b.categoryId, description: b.description,
    price: b.price, salePrice: b.salePrice || null, stockQty: b.stockQty || 0,
    cpu: b.cpu, ramGb: b.ramGb, storageGb: b.storageGb, screenSize: b.screenSize,
    isFeatured: b.isFeatured === 'true' || b.isFeatured === true,
    thumbnailUrl: req.files?.[0] ? `/uploads/${req.files[0].filename}` : b.thumbnailUrl,
  });
  if (req.files?.length) {
    await ProductImage.bulkCreate(req.files.map((f, i) => ({
      productId: product.id, imageUrl: `/uploads/${f.filename}`, sortOrder: i,
    })));
  }
  res.status(201).json({ data: product });
});

exports.updateProduct = asyncHandler(async (req, res) => {
  const product = await Product.findByPk(req.params.id);
  if (!product) return res.status(404).json({ message: 'Product not found' });
  const fields = ['title', 'brandId', 'categoryId', 'description', 'price', 'salePrice', 'stockQty', 'cpu', 'ramGb', 'storageGb', 'screenSize', 'isFeatured'];
  fields.forEach((f) => { if (req.body[f] !== undefined) product[f] = req.body[f]; });
  if (req.files?.length) product.thumbnailUrl = `/uploads/${req.files[0].filename}`;
  await product.save();
  res.json({ data: product });
});

exports.deleteProduct = asyncHandler(async (req, res) => {
  const n = await Product.destroy({ where: { id: req.params.id } });
  if (!n) return res.status(404).json({ message: 'Product not found' });
  res.json({ message: 'Product deleted' });
});

/* ---------- Order lifecycle ---------- */
exports.listOrders = asyncHandler(async (req, res) => {
  const where = req.query.status ? { status: req.query.status } : {};
  const orders = await Order.findAll({
    where, include: [{ model: User, as: 'user', attributes: ['fullName', 'email'] }],
    order: [['createdAt', 'DESC']],
  });
  res.json({ data: orders });
});

exports.updateOrderStatus = asyncHandler(async (req, res) => {
  const order = await Order.findByPk(req.params.id);
  if (!order) return res.status(404).json({ message: 'Order not found' });
  const allowed = ['pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled'];
  if (!allowed.includes(req.body.status))
    return res.status(400).json({ message: 'Invalid status' });
  order.status = req.body.status;
  await order.save();
  // notify customer of lifecycle change
  await Notification.create({
    userId: order.userId, title: `Order ${order.trackingCode} updated`,
    body: `Your order status is now: ${order.status}.`,
  });
  res.json({ data: order });
});

/* ---------- User moderation ---------- */
exports.listUsers = asyncHandler(async (req, res) => {
  res.json({ data: await User.findAll({ attributes: ['id', 'fullName', 'email', 'role', 'createdAt'], order: [['createdAt', 'DESC']] }) });
});

exports.setUserRole = asyncHandler(async (req, res) => {
  const user = await User.findByPk(req.params.id);
  if (!user) return res.status(404).json({ message: 'User not found' });
  if (!['customer', 'admin'].includes(req.body.role))
    return res.status(400).json({ message: 'Invalid role' });
  user.role = req.body.role;
  await user.save();
  res.json({ data: { id: user.id, role: user.role } });
});
