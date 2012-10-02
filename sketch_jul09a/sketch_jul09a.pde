int d;
float d2, a = PI/3, r, alpha, beta;

int diameter_init = 500;
float radius_init = 0.5*diameter_init;
int margin = 10;
int canvas = diameter_init + 2*margin;
float centre_point = 0.5*canvas;

void setup() {
  d = 100;
  size(canvas, canvas);
//  ellipse(centre_point,centre_point,diameter_init,diameter_init);
}
void draw() {
  d2 = d*(1+2*sqrt(3)/3);
  a = PI/3;
  r = 0.5 * d;
  alpha = r / tan(a);
  beta = r / sin(a);
  //println(beta);
  ellipse(centre_point, centre_point, d2, d2);
  ellipse(centre_point, centre_point- beta, d, d);
  ellipse(centre_point + r, centre_point + alpha, d, d);
  ellipse(centre_point - r, centre_point + alpha, d, d);
}
