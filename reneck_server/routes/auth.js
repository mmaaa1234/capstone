const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const db = require("../db");

const router = express.Router();

// 회원가입 API
router.post("/register", async (req, res) => {
  try {
    const { email, password, name } = req.body; //  user_id → email

    // 필수 입력값 확인
    if (!email || !password || !name) {
      return res.status(400).json({ message: "필수 정보를 모두 입력하세요." });
    }

    // 이메일 중복 확인
    const [rows] = await db.execute("SELECT id FROM users WHERE email = ?", [
      email,
    ]);
    if (rows.length > 0) {
      return res.status(409).json({ message: "이미 존재하는 이메일입니다." });
    }

    // 비밀번호 암호화
    const hashedPassword = await bcrypt.hash(password, 10);

    // DB에 저장
    await db.execute(
      "INSERT INTO users (email, password, name, created_at) VALUES (?, ?, ?, NOW())",
      [email, hashedPassword, name]
    );

    res.status(201).json({
      message: "회원가입 성공",
      user: {
        email: email,
        name: name,
      },
    });
  } catch (error) {
    console.error("회원가입 에러:", error);
    res.status(500).json({ message: "서버 오류", error: error.message });
  }
});

// 로그인 API
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body; // user_id → email

    // 필수 입력값 확인
    if (!email || !password) {
      return res
        .status(400)
        .json({ message: "이메일과 비밀번호를 입력하세요." });
    }

    // 유저 조회
    const [rows] = await db.execute("SELECT * FROM users WHERE email = ?", [
      email,
    ]);
    if (rows.length === 0) {
      return res.status(401).json({ message: "존재하지 않는 이메일입니다." });
    }

    const user = rows[0];

    // 비밀번호 비교
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(401).json({ message: "비밀번호가 일치하지 않습니다." });
    }

    // JWT 토큰 생성
    const token = jwt.sign(
      { email: user.email }, // payload 안에도 email
      "jnp_secret_key", // 개발용 키
      { expiresIn: "7d" }
    );

    res.json({
      message: "로그인 성공",
      token: token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    });
  } catch (error) {
    console.error("로그인 에러:", error);
    res.status(500).json({ message: "서버 오류", error: error.message });
  }
});

module.exports = router;
