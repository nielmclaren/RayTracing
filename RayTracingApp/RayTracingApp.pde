
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
    .addRectangle(random(width), random(height), random(300), random(300), random(2 * PI))
    .addRectangle(random(width), random(height), random(300), random(300), random(2 * PI))
    .addRectangle(random(width), random(height), random(300), random(300), random(2 * PI))
    .addRectangle(random(width), random(height), random(300), random(300), random(2 * PI))
    .addRectangle(random(width), random(height), random(300), random(300), random(2 * PI));

  background(0);
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
