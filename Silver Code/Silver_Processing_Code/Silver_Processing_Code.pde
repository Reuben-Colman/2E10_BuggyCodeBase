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
int speed = 0;
Button resetDistanceBtn;
ToggleSwitch threeWaySwitch;
Speedometer mySpeedometer;
int lastPosition = -1; // To track switch position changes
float radius = 140;
NumberInput speedInput;

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
  resetDistanceBtn = new Button("RESET", width/2 - 75, 135, 150, 40, #FF5555);
  mySpeedometer = new Speedometer(width/2, height/2, 125, font);
  speedInput = new NumberInput(width/2 - 50, 350, 100, 40);
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
  
  speedInput.display();
  speedInput.handleInput();
  
  // Handle 3-way switch
  threeWaySwitch.handleInput();
  threeWaySwitch.display();
  handleSwitchPosition();
  
  mySpeedometer.setSpeed(speed);
  mySpeedometer.display();
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
  textSize(25);
  text("Distance Traveled: " + nf(distanceTraveled/10, 1, 1) + " m", width/2, 100);
}
  
void drawBuggySpeed() {
  fill(#666666);
  textSize(25);
  text("Buggy Speed: " + nf(speed/10, 1, 1) + " m/s", width/2, 550);
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
