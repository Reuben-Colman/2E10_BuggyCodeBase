void processingDistance(double distance){
  int dist = distance*10;
  WiFiClient client2 = server2.available();
  j = (char) dist;
  server2.write(j);
}