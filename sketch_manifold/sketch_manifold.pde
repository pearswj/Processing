/**
Manifold and Conway Operations
Will Pearson, University of Bath, November 2012.
**/

import peasy.*;
//PeasyCam cam;
float rot = 0; // To hold the cumulative rotation.

Manifold manifold;

void setup() {
  size(800, 800, OPENGL);
  smooth(4);
  
  // Set up Peasycam.
  //cam = new PeasyCam(this, 100);
  
  // Manually create tetrahedron for testing puposes.
  manifold = new Manifold();
  
  //manifold = manifold.tetrahedron(1);
  manifold = manifold.cube(1);
}

void draw() {
  // Center and rotate.
  translate(width/2, height/2);
  scale(200);
  rotateX(radians(rot));
  rotateY(radians(rot));
  rot++;
  
  background(255);
  lights();
  
  //manifold.drawFaces();
  manifold.drawEdges();
  manifold.drawVertices();
}
