
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
  Material material = Material.glass()
    .isTransparent(true)
    .reflectivity(0);

  world = new World()
    .addLight(new PVector(100, height/2))
    .addObject(new Rectangle(width/2, height/2, 300, 200)
        .rotation(atan2(mouseY - height/2, mouseX - width/2))
        .material(material));
}

void resetFuntimes() {
  int numLights = 1;
  int numRectangles = 5;
  Material material = Material.glass()
    .isTransparent(true)
    .reflectivity(0);

  world = new World();

  for (int i = 0; i < numLights; i++) {
    world.addLight(new PVector(random(width), random(height)));
  }

  for (int i = 0; i < numRectangles; i++) {
    world.addObject(new Rectangle(random(width), random(height), random(300), random(300))
        .rotation(random(2 * PI))
        .material(material));
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
  g.fill(64);
  g.noStroke();

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
    color c = color(random(255), 128, 255);

    for (int i = 0; i < numRays; i++) {
      PVector direction = new PVector(
          cos((float)i / numRays * 2 * PI),
          sin((float)i / numRays * 2 * PI));
      drawRay(g, position, direction, c);
    }
  }
}

void drawRay(PGraphics g, PVector position, PVector direction, color c) {
  drawRay(g, position, direction, c, 0, 1);
}

// FIXME: Refactor.
void drawRay(PGraphics g, PVector position, PVector direction, color c, float startDistance, float strength) {
  g.stroke(hue(c), saturation(c), brightness(c), strength * 128);

  Intersection nearestIntersection = null;
  Object nearestIntersectionObject = null;
  float nearestIntersectionDist = Float.MAX_VALUE;

  ArrayList<Object> objects = world.objects();
  for (Object object : objects) {
    if (object.shape() == Shape.RECTANGLE) {
      Rectangle rectangle = (Rectangle)object;
      Intersection intersection = rectangle.getRayIntersection(position, direction);
      if (intersection != null) {
        float intersectionDist = PVector.dist(intersection.point(), position);
        if (intersectionDist > Constants.MIN_INTERSECTION_DISTANCE && intersectionDist < nearestIntersectionDist) {
          nearestIntersection = intersection;
          nearestIntersectionObject = object;
          nearestIntersectionDist = intersectionDist;
        }
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
  float cosTheta1 = -incidentDotNormal;
  float k = n * cosTheta1 - sqrt(1 - n * n * (1 - cosTheta1 * cosTheta1));
  PVector result = incident.copy();
  result.mult(n);
  result.add(PVector.mult(normal, k));
  result.normalize();
  
  return result;
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

String deg(float v) {
  return "" + floor(v * 180/PI * 10) / 10;
}
