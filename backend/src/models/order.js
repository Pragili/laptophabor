const { DataTypes } = require('sequelize');
module.exports = (sequelize) => sequelize.define('Order', {
  id: { type: DataTypes.INTEGER.UNSIGNED, autoIncrement: true, primaryKey: true },
  userId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  addressId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  subtotal: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
  tax: { type: DataTypes.DECIMAL(10, 2), allowNull: false, defaultValue: 0 },
  shippingFee: { type: DataTypes.DECIMAL(10, 2), allowNull: false, defaultValue: 0 },
  total: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
  status: { type: DataTypes.ENUM('pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled'), defaultValue: 'pending' },
  paymentRef: { type: DataTypes.STRING(120) },
  trackingCode: { type: DataTypes.STRING(60) },
}, { tableName: 'orders' });
