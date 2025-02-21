#include <WiFiS3.h>
#include "Arduino_LED_Matrix.h"

ArduinoLEDMatrix matrix;

const uint32_t wifi_check[] = {
    0x801402,
		0x20400801,
		0x200400
};
const uint32_t wifi_x[] = {
    0x20410809,
		0x600600,
		0x90108204
};

char ssid[] = "VODAFONE-0784"; // Add WiFi Name
char pass[] = "F9JPJMAADPDCXMHJ";  // Add WiFi password

const int slowSpeed = 255;
const int highSpeed = 120;

double distance_on_foward = 1;
double distance_traveled = 0;

const int REYE = 13; // Right IR Sensor digital pin 
const int LEYE = 12;  // Left IR Sensor digital pin

const int LM1 = 5; // Left Motor Logic Pin 1
const int LM2 = 4; // Left Motor Logic Pin 2
const int RM1 = 3; // Right Motor Logic Pin 1
const int RM2 = 7; // Right Motor Logic Pin 2

const int echoPin = 6; // Echo Pin for Ultrasonic
const int trigPin = 11; // Trig Pin for Ultrasonic

long duration; // Length of time for ultrasonic ping to return
int distance; // Distance from buggy to obstacle
bool keepDriving = false; // True if buggy receives instruction to start

int LEYE_Status = digitalRead( LEYE ); // Current status of Left IR Sensor
int REYE_Status = digitalRead( REYE ); // Current status of Right IR Sensor

WiFiServer server(5200); // Creating Server object

void setup() {
  Serial.begin(9600);
  pinMode( LM2, OUTPUT ); // Set Left Motor Logic pin 2 as output
  pinMode( LM1, OUTPUT ); // Set Left Motor Logic pin 1 as output
  pinMode( RM1, OUTPUT ); // Set Right Motor Logic pin 1 as output
  pinMode( RM2, OUTPUT ); // Set Right Motor Logic pin 2 as output
  pinMode( LEYE, INPUT ); // Set Left IR Sensor as input
  pinMode( REYE, INPUT ); // Set Right IR Sensor as input
  pinMode( LM2, LOW); // Set Left Motor Logic pin 2 to low
  pinMode( LM1, LOW); // Set Left Motor Logic pin 1 to low
  pinMode( RM1, LOW); // Set Right Motor Logic pin 1 to low
  pinMode( RM2, LOW); // Set Right Motor Logic pin 2 to low
  pinMode(trigPin, OUTPUT); // trigPin OUTPUT
  pinMode(echoPin, INPUT); // echoPin  INPUT
  distance = 0; // No obstacle in front
  WiFi.begin(ssid, pass); // Initialize the WiFi library's network settings
  IPAddress ip = WiFi.localIP(); // IP Address of arduino
  Serial.print("IP Address:"); 
  Serial.println(ip);
  server.begin(); // Tells server to listen for incoming connections
  matrix.begin();
}

void loop() {
  distance = Ultrasonic();
  
  WiFiClient client = server.available(); // Waiting for a client to connect
  if (client.connected()) {
    Serial.println("Connected");
    matrix.loadFrame(wifi_check); // loads check mark on led matrix to confirm wifi conncection
    char c = client.read();
    if (c == 'z'){ // If start signal received from client

      if (distance <= 10 || distance >= 2000) {
        S();
        server.write('o'); // Send the char 'o' to the Processor PC to signal an obstacle in front of the buggy
      } else {
        Drive();
        Serial.println("Distance Traveled: ");
        Serial.println(distance_traveled);
      }
      keepDriving = true; // Buggy has been started

    }

    if (c == 's'){ // If Stop signal received from client
      S();
      keepDriving = false; // Buggy has been stopped
    }
  }

  else{  // If client briefly disconnects
     if (keepDriving == true){  // Keep driving if previously driving
      if (distance <= 10 || distance >= 2000) {
        S();
        server.write('o'); // Send the char 'o' to the Processor PC to signal an obstacle in front of the buggy
      } else {
        Drive();
        Serial.println("Distance Traveled: ");
        Serial.println(distance_traveled);
      }
    } else {
      S();
    }
    matrix.loadFrame(wifi_x);
  }
}