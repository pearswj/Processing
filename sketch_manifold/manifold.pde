/**
* Manifold class
**/

/////////////////////////////////////////////////////////////
//                     Manifold Class                      //
/////////////////////////////////////////////////////////////

class Manifold {
  
  private List<Vertex> vertices;
  private List<Edge> edges;
  private List<Face> faces;
  
  Manifold() {
    this.vertices = new ArrayList<Vertex>(); 
    this.edges = new ArrayList<Edge>();
    this.faces = new ArrayList<Face>();
  }
  
  // Add a new vertex:
  // -----------------
  
  void addVertex(Vertex v) {
    this.vertices.add(v);
  }
  
  void addVertex(PVector position) {
    this.addVertex(new Vertex(position));
  }
  
  // Add a new face:
  // ---------------
  
  void addFace(Vertex[] vertices) {
    // Add a new face, described by its vertices.
    // Vertices must be supplied in anticlockwise order.
    Face f = new Face(vertices);
    // Find/create edges.
    for (int i = 0; i < vertices.length; i++) {
      Vertex start = vertices[i];
      Vertex end = vertices[(i+1)%vertices.length];
      Edge e = this.findEdge(start, end);
      if (e != null) {
        e.right = f;
      } else {
        this.addEdge(start, end, f);
      }
    }   
    this.faces.add(f);
  }
  
  void addFace(int[] vIndex) {
    // Add a new face, described by vertex indices
    // TODO: catch 'index out of bounds' errors
    Vertex[] vertices = new Vertex[vIndex.length];
    for (int i = 0; i < vIndex.length; i++) {
      vertices[i] = this.vertices.get(vIndex[i]);
    }
    this.addFace(vertices);
  }
      
  
  // Add a new edge:
  // ---------------
  
  void addEdge(Edge e) {
    this.edges.add(e);
    e.start.edges.add(e);
    e.end.edges.add(e);
  }
  
  void addEdge(Vertex start, Vertex end, Face left) {
    this.addEdge(new Edge(start, end, left));
  }
  
  // Draw methods:
  // -------------

  void drawVertices() {
    // Draw nodes:
    for (Vertex v : this.vertices) {
      v.draw();
    }
  }
  
  void drawEdges() {
    for (Edge e : this.edges) {
      e.draw();
    }
  }
  
  void drawFaces() {
    for (Face f : this.faces) {
      f.draw();
    }
  }
  
  // Helper methods:
  // ---------------
  
  Edge findEdge(Vertex start, Vertex end) {
    // If an edge exists from 'start' to 'end', return it (else return null).
    // Note: direction specific!
    for (Edge e : this.edges) {
      if (e.start == end && e.end == start) {
        return e;
      }
    }
    return null;
  }
  
  // Accessor functions:
  // -------------------
  
  List<Vertex> vertices() {
    return this.vertices;
  }
  
  List<Edge> edges() {
    return this.edges;
  }
  
  List<Face> faces() {
    return this.faces;
  }
}

