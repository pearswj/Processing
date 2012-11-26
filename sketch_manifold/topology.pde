/*

 Topological classes.
 Will Pearson, University of Bath, November 2012.
 
 * Vertex class
 * Edge class
 * Face class
 
 */

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

  void draw(boolean normals) {
    noStroke();
    fill(0);
    pushMatrix();
    translate(this.position.x, this.position.y, this.position.z);
    sphere(0.02);
    popMatrix();
    if (normals) {
      // draw normals
      PVector a = this.position;
      PVector b = PVector.add(this.position, PVector.mult(this.normal(), 0.1));
      strokeWeight(1);
      stroke(0);
      line(a.x, a.y, a.z, b.x, b.y, b.z);
    }
  }
  
  void draw() {
    this.draw(false);
  }

  void sortEdges() {
    if (!this.edges.isEmpty()) {
      List<Edge> sorted = new ArrayList<Edge>();
      sorted.add(this.edges.remove(0));
      int n = this.edges.size(); // Store this somewhere safe...
      for (int i = 0; i < n; i++) {
        Face f;
        Edge e = sorted.get(i); // Last edge in sorted list.
        if (this == e.start) {
          f = e.left;
        } 
        else {
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

  Face[] getFaces() {
    // returns an array of faces to which this vertex belongs (ordered anticlockwise)
    Face[] faces = new Face[this.edges.size()];
    this.sortEdges();
    for (int i = 0; i < this.edges.size(); i++) {
      Edge e = this.edges.get(i);
      if (this == e.start) {
        faces[i] = e.right;
      } 
      else {
        faces[i] = e.left;
      }
    }
    return faces;
  }
  
  Edge edgeTo(Vertex b) {
    // Find edge starting at this and ending at b (directional)
    for (Edge e : this.edges) {
      if (e.start == this && e.end == b) {
        return e;
      }
    }
    return null;
  }
  
  Edge edgeWith(Vertex b) {
    // Find edge starting/ending at this and ending/starting at b (non-directional)
    if (this.edgeTo(b) != null) {
      return this.edgeTo(b);
    } else {
      return b.edgeTo(this);
    }
  }
  
  PVector normal() {
    PVector n = new PVector();
    for (Face f : this.getFaces()) {
      n.add(f.normal());
    }
    return n.normalize(null);
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
    line(this.start.position.x, this.start.position.y, this.start.position.z,
         this.end.position.x, this.end.position.y, this.end.position.z);
  }
  
  float length() {
    return start.position.dist(end.position);
  }
}

/////////////////////////////////////////////////////////////
//                       Face Class                        //
/////////////////////////////////////////////////////////////

class Face {

  Vertex[] vertices;
  //Edge[] edges;

  Face(Vertex[] vertices) {
    this.vertices = vertices;
    //this.edges = new Edge[vertices.length];
  }

  void draw(boolean normals) { 
    noStroke();
    fill(204, 102, 0);
    if (this.vertices.length <= 3) {
      // draw face normally for triangles
      beginShape();
      for (Vertex v : this.vertices) {
        vertex(v.position.x, v.position.y, v.position.z);
      }
      endShape(CLOSE);
    } 
    else {
      // draw 'fan' around centroid of face
      PVector c = this.centroid();
      for (int i = 0; i < this.vertices.length; i++) {
        PVector a = this.vertices[i].position;
        PVector b = this.vertices[(i+1)%this.vertices.length].position;
        beginShape();
        vertex(a.x, a.y, a.z);
        vertex(b.x, b.y, b.z);
        vertex(c.x, c.y, c.z);
        endShape(CLOSE);
      }
    }
    if (normals) {
      // draw normals
      PVector a = this.centroid();
      PVector b = PVector.add(this.centroid(), PVector.mult(this.normal(), 0.1));
      strokeWeight(1);
      stroke(0);
      line(a.x, a.y, a.z, b.x, b.y, b.z);
    }
  }

  void draw() {
    this.draw(false);
  }

  PVector centroid() {
    PVector c = new PVector(0, 0, 0);
    for (Vertex v : this.vertices) {
      c.add(v.position);
    }
    c.div(this.vertices.length);
    return c;
  }

  PVector normal() {
    PVector n = new PVector();
    for (int i=0; i<this.vertices.length; i++) {
      n.add(this.vertices[i].position.cross(this.vertices[(i+1)%this.vertices.length].position));
    }
    return n.normalize(null);
  }
  
  float area() {
    // planar polygon
    float A = 0.;
    for (int i = 0; i < this.vertices.length - 1; i++) {
      A += (this.vertices[i].position.x * this.vertices[i+1].position.y) -
           (this.vertices[i+1].position.x * this.vertices[i].position.y);
    }
    //A *= 0.5;
    return abs(A * 0.5);
  }
}

