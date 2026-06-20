const { DataTypes } = require('sequelize');
module.exports = (sequelize) => sequelize.define('Address', {
  id: { type: DataTypes.INTEGER.UNSIGNED, autoIncrement: true, primaryKey: true },
  userId: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  line1: { type: DataTypes.STRING(200), allowNull: false },
  city: { type: DataTypes.STRING(80), allowNull: false },
  state: { type: DataTypes.STRING(80) },
  postalCode: { type: DataTypes.STRING(20) },
  country: { type: DataTypes.STRING(80), allowNull: false },
  isDefault: { type: DataTypes.BOOLEAN, defaultValue: false },
}, { tableName: 'addresses' });
