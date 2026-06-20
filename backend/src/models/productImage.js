const { DataTypes } = require('sequelize');
module.exports = (sequelize) => sequelize.define('ProductImage', {
  id: { type: DataTypes.INTEGER.UNSIGNED, autoIncrement: true, primaryKey: true },
  productId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  imageUrl: { type: DataTypes.STRING(512), allowNull: false },
  sortOrder: { type: DataTypes.TINYINT.UNSIGNED, defaultValue: 0 },
}, { tableName: 'product_images', timestamps: false });
