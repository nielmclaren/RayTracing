
World world;
float t;
float dt;
color theColor;

FileNamer fileNamer;

void setup() {
  size(800, 800);
  colorMode(HSB);

  t = 0;
  dt = 0.01;
  theColor = color(random(255), 255, 255);
  
  reset();
  redraw();

  fileNamer = new FileNamer("output/export", "png");
}

void draw() {}

void reset() {
  resetSimple();
  background(0);
}

void resetSimple() {
  resetSimple(0);
}

void resetSimple(float t) {
  float earthRadius = 100;
  float moonOrbitRadius = 200;
  float moonRadius = 40;
  
  Material material = getMaterial();
  world = new World()
    .addLight(new PVector(400, 100))
    .addObject(new Ellipse(400, 500, earthRadius, earthRadius)
        .rotation(PI/3 + map(t, 0, 1, 0, -PI))
        .material(material))
    .addObject(new Ellipse(
          400 + moonOrbitRadius * cos(t * 2 * PI),
          500 + moonOrbitRadius * sin(t * 2 * PI),
          moonRadius, moonRadius)
        .rotation(PI/3 + map(t, 0, 1, 0, -PI))
        .material(material));
}

void resetFuntimes() {
  int numLights = 3;
  int numRectangles = 4;
  int numEllipses = 3;
  Material material = getMaterial();
  world = new World();

  for (int i = 0; i < numLights; i++) {
    world.addLight(new PVector(random(width), random(height)));
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
    world.addObject(new Ellipse(random(width), random(height), 150, 100)
        .rotation(random(2 * PI))
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
  g.fill(64, 0);
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
  println(t);
  int numRays = 16 * 360;
  PVector direction = new PVector(1, 0);
  ArrayList<Light> lights = world.lights();
  for (Light light : lights) {
    PVector position = light.position();
    for (int i = 0; i < numRays; i++) {
      float u = (float)i / numRays;
      float v = u * 2 * PI + t * 2 * PI / numRays;
      direction.x = cos(v);
      direction.y = sin(v);
      drawRay(g, position, direction, theColor);
    }
  }
}

void drawStreamRays(PGraphics g, PVector position, float startAngle, float endAngle, color c) {
  int numRays = 120;
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
  g.stroke(hue(c), saturation(c), brightness(c), strength * 32);

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

float normalizeAngle(float v) {
  while (v < 0) {
    v += 2 * PI;
  }
  return v % (2 * PI);
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
    case 'j':
      forward();
      break;
    case 'k':
      backward();
      break;
  }
}

void saveAnimation() {
  FileNamer animationNamer = new FileNamer("output/anim", "/");
  FileNamer frameNamer = new FileNamer(animationNamer.next() + "frame", "png");

  int numFrames = 100;
  for (int i = 0; i < numFrames; i++) {
    resetSimple((float)i / numFrames);
    redraw();
    save(frameNamer.next());
  }
}

void forward() {
  t += dt;
  while (t >= 1) t -= 1;
  resetSimple(t);
  redraw(t);
}

void backward() {
  t -= dt;
  while (t < 0) t += 1;
  resetSimple(t);
  redraw(t);
}

String deg(float v) {
  return "" + floor(v * 180/PI * 10) / 10;
}
