const express = require("express");
const app = express();
const PORT = 3000;

// JSON 파싱 가능하게 설정 (필요할 수도 있음)
app.use(express.json());

// 파일 업로드 처리 라우터 연결
const uploadRouter = require("./routes/upload");
//회원가입, 로그인 라우터 연결
const authRouter = require("./routes/auth");
app.use("/upload", uploadRouter);
app.use("/auth", authRouter);

//모든 도메인에서 이 서버에 접근 가능하게 허용
const cors = require("cors");
app.use(cors());

//모든 네트워크에서 접근 가능
app.listen(PORT, "0.0.0.0", () => {
  console.log(`서버가 http://localhost:${PORT} 에서 실행 중입니다.`);
});
