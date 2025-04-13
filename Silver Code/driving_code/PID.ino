double computeFollowPID(double inp) {     
  currentTimePID = millis();                     // get current time
  elapsedTimePID = (double)(currentTimePID - previousTimePID); // compute time elapsed
  
  errorPID = inp - setPointF;            
  intError = intError + errorPID * elapsedTimePID; // compute integral
  devError = (lastErrorPID - errorPID) / elapsedTimePID; // compute derivative

  double out = kpF * errorPID + kiF * intError + kdF * devError; // PID output               

  lastErrorPID = errorPID;         
  previousTimePID = currentTimePID;   

  // set output limits of 0-255
  if (out < 0) {
    out = 0;
  }
  else if (out > 120) {
    out = 120;
  }

  return out;   
}