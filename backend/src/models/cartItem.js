const { DataTypes } = require('sequelize');
module.exports = (sequelize) => sequelize.define('CartItem', {
  id: { type: DataTypes.INTEGER.UNSIGNED, autoIncrement: true, primaryKey: true },
  userId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  productId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  quantity: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false, defaultValue: 1 },
}, { tableName: 'cart_items', indexes: [{ unique: true, fields: ['user_id', 'product_id'] }] });
