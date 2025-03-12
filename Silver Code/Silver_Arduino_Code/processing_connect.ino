void ClientConnected(WiFiClient client){
    Serial.println("Connected"); // prints that the buggy connected to processing
    matrix.loadFrame(wifi_check); // loads check mark on led matrix to confirm wifi conncection
    char c = client.read(); // reads the imput from processing

    if (c == 'z'){ // If start signal received from client
      if (distance <= 10) { // if obstical less then 10cm or greater then 2000 cm away then buggy stops, 2000 cm because if objstical close then gives inaccturae reading
        Stop(); // stops the buggy
        server.write("OBSTACLE\n"); // Send the char 'o' to the Processor PC to signal an obstacle in front of the buggy
      } 
      else {
        Drive_Reference_Speed(); // calls the drive function
      }
    keepDriving = "Go"; // Buggy has been started
    }

    if (c == 's'){ // If Stop signal received from client
      Stop(); // stops the buggy
      Serial.println("Buggy Stopped");
      keepDriving = "Stop"; // Buggy has been stopped
    }

    if (c == 'f'){ // If folllowing signal received from client
      Drive_Following(); // stops the buggy
      Serial.println("Buggy Following"); 
      keepDriving = "Following"; // Buggy has been stopped
    }

    if (c == 'r'){ // If Reset signal received from client
      distance_traveled = 0; //resets distance to 0;
      Serial.println("Distance Traveled Reset");
    }

    

}


void processingDistance(double distance){
  int dist = distance*10; //converts double distance to intiger
  WiFiClient client2 = server2.available(); //checks if server avaliable to send to
  j = (char) dist; //converts the intiger to a character
  server2.write(j); // sends the caracter to processing to be decoded
}