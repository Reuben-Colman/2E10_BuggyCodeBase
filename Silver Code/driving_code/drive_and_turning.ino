const int truningSpeed = 130; // speed while turning
//const int highSpeed = 130;    // speed while going forward
  
void DrivingStatus() {
  //Serial.println("Driving Status Called");
  if (keepDriving == 'z') {  // Keep driving if previously driving
    if (distance <= 10) { // if ultrasonic measures object is less than 10 cm away
      Stop(); // stops the buggy
      server.write("OBSTACLE\n"); // Send "OBSTACLE" to the Processor PC to signal an obstacle
    } 
    else {
      DriveReference(); // calls the drive function
    }
  } 
  else if (keepDriving == 'f') {  // If following mode
    DriveFollowing(); // calls the drive function
  }
  else { // if keepDriving is not active
    Stop(); // stops the buggy
    //Serial.println("Stop Called");
  }

  matrix.loadFrame(wifi_x); // displays x on the LED matrix, as client is not currently connected
}

void foward(int FowardSpeed) { // drives both motors forward
  Serial.print("Foward Called, Speed: ");
  Serial.println(FowardSpeed);

  analogWrite(RM1, 0); 
  analogWrite(RM2, FowardSpeed); 

  analogWrite(LM1, 0); 
  analogWrite(LM2, FowardSpeed);
}

void TurnRight() { // reverses the left motor to orient buggy to the right
  Serial.println("Turn Right Called");

  analogWrite(RM1, 0); 
  analogWrite(RM2, 0);

  analogWrite(LM1, 0); 
  analogWrite(LM2, truningSpeed);
}

void TurnLeft() { // reverses the right motor to orient buggy to the left
  Serial.println("Turn Left Called");

  analogWrite(RM1, 0); 
  analogWrite(RM2, truningSpeed); 

  analogWrite(LM1, 0); 
  analogWrite(LM2, 0);
}

void Stop() { // Stops all motors
  analogWrite(RM1, 0); 
  analogWrite(RM2, 0); 

  analogWrite(LM1, 0); 
  analogWrite(LM2, 0);
}
