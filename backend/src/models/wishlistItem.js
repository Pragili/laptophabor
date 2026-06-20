const { DataTypes } = require('sequelize');
module.exports = (sequelize) => sequelize.define('WishlistItem', {
  id: { type: DataTypes.INTEGER.UNSIGNED, autoIncrement: true, primaryKey: true },
  userId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  productId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
}, { tableName: 'wishlist_items', indexes: [{ unique: true, fields: ['user_id', 'product_id'] }] });
