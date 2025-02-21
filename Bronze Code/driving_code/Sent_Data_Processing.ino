void processingDistance(double distance){
  WiFiClient client2 = server2.available();
  j = (char) distance;
  server2.write(j);
}