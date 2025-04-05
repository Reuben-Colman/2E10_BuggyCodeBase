void DriveReference() {
  //Serial.println("Driving Reference Called");
  Serial.print("SpeedRef: ");
  Serial.println(speedRef);
  speedRefNom = ((float)speedRef / 50) * 255;
  speedRefNom = constrain(speedRefNom, 0, 255);
  Serial.print("SpeedRefNom: ");
  Serial.println(speedRefNom);

  LEYE_Status = digitalRead(LEYE); // Store current status of Left IR Sensor
  REYE_Status = digitalRead(REYE); // Store current status of Right IR Sensor
  Serial.print("Ir Sesors( R / L): ");
  Serial.print(REYE_Status);
  Serial.println(LEYE_Status);

  if (LEYE_Status == HIGH && REYE_Status == HIGH) { // If both IR Sensors detect black
    foward(speedRefNom); // call the forward function
  }
  if (LEYE_Status == HIGH && REYE_Status == LOW) { // If left IR detects white, turn left
    TurnLeft();
  }
  if (REYE_Status == HIGH && LEYE_Status == LOW) { // If right IR detects white, turn right
    TurnRight();
  }
}