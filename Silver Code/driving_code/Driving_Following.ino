void DriveFollowing() {
  Serial.println("Driving Following Called");
  int speedFollow = computeFollowPID(distance);
  LEYE_Status = digitalRead(LEYE); // Store current status of Left IR Sensor
  REYE_Status = digitalRead(REYE); // Store current status of Right IR Sensor

  if (LEYE_Status == LOW && REYE_Status == LOW) { // If both IR Sensors detect black
    foward(speedFollow); // call the forward function
  }
  if (LEYE_Status == HIGH) { // If left IR detects white, turn left
    TurnLeft();
  }
  if (REYE_Status == HIGH) { // If right IR detects white, turn right
    TurnRight();
  }
}