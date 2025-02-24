void processingDistance(double distance){
  int dist = distance*10; //converts double distance to intiger
  WiFiClient client2 = server2.available(); //checks if server avaliable to send to
  j = (char) dist; //converts the intiger to a character
  server2.write(j); // sends the caracter to processing to be decoded
}