/**

Topological classes.
Will Pearson, University of Bath, November 2012.

* Vertex class
* Edge class
* Face class

**/

/////////////////////////////////////////////////////////////
//                      Vertex Class                       //
/////////////////////////////////////////////////////////////

class Vertex {

  PVector position;
  List<Edge> edges; // When you create a vertex, the number of edges is unknown.

  Vertex(PVector position) {
    this.position = position.get();
    this.edges = new ArrayList<Edge>();
  }

  void draw() {
    noStroke();
    fill(0);
    pushMatrix();
    translate(this.position.x, this.position.y, this.position.z);
    sphere(0.02);
    popMatrix();
  }
  
  void sortEdges() {
    if (!this.edges.isEmpty()) {
      List<Edge> sorted = new ArrayList<Edge>();
      sorted.add(this.edges.remove(0));
      int n = this.edges.size(); // Store this somewhere safe...
      for (int i = 0; i < n; i++) {
        Face f;
        Edge e = sorted.get(i); // Last edge in sorted list.
        if (this == e.end) {
          f = e.left;
        } else {
          f = e.right;
        }
        // Find the next edge (the one with face f on one side).
        for (Edge en: this.edges) {
          if (f == en.left || f == en.right) {
            sorted.add(en);
            this.edges.remove(en);
            break;
          }
        }
      }
      this.edges = sorted;
    }
  }
}

/////////////////////////////////////////////////////////////
//                       Edge Class                        //
/////////////////////////////////////////////////////////////

class Edge {

  Vertex start;
  Vertex end;
  Face left;
  Face right;

  Edge(Vertex start, Vertex end, Face left) {
    this.start = start;
    this.end = end;
    this.left = left;
    this.right = null;
  }

  void draw() {
    stroke(0);
    strokeWeight(2);
    line(this.start.position.x, this.start.position.y, this.start.position.z, this.end.position.x, this.end.position.y, this.end.position.z);
  }
}

/////////////////////////////////////////////////////////////
//                       Face Class                        //
/////////////////////////////////////////////////////////////

class Face {
  
  Vertex[] vertices;
  Edge[] edges;
  
  Face(Vertex[] vertices) {
    this.vertices = vertices;
    this.edges = new Edge[vertices.length];
  }
  
  void draw() {
    noStroke();
    fill(204, 102, 0);
    beginShape();
    for (Vertex v : this.vertices) {
      vertex(v.position.x, v.position.y, v.position.z);
    }
    endShape(CLOSE);
  }
  
  PVector centroid() {
    PVector c = new PVector(0, 0, 0);
    for (Vertex v : this.vertices) {
      c.add(v.position);
    }
    c.div(this.vertices.length);
    return c;
  }
}
