/*

 Manifold class.
 Will Pearson, University of Bath, November 2012.
 
 * pyramids, prisms and antiprisms
 * Conway operations (dual)
 * subdivision (Catmull-Clark, Loop)
 
 */

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
      Edge e = end.edgeTo(start); // find an edge that exists in the opposite dir
      if (e != null) {
        e.right = f;
        //f.edges[i] = e; // Add edge to face.
      } 
      else if (start.edgeTo(end) == null) {
        // check if an edge already exists in the same direction and if not
        // create an edge.
        this.addEdge(start, end, f);
        //f.edges[i] = this.addEdge(start, end, f);
      } 
      else {
        // don't add the new face if there's an existing edge in the same dir.
        // (something's probably wrong in the vertex order...)
        return null;
      }
      // Note: should check that there isn't already an edge in this direction
      // (i.e. face created wrong...)
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

  Edge addEdge(Edge e) {
    this.edges.add(e);
    if (!e.start.edges.contains(e)) {
      e.start.edges.add(e);
    }
    if (!e.end.edges.contains(e)) {
      e.end.edges.add(e);
    }
    return e;
  }

  Edge addEdge(Vertex start, Vertex end, Face left) {
    return this.addEdge(new Edge(start, end, left));
  }
  
  //---------------------------------------------------------//
  //            Remove vertices, faces and edges             //
  //---------------------------------------------------------//
  
  boolean removeFace(Face f) {
    // remove a face
    logger(this, "INFO", "removeFace; removing face " + f + "...");
    for (Edge e : f.edges()) {
      logger(this, "DEBUG", "removeFace; removing face " + f + " from edge " + e);
      if (e.left == f) {
        // f is on the left of the edge
        if (e.right != null) {
          // the edge has a right face, reverse the edge
          e.reverse();
          e.right = null;
        }
        else {
          // no face on right, just remove the edge
          //this.removeEdge(e);
          e.start.edges.remove(e);
          e.end.edges.remove(e);
          this.edges.remove(e);
        }
      }
      else {
        // f is on the left of the edge
        e.right = null;
      }
    }
    return this.faces.remove(f);
  }
  
  boolean removeEdge(Edge e) {
    // remove an edge
    // remove the edge from the vertices that list it (i.e. start and end)
    e.start.edges.remove(e);
    e.end.edges.remove(e);
    // remove the faces that depended on this edge
    this.removeFace(e.left);
    this.removeFace(e.right);
    return this.edges.remove(e);
  } 

  //---------------------------------------------------------//
  //                      Draw Methods                       //
  //---------------------------------------------------------//

  void drawVertices(boolean normals) {
    for (Vertex v : this.vertices) {
      v.draw(normals);
    }
  }
  
  void drawVertices() {
    this.drawVertices(false);
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
  
  // return arrays of vertices, edges and faces
  
  Vertex[] vertices() {
    return this.vertices.toArray(new Vertex[this.vertices.size()]);
  }

  Edge[] edges() {
    return this.edges.toArray(new Edge[this.edges.size()]);
  }

  Face[] faces() {
    return this.faces.toArray(new Face[this.faces.size()]);
  }

  //---------------------------------------------------------//
  //                    Conway Operations                    //
  //---------------------------------------------------------//

  // Dual

  Manifold dual() {
    // Find the dual of the current manifold.
    Manifold d = new Manifold();
    // vertices from faces
    for (Face f : this.faces) {
      d.addVertex(f.centroid());
    }
    // vertices from boundary edges
    Vertex[] boundaryPoints = new Vertex[this.edges.size()];
    //for (Edge e : this.edges) {
    for (int i = 0; i < this.edges.size(); i++) {
      if (this.edges.get(i).boundary() == true) {
        // add boundaryPoint to dual (also store in boundaryPoints for indexing)
        boundaryPoints[i] = d.addVertex(this.edges.get(i).midPoint());
      }
    }
    // faces from vertices (and boundary points)
    for (Vertex v : this.vertices) {
      if (v.edges.size() > 0) { // Check that vertex isn't an orphan 
        //Vertex[] fv = new Vertex[v.edges.size()];
        List<Vertex> fv = new ArrayList<Vertex>();
        Face[] vf = v.faces();
        logger(this, "DEBUG", "dual; " + vf.length + " faces on vertex " + v);
        if (v.edges.get(0).boundary() == true) {
          logger(this, "DEBUG", "dual; adding edge-point for boundary edge");// " + e);
          fv.add(boundaryPoints[this.edges.indexOf(v.edges.get(0))]);
        }
        //for (int i = 0; i < vf.length; i++) {
        for (Face f : vf) {
          //fv[i] = d.vertices.get(this.faces.indexOf(vf[i]));
          logger(this, "DEBUG", "dual; adding face-point for face");// " + f);
          fv.add(d.vertices.get(this.faces.indexOf(f)));
        }
        if (v.edges.get(v.edges.size()-1).boundary() == true) {
          logger(this, "DEBUG", "dual; adding edge-point for boundary edge");// " + e);
          fv.add(boundaryPoints[this.edges.indexOf(v.edges.get(v.edges.size()-1))]);
        }
        d.addFace(fv.toArray(new Vertex[0]));
      }
    }
    this.set(d);
    return d;
  }

  //---------------------------------------------------------//
  //                       Subdivision                       //
  //---------------------------------------------------------//

  // Catmull-Clark

  Manifold catmullClark() {
    // subdivide the manifold following the Catmull-Clark algorithm.
    // see http://rosettacode.org/wiki/Catmull–Clark_subdivision_surface (1)
    // and https://graphics.stanford.edu/wikis/cs148-09-summer/Assignment3Description (2)
    // TODO: handle boundaries
    Manifold cc = new Manifold();

    // for each face, a FACE POINT is created which is the average
    // of all the points of the face.
    Vertex[] facePoints = new Vertex[this.faces.size()];
    for (Face f : this.faces) {
      facePoints[this.faces.indexOf(f)] = cc.addVertex(f.centroid());
    }

    // for each edge, an EDGE POINT is created which is the average
    // between the center of the edge and the center of the segment
    // made with the face points of the two adjacent faces.
    Vertex[] edgePoints = new Vertex[this.edges.size()];
    for (Edge e : this.edges) {
      PVector edgePoint = new PVector();
      edgePoint.add(e.left.centroid());
      edgePoint.add(e.right.centroid());
      edgePoint.add(e.start.position);
      edgePoint.add(e.end.position);
      edgePoint.div(4);
      edgePoints[this.edges.indexOf(e)] = cc.addVertex(edgePoint);
    }

    // for each ORIGINAL POINT, update location based on: (-Q + 4E + (n-3)*S)/n 
    Vertex[] origPoints = new Vertex[this.vertices.size()];
    for (Vertex v : this.vertices) {
      // old coordinates
      PVector oldCoords = v.position.get();
      // average of the face points of the faces the point belongs to
      PVector avgFacePoints = new PVector();
      for (Face f : v.faces()) {
        avgFacePoints.add(facePoints[this.faces.indexOf(f)].position);
      }
      avgFacePoints.div(v.faces().length);
      // average of the centers of edges the point belongs to
      PVector avgEdgePoints = new PVector();
      for (Edge e : v.edges) {
        avgEdgePoints.add(edgePoints[this.edges.indexOf(e)].position);
      }
      avgEdgePoints.div(v.edges.size());
      // calculate new coordinates
      float n = v.faces().length; // number of faces a point belongs to
      PVector newCoords = PVector.sub(PVector.mult(avgEdgePoints, 4), avgFacePoints);
      newCoords.add(PVector.mult(oldCoords, (n-3)));
      newCoords.div(n);
      origPoints[this.vertices.indexOf(v)] = cc.addVertex(newCoords); // update
    }

    // add faces by linking up each original (moved) point with a face point and
    // the two corresponding edge points
    for (Face f : this.faces) {
      for (int i = 0; i < f.vertices.length; i++) {
        Vertex prev = f.vertices[i];
        Vertex curr = f.vertices[(i+1)%f.vertices.length];
        Vertex next = f.vertices[(i+2)%f.vertices.length];
        Edge nextEdge = curr.edgeWith(next);
        Edge prevEdge = curr.edgeWith(prev);
        Vertex[] subFace = new Vertex[4];
        subFace[0] = origPoints[this.vertices.indexOf(curr)];
        subFace[1] = edgePoints[this.edges.indexOf(nextEdge)];
        subFace[2] = facePoints[this.faces.indexOf(f)];
        subFace[3] = edgePoints[this.edges.indexOf(prevEdge)];
        cc.addFace(subFace);
      }
    }
    this.set(cc);
    return cc;
  }

  // Loop

  Manifold loop() {
    // http://www.cs.cmu.edu/afs/cs/academic/class/15462-s12/www/lec_slides/lec07.pdf (1)
    // http://graphics.stanford.edu/~mdfisher/subdivision.html (2)
    // Note: triangulates non triangular faces first. 
    // TODO: handle boundaries
    Manifold l = new Manifold();
    this.triangulate();
    // for each edge, an EDGE POINT is created
    Vertex[] edgePoints = new Vertex[this.edges.size()];
    for (Edge e : this.edges) {
      PVector edgePoint = new PVector();
      for (Vertex v : e.left.vertices) {
        if (v != e.start && v != e.end) {
          edgePoint.add(PVector.mult(v.position, 0.125));
          break;
        }
      }
      for (Vertex v : e.right.vertices) {
        if (v != e.start && v != e.end) {
          edgePoint.add(PVector.mult(v.position, 0.125));
          break;
        }
      }
      edgePoint.add(PVector.mult(e.start.position, 0.375));
      edgePoint.add(PVector.mult(e.end.position, 0.375));

      edgePoints[this.edges.indexOf(e)] = l.addVertex(edgePoint);
    }

    // for each ORIGINAL POINT, create a new point
    Vertex[] origPoints = new Vertex[this.vertices.size()];
    for (Vertex v : this.vertices) {
      float n = v.faces().length;
      float beta; // (2)
      if ( n > 3) {
        beta = 3 / (8 * n);
      }
      else {
        beta = 0.1875;
      }
      //float beta = (1/n) * (0.625 - sq(0.375 + 0.25 * cos(2 * PI / n))); // Loop's original algorithm (1)
      //println(beta);
      PVector origPoint = PVector.mult(v.position, 1 - n * beta);
      for (Face f : v.faces()) {
        origPoint.add(PVector.mult(f.vertices[(Arrays.asList(f.vertices).indexOf(v) + 1) % f.vertices.length].position, beta));
      }
      origPoints[this.vertices.indexOf(v)] = l.addVertex(origPoint);
    }

    // draw faces
    for (Face f : this.faces) {
      for (Vertex v : f.vertices) { // this part ONLY works with triangular original meshes
        Vertex[] newf = new Vertex[3];
        newf[0] = origPoints[this.vertices.indexOf(v)];
        // TODO: break the next two lines down and handle error when a subdivision of a n>3 face has been attempted 
        newf[1] = edgePoints[this.edges.indexOf(v.edgeWith(f.vertices[(Arrays.asList(f.vertices).indexOf(v) + 1) % f.vertices.length]))];
        newf[2] = edgePoints[this.edges.indexOf(v.edgeWith(f.vertices[(Arrays.asList(f.vertices).indexOf(v) + 2) % f.vertices.length]))];
        l.addFace(newf);
      }
      Vertex[] newf = new Vertex[f.vertices.length];
      for (int i = 0; i < f.vertices.length; i++) {
        newf[i] = edgePoints[this.edges.indexOf(f.vertices[i].edgeWith(f.vertices[(i+1)%f.vertices.length]))];
      }
      l.addFace(newf);
    }
    this.set(l);
    return l;
  }


  //---------------------------------------------------------//
  //                         Other...                        //
  //---------------------------------------------------------//

  void toSphere() {
    // Project vertices onto a unit sphere.
    // Note: assumes that the centroid of the manifold is at the origin.
    for (Vertex v : this.vertices) {
      v.position.setMag(1);
    }
  }
  
  void triangulate() {
    // Triangulate any faces with more than 3 sides
    // Draw fan around centroid
    Face[] originalFaces = this.faces.toArray(new Face[0]); // Clone
    for (Face f : originalFaces) {
      int n = f.vertices.length;
      if (n > 3) {
        logger(this, "DEBUG", "triangulate; triangulating face " + f);
        Vertex centroid = this.addVertex(f.centroid());
        this.removeFace(f);
        for (int i = 0; i < n; i++) {
          logger(this, "DEBUG", "triangulate; add new face");
          this.addFace(new Vertex[] {
            f.vertices[i], f.vertices[(i+1)%n], centroid
          }
          );
        }
      }
    }
  }
  
  void set(Manifold m) {
    this.vertices = m.vertices;
    this.edges = m.edges;
    this.faces = m.faces;
  }

  // Debug...
  
  void debug() {
    this.debug(true);
  }

  void debug(boolean detail) {
    println("// " + this + "\n");

    println("Vertices: " + this.vertices.size());
    if (detail) {
      for (Vertex v : this.vertices) {
        println("* " + v + ":\t" + v.position + "\t (" + v.edges.size() + " edge(s))");
      }
      println();
    }

    println("Edges: " + this.edges.size());
    if (detail) {
      for (Edge e : this.edges) {
        println("* " + e + ":\t" + e.left + "\t" + e.right);
      }
      println();
    }

    println("Faces: " + this.faces.size());
    if (detail) {
      for (Face f : this.faces) {
        print("* " + f + ":");
        //for (Edge fe : f.edges) {
        //  print("\t" + fe);
        //}
        println();
      }
    }

    println();
  }
  
  //---------------------------------------------------------//
  //                         Export                          //
  //---------------------------------------------------------//
  
  // OBJ (http://en.wikipedia.org/wiki/Wavefront_.obj_file)
  
  void exportOBJ() {
    PrintWriter obj = createWriter("export.obj");
    // vertices: "v x y z w"
    for (Vertex v : this.vertices) {
      obj.println("v " + v.position.x + " " + v.position.y + " " + v.position.z + " 1.0");
    }
    // vertex normals: "vn x y z w"
    for (Vertex v : this.vertices) {
      obj.println("vn " + v.normal().x + " " + v.normal().y + " " + v.normal().z);
    }
    // faces: "f v1 v2 v3 ..."
    for (Face f : this.faces) {
      obj.print("f");
      for (Vertex fv : f.vertices) {
        obj.print(" " + (this.vertices.indexOf(fv)+1) + "//" + (this.vertices.indexOf(fv)+1)); // vertices numbered from 1 (not 0)
      }
      obj.println();
    }
    obj.flush();
    obj.close();
  }
  
  // VRML (Indexed Face Sets: http://cs.iupui.edu/~aharris/mm/vrml4/vrml4.html)
  
  void exportVRML() {
    PrintWriter vrml = createWriter("export.wrl");
    vrml.println("#VRML V2.0 utf8");
    vrml.println("Shape {");
    vrml.println("  geometry IndexedFaceSet {\n    coord Coordinate {");
    vrml.println("      point [");
    for (Vertex v : this.vertices) {
      vrml.println("        " + v.position.x + " " + v.position.y + " " + v.position.z + ",");
    }
    vrml.println("    }\n    coordIndex [");
    for (Face f : this.faces) {
      vrml.print("      ");
      for (int i = 0; i < f.vertices.length; i++) {
        vrml.print(this.vertices.indexOf(f.vertices[i]) + ",");
      }
      vrml.println("-1,"); // end face
    }
    vrml.println("    ]\n  }\n}");
    vrml.flush();
    vrml.close();
  }
}

