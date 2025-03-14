import processing.net.*;

Client myClient;
Client myClient2;
Client myClient3;
boolean obstacleDetected = false;
PFont font;
float distanceTraveled = 0.0;
int timeWhenObstacle;
int timeSinceObstacle;
String input = "s";
int distance = 0;
Button resetDistanceBtn;
ToggleSwitch threeWaySwitch;
int lastPosition = -1; // To track switch position changes

String IP = "192.168.61.149";

void setup() {
  size(500, 700);
  surface.setTitle("Buggy Controller");
  smooth();
  noStroke();
  
  font = createFont("Arial Bold", 20);
  textFont(font);
  
  myClient = new Client(this, IP, 5200); // Ultrasonic Client
  myClient2 = new Client(this, IP, 5800); // Distance Traveled Client
  myClient3 = new Client(this, IP, 6000); // Buggy Speed Client
  
  threeWaySwitch = new ToggleSwitch(width/2 + 100, height/2 + 350, 200, 50);
  
  resetDistanceBtn = new Button("RESET", width/2 - 75, 260, 150, 40, #FF5555);
}

void draw() {
  background(255);
  
  // Handle incoming data
  while(myClient.available() > 0) {
    String input = myClient.readStringUntil('\n');
    if (input != null) ArduinoData(input);
  }
  
  while(myClient2.available() > 0) {
    distance = myClient2.readChar();
  }
  
  distanceTraveled = int(distance);
  timeSinceObstacle = millis() - timeWhenObstacle;
  
  // UI Elements
  drawTitle();
  drawDistanceDisplay();
  resetDistanceBtn.display();
  
  // Handle 3-way switch
  threeWaySwitch.handleInput();
  threeWaySwitch.display();
  handleSwitchPosition();
  
  drawStatusMessages();
}

void handleSwitchPosition() {
  if (threeWaySwitch.currentPosition != lastPosition) {
    String command;
    switch(threeWaySwitch.currentPosition) {
      case 0: command = "z\n"; break; // driving
      case 1: command = "s\n"; break; // stopped
      case 2: command = "f\n"; break; // following
      default: command = "s\n";
    }
    
    if (myClient.active()) {
      myClient.write(command);
      println("Sent command: " + command.trim());
    }
    lastPosition = threeWaySwitch.currentPosition;
  }
}

void drawTitle() {
  fill(#666666);
  textAlign(CENTER, TOP);
  textSize(34);
  text("BUGGY CONTROLLER", width/2, 25);
}

void drawDistanceDisplay() {
  fill(#666666);
  textSize(30);
  text("Distance Traveled: " + nf(distanceTraveled/10, 1, 1) + " m", width/2, 200);
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
      case 2: statusText = 
        "Status: FOLLOWING"; 
        statusColor = #00C851;
        break;
      default: statusText = 
        "Status: UNKNOWN";
        statusColor = #666666;
    }
  }
  
  textSize(18);
  fill(statusColor);
  textAlign(CENTER, CENTER);
  text(statusText, width/2, height - 50);
}

void mousePressed() {
  if (resetDistanceBtn.isOver()) {
    distanceTraveled = 0.0;
    distance = 0;
    myClient.write("r");
    println("Distance reset");
  }
}
