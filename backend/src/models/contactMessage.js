const { DataTypes } = require('sequelize');
module.exports = (sequelize) => sequelize.define('ContactMessage', {
  id: { type: DataTypes.INTEGER.UNSIGNED, autoIncrement: true, primaryKey: true },
  userId: { type: DataTypes.INTEGER.UNSIGNED },
  name: { type: DataTypes.STRING(120), allowNull: false },
  email: { type: DataTypes.STRING(190), allowNull: false },
  subject: { type: DataTypes.STRING(160) },
  message: { type: DataTypes.TEXT, allowNull: false },
}, { tableName: 'contact_messages' });
