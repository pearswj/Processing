PVector v1, v2, v3, r, u, v, w, r_, v1_, v2_, v3_;

void setup() {
  size(500,500);
  translate(width/2,height/2);
  // Define the three points which form the triangle.
  v1 = new PVector(10, 0, 0);
  v2 = new PVector(60, 30, 0);
  v3 = new PVector(20, 50, 0);

  // Define the point being tested.
  r = new PVector(30, 20, 0);

  // Define the local coordinate system.
  u = PVector.sub(v2, v1);
  u.normalize();
  w = u.cross(PVector.sub(v3, v1));
  w.normalize();
  v = u.cross(w);
  v.normalize();

  // Define r in the local coordinate system.
  //r_ = new PVector(PVector.sub(r,v1).dot(u),PVector.sub(r,v1).dot(v),PVector.sub(r,v1).dot(w));
  r_ = globalToLocal(u, v, w, r, v1);

  // Check whether r is in the plane of the triangle.
  print("Is r in the plane of the triangle? ");
  if (r_.z == 0) {
    //if (PVector.sub(v2,v1).cross(PVector.sub(v2,v1)).dot(PVector.sub(r,v1)) == 0) {
    println("yes");
  } 
  else {
    println("no");
  }

  // Define v2 and v3 in local coordinate system.
  v1_ = globalToLocal(u, v, w, v1, v1);
  println("v1_: " + v1_);
  v2_ = globalToLocal(u, v, w, v2, v1);
  v3_ = globalToLocal(u, v, w, v3, v1);
  println("v2_: " + v2_);
  println("v3_: " + v3_);

  // Check whether r is inside the triangle.
  print("Is r inside the triangle? ");
  if ((PVector.sub(v2_, v1_).cross(PVector.sub(r_, v1_)).normalize(null) == PVector.sub(v3_, v2_).cross(PVector.sub(r_, v2_)).normalize(null)) && 
      (PVector.sub(v2_, v1_).cross(PVector.sub(r_, v1_)).normalize(null) == PVector.sub(v1_, v3_).cross(PVector.sub(r_, v3_)).normalize(null))) {
    println("yes");
  } 
  else {
    println("no");
  }
  
  println(PVector.sub(v2_, v1_).cross(PVector.sub(r_, v1_)).normalize(null));
  println(PVector.sub(v3_, v2_).cross(PVector.sub(r_, v2_)).normalize(null));
  println(PVector.sub(v1_, v3_).cross(PVector.sub(r_, v3_)).normalize(null));
  
  point(0,0);
  point(v2_.x,v2_.y);
  point(v3_.x,v3_.y);
  point(r_.x,r_.y);
}

PVector globalToLocal(PVector u, PVector v, PVector w, PVector r, PVector o) {
  return new PVector(PVector.sub(r, o).dot(u), PVector.sub(r, o).dot(v), PVector.sub(r, o).dot(w));
}

