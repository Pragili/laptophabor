const { DataTypes } = require('sequelize');
module.exports = (sequelize) => sequelize.define('Brand', {
  id: { type: DataTypes.INTEGER.UNSIGNED, autoIncrement: true, primaryKey: true },
  name: { type: DataTypes.STRING(80), allowNull: false, unique: true },
  logoUrl: { type: DataTypes.STRING(512) },
}, { tableName: 'brands' });
