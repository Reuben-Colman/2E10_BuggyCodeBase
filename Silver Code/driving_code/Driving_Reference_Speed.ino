void DriveReference() {
  //Serial.println("Driving Reference Called");
  Serial.println(speedRef);
  speedRefNom = (speedRef / 50) * 255;
  Serial.print("SpeedRefNom: ");
  Serial.println(speedRefNom);

  LEYE_Status = digitalRead(LEYE); // Store current status of Left IR Sensor
  REYE_Status = digitalRead(REYE); // Store current status of Right IR Sensor

  if (LEYE_Status == LOW && REYE_Status == LOW) { // If both IR Sensors detect black
    foward(speedRefNom); // call the forward function
  }
  if (LEYE_Status == HIGH) { // If left IR detects white, turn left
    TurnLeft();
  }
  if (REYE_Status == HIGH) { // If right IR detects white, turn right
    TurnRight();
  }
}