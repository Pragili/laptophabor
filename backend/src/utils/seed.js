/* Seeds the database with brands, categories, sample laptops, FAQs and demo users.
   Run:  npm run seed   (drops & recreates all tables) */
require('dotenv').config();
const bcrypt = require('bcryptjs');
const { sequelize, User, Brand, Category, Product, ProductImage, Faq } = require('../models');

// Local product imagery generated into src/uploads (served at /uploads/...).
// Stored as RELATIVE paths; the Flutter app resolves them against its API host.
const IMG = (i, suffix = '') => `/uploads/laptop-${i}${suffix}.png`;

async function run() {
  await sequelize.sync({ force: true });
  console.log('Tables recreated.');

  // Users
  const adminPass = await bcrypt.hash('admin123', 10);
  const userPass = await bcrypt.hash('user123', 10);
  await User.bulkCreate([
    { fullName: 'Site Admin', email: 'admin@laptopharbor.com', passwordHash: adminPass, role: 'admin' },
    { fullName: 'Ada Obi', email: 'ada@example.com', passwordHash: userPass, role: 'customer' },
  ]);

  // Brands & categories
  const brands = await Brand.bulkCreate(
    ['Dell', 'HP', 'Apple', 'Lenovo', 'Asus', 'Acer', 'Razer', 'MSI', 'Microsoft', 'Samsung']
      .map((name) => ({ name }))
  );
  const cats = await Category.bulkCreate(
    ['Gaming', 'Ultrabook', 'Business', '2-in-1', 'Budget'].map((name) => ({ name }))
  );
  const B = Object.fromEntries(brands.map((b) => [b.name, b.id]));
  const C = Object.fromEntries(cats.map((c) => [c.name, c.id]));

  const products = [
    { title: 'Dell Alienware m16', brand: 'Dell', cat: 'Gaming', price: 1499, sale: 1299, cpu: 'Intel Core i7-13700H', ram: 16, storage: 1024, screen: 16.0, featured: true },
    { title: 'Lenovo Legion 5 Pro', brand: 'Lenovo', cat: 'Gaming', price: 1199, cpu: 'AMD Ryzen 7 7745HX', ram: 16, storage: 512, screen: 16.0, featured: true },
    { title: 'Asus ROG Zephyrus G14', brand: 'Asus', cat: 'Gaming', price: 1750, sale: 1575, cpu: 'AMD Ryzen 9 7940HS', ram: 32, storage: 1024, screen: 14.0, featured: true },
    { title: 'Apple MacBook Air M3', brand: 'Apple', cat: 'Ultrabook', price: 1299, cpu: 'Apple M3', ram: 16, storage: 512, screen: 13.6, featured: true },
    { title: 'Apple MacBook Pro 14', brand: 'Apple', cat: 'Ultrabook', price: 1999, cpu: 'Apple M3 Pro', ram: 18, storage: 512, screen: 14.2 },
    { title: 'Dell XPS 15', brand: 'Dell', cat: 'Ultrabook', price: 1499, sale: 1349, cpu: 'Intel Core i7-13700H', ram: 16, storage: 512, screen: 15.6, featured: true },
    { title: 'HP Spectre x360', brand: 'HP', cat: '2-in-1', price: 1150, cpu: 'Intel Core i7-1355U', ram: 16, storage: 512, screen: 13.5 },
    { title: 'Lenovo ThinkPad X1 Carbon', brand: 'Lenovo', cat: 'Business', price: 1620, sale: 1450, cpu: 'Intel Core i7-1365U', ram: 16, storage: 1024, screen: 14.0 },
    { title: 'HP Pavilion 15', brand: 'HP', cat: 'Budget', price: 680, sale: 599, cpu: 'Intel Core i5-1335U', ram: 8, storage: 512, screen: 15.6 },
    { title: 'Acer Aspire 5', brand: 'Acer', cat: 'Budget', price: 549, cpu: 'AMD Ryzen 5 7530U', ram: 8, storage: 256, screen: 15.6 },
    { title: 'Asus Zenbook 14 OLED', brand: 'Asus', cat: 'Ultrabook', price: 999, sale: 899, cpu: 'Intel Core i7-1360P', ram: 16, storage: 512, screen: 14.0 },
    { title: 'Acer Predator Helios 16', brand: 'Acer', cat: 'Gaming', price: 1899, cpu: 'Intel Core i9-13900HX', ram: 32, storage: 2048, screen: 16.0 },
    { title: 'Microsoft Surface Laptop 5', brand: 'Microsoft', cat: 'Ultrabook', price: 1299, sale: 1149, cpu: 'Intel Core i7-1255U', ram: 16, storage: 512, screen: 13.5, featured: true },
    { title: 'Razer Blade 15', brand: 'Razer', cat: 'Gaming', price: 2299, sale: 1999, cpu: 'Intel Core i7-13800H', ram: 16, storage: 1024, screen: 15.6, featured: true },
    { title: 'MSI Stealth 16', brand: 'MSI', cat: 'Gaming', price: 1999, cpu: 'Intel Core i9-13900H', ram: 32, storage: 1024, screen: 16.0 },
    { title: 'Dell Inspiron 15', brand: 'Dell', cat: 'Budget', price: 649, sale: 549, cpu: 'Intel Core i5-1334U', ram: 8, storage: 512, screen: 15.6 },
    { title: 'HP Omen 16', brand: 'HP', cat: 'Gaming', price: 1399, sale: 1249, cpu: 'Intel Core i7-13700HX', ram: 16, storage: 1024, screen: 16.1, featured: true },
    { title: 'Lenovo Yoga 9i', brand: 'Lenovo', cat: '2-in-1', price: 1399, cpu: 'Intel Core i7-1360P', ram: 16, storage: 1024, screen: 14.0 },
    { title: 'Apple MacBook Air M2', brand: 'Apple', cat: 'Ultrabook', price: 1099, sale: 999, cpu: 'Apple M2', ram: 8, storage: 256, screen: 13.6 },
    { title: 'Asus TUF Gaming A15', brand: 'Asus', cat: 'Gaming', price: 1099, cpu: 'AMD Ryzen 7 7735HS', ram: 16, storage: 512, screen: 15.6 },
    { title: 'Acer Swift 3', brand: 'Acer', cat: 'Ultrabook', price: 749, sale: 649, cpu: 'Intel Core i5-1240P', ram: 16, storage: 512, screen: 14.0 },
    { title: 'Samsung Galaxy Book3', brand: 'Samsung', cat: 'Ultrabook', price: 1049, cpu: 'Intel Core i5-1340P', ram: 16, storage: 512, screen: 15.6 },
  ];

  for (let i = 0; i < products.length; i++) {
    const p = products[i];
    const created = await Product.create({
      title: p.title,
      slug: p.title.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
      brandId: B[p.brand], categoryId: C[p.cat],
      description: `${p.title} — ${p.cpu}, ${p.ram}GB RAM, ${p.storage}GB SSD, ${p.screen}" display. A great choice for ${p.cat.toLowerCase()} users.`,
      price: p.price, salePrice: p.sale || null,
      stockQty: [3, 8, 12, 20, 2, 15][i % 6],
      cpu: p.cpu, ramGb: p.ram, storageGb: p.storage, screenSize: p.screen,
      isFeatured: !!p.featured, thumbnailUrl: IMG(i),
      ratingAvg: (3.8 + (i % 5) * 0.25).toFixed(1), ratingCount: 12 + i * 7,
    });
    await ProductImage.bulkCreate([
      { productId: created.id, imageUrl: IMG(i), sortOrder: 0 },
      { productId: created.id, imageUrl: IMG(i, '-b'), sortOrder: 1 },
      { productId: created.id, imageUrl: IMG(i, '-c'), sortOrder: 2 },
    ]);
  }

  await Faq.bulkCreate([
    { category: 'Orders', question: 'How do I track my order?', answer: 'Open Profile → My Orders, select an order and tap Track to view its live status timeline.' },
    { category: 'Orders', question: 'Can I change my shipping address?', answer: 'You can change your address before placing the order during the checkout Shipping step.' },
    { category: 'Payment', question: 'What payment methods are supported?', answer: 'This demo uses a simulated mock gateway supporting card and bank-transfer flows.' },
    { category: 'Returns', question: 'How do refunds work?', answer: 'Refunds are issued to the original payment method within 5–7 business days after approval.' },
    { category: 'Account', question: 'How do I reset my password?', answer: 'On the Login screen tap “Forgot?”, enter your email and follow the reset instructions.' },
  ]);

  console.log('✅ Seed complete.');
  console.log('   Admin:    admin@laptopharbor.com / admin123');
  console.log('   Customer: ada@example.com / user123');
  await sequelize.close();
}

run().catch((e) => { console.error(e); process.exit(1); });
