//Driving Speeds
//const int FowardSpeed = 130; // speed while foward
const int TurningSpeed = 255; // speed while turning
  
void Drive_Reference_Speed(Speed){ //Driving With Input Speed
  LEYE_Status = digitalRead( LEYE ); // Store current status of Left Eye
  REYE_Status = digitalRead( REYE ); // Store current status of Right Eye

  if(LEYE_Status == HIGH && REYE_Status == HIGH){ // If both IR Sensors detect black
    foward(Speed); // calls the foward function
  }

  if(LEYE_Status == LOW && REYE_Status == HIGH){ // If left ir dect white, turn right motor, and stop left motor
    TurnLeft(TurningSpeed); // calls the TurnLeft function
  }

  if(REYE_Status == LOW && LEYE_Status == HIGH){ // If left ir dect white, turn right motor, and stop left motor
    TurnRight(TurningSpeed); // calls the TurnRight function
  }
}

void Drive_Following(){ //Driving With Input Speed
  LEYE_Status = digitalRead( LEYE ); // Store current status of Left Eye
  REYE_Status = digitalRead( REYE ); // Store current status of Right Eye

  dist = Ultrasonic();

  if(LEYE_Status == HIGH && REYE_Status == HIGH){ // If both IR Sensors detect black
    foward(Speed); // calls the foward function
  }

  if(LEYE_Status == LOW && REYE_Status == HIGH){ // If left ir dect white, turn right motor, and stop left motor
    TurnLeft(TurningSpeed); // calls the TurnLeft function
  }

  if(REYE_Status == LOW && LEYE_Status == HIGH){ // If left ir dect white, turn right motor, and stop left motor
    TurnRight(TurningSpeed); // calls the TurnRight function
  }
}

void DrivingStatus(){
  if (keepDriving == "Go"){  // Keep driving if previously driving
    if (distance <= 10) { // if ultrasonic measures, object is less then 10 cm away
      Stop(); // stops the buggy
      server.write("OBSTACLE\n"); // Send the char 'o' to the Processor PC to signal an obstacle in front of the buggy
    } 
    else {
      Drive_Reference_Speed(Speed); // calls the drive function
    }
  }
  else if (keepDriving == "Follow"){
    Drive_Following();
  }
  else { // if keepDriving == false
    Stop();// stops the buggy
  }

  matrix.loadFrame(wifi_x); // displays x on the led matrix, as client is not currently connected
}

void foward(FowardSpeed) { // drives both motors foward
  analogWrite( RM1, FowardSpeed); 
  analogWrite( RM2, 0); 

  analogWrite( LM1, FowardSpeed); 
  analogWrite( LM2, 0);
  distance_traveled = distance_traveled + distance_on_foward; // conputes the distance traveled so far
}

void TurnRight(TurningSpeed){ // reverses the left motor to orient buggy to the right
  analogWrite( RM1, TurningSpeed); 
  analogWrite( RM2, 0);

  analogWrite( LM1, 0); 
  analogWrite( LM2, 0);
}

void TurnLeft(TurningSpeed) { // reverses the right motor to orient buggy to the left
  analogWrite( RM1, 0); 
  analogWrite( RM2, 0); 

  analogWrite( LM1, TurningSpeed); 
  analogWrite( LM2, 0);
}

void Stop(){ // Stops all motors
  analogWrite( RM1, 0); 
  analogWrite( RM2, 0); 

  analogWrite( LM1, 0); 
  analogWrite( LM2, 0);
}