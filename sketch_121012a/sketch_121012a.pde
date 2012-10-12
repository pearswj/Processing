import processing.opengl.*;

ArrayList rockets;
PVector gravity;

void setup() {
  size(600,600,OPENGL);
  smooth();
  background(0);
  rockets = new ArrayList();  // Create an empty ArrayList
  //rockets.add(new Rocket());
  gravity = new PVector(0, 9.81);
  println("Press any key!");
  //hint(DISABLE_DEPTH_TEST);
}

void draw() {
  //background(0);
  for (int i = 0; i < rockets.size(); i++) {
    // We must cast each item in the ArrayList so that it knows about Rocket's
    // member functions
    Rocket rocket = (Rocket) rockets.get(i);
    if (rocket.finished()) {
      rockets.remove(i);
      continue;
    }
    rocket.update();
    rocket.render();
  }
  stroke(255,20);
  strokeWeight(16);
  point(width/2,3*height/4,0);
}

void keyPressed() {
  rockets.add(new Rocket()); // Add a new Rocket
  println("Number of active rockets: " + rockets.size()); // print the number of Rockets
}

class Rocket {

  PVector location;
  PVector velocity;
  float diameter;

  Rocket() {
    location = new PVector(width/2,3*height/4,0);
    velocity = new PVector(random(-4,4),-10,random(-4,4)); // Randomise starting angle
    velocity.normalize();
    velocity.mult(12); // Velocity
    diameter = 16;
  }

  void update() {
    velocity.add(PVector.div(gravity,frameRate));
    location.add(velocity);
  }

  void render() {
    stroke(255,20);
    strokeWeight(diameter);
    point(location.x,location.y,location.z);
  }
  
  boolean finished() {
    if (location.y > height) {
      return true;
    }
    else {
      return false;
    }
  }
}
