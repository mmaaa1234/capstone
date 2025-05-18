// db.js
const mysql = require("mysql2");
const pool = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "cheese2044!",
  database: "user_service",
});

module.exports = pool.promise(); // 또는 pool
