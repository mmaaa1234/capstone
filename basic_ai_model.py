import cv2
import math
from mediapipe import solutions

def calculate_angle(p1, p2):
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    angle_rad = math.atan2(dy, dx)
    angle_deg = abs(math.degrees(angle_rad))
    if is_right:
        angle_deg = 180 - abs(angle_deg)
    else:
        angle_deg = abs(angle_deg)
    return angle_deg

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

            # 방향 판단
            if left_ear.visibility > 0.5 and nose.x < left_ear.x:
                view_side = "left"
                p1 = (int(left_ear.x * w), int(left_ear.y * h))
                shoulder = left_shoulder
                is_right = None
            elif right_ear.visibility > 0.5 and nose.x > right_ear.x:
                view_side = "right"
                p1 = (int(right_ear.x * w), int(right_ear.y * h))
                shoulder = right_shoulder
                is_right = True

            # C7 추정 (어깨 중간)
            c7_x = (left_shoulder.x + right_shoulder.x) / 2
            c7_y = (left_shoulder.y + right_shoulder.y) / 2
            c7_point = (int(c7_x * w), int(c7_y * h))

            if view_side in ["left", "right"]:
                p2 = (int(shoulder.x * w), int(shoulder.y * h))
                cva_angle = calculate_angle(p1, p2)

                # 수평 기준선 (어깨 기준 수평선)
                if is_right:
                    horiz_line = (p2[0] + 100, p2[1])
                else:
                    horiz_line = (p2[0] - 100, p2[1])

                if cva_angle < 48:
                    color = (255,0,0)
                    cv2.putText(frame, 'Forward Head Posture Detected!', (30, 100), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
                else:
                    color = (0,255,0)
                cv2.line(frame, p1, p2, color, 2)  # 귀-어깨
                cv2.line(frame, p2, horiz_line, color, 2)  # 어깨-수평선
                cv2.putText(frame, f'CVA: {cva_angle:.2f}', (30, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2)

            # 방향 표시
            cv2.putText(frame, f"View: {view_side}", (30, 140), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 0), 2)

        cv2.imshow("Neck Check - CVA Measurement", frame)
        if cv2.waitKey(5) & 0xFF == 27:
            break

cap.release()
cv2.destroyAllWindows()
