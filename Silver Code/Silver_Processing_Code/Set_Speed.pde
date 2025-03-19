class NumberInput {
  float x, y, width, height;
  float value = 0.0;
  boolean hasFocus = false;
  String inputText = "";
  Button plusBtn, minusBtn;
  
  NumberInput(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.width = w;
    this.height = h;
    
    // Create +/- buttons (circular)
    float btnSize = h * 0.8;
    this.minusBtn = new Button("-", x - btnSize - 10, y, btnSize, btnSize, #CCCCCC);
    this.plusBtn = new Button("+", x + w + 10, y, btnSize, btnSize, #CCCCCC);
  }
  
  void display() {
    if (threeWaySwitch.currentPosition != 0) return;
    
    // Text box
    fill(255);
    stroke(hasFocus ? #00C851 : #666666);
    strokeWeight(hasFocus ? 2 : 1);
    rect(x, y, width, height, 5);
    
    // Text content
    fill(#333333);
    textSize(height * 0.6);
    textAlign(CENTER, CENTER);
    String displayText = hasFocus ? inputText : nf(value, 0, 1);
    text(displayText, x + width/2, y + height/2);
    
    // Buttons
    minusBtn.display();
    plusBtn.display();
  }
  
  void handleInput() {
    if (threeWaySwitch.currentPosition != 0) return;
    
    if (minusBtn.isOver() && mousePressed) {
      value = max(0, value - 0.1);
      inputText = "";
    }
    if (plusBtn.isOver() && mousePressed) {
      value = min(10.0, value + 0.1); // Max 10.0
      inputText = "";
    }
  }
  
  void handleClick() {
    if (threeWaySwitch.currentPosition != 0) return;
    
    // Check text box click
    if (mouseX > x && mouseX < x + width && 
        mouseY > y && mouseY < y + height) {
      hasFocus = true;
      inputText = "";
    } else {
      hasFocus = false;
      // Validate input when losing focus
      try {
        value = float(inputText);
        value = constrain(value, 0, 10.0);
      } catch (Exception e) {
        value = 0.0;
      }
      inputText = "";
    }
  }
  
  void keyPressed() {
    if (hasFocus && threeWaySwitch.currentPosition == 0) {
      if (key == BACKSPACE && inputText.length() > 0) {
        inputText = inputText.substring(0, inputText.length()-1);
      } 
      else if (Character.isDigit(key) || (key == '.' && !inputText.contains("."))) {
        inputText += key;
      }
    }
  }
}
