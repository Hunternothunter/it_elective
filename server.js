const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");

const app = express();
const port = 3000;

// Use CORS to allow Flutter to make requests
app.use(cors());
app.use(express.json());

// MySQL connection
const db = mysql.createConnection({
  host: "localhost", // Your MySQL host
  user: "root", // Your MySQL user
  password: "", // Your MySQL password
  database: "capstoneone", // Your database name
});

// Connect to MySQL
db.connect((err) => {
  if (err) {
    console.error("Error connecting to the database:", err);
    return;
  }
  console.log("Connected to MySQL database.");
});

// API to get hydro parameters
app.get("/api/hydro-parameters", (req, res) => {
  const query =
    "SELECT id, ROUND(ph_level, 2) AS ph_level, ROUND(tds_level, 2) AS tds_level, ROUND(ec_level, 2) AS ec_level, ROUND(air_humidity, 2) AS air_humidity, ROUND(air_temperature, 2) AS air_temperature, ROUND(water_temperature, 2) AS water_temperature, TIMESTAMP FROM hydro_parameters ORDER BY TIMESTAMP DESC LIMIT 1"; // Get the most recent data
  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).json({ error: "Database error" });
      return;
    }
    res.json(results[0]);
  });
});

// API to get component control data
app.get("/api/components-control", (req, res) => {
  const query =
    "SELECT component_name, dispense_amount FROM components_control WHERE isActive = 1";
  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).json({ error: "Database error" });
      return;
    }
    res.json(results);
  });
});

app.post("/api/user-login", (req, res) => {
  const { username, password } = req.body; // Assuming you are passing these values in the request body
  const query =
    "SELECT username, password FROM user_login WHERE username = ? AND password = ? AND isActive = 1";

  // Execute the query
  db.query(query, [username, password], (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Database error" });
    }
    if (results.length === 0) {
      return res.status(401).json({ error: "Incorrect username or password" });
    }

    return res.json(results[0]); // Send the first result (user object) as response
  });
});

// API to save growlight and water pump settings
app.post("/api/update_controls", (req, res) => {
  const { componentName, dispenseAmount } = req.body;

  if (!componentName || dispenseAmount === undefined) {
    return res.status(400).json({ error: "Missing required parameters" });
  }

  const componentQuery = `UPDATE components_control SET dispense_amount = ? WHERE component_name = ?`;

  db.query(componentQuery, [dispenseAmount, componentName], (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Database error" });
    }
    res.status(200).json({ message: "Settings updated successfully" });
  });
});

app.get("/api/fetch_data_source", (req, res) => {
  const query =
    "SELECT id, hydro_uuid, ROUND(pH_level, 2) AS pH_level, ROUND(tds_level, 2) AS tds_level, ROUND(water_temperature, 2) AS water_temperature, ROUND(air_temperature, 2) AS air_temperature, ROUND(air_humidity, 2) AS air_humidity, ROUND(ec_level, 2) AS ec_level, TIMESTAMP FROM hydro_parameters ORDER BY TIMESTAMP DESC"; // Get the most recent data

  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).json({ error: "Database error" });
      return;
    }
    res.json(results);
  });
});


app.get("/api/notifications", (req, res) => {
  const query = "SELECT message, is_read, TYPE, created_at FROM notifications ORDER BY created_at DESC";
  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).json({ error: "Database error" });
      return;
    }
    console.log(results); // Log the results to check for null values
    res.json(results); // Send the results to the client
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
