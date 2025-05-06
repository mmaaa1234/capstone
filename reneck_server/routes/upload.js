const express = require("express");
const multer = require("multer");
const jwt = require("jsonwebtoken");
const axios = require("axios");
const FormData = require("form-data");
const db = require("../db"); // DB 파일 import

const router = express.Router();

// JWT 검증 미들웨어
const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ message: "인증 토큰이 없습니다." });
  }
  const token = authHeader.split(" ")[1];
  // 토큰 유효성 검사

  jwt.verify(token, "jnp_secret_key", (err, decoded) => {
    if (err)
      return res.status(403).json({ message: "토큰이 유효하지 않습니다." });
    //검증 성공 시 decoded된 사용자자 정보 req.user에 저장
    req.user = decoded;
    next();
  });
};

// multer 설정 (메모리 저장 방식, 실시간 영상 프레임 전송)
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// upload 주소로 POST 요청, verifyToken으로 인증 체크, 파일 하나 받기
router.post("/", verifyToken, upload.single("file"), async (req, res) => {
  try {
    const email = req.user.email; //JWT 토근 안에 들어 있는 이메일 값

    // 메모리에 있는 프레임 AI 서버 전송
    const formData = new FormData();
    formData.append("file", req.file.buffer, {
      filename: req.file.originalname,
      contentType: req.file.mimetype,
    });

    const aiServerUrl = "http://your-ai-server.com/"; // AI 서버 URL

    // AI 서버로 요청
    const aiResponse = await axios.post(aiServerUrl, formData, {
      headers: formData.getHeaders(),
    });

    const analysisResult = aiResponse.data; // AI 분석 결과

    // DB 저장
    await db.execute(
      "INSERT INTO uploads (email, analysis_result, created_at) VALUES (?, ?, NOW())",
      [email, JSON.stringify(analysisResult)]
    );

    // 클라이언트 최종 응답
    res.json({
      message: "업로드 완료 + AI 결과 수신 + DB 저장 완료",
      analysisResult: analysisResult,
    });
  } catch (error) {
    console.error("에러 발생:", error);
    res.status(500).json({ message: "서버 오류", error: error.message });
  }
});

module.exports = router;
