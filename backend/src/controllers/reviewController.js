const { sequelize, Review, Product, User } = require('../models');
const asyncHandler = require('../utils/asyncHandler');

async function recomputeRating(productId, t) {
  const reviews = await Review.findAll({ where: { productId }, transaction: t });
  const count = reviews.length;
  const avg = count ? reviews.reduce((s, r) => s + r.rating, 0) / count : 0;
  await Product.update(
    { ratingAvg: avg.toFixed(1), ratingCount: count },
    { where: { id: productId }, transaction: t }
  );
}

exports.listForProduct = asyncHandler(async (req, res) => {
  const data = await Review.findAll({
    where: { productId: req.params.productId },
    include: [{ model: User, as: 'user', attributes: ['id', 'fullName', 'avatarUrl'] }],
    order: [['createdAt', 'DESC']],
  });
  res.json({ data });
});

exports.create = asyncHandler(async (req, res) => {
  const { productId, rating, comment } = req.body;
  const exists = await Review.findOne({ where: { userId: req.user.id, productId } });
  if (exists) return res.status(409).json({ message: 'You already reviewed this product' });
  const review = await sequelize.transaction(async (t) => {
    const r = await Review.create({ userId: req.user.id, productId, rating, comment }, { transaction: t });
    await recomputeRating(productId, t);
    return r;
  });
  res.status(201).json({ data: review });
});

exports.update = asyncHandler(async (req, res) => {
  const review = await Review.findOne({ where: { id: req.params.id, userId: req.user.id } });
  if (!review) return res.status(404).json({ message: 'Review not found' });
  const { rating, comment } = req.body;
  await sequelize.transaction(async (t) => {
    if (rating != null) review.rating = rating;
    if (comment != null) review.comment = comment;
    await review.save({ transaction: t });
    await recomputeRating(review.productId, t);
  });
  res.json({ data: review });
});

exports.remove = asyncHandler(async (req, res) => {
  const review = await Review.findOne({ where: { id: req.params.id, userId: req.user.id } });
  if (!review) return res.status(404).json({ message: 'Review not found' });
  const productId = review.productId;
  await sequelize.transaction(async (t) => {
    await review.destroy({ transaction: t });
    await recomputeRating(productId, t);
  });
  res.json({ message: 'Review deleted' });
});
