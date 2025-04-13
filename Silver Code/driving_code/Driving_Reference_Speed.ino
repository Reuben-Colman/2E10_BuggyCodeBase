void DriveReference() {
  //Serial.println("Driving Reference Called");
  //Serial.print("SpeedRef: ");
  //Serial.println(speedRef);

  speedRefNom = constrain(speedRefNom, 0, 255);

  //Serial.print("SpeedRefNom: ");
  //Serial.println(speedRefNom);

  //Serial.print("SpeedRefAfter: ");
  //Serial.println(speedRefNom);

  LEYE_Status = digitalRead(LEYE); // Store current status of Left IR Sensor
  REYE_Status = digitalRead(REYE); // Store current status of Right IR Sensor

  Serial.print("Ir Sesors( R / L): ");
  Serial.print(REYE_Status);
  Serial.println(LEYE_Status);

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
  if(currentTimeSpeedCheck - lastTimeSpeedCheck >= 1500){ // checks speed every 1.5 seconds
    encoderSpeed();
    double encoderspeedreal = EncoderSpeed*10;
    //Serial.println("------- Speed Check -------");
    //Serial.print("SpeedRef: ");
    //Serial.println(speedRef);
    //Serial.print("SpeedRefNomBefore: ");
    //Serial.println(speedRefNom);
    //Serial.print("Encoder Speed: ");
    //Serial.println(EncoderSpeed*10);

    if(speedRef - encoderspeedreal > 0){ // if the buggy speed is slower the the desired speed
      //Serial.println("Buggy Speed Slower then Specified");
      //Serial.println(speedRef - EncoderSpeed*10);
      if(speedRef - encoderspeedreal >= 5){ // if the buggy speed is slower the the desired speed by 10 cm or more
        speedRefNom = speedRefNom + 10;
        lastTimeSpeedCheck = currentTimeSpeedCheck;
        return;
      }
      else if(speedRef - encoderspeedreal < 5){ // if the buggy speed is slower the the desired speed by less then 10cm
        speedRefNom = speedRefNom + 1;
        lastTimeSpeedCheck = currentTimeSpeedCheck;
        return;
      }
    }

    if(speedRef - encoderspeedreal < -0.99){ // if the buggy speed is faster the the desired speed
      //Serial.println("Buggy Speed Faster then Specified");
      if(speedRef - encoderspeedreal <= -5){ // if the buggy speed is slower the the desired speed by 10 cm or more
        speedRefNom = speedRefNom - 10;
        lastTimeSpeedCheck = currentTimeSpeedCheck;
        return;
      }
      else if(speedRef - encoderspeedreal > -5){ // if the buggy speed is slower the the desired speed by less then 10cm
        speedRefNom = speedRefNom - 1;
        lastTimeSpeedCheck = currentTimeSpeedCheck;
        return;
      }
    }

    //Serial.print("SpeedRefNomAfter: ");
    //Serial.println(speedRefNom);
  }
}