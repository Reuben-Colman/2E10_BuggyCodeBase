class ToggleSwitch {
  float x, y, switchWidth, switchHeight;
  color trackColor, knobColorOff, knobColorOn;
  int currentPosition; // 0=left, 1=middle, 2=right
  boolean dragging = false;
  
  ToggleSwitch(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.switchWidth = w;
    this.switchHeight = h;
    trackColor = #CCCCCC;
    knobColorOff = #FF4444;
    knobColorOn = #00C851;
    currentPosition = 1;
  }
  
  boolean isOver() {
    return mouseX > x && mouseX < x + switchWidth && 
           mouseY > y && mouseY < y + switchHeight;
  }
  
  void handleInput() {
    if (mousePressed && isOver()) {
      dragging = true;
      float clickX = mouseX - x;
      if (clickX < switchWidth/3) currentPosition = 0;
      else if (clickX < 2*switchWidth/3) currentPosition = 1;
      else currentPosition = 2;
    }
    if (!mousePressed) dragging = false;
  }
  
  void display() {
    // Draw track
    fill(trackColor);
    rect(x, y + switchHeight/4, switchWidth, switchHeight/2, 10);
    
    // Calculate knob position
    float knobX;
    switch(currentPosition) {
      case 0: knobX = x + 20; break;
      case 1: knobX = x + switchWidth/2; break;
      default: knobX = x + switchWidth - 20;
    }
    
    // Calculate color
    color knobColor = (currentPosition == 1) ? knobColorOff : knobColorOn;
    
    
    // Hover effect
    if (isOver() || dragging) {
      knobColor = lerpColor(knobColor, color(255), 0.2);
    }
    
    // Draw sliding knob
    fill(knobColor);
    rect(knobX - 15, y, 30, switchHeight, 8);
    
    // Draw labels
    fill(#666666);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("Driving", x + 20, y + switchHeight + 15);
    text("OFF", x + switchWidth/2, y + switchHeight + 15);
    text("Following", x + switchWidth - 20, y + switchHeight + 15);
  }
}
