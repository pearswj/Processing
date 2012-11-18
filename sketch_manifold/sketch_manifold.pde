/**
 
 Manifold and Conway Operations
 Will Pearson, University of Bath, November 2012.
 
 */

import peasy.*;
PeasyCam cam;
//float rot = 0; // To hold the cumulative rotation.

Manifold manifold, test;

void setup() {
  size(700, 700, OPENGL);
  smooth(4);

  cam = new PeasyCam(this, 400);

  // Manually create tetrahedron for testing puposes.
  Factory factory = new Factory(); 

  manifold = factory.pyramid(3, 1, true);
  //manifold = factory.prism(5, 1);
  //manifold = factory.antiprism(8);

  manifold.toSphere();
  //test = manifold.catmullClark().catmullClark().catmullClark();
  test = manifold.loop().loop().loop();

  manifold.debug(true);
  test.debug(true);
}

void draw() {
  // Center and rotate.
  //translate(width/2, height/2);
  scale(150);
  //rotateX(radians(rot));
  //rotateY(radians(rot));
  //rot++;

  // Misc.
  background(255);
  lights();

  // Draw manifolds.
  manifold.drawEdges();
  //manifold.drawFaces(true);
  test.drawFaces(false);
  //test.drawEdges();
  //test.drawVertices();
}

