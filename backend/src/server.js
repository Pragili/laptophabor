require('dotenv').config();
const app = require('./app');
const { sequelize } = require('./models');

const PORT = process.env.PORT || 4000;

(async () => {
  try {
    await sequelize.authenticate();
    // alter:true keeps schema in sync during development
    await sequelize.sync({ alter: true });
    console.log('✅ MySQL connected & models synced');
    app.listen(PORT, () => console.log(`🚀 LaptopHarbor API running on http://localhost:${PORT}`));
  } catch (err) {
    console.error('❌ Startup failed:', err.message);
    process.exit(1);
  }
})();
