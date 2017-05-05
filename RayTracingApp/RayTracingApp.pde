
final int MIN_INTERSECTION_DISTANCE = 1;
final int MAX_RAY_LENGTH = 3000;

World world;

FileNamer fileNamer;

void setup() {
  size(800, 800);
  reset();
  redraw();

  fileNamer = new FileNamer("output/export", "png");
}

void draw() {}

void reset() {
  resetFuntimes();
  background(0);
}

void resetSimple() {
  world = new World()
    .addLight(new PVector(width/2, 200))
    .addRectangle(width/2, height/2, 300, 200, atan2(mouseY - height/2, mouseX - width/2));
}

void resetFuntimes() {
  int numLights = 3;
  int numRectangles = 5;
  world = new World();

  for (int i = 0; i < numLights; i++) {
    world.addLight(new PVector(random(width), random(height)));
  }

  for (int i = 0; i < numRectangles; i++) {
    world.addRectangle(random(width), random(height), random(300), random(300), random(2 * PI));
  }
}

void redraw() {
  drawGrid(g);
  drawLights(g);
  drawRectangles(g);
  drawRays(g);
}

void drawGrid(PGraphics g) {
  g.stroke(96, 64, 110);
  for (int x = 0; x < width; x += 100) {
    g.line(x, 0, x, height);
  }
  for (int y = 0; y < height; y += 100) {
    g.line(0, y, width, y);
  }
}

void drawLights(PGraphics g) {
  g.ellipseMode(CENTER);
  g.fill(255);
  g.noStroke();

  ArrayList<Light> lights = world.lights();
  for (Light light : lights) {
    int radius = 5;
    PVector position = light.position();
    g.ellipse(position.x, position.y, radius, radius);
  }
}

void drawRectangles(PGraphics g) {
  g.rectMode(CENTER);
  g.noStroke();
  g.fill(128);

  ArrayList<Object> objects = world.objects();
  for (Object object : objects) {
    if (object.shape() == Shape.RECTANGLE) {
      Rectangle rectangle = (Rectangle)object;
      g.pushMatrix();
      g.translate(rectangle.x(), rectangle.y());
      g.rotate(rectangle.rotation());
      g.rect(0, 0, rectangle.width(), rectangle.height());
      g.popMatrix();
    }
  }
}

void drawRays(PGraphics g) {
  int numRays = 4 * 360;
  ArrayList<Light> lights = world.lights();
  for (Light light : lights) {
    PVector position = light.position();

    for (int i = 0; i < numRays; i++) {
      PVector direction = new PVector(
          cos((float)i / numRays * 2 * PI),
          sin((float)i / numRays * 2 * PI));
      drawRay(g, position, direction);
    }
  }
}

void drawRay(PGraphics g, PVector position, PVector direction) {
  drawRay(g, position, direction, 0, 1);
}

void drawRay(PGraphics g, PVector position, PVector direction, float startDistance, float strength) {
  g.stroke(255, 255, 0, strength * 32);

  Intersection nearestIntersection = null;
  float nearestIntersectionDist = Float.MAX_VALUE;

  ArrayList<Object> objects = world.objects();
  for (Object object : objects) {
    if (object.shape() == Shape.RECTANGLE) {
      Rectangle rectangle = (Rectangle)object;
      Intersection intersection = rectangle.getRayIntersection(position, direction);
      if (intersection != null) {
        float intersectionDist = PVector.dist(intersection.point(), position);
        if (intersectionDist > MIN_INTERSECTION_DISTANCE && intersectionDist < nearestIntersectionDist) {
          nearestIntersection = intersection;
          nearestIntersectionDist = intersectionDist;
        }
      }
    }
  }

  float maxLength = MAX_RAY_LENGTH - startDistance;
  if (nearestIntersection == null || nearestIntersectionDist > maxLength) {
    g.line(position.x, position.y, position.x + maxLength * direction.x, position.y + maxLength * direction.y);
  } else {
    g.line(position.x, position.y, nearestIntersection.point().x, nearestIntersection.point().y);
    PVector reflected = reflect(direction, nearestIntersection);
    drawRay(g, nearestIntersection.point(), reflected, startDistance + nearestIntersectionDist, strength * 0.6);
  }
}

PVector reflect(PVector direction, Intersection intersection) {
  PVector result = intersection.normal().copy();
  result.mult(2 * direction.dot(intersection.normal()));
  return PVector.sub(direction, result);
}

void keyReleased() {
  switch (key) {
    case 'b':
      background(0);
      break;
    case 'e':
      reset();
      redraw();
      break;
    case 'r':
      save(fileNamer.next());
      break;
  }
}
