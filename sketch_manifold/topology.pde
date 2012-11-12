/**
* Vertex class
* Edge class
* Face class
**/

/////////////////////////////////////////////////////////////
//                      Vertex Class                       //
/////////////////////////////////////////////////////////////

class Vertex {

  PVector position;
  List<Edge> edges;

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
}
