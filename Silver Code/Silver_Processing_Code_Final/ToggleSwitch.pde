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
