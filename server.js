const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const port = 3000;

// Use CORS to allow Flutter to make requests
app.use(cors());
app.use(express.json());

// MySQL connection
const db = mysql.createConnection({
  host: 'localhost',       // Your MySQL host
  user: 'root',            // Your MySQL user
  password: '',            // Your MySQL password
  database: 'capstoneone'  // Your database name
});

// Connect to MySQL
db.connect(err => {
  if (err) {
    console.error('Error connecting to the database:', err);
    return;
  }
  console.log('Connected to MySQL database.');
});

// API to get hydro parameters
app.get('/api/hydro-parameters', (req, res) => {
  const query = 'SELECT id, ROUND(ph_level, 2) AS ph_level, ROUND(tds_level, 2) AS tds_level, ROUND(ec_level, 2) AS ec_level, ROUND(air_humidity, 2) AS air_humidity, ROUND(air_temperature, 2) AS air_temperature, ROUND(water_temperature, 2) AS water_temperature, TIMESTAMP FROM hydro_parameters ORDER BY TIMESTAMP DESC LIMIT 1';  // Get the most recent data
  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).json({ error: 'Database error' });
      return;
    }
    res.json(results[0]);
  });
});

// API to get component control data
app.get('/api/components-control', (req, res) => {
  const query = 'SELECT * FROM components_control WHERE isActive = 1';
  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).json({ error: 'Database error' });
      return;
    }
    res.json(results);
  });
});

// API to get user login data
app.get('/api/user-login', (req, res) => {
  const query = 'SELECT * FROM user_login';
  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).json({ error: 'Database error' });
      return;
    }
    res.json(results);
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
