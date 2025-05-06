const mysql = require("mysql2/promise");

// DB 연결 설정
const pool = mysql.createPool({
  host: "localhost",
  user: "your_db_user", //  DB 사용자명
  password: "your_db_password", //  DB 비밀번호
  database: "your_db_name", //  사용할 데이터베이스 이름
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

module.exports = pool;
