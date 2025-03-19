class Speedometer {
  float x, y;
  float radius;
  float speed;
  PFont font;
  float needleLength;
  color arcColor = #CCCCCC;
  color needleColor = #FF0000;
  color textColor = #666666;
  int numLabels = 11;
  float minSpeed = 0;
  float maxSpeed = 100;

  Speedometer(float x, float y, float radius, PFont font) {
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.font = font;
    this.needleLength = radius * 0.8;
  }

  void setSpeed(float speed) {
    this.speed = constrain(speed, minSpeed, maxSpeed);
  }

  void display() {
    pushStyle(); // Save current style settings
    drawArc();
    drawLabels();
    drawNeedle();
    drawSpeedText();
    popStyle(); // Restore original styles
  }

  private void drawArc() {
    noFill();
    stroke(arcColor);
    strokeWeight(6);
    arc(x, y + 5, radius * 2, radius * 2, PI, TWO_PI);
  }

  private void drawLabels() {
    for (int i = 0; i < numLabels; i++) {
      float angle = map(i, 0, numLabels - 1, PI, TWO_PI);
      float xPos = x + cos(angle) * (radius + 10);
      float yPos = y + sin(angle) * (radius + 10);
      stroke(#CCCCCC);
      textAlign(CENTER, CENTER);
      text(i * 10, xPos, yPos);
    }
  }

  private void drawNeedle() {
    float needleAngle = map(speed, minSpeed, maxSpeed, PI, TWO_PI);
    float needleX = x + cos(needleAngle) * needleLength;
    float needleY = y + sin(needleAngle) * needleLength;

    stroke(needleColor);
    strokeWeight(3);
    line(x, y, needleX, needleY);
  }

  private void drawSpeedText() {
    fill(#666666);
    textFont(font);
    textSize(18);
    textAlign(CENTER, CENTER);
    text(nf(speed, 0, 0), x - 20, y + 20);
    text("cm/s", x + 20, y + 20);
  }
}
