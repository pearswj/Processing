/**
The following classes contain topological information and properties of structural elements (to be separated at a later date).  
**/

/////////////////////////////////////////////////////////////
//                     Manifold Class                      //
/////////////////////////////////////////////////////////////

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
      // Set [mouse]over boolean (only true if the mouse isn't over any other nodes)
      if (!overOther(n) && n.mouseOver()) {
        n.over = true;
      } else {
        n.over = false;
      }
      
      // Calculate nodal forces from link strain.
      n.force.set(gravity);
      for (Link l : n.links) {
        float strain = (l.length() - l.originalLength) / l.originalLength;
        float forceDensity = strain * l.axialStiffness;
        n.force.add(PVector.mult(l.direction(n), forceDensity));
      }
      n.force.div(n.mass);
      
      // Update node positions.
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
  
  // Accessor functions:
  // -------------------
  
  List<Node> nodes() {
    return this.nodes;
  }
  
  List <Link> links() {
    return this.links;
  }
  
  // Collision detection:
  // --------------------
  
  void detectCollision(Ball b) {
    for (Node n : this.nodes) {
      n.detectCollision(b);
    }
  }
}

/////////////////////////////////////////////////////////////
//                       Node Class                        //
//                         (free)                          //
/////////////////////////////////////////////////////////////

class Node {

  List<Link> links;
  PVector location, velocity, force;
  boolean over = false, move = false;
  float mass = 1.0;

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
      this.velocity.mult(0.99); // damping
      this.velocity.add(PVector.div(this.force, frameRate*frameRate));
      this.location.add(this.velocity);
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
  
  void detectCollision(Ball b) {
    PVector m = PVector.sub(this.location, b.location);
    if (m.mag() < b.r) {
      m.setMag(b.r);
      this.location = PVector.add(m, b.location);
    }
  }
}

//---------------------------------------------------------//
//                       Fixed Node                        //
//---------------------------------------------------------//

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
  
  void detectCollision(Ball b) {
    // Do nothing!
  }
}

/////////////////////////////////////////////////////////////
//                       Link Class                        //
/////////////////////////////////////////////////////////////

class Link {

  Node from;
  Node to;
  float originalLength;
  float axialStiffness = 100.0; // E A / L

  Link(Node from, Node to) {
    this.from = from;
    this.to = to;
    this.originalLength = PVector.sub(to.location, from.location).mag();
  }

  void draw() {
    stroke(0, 150);
    strokeWeight(3);
    line(this.from.location.x, this.from.location.y, this.to.location.x, this.to.location.y);
  }
  
  float length() {
    // Return current length of link element
    return (PVector.sub(this.from.location, this.to.location)).mag();
  }
  
  PVector direction(Node n) {
    // Return direction vector for link, oriented from stated node
    // (null vector if node not at start or end of link)
    PVector r = PVector.sub(this.to.location, this.from.location);
    r.normalize();
    if (n == this.from) {
      return r;
    } else if (n == this.to) {
      r.mult(-1.0);
    } else {
      r.mult(0.0);
    }
    return r;
  }
}
