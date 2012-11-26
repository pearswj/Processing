/**
 
 Manifold and Conway Operations
 Will Pearson, University of Bath, November 2012.
 
 */

import peasy.*;
import controlP5.*;

PeasyCam cam;
ControlP5 cp5;
Controller primitive;

Manifold manifold;

void setup() {
  size(700, 700, OPENGL);
  smooth(4);

  cam = new PeasyCam(this, 600);

  //---------------------------------------------------------//
  //                        ControlP5                        //
  //---------------------------------------------------------//

  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  cp5.setBroadcast(false);
  
  primitive = cp5.addButton("pyramid") // default
     .setValue(3)
     .setPosition(50,50)
     .setSize(100,20)
     .setId(0)
     ;
  cp5.addButton("prism")
     .setValue(3)
     .setPosition(50,70)
     .setSize(100,20)
     .setId(1)
     ;
  cp5.addButton("antiprism")
     .setValue(3)
     .setPosition(50,90)
     .setSize(100,20)
     .setId(2)
     ;

  Slider s = cp5.addSlider("numSides")
                .setPosition(50, 130)
                .setSize(100,20)
                .setRange(3, 25)
                .setId(3)
                ;
  
  //l.plugTo(factory);
  cp5.setBroadcast(true);
                
  gui(); // desturate...
  s.setValue(3); // with primitive set to "pyramid", draw a tetrahedron to kick things off...

  //---------------------------------------------------------//

  // TODO: Implement these methods in ControlP5
  
  //manifold.toSphere();
  //test = manifold.catmullClark();
  //test = manifold.loop();

  //manifold.debug(false);
  //manifold.exportOBJ();
  //test.exportVRML();
}

void draw() {
  scale(150);

  // Misc.
  background(255);
  lights();

  // Draw manifolds.
  manifold.drawEdges();
  manifold.drawFaces(false);
  //test.drawFaces(false);
  //test.drawEdges();
  //test.drawVertices(true);

  noLights();
  gui();
}

void gui() {
  // http://www.sojamo.de/libraries/controlP5/examples/extra/ControlP5withPeasyCam/ControlP5withPeasyCam.pde
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void  numSides(int n) {
  primitive.setValue(n);
  //primitive.update();
}

void controlEvent(ControlEvent theEvent) {
  //println(theEvent.controller().name()+" = "+theEvent.value());
  int n = (int)cp5.getController("numSides").getValue();
  int id = theEvent.controller().getId();
  Factory factory = new Factory();
  switch(id) {
    case(0):
    manifold = factory.pyramid(n, 1, true);
    break;
    case(1):
    manifold = factory.prism(n, 1);
    break;
    case(2):
    manifold = factory.antiprism(n, 1);
    break;
  }
  if (id == 0 || id == 1 || id == 2) {
    primitive = theEvent.controller();
  }
}

