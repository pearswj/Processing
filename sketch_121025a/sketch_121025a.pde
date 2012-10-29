float SPAN, requiredLengthSq, EA_L;
Chain chain;
PVector gravity;

void setup() {
  int numNodes = 50;
  size(1200, 750);
  smooth();
  frameRate(30);
  SPAN = 0.9 * width;
  chain = new Chain(numNodes);
  gravity = new PVector(0,1.8);
  
  float c = 5.0 * SPAN * 0.5;
  float arg = SPAN / (2.0 * c);
  requiredLengthSq = sq(2.0 * c * ((exp(arg) - exp(-arg)) * 0.5) / numNodes);
  //println(c + " " + arg + " " + sqrt(requiredLengthSq)); 
  EA_L = 1.0;
  
  // Debug
//  println("req: " + sqrt(requiredLengthSq) + "\n");
//  println("Links:");
//  for (int i=0; i<numNodes; i++) {
//      println(chain.nodes.indexOf(chain.links.get(i).from) + "\t" + chain.nodes.indexOf(chain.links.get(i).to)); 
//    }
//  println();
//  for (Node n : chain.nodes) {
//    println(n.location.x + "\t" + n.location.y + "\t\t" + n.force.x + "\t" + n.force.y);
//  }
//  println();  
}

void draw() {
  background(255);
  for (int i=0; i<10; i++) {
    chain.update();
  }
  chain.draw();
  
  // Debug
//  for (Node n : chain.nodes) {
//    println(n.location.x + "\t" + n.location.y + "\t\t" + n.force.x + "\t" + n.force.y);
//  }
//  println();
  
  //noLoop();
}

void keyPressed()
{
  loop();
}

class Chain {
  List<Node> nodes;
  List<Link> links;

  Chain(int n) {
    this.nodes = new ArrayList<Node>();
    for (int i=0; i<=n; i++) {
      this.nodes.add(new Node());
      // Set initial starting position for nodes.
      this.nodes.get(i).location.set(new PVector(0.5*(width-SPAN)+SPAN*(float(i)/(n)), 0.1*SPAN));
      //print(i + " " + n + " ");
      //println(0.5*(width-SPAN)+SPAN*(i/(n-1)));
    }
    this.links = new ArrayList<Link>();
    for (int i=0; i<n; i++) {
      this.links.add(new Link(this.nodes.get(i), this.nodes.get(i+1)));
    }
    
  }
  
  void update() {
    for (Node n : this.nodes) {
      n.force.set(gravity);
    }
    //println("Debug links..."); //
    for (Link l : this.links) {
      PVector deltaCoord = PVector.sub(l.to.location, l.from.location);
      float currentLengthSq = sq(deltaCoord.mag());
      float strain = (currentLengthSq / requiredLengthSq - 1.0) * 0.5;
      float forceDensity = strain * EA_L;
      //println(deltaCoord.x + "\t" + deltaCoord.y + "\t" + sqrt(currentLengthSq) + "\t" + forceDensity); //
      l.from.force.add(PVector.mult(deltaCoord,forceDensity));
      l.to.force.sub(PVector.mult(deltaCoord,forceDensity));
    }
    println();
    for (Node n : this.nodes) {
      // Update location of all nodes (except first and last):
      if (this.nodes.indexOf(n) != 0 && this.nodes.indexOf(n) != this.nodes.size()-1) {
        n.update();
      }
    }
  }
  
  void draw() {
    noFill();
    beginShape();
    for (Node n : nodes) {
      n.draw();
      vertex(n.location.x,n.location.y);
    }
    strokeWeight(3);
    endShape();
  }
}

class Node {

  PVector location, velocity, force;
  float mass;

  Node() {
    this.velocity = new PVector(0, 0);
    this.location = new PVector();
    this.force = new PVector();
    this.mass = 1.0;
  }
  
  void update() {
    this.velocity.mult(0.99);
    this.velocity.add(PVector.mult(this.force, 0.25));
    this.location.add(PVector.mult(this.velocity, 0.25));
  }
  
  void draw() {
    stroke(0, 70);
    strokeWeight(10);
    point(this.location.x, this.location.y);
  }
}

class Link {
  
  Node from;
  Node to;
  
  Link(Node from, Node to) {
    this.from = from;
    this.to = to;
  }
}
