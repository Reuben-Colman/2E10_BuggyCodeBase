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
String IP = "192.168.1.37";

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
      myClient4.write(speedInput.getFinalizedSpeed());
      println("Sent speed: " + speedInput.getFinalizedSpeed());
    } else {
      println("Speed client not connected. Unable to send speed.");
    }
    
    lastPosition = threeWaySwitch.currentPosition;
  }
  
  // Removed continuous sending from here to send only on update.
}

// Keep the rest of your code (Button, Speedometer, drawTitle, etc.) unchanged.

// ============ CLASS DEFINITIONS ============ 

class ToggleSwitch {
  static final int DRIVING = 0;
  static final int OFF = 1;
  static final int FOLLOWING = 2;
  
  float x, y, switchWidth, switchHeight;
  color trackColor, knobColorOff, knobColorOn;
  int currentPosition;
  boolean dragging = false;
  
  ToggleSwitch(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.switchWidth = w;
    this.switchHeight = h;
    trackColor = #CCCCCC;
    knobColorOff = #FF4444;
    knobColorOn = #00C851;
    currentPosition = OFF;
  }

  boolean isOver() {
    return mouseX > x && mouseX < x + switchWidth && 
           mouseY > y && mouseY < y + switchHeight;
  }

  void handleInput() {
    if (mousePressed && isOver()) {
      dragging = true;
      float clickX = mouseX - x;
      if (clickX < switchWidth/3) currentPosition = DRIVING;
      else if (clickX < 2*switchWidth/3) currentPosition = OFF;
      else currentPosition = FOLLOWING;
    }
    if (!mousePressed) dragging = false;
  }

  void display() {
    // Track
    fill(trackColor);
    rect(x, y + switchHeight/4, switchWidth, switchHeight/2, 10);
    
    // Knob
    float knobX = x + 20; // Default to DRIVING
    if (currentPosition == OFF) knobX = x + switchWidth/2;
    else if (currentPosition == FOLLOWING) knobX = x + switchWidth - 20;
    
    color knobColor = (currentPosition == OFF) ? knobColorOff : knobColorOn;
    if (dragging || isOver()) knobColor = lerpColor(knobColor, color(255), 0.2);
    
    fill(knobColor);
    rect(knobX - 15, y, 30, switchHeight, 8);
    
    // Labels
    fill(#666666);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("Driving", x + 20, y + switchHeight + 15);
    text("OFF", x + switchWidth/2, y + switchHeight + 15);
    text("Following", x + switchWidth - 20, y + switchHeight + 15);
  }
}

class NumberInput {
  float x, y, width, height;
  float value = 0.0;
  boolean hasFocus = false;
  String inputText = "";
  ToggleSwitch switchRef;
  
  // Variable to store the last sent speed value
  float lastSentSpeed = -1.0;
  
  NumberInput(float x, float y, float w, float h, ToggleSwitch sw) {
    this.x = x;
    this.y = y;
    this.width = w;
    this.height = h;
    this.switchRef = sw;
  }

