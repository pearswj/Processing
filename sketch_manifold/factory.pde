/*

 Factory class.
 Will Pearson, University of Bath, November 2012.
 
 * To create basic polyhedra (pyramids, prisms and antiprisms)
 * TODO: bipyramid, primitives (tetrahedron, cube, octahedron, dodecahedron, icosahedron)
 
 */

/////////////////////////////////////////////////////////////
//                      Factory Class                      //
/////////////////////////////////////////////////////////////

class Factory {

  Factory() {
  }
  
  //---------------------------------------------------------//
  //                       Primitives                        //
  //---------------------------------------------------------//
  
  Manifold tetrahedron() {
    return this.pyramid(3, 1, true);
  }
  
  Manifold cube() {
    return this.prism(4, 1);
  }
  
  Manifold octahedron() {
    return this.antiprism(3, 1);
  }

  //---------------------------------------------------------//
  //                         Pyramid                         //
  //---------------------------------------------------------//

  Manifold pyramid(int n, float s, boolean constrainLaterals) {
    // Create a uniform pyramid with an n-sided base, sidelength s and centered at the origin.
    Manifold t = new Manifold();

    float a = 2 * PI / n;
    boolean ignoreSideLengths = (s == 0);
    float R;
    if (ignoreSideLengths) {
      s = 1;
      //R = (0.5*s) / sin(0.5*(2 * PI / 3)); // R set for pyramid with 3-sided base, side length 1
      R = 0.7;
    }
    else {
      R = (0.5*s) / sin(0.5*a);
    }
    float h; // height
    if (constrainLaterals && n < 6) {
      h = sqrt(sq(s) - sq(R)); // length of lateral edges == length of base edges (doesn't make sense for n >= 6!)
    } 
    else {
      h = s;
    }
    s *= 0.5;

    // Add vertices for base (anticlockwise, looking down)
    for (int i = 0; i < n; i++) {
      t.addVertex(new PVector(R * sin(-i * a), h/4, R * cos(-i * a)));
    }
    t.addVertex(new PVector(0, -3*h/4, 0)); // apex

    int[] base = new int[n];
    for (int i = 0; i < n; i++) {
      t.addFace(new int[] {
        i, (i+1)%n, n
      }
      );
      base[i] = n - (i + 1); // reverse order
    }
    t.addFace(base);
    logger(this, "INFO", "pyramid; new pyramid created with " + n + " sides");
    return t;
  }

  Manifold pyramid(int n) {
    return this.pyramid(n, 0, false);
  }

  //---------------------------------------------------------//
  //                          Prism                          //
  //---------------------------------------------------------//

  Manifold prism(int n, float s) {
    // Create a prism with n-sided top/bottom, side length s and centered at the origin.
    Manifold c = new Manifold();

    float a = 2 * PI / n; // angle
    boolean ignoreSideLengths = (s == 0);
    float R;
    if (ignoreSideLengths) {
      s = 1;
      R = 0.7;
    }
    else {
      R = (0.5*s) / sin(0.5*a); // radius
    }
    
    // Add vertices for top face (anticlockwise, looking down). 
    for (int i = 0; i < n; i++) {
      c.addVertex(new PVector(R * cos(i * a), -0.5 * s, R * sin(i * a)));
    }
    // Add vertices for bottom face (anticlockwise, looking down).
    for (int i = 0; i < n; i++) {
      c.addVertex(new PVector(R * cos(i * a), 0.5 * s, R * sin(i * a)));
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
      c.addFace(new int[] {
        (i+1)%n, i, i+n, (i+1)%n+n
      }
      );
    }
    logger(this, "INFO", "prism; new prism created with " + n + " sides");
    return c;
  }

  Manifold prism(int n) {
    return this.prism(n, 0);
  }

  //---------------------------------------------------------//
  //                        Antiprism                        //
  //---------------------------------------------------------//

  Manifold antiprism(int n, float s) {
    // Create an antiprism with n-sided top/bottom, side length s (top/bottom only, for now) and centered at the origin.
    Manifold c = new Manifold();

    float a = 2 * PI / n; // angle
    boolean ignoreSideLengths = (s == 0);
    float R, h;
    if (ignoreSideLengths) {
      s = 1;
      R = 0.7;
      h = 1;
    }
    else {
      R = (0.5*s) / sin(0.5*a); // radius
      h = sqrt(1 - 0.24 * sq(1/cos(PI/(2*n)))); // height (see http://mathworld.wolfram.com/Antiprism.html)
    }

    // Add vertices for top face (anticlockwise). 
    for (int i = 0; i < n; i++) {
      c.addVertex(new PVector(R * cos(i * a), -0.5 * h, R * sin(i * a)));
    }
    // Add vertices for bottom face (anticlockwise).
    for (int i = 0; i < n; i++) {
      c.addVertex(new PVector(R * cos((0.5 + i) * a), 0.5 * h, R * sin((0.5 + i) * a)));
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
      c.addFace(new int[] {
        (i+1)%n, i, i+n
      }
      );
      c.addFace(new int[] {
        (i+1)%n, i+n, (i+1)%n+n
      }
      );
    }
    logger(this, "INFO", "antiprism; new antiprism created with " + n + " sides");
    return c;
  }

  Manifold antiprism(int n) {
    return this.antiprism(n, 0);
  }
}

