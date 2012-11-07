/////////////////////////////////////////////////////////////
//                       Ball Class                        //
/////////////////////////////////////////////////////////////
/**
  Description:
  A simple moveable ball that the chain can drape over
**/

class Ball {
  PVector location;
  PVector velocity;
  boolean over = false, move = false;
  float r;
  
  Ball(PVector location, float diameter) {
    this.location = location.get();
    velocity = new PVector(0, 0, 0);
    this.r = diameter/2;
  }
  
  void update() {
    if (this.move) {
      this.location.set(mouseX, mouseY, 0);
    }
    // Check over.
    if (this.mouseOver()) {
      this.over = true;
    } else {
      this.over = false;
    }
  }
  
  void draw() {
    stroke(0, 150);
    strokeWeight(this.r*2);
    point(this.location.x, this.location.y);
  }
  
  boolean mouseOver() {
    return (PVector.sub(this.location, new PVector(mouseX, mouseY)).mag() < this.r);
  }
  
  void mousePressed() {
    if (this.over) {
      this.move = true;
    } else {
      this.move = false;
    }
  }
  
  void mouseReleased() {
    this.move = false;
    this.velocity.set(0, 0, 0);
  }
}
