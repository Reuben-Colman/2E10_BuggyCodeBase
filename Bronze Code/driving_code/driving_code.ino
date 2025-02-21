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

char ssid[] = "VODAFONE-0784"; // WiFi Name
char pass[] = "F9JPJMAADPDCXMHJ";  // WiFi password

const int slowSpeed = 255; // speed while turning
const int highSpeed = 120; // speed while going foward

const double distance_on_foward = 1; // distance traveled by 1 call of foward
double distance_traveled = 0; // global variable, distance traveled

const int REYE = 13; // Right IR Sensor pin 
const int LEYE = 12;  // Left IR Sensor pin

const int LM1 = 5; // Left Motor Pin 1
const int LM2 = 4; // Left Motor Pin 2
const int RM1 = 3; // Right Motor Pin 1
const int RM2 = 7; // Right Motor Pin 2

const int echoPin = 6; // Echo Pin for Ultrasonic Sensor
const int trigPin = 11; // Trig Pin for Ultrasonic Sensor

long duration; // Length of time for ultrasonic ping to return
int distance; // Distance from buggy to obstacle
bool keepDriving = false; // True if buggy receives instruction to start

int LEYE_Status = digitalRead( LEYE ); // Current status of Left IR Sensor
int REYE_Status = digitalRead( REYE ); // Current status of Right IR Sensor

WiFiServer server(5200); // Creating Server object

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
  distance = 0; // No obstacle in front
  WiFi.begin(ssid, pass); // Initialize the WiFi library's network settings
  IPAddress ip = WiFi.localIP(); // IP Address of arduino
  Serial.print("IP Address:"); // prints IP Address of Arduino to connect to with Processing
  Serial.println(ip);
  server.begin(); // Tells server to listen for incoming connections
  matrix.begin(); // initialises the led matrix
}

void loop() {
  distance = Ultrasonic(); // call ultrasonic to get distance to object
  
  WiFiClient client = server.available(); // Waiting for a client to connect
  if (client.connected()) {
    Serial.println("Connected"); // prints that the buggy connected to processing
    matrix.loadFrame(wifi_check); // loads check mark on led matrix to confirm wifi conncection
    char c = client.read(); // reads the imput from processing
    if (c == 'z'){ // If start signal received from client

      if (distance <= 10 || distance >= 2000) { // if obstical less then 10cm or greater then 2000 cm away then buggy stops, 2000 cm because if objstical close then gives inaccturae reading
        Stop(); // stops the buggy
        server.write('o'); // Send the char 'o' to the Processor PC to signal an obstacle in front of the buggy
      } else {
        Drive(); // calls the drive function
        Serial.println("Distance Traveled: "); // prints the distance traveld by the buggy so far
        Serial.println(distance_traveled);
      }
      keepDriving = true; // Buggy has been started

    }

    if (c == 's'){ // If Stop signal received from client
      Stop(); // stops the buggy
      keepDriving = false; // Buggy has been stopped
    }
  }

  else{  // If client briefly disconnects
     if (keepDriving == true){  // Keep driving if previously driving
      if (distance <= 10 || distance >= 2000) {
        Stop(); // stops the buggy
        server.write('o'); // Send the char 'o' to the Processor PC to signal an obstacle in front of the buggy
      } else {
        Drive(); // calls the drive function
        Serial.println("Distance Traveled: "); // prints the distance traveld by the buggy so far
        Serial.println(distance_traveled);
      }
    } else {
      Stop();// stops the buggy
    }
    matrix.loadFrame(wifi_x); // displays x on the led matrix, as wifi is not currently connected
  }
}