const express = require('express');
const bodyParser = require('body-parser');
const authRoutes = require('./src/routes/authRoutes.js');
const predictionRoutes = require('./src/routes/predictionRoutes.js');
const areaRoutes = require('./src/routes/areaRoutes.js');
const sequelize = require('./src/config/db.js');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.use('/api/express/auth', authRoutes);
app.use('/api/express/predictions', predictionRoutes);
app.use('/api/express/areas', areaRoutes);

sequelize.sync({ alter: true }).then(() => {
  app.listen(5000, () =>
    console.log('Server running on http://localhost:5000')
  );
});
