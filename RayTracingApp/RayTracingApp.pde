
World world;

FileNamer fileNamer;

void setup() {
  size(800, 800);
  colorMode(HSB);
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
  Material material = getMaterial();
  world = new World()
    .addLight(new PVector(100, height/2))
    .addObject(new Ellipse(width/2, height/2, 300, 200)
        .rotation(atan2(mouseY - height/2, mouseX - width/2))
        .material(material));
}

void resetFuntimes() {
  int numLights = 1;
  int numRectangles = 0;
  int numEllipses = 7;
  Material material = getMaterial();
  world = new World();

  for (int i = 0; i < numLights; i++) {
    world.addLight(new PVector(width/2, height/2));
  }

  for (int i = 0; i < numRectangles; i++) {
    world.addObject(new Rectangle(random(width), random(height), random(300), random(300))
        .rotation(random(2 * PI))
        .material(material));
  }

  for (int i = 0; i < numEllipses; i++) {
    float r0 = 200;
    float r1 = 400;
    float a = PI/2 + map(i, 0, numEllipses, 0, 2 * PI);
    world.addObject(new Ellipse(width/2 + r0 * cos(a), height/2 + r0 * sin(a), 150, 100)
        .rotation(PI/2 + a + map(i, 0, numEllipses, 0, PI/2))
        .material(material))
      .addObject(new Ellipse(width/2 + r1 * cos(a), height/2 + r1 * sin(a), 200, 100)
        .rotation(PI/2 + a - map(i, 0, numEllipses, 0, PI/2))
        .material(material));
  }
}

Material getMaterial() {
  return Material.glass()
    .isTransparent(true)
    .reflectivity(0);
}

void redraw() {
  redraw(0);
}

void redraw(float t) {
  drawGrid(g);
  drawObjects(g);
  drawRays(g, t);
}

void drawGrid(PGraphics g) {
  g.pushStyle();
  g.background(0);
  g.colorMode(RGB);
  g.stroke(96, 64, 110);
  for (int x = 0; x < width; x += 100) {
    g.line(x, 0, x, height);
  }
  for (int y = 0; y < height; y += 100) {
    g.line(0, y, width, y);
  }
  g.popStyle();
}

void drawObjects(PGraphics g) {
  g.rectMode(CENTER);
  g.fill(64);
  g.noStroke();

  ArrayList<Object> objects = world.objects();
  for (Object object : objects) {
    switch (object.shape()) {
      case RECTANGLE:
        drawRectangle((Rectangle)object);
        break;
      case ELLIPSE:
        drawEllipse((Ellipse)object);
        break;
    }
  }
}

void drawRectangle(Rectangle rectangle) {
  g.pushMatrix();
  g.translate(rectangle.x(), rectangle.y());
  g.rotate(rectangle.rotation());
  g.rect(0, 0, rectangle.width(), rectangle.height());
  g.popMatrix();
}

void drawEllipse(Ellipse ellipse) {
  g.pushMatrix();
  g.translate(ellipse.x(), ellipse.y());
  g.rotate(ellipse.rotation());
  g.ellipse(0, 0, ellipse.width(), ellipse.height());
  g.popMatrix();
}

void drawRays(PGraphics g, float t) {
  ArrayList<Light> lights = world.lights();
  int numStreams = 3;
  float a = 0.05 * 2 * PI;
  for (Light light : lights) {
    PVector position = light.position();
    color c = color(20, 192, 255);

    for (int i = 0; i < numStreams; i++) {
      float startAngle = t * 2 * PI / 3 + map(i, 0, numStreams, 0, 2 * PI);
      float endAngle = startAngle + a;
      drawStreamRays(g, position, startAngle, endAngle, c);
    }
  }
}

void drawStreamRays(PGraphics g, PVector position, float startAngle, float endAngle, color c) {
  int numRays = 4 * 360;
  for (int i = 0; i < numRays; i++) {
    PVector direction = new PVector(1, 0);
    direction.rotate(map(i, 0, numRays, startAngle, endAngle));
    drawRay(g, position, direction, c);
  }
}

