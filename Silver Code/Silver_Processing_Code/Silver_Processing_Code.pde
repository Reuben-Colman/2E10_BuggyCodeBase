import processing.net.*;

Client myClient;
Client myClient2;
boolean isPowered = false;
boolean obstacleDetected = false;
ToggleSwitch powerSwitch;
PFont font;
float switchPosition;
float targetPosition;
float distanceTraveled = 0.0;
int timeWhenObstacle;
int timeSinceObstacle;
String input = "s";
int distance = 0;
Button resetDistanceBtn;

void setup() {
  size(500, 700); //Window size
  surface.setTitle("Buggy Controller"); //title
  smooth();
  noStroke();
  
  font = createFont("Arial Bold", 20);
  textFont(font);
  
  // Initialize client (replace with your Arduino IP)
  myClient = new Client(this, "192.168.61.149", 5200  ); //Ultrasonic Client
  myClient2 = new Client(this, "192.168.61.149", 5800  ); //Distance Traveled Client

  // Initialize switch positions
  switchPosition = targetPosition = 20;
  powerSwitch = new ToggleSwitch(width/2 - 60, height/2 + 50, 120, 50); //toggle switch for on/off
  
  resetDistanceBtn = new Button("RESET", width/2 - 75, 260, 150, 40, #FF5555); //distance traveled reset button
}

void draw() {
  background(255); // White background
  
  // Incoming data from Arduino
  while(myClient.available() > 0){ // Ultrasonic data
    String input = myClient.readStringUntil('\n');
    if (input != null){
      ArduinoData(input);
    }
  }
  
  while(myClient2.available() > 0){ //Distance Traveled Data
    distance = myClient2.readChar();
  }
  float distanceTraveled = int(distance); // Convert distance character to an integer
   
  timeSinceObstacle = millis() - timeWhenObstacle; //timer for ultrasonic
  
  // Title
  fill(#666666);
  textAlign(CENTER, TOP);
  textSize(34);
  text("BUGGY CONTROLER", width/2, 25);

  // Distance display
  fill(#666666);
  textSize(30);
  text("Distance Traveled: " + nf(distanceTraveled/10, 1, 1) + " m", width/2, 200);
  
  //Reset distance traveled button
  resetDistanceBtn.display();
  
  // Toggle switch
  switchPosition = lerp(switchPosition, targetPosition, 0.2);
  powerSwitch.display(switchPosition);
  
  // Status display
  drawStatusMessages();
}

void ArduinoData(String data) {
  String[] messages = split(data, '\n');
  for (String msg : messages) {
    msg = msg.trim();
    println("Raw message: " + msg);  // Prints imput data
    
    if (msg.equals("OBSTACLE")) {
      timeWhenObstacle = millis();
      println("Obstacle detected!");
      }
    }
  }

//Status text
void drawStatusMessages() { 
  String statusText = "Status: " + (isPowered ? "DRIVING" : "STOPPED"); //displays driving or stopped based on switch
  color statusColor = #666666;
  
  if(timeSinceObstacle < 500) { //displays obstacle detected in red
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
  if (powerSwitch.isOver()) { //toggle switch logic
    isPowered = !isPowered;
    targetPosition = isPowered ? powerSwitch.switchWidth - 20 : 20;
    
    if(myClient.active()) {
      myClient.write(isPowered ? "z\n" : "s\n"); //Sends z or s based on toggle switch position
      println("Sent command: " + (isPowered ? "START" : "STOP"));
    }
  }
  
  if (resetDistanceBtn.isOver()) { //reset button logic
    distanceTraveled = 0.0; //sets processing distance traveled to 0;
    distance = 0; //sets processing distance to 0;
    myClient.write("r"); // sends reset code to arduino to reset distance traveled
    println("Distance reset");
  }
}

class ToggleSwitch { // toggle switch
  float x, y, switchWidth, switchHeight;
  color trackColor, knobColorOff, knobColorOn;
  
  ToggleSwitch(float x, float y, float w, float h) {
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
      knobColor = lerpColor(knobColor, color(255, 255, 255), 0.2);
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

class Button { // reset button 
  String label;
  float x, y, w, h;
  color btnColor, baseColor;
  
  Button(String label, float x, float y, float w, float h, color c) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.baseColor = c;
    this.btnColor = c;
  }
  
  boolean isOver() {
    return mouseX > x && mouseX < x + w && 
           mouseY > y && mouseY < y + h;
  }
  
  void display() {
    // Hover effect
    btnColor = isOver() ? lerpColor(baseColor, color(255, 255, 255), 0.2) : baseColor;
    
    // Button body
    fill(btnColor);
    rect(x, y, w, h, 5);
    
    // Button text
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(label, x + w/2, y + h/2);
  }
}
