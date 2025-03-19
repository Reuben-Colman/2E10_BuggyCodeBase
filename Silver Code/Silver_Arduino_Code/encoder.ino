void encoderSpeed(){
  unsigned long currentTimeSpeed = millis();
  if (currentTimeSpeed - lastSpeedTime >= 1000) {
    EncoderSpeed =  pulseCount * distancePulse / ((currentTimeSpeed - lastSpeedTime) / 1000.0);

    Serial.print("Speed: ");
    Serial.print(EncoderSpeed, 3); // Print speed with 3 decimal places
    Serial.println(" cm/s");

    pulseCount = 0;
    lastSpeedTime = currentTimeSpeed;
  }
}

void encoderDistance(){
  unsigned long currentTimeDist = millis();
  if (currentTimeDist - lastDistTime >= 1000) {
    distance_traveled += pulseCount * distancePulse;

    Serial.print("Distance Traveled: ");
    Serial.print(distance_traveled, 3); // Print speed with 3 decimal places
    Serial.println(" m");

    pulseCount = 0;
    lastDistTime = currentTimeDist;
  }
}