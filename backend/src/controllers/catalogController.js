const { Op } = require('sequelize');
const { Product, Brand, Category, ProductImage, Review, User } = require('../models');
const asyncHandler = require('../utils/asyncHandler');

const productInclude = [
  { model: Brand, as: 'brand', attributes: ['id', 'name'] },
  { model: Category, as: 'category', attributes: ['id', 'name'] },
  { model: ProductImage, as: 'images', attributes: ['imageUrl', 'sortOrder'] },
];

// GET /api/products  — multi-parameter filtering, sorting, pagination, search
exports.listProducts = asyncHandler(async (req, res) => {
  const {
    q, categoryId, brandId, minPrice, maxPrice, ram, storage, cpu,
    minRating, sale, sort = 'newest', page = 1, limit = 20,
  } = req.query;

  const where = {};
  if (q) where.title = { [Op.like]: `%${q}%` };
  if (categoryId) where.categoryId = categoryId;
  if (brandId) where.brandId = { [Op.in]: String(brandId).split(',') };
  if (minPrice || maxPrice) where.price = {
    ...(minPrice ? { [Op.gte]: minPrice } : {}),
    ...(maxPrice ? { [Op.lte]: maxPrice } : {}),
  };
  if (ram) where.ramGb = { [Op.in]: String(ram).split(',') };
  if (storage) where.storageGb = { [Op.in]: String(storage).split(',') };
  if (cpu) where.cpu = { [Op.like]: `%${cpu}%` };
  if (minRating) where.ratingAvg = { [Op.gte]: minRating };
  if (sale === 'true' || sale === true) where.salePrice = { [Op.not]: null };

  const orderMap = {
    price_asc: [['price', 'ASC']],
    price_desc: [['price', 'DESC']],
    rating: [['ratingAvg', 'DESC']],
    popular: [['ratingCount', 'DESC']],
    newest: [['createdAt', 'DESC']],
  };

  const offset = (Number(page) - 1) * Number(limit);
  const { rows, count } = await Product.findAndCountAll({
    where, include: productInclude, order: orderMap[sort] || orderMap.newest,
    limit: Number(limit), offset, distinct: true,
  });

  res.json({ data: rows, total: count, page: Number(page), limit: Number(limit) });
});

exports.featured = asyncHandler(async (req, res) => {
  const data = await Product.findAll({ where: { isFeatured: true }, include: productInclude, limit: 10 });
  res.json({ data });
});

exports.getProduct = asyncHandler(async (req, res) => {
  const product = await Product.findByPk(req.params.id, {
    include: [
      ...productInclude,
      { model: Review, as: 'reviews', include: [{ model: User, as: 'user', attributes: ['id', 'fullName', 'avatarUrl'] }] },
    ],
  });
  if (!product) return res.status(404).json({ message: 'Product not found' });
  res.json({ data: product });
});

exports.listCategories = asyncHandler(async (req, res) => {
  res.json({ data: await Category.findAll({ order: [['name', 'ASC']] }) });
});

exports.listBrands = asyncHandler(async (req, res) => {
  res.json({ data: await Brand.findAll({ order: [['name', 'ASC']] }) });
});
