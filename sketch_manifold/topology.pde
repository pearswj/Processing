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
    // TODO: test for boundaries
    if (!this.edges.isEmpty()) {
      List<Edge> sorted = new ArrayList<Edge>();
      Edge e = this.edges.remove(0);
      sorted.add(e);
      int n = this.edges.size(); // Store this somewhere safe...
      boolean rs = false;
      for (int i = 0; i < n; i++) {
        Face f;
        if (rs == false) { // FORWARD SORT (default)
          //Edge e = sorted.get(i); // Last edge in sorted list.
          logger(this, "DEBUG", "sortEdges; searching from " + e);
          if (this == e.start) {
            f = e.left;
          } 
          else {
            f = e.right;
          }
          if (f == null) { // Go back to first edge and reverse sort
            rs = true;
            e = sorted.get(0);
            i--;
            logger(this, "DEBUG", "sortEdges; " + e + " is a boundary edge, returning to start and reversing");
            continue;
          }
          // Find the next edge (the one with face f on one side).
          for (Edge en: this.edges) {
            if (f == en.left || f == en.right) {
              sorted.add(en);
              this.edges.remove(en);
              logger(this, "DEBUG", "sortEdges; edge found: " + en);
              e = en;
              break;
            }
          }
        }
        else { // REVERSE SORT (if boundary found) 
          //Edge e = sorted.get(0); // First edge in sorted list.
          logger(this, "DEBUG", "sortEdges; searching from " + e);
          if (this == e.start) {
            f = e.right;
          } 
          else {
            f = e.left;
          }
          // Find the next edge (the one with face f on one side).
          for (Edge en: this.edges) {
            if (f == en.left || f == en.right) {
              sorted.add(0, en);
              this.edges.remove(en);
              e = en;
              logger(this, "DEBUG", "sortEdges; edge found: " + en);
              break;
            }
          }
        }
      }
      // warn if there are edges left over (not a manifold)
      if (this.edges.size() > 0) {
        logger(this, "WARNING", "sortEdges; sort error - not a manifold! (" + this.edges.size() + " edge(s) left over.)");
      }
      this.edges = sorted;
    }
  }

  Face[] faces() {
    // returns an array of faces to which this vertex belongs (ordered anticlockwise)
    List<Face> faces = new ArrayList<Face>();
    this.sortEdges();
    for (Edge e : this.edges) {
      if (this == e.start && e.right != null) {
        faces.add(e.right);
      } 
      else if (this == e.end && e.left != null) {
        faces.add(e.left);
      }
    }
    return faces.toArray(new Face[faces.size()]);
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
    Edge e = this.edgeTo(b);
    if (e != null) {
      return e;
    } else {
      return b.edgeTo(this);
    }
  }
  
  PVector normal() {
    // sort edges --> .cross adjacent (normalised) pairs --> sum and normalise
    this.sortEdges();
    PVector n = new PVector();
    for (int i = 0; i < this.edges.size(); i++) {
      PVector a = this.edges.get(i).vector().normalize(null);
      PVector b = this.edges.get((i+1)%this.edges.size()).vector().normalize(null);
      // vectors must start at 'this' vertex 
      if (this.edges.get(i).end == this) {
        a.mult(-1);
      }
      if (this.edges.get((i+1)%this.edges.size()).end == this) {
        b.mult(-1);
      }
      n.add(a.cross(b));
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
    // TODO: differentiate boundaries
    stroke(0); // TODO: set colour here
    if (this.boundary() == false) {
      strokeWeight(2);
    }
    else {
      strokeWeight(5);
    }
    line(this.start.position.x, this.start.position.y, this.start.position.z,
         this.end.position.x, this.end.position.y, this.end.position.z);
  }
  
  float length() {
    return this.start.position.dist(this.end.position);
  }
  
  PVector vector() {
    return PVector.sub(this.end.position, this.start.position);
  }
  
  boolean boundary() {
    return (this.right == null);
  }
  
  PVector midPoint() {
    return PVector.div(PVector.add(this.start.position, this.end.position), 2);
  }
  
  void reverse() {
    Vertex tempVertex = this.start;
    this.start = this.end;
    this.end = tempVertex;
    Face tempFace = this.left;
    this.left = this.right;
    this.right = tempFace;
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
  
  Edge[] edges() {
    // For each pair of vertices, get the edge!
    logger(this, "INFO", "getEdges; Finding edges for face " + this);
    int n = this.vertices.length;
    Edge[] edges = new Edge[n];
    for (int i = 0; i < n; i++) {
      edges[i] = this.vertices[i].edgeWith(this.vertices[(i+1)%n]);
    } 
    return edges;
  }
}

