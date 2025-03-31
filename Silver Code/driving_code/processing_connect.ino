// "z" received: Drive Reference
// "f" received: Drive Following
// "s" received: Stop buggy
// "r" received: Reset distance traveled

void ClientConnected(WiFiClient client) {
  Serial.println("Connected"); // prints that the buggy connected to Processing
  matrix.loadFrame(wifi_check); // loads check mark on LED matrix to confirm WiFi connection
  char c = client.read(); // reads the input from Processing

  if (c == 'z') { // If start signal received from client
    if (distance <= 10) { // if obstacle is less than 10cm away
      Stop(); // stops the buggy
      server2.write("OBSTACLE\n"); // Signal obstacle to Processing
    } 
    else {
      DriveReference(); // calls the drive reference function
    }
    Serial.println("Buggy Reference Speed");
    keepDriving = 'r'; // Buggy has been started
  }

  if (c == 'f') { // If following signal received from client
    DriveFollowing(); // drive in following mode
    Serial.println("Buggy Following");
    keepDriving = 'f';
  }

  if (c == 's') { // If stop signal received from client
    Stop(); // stops the buggy
    Serial.println("Buggy Stopped");
    keepDriving = 's';
  }

  if (c == 'r') { // If reset signal received from client
    distance_traveled = 0; // resets distance to 0
    Serial.println("Distance Traveled Reset");
  }
}

void RefSpeedInput(WiFiClient client4) {
  char s = client4.read();
  speedRef = (int)s;
  Serial.print("speedRef: ");
  Serial.println(speedRef);
}

void processingDistance(double distance) {
  int dist = distance * 10; // converts double distance to integer
  WiFiClient client2 = server2.available(); // checks if server available to send to
  j = (char) dist; // converts the integer to a character
  server2.write(j); // sends the character to Processing
}

void processingSpeed(double Speed) {
  int s = Speed * 10; // converts double speed to integer
  WiFiClient client3 = server3.available(); // checks if server available to send to
  q = (char) s; // converts the integer to a character
  server3.write(q); // sends the character to Processing
}