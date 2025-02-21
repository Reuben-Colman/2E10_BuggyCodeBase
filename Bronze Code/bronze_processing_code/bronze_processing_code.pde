import processing.net.*;

Client myClient;
boolean isPowered = false;
boolean obstacleDetected = false;
SliderSwitch powerSwitch;
PFont font;
float switchPosition;
float targetPosition;
float distanceTraveled = 0.0;
int timeWhenObstacle;
int timeSinceObstacle;
String input = "s";

void setup() {
  size(500, 700);
  surface.setTitle("Buggy Controller");
  smooth();
  noStroke();
  
  font = createFont("Arial Bold", 20);
  textFont(font);
  
  // Initialize client (replace with your Arduino IP)
  myClient = new Client(this, "192.168.1.14", 5200  );
  
  // Initialize switch positions
  switchPosition = targetPosition = 20;
  powerSwitch = new SliderSwitch(width/2 - 60, height/2 - 25, 120, 50);
}

void draw() {
  background(255); // White background
  
  // Handle incoming data
  if(myClient.available() > 0) {
    input = myClient.readString();
    if(input != null) {
      parseArduinoData(input);
    }
  }
  
  timeSinceObstacle = millis() - timeWhenObstacle;
  
  // Title
  fill(#333333);
  textAlign(CENTER, TOP);
  textSize(28);
  text("BUGGY CONTROLER", width/2, 25);

  // Distance display
  fill(#000000);
  textSize(36);
  text("Distance: " + nf(distanceTraveled, 0, 2) + " m", width/2, 200);
  
  // Animate switch
  switchPosition = lerp(switchPosition, targetPosition, 0.2);
  powerSwitch.display(switchPosition);
  
  // Status display
  drawStatusMessages();
}

void parseArduinoData(String data) {
  String[] messages = split(data, '\n');
  for(String msg : messages) {
    msg = msg.trim();
    if(msg.equals("O")) {
      timeWhenObstacle = millis();
    } 
    else if(msg.startsWith("DIST:")) {
      try {
        distanceTraveled = Float.parseFloat(msg.substring(5));
      } catch(NumberFormatException e) {
        println("Error parsing distance: " + msg);
      }
    }
  }
}

void drawStatusMessages() {
  String statusText = "Status: " + (isPowered ? "ACTIVE" : "STANDBY");
  color statusColor = #666666;
  
  if(timeSinceObstacle < 3000) {
    statusText = "Status: OBSTACLE DETECTED!";
    println("Obstacle dectected");
    statusColor = #FF0000;
  } 
  else if(timeSinceObstacle > 3000 && timeSinceObstacle < 6000) {
    statusText = "Status: OBSTACLE CLEARED";
    statusColor = #00C851;
  }
  
  textSize(18);
  fill(statusColor);
  textAlign(CENTER, CENTER);
  text(statusText, width/2, height - 50);
}

void mousePressed() {
  if (powerSwitch.isOver()) {
    isPowered = !isPowered;
    targetPosition = isPowered ? powerSwitch.switchWidth - 20 : 20;
    
    if(myClient.active()) {
      myClient.write(isPowered ? "z\n" : "s\n");
      println("Sent command: " + (isPowered ? "START" : "STOP"));
    }
  }
}

class SliderSwitch {
  float x, y, switchWidth, switchHeight;
  color trackColor, knobColorOff, knobColorOn;
  
  SliderSwitch(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.switchWidth = w;
    this.switchHeight = h;
    trackColor = #CCCCCC;
    knobColorOff = #FF4444;
    knobColorOn = #00C851;
  }
  
  boolean isOver() {
    return mouseX > x && mouseX < x + switchWidth && 
           mouseY > y && mouseY < y + switchHeight;
  }
  
  void display(float knobPosition) {
    // Draw track
    fill(trackColor);
    rect(x, y + switchHeight/4, switchWidth, switchHeight/2, 10);
    
    // Calculate knob color
    color knobColor = lerpColor(knobColorOff, knobColorOn, 
                              map(switchPosition, 20, switchWidth - 20, 0, 1));
    
    // Hover effect
    if (isOver()) {
      knobColor = lerpColor(knobColor, color(0), 0.1);
    }
    
    // Draw sliding knob
    fill(knobColor);
    rect(x + knobPosition - 15, y, 30, switchHeight, 8);
    
    // Draw labels
    fill(#666666);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("OFF", x + 20, y + switchHeight + 15);
    text("ON", x + switchWidth - 20, y + switchHeight + 15);
  }
}
