PVector v1, v2, v3, r;

void setup() {
  size(500, 500);
  translate(width/2, height/2);

  // Define the three points which form the triangle.
  v1 = new PVector(0, 0, 40);
  v2 = new PVector(0, 100, 60);
  v3 = new PVector(0, 80, 120);

  // Define the triangle.
  Triangle abc = new Triangle(v1, v2, v3);

  // Define the point being tested.
  r = new PVector(0, 50, 70);

  // Test triangle (abc) with point (r).
  println("The point is on the plane of the triangle: " + abc.isPointOnPlane(r));
  println("The point is \"inside\" the triangle: " + abc.isPointInside(r));
  
  // Draw the projection to check graphically.
  abc.draw();
  stroke(100);
  point(abc.convertToLocal(r).x, abc.convertToLocal(r).y);
}


class Triangle {

  PVector a, b, c;
  PVector u, v, w;
  PVector a_, b_, c_;

  Triangle(PVector tempA, PVector tempB, PVector tempC) {
    a = tempA.get();
    b = tempB.get();
    c = tempC.get();

    u = PVector.sub(b, a);
    u.normalize();
    w = u.cross(PVector.sub(c, a));
    w.normalize();
    v = u.cross(w);
    v.normalize();

    a_ = new PVector(PVector.sub(a, a).dot(u), PVector.sub(a, a).dot(v), PVector.sub(a, a).dot(w));
    b_ = new PVector(PVector.sub(b, a).dot(u), PVector.sub(b, a).dot(v), PVector.sub(b, a).dot(w));
    c_ = new PVector(PVector.sub(c, a).dot(u), PVector.sub(c, a).dot(v), PVector.sub(c, a).dot(w));
  }

  // Check whether a point (r) lies on the same plane as the triangle.
  boolean isPointOnPlane(PVector r) {
    return (PVector.sub(r, this.a).dot(this.w) == 0);
  }

  // Check whether a point (r) lies "inside" the triangle.
  // It assumes that the triangle has been translated into u-v plane (x-y).
  boolean isPointInside(PVector r) {
    PVector r_ = new PVector(PVector.sub(r, a).dot(u), PVector.sub(r, a).dot(v), PVector.sub(r, a).dot(w));
    r_.z = 0; // Flatten localised r vector onto the plane of the triangle.

    PVector na = PVector.sub(b_, a_).cross(PVector.sub(r_, a_)).normalize(null);
    PVector nb = PVector.sub(c_, b_).cross(PVector.sub(r_, b_)).normalize(null);
    PVector nc = PVector.sub(a_, c_).cross(PVector.sub(r_, c_)).normalize(null);

    return (na.z == nb.z && na.z == nc.z);
  }

  // Draw flattened triangle.
  void draw() {
    line(a_.x, a_.y, b_.x, b_.y);
    line(b_.x, b_.y, c_.x, c_.y);
    line(c_.x, c_.y, a_.x, a_.y);
    strokeWeight(10);
    point(a_.x, a_.y);
    point(b_.x, b_.y);
    point(c_.x, c_.y);
  }

  void debug() {
    println(a + " " + b + " " + c);
    println(a_ + " " + b_ + " " + c_);
  }

  // Convert vector (r) into the local coordinate system of the triangle.
  PVector convertToLocal(PVector r) {
    return new PVector(PVector.sub(r, this.a).dot(this.u), PVector.sub(r, this.a).dot(this.v), PVector.sub(r, this.a).dot(this.w));
  }
}

