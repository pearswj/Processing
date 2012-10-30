Chain chain;
PVector gravity;

void setup() {
  size(1200, 750);
  smooth();
  frameRate(30);

  // Create a chain - Chain(from, to, number of links)
  chain = new Chain(new PVector(60, 108), new PVector(1140, 108), 40);

  gravity = new PVector(0, 1.8);
}

void draw() {
  background(255);
  for (int i=0; i<10; i++) { // Update chain 10x each frame
    chain.update();
  }
  chain.draw();
}

class Chain {
  List<Node> nodes;
  List<Link> links;
  float requiredLengthSq;

  Chain(PVector from, PVector to, int n) {
    this.nodes = new Stack<Node>();

    // Add nodes and set initial starting positions.
    PVector delta = PVector.div(PVector.sub(to, from), n); // Vector between nodes (starting pos.)
    this.nodes.add(new Fixed());
    this.nodes.get(0).location.set(from);
    for (int i=1; i<n; i++) {
      this.nodes.add(new Node());
      this.nodes.get(i).location.set(PVector.add(from, PVector.mult(delta, i)));
    }
    this.nodes.add(new Fixed());
    this.nodes.get(n).location.set(to);

    // Add links and set from/to nodes.
    this.links = new ArrayList<Link>();
    for (int i=0; i<n; i++) {
      this.links.add(new Link(this.nodes.get(i), this.nodes.get(i+1)));
    }

    // Calculate required length (squared).
    float span = PVector.sub(to, from).mag();
    float c = 5.0 * span * 0.5;
    float arg = span / (2.0 * c);
    requiredLengthSq = sq(2.0 * c * ((exp(arg) - exp(-arg)) * 0.5) / n);
  }

  void update() {
    // Initalise force on nodes (gravity):
    for (Node n : this.nodes) {
      n.force.set(gravity);
    }
    // Calculate member forces and add to nodes:
    // (maybe this should be refactored into the Link class...)
    for (Link l : this.links) {
      PVector deltaCoord = PVector.sub(l.to.location, l.from.location);
      float currentLengthSq = sq(deltaCoord.mag());
      float strain = (currentLengthSq / this.requiredLengthSq - 1.0) * 0.5;
      float forceDensity = strain * l.axialStiffness;
      l.from.force.add(PVector.mult(deltaCoord, forceDensity));
      l.to.force.sub(PVector.mult(deltaCoord, forceDensity));
    }
    // Update location of all nodes:
    for (Node n : this.nodes) {
      n.update();
    }
  }

  void draw() {
    // Draw nodes:
    for (Node n : this.nodes) {
      n.draw();
    }
    //Draw links:
    for (Link l : this.links) {
      l.draw();
    }
  }
}

class Node {

  PVector location, velocity, force;
  //float mass;

  Node() {
    this.velocity = new PVector(0, 0);
    this.location = new PVector();
    this.force = new PVector();
    //this.mass = 1.0;
  }

  void update() {
    this.velocity.mult(0.99);
    this.velocity.add(PVector.mult(this.force, 0.25));
    this.location.add(PVector.mult(this.velocity, 0.25));
  }

  void draw() {
    stroke(0, 50);
    strokeWeight(10);
    point(this.location.x, this.location.y);
  }
}

class Fixed extends Node {

  Fixed() {
    super();
  }

  void draw() {
    stroke(0, 150);
    strokeWeight(10);
    point(this.location.x, this.location.y);
  }

  void update() {
    // Do nothing!
  }
}

class Link {

  Node from;
  Node to;
  float axialStiffness; // E A / L

  Link(Node from, Node to) {
    this.from = from;
    this.to = to;
    this.axialStiffness = 1.0;
  }

  void draw() {
    stroke(0, 150);
    strokeWeight(3);
    line(this.from.location.x, this.from.location.y, this.to.location.x, this.to.location.y);
  }
}

