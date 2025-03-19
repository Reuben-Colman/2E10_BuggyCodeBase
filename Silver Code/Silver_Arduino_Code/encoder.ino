void encoderSpeed(){
  unsigned long currentTime = millis();
  if (currentTime - lastSpeedTime >= 100) {
    EncoderSpeed = (pulseCount * distancePulse) / ((currentTime - lastSpeedTime) / 1000.0);

    Serial.print("Speed: ");
    Serial.print(EncoderSpeed, 3); // Print speed with 3 decimal places
    Serial.println(" m/s");

    pulseCount = 0;
    lastSpeedTime = currentTime;
  }
}

void encoderDistance(){
  unsigned long currentTime = millis();
  if (currentTime - lastDistTime >= 100) {
    distance_traveled += pulseCount * distancePulse;

    Serial.print("Speed: ");
    Serial.print(distance_traveled, 3); // Print speed with 3 decimal places
    Serial.println(" m/s");

    pulseCount = 0;
    lastDistTime = currentTime;
  }
}