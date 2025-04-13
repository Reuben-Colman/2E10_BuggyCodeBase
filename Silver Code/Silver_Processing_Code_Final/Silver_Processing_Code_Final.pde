import processing.net.*; 

// Network clients
Client myClient;
Client myClient2;
Client myClient3;
Client myClient4;

// UI Components
ToggleSwitch threeWaySwitch;
NumberInput speedInput;
Button resetDistanceBtn;
Speedometer mySpeedometer;

// Global variables
PFont font;
float distanceTraveled = 0.0;
int timeWhenObstacle;
int timeSinceObstacle;
int distance = 0;
int speed = 0;  // Changed to proper case
int lastPosition = -1;
String IP = "192.168.0.119";

void setup() {
  size(500, 700);
  surface.setTitle("Buggy Controller");
  smooth();
  noStroke();
  
  // Initialize components AFTER size() is called
  mySpeedometer = new Speedometer(width/2, height/2, 125, createFont("Arial Bold", 20));
  threeWaySwitch = new ToggleSwitch(width/2 - 100, height/2 + 150, 200, 50);
  resetDistanceBtn = new Button("RESET", width/2 - 75, 135, 150, 40, #FF5555);
  speedInput = new NumberInput(width/2 - 50, height/2 + 100, 100, 40, threeWaySwitch);
  
  // Font setup
  font = createFont("Arial Bold", 20);
  textFont(font);
  
  // Network connections
  myClient = new Client(this, IP, 5200); // sending commands
  myClient2 = new Client(this, IP, 5800); // receiving obstacle detected and distance
  myClient3 = new Client(this, IP, 6000); // receiving current speed
  myClient4 = new Client(this, IP, 5400); // sending speed
}

void draw() {
  background(255);
  
  // Handle incoming data
  handleNetworkData();
  
  // Update UI
  drawTitle();
  drawDistanceDisplay();
  resetDistanceBtn.display();
  
  speedInput.display();
  
  threeWaySwitch.display();
  threeWaySwitch.handleInput();
  
  mySpeedometer.setSpeed(speed);  // Update speedometer with received speed
  mySpeedometer.display();
  drawStatusMessages();
  
  // Handle switch position changes
  handleSwitchPosition();
}

void handleNetworkData() {
  // Handle ultrasonic data
  while(myClient.available() > 0) {
    String input = myClient.readStringUntil('\n');
    if (input != null) ArduinoData(input);
  }
  
  // Handle distance data
  while(myClient2.available() > 0) {
    distance = myClient2.readChar();
  }
  distanceTraveled = int(distance);
  
  // Handle speed data - FIXED SECTION
  while(myClient3.available() > 0) {
    speed = myClient3.readChar();
  }
  
  timeSinceObstacle = millis() - timeWhenObstacle;
}

void handleSwitchPosition() {
  if (threeWaySwitch.currentPosition != lastPosition) {
    String command = "s\n";
    
    switch(threeWaySwitch.currentPosition) {
      case ToggleSwitch.DRIVING:
        command = "z\n";
        break;
      case ToggleSwitch.FOLLOWING:
        command = "f\n";
        break;
      case ToggleSwitch.OFF:
        command = "s\n";
        break;
    }
    
    if (myClient != null && myClient.active()) {
      myClient.write(command);
      println("Sent: " + command.trim());
    } else {
      println("Command client not connected. Unable to send command.");
    }
    
    // Also send the current speed if the switch changes, in case it needs updating.
    if (myClient4 != null && myClient4.active() && speedInput.hasFinalizedValue()) {
      speedInput.sendSpeedCommand();
    } else {
      println("Speed client not connected. Unable to send speed.");
    }
    
    lastPosition = threeWaySwitch.currentPosition;
  }
}

void ArduinoData(String data) {
  String[] messages = split(data, '\n');
  for (String msg : messages) {
    msg = msg.trim();
    if (msg.equals("OBSTACLE")) {
      timeWhenObstacle = millis();
      println("Obstacle detected!");
    }
  }
}

void mousePressed() {  
  if (resetDistanceBtn.isOver()) {
    distanceTraveled = 0.0;
    distance = 0;
    myClient.write("r");
    println("Distance reset");
  }
  speedInput.handleClick();
}

void keyPressed() {
  speedInput.keyPressed();
}

void drawTitle() {
  fill(#666666);
  textAlign(CENTER, TOP);
  textSize(34);
  text("BUGGY CONTROLLER", width/2, 25);
}

void drawDistanceDisplay() {
  fill(#666666);
  textSize(25);
  text("Distance Traveled: " + nf(distanceTraveled/10, 1, 1) + " m", width/2, 100);
}
