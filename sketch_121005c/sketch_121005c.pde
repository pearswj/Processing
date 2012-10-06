// Creating an array of objects.
Mover[] movers = new Mover[20];

void setup() {
  size(600,600);
  smooth();
  background(255);
  // Initializing all the elements of the array
  for (int i = 0; i < movers.length; i++) {
    movers[i] = new Mover(); 
  }
}

void draw() {
  noStroke();
  fill(255,10);
  rect(0,0,width,height);

  // Calling functions of all of the objects in the array.
  for (int i = 0; i < movers.length; i++) {
    movers[i].update();
    movers[i].checkEdges();
    movers[i].display(); 
  }
}

class Mover {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float topspeed;
  PVector gravity;
  float bounceCoefficient;
  float friction;
  float diameter;

  Mover() {
    location = new PVector(random(width), random(height));
    velocity = new PVector(0,0);
    topspeed = random(5,10);
    gravity = new PVector(0, 0.3);
    bounceCoefficient = -0.8;
    friction = 0.8;
    diameter = 16;
  }

  void update() {

    // Our algorithm for calculating acceleration:
    if (mousePressed == true) {
      PVector mouse = new PVector(mouseX, mouseY);
      PVector dir = PVector.sub(mouse, location);  // Find vector pointing towards mouse
      dir.normalize();     // Normalize
      dir.mult(0.5);       // Scale 
      acceleration = dir;  // Set to acceleration

      // Motion 101!  Velocity changes by acceleration.  Location changes by velocity.
      velocity.add(acceleration);
      velocity.limit(topspeed);
    }
    velocity.add(gravity);
    location.add(velocity);
  }

  void display() {
    stroke(0);
    fill(175);
    ellipse(location.x,location.y,diameter,diameter);
  }

  void checkEdges() {
    // Apply boundary conditions including coefficient of distribution
    // (proportion of energy conserved through bounce) and friction
    if (location.y >= height-diameter/2) {
      location.y = height-diameter/2;
      velocity.y = velocity.y * bounceCoefficient;
      velocity.x = velocity.x * friction;
    }
  }
}

