
void Drive() {
  LEYE_Status = digitalRead( LEYE ); // Store current status of Left Eye
  REYE_Status = digitalRead( REYE ); // Store current status of Right Eye

  if(LEYE_Status == HIGH || REYE_Status == HIGH){ // IR Sensor decet black
    foward();
    distance_traveled = distance_traveled + distance_on_foward;
  }

  if(LEYE_Status == LOW){ // If left ir dect white, turn right motor, and stop left motor
    TurnLeft();
  }

  if(REYE_Status == LOW){ // If left ir dect white, turn right motor, and stop left motor
    TurnRight();
  }
}

void foward() {
  analogWrite( RM1, highSpeed); 
  analogWrite( RM2, 0); 

  analogWrite( LM1, highSpeed); 
  analogWrite( LM2, 0);
}

void TurnRight(){
  analogWrite( RM1, 0); 
  analogWrite( RM2, 0);

  analogWrite( LM1, 0); 
  analogWrite( LM2, slowSpeed);
}

void TurnLeft() { 
  analogWrite( RM1, 0); 
  analogWrite( RM2, slowSpeed); 

  analogWrite( LM1, 0); 
  analogWrite( LM2, 0);
}

void Stop(){ // Stops all motors
  analogWrite( RM1, 0); 
  analogWrite( RM2, 0); 

  analogWrite( LM1, 0); 
  analogWrite( LM2, 0);
}