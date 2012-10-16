import processing.opengl.*;

Rocket active;
PVector gravity;

void setup() {
  size(600, 600, OPENGL);
  smooth();
  background(0);
  //rockets = new ArrayList();  // Create an empty ArrayList
  //rockets.add(new Rocket());
  gravity = new PVector(0, 9.81);
  println("Press any key!");
  //hint(DISABLE_DEPTH_TEST);
}

void draw() {
  //background(0);
  if (active != null) {
    active.update();
  }
  stroke(255, 20);
  strokeWeight(16);
  point(width/2, 3*height/4, 0);
}

void keyPressed() {
  if (active != null) {
    active.add(new RRocket(10)); // Add a new Rocket
  }
  else {
    active = new RRocket(10);
  }
}   

class Rocket {

  PVector location;
  PVector velocity;
  float diameter;
  Rocket next;
  Rocket payload;
  int fuse;

  Rocket() {
    next = null;
    location = new PVector(width/2, 3*height/4, 0);
    velocity = new PVector(random(-4, 4), -10, random(-4, 4)); // Randomise starting angle
    velocity.normalize();
    velocity.mult(12); // Velocity
    diameter = 16;
  }

  void update() {
    Rocket n = this;
    while (n != null) {
      n.updateLocation();
      n.render();
      n.fuse--;
      if (n.next != null) {
        if (n.next.finished()) {
          if (n.next.payload != null) {
            n.next = n.next.payload;
            // iterate through payload and link up last item with n.next.next
            // and update payloads with current location/velocity
          }
          else {
            n.next = n.next.next;
          }
        }
      }
      n = n.next;
    }
  }

  void updateLocation() {
    velocity.add(PVector.div(gravity, frameRate));
    location.add(velocity);
  }

  void render() {
    stroke(255, 20);
    strokeWeight(diameter);
    point(location.x, location.y, location.z);
  }

  boolean finished() {
    if (fuse <= 0 || location.y > height) {
      return true;
    }
    else {
      return false;
    }
  }

  void add(Rocket r) {
    Rocket n = this;
    while (n.next != null) {
      n = n.next;
    }
    n.next = r;
  }
}

class RRocket extends Rocket {

  RRocket(int s) {
    super();
    fuse = 120;
    payload = new Rocket();
    Rocket r = payload;
    for (int i = 0; i < s; i++) {
      r.next = new Rocket();
      r = r.next;
    }
  }
}

