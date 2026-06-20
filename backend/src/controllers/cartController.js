const { CartItem, Product, Brand } = require('../models');
const asyncHandler = require('../utils/asyncHandler');

const include = [{ model: Product, as: 'product', include: [{ model: Brand, as: 'brand', attributes: ['name'] }] }];

exports.getCart = asyncHandler(async (req, res) => {
  const items = await CartItem.findAll({ where: { userId: req.user.id }, include });
  res.json({ data: items });
});

exports.addToCart = asyncHandler(async (req, res) => {
  const { productId, quantity = 1 } = req.body;
  const product = await Product.findByPk(productId);
  if (!product) return res.status(404).json({ message: 'Product not found' });

  let item = await CartItem.findOne({ where: { userId: req.user.id, productId } });
  if (item) {
    item.quantity = Math.min(item.quantity + Number(quantity), product.stockQty);
    await item.save();
  } else {
    item = await CartItem.create({ userId: req.user.id, productId, quantity: Math.min(quantity, product.stockQty) });
  }
  res.status(201).json({ data: item });
});

exports.updateQty = asyncHandler(async (req, res) => {
  const { quantity } = req.body;
  const item = await CartItem.findOne({ where: { id: req.params.id, userId: req.user.id }, include });
  if (!item) return res.status(404).json({ message: 'Cart item not found' });
  if (quantity <= 0) { await item.destroy(); return res.json({ message: 'Item removed' }); }
  item.quantity = Math.min(Number(quantity), item.product.stockQty);
  await item.save();
  res.json({ data: item });
});

exports.removeItem = asyncHandler(async (req, res) => {
  const n = await CartItem.destroy({ where: { id: req.params.id, userId: req.user.id } });
  if (!n) return res.status(404).json({ message: 'Cart item not found' });
  res.json({ message: 'Item removed' });
});

exports.clearCart = asyncHandler(async (req, res) => {
  await CartItem.destroy({ where: { userId: req.user.id } });
  res.json({ message: 'Cart cleared' });
});
