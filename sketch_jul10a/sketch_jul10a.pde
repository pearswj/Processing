// Uniform Neighbour Model - Circle Packing (Petals)
// Will Pearson - July 2012

import processing.pdf.*;

float k, theta;
int r;

Petal p;

void setup() {
  k = 7; // no. petals
  theta = 360; // angle sum
  r = 75; // radius of centre circle
  
  p = new Petal(r, k, theta);
  
  size(600, 600);
  background(255);
}

void draw() {
  beginRecord(PDF, "petals.pdf");
  ellipse(width/2, height/2, r*2, r*2); // draw centre circle
  for (float a = 0; a < theta; a += theta / k) {
    p.draw(a); // draw petals
  }
  endRecord();
}

class Petal {
  float beta, r, r0; // radius

  Petal(float r0_, float k, float theta) {
    beta = sin(radians(theta/(2*k)));
    r = r0_*(beta/(1-beta));
    r0 = r0_;
  }

  void draw(float a) {
    float x, y;
    x = (r + r0) * sin(radians(a));
    y = (r + r0) * cos(radians(a));
    ellipse(width/2-x, height/2-y, r*2, r*2);
  }
}

