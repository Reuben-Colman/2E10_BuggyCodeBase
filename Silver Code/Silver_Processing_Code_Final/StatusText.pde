void drawStatusMessages() {
  String statusText;
  color statusColor;
  
  if(timeSinceObstacle < 500) {
    statusText = "Status: OBSTACLE DETECTED!";
    statusColor = #FF4444;
  } else {
    switch(threeWaySwitch.currentPosition) {
      case 0: 
        statusText = "Status: Driving"; 
        statusColor = #00C851;
        break;
      case 1: 
        statusText = "Status: OFF"; 
        statusColor = #FF4444;
        break;
      case 2: 
        statusText = "Status: FOLLOWING"; 
        statusColor = #00C851;
        break;
      default: 
        statusText = "Status: UNKNOWN";
        statusColor = #666666;
    }
  }
  
  textSize(18);
  fill(statusColor);
  textAlign(CENTER, CENTER);
  text(statusText, width/2, height - 50);
}
