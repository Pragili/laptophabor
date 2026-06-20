const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const { User } = require('../models');
const { signToken } = require('../utils/token');
const asyncHandler = require('../utils/asyncHandler');

const publicUser = (u) => ({
  id: u.id, fullName: u.fullName, email: u.email, phone: u.phone,
  avatarUrl: u.avatarUrl, role: u.role,
});

exports.register = asyncHandler(async (req, res) => {
  const { fullName, email, password, phone } = req.body;
  if (!fullName || !email || !password)
    return res.status(400).json({ message: 'fullName, email and password are required' });

  const exists = await User.findOne({ where: { email } });
  if (exists) return res.status(409).json({ message: 'Email already registered' });

  const passwordHash = await bcrypt.hash(password, 10);
  const avatarUrl = req.file ? `/uploads/${req.file.filename}` : null;
  const user = await User.create({ fullName, email, password: undefined, passwordHash, phone, avatarUrl });

  res.status(201).json({ token: signToken(user), user: publicUser(user) });
});

exports.login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ where: { email } });
  if (!user) return res.status(401).json({ message: 'Invalid credentials' });

  const ok = await bcrypt.compare(password, user.passwordHash);
  if (!ok) return res.status(401).json({ message: 'Invalid credentials' });

  res.json({ token: signToken(user), user: publicUser(user) });
});

exports.me = asyncHandler(async (req, res) => {
  const user = await User.findByPk(req.user.id);
  if (!user) return res.status(404).json({ message: 'User not found' });
  res.json({ user: publicUser(user) });
});

exports.updateProfile = asyncHandler(async (req, res) => {
  const user = await User.findByPk(req.user.id);
  if (!user) return res.status(404).json({ message: 'User not found' });
  const { fullName, phone } = req.body;
  if (fullName) user.fullName = fullName;
  if (phone) user.phone = phone;
  if (req.file) user.avatarUrl = `/uploads/${req.file.filename}`;
  await user.save();
  res.json({ user: publicUser(user) });
});

exports.forgotPassword = asyncHandler(async (req, res) => {
  const { email } = req.body;
  const user = await User.findOne({ where: { email } });
  // Always 200 to avoid email enumeration
  if (user) {
    user.resetToken = crypto.randomBytes(20).toString('hex');
    user.resetExpires = new Date(Date.now() + 60 * 60 * 1000);
    await user.save();
    // In production this token would be emailed. For the capstone demo we return it.
    return res.json({ message: 'Reset token generated', resetToken: user.resetToken });
  }
  res.json({ message: 'If that email exists, a reset link has been sent' });
});

exports.resetPassword = asyncHandler(async (req, res) => {
  const { resetToken, newPassword } = req.body;
  const user = await User.findOne({ where: { resetToken } });
  if (!user || !user.resetExpires || user.resetExpires < new Date())
    return res.status(400).json({ message: 'Invalid or expired reset token' });
  user.passwordHash = await bcrypt.hash(newPassword, 10);
  user.resetToken = null;
  user.resetExpires = null;
  await user.save();
  res.json({ message: 'Password updated successfully' });
});
