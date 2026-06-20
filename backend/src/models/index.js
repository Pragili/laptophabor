const sequelize = require('../config/database');

const User = require('./user')(sequelize);
const Brand = require('./brand')(sequelize);
const Category = require('./category')(sequelize);
const Product = require('./product')(sequelize);
const ProductImage = require('./productImage')(sequelize);
const Address = require('./address')(sequelize);
const CartItem = require('./cartItem')(sequelize);
const WishlistItem = require('./wishlistItem')(sequelize);
const Order = require('./order')(sequelize);
const OrderItem = require('./orderItem')(sequelize);
const Review = require('./review')(sequelize);
const Notification = require('./notification')(sequelize);
const Faq = require('./faq')(sequelize);
const ContactMessage = require('./contactMessage')(sequelize);

/* ---------- Associations ---------- */
// Brand 1:M Product
Brand.hasMany(Product, { foreignKey: 'brandId', as: 'products' });
Product.belongsTo(Brand, { foreignKey: 'brandId', as: 'brand' });

// Category 1:M Product
Category.hasMany(Product, { foreignKey: 'categoryId', as: 'products' });
Product.belongsTo(Category, { foreignKey: 'categoryId', as: 'category' });

// Product 1:M ProductImage
Product.hasMany(ProductImage, { foreignKey: 'productId', as: 'images', onDelete: 'CASCADE' });
ProductImage.belongsTo(Product, { foreignKey: 'productId' });

// User 1:M Address
User.hasMany(Address, { foreignKey: 'userId', as: 'addresses', onDelete: 'CASCADE' });
Address.belongsTo(User, { foreignKey: 'userId' });

// User M:N Product via CartItem
User.hasMany(CartItem, { foreignKey: 'userId', as: 'cartItems', onDelete: 'CASCADE' });
CartItem.belongsTo(User, { foreignKey: 'userId' });
Product.hasMany(CartItem, { foreignKey: 'productId', onDelete: 'CASCADE' });
CartItem.belongsTo(Product, { foreignKey: 'productId', as: 'product' });

// User M:N Product via WishlistItem
User.hasMany(WishlistItem, { foreignKey: 'userId', as: 'wishlistItems', onDelete: 'CASCADE' });
WishlistItem.belongsTo(User, { foreignKey: 'userId' });
Product.hasMany(WishlistItem, { foreignKey: 'productId', onDelete: 'CASCADE' });
WishlistItem.belongsTo(Product, { foreignKey: 'productId', as: 'product' });

// User 1:M Order ; Address 1:M Order
User.hasMany(Order, { foreignKey: 'userId', as: 'orders' });
Order.belongsTo(User, { foreignKey: 'userId', as: 'user' });
Address.hasMany(Order, { foreignKey: 'addressId' });
Order.belongsTo(Address, { foreignKey: 'addressId', as: 'address' });

// Order M:N Product via OrderItem
Order.hasMany(OrderItem, { foreignKey: 'orderId', as: 'items', onDelete: 'CASCADE' });
OrderItem.belongsTo(Order, { foreignKey: 'orderId' });
Product.hasMany(OrderItem, { foreignKey: 'productId' });
OrderItem.belongsTo(Product, { foreignKey: 'productId', as: 'product' });

// Reviews
User.hasMany(Review, { foreignKey: 'userId', as: 'reviews', onDelete: 'CASCADE' });
Review.belongsTo(User, { foreignKey: 'userId', as: 'user' });
Product.hasMany(Review, { foreignKey: 'productId', as: 'reviews', onDelete: 'CASCADE' });
Review.belongsTo(Product, { foreignKey: 'productId' });

// Notifications
User.hasMany(Notification, { foreignKey: 'userId', as: 'notifications', onDelete: 'CASCADE' });
Notification.belongsTo(User, { foreignKey: 'userId' });

// Contact (nullable user)
User.hasMany(ContactMessage, { foreignKey: 'userId', onDelete: 'SET NULL' });
ContactMessage.belongsTo(User, { foreignKey: 'userId' });

module.exports = {
  sequelize,
  User, Brand, Category, Product, ProductImage, Address,
  CartItem, WishlistItem, Order, OrderItem, Review,
  Notification, Faq, ContactMessage,
};
