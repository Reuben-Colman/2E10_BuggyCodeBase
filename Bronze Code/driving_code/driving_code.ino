#include <WiFiS3.h>
#include "Arduino_LED_Matrix.h"

ArduinoLEDMatrix matrix;

// PC will only connect mementerally, so will flash with check mark
const uint32_t wifi_check[] = { // check mark displayed on led matrix while connected to pc
    0x801402,
		0x20400801,
		0x200400
};
const uint32_t wifi_x[] = { // x displayed on led matrix while not connected to pc
    0x20410809,
		0x600600,
		0x90108204
};

char ssid[] = "A15"; // WiFi Name
char pass[] = "sean1234";  // WiFi password

//Driving Speeds
const int slowSpeed = 255; // speed while turning
cnst int highSpeed = 130; // speed while going foward

//Buggy Distance Traveled Variables
const double distance_on_foward = 0.005/2; // distance traveled by 1 call of foward
double distance_traveled = 0; // global variable, distance traveled
char j;

//Arduino PINS
const int REYE = 13; // Right IR Sensor pin 
const int LEYE = 12;  // Left IR Sensor pin

const int LM1 = 5; // Left Motor Pin 1
const int LM2 = 4; // Left Motor Pin 2
const int RM1 = 3; // Right Motor Pin 1
const int RM2 = 7; // Right Motor Pin 2

const int echoPin = 6; // Echo Pin for Ultrasonic Sensor
const int trigPin = 11; // Trig Pin for Ultrasonic Sensor

//Ultrasonic variables
long duration; // Length of time for ultrasonic ping to return
int distance = 0; // Distance from buggy to obstacle
bool keepDriving = false; // True if buggy receives instruction to start

int LEYE_Status = digitalRead( LEYE ); // Current status of Left IR Sensor
int REYE_Status = digitalRead( REYE ); // Current status of Right IR Sensor

WiFiServer server(5200); // Creating Server1
WiFiServer server2(5800); // Creating Server2

void setup() {
  Serial.begin(9600);
  pinMode( LM2, OUTPUT ); // Set Left Motor pin 2 as output
  pinMode( LM1, OUTPUT ); // Set Left Motor pin 1 as output
  pinMode( RM1, OUTPUT ); // Set Right Motor pin 1 as output
  pinMode( RM2, OUTPUT ); // Set Right Motor pin 2 as output
  pinMode( LEYE, INPUT ); // Set Left IR Sensor as input
  pinMode( REYE, INPUT ); // Set Right IR Sensor as input
  pinMode( LM2, LOW); // Set Left Motor Logic pin 2 to low
  pinMode( LM1, LOW); // Set Left Motor Logic pin 1 to low
  pinMode( RM1, LOW); // Set Right Motor Logic pin 1 to low
  pinMode( RM2, LOW); // Set Right Motor Logic pin 2 to low
  pinMode(trigPin, OUTPUT); // trigPin OUTPUT
  pinMode(echoPin, INPUT); // echoPin  INPUT
  WiFi.begin(ssid, pass); // Initialize the WiFi library's network settings
  IPAddress ip = WiFi.localIP(); // IP Address of arduino
  Serial.print("IP Address:"); // prints IP Address of Arduino to connect to with Processing
  Serial.println(ip);
  server.begin(); // Tells server to listen for incoming connections
  server2.begin();
  matrix.begin(); // initialises the led matrix
}

void loop() {
  distance = Ultrasonic(); // call ultrasonic to get distance to object

  WiFiClient client = server.available(); // arduino server is avaliable to connect
  if (client.connected()) { // if the client sends data to arduino
    ClientConnected(client); //runs the client connection function 
  }
  else{  // If client is not connected
     DrivingStatus();
  }

  processingDistance(distance_traveled); //Sends distance traveled to processing
}