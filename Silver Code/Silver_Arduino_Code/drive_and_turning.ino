//Driving Speeds
const int slowSpeed = 255; // speed while turning
const int highSpeed = 130; // speed while going foward
  
void Drive() {
  LEYE_Status = digitalRead( LEYE ); // Store current status of Left Eye
  REYE_Status = digitalRead( REYE ); // Store current status of Right Eye

  if(LEYE_Status == HIGH && REYE_Status == HIGH){ // If both IR Sensors detect black
    foward(); // calls the foward function
  }

  if(LEYE_Status == LOW){ // If left ir dect white, turn right motor, and stop left motor
    TurnLeft(); // calls the TurnLeft function
  }

  if(REYE_Status == LOW){ // If left ir dect white, turn right motor, and stop left motor
    TurnRight(); // calls the TurnRight function
  }
}

void DrivingStatus(){
  if (keepDriving == true){  // Keep driving if previously driving
    if (distance <= 10) { // if ultrasonic measures, object is less then 10 cm away
      Stop(); // stops the buggy
      server.write("OBSTACLE\n"); // Send the char 'o' to the Processor PC to signal an obstacle in front of the buggy
    } 
    else {
      Drive(); // calls the drive function
    }
  } 
  else { // if keepDriving == false
    Stop();// stops the buggy
  }

  matrix.loadFrame(wifi_x); // displays x on the led matrix, as client is not currently connected
}

void foward() { // drives both motors foward
  analogWrite( RM1, highSpeed); 
  analogWrite( RM2, 0); 

  analogWrite( LM1, highSpeed); 
  analogWrite( LM2, 0);
  distance_traveled = distance_traveled + distance_on_foward; // conputes the distance traveled so far
}

void TurnRight(){ // reverses the left motor to orient buggy to the right
  analogWrite( RM1, 0); 
  analogWrite( RM2, 0);

  analogWrite( LM1, 0); 
  analogWrite( LM2, slowSpeed);
}

void TurnLeft() { // reverses the right motor to orient buggy to the left
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