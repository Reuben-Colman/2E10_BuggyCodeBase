void DriveReference() {
  int speedRefNom = 0;
  constrain(speedRefNom, 0, 255);
  speedRefNom = (speedRef/50)*255;

  LEYE_Status = digitalRead( LEYE ); // Store current status of Left Eye
  REYE_Status = digitalRead( REYE ); // Store current status of Right Eye

  if(LEYE_Status == HIGH && REYE_Status == HIGH){ // If both IR Sensors detect black
    foward(speedRefNom); // calls the foward function
  }

  if(LEYE_Status == LOW){ // If left ir dect white, turn right motor, and stop left motor
    TurnLeft(); // calls the TurnLeft function
  }

  if(REYE_Status == LOW){ // If left ir dect white, turn right motor, and stop left motor
    TurnRight(); // calls the TurnRight function
  }
}