const { DataTypes } = require('sequelize');
module.exports = (sequelize) => sequelize.define('Category', {
  id: { type: DataTypes.INTEGER.UNSIGNED, autoIncrement: true, primaryKey: true },
  name: { type: DataTypes.STRING(80), allowNull: false, unique: true },
  iconUrl: { type: DataTypes.STRING(512) },
}, { tableName: 'categories' });
