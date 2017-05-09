
class Ellipse extends Object {
  private float _x;
  private float _y;
  private float _width;
  private float _height;
  private float _rotation;

  Ellipse(float centerX, float centerY, float width, float height) {
    init(centerX, centerY, width, height, 0);
  }

  Ellipse(float centerX, float centerY, float width, float height, float rotation) {
    init(centerX, centerY, width, height, rotation);
  }

  private void init(float centerX, float centerY, float width, float height, float rotation) {
    _x = centerX;
    _y = centerY;
    _width = width;
    _height = height;
    _rotation = rotation;
  }

  float x() {
    return _x;
  }

  Ellipse x(float v) {
    _x = v;
    return this;
  }

  float y() {
    return _y;
  }

  Ellipse y(float v) {
    _y = v;
    return this;
  }

  float width() {
    return _width;
  }

  Ellipse width(float v) {
    _width = v;
    return this;
  }

  float height() {
    return _height;
  }

  Ellipse height(float v) {
    _height = v;
    return this;
  }

  float rotation() {
    return _rotation;
  }

  Ellipse rotation(float v) {
    _rotation = v;
    return this;
  }

  Ellipse material(Material material) {
    super.material(material);
    return this;
  }

  Intersection getRayIntersection(PVector source, PVector direction) {
    if (direction.x == 0) {
        // TODO: Implement ellipse ray intersection with vertical lines.
    }
    
    float m = direction.y / direction.x; // Slope.
    float d = (source.y - _y) - m * (source.x - _x); // Y-intercept.
    float mSq = m * m;
    float dSq = d * d;
    
    float h = _width / 2;
    float v = _height / 2;
    float hSq = h * h;
    float vSq = v * v;
    
    float a = vSq + hSq * mSq;
    float b = 2 * hSq * d * m;
    float c = hSq * (dSq - vSq);

    float discriminant = b * b - 4 * a * c;
    if (discriminant == 0) {
        float x = -b / (2 * a);
        float y = m * x + d;
        PVector result = new PVector(_x + x, _y + y);
        return new Intersection(result, getNormalTo(new PVector(x, y)));
    }
    
    float x0 = (-b + sqrt(discriminant)) / (2 * a);
    PVector p0 = new PVector(_x + x0, _y + m * x0 + d);
    
    float x1 = (-b - sqrt(discriminant)) / (2 * a);
    PVector p1 = new PVector(_x + x1, _y + m * x1 + d);

    if (PVector.sub(p0, source).dot(direction) > 0 && p0.dist(source) < p1.dist(source)) {
        return new Intersection(p0, getNormalTo(p0));
    } else if (PVector.sub(p1, source).dot(direction) > 0) {
        return new Intersection(p1, getNormalTo(p1));
    }
    return null;
  }

  private PVector getNormalTo(PVector p) {
     // TODO: Implement ellipse normals.
     return new PVector();
  }

  Shape shape() {
    return Shape.ELLIPSE;
  }
}
