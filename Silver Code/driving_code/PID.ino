double computeFollowPID(double inp){     
  currentTimePID = millis();                //get current time
  elapsedTimePID = (double)(currentTimePID - previousTimePID);        //compute time elapsed from previous computation
        
  errorPID = inp - setPointF;            
  intError = errorPID * elapsedTimePID + intError;     // compute integral
  devError = (lastError - error)/elapsedTime;   // compute derivative

  double out = kpF*error + kiF*intError + kdF*devError;   //PID output               

  lastErrorPID = error;         
  previousTimePID = currentTimePID;   

  //set output limits of 0-255
  if (out < 0) {
    out = 0;
  }

  if (out > 255) {
    out = 255;
  }

  return out;   
}