void drawRay(PGraphics g, PVector position, PVector direction, color c) {
  drawRay(g, position, direction, c, 0, 1);
}

// FIXME: Refactor.
void drawRay(PGraphics g, PVector position, PVector direction, color c, float startDistance, float strength) {
  g.stroke(hue(c), saturation(c), brightness(c), strength * 8);

  Intersection nearestIntersection = null;
  Object nearestIntersectionObject = null;
  float nearestIntersectionDist = Float.MAX_VALUE;

  ArrayList<Object> objects = world.objects();
  for (Object object : objects) {
    Intersection intersection = null;
    if (object.shape() == Shape.RECTANGLE) {
      Rectangle rectangle = (Rectangle)object;
      intersection = rectangle.getRayIntersection(position, direction);
    } else if (object.shape() == Shape.ELLIPSE) {
      Ellipse ellipse = (Ellipse)object;
      intersection = ellipse.getRayIntersection(position, direction);
    }

    if (intersection != null) {
      float intersectionDist = PVector.dist(intersection.point(), position);
      if (intersectionDist > Constants.MIN_INTERSECTION_DISTANCE && intersectionDist < nearestIntersectionDist) {
        nearestIntersection = intersection;
        nearestIntersectionObject = object;
        nearestIntersectionDist = intersectionDist;
      }
    }
  }

  float maxLength = Constants.MAX_RAY_LENGTH - startDistance;
  if (nearestIntersection == null || nearestIntersectionDist > maxLength) {
    g.line(position.x, position.y, position.x + maxLength * direction.x, position.y + maxLength * direction.y);
  } else {
    g.line(position.x, position.y, nearestIntersection.point().x, nearestIntersection.point().y);

    Material material = nearestIntersectionObject.material();

    float reflectivity = material.reflectivity();
    if (reflectivity > 0) {
      PVector reflected = reflect(direction, nearestIntersection);
      drawRay(g, nearestIntersection.point(), reflected, c, startDistance + nearestIntersectionDist, strength * reflectivity);
    }

    if (material.isTransparent()) {
      float index = material.indexOfRefraction();
      PVector refracted = refract(direction, nearestIntersection, index);
      if (refracted != null) {
        drawRay(g, nearestIntersection.point(), refracted, c, startDistance + nearestIntersectionDist, strength);
      }
    }
  }
}

PVector reflect(PVector direction, Intersection intersection) {
  PVector result = intersection.normal().copy();
  result.mult(2 * direction.dot(intersection.normal()));
  return PVector.sub(direction, result);
}

PVector refract(PVector incident, Intersection intersection, float indexOfRefraction) {
  PVector normal = intersection.normal();
  float incidentDotNormal = incident.dot(normal);
  if (incidentDotNormal > 0) {
    // Make sure normal points away from the incident ray vector.
    normal.mult(-1);
  }

  float n = incidentDotNormal > 0 ? indexOfRefraction / 1 : 1 / indexOfRefraction;
  float nSq = n * n;
  float incidentCos = normal.dot(incident);
  float incidentCosSq = incidentCos * incidentCos;
  float refractedSinSq = nSq * (1 - incidentCosSq);
  if (refractedSinSq > 1.0) {
    return null;
  }

  float k = n + sqrt(1.0 - refractedSinSq);
  PVector result = PVector.mult(incident, n);
  result.sub(PVector.mult(normal, k));
  return result;
}

void mouseReleased() {
  redraw(atan2(mouseY - height/2, mouseX - width/2) / (2 * PI));
}

void keyReleased() {
  switch (key) {
    case 'a':
      saveAnimation();
      break;
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

void saveAnimation() {
  FileNamer animationNamer = new FileNamer("output/anim", "/");
  FileNamer frameNamer = new FileNamer(animationNamer.next() + "frame", "png");
  resetFuntimes();

  int numFrames = 100;
  for (int i = 0; i < numFrames; i++) {
    redraw((float)i / numFrames);
    save(frameNamer.next());
  }
}

String deg(float v) {
  return "" + floor(v * 180/PI * 10) / 10;
}
