const { Notification } = require('../models');
const asyncHandler = require('../utils/asyncHandler');

exports.list = asyncHandler(async (req, res) => {
  res.json({ data: await Notification.findAll({ where: { userId: req.user.id }, order: [['createdAt', 'DESC']] }) });
});

exports.markRead = asyncHandler(async (req, res) => {
  await Notification.update({ isRead: true }, { where: { id: req.params.id, userId: req.user.id } });
  res.json({ message: 'Marked read' });
});

exports.markAllRead = asyncHandler(async (req, res) => {
  await Notification.update({ isRead: true }, { where: { userId: req.user.id } });
  res.json({ message: 'All marked read' });
});
