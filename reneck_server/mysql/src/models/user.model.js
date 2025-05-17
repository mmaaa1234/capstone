const db = require("../config/db.config");

async function createUser({ username, password, email }) {
  const [result] = await db.execute(
    `INSERT INTO users (username, password, email) 
     VALUES (?, ?, ?)`,
    [username, password, email]
  );
  return result.insertId;
}

async function findUserByUsername(username) {
  const [rows] = await db.execute(
    `SELECT id, username, password, email, created_at
     FROM users WHERE username = ?`,
    [username]
  );
  return rows[0] || null;
}

module.exports = {
  createUser,
  findUserByUsername,
};
