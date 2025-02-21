import processing.net.*;

Client myClient;
Client myClient2;
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
int distance = 0;

void setup() {
  size(500, 700);
  surface.setTitle("Buggy Controller");
  smooth();
  noStroke();
  
  font = createFont("Arial Bold", 20);
  textFont(font);
  
  // Initialize client (replace with your Arduino IP)
  myClient = new Client(this, "192.168.1.14", 5200  );
  myClient2 = new Client(this, "192.168.1.14", 5800  );

  // Initialize switch positions
  switchPosition = targetPosition = 20;
  powerSwitch = new SliderSwitch(width/2 - 60, height/2 - 25, 120, 50);
}

void draw() {
  background(255); // White background
  
  // Handle incoming data
  while(myClient.available() > 0){
    String input = myClient.readStringUntil('\n');
    if (input != null){
      parseArduinoData(input);
    }
  }
  
  while(myClient2.available() > 0){
    distance = myClient2.readChar();
  }
  int distanceTraveled = int(distance); // Convert distance char to an integer
   
  timeSinceObstacle = millis() - timeWhenObstacle;
  
  // Title
  fill(#333333);
  textAlign(CENTER, TOP);
  textSize(34);
  text("BUGGY CONTROLER", width/2, 25);

  // Distance display
  fill(#000000);
  textSize(30);
  text("Distance: " + nf(distanceTraveled) + " m", width/2, 200);
  
  // Animate switch
  switchPosition = lerp(switchPosition, targetPosition, 0.2);
  powerSwitch.display(switchPosition);
  
  // Status display
  drawStatusMessages();
}

void parseArduinoData(String data) {
  String[] messages = split(data, '\n');
  for (String msg : messages) {
    msg = msg.trim();
    println("Raw message: " + msg);  // Debug line
    
    if (msg.equals("OBSTACLE")) {
      timeWhenObstacle = millis();
      println("Obstacle detected!");
      }
    }
  }


void drawStatusMessages() {
  String statusText = "Status: " + (isPowered ? "DRIVING" : "STOPPED");
  color statusColor = #666666;
  
  if(timeSinceObstacle < 500) {
    statusText = "Status: OBSTACLE DETECTED!";
    println("Obstacle dectected");
    statusColor = #FF0000;
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
