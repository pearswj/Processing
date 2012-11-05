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

