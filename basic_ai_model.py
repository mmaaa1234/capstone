import cv2
import math
from mediapipe import solutions


def calculate_angle(p1, p2, is_right=None):
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    angle_rad = math.atan2(dy, dx)
    angle_deg = abs(math.degrees(angle_rad))
    if is_right:
        angle_deg = 180 - angle_deg
    return angle_deg


def midpoint(p1, p2):
    return ((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)


cap = cv2.VideoCapture(0)

with solutions.pose.Pose(static_image_mode=False, model_complexity=1) as pose:
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        h, w, _ = frame.shape
        image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = pose.process(image_rgb)

        if results.pose_landmarks:
            landmarks = results.pose_landmarks.landmark
            nose = landmarks[solutions.pose.PoseLandmark.NOSE]
            left_ear = landmarks[solutions.pose.PoseLandmark.LEFT_EAR]
            right_ear = landmarks[solutions.pose.PoseLandmark.RIGHT_EAR]
            left_shoulder = landmarks[solutions.pose.PoseLandmark.LEFT_SHOULDER]
            right_shoulder = landmarks[solutions.pose.PoseLandmark.RIGHT_SHOULDER]

            view_side = "unknown"
            cva_angle = None
            p1 = p2 = None
            is_right = None

            # 방향 판단
            if left_ear.visibility > 0.5 and nose.x < left_ear.x:
                view_side = "left"
                p1 = (int(left_ear.x * w), int(left_ear.y * h))
                shoulder = left_shoulder
                is_right = False
            elif right_ear.visibility > 0.5 and nose.x > right_ear.x:
                view_side = "right"
                p1 = (int(right_ear.x * w), int(right_ear.y * h))
                shoulder = right_shoulder
                is_right = True

            # 어깨-엉덩이 중간점 (척추 라인)
            shoulder_mid = midpoint(left_shoulder, right_shoulder)
            hip_mid = midpoint(landmarks[solutions.pose.PoseLandmark.LEFT_HIP],
                               landmarks[solutions.pose.PoseLandmark.RIGHT_HIP])

            p_shoulder = (int(shoulder_mid[0] * w), int(shoulder_mid[1] * h))
            p_hip = (int(hip_mid[0] * w), int(hip_mid[1] * h))

            # 척추 선 시각화
            cv2.line(frame, p_shoulder, p_hip, (0, 255, 255), 2)
            cv2.putText(frame, "Spine Line", (p_hip[0], p_hip[1] - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 2)

            # 척추 기울기 측정
            spine_angle = calculate_angle(p_hip, p_shoulder)
            cv2.putText(frame, f'Spine Angle: {spine_angle:.2f}', (30, 180), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)

            # C7 추정 (어깨 중간)
            c7_x = (left_shoulder.x + right_shoulder.x) / 2
            c7_y = (left_shoulder.y + right_shoulder.y) / 2
            c7_point = (int(c7_x * w), int(c7_y * h))

            if view_side in ["left", "right"]:
                p2 = (int(shoulder.x * w), int(shoulder.y * h))
                cva_angle = calculate_angle(p1, p2, is_right)

                # 수평 기준선 (어깨 기준 수평선)
                horiz_line = (p2[0] + 100, p2[1]) if is_right else (p2[0] - 100, p2[1])

                # 결과에 따라 색상 구분
                if cva_angle < 48:
                    color = (255, 0, 0)
                    cv2.putText(frame, 'Forward Head Posture Detected!', (30, 100),
                                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
                else:
                    color = (0, 255, 0)

                cv2.line(frame, p1, p2, color, 2)       # 귀-어깨 선
                cv2.line(frame, p2, horiz_line, color, 2)  # 어깨-수평선
                cv2.putText(frame, f'CVA: {cva_angle:.2f}', (30, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2)

            # 방향 표시
            cv2.putText(frame, f"View: {view_side}", (30, 140), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 0), 2)

        cv2.imshow("Neck Check - CVA Measurement", frame)
        if cv2.waitKey(5) & 0xFF == 27:
            break

cap.release()
cv2.destroyAllWindows()
