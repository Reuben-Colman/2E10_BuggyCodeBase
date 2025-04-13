class NumberInput {
  float x, y, width, height;
  float value = 0.0;
  boolean hasFocus = false;
  String inputText = "";
  ToggleSwitch switchRef;
  
  // Variable to store the last sent speed value
  float lastSentSpeed = 0;
  
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
