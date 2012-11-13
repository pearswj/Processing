/**

Manifold class.
Will Pearson, University of Bath, November 2012.

* pyramids, prisms and antiprisms
* Conway operations

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
  
  Vertex addVertex(Vertex v) {
    this.vertices.add(v);
    return v;
  }
  
  Vertex addVertex(PVector position) {
    return this.addVertex(new Vertex(position));
  }
  
  // Add a new face:
  // ---------------
  
  Face addFace(Vertex[] vertices) {
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
        f.edges[i] = e; // Add edge to face.
      } else {
        f.edges[i] = this.addEdge(start, end, f);
      }
    }   
    this.faces.add(f);
    return f;
  }
  
  Face addFace(int[] vIndex) {
    // Add a new face, described by vertex indices
    // TODO: catch 'index out of bounds' errors
    Vertex[] vertices = new Vertex[vIndex.length];
    for (int i = 0; i < vIndex.length; i++) {
      vertices[i] = this.vertices.get(vIndex[i]);
    }
    return this.addFace(vertices);
  }
      
  
  // Add a new edge:
  // ---------------
  
  Edge addEdge(Edge e) {
    this.edges.add(e);
    e.start.edges.add(e);
    e.end.edges.add(e);
    return e;
  }
  
  Edge addEdge(Vertex start, Vertex end, Face left) {
    return this.addEdge(new Edge(start, end, left));
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
  
  Manifold pyramid(int n, float s, boolean constrainLaterals) {
    // Create a uniform pyramid with an n-sided base, sidelength s and centered at the origin.
    Manifold t = new Manifold();
    
    float a = 2 * PI / n;
    float m = (0.5*s) / sin(0.5*a);
    float h; // height
    if (constrainLaterals && n < 6) {
      h = sqrt(sq(s) - sq(m)); // length of lateral edges == length of base edges (doesn't make sense for n >= 6!)
    } else {
      h = s;
    }
    s *= 0.5;
    
    // Add vertices for base (anticlockwise, looking down)
    for (int i = 0; i < n; i++) {
      t.addVertex(new PVector(m * sin(-i * a), h/4, m * cos(-i * a)));
    }
    t.addVertex(new PVector(0, -3*h/4, 0)); // apex
    
    int[] base = new int[n];
    for (int i = 0; i < n; i++) {
      t.addFace(new int[]{i, (i+1)%n, n});
      base[i] = n - (i + 1); // reverse order
    }
    t.addFace(base);
    
    return t;
  }
  
  Manifold pyramid(int n) {
    return this.pyramid(n, 1, false);
  }
  
  Manifold prism(int n, float s) {
    // Create a prism with n-sided top/bottom, sidelength s and centered at the origin.
    Manifold c = new Manifold();
    
    float a = 2 * PI / n;
    float m = (0.5*s) / sin(0.5*a);
    s *= 0.5;
    
    // Add vertices for top face (anticlockwise, looking down). 
    for (int i = 0; i < n; i++) {
      c.addVertex(new PVector(m * sin((0.5 - i) * a), -s, m * cos((0.5 - i) * a)));
    }
    // Add vertices for bottom face (anticlockwise, looking down).
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
    // Simpler method for sidelength 1
    return this.prism(n, 1); //.toSphere();
  }
  
  Manifold antiprism(int n, float s) {
    // Create an antiprism with n-sided top/bottom, sidelength s (top/bottom only, for now) and centered at the origin.
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
  
  // Conway Operations:
  // ------------------
  
  Manifold dual() {
    // Find the dual of the current manifold.
    Manifold d = new Manifold();
    for (Face f : this.faces) {
      PVector c = f.centroid();
      d.addVertex(c);
    }
    for (Vertex v : this.vertices) {
      //Vertex[] fv = new Vertex[v.edges.size()];
      List<Vertex> fv = new ArrayList<Vertex>();
      v.sortEdges();
      for (Edge e : v.edges) {
        if (v == e.start) {
          fv.add(d.vertices.get(this.faces.indexOf(e.right)));
        } else {
          fv.add(d.vertices.get(this.faces.indexOf(e.left)));
        }
      }
      d.addFace(fv.toArray(new Vertex[v.edges.size()])); // convert ArrayList to Array
    }
    return d;
  }
  
  // Other operations:
  // -----------------
  
  void toSphere() {
    // Project vertices onto a unit sphere.
    // Note: assumes that the centroid of the manifold is at the origin.
    for (Vertex v : this.vertices) {
      v.position.setMag(1);
    }
  }
  
  // Debug...
  // --------
  
  void debug(boolean detail) {
    println("// " + this + "\n");
    
    println("Vertices: " + manifold.vertices().size());
    if (detail) {
      println();
    }
    
    println("Edges: " + manifold.edges().size());
    if (detail) {
      for (Edge e : this.edges) {
        println("* " + e + ":\t" + e.left + "\t" + e.right);
      }
      println();
    }
    
    println("Faces: " + manifold.faces().size());
    if (detail) {
      for (Face f : this.faces) {
        print("* " + f + ":");
        for (Edge fe : f.edges) {
          print("\t" + fe);
        }
        println();
      }
    }
    
    println();
  }
}

