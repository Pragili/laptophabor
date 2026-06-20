const { WishlistItem, Product, Brand } = require('../models');
const asyncHandler = require('../utils/asyncHandler');

const include = [{ model: Product, as: 'product', include: [{ model: Brand, as: 'brand', attributes: ['name'] }] }];

exports.getWishlist = asyncHandler(async (req, res) => {
  res.json({ data: await WishlistItem.findAll({ where: { userId: req.user.id }, include }) });
});

exports.toggle = asyncHandler(async (req, res) => {
  const { productId } = req.body;
  const existing = await WishlistItem.findOne({ where: { userId: req.user.id, productId } });
  if (existing) { await existing.destroy(); return res.json({ inWishlist: false }); }
  await WishlistItem.create({ userId: req.user.id, productId });
  res.status(201).json({ inWishlist: true });
});
