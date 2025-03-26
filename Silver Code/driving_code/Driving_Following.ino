void DriveFollowing() {
  speedFollow = computeFollowPID(distance);
  LEYE_Status = digitalRead( LEYE ); // Store current status of Left Eye
  REYE_Status = digitalRead( REYE ); // Store current status of Right Eye

  if(LEYE_Status == HIGH && REYE_Status == HIGH){ // If both IR Sensors detect black
    foward(speedFollow); // calls the foward function
  }

  if(LEYE_Status == LOW){ // If left ir dect white, turn right motor, and stop left motor
    TurnLeft(); // calls the TurnLeft function
  }

  if(REYE_Status == LOW){ // If left ir dect white, turn right motor, and stop left motor
    TurnRight(); // calls the TurnRight function
  }
}