#include <WiFiS3.h>
#include "Arduino_LED_Matrix.h"

ArduinoLEDMatrix matrix;

// PC will only connect momentarily, so will flash with check mark
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

char ssid[] = "VODAFONE-5C78";       // WiFi Name
char pass[] = "9F34MP2P2FJ4K3BD";  // WiFi password

// Buggy Distance Traveled Variables
double distance_traveled = 0; // global variable, distance traveled
char j;
char q;
double EncoderSpeed = 0; // buggy speed as measured by encoders

int speedFollow = 0;
int speedRef; // cm/s
// Removed stray constrain(speedRef, 0, 50);

// PID Tracking Variables
double previous_distancePID = 0, prev_speedPID = 0;
unsigned long previousTimePID = 0; // only one previous time variable needed
unsigned long currentTimePID;
double elapsedTimePID;
double errorPID;
double lastErrorPID = 0;
double input, output, setPoint, last_out = 0;
double intError = 0, devError = 0;  // initialize integral error

double kpF = 3.5;
double kiF = 0.00004;
double kdF = 1;
double kpS = 0.3; 
double kiS = 3.5; 
double kdS = 1.2;

double inputS, outputS, setPointS = 0.0; // Initialize setPointS
double inputF, outputF, setPointF = 10.0; // Set a reference distance for following

// Arduino PINS
const int REYE = 13; // Right IR Sensor pin 
const int LEYE = 12; // Left IR Sensor pin

const int LM1 = 9; // Left Motor Pin 1
const int LM2 = 5; // Left Motor Pin 2

const int RM1 = 6; // Right Motor Pin 1
const int RM2 = 3; // Right Motor Pin 2

const int echoPin = 4; // Echo Pin for Ultrasonic Sensor
const int trigPin = 11; // Trig Pin for Ultrasonic Sensor

const int RENC = 1; // Right Encoder Pin
const int LENC = 0; // Left Encoder Pin

// Encoders
volatile int pulseCountSpeed = 0; // Stores encoder pulse count for distance
volatile long pulseCountDist  = 0;
unsigned long lastSpeedTime = 0;
unsigned long lastDistTime = 0;

const float distancePulse = (2 * 3.1416 * 0.65/2) / 8;

//-------------------
char keepDriving = 's'; // Use character literal instead of string literal
int speedRefNom;

// Ultrasonic
long duration; // Length of time for ultrasonic ping to return
int distance = 0; // Distance from buggy to obstacle

// IR Sensors
int LEYE_Status; // declared globally; will be updated in functions
int REYE_Status;

// Wifi
WiFiServer server(5200); // Creating Server1, for commands e.g. z, s, f, r
WiFiServer server2(5800); // Creating Server2, for obstacle detection
WiFiServer server3(6000); // Creating Server3, for speed relayed back
WiFiServer server4(6200); // Creating Server4, for speed input for reference speed


void setup() {
  Serial.begin(9600);

  // Encoders 
  pinMode(LENC, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(LENC), encoderISR, RISING);

  // Motors
  pinMode(LM2, OUTPUT); // Set Left Motor pin 2 as output
  pinMode(LM1, OUTPUT); // Set Left Motor pin 1 as output
  pinMode(RM1, OUTPUT); // Set Right Motor pin 1 as output
  pinMode(RM2, OUTPUT); // Set Right Motor pin 2 as output

  digitalWrite(LM2, LOW); // Set Left Motor Logic pin 2 to low
  digitalWrite(LM1, LOW); // Set Left Motor Logic pin 1 to low
  digitalWrite(RM1, LOW); // Set Right Motor Logic pin 1 to low
  digitalWrite(RM2, LOW); // Set Right Motor Logic pin 2 to low

  // IR Sensors
  pinMode(LEYE, INPUT); // Set Left IR Sensor as input
  pinMode(REYE, INPUT); // Set Right IR Sensor as input

  // Ultrasonic Sensor
  pinMode(trigPin, OUTPUT); // trigPin OUTPUT
  pinMode(echoPin, INPUT);  // echoPin INPUT

  // Wifi
  WiFi.begin(ssid, pass);   // Initialize the WiFi library's network settings
  if(Serial.println(WiFi.localIP()) != "0.0.0.0"){
    Serial.print("IP Address:");
    Serial.println(WiFi.localIP());
  }
  server.begin();  // Tells server to listen for incoming connections
  server2.begin();
  server3.begin();
  server4.begin();

  matrix.begin();  // Initializes the LED matrix
}

void loop() {
  //Serial.println("----------- NEW LOOP ----------");
  distance = Ultrasonic(); // call ultrasonic to get distance to object
  //Serial.print("Distance: ");
  //Serial.println(distance);
  WiFiClient client4 = server4.available(); // Arduino server available to connect
  if (client4.connected()) { // if the client sends data to Arduino
    RefSpeedInput(client4); // run the client connection function 
  }

  WiFiClient client1 = server.available(); // Arduino server available to connect
  if (client1.connected()) { // if the client sends data to Arduino
    ClientConnected(client1); // run the client connection function 
  }
  else {  // If client is not connected
    DrivingStatus();
  }

  
  //Serial.println(keepDriving);
  encoderSpeed();
  encoderDistance();
  processingDistance(distance_traveled); // Sends distance traveled to Processing
  processingSpeed(EncoderSpeed); // Missing semicolon added
  //Serial.println(WiFi.localIP());
}