  void display() {
    if (switchRef.currentPosition != ToggleSwitch.DRIVING) return;
    
    // Text box
    fill(255);
    stroke(hasFocus ? #00C851 : #666666);
    strokeWeight(hasFocus ? 2 : 1);
    rect(x, y, width, height, 5);
    
    // Display text: if in focus, show raw input; otherwise show formatted value
    String displayText = hasFocus ? inputText : nf(value, 1, 1);
    fill(#333333);
    textSize(height * 0.6);
    textAlign(CENTER, CENTER);
    text(displayText, x + width/2, y + height/2);
  }

  void handleClick() {
    if (switchRef.currentPosition != ToggleSwitch.DRIVING) return;
    
    if (mouseX > x && mouseX < x + width && 
        mouseY > y && mouseY < y + height) {
      hasFocus = true;
      // Optionally, you can clear inputText here if desired:
      // inputText = "";
    } else {
      updateValueFromInput(); // Finalize input when focus is lost
      hasFocus = false;
    }
  }

  void keyPressed() {
    if (hasFocus && switchRef.currentPosition == ToggleSwitch.DRIVING) {
      if (key == BACKSPACE && inputText.length() > 0) {
        inputText = inputText.substring(0, inputText.length()-1);
      } 
      else if (key == ENTER || key == RETURN) {
        updateValueFromInput(); // Finalize input on ENTER
        hasFocus = false;
      }
      else if (Character.isDigit(key) || (key == '.' && inputText.indexOf('.') == -1)) {
        inputText += key;
        // Do not update the value immediately; wait until input is finalized.
      }
    }
  }

  // This function finalizes the value and sends it if it has changed
  private void updateValueFromInput() {
    try {
      if (inputText.startsWith(".")) inputText = "0" + inputText;
      
      if (inputText.isEmpty()) {
        value = 0.0;
        return;
      }
      
      // Convert the raw input to a float and constrain it
      value = constrain(float(inputText), 0, 50.0);
      inputText = str(value); // Update the displayed input
      
      // Send only if the value has changed
      if (value != lastSentSpeed) {
        sendSpeedCommand();
        lastSentSpeed = value;
      }
    } 
    catch (Exception e) {
      value = 0.0;
      inputText = "";
      println("Error sending data: " + e.getMessage());
    }
  }
  
  // Helper function to check if the speed value has been finalized (not while typing)
  boolean hasFinalizedValue() {
    return !hasFocus;
  }
  
  // Returns the current finalized speed as a string (without the newline)
  String getFinalizedSpeed() {
    return str(value);
  }
  
  // Sends the finalized speed value over client4 to the Arduino
  private void sendSpeedCommand() {
    if (myClient4.active() && switchRef.currentPosition == ToggleSwitch.DRIVING) {
      char speedCommand = (char)value;
      myClient4.write(speedCommand);
      println("Sent speed: " + speedCommand);
    }
  }
}

// Keep the existing implementations for the Button, Speedometer, drawStatusMessages, ArduinoData, mousePressed, keyPressed, etc.

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

class Speedometer {
  float x, y;
  float radius;
  float speed;
  PFont font;
  float needleLength;
  color arcColor = #CCCCCC;
  color needleColor = #FF0000;
  color textColor = #666666;
  int numLabels = 11;
  float minSpeed = 0;
  float maxSpeed = 100;

  Speedometer(float x, float y, float radius, PFont font) {
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.font = font;
    this.needleLength = radius * 0.8;
  }

  void setSpeed(float speed) {
    this.speed = constrain(speed, minSpeed, maxSpeed);
  }

  void display() {
    pushStyle();
    drawArc();
    drawLabels();
    drawNeedle();
    drawSpeedText();
    popStyle();
  }

  private void drawArc() {
    noFill();
    stroke(arcColor);
    strokeWeight(6);
    arc(x, y + 5, radius * 2, radius * 2, PI, TWO_PI);
  }

  private void drawLabels() {
    for (int i = 0; i < numLabels; i++) {
      float angle = map(i, 0, numLabels - 1, PI, TWO_PI);
      float xPos = x + cos(angle) * (radius + 10);
      float yPos = y + sin(angle) * (radius + 10);
      stroke(#CCCCCC);
      textAlign(CENTER, CENTER);
      text(i * 10, xPos, yPos);
    }
  }

  private void drawNeedle() {
    float needleAngle = map(speed, minSpeed, maxSpeed, PI, TWO_PI);
    float needleX = x + cos(needleAngle) * needleLength;
    float needleY = y + sin(needleAngle) * needleLength;
    stroke(needleColor);
    strokeWeight(3);
    line(x, y, needleX, needleY);
  }

  private void drawSpeedText() {
    fill(#666666);
    textFont(font);
    textSize(18);
    textAlign(CENTER, CENTER);
    text(nf(speed, 0, 0), x - 20, y + 20);
    text("cm/s", x + 20, y + 20);
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
