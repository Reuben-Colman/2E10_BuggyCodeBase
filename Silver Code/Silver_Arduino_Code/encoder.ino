encoder(){
  unsigned long currentTime = millis();
    float elapsedTime = (currentTime - lastTime) / 1000.0; // Convert to seconds

    if (elapsedTime >= 1.0) {  // Calculate speed every second
        float wheelRotations = (float)pulseCount / PULSES_PER_CYCLE;
        float speed = wheelRotations * WHEEL_CIRCUMFERENCE; // Speed in meters per second

        Serial.print("Speed: ");
        Serial.print(speed, 3); // Print speed with 3 decimal places
        Serial.println(" m/s");

        // Reset values
        pulseCount = 0;
        lastTime = currentTime;
    }
}

// Interrupt Service Routine (ISR) for counting pulses
  void countPulses() {
    pulseCount++;  // Increment count on each rising edge
}