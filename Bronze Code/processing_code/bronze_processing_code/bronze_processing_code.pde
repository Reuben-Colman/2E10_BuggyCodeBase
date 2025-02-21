import controlP5.*;
import processing.net.*;

ControlP5 cp5; // Creation of controlP5 object
Client myClient; // Creation of Client object

void setup() {
size(800,700); // Set screen width to 800 and height to 700
cp5 = new ControlP5(this); // Initialise controlP5 object
myClient =new Client(this,"192.168.1.3",80); // Initialise Client object using Arduino IP Address

cp5.addButton("Start") // Add Start Button to screen
.setValue(0)
.setPosition(250,200)
.setSize(300,30); // Set size of button as width = 300 and height = 30

cp5.addButton("Stop") // Add Stop Button to screen
.setValue(0)
.setPosition(250,500)
.setSize(300,30);

rectMode(CENTER); //  Interpret the first two parameters of rect() as the shape's center point, while the third and fourth parameters are its width and height.
textAlign(CENTER, CENTER); //  Horizontal and vertical alignment respectively
}


int timeWhenObstacle;
int timeSinceObstacle ;

void draw() {
  char dataIn = 'a';
 
  if(myClient.available() > 0){ // If any bytes are available from the server return the number of bytes
    dataIn = myClient.readChar();
  }
   
  if (dataIn == 'o'){ // Proceed if an Obstacle has been detected
    timeWhenObstacle = millis(); // Store the time instant whe  an Obstacle was detected
  }
  timeSinceObstacle = millis() - timeWhenObstacle; // Calculate time since Obstacle detected
  
  if (timeSinceObstacle < 3000){ // Print Obstacle detected if an Obstacle has been detected
    fill(255);
    rect(400,380,200,20);
    fill(0);
    text("OBSTACLE DETECTED",400,380);
  }
  else{ // Remove the Obstacle Detected message from the text box
    fill(255);
    rect(400,380,200,20);
    fill(0);
    text("",400,380);
  }
 
  if (timeSinceObstacle > 3000 && timeSinceObstacle < 6000){ // If no Obstacle detected for 3 seconds print obstacle cleared for 3 seconds
  fill(255);
  rect(400,350,200,20);
  fill(0);
  text("OBSTACLE CLEARED",400,350);
  }
  else{ // Remove the Obstacle Cleared message from the text box after it has been displayed for 3 seconds
  fill(255);
  rect(400,350,200,20);
  fill(0);
  text("",400,350);
  }
}



public void Start() { // Start button functionality description
if (myClient.active()){
myClient.write("z"); // Write char z to the Arduino which is the client
println("Start Button Pressed");
}
background(0, 160, 0); // Set the background colour to green;
}

public void Stop() { // // Stop button functionality description
if (myClient.active()){
myClient.write("s");
println("Stop Button Pressed");
}
background(255, 0, 0); // Set the background colour to red;
}
