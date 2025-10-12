const express = require('express');
const bodyParser = require('body-parser');
const swaggerUi = require('swagger-ui-express');
const swaggerSpecs = require('./src/config/swagger.js');
const authRoutes = require('./src/routes/authRoutes.js');
const predictionRoutes = require('./src/routes/predictionRoutes.js');
const areaRoutes = require('./src/routes/areaRoutes.js');
const emailRoutes = require('./src/routes/emailRoutes.js');
const natureElementRoutes = require('./src/routes/natureElementRoutes.js');
const sequelize = require('./src/config/db.js');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');
const cron = require('node-cron');
const app = express();
require('dotenv').config();
app.use(helmet());
app.use(morgan('dev'));
app.use(cors());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
const FLASK_API_URL = process.env.FLASK_API_URL;
const SECRET_KEY = process.env.FETCH_SECRET_KEY;
const axios = require('axios');
const TRIGGER_URL = `${FLASK_API_URL}/trigger_fetch`;

const triggerDataFetch = async () => {
  console.log(`[${new Date().toISOString()}] Cron job triggered: Calling Flask API to fetch data...`);
  // ... (toàn bộ logic của hàm triggerDataFetch giữ nguyên) ...
  if (!FLASK_API_URL || !SECRET_KEY) {
    console.error('ERROR: FLASK_API_URL or FETCH_SECRET_KEY is not defined in .env file.');
    return;
  }
  try {
    const response = await axios.post(TRIGGER_URL, {}, {
      headers: { 'X-FETCH-SECRET': SECRET_KEY },
      timeout: 10000,
    });
    console.log('SUCCESS: Request accepted by Flask server. Message:', response.data.message);
  } catch (error) {
    console.error('ERROR during cron job execution:', error.message);
  }
};

cron.schedule('0 0 * * *', triggerDataFetch, {
  scheduled: true,
  timezone: 'Asia/Ho_Chi_Minh',
});


// Swagger Documentation
app.use('/api/express/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpecs, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Aquaculture Prediction System API',
  swaggerOptions: {
    persistAuthorization: true,
    displayRequestDuration: true,
    docExpansion: 'none',
    filter: true,
    showRequestHeaders: true,
    tryItOutEnabled: true
  }
}));

// API Routes
app.use('/api/express/auth', authRoutes);
app.use('/api/express/predictions', predictionRoutes);
app.use('/api/express/areas', areaRoutes);
app.use('/api/express/emails', emailRoutes);
app.use('/api/express/nature-elements', natureElementRoutes);

sequelize.sync().then(() => {
  app.listen(5000, () => {
    console.log('🚀 Server running on http://localhost:5000');
    console.log('📚 API Documentation available at http://localhost:5000/api/express/docs');
  });
});
