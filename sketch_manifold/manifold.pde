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

  // delete a face:
  //void deleteFace(Face f) {
  // check edges, if f was their left, reverse direction (e.start = e.end and e.end = e.start) and e.left = e.right,
  //}

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
    // vertices from faces
    for (Face f : this.faces) {
      PVector c = f.centroid();
      d.addVertex(c);
    }
    // faces from vertices
    for (Vertex v : this.vertices) {
      Vertex[] fv = new Vertex[v.edges.size()];
      Face[] vf = v.getFaces();
      for (int i = 0; i < vf.length; i++) {
        fv[i] = d.vertices.get(this.faces.indexOf(vf[i]));
      }
      d.addFace(fv);
    }
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
      for (Face f : v.getFaces()) {
        avgFacePoints.add(facePoints[this.faces.indexOf(f)].position);
      }
      avgFacePoints.div(v.getFaces().length);
      // average of the centers of edges the point belongs to
      PVector avgEdgePoints = new PVector();
      for (Edge e : v.edges) {
        avgEdgePoints.add(edgePoints[this.edges.indexOf(e)].position);
      }
      avgEdgePoints.div(v.edges.size());
      // calculate new coordinates
      float n = v.getFaces().length; // number of faces a point belongs to
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
    return cc;
  }

  // Loop

  Manifold loop() {
    // http://www.cs.cmu.edu/afs/cs/academic/class/15462-s12/www/lec_slides/lec07.pdf (1)
    // http://graphics.stanford.edu/~mdfisher/subdivision.html (2)
    // apply to triangular based meshes ONLY. 
    // TODO: handle boundaries
    Manifold l = new Manifold();

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
      float n = v.getFaces().length;
      // float beta; // (2)
      // if ( n > 3) {
      //   beta = 3 / (8 * n);
      // } else {
      //   beta = 0.1875;
      // }
      float beta = (1/n) * (0.625 - sq(0.375 + 0.25 * cos(2 * PI / n))); // Loop's original algorithm (1)
      println(beta);
      PVector origPoint = PVector.mult(v.position, 1 - n * beta);
      for (Face f : v.getFaces()) {
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

  // Debug...

  void debug(boolean detail) {
    println("// " + this + "\n");

    println("Vertices: " + this.vertices().size());
    if (detail) {
      for (Vertex v : this.vertices) {
        println("* " + v + ":\t" + v.position);
      }
      println();
    }

    println("Edges: " + this.edges().size());
    if (detail) {
      for (Edge e : this.edges) {
        println("* " + e + ":\t" + e.left + "\t" + e.right);
      }
      println();
    }

    println("Faces: " + this.faces().size());
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
  
  // Obj (http://en.wikipedia.org/wiki/Wavefront_.obj_file)
  
  void exportObj() {
    PrintWriter obj = createWriter("export.obj");
    // vertices: "v x y z w"
    for (Vertex v : this.vertices) {
      obj.println("v " + v.position.x + " " + v.position.y + " " + v.position.z + " 1.0");
    }
    // faces: "f v1 v2 v3 ..."
    for (Face f : this.faces) {
      obj.print("f");
      for (Vertex fv : f.vertices) {
        obj.print(" " + (this.vertices.indexOf(fv)+1)); // vertices numbered from 1 (not 0)
      }
      obj.println();
    }
    obj.flush();
    obj.close();
  }
}

