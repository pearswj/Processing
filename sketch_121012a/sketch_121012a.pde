import processing.opengl.*;

Factory factory;
PVector gravity;

void setup() {
  size(600, 600, OPENGL);
  //translate(width/2, 3*height/4);
  smooth();
  background(0);
  factory = new Factory();
  gravity = new PVector(0, 9.81);
  println("Press the \"?\" key for help!");
  //hint(DISABLE_DEPTH_TEST);
}

void draw() {
  background(0);
  stroke(255, 20);
  strokeWeight(16);
  point(width/2, 3*height/4, 0);
  factory.update();
  factory.draw();
  //if (frameRate < 60 == false) {
  //  factory.add(new Shell(25));
  //}
}

void keyPressed() {
  if (key == '1') {
    factory.add(new Simple()); // Add a new simple firework
  }
  else if (key == '2') {
    factory.add(new Shell(100)); // Add a new shell firework
  }
  else if (key == '?') {
    println("1 - simple (mortar) type");
    println("2 - shell type");
  }
  //factory.debug();
}

// The firework factory:
// Maintains the active list of fireworks
class Factory {

  private List<Firework> active;

  Factory() {
    active = new Stack<Firework>();
  }

  void update() {
    List<Firework> temp = new Stack<Firework>();
    for (Firework f : this.active) {
      f.update();
      if (f.alive()) {
        temp.add(f);
      }
      else if (f.payload() != null) {
        temp.addAll(f.payload());
      }
    }
    this.active = temp;
  }

  void draw() {
    for (Firework itr : this.active) {
      itr.draw();
    }
  }

  void add(Firework f) {
    this.active.add(f);
  }

  void debug() {
    println(active.size());
  }
}

// Firework interface:
// Defines a firework as an object that implements these methods/properties
interface Firework {
  void update();
  void draw();
  boolean alive();
  List<Firework> payload();
  PVector location();
  PVector velocity();
}

// A simple (mortar type) firework with no payload
class Simple implements Firework {

  PVector location;
  PVector velocity;
  float diameter;
  //List<Firework> payload = null;

  Simple() {
    this.location = new PVector(width/2, 3*height/4, 0);
    this.velocity = new PVector(random(-4, 4), -10, random(-4, 4)); // Randomise starting angle
    this.velocity.setMag(random(8, 12));
    this.diameter = 10;
  }

  void update() {
    this.velocity.add(PVector.div(gravity, frameRate));
    this.location.add(velocity);
  }

  void draw() {
    stroke(255, 70);
    strokeWeight(this.diameter);
    point(this.location.x, this.location.y, this.location.z);
  }

  boolean alive() {
    return (this.location.y <= 3*height/4);
  }
  
  List<Firework> payload() {
    return null;
  }
  
  PVector location() {
    return this.location;
  }
  
  PVector velocity() {
    return this.velocity;
  }
}

// A shell type firework, both based on and containing a payload of simple fireworks
class Shell extends Simple {
  
  int fuse;
  PVector[] s;
  List<Firework> payload;

  Shell(int n) {
    super();
    this.fuse = 50;
    this.payload = new Stack<Firework>();
    for (int i = 0; i < n; i++) {
      this.payload.add(new Simple());
    }
    // Create array of secondary velocities
    s = this.distributeOnSphere(n);
    this.diameter = 20;
  }

  void update() {
    super.update();
    this.fuse--;
    // If the original Simple has died, initialise the secondary shell.
    if (this.alive() == false) {
      for (Firework f : this.payload()) {
        f.location().set(this.location.get());
        f.velocity().set(PVector.add(this.velocity, s[this.payload.indexOf(f)]));
      }
    }
  }

  boolean alive() {
    return (this.fuse > 0 && this.location.y <= 3*height/4);
  }
  
  List<Firework> payload() {
    return this.payload;
  }
  
  PVector[] distributeOnSphere(int n) {
        PVector[] distro = new PVector[n];
    for (int i = 0; i < distro.length; i++) {
      while (distro[i] == null || distro[i].mag () > 1) {
        distro[i] = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
      }
      distro[i].setMag(random(2, 5));
    }
    return distro;
  }
}

