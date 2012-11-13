/**

Factory class.
Will Pearson, University of Bath, November 2012.

* To create basic polyhedra (pyramids, prisms and antiprisms)

**/

/////////////////////////////////////////////////////////////
//                     Manifold Class                      //
/////////////////////////////////////////////////////////////

class Factory {
  
  Factory() {
  }
   
  //---------------------------------------------------------//
  //                         Pyramid                         //
  //---------------------------------------------------------//
  
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
  
  //---------------------------------------------------------//
  //                          Prism                          //
  //---------------------------------------------------------//
  
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
  
  //---------------------------------------------------------//
  //                        Antiprism                        //
  //---------------------------------------------------------//
  
  Manifold antiprism(int n, float s) {
    // Create an antiprism with n-sided top/bottom, sidelength s (top/bottom only, for now) and centered at the origin.
    Manifold c = new Manifold();
    
    float a = 2 * PI / n;
    float m = (0.5*s) / sin(0.5*a); // copied from prism (TODO: figure out how to generate a uniform antiprism)
    s *= 0.5; 
    
    // Add vertices for top face (anticlockwise). 
    for (int i = 0; i < n; i++) {
      c.addVertex(new PVector(m * sin((0.5 - i) * a), -s, m * cos((0.5 - i) * a)));
    }
    // Add vertices for bottom face (anticlockwise).
    for (int i = 0; i < n; i++) {
      c.addVertex(new PVector(m * cos(i * a), s, m * sin(i * a)));
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
      c.addFace(new int[]{(i+1)%n, i, i+n});
      c.addFace(new int[]{(i+1)%n, i+n, (i+1)%n+n});
    }
    
    return c;
  }
  
  Manifold antiprism(int n) {
    // See prism short method.
    return this.antiprism(n, 1);
  }
}
