/**

Manifold and Conway Operations
Will Pearson, University of Bath, November 2012.

**/

//import peasy.*;
//PeasyCam cam;
float rot = 0; // To hold the cumulative rotation.

Manifold manifold, dual;

void setup() {
  size(700, 700, OPENGL);
  smooth(4);
  
  //cam = new PeasyCam(this, 100);
  
  // Manually create tetrahedron for testing puposes.
  Factory factory = new Factory(); 
  
  manifold = factory.pyramid(3, 1, true);
  //manifold = factory.prism(5, 1);
  //manifold = factory.antiprism(8);

  manifold.toSphere();
  dual = manifold.dual();
  
  manifold.debug(true);
  dual.debug(true);
}

void draw() {
  // Center and rotate.
  translate(width/2, height/2);
  scale(150);
  rotateX(radians(rot));
  rotateY(radians(rot));
  rot++;
  
  // Misc.
  background(255);
  lights();
  
  // Draw manifolds.
  manifold.drawEdges();
  //manifold.drawFaces(true);
  dual.drawFaces(true);
  dual.drawEdges();
  dual.drawVertices();
}
