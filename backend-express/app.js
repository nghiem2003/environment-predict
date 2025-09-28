const express = require('express');
const bodyParser = require('body-parser');
const authRoutes = require('./src/routes/authRoutes.js');
const predictionRoutes = require('./src/routes/predictionRoutes.js');
const areaRoutes = require('./src/routes/areaRoutes.js');
const emailRoutes = require('./src/routes/emailRoutes.js');
const natureElementRoutes = require('./src/routes/natureElementRoutes.js');
const sequelize = require('./src/config/db.js');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');

const app = express();

app.use(helmet());
app.use(morgan('dev'));
app.use(cors());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.use('/api/express/auth', authRoutes);
app.use('/api/express/predictions', predictionRoutes);
app.use('/api/express/areas', areaRoutes);
app.use('/api/express/emails', emailRoutes);
app.use('/api/express/nature-elements', natureElementRoutes);

sequelize.sync().then(() => {
  app.listen(5000, () =>
    console.log('Server running on http://localhost:5000')
  );
});
