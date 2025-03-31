int Ultrasonic() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH); // sends out ultrasonic pulse for 10 microseconds
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW); 
  duration = pulseIn(echoPin, HIGH); // reads and times when the ultrasonic pulse returns
  distance = (duration / 2) / 29.1; // calculates the distance based on the time taken for the pulse to return
  return distance;
}