const { Address } = require('../models');
const asyncHandler = require('../utils/asyncHandler');

exports.list = asyncHandler(async (req, res) => {
  res.json({ data: await Address.findAll({ where: { userId: req.user.id }, order: [['isDefault', 'DESC']] }) });
});

exports.create = asyncHandler(async (req, res) => {
  const { line1, city, state, postalCode, country, isDefault } = req.body;
  if (isDefault) await Address.update({ isDefault: false }, { where: { userId: req.user.id } });
  const addr = await Address.create({ userId: req.user.id, line1, city, state, postalCode, country, isDefault: !!isDefault });
  res.status(201).json({ data: addr });
});

exports.remove = asyncHandler(async (req, res) => {
  const n = await Address.destroy({ where: { id: req.params.id, userId: req.user.id } });
  if (!n) return res.status(404).json({ message: 'Address not found' });
  res.json({ message: 'Address removed' });
});
