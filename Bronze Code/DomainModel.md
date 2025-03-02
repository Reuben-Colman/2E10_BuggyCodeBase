```mermaid
flowchart LR
  A[WiFi Buggy Controller] -- Go / Stop / Reset --> C[Arduino]
  C -- Distance Traveled / Status --> A

  C ==> D[Left Motor]
  E[Right IRSensors] ==> C
  G[Left IRSensors] ==> C
  C ==> F[Ultrasonic Sensor]
  C ==> B[Right Motor]

  F -- Obstacle within 10cm --> C
  E -.-> B
  G -.-> D
```
Start Command Sent
```mermaid
sequenceDiagram
  Arduino ->> Ultrasonic Sensor: What is the distance to the next Obstacle?
  Ultrasonic Sensor ->> Arduino: It is 40cm 
  Arduino ->> Client1: Did i recieve a command?
  Client1 ->> Arduino: Yes, it was "Z" (Start)
  Arduino -->> Arduino: Update keep driving to true
  Arduino -->> Drive Function: The distance is grater then 10cm, Call
  Drive Function ->> IR Sesors: Are either sensor on the white line?
  IR Sesors ->> Drive Function: No!
  Drive Function ->> Motors: Both Motors go foward, and add to the distance traveled
  Arduino ->> Client2: Send the distance travel to the client
```
Stop Command Sent
```mermaid
sequenceDiagram
  Arduino ->> Ultrasonic Sensor: What is the distance to the next Obstacle?
  Ultrasonic Sensor ->> Arduino: It is 40cm 
  Arduino ->> Client1: Did i recieve a command?
  Client1 ->> Arduino: Yes, it was "S" (Stop)
  Arduino -->> Arduino: Update keep driving to flase
  Arduino -->> Stop Function: Call
  Stop Function ->> Motors: Stop Both Motors
  Arduino ->> Client2: Send the distance travel to the client
```
Obstacle within 10cm
```mermaid
sequenceDiagram
  Arduino ->> Ultrasonic Sensor: What is the distance to the next Obstacle?
  Ultrasonic Sensor ->> Arduino: It is 9cm 
  Arduino ->> Client1: Obstacle Detected
  Arduino ->> Client1: Did i recieve a command?
  Client1 ->> Arduino: Yes, it was "Z" (Start)
  Arduino -->> Arduino: Update keep driving to true
  Arduino -->> Stop Function: The distance was less then 10cm, Call
  Stop Function ->> Motors: Stop Both Motors
  Arduino ->> Client2: Send the distance travel to the client
```
No Command Recieved but keep driving is true
```mermaid
sequenceDiagram
  Arduino ->> Ultrasonic Sensor: What is the distance to the next Obstacle?
  Ultrasonic Sensor ->> Arduino: It is 40cm 
  Arduino ->> Client1: Did i recieve a command?
  Client1 ->> Arduino: No
  Arduino -->> Arduino: The Status of keep driving is true
  Arduino -->> Drive Function: The distance is grater then 10cm, Call
  Drive Function ->> IR Sesors: Are either sensor on the white line?
  IR Sesors ->> Drive Function: No!
  Drive Function ->> Motors: Both Motors go foward, and add to the distance traveled
  Arduino ->> Client2: Send the distance travel to the client
```
No Command Recieved but keep driving is false
```mermaid
sequenceDiagram
  Arduino ->> Ultrasonic Sensor: What is the distance to the next Obstacle?
  Ultrasonic Sensor ->> Arduino: It is 40cm 
  Arduino ->> Client1: Did i recieve a command?
  Client1 ->> Arduino: No
  Arduino -->> Arduino: The Status of keep driving is false
  Arduino -->> Stop Function: Call
  Stop Function ->> Motors: Stop Both Motors
  Arduino ->> Client2: Send the distance travel to the client
```
Drive Function Sequence sequenceDiagram
```mermaid
sequenceDiagram
  Drive Function ->> IR Sesors: Are either sensor on the white line?
  IR Sesors ->> Drive Function: No!
  Drive Function ->> Motors: Both Motors go foward, and add to the distance traveled
```
```mermaid
sequenceDiagram
  Drive Function ->> IR Sesors: Are either sensor on the white line?
  IR Sesors ->> Drive Function: Yes, the left one!
  Drive Function ->> Motors: Reverse the left motor
```
```mermaid
sequenceDiagram
  Drive Function ->> IR Sesors: Are either sensor on the white line?
  IR Sesors ->> Drive Function: Yes, the Right one!
  Drive Function ->> Motors: Reverse the right motor
```
