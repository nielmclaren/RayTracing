
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
    
    float r = _rotation;
    float cosine = cos(r);
    float sine = sin(r);
    float cosineSq = cosine * cosine;
    float sineSq = sine * sine;
    
    float a = vSq * (cosineSq + 2 * m * cosine * sine + mSq * sineSq) + hSq * (mSq * cosineSq - 2 * m * cosine * sine + sineSq);
    float b = 2 * vSq * d * (cosine * sine + m * sineSq) + 2 * hSq * d * (m * cosineSq - cosine * sine);
    float c = dSq * (vSq * sineSq + hSq * cosineSq) - hSq * vSq;

    float discriminant = b * b - 4 * a * c;
    if (discriminant == 0) {
      float x = -b / (2 * a);
      float y = m * x + d;
      PVector result = new PVector(_x + x, _y + y);
      return new Intersection(result, getNormalAt(new PVector(x, y)));
    }
    
    float x0 = (-b + sqrt(discriminant)) / (2 * a);
    PVector p0 = new PVector(_x + x0, _y + m * x0 + d);
    
    float x1 = (-b - sqrt(discriminant)) / (2 * a);
    PVector p1 = new PVector(_x + x1, _y + m * x1 + d);

    float dist0 = p0.dist(source);
    float dist1 = p1.dist(source);
    boolean isP0Valid = dist0 > Constants.MIN_INTERSECTION_DISTANCE && PVector.sub(p0, source).dot(direction) > 0;
    boolean isP1Valid = dist1 > Constants.MIN_INTERSECTION_DISTANCE && PVector.sub(p1, source).dot(direction) > 0;

    if (isP0Valid && (!isP1Valid || dist0 < dist1)) {
      return new Intersection(p0, getNormalAt(p0));
    } else if (isP1Valid) {
      return new Intersection(p1, getNormalAt(p1));
    }
    return null;
  }

  private PVector getNormalAt(PVector p) {
    float h = _width / 2;
    float v = _height / 2;
    float hSq = h * h;
    float vSq = v * v;

    float r = _rotation;
    float cosine = cos(-r);
    float sine = sin(-r);
    
    float x0 = p.x - _x;
    float y0 = p.y - _y;
    float x = x0 * cosine - y0 * sine;
    float y = x0 * sine + y0 * cosine;
    
    PVector result = new PVector(-y * h/v, x * v/h);
    result.normalize();
    result.rotate(r - PI/2);
    return result;
  }

  Shape shape() {
    return Shape.ELLIPSE;
  }
}
