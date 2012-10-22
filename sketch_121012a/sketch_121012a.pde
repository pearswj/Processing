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
    factory.add(new Firework()); // Add a new simple firework
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

class Factory {

  private List<Firework> active;

  Factory() {
    active = new LinkedList<Firework>();
  }

  void update() {
    LinkedList<Firework> temp = new LinkedList<Firework>();
    for (Firework f : this.active) {
      f.update();
      if (f.alive()) {
        temp.add(f);
      }
      else if (f.payload.isEmpty() == false) {
        temp.addAll(f.payload);
      }
    }
    this.active = temp;
  }

  void draw() {
    for (Firework itr : this.active) {
      itr.draw();
    }
  }

  void add(Firework firework) {
    this.active.add(firework);
  }

  void debug() {
    println(active.size());
  }
}

class Firework {

  PVector location;
  PVector velocity;
  float diameter;
  List<Firework> payload = new Stack<Firework>();

  Firework() {
    this.location = new PVector(width/2, 3*height/4, 0);
    this.velocity = new PVector(random(-4, 4), -10, random(-4, 4)); // Randomise starting angle
    this.velocity.setMag(10);
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
}

class Shell extends Firework {

  //List<Firework> payload; // Declared in Superclass (or Abstract class...)
  int fuse;
  PVector[] s;

  Shell(int n) {
    super();
    this.fuse = 50;
    this.payload = new Stack<Firework>();
    for (int i = 0; i < n; i++) {
      this.payload.add(new Firework());
    }
    // Create array of secondary velocities
    s = this.distributeOnSphere(n);
    this.diameter = 20;
  }

  void update() {
    super.update();
    this.fuse--;
    // If the original firework has died, initialise the secondary shell.
    if (this.alive() == false) {
      for (Firework f : this.payload) {
        f.location = this.location.get();
        f.velocity = PVector.add(this.velocity, s[this.payload.indexOf(f)]);
      }
    }
  }

  boolean alive() {
    return (this.fuse > 0 && this.location.y <= 3*height/4);
  }
  
  PVector[] distributeOnSphere(int n) {
        PVector[] distro = new PVector[n];
    for (int i = 0; i < distro.length; i++) {
      while (distro[i] == null || distro[i].mag () > 1) {
        distro[i] = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
      }
      distro[i].setMag(5);
    }
    return distro;
  }
}

