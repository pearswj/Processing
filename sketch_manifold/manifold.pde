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
  
  //---------------------------------------------------------//
  //              Add vertices, faces and edges              //
  //---------------------------------------------------------//
  
  // Add a new vertex:
  
  Vertex addVertex(Vertex v) {
    this.vertices.add(v);
    return v;
  }
  
  Vertex addVertex(PVector position) {
    return this.addVertex(new Vertex(position));
  }
  
  // Add a new face:
  
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
        e.right = f; // check that there isn't already an edge in this direction (face created wrong...)
        //f.edges[i] = e; // Add edge to face.
      } else {
        this.addEdge(start, end, f);
        //f.edges[i] = this.addEdge(start, end, f);
      }
    }   
    this.faces.add(f);
    return f;
  }
  
  Face addFace(int[] vIndex) {
    // Add a new face, described by vertex indices
    // TODO: catch 'index out of bounds' errors
    Vertex[] vertices = new Vertex[vIndex.length];
    println("Got this far!");
    for (int i = 0; i < vIndex.length; i++) {
      vertices[i] = this.vertices.get(vIndex[i]);
    }
    return this.addFace(vertices);
  }
      
  
  // Add a new edge:
  
  Edge addEdge(Edge e) {
    this.edges.add(e);
    e.start.edges.add(e);
    e.end.edges.add(e);
    return e;
  }
  
  Edge addEdge(Vertex start, Vertex end, Face left) {
    return this.addEdge(new Edge(start, end, left));
  }
  
  //---------------------------------------------------------//
  //                      Draw Methods                       //
  //---------------------------------------------------------//

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
  
  void drawFaces(boolean normals) {
    for (Face f : this.faces) {
      f.draw(normals);
    }
  }
    
  void drawFaces() {
    this.drawFaces(false);
  }
  
  //---------------------------------------------------------//
  //                    Accessor Methods                     //
  //---------------------------------------------------------//
  
  List<Vertex> vertices() {
    return this.vertices;
  }
  
  List<Edge> edges() {
    return this.edges;
  }
  
  List<Face> faces() {
    return this.faces;
  }
  
  //---------------------------------------------------------//
  //                    Conway Operations                    //
  //---------------------------------------------------------//
  
  // Dual
  
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
  
  //---------------------------------------------------------//
  //                         Other...                        //
  //---------------------------------------------------------//
  
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
  
  void toSphere() {
    // Project vertices onto a unit sphere.
    // Note: assumes that the centroid of the manifold is at the origin.
    for (Vertex v : this.vertices) {
      v.position.setMag(1);
    }
  }
  
  // Debug...
  
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
        //print("* " + f + ":");
        //for (Edge fe : f.edges) {
        //  print("\t" + fe);
        //}
        println();
      }
    }
    
    println();
  }
}

