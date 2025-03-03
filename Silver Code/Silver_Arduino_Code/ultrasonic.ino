long duration; // Length of time for ultrasonic ping to return
int distance = 0; // Distance from buggy to obstacle

int Ultrasonic() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH); // sends out ultrasonic pulse for 10 Microseconds
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW); 
  duration = pulseIn(echoPin, HIGH); // reads and times when the ultrasonic pulse returns
  distance = (duration/2) / 29.1; // calculates the distance based on the time taken for the pulse to return

  return distance; // returns the distance
}
