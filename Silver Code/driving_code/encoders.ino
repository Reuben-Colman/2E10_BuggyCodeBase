void encoderSpeed() {
  unsigned long currentTimeSpeed = millis();
  if (currentTimeSpeed - lastSpeedTime >= 1000) {
    EncoderSpeed = pulseCountSpeed * distancePulse / ((currentTimeSpeed - lastSpeedTime) / 1000.0);
    //Serial.print("Speed: ");
    //Serial.print(EncoderSpeed, 3); // Print speed with 3 decimal places
    //Serial.println(" cm/s");
    pulseCountSpeed = 0;
    lastSpeedTime = currentTimeSpeed;
  }
}

void encoderDistance() {
  unsigned long currentTimeDist = millis();
  if (currentTimeDist - lastDistTime >= 1000) {
    distance_traveled += pulseCountDist * distancePulse;
    //Serial.print("Distance Traveled: ");
    //Serial.print(distance_traveled, 3);
    //Serial.println(" cm");
    pulseCountDist = 0;
    lastDistTime = currentTimeDist;
  }
}

void encoderISR() {
  pulseCountSpeed++;
  pulseCountDist++;
}