const { Faq, ContactMessage } = require('../models');
const asyncHandler = require('../utils/asyncHandler');

exports.listFaqs = asyncHandler(async (req, res) => {
  const where = req.query.category ? { category: req.query.category } : {};
  res.json({ data: await Faq.findAll({ where, order: [['category', 'ASC']] }) });
});

exports.sendContact = asyncHandler(async (req, res) => {
  const { name, email, subject, message } = req.body;
  if (!name || !email || !message)
    return res.status(400).json({ message: 'name, email and message are required' });
  const msg = await ContactMessage.create({ userId: req.user?.id || null, name, email, subject, message });
  res.status(201).json({ data: msg, message: 'Message received. We will reply within 24h.' });
});
