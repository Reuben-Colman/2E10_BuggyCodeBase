//Driving Speeds
const int truningSpeed = 255; // speed while turning
const int highSpeed = 130; // speed while going foward
  
void DrivingStatus(){
  if (keepDriving == "r"){  // Keep driving if previously driving
    if (distance <= 10) { // if ultrasonic measures, object is less then 10 cm away
      Stop(); // stops the buggy
      server.write("OBSTACLE\n"); // Send the char 'o' to the Processor PC to signal an obstacle in front of the buggy
    } 
    else {
      DriveReference(); // calls the drive function
    }
  } 
  else if (keepDriving == "f"){  // Keep driving if previously Following
    DriveFollowing(); // calls the drive function
  }
  else { // if keepDriving == false
    Stop();// stops the buggy
  }

  matrix.loadFrame(wifi_x); // displays x on the led matrix, as client is not currently connected
}

void foward(int FowardSpeed) { // drives both motors foward
  analogWrite( RM1, FowardSpeed); 
  analogWrite( RM2, 0); 

  analogWrite( LM1, FowardSpeed); 
  analogWrite( LM2, 0);
}

void TurnRight(){ // reverses the left motor to orient buggy to the right
  analogWrite( RM1, 0); 
  analogWrite( RM2, 0);

  analogWrite( LM1, 0); 
  analogWrite( LM2, truningSpeed);
}

void TurnLeft() { // reverses the right motor to orient buggy to the left
  analogWrite( RM1, 0); 
  analogWrite( RM2, truningSpeed); 

  analogWrite( LM1, 0); 
  analogWrite( LM2, 0);
}

void Stop(){ // Stops all motors
  analogWrite( RM1, 0); 
  analogWrite( RM2, 0); 

  analogWrite( LM1, 0); 
  analogWrite( LM2, 0);
}