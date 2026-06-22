#include <Servo.h>

// X Axis
#define X_STEP 2
#define X_DIR 5

// Y Axis
#define Y_STEP 3
#define Y_DIR 6

// Enable pin
#define ENABLE 8

// Servo
#define SERVO_PIN 11

Servo penServo;

// Position tracking
int currentX = 0;
int currentY = 0;

// Pen positions
int penUp = 90;
int penDown = 30;

void setup() {

  Serial.begin(115200);

  pinMode(X_STEP, OUTPUT);
  pinMode(X_DIR, OUTPUT);

  pinMode(Y_STEP, OUTPUT);
  pinMode(Y_DIR, OUTPUT);

  pinMode(ENABLE, OUTPUT);

  digitalWrite(ENABLE, LOW);

  penServo.attach(SERVO_PIN);

  penServo.write(penUp);
}

void loop() {

  if (Serial.available()) {

    String cmd = Serial.readStringUntil('\n');
    cmd.trim();

    if (cmd.startsWith("G1")) {

      int xIndex = cmd.indexOf('X');
      int yIndex = cmd.indexOf('Y');

      int targetX = currentX;
      int targetY = currentY;

      if (xIndex != -1) {
        targetX = cmd.substring(xIndex + 1).toInt();
      }

      if (yIndex != -1) {
        targetY = cmd.substring(yIndex + 1).toInt();
      }

      moveTo(targetX, targetY);
    }

    // Pen down
    if (cmd.startsWith("M3")) {
      penServo.write(penDown);
      delay(500);
    }

    // Pen up
    if (cmd.startsWith("M5")) {
      penServo.write(penUp);
      delay(500);
    }

    Serial.println("done");
  }
}

void moveTo(int targetX, int targetY) {

  int dx = targetX - currentX;
  int dy = targetY - currentY;

  digitalWrite(X_DIR, dx > 0 ? HIGH : LOW);
  digitalWrite(Y_DIR, dy > 0 ? HIGH : LOW);

  dx = abs(dx);
  dy = abs(dy);

  int steps = max(dx, dy);

  for (int i = 0; i < steps; i++) {

    if (i < dx) {
      digitalWrite(X_STEP, HIGH);
    }

    if (i < dy) {
      digitalWrite(Y_STEP, HIGH);
    }

    delayMicroseconds(800);

    digitalWrite(X_STEP, LOW);
    digitalWrite(Y_STEP, LOW);

    delayMicroseconds(800);
  }

  currentX = targetX;
  currentY = targetY;
}
