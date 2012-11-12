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
  
  // Accessor methods:
  // -----------------
  
  List<Vertex> vertices() {
    return this.vertices;
  }
  
  List<Edge> edges() {
    return this.edges;
  }
  
  List<Face> faces() {
    return this.faces;
  }
  
  // Factory methods:
  // ----------------
  // To create basic polyhedra (pyramids, prisms and antiprisms).
  // Note: maybe these should be declared in a static Factory class?
  
  Manifold tetrahedron(float s) {
    // Create a tetrahedron with sidelength s, centered at the origin.
    // (To be generalised into an pyramid creator.)
    int n = 3; // number of sides on base (TODO: implement as argument)
    Manifold t = new Manifold();
    
    s *= 0.5;
    t.addVertex(new PVector(s, 0, -s/sqrt(2)));
    t.addVertex(new PVector(-s, 0, -s/sqrt(2)));
    t.addVertex(new PVector(0, -s, s/sqrt(2)));
    t.addVertex(new PVector(0, s, s/sqrt(2))); // apex
    
    int[] base = new int[n];
    for (int i = 0; i < n; i++) {
      t.addFace(new int[]{i, (i+1)%n, n});
      base[i] = i;
    }
    t.addFace(base);
    
    return t;
  }
  
  Manifold prism(int n, float s) {
    // Create a cube with sidelength s, centered at the origin.
    // (To be generalised into a prism creator.)
    Manifold c = new Manifold();
    
    float a = 2 * PI / n;
    float m = (0.5*s) / sin(0.5*a);
    s *= 0.5;
    
    // Add vertices for top face (anticlockwise). 
    for (int i = 0; i < n; i++) {
      c.addVertex(new PVector(m * sin((0.5 - i) * a), -s, m * cos((0.5 - i) * a)));
    }
    // Add vertices for bottom face (anticlockwise).
    for (int i = 0; i < n; i++) {
      c.addVertex(new PVector(m * sin((0.5 - i) * a), s, m * cos((0.5 - i) * a)));
    }
    
    // Add top/bottom faces.
    int[] top = new int[n];
    int[] bottom = new int[n];
    for (int i = 0; i < n; i++) {
      top[i] = i;
      bottom[i] = 2 * n - (i + 1);
    }
    c.addFace(top);
    c.addFace(bottom);
    
    // Add side faces.
    for (int i = 0; i < n; i++) {
      c.addFace(new int[]{(i+1)%n, i, i+n, (i+1)%n+n});
    }
    
    return c;
  }
  
  Manifold prism(int n) {
    // Simpler method for sidelength 1 (might depricate sidelength anyway as it doesn't really work for n sided prisms...)
    return this.prism(n, 1); //.toSphere();
  }
  
  Manifold antiprism(int n, float s) {
    // Create a cube with sidelength s, centered at the origin.
    // (To be generalised into a prism creator.)
    Manifold c = new Manifold();
    
    float a = 2 * PI / n;
    float m = (0.5*s) / sin(0.5*a); // copied from prism (TODO: figure out how to generate a uniform antiprism)
    s *= 0.5; 
    
    // Add vertices for top face (anticlockwise). 
    for (int i = 0; i < n; i++) {
      c.addVertex(new PVector(m * cos((0.5 - i) * a), -s, m * sin((0.5 - i) * a)));
    }
    // Add vertices for bottom face (anticlockwise).
    for (int i = 0; i < n; i++) {
      c.addVertex(new PVector(m * cos(-i * a), s, m * sin(-i * a)));
    }
    
    // Add top/bottom faces.
    int[] top = new int[n];
    int[] bottom = new int[n];
    for (int i = 0; i < n; i++) {
      top[i] = i;
      bottom[i] = 2 * n - (i + 1); // reverse order
    }
    c.addFace(top);
    c.addFace(bottom);
    
    // Add side faces.
    for (int i = 0; i < n; i++) {
      c.addFace(new int[]{i, (i+1)%n, i+n});
      c.addFace(new int[]{(i+1)%n, (i+1)%n+n, i+n});
    }
    
    return c;
  }
  
  Manifold antiprism(int n) {
    // See prism short method.
    return this.antiprism(n, 1);
  }
  
  void toSphere() {
    // Project vertices onto a unit sphere.
    // Note: assumes that the centroid of the manifold is at the origin.
    for (Vertex v : this.vertices) {
      v.position.setMag(1);
    }
  }
}

