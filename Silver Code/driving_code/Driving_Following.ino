void DriveFollowing() {
  Serial.println("Driving Following Called");
  distance = Ultrasonic();
  //Serial.println(distance);
  int speedFollow = computeFollowPID(distance);
  //Serial.println(speedFollow);
  LEYE_Status = digitalRead(LEYE); // Store current status of Left IR Sensor
  REYE_Status = digitalRead(REYE); // Store current status of Right IR Sensor

  if (LEYE_Status == HIGH && REYE_Status == HIGH) { // If both IR Sensors detect black
    foward(speedFollow); // call the forward function
  }
  if (LEYE_Status == HIGH && REYE_Status == LOW) { // If left IR detects white, turn left
    TurnLeft();
  }
  if (REYE_Status == HIGH && LEYE_Status == LOW) { // If right IR detects white, turn right
    TurnRight();
  }
}