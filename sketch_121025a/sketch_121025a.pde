/**
Modelling a hanging chain.
Will Pearson, University of Bath, November 2012.
 
Click & drag based on http://processing.org/learning/topics/springs.html
**/

Chain chain;
PVector gravity;

void setup() {
  size(750, 750);
  smooth();
  frameRate(30);

  // Create a chain - Chain(from, to, number of links)
  chain = new Chain(new PVector(60, 108, 0), new PVector(600, 300, 0), 30);

  gravity = new PVector(0, 1.8);
}

void draw() {
  background(255);    
  for (int i=0; i<10; i++) { // Update chain 10x each frame
    chain.update();
  }
  chain.draw();
}

void mousePressed() {
  chain.mousePressed();
}

void mouseReleased() {
  chain.mouseReleased();
}

class Chain extends Manifold {

  Chain(PVector from, PVector to, int n) {
    // Initialise manifold.
    super();

    // Add n+1 nodes along the length of the chain.
    PVector delta = PVector.div(PVector.sub(to, from), n); // Vector between nodes (starting pos.)
    this.addNode(new Fixed(from));
    for (int i=1; i<n; i++) {
      this.addNode(new Node(PVector.add(from, PVector.mult(delta, i))));
    }
    this.addNode(new Fixed(to));

    // Add n links along length of the chain.
    for (int i=0; i<n; i++) {
      this.addLink(new Link(this.nodes.get(i), this.nodes.get(i+1)));
    }
  }
}

// --------------------------
// Manifold/Node/Link classes
// --------------------------

class Manifold {
  List<Node> nodes;
  List<Link> links;
  
  Manifold() {
    this.nodes = new ArrayList<Node>(); 
    this.links = new ArrayList<Link>();
  }
  
  // Add a new node:
  // ---------------
  
  void addNode(Node n) {
    this.nodes.add(n);
  }
  
  void addNode(PVector position) {
    this.addNode(new Node(position));
  }
  
  // Add a new link:
  // ---------------
  
  void addLink(Link l) {
    //if (!(this.links.contains(l))) {
    this.links.add(l);
    l.from.links.add(l);
    l.to.links.add(l);
  }
  
  void addLink(Node from, Node to) {
    this.addLink(new Link(from, to));
  }
  
  // Update:
  // -------

  void update() {
    // Initalise force on nodes (gravity):
    for (Node n : this.nodes) {
      n.force.set(gravity);
      // Set [mouse]over boolean (only true if the mouse isn't over any other nodes)
      if (!overOther(n) && n.mouseOver()) {
        n.over = true;
      } else {
        n.over = false;
      }
    }
    // Calculate member forces and add to nodes:
    // (maybe this should be refactored into the Link class...)
    for (Link l : this.links) {
      PVector deltaCoord = PVector.sub(l.to.location, l.from.location);
      float currentLength = deltaCoord.mag();
      float strain = (currentLength - l.originalLength) / l.originalLength;
      float forceDensity = strain * l.axialStiffness;
      l.from.force.add(PVector.mult(deltaCoord, forceDensity));
      l.to.force.sub(PVector.mult(deltaCoord, forceDensity));
    }
    // Update location of all nodes:
    for (Node n : this.nodes) {
      n.update();
    }
  }
  
  // Draw:
  // -----

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
  
  // Helper functions:
  // -----------------
  
  // Check if the mouse is currently over any other nodes.
  boolean overOther(Node focus) {
   for (Node n : this.nodes) {
     if (n != focus) {
       if (n.over) {
         return true;
       }
     }
   }
   return false;
  }
  
  // Convert fixed nodes to free, and vice versa.
  void toggleNode(Node n) {
    Node f;
    if (n instanceof Fixed) {
      f = new Node(n.location);
    } else { // If node is not fixed then it must be free.
      f = new Fixed(n.location);
    }
    // Update references to n in the links which connect to it. 
    for (Link l : n.links) {
      if (l.from == n) {
        l.from = f;
      } else if (l.to == n) {
        l.to = f;
      }
    }
    f.links = n.links;
    // Find n in Manifold's list of nodes and replace with f.
    for (Node e : this.nodes) {
      if (e == n) {
        this.nodes.set(this.nodes.indexOf(e), f);
      }
    }
  }
  
  void mousePressed() 
  {
    if (mouseButton == LEFT) {
      for (Node n : this.nodes) {
        n.pressed();
      }
    } else if (mouseButton == RIGHT) {
      for (Node n : this.nodes) {
        if (n.over) {
          this.toggleNode(n);
        }
      }
    }
  }
  
  void mouseReleased() {
    for (Node n : this.nodes) {
      n.released();
    }
  }
}

class Node {

  List<Link> links;
  PVector location, velocity, force;
  boolean over = false, move = false;

  Node(PVector location) {
    this.velocity = new PVector(0, 0);
    this.location = location.get();
    this.force = new PVector();
    this.links = new ArrayList<Link>(); // init empty list of links
  }

  void update() {
    if (this.move) {
      this.location.set(mouseX, mouseY, 0);
    } else {
      this.velocity.mult(0.99);
      this.velocity.add(PVector.mult(this.force, 0.25));
      this.location.add(PVector.mult(this.velocity, 0.25));
    }
  }

  void draw() {
    stroke(0, 50);
    this.setStrokeWeight();
    point(this.location.x, this.location.y);
  }
  
  boolean mouseOver() {
        return (PVector.sub(this.location, new PVector(mouseX, mouseY)).mag() < 10);
  }
  
  void pressed() { 
    if (this.over) {
      this.move = true;
    } else {
      this.move = false;
    }
  }
  
  void released() {
    this.move = false;
  }
  
  void setStrokeWeight() {
    if (this.over) {
      strokeWeight(20);
    } else {
      strokeWeight(10);
    }
  }
}

class Fixed extends Node {

  Fixed(PVector location) {
    super(location);
  }

  void draw() {
    stroke(0, 150);
    setStrokeWeight();
    point(this.location.x, this.location.y);
  }

  void update() {
    if (this.move) {
      this.location.set(mouseX, mouseY, 0);
    }
  }
}

class Link {

  Node from;
  Node to;
  float originalLength;
  float axialStiffness; // E A / L

  Link(Node from, Node to) {
    this.from = from;
    this.to = to;
    this.axialStiffness = 1.0;
    this.originalLength = PVector.sub(to.location, from.location).mag();
  }

  void draw() {
    stroke(0, 150);
    strokeWeight(3);
    line(this.from.location.x, this.from.location.y, this.to.location.x, this.to.location.y);
  }
}
