
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
  world = new World();
  world
    .addLight(new PVector(random(width), random(height)))
    .addLight(new PVector(random(width), random(height)))
    .addLight(new PVector(random(width), random(height)))
    .addRectangle(random(width), random(height), random(300), random(300))
    .addRectangle(random(width), random(height), random(300), random(300))
    .addRectangle(random(width), random(height), random(300), random(300));

  background(0);
}

void redraw() {
  drawLights(g);
  drawRectangles(g);
  drawRays(g);
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
  g.rectMode(CORNER);
  g.noStroke();
  g.fill(128);

  ArrayList<Object> objects = world.objects();
  for (Object object : objects) {
    if (object.shape() == Shape.RECTANGLE) {
      Rectangle rectangle = (Rectangle)object;
      g.rect(rectangle.x(), rectangle.y(), rectangle.width(), rectangle.height());
    }
  }
}

void drawRays(PGraphics g) {
  ArrayList<Light> lights = world.lights();
  for (Light light : lights) {
    PVector position = light.position();

    for (int i = 0; i < 4 * 360; i++) {
      PVector direction = new PVector(
          cos((float)i / 360 * 2 * PI),
          sin((float)i / 360 * 2 * PI));
      drawRay(g, position, direction);
    }
  }
}

void drawMouseRays(PGraphics g) {
  PVector mouse = new PVector(mouseX, mouseY);

  ArrayList<Light> lights = world.lights();
  for (Light light : lights) {
    PVector position = light.position();
    PVector direction = PVector.sub(mouse, position);
    direction.normalize();
    drawRay(g, position, direction);
  }
}

void drawRay(PGraphics g, PVector position, PVector direction) {
  int maxLength = 1200;

  g.stroke(255, 255, 0, 32);

  PVector nearestIntersection = null;
  float nearestIntersectionDist = Float.MAX_VALUE;

  ArrayList<Object> objects = world.objects();
  for (Object object : objects) {
    if (object.shape() == Shape.RECTANGLE) {
      Rectangle rectangle = (Rectangle)object;
      PVector intersection = rectangle.getRayIntersection(position, direction);
      if (intersection != null) {
        float intersectionDist = PVector.dist(intersection, position);
        if (intersectionDist < nearestIntersectionDist) {
          nearestIntersection = intersection;
          nearestIntersectionDist = intersectionDist;
        }
      }
    }
  }

  if (nearestIntersection == null) {
    g.line(position.x, position.y, position.x + maxLength * direction.x, position.y + maxLength * direction.y);
  } else {
    g.line(position.x, position.y, nearestIntersection.x, nearestIntersection.y);
  }
}

void mouseMoved() {
  redraw();
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
