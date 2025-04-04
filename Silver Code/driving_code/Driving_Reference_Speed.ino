void DriveReference() {
  //Serial.println("Driving Reference Called");
  //Serial.print("SpeedRef: ");
  //Serial.println(speedRef);

  speedRefNom = ((float)speedRef / 50) * 255;
  speedRefNom = constrain(speedRefNom, 0, 255);

  //Serial.print("SpeedRefNom: ");
  //Serial.println(speedRefNom);

  LEYE_Status = digitalRead(LEYE); // Store current status of Left IR Sensor
  REYE_Status = digitalRead(REYE); // Store current status of Right IR Sensor

  //Serial.print("Ir Sesors( R / L): ");
  //Serial.print(REYE_Status);
  //Serial.println(LEYE_Status);

  if (LEYE_Status == HIGH && REYE_Status == HIGH) { // If both IR Sensors detect black
    foward(speedRefNom); // call the forward function
    speedCheck();
  }
  if (LEYE_Status == HIGH && REYE_Status == LOW) { // If left IR detects white, turn left
    TurnLeft();
  }
  if (REYE_Status == HIGH && LEYE_Status == LOW) { // If right IR detects white, turn right
    TurnRight();
  }
}

void speedCheck(){
  unsigned long currentTimeSpeedCheck = millis();
  if(currentTimeSpeedCheck - lastTimeSpeedCheck >= 3000){ // checks speed every second
    encoderSpeed();
    Serial.print("SpeedRefBefore: ");
    Serial.println(speedRefNom);
    Serial.print("Encoder Speed: ");
    Serial.println(EncoderSpeed*10);

    if(speedRef - EncoderSpeed*10 > 0){ // if the buggy speed is slower the the desired speed
      if(speedRef - EncoderSpeed*10 >= 5){ // if the buggy speed is slower the the desired speed by 10 cm or more
        speedRefNom = speedRefNom + 10;
      }
      if(speedRef - EncoderSpeed*10 < 5){ // if the buggy speed is slower the the desired speed by less then 10cm
        speedRefNom = speedRefNom + 1;
      }
    }

    if(speedRef - EncoderSpeed*10 < -0.99){ // if the buggy speed is faster the the desired speed
      if(speedRef - EncoderSpeed*10 <= -5){ // if the buggy speed is slower the the desired speed by 10 cm or more
        speedRefNom = speedRefNom - 10;
      }
      if(speedRef - EncoderSpeed*10 > -5){ // if the buggy speed is slower the the desired speed by less then 10cm
        speedRefNom = speedRefNom - 1;
      }
    }

    lastTimeSpeedCheck = currentTimeSpeedCheck;
    Serial.print("SpeedRefAfter: ");
    Serial.println(speedRefNom);
  }
}