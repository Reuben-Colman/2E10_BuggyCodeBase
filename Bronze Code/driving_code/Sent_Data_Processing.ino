void processingDistance(double distance){
  WiFiClient client2 = server2.available();
  j = (char) distance;
  server2.write(j);
  //int distanceTraveled = int(distance); // Convert distance char to an integer
  Serial.println(distance);
  //Serial.println(distanceTraveled);
}