const { DataTypes } = require('sequelize');
module.exports = (sequelize) => sequelize.define('Faq', {
  id: { type: DataTypes.INTEGER.UNSIGNED, autoIncrement: true, primaryKey: true },
  question: { type: DataTypes.STRING(300), allowNull: false },
  answer: { type: DataTypes.TEXT, allowNull: false },
  category: { type: DataTypes.STRING(80) },
}, { tableName: 'faqs' });
