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

boolean showVertices = false;
boolean showVertexNormals = false;
boolean showEdges = true;
boolean showFaces = true;
boolean showFaceNormals = false;

void setup() {
  size(700, 700, OPENGL);
  smooth(4);

  cam = new PeasyCam(this, 600);
  
  manifold = new Manifold();
  
  // debug dual with boundaries...
//  Factory factory = new Factory();
//  manifold.set(factory.pyramid(3, 1, true));
//  manifold.debug(true);
//  println("Trying to remove face 0...");
//  manifold.removeFace(manifold.faces()[0]);
//  manifold.debug(true);
//  println("Sorting edges for vertex 0...");
//  manifold.vertices()[0].sortEdges();
//  manifold.debug(false);
//  println("Trying to dual...");
//  manifold.dual();
//  println("Dual successful!");
  
  
  //---------------------------------------------------------//
  //                        ControlP5                        //
  //---------------------------------------------------------//

  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  cp5.setBroadcast(false);
  
  // SEEDS
  Group seeds = cp5.addGroup("seeds").setBackgroundColor(color(0, 64)).setBackgroundHeight(140);
  
  primitive = cp5.addButton("pyramid").setPosition(20,20).setSize(100,20) // default
     .setValue(3).setId(0).moveTo(seeds);
  cp5.addButton("prism").setPosition(20,40).setSize(100,20)
     .setValue(3).setId(1).moveTo(seeds);
  cp5.addButton("antiprism").setPosition(20,60).setSize(100,20)
     .setValue(3).setId(2).moveTo(seeds);
  //cp5.addTextlabel("type").setText("TYPE").setPosition(120, 40).moveTo(primitives);

  Slider s = cp5.addSlider("numSides").setPosition(20, 100).setSize(100,20).setRange(3, 25)
                .moveTo(seeds).setLabel("num sides");
  
  // MODIFIERS
  Group modifiers = cp5.addGroup("modifiers").setBackgroundColor(color(0, 64)).setBackgroundHeight(140);
  // Conway operations
  cp5.addButton("dual").setPosition(20,20).setSize(100,20)
     .plugTo(manifold).moveTo(modifiers);
  // Misc
  cp5.addButton("toSphere").setPosition(20,40).setSize(100,20)
     .plugTo(manifold).moveTo(modifiers);
  // Subdivision
  cp5.addButton("catmullClark").setPosition(20,60).setSize(100,20)
     .plugTo(manifold).moveTo(modifiers);
  cp5.addButton("loop").setPosition(20,80).setSize(100,20)
     .plugTo(manifold).moveTo(modifiers);
  // Debug
  cp5.addButton("removeFace").setPosition(20,100).setSize(100,20)
     .plugTo(manifold).moveTo(modifiers);
  
  // EXPORTERS
  Group exporters = cp5.addGroup("exporters").setBackgroundColor(color(0, 64)).setBackgroundHeight(80)
                       .setLabel("export");
  // 3D face/vertex/colour
  cp5.addButton("exportOBJ").setPosition(20,20).setSize(100,20)
     .plugTo(manifold).moveTo(exporters);
  cp5.addButton("exportVRML").setPosition(20,40).setSize(100,20)
     .plugTo(manifold).moveTo(exporters);
  // Debug
  cp5.addButton("debug").setPosition(20,60).setSize(100,20)
     .plugTo(manifold).moveTo(exporters);
  
  // VIEWERS
  Group viewers = cp5.addGroup("viewers").setBackgroundColor(color(0, 64)).setBackgroundHeight(150)
                         .setLabel("view options");
  
  cp5.addToggle("showVertices").setPosition(20,20).setSize(20,20).moveTo(viewers);
  cp5.addToggle("showVertexNormals").setPosition(100,20).setSize(20,20).moveTo(viewers);
  cp5.addToggle("showEdges").setPosition(20,60).setSize(20,20).moveTo(viewers);
  cp5.addToggle("showFaces").setPosition(20,100).setSize(20,20).moveTo(viewers);
  cp5.addToggle("showFaceNormals").setPosition(100,100).setSize(20,20).moveTo(viewers);

  Accordion accordion = cp5.addAccordion("acc")
                 .setPosition(40,40).setWidth(200)
                 .addItem(seeds).addItem(modifiers).addItem(exporters).addItem(viewers);
  accordion.open(0);
  accordion.setCollapseMode(Accordion.SINGLE);
  
  cp5.setBroadcast(true);
                
  gui(); // desturate...
  s.setValue(3); // with primitive set to "pyramid", draw a tetrahedron to kick things off...

  //---------------------------------------------------------//
}

void draw() {
  scale(150);

  // Misc.
  background(255);
  lights();

  // Draw manifolds.
  if (showVertices) {
    manifold.drawVertices(showVertexNormals);
  }
  if (showEdges) {
    manifold.drawEdges();
  }
  if (showFaces) {
    manifold.drawFaces(showFaceNormals);
  }

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
  //unplug();
  //plug();
}

void removeFace(int n) {
  manifold.removeFace(manifold.faces()[0]);
}

void controlEvent(ControlEvent theEvent) {
  //println(theEvent.controller().name()+" = "+theEvent.value());
  if (!theEvent.isGroup()) {
    int id = theEvent.controller().getId();
    if (id == 0 || id == 1 || id == 2) { // if one of the primitive buttons is pushed
      int n = (int)cp5.getController("numSides").getValue();
      Factory factory = new Factory();
      //unplug();
      switch(id) {
        case(0):
        manifold.set(factory.pyramid(n, 1, true));
        break;
        case(1):
        manifold.set(factory.prism(n, 1));
        break;
        case(2):
        manifold.set(factory.antiprism(n, 1));
        break;
      }
      primitive = theEvent.controller();
      //plug();
    }
  }
}

void unplug() {
  cp5.getController("exportOBJ").unplugFrom(manifold);
  cp5.getController("exportVRML").unplugFrom(manifold);
  cp5.getController("dual").unplugFrom(manifold);
  cp5.getController("toSphere").unplugFrom(manifold);
  cp5.getController("catmullClark").unplugFrom(manifold);
  cp5.getController("loop").unplugFrom(manifold);  
}

void plug() {
  cp5.getController("exportOBJ").plugTo(manifold);
  cp5.getController("exportVRML").plugTo(manifold);
  cp5.getController("dual").plugTo(manifold);
  cp5.getController("toSphere").plugTo(manifold);
  cp5.getController("catmullClark").plugTo(manifold);
  cp5.getController("loop").plugTo(manifold);
}

