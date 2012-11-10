/**
Manifold and Conway Operations
Will Pearson, University of Bath, November 2012.
**/

import peasy.*;
PeasyCam cam;

Manifold manifold;

void setup() {
  size(800, 800, OPENGL);
  smooth(4);
  
  //translate(width/2, height/2);
  //scale(50);
  
  // Set up Peasycam.
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  
  // Manually create tetrahedron for testing puposes.
  manifold = new Manifold();
  
  manifold.addVertex(new PVector(20, 0, -20/sqrt(2)));
  manifold.addVertex(new PVector(-20, 0, -20/sqrt(2)));
  manifold.addVertex(new PVector(0, 20, 20/sqrt(2)));
  manifold.addVertex(new PVector(0, -20, 20/sqrt(2)));
  
  manifold.addFace(new int[]{0, 2, 3});
  manifold.addFace(new int[]{1, 3, 2});
  manifold.addFace(new int[]{0, 1, 2});
  manifold.addFace(new int[]{0, 3, 1});
}

void draw() {
  background(255);
  lights();
  manifold.drawFaces();
  manifold.drawEdges();
  manifold.drawVertices();
}
