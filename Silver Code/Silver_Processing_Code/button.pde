class Button { // reset button 
  String label;
  float x, y, w, h;
  color btnColor, baseColor;
  
  Button(String label, float x, float y, float w, float h, color c) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.baseColor = c;
    this.btnColor = c;
  }
  
  boolean isOver() {
    return mouseX > x && mouseX < x + w && 
           mouseY > y && mouseY < y + h;
  }
  
  void display() {
    // Hover effect
    btnColor = isOver() ? lerpColor(baseColor, color(255, 255, 255), 0.2) : baseColor;
    
    // Button body
    fill(btnColor);
    rect(x, y, w, h, 5);
    
    // Button text
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(label, x + w/2, y + h/2);
  }
